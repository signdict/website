use Mix.Config

config :sign_dict, :environment, :test

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sign_dict, SignDictWeb.Endpoint,
  http: [port: 4001],
  server: true

config :sign_dict, :sql_sandbox, true

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :sign_dict, SignDict.Repo,
  username: "postgres",
  password: "postgres",
  database: "signdict_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Make crypto a bit faster for tests
config :bcrypt_elixir, log_rounds: 4

config :wallaby, screenshot_on_failure: true

# Using english locale for tests, this makes it
# easier for non german speaking people
config :sign_dict, SignDictWeb.Gettext, default_locale: "en"

config :sign_dict, :upload_path, "./test/uploads"

config :sign_dict, SignDictWeb.Mailer, adapter: Bamboo.TestAdapter

config :sign_dict, :queue, library: SignDict.MockExq

config :bamboo, :refute_timeout, 10

config :sign_dict, :jw_player,
  api_key: "API_KEY",
  api_secret: "API_SECRET"

config :sign_dict, :recaptcha, library: SignDict.MockRecaptcha
