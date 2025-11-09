import Config

config :sign_dict, :environment, :test

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :sign_dict, SignDict.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "signdict_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sign_dict, SignDictWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4001],
  secret_key_base: "IbvRqnbFA6gSVazDZ6YE2RKTqj83ciopiRPh6l52Uj2B2bIy7LO42WpMr7uHmkYv",
  server: true

config :sign_dict, :sql_sandbox, true

# Print only warnings and errors during test
config :logger, level: :warning

# Make crypto a bit faster for tests
config :bcrypt_elixir, log_rounds: 4

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Using english locale for tests, this makes it
# easier for non german speaking people
config :sign_dict, SignDictWeb.Gettext, default_locale: "en"

config :sign_dict, :upload_path, "./test/uploads"

config :sign_dict, SignDictWeb.Mailer, adapter: Bamboo.TestAdapter
config :bamboo, :refute_timeout, 10

config :sign_dict, :newsletter, subscriber: SignDict.MockChimp

config :sign_dict, :queue, library: SignDict.MockExq

config :sign_dict, :jw_player,
  api_key: "API_KEY",
  api_secret: "API_SECRET"
