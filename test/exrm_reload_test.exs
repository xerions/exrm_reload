defmodule ExrmReloadTest do
  use ExUnit.Case
  doctest ReleaseManager.Reload

  setup do
    {:ok, _} = :net_kernel.start([:master, :longnames])
    true = :erlang.set_cookie(node, :test_application)
    System.cmd("mix", ["do", "deps.get,", "compile,", "release"], [cd: "test/test_application"])
    :os.cmd('./test/test_application/rel/test_application/bin/test_application start') |> IO.inspect
    :pong = ping
    on_exit fn ->
      :os.cmd('./test/test_application/rel/test_application/bin/test_application stop')
      System.cmd("rm", ["-Rf", "deps", "_build", "rel"], [cd: "test/test_application"])
    end
  end

  test "test_application" do
    assert true == rpc(Application, :get_env, [:test_application, :test_value])
    assert 10 == rpc(Application, :get_env, [:test_application, :test_value2])

    {:ok, [[conf]]} = rpc(:init, :get_argument, [:conform_config])
    conf_file = conf |> List.to_string
    File.write!(conf_file, "test_value = false\nconfig.watch = true\n")
    assert :ok == rpc(ReleaseManager.Reload, :run)

    assert false == rpc(Application, :get_env, [:test_application, :test_value])
    assert 10 == rpc(Application, :get_env, [:test_application, :test_value2])
    assert "new" == rpc(Application, :get_env, [:test_application, :new_value])

    :timer.sleep(5000) # time to activate watcher
    File.write!(conf_file, "test_value = true\nconfig.watch = true\n")
    :timer.sleep(5000)
    assert true == rpc(Application, :get_env, [:test_application, :test_value])
  end

  defp rpc(module, function, args \\ []) do
    :rpc.call(:"test_application@127.0.0.1", module, function, args)
  end

  defp ping(), do: ping(3)
  defp ping(n) do
    :timer.sleep(5000)
    case :net_adm.ping :"test_application@127.0.0.1" do
      :pong -> :pong
      _ -> if n < 0, do: :pang, else: ping(n-1)
    end
  end
end
