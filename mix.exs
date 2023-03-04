defmodule Servy.MixProject do
  use Mix.Project

  def project do
    [
      app: :servy,
      description: "What is this?",
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex],
      mod: {Servy, []},
      env: [port: 8080]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 5.0"},
      {:httpoison, "~> 1.8"}
    ]
  end
end
