defmodule ExrmReload.Mixfile do
  use Mix.Project

  def project do
    [app: :exrm_reload,
     version: "0.0.1",
     elixir: ">= 1.0.5",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:conform]]
  end

  defp deps do
    [{:conform, "~> 0.16.0"},
     {:meck, github: "eproxus/meck", only: :test}]
  end
end
