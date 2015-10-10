defmodule TestApplication do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    opts = [strategy: :one_for_one, name: TestApplication.Supervisor]
    Supervisor.start_link([], opts)
  end

  def config_change(_changed, _new, _removed) do
    spawn fn -> :application.set_env(:test_application, :new_value, "new") end
    :ok
  end
end
