defmodule ReleaseManager.Reload do
  @moduledoc """
  Reload plugin for EXRM.

  It works at the runtime system.
  It generates new sys.config by conform config and schema and applies changes via application_controller.

  I was inspired by corman (https://github.com/EchoTeam/corman)
  """

  @doc "Reload the configuration for all loaded applications."
  def run do
    (for {application, _, _} <- Application.loaded_applications, do: application) |> run
  end

  @doc "Reload the configuration for list of application."
  def run(applications) do
    {:ok, [[schema]]} = :init.get_argument(:conform_schema)
    {:ok, [[config]]} = :init.get_argument(:conform_config)
    {:ok, [[sys_config]]} = :init.get_argument(:config)
    case :init.get_argument(:running_conf) do
      {:ok, [[running_conf]]} -> File.copy! config, running_conf
      _ -> :skip
    end
    generate_sys_config(schema, config, sys_config)
    |> check_config!
    |> reload(applications)
  end

  defp generate_sys_config(schema, config, sys_config) do
    config = config |> List.to_string |> :conf_parse.file
    schema = schema |> List.to_string |> Conform.Schema.load! |> Dict.delete(:import)
    :code.is_loaded(Conform.SysConfig) == false and :code.load_file(Conform.SysConfig)
    case function_exported?(Conform.SysConfig, :read, 1) do
      true ->
        {:ok, [conf]} = Conform.SysConfig.read(sys_config |> List.to_string)
        final = Conform.Translate.to_config(schema, conf, config)
        Conform.SysConfig.write(sys_config, final) == :ok and sys_config
      false ->
        {:ok, [conf]} = Conform.Config.read(sys_config |> List.to_string)
        translated = Conform.Translate.to_config(conf, config, schema)
        final = Conform.Config.merge(conf, translated)
        Conform.Config.write(sys_config, final) == :ok and sys_config
    end
  end

  defp check_config!(sys_config) do
    {:ok, [data]} = :file.consult(sys_config)
    data
  end

  defp reload(config, applications) do
    applications |> application_specs |> change_application_data(config)
  end

  defp application_specs(applications) do
    specs = for application <- applications, do: {:application, application, make_application_spec(application)}
    incorrect_apps = for {_, application, :incorrect_spec} <- specs, do: application
    case incorrect_apps do
      [] -> specs
      _ -> {:incorrect_specs, incorrect_apps}
    end
  end

  defp make_application_spec(application) when is_atom(application) do
    {:ok, loaded_app_apec} = :application.get_all_key(application)
    case :code.where_is_file(Atom.to_char_list(application) ++ '.app') do
      :non_existing -> loaded_app_apec
      app_spec_path when is_list(app_spec_path) -> parse_app_file(app_spec_path)
    end
  end

  defp parse_app_file(app_spec_path) do
    case :file.consult(app_spec_path) do
      {:ok, [{:application, _, spec}]} -> spec
      {:error, _Reason} -> :incorrect_spec
    end
  end

  defp change_application_data(specs, config) do
    old_env = :application_controller.prep_config_change
    :ok = :application_controller.change_application_data(specs, config)
    :application_controller.config_change(old_env)
  end
end
