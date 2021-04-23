defmodule SignDict.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sign_dict,
      version: "0.0.#{committed_at()}",
      elixir: "~> 1.2",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
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
      extra_applications: [:canada, :elixir_make, :exq, :exq_ui, :recaptcha]
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
      {:absinthe_plug, "~> 1.4.0"},
      {:absinthe, "1.4.16"},
      {:arc_ecto, "~> 0.11.1"},
      {:arc, "~> 0.11.0"},
      {:bamboo_smtp, "~> 3.1.3"},
      {:bamboo, "~> 1.7.1"},
      {:bcrypt_elixir, "~> 2.3.0"},
      {:bootleg, "~> 0.7", runtime: false},
      {:bugsnag, "~> 3.0.0"},
      {:plugsnag, "~> 1.6.0"},
      {:canary, "~> 1.1.0"},
      {:comeonin, "~> 5.3.1"},
      {:plug_cowboy, "~> 2.0"},
      {:credo, "~> 1.5.0", only: [:dev, :test]},
      {:distillery, "~> 2.1.1", runtime: false},
      {:ex_chimp, "~> 0.0.3"},
      {:ex_machina, "~> 2.1"},
      {:excoveralls, "~> 0.6", only: :test},
      {:exgravatar, "~> 2.0.0"},
      {:exq_ui, "~> 0.11.0"},
      {:exq, "~> 0.11"},
      {:gettext, "~> 0.13"},
      {:guardian, "~> 2.1.1"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix, "~> 1.4.1"},
      {:plug, "~> 1.11.0"},
      {:postgrex, "~> 0.15.0"},
      {:recaptcha, "~> 3.0.0"},
      {:scrivener_ecto, "~> 2.7.0"},
      {:scrivener_html, "~> 1.7"},
      {:secure_random, "~> 0.5"},
      {:state_mc, "~> 0.1.0"},
      {:timex, "~> 3.6"},
      {:wallaby, "~> 0.28.0", only: :test},
      {:jason, "~> 1.1"},
      {:briefly, "~> 0.3"},
      {:tzdata, "~> 1.1.0"},
      {:ex_check, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:httpoison, "~> 1.4"},
      {:downstream, "~> 1.0.0"},
      {:ua_inspector, "~> 2.0"},
      {:csv, "~> 2.3"},
      {:poison, "~> 3.1.0"},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false}
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
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  def committed_at do
    System.cmd("git", ~w[log -1 --date=short --pretty=format:%ct]) |> elem(0)
  end
end
