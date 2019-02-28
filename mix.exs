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
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SignDict, []},
      extra_applications: [:canada, :elixir_make, :exq, :exq_ui]
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
      # I got compile errors on higher versions of absinthe
      {:absinthe, "1.4.13"},
      {:arc_ecto, "~> 0.8.0"},
      {:arc, "~> 0.8.0"},
      {:bamboo_smtp, "~> 1.4.0"},
      {:bamboo, "~> 0.8"},
      {:bcrypt_elixir, "~> 1.0"},
      {:bootleg, "~> 0.7", runtime: false},
      {:bugsnex, "~> 0.3.1"},
      {:canary, "~> 1.1.0"},
      {:comeonin, "~> 4.0"},
      {:cowboy, "~> 1.0"},
      {:credo, "~> 0.9.2", only: [:dev, :test]},
      {:distillery, "~> 1.5", runtime: false},
      {:ex_chimp, "~> 0.0.3"},
      {:ex_machina, "~> 2.1"},
      {:excoveralls, "~> 0.6", only: :test},
      {:exgravatar, "~> 2.0.0"},
      {:exq_ui, "~> 0.9.0"},
      {:exq, "~> 0.11"},
      {:gettext, "~> 0.13"},
      {:guardian, "~> 1.2.0"},
      {:mix_test_watch, "~> 0.6", only: :dev, runtime: false},
      {:phoenix_ecto, "~> 3.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.1", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix, "~> 1.3.2"},
      {:plug, "~> 1.5.0"},
      {:poison, "~> 3.1.0"},
      {:postgrex, ">= 0.0.0"},
      {:recaptcha, "~> 2.3.0"},
      {:scrivener_ecto, "~> 1.0"},
      {:scrivener_html, "~> 1.7"},
      {:secure_random, "~> 0.5"},
      {:state_mc, "~> 0.1.0"},
      {:timex, "~> 3.2"},
      {:wallaby, "~> 0.20.0", only: :test}
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
