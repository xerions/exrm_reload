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
     {:conform, github: "xerions/conform", branch: "master"},
     {:exrm, github: "xerions/exrm", branch: "master"}]
  end
end
