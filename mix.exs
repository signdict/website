defmodule SignDict.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sign_dict,
      version: "0.0.1-#{committed_at()}",
      elixir: "~> 1.20",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: dialyzer()
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      plt_add_apps: [:mix]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SignDict, [env: Mix.env()]},
      extra_applications: [:canada, :elixir_make, :exq]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:absinthe_plug, "~> 1.5.9"},
      {:absinthe, "~> 1.12"},
      {:waffle, "~> 2.1"},
      {:waffle_ecto, "~> 0.1"},
      {:bcrypt_elixir, "~> 3.3.2"},
      {:bugsnag, "~> 3.0.0"},
      {:plugsnag, "~> 1.7"},
      {:canary, "~> 1.2.0"},
      {:comeonin, "~> 5.5.1"},
      {:plug_cowboy, "~> 2.0"},
      {:credo, "~> 1.7.19", only: [:dev, :test]},
      {:ex_machina, "~> 2.1"},
      {:excoveralls, "~> 0.6", only: :test},
      {:exgravatar, "~> 2.0.0"},
      {:exq, "~> 0.21"},
      {:gettext, "~> 1.0"},
      {:guardian, "~> 2.5"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.14"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_pubsub, "~> 2.1"},
      {:phoenix_view, "~> 2.0.4"},
      {:phoenix, "~> 1.8"},
      {:plug, "~> 1.20"},
      {:state_mc, github: "bitboxer/state_mc"},
      {:timex, "~> 4.0"},
      # {:wallaby, "~> 0.30.1", only: :test},
      {:jason, "~> 1.4"},
      {:briefly, "~> 0.5"},
      {:tzdata, "~> 1.2"},
      {:ex_check, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:httpoison, "~> 3.0"},
      {:ua_inspector, "~> 3.0"},
      {:csv, "~> 3.2"},
      {:poison, "~> 6.0"},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:postgrex, "~> 0.22.4"},
      {:scrivener, "~> 2.7.2"},
      {:scrivener_html, git: "https://github.com/getdizzie/scrivener_html"},
      {:scrivener_ecto, "~> 3.1.0"},
      # ua_inspector still declares hackney ~> 1.0; it downloads through
      # SignDict.Services.UAInspectorDownloader instead, so hackney 4 is safe.
      {:hackney, "~> 4.12", override: true},
      # poison (needed by bugsnag) declares decimal ~> 2.1 but works with decimal 3
      {:decimal, "~> 3.1", override: true},
      {:mix_test_interactive, "~> 6.0", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      precommit: ["compile --warning-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end

  # Coolify passes SOURCE_COMMIT to the build, locally we read it from .git.
  # Fall back to "unknown" so the build never fails without git information.
  def committed_at do
    case System.get_env("SOURCE_COMMIT") do
      commit when commit not in [nil, ""] -> commit
      _ -> commit_from_git() || "unknown"
    end
  end

  defp commit_from_git do
    case File.read(".git/HEAD") do
      {:ok, "ref: " <> ref} -> read_git_file(Path.join(".git", String.trim(ref)))
      {:ok, commit} -> String.trim(commit)
      _ -> nil
    end
  end

  defp read_git_file(path) do
    case File.read(path) do
      {:ok, content} -> String.trim(content)
      _ -> nil
    end
  end
end
