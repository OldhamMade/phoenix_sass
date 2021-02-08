defmodule Mix.Tasks.Compile.PhoenixSassTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  @fixtures_path "../../fixtures" |> Path.expand(__DIR__)

  defmodule TestProject do
    def project do
      [
        app: :test_project
      ]
    end
  end

  setup do
    # create a temporary directory to sandbox the changes,
    # and enable tracking to delete when done
    Temp.track!()
    {:ok, test_dir} = Temp.mkdir "_build"

    # add the project to the env
    Mix.Project.push(
      TestProject
    )

    # set the build path to the new temp dir
    System.put_env("MIX_BUILD_PATH", test_dir)

    # "mock" the env so funcs in erlang's :code module such as
    # :code.lib_dir/0, :code.priv_dir/1, etc. can resolve the
    # temp files
    ebin_path = Path.join(test_app_dir(), "ebin")
    File.mkdir_p!(ebin_path)
    Code.prepend_path(ebin_path)

    # copy the Sass fixtures to the test priv dir
    File.mkdir_p!(test_priv_dir())
    File.cp_r!(@fixtures_path, test_app_dir())

    # rollback on exit
    on_exit(&Mix.Project.pop/0)

    :ok
  end

  test "setup completed successfully" do
    assert File.exists?(Path.join([test_app_dir(), "config", "config.exs"]))
  end

  describe "PhoenixSass" do
    test ":ok for no sass files" do
      File.rm_rf!(Path.join(test_app_dir(), "priv/*"))

      assert Mix.Tasks.Phx.Sass.run([]) == :ok
    end

    test ":error when priv_dir inaccessible" do
      File.rm_rf!(test_app_dir())

      {result, msg} = Mix.Tasks.Phx.Sass.run([])

      assert result == :error
      assert msg =~ "priv_dir path invalid or inaccessible:"
    end

    test "compiles sass to css successfully" do
      Mix.Tasks.Phx.Sass.run([])

      assert File.exists?(Path.join([test_priv_dir(), "static", "css", "main.css"]))
    end

    test "compiles sass in subdirs to css successfully" do
      Mix.Tasks.Phx.Sass.run([])

      assert File.exists?(Path.join([test_priv_dir(), "static", "css", "sub", "extra.css"]))
    end

    test "skips sass with underscore prefix successfully" do
      Mix.Tasks.Phx.Sass.run([])

      assert File.exists?(Path.join([test_priv_dir(), "sass", "_import.sass"]))
      assert !File.exists?(Path.join([test_priv_dir(), "static", "css", "_import.css"]))

      assert 2 == (
        Path.join([test_priv_dir(), "static", "css", "**", "*.css"])
        |> Path.wildcard()
        |> Enum.count()
      )
    end

    test "errors are handled properly" do
      Path.join(test_app_dir(), "priv/sass/main.sass")
      |> File.write("\n*\n  backgroun-color #", [:append])

      assert Mix.Tasks.Phx.Sass.run([]) == :ok
      assert capture_log(fn -> Mix.Tasks.Phx.Sass.run([]) end) =~ "sass processing errors: 1"
    end
  end

  defp test_app_dir() do
    Mix.Project.config()
    |> Mix.Project.app_path()
  end

  defp test_priv_dir() do
    test_app_dir()
    |> Path.join("priv")
  end
end
