defmodule PhoenixSass.MixProject do
  use Mix.Project

  @version "0.1.8"

  @description "Auto-compile Sass to CSS within Phoenix projects without NodeJS"
  @repo_url "https://github.com/OldhamMade/phoenix_sass"

  def project do
    [
      app: :phoenix_sass,
      version: @version,
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      deps: deps(),

      # Hex
      package: hex_package(),
      description: @description,

      # Docs
      name: "phoenix_sass",
      docs: docs(),

      # Coverage
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def hex_package do
    [
      maintainers: ["Phillip Oldham"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @repo_url},
      files: ~w(lib .formatter.exs mix.exs *.md LICENSE)
    ]
  end

  defp deps do
    [
      {:sass_compiler, "~> 0.1"},
      {:temp, "~> 0.4", only: :test},
      {:excoveralls, "~> 0.10", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
    ]
  end

  defp docs do
    [extras: ["README.md"],
     main: "readme",
     source_ref: "v#{@version}",
     source_url: @repo_url]
  end
end
