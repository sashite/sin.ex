defmodule Sashite.Sin.MixProject do
  use Mix.Project

  @version "2.1.0"
  @source_url "https://github.com/sashite/sin.ex"

  def project do
    [
      app: :sashite_sin,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Sashite.Sin",
      source_url: @source_url,
      homepage_url: "https://sashite.dev/specs/sin/",
      docs: [
        main: "readme",
        extras: ["README.md", "LICENSE"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description do
    "SIN (Style Identifier Notation) implementation for Elixir. " <>
      "Provides a rule-agnostic format for identifying player styles in abstract strategy " <>
      "board games with immutable identifier structs and functional programming principles."
  end

  defp package do
    [
      name: "sashite_sin",
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE),
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "Specification" => "https://sashite.dev/specs/sin/1.0.0/",
        "Documentation" => "https://hexdocs.pm/sashite_sin"
      },
      maintainers: ["Cyril Kato"]
    ]
  end
end
