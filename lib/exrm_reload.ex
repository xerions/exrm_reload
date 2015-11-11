defmodule ExrmReload do
  use Application
  import Supervisor.Spec, warn: false

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    children = []
    opts = [strategy: :one_for_one, name: ExrmReload.Supervisor]
    {:ok, sup} = Supervisor.start_link(children, opts)
    Application.get_env(:exrm_reload, :watch) |> check_watch()
    {:ok, sup}
  end

  def config_change(changed, _new, _removed) do
    changed[:watch] |> check_watch
  end

  def check_watch(watch?) do
    if watch? do start_watcher else stop_watcher end
  end

  defp start_watcher() do
    {:ok, [[config]]} = :init.get_argument(:conform_config)
    supervisor = supervisor(:fs, [:exrm_reload_watcher, Path.dirname(config) |> to_char_list], id: :exrm_reload_watcher)
    Supervisor.start_child(ExrmReload.Supervisor, supervisor)
    Supervisor.start_child(ExrmReload.Supervisor, worker(ExrmReload.Watcher, []))
    :ok
  end

  defp stop_watcher() do
    stop_child(:exrm_reload_watcher)
    stop_child(ExrmReload.Watcher)
  end

  defp stop_child(id) do
    case Supervisor.terminate_child(ExrmReload.Supervisor, id) do
      :ok ->
        :ok = Supervisor.delete_child(ExrmReload.Supervisor, id)
      {:error, :not_found} ->
        :not_found
    end
  end
end
