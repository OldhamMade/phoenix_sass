defmodule Mix.Tasks.Compile.PhoenixSassTest do
  use ExUnit.Case

  @fixtures_path "../../fixtures" |> Path.expand(__DIR__)

  defmodule TestProject do
    def project do
      [
        app: :test_project
      ]
    end
  end

  setup do
    # Temp.track!
    {:ok, test_dir} = Temp.mkdir "_build"

    System.put_env("MIX_BUILD_PATH", test_dir)

    Mix.Project.push(
      TestProject
    )

    File.mkdir_p!(app_dir())
    File.cp_r!(@fixtures_path, app_dir())

    on_exit(&Mix.Project.pop/0)

    :ok
  end

  test "setup completed successfully" do
    assert File.exists?(Path.join([app_dir(), "config", "config.exs"]))
  end

  describe "PhoenixSass" do
    test "compiles sass to css successfully" do
      Mix.Tasks.Compile.PhoenixSass.run([])

      assert File.exists?(Path.join([app_dir(), "priv", "static", "css", "main.css"]))
    end

    test "compiles sass in subdirs to css successfully" do
      Mix.Tasks.Compile.PhoenixSass.run([])

      assert File.exists?(Path.join([app_dir(), "priv", "static", "css", "sub", "extra.css"]))
    end

    test "skips sass with underscore prefix successfully" do
      Mix.Tasks.Compile.PhoenixSass.run([])

      assert File.exists?(Path.join([app_dir(), "priv", "sass", "_import.sass"]))
      assert !File.exists?(Path.join([app_dir(), "priv", "static", "css", "_import.css"]))

      assert 2 == (
        Path.join([app_dir(), "priv", "static", "css", "**", "*.css"])
        |> Path.wildcard()
        |> Enum.count()
      )
    end
  end

  defp app_dir() do
    Mix.Project.config()
    |> Mix.Project.app_path()
  end
end
