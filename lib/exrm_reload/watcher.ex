defmodule ExrmReload.Watcher do
  use GenServer
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init([]) do
    :fs.subscribe(:exrm_reload_watcher)
    {:ok, nil}
  end

  def handle_info({_, {:fs, :file_event}, {file, _}}, state) do
    if Path.extname(file) == ".conf" or Application.get_env(:exrm_reload, :dev) do
      Logger.info "configuration changes are detected, reloading"
      ReleaseManager.Reload.run()
    end
    {:noreply, state}
  end

end
