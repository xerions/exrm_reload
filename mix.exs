defmodule ExrmReload.Mixfile do
  use Mix.Project

  def project do
    [app: :exrm_reload,
     version: "0.2.1",
     elixir: ">= 1.0.5",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :conform, :fs],
     mod: {ExrmReload, []}]
  end

  defp deps do
    [{:conform, github: "xerions/conform", branch: "master"},
     {:fs, github: "liveforeverx/fs", branch: "master"}]
  end
end
