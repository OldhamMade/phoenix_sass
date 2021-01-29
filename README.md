# Sass compiler for Phoenix

![CI][ci-badge] [![Coverage Status][coverage-badge]][coverage-link]

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

1. Add the `:phoenix_sass` compiler to your Mix `compilers` so your backends
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
    +   pattern: "sass/**/*.s[ac]ss",  # this is the default
    +   output_dir: "static/css",      # this is the default
    +   output_style: 3   # this is the default (compressed)
    ```


## Configuration

Configuration is simple: `:pattern` can be a string or a list of
strings defining paths to search for Sass files.

All paths (`pattern` and `output_dir`) are relative to `:code.priv_dir/1`.

Any further options are passed directly through to [`sass_compiler`][sass_compiler_opts]
along with `output_style`.


## Usage

Add Sass files to the `priv` directory, define `pattern` to find them,
then edit them as needed. They'll be converted to CSS when edited,
written to `output_dir`, and Phoenix's LiveReload will see the change
and take care of the rest.

Sass files prefixed with an underscore (for example, a file named
`_colors.scss`) will be skipped during processing, but should be resolved
correctly for `@import` directives.


## Releases

During development the compiler will automatically convert Sass files
to CSS, however for releases the conversion needs to be executed
manually using the mix task:
<!-- MIX_TASK !-->

    mix phx.sass

This will find Sass files matching the `pattern` defined in your
config, convert them to CSS, and save them in the `output_dir`.

It's recommended that this step is done just before calling `mix phx.digest`:

    mix do phx.sass, phx.digest

<!-- MIX_TASK !-->

## Contributing

**Note: the project is made & maintained by a small team of humans,
who on occasion may make mistakes and omissions. Please do not
hesitate to point out if you notice a bug or something missing, and
consider contributing if you can.**

The project is managed on a best-effort basis, and aims to be "good
enough". If there are features missing please raise a ticket or create
a Pull Request by following these steps:

1.  [Fork it](/fork)
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Raise a new pull request via GitHub

## Liability

We take no responsibility for the use of our tool, or external
instances provided by third parties. We strongly recommend you abide
by the valid official regulations in your country. Furthermore, we
refuse liability for any inappropriate or malicious use of this
tool. This tool is provided to you in the spirit of free, open
software.

You may view the LICENSE in which this software is provided to you
[here](./LICENSE).

> 8. Limitation of Liability. In no event and under no legal theory,
>    whether in tort (including negligence), contract, or otherwise,
>    unless required by applicable law (such as deliberate and grossly
>    negligent acts) or agreed to in writing, shall any Contributor be
>    liable to You for damages, including any direct, indirect, special,
>    incidental, or consequential damages of any character arising as a
>    result of this License or out of the use or inability to use the
>    Work (including but not limited to damages for loss of goodwill,
>    work stoppage, computer failure or malfunction, or any and all
>    other commercial damages or losses), even if such Contributor
>    has been advised of the possibility of such damages.

[ci-badge]: https://github.com/OldhamMade/phoenix_sass/workflows/CI/badge.svg
[coverage-badge]: https://coveralls.io/repos/github/OldhamMade/phoenix_sass/badge.svg
[coverage-link]: https://coveralls.io/github/OldhamMade/phoenix_sass
[sass_compiler_opts]: https://hexdocs.pm/sass_compiler/Sass.html#module-currently-supported-sass-options
