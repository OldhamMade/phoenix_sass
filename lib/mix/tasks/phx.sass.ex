defmodule Mix.Tasks.Phx.Sass do
  use Mix.Task

  @moduledoc """
  Force Sass (.sass/.scss) files to be compiled to CSS.

  #{
    File.read!("README.md")
    |> String.split(~r/<!-- MIX_TASK !-->/)
    |> Enum.at(1)
  }
  """

  @recursive true

  @shortdoc "Compile .sass/.scss files to .css"
  defdelegate run(args),
    to: Mix.Tasks.Compile.PhoenixSass
end
