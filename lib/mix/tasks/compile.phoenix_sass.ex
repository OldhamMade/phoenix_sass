defmodule Mix.Tasks.Compile.PhoenixSass do
  use Mix.Task.Compiler

  require Logger

  alias PhoenixSass.Transform

  @recursive true

  @moduledoc """
  Force Sass files to recompile when .sass/.scss files change.
  """

  @default_config [
    pattern: "priv/sass/**/*.s[ac]ss",
    output_dir: "priv/static/css",
    output_style: 3
  ]

  def run(_args) do
    app_dir()
    |> Path.join(config()[:pattern])
    |> process_patterns()
    |> check_result()
  end

  defp process_patterns(pattern) when not is_list(pattern),
    do: process_patterns([pattern])
  defp process_patterns(patterns) do
    patterns
    |> Enum.map(&process_pattern/1)
    |> List.flatten()
  end

  defp process_pattern(pattern) do
    root =
      app_dir()

    config =
      config()

    src =
      find_src_base(pattern, root)

    opts =
      sass_opts(config())

    pattern
    |> Path.wildcard()
    |> Enum.map(&to_transform/1)
    |> Enum.map(&set_root(&1, root))
    |> Enum.map(&set_srcdir(&1, src))
    |> Enum.map(&set_destdir(&1, config))
    |> Enum.map(&set_sass_opts(&1, opts))
    |> Enum.map(&do_transform/1)
  end

  defp to_transform(path),
    do: %Transform{ basename: Path.basename(path) }

  defp set_root(%Transform{} = transform, path),
    do: %{ transform | root: path }

  defp set_srcdir(%Transform{} = transform, path),
    do: %{ transform | srcdir: path }

  defp set_destdir(%Transform{} = transform, config),
    do: %{ transform | destdir: config[:output_dir] }

  defp set_sass_opts(%Transform{} = transform, opts),
    do: %{ transform | opts: opts }

  defp do_transform(%Transform{basename: "_" <> _filename} = transform),
    do: %{ transform | result: :skipped}
  defp do_transform(%Transform{} = transform) do
    with src <- to_path(transform, [:root, :srcdir, :basename]),
         dest <- to_path(transform, [:root, :destdir, :basename], "css"),
         {:ok, sass} <- Sass.compile_file(src, transform.opts),
         :ok <- File.write(dest, sass)
      do

      %{ transform | result: :ok }

    else
      error ->
        %{ transform | result: error }
    end
  end

  defp find_src_base(pattern, root) do
    pattern
    |> String.replace(root, "", global: false)
    |> Path.split()
    |> Enum.take_while(&(!is_globish?(&1)))
    |> Path.join()
  end

  defp to_path(%Transform{} = transform, parts, ext) do
    ext = String.trim(ext, ".")

    to_path(transform, parts)
    |> Path.rootname()
    |> Kernel.<>(".#{ext}")
  end
  defp to_path(%Transform{} = transform, parts) do
    parts
    |> Enum.map(&Map.get(transform, &1))
    |> Path.join()
  end

  defp is_globish?(chunk),
    do: String.contains?(chunk, ["*", "?", "[", "{"])

  defp app_dir() do
    Mix.Project.config[:app]
    |> Application.app_dir()
  end

  defp config do
    app_config =
      Mix.Project.config[:app]
      |> Application.get_env(:phoenix_sass, [])

    Keyword.merge(@default_config, app_config)
  end

  defp sass_opts(config) do
    config
    |> Keyword.drop([:pattern, :output_dir])
    |> Enum.into(%{})
  end

  defp check_result([]), do: {:noop}
  defp check_result(transforms) do
    results =
      transforms
      |> Enum.group_by(fn
        %Transform{result: {:error, _}} = _ -> :error
        t -> t.result
      end)

    processed =
      results
      |> Map.get(:ok, [])
      |> Enum.count()

    skipped =
      results
      |> Map.get(:skipped, [])
      |> Enum.count()

    Logger.info("sass processing result: #{processed} processed, #{skipped} skipped")

    results
    |> Map.get(:error)
    |> warn_of_errors()

    {:ok, []}
  end

  defp warn_of_errors(nil), do: :noop
  defp warn_of_errors(errors) do
    report =
      errors
      |> Enum.map(&format_warning/1)
      |> Enum.join("\n")

    count =
      errors
      |> Enum.count()

    Logger.warn("sass processing errors: #{count}")
    Logger.debug("sass error details:\n#{report}")
  end

  defp format_warning(%Transform{} = transform) do
    "  #{Path.join(transform.srcdir, transform.basename)} -> #{inspect transform.result}"
  end

end
