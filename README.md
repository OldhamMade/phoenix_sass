# Sass compiler for Phoenix

[![current build status on Travis-CI.org](https://travis-ci.org/OldhamMade/phoenix_sass.svg?branch=master)][travis]

This library compiles Sass (`.scss` and `.sass`) files to CSS
within Phoenix projects.


## Why? (Rationale)

One should be able to use Sass with a website without the need for NodeJS.


## Installation

1. Add `phoenix_sass` to your list of dependencies in `mix.exs`:

    ```diff
      defp deps do
        [
          {:phoenix, "~> 1.5.1"},
          {:phoenix_ecto, "~> 4.1"},
          {:ecto_sql, "~> 3.4"},
          {:postgrex, ">= 0.0.0"},
          {:phoenix_live_view, "~> 0.12.0"},
          {:floki, ">= 0.0.0", only: :test},
          {:phoenix_html, "~> 2.11"},
          {:phoenix_live_reload, "~> 1.2", only: :dev},
          {:phoenix_live_dashboard, "~> 0.2.0"},
          {:telemetry_metrics, "~> 0.4"},
          {:telemetry_poller, "~> 0.4"},
          {:gettext, "~> 0.11"},
          {:jason, "~> 1.0"},
    -     {:plug_cowboy, "~> 2.0"}
    +     {:plug_cowboy, "~> 2.0"},
    +     {:phoenix_sass, "~> 0.1.0"}
        ]
      end
    ```

1. Add the `:phoenix_sass` compiler to your Mix compilers so your backends
   are recompiled when Saas files change:

    ```diff
      def project do
        [
          app: :your_app,
          version: "0.1.0",
          elixir: "~> 1.9",
          elixirc_paths: elixirc_paths(Mix.env()),
    -     compilers: [:phoenix, :gettext] ++ Mix.compilers(),
    +     compilers: [:phoenix, :gettext] ++ Mix.compilers() ++ [:phoenix_sass],
          start_permanent: Mix.env() == :prod,
          releases: releases(),
          aliases: aliases(),
          deps: deps()
        ]
      end
    ```

1. Add `phoenix_sass` to your list of reloadable compilers in `config/dev.exs`:

    ```diff
      config :your_app, YourAppWeb.Endpoint,
        http: [port: 4000],
        debug_errors: true,
        code_reloader: true,
        check_origin: false,
    +   reloadable_compilers: [:gettext, :phoenix, :elixir, :phoenix_sass],
        watchers: [
    ```

1. Add your Sass dir to the live reload patterns in `config/dev.exs`, for example:

    ```diff
      config :your_app, YourAppWeb.Endpoint,
        live_reload: [
          patterns: [
    +       ~r"priv/sass/.*(sass|scss)$",
            ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
    ```

1. And finally, in `config/prod.exs` (or `config/releases.exs`) define your options:

    ```diff
    + config :your_app, :phoenix_sass,
    +   pattern: "priv/sass/**/*.s[ac]ss",   # this is the default
    +   output_dir: "priv/static/css",  # this is the default
    +   output_style: 3   # this is the default (compressed)
    ```


## Config

Config is pretty simple. `:pattern` can be a string or a list of
strings defining paths to search for Sass files.

All paths (`pattern` and `output_dir`) are relative to `Application.app_dir/1`.

Any further options are passed directly through to [`sass_compiler`][sass_compiler_opts]
along with `output_style`.


## Usage

Simply add Sass files to `priv/sass` and edit them as needed. They'll
be converted to CSS on save, and Phoenix's LiveReload will take care
of the rest.

Any Sass file prefixed with an underscore (for example, a file named
`_colors.scss`) will be skipped during processing, but should be handled
correctly as an include file (for a file named `app.scss`, for example).


[travis]: https://travis-ci.org/OldhamMade/phoenix_sass
[sass_compiler_opts]: https://hexdocs.pm/sass_compiler/Sass.html#module-currently-supported-sass-options
