defmodule TestApplication.Mixfile do
  use Mix.Project

  def project do
    [app: :test_application, 
     version: "0.0.1",
     deps: deps]
  end

  def application do
    [mod: {TestApplication, []},
     applications: [:exrm_reload]]
  end

  def deps do
    [{:exrm_reload, path: "../../"},
     {:conform, "~> 0.16.0", override: true},
     {:exrm, github: "surik/exrm", branch: "conform_args_to_command_line"}]
  end
end
