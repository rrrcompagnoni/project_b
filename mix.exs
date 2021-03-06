defmodule ProjectB.MixProject do
  use Mix.Project

  def project do
    [
      app: :project_b,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ProjectB.Application, []}
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.4"},
      {:jason, "~> 1.2"},
      {:finch, "~> 0.6.3"},
      {:credo, "~> 1.5"}
    ]
  end
end
