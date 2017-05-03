use Mix.Config

config :sign_dict, :environment, :prod

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
#
# You should also configure the url host to something
# meaningful, we use this information when generating URLs.
#
# Finally, we also include the path to a manifest
# containing the digested version of static files. This
# manifest is generated by the mix phoenix.digest task
# which you typically run after static files are built.
config :sign_dict, SignDict.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: "beta.signdict.org", port: 80],
  cache_static_manifest: "priv/static/manifest.json",
  root: ".",
  server: true,
  version: Mix.Project.config[:version]

# Do not print debug messages in production
config :logger, level: :info

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :sign_dict, SignDict.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :sign_dict, SignDict.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :sign_dict, SignDict.Endpoint, server: true
#

config :sign_dict, SignDict.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :sign_dict, :upload_path, "/home/bitboxer/deployments/sign_dict/uploads"

config :sign_dict, SignDict.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("DB_DATABASE"),
  hostname: System.get_env("DB_HOSTNAME"),
  pool_size: 20

config :phoenix, :serve_endpoints, true

config :bugsnex, :release_stage, "production"
config :bugsnex, :use_logger, true
config :bugsnex, :api_key, System.get_env("BUGSNAG_API_KEY")

config :pryin,
       api_key: System.get_env("PRYIN_API_KEY"),
       enabled: true,
       env: :prod
