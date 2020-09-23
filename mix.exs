defmodule PhoenixSass.MixProject do
  use Mix.Project

  @version "0.1.4"

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
      docs: docs()
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
      {:ex_doc, "~> 0.19", only: :docs}
    ]
  end

  defp docs do
    [extras: ["README.md"],
     main: "readme",
     source_ref: "v#{@version}",
     source_url: @repo_url]
  end
end
