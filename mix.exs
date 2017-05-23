defmodule SignDict.Mixfile do
  use Mix.Project

  def project do
    [app: :sign_dict,
     version: "0.0.#{committed_at()}",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SignDict, []},
      extra_applications: [:canada, :elixir_make, :pryin, :exq, :exq_ui]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.3"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:plug, "~> 1.3.3"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:state_mc, "~> 0.1.0"},
     {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
     {:excoveralls, "~> 0.6", only: :test},
     {:guardian, "~> 0.14.0"},
     {:comeonin, "~> 3.0"},
     {:ex_machina, "~> 2.0"},
     {:wallaby, "~> 0.17.0", only: :test},
     {:canary, "~> 1.1.0"},
     {:secure_random, "~> 0.5"},
     {:bamboo, "~> 0.8"},
     {:bamboo_smtp, "~> 1.3.0"},
     {:bugsnex, "~> 0.3.0"},
     {:arc, "~> 0.8.0"},
     {:arc_ecto, "~> 0.7.0"},
     {:exgravatar, "~> 2.0.0"},
     {:distillery, "~> 1.4.0"},
     {:timex, "~> 3.0"},
     {:pryin, "~> 1.0"},
     {:scrivener_ecto, "~> 1.0"},
     {:scrivener_html, "~> 1.7"},
     {:exq, "~> 0.8.6"},
     {:exq_ui, "~> 0.8.6"},
     {:ex_chimp, "~> 0.0.2"},
   ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end

  def committed_at do
    System.cmd("git", ~w[log -1 --date=short --pretty=format:%ct]) |> elem(0)
  end
end
