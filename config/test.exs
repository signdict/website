use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sign_dict, SignDict.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :sign_dict, SignDict.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "signdict_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Make crypto a bit faster for tests
config :comeonin, :bcrypt_log_rounds, 1
