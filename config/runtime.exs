import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/hello start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :sign_dict, SignDictWeb.Endpoint, server: true
end

if config_env() == :prod do
  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :sign_dict, SignDict.Repo,
    username: System.get_env("DB_USERNAME"),
    password: System.get_env("DB_PASSWORD"),
    database: System.get_env("DB_DATABASE"),
    hostname: System.get_env("DB_HOSTNAME"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  host = System.get_env("PHX_HOST") || "signdict.org"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :sign_dict, SignDictWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    check_origin: [
      "//localhost",
      "//signdict.org",
      "//www.signdict.org"
    ],
    cache_static_manifest: "priv/static/cache_manifest.json",
    root: ".",
    socket_options: maybe_ipv6

  config :sign_dict, SignDictWeb.Endpoint, secret_key_base: System.get_env("SECRET_KEY_BASE")

  config :bugsnag,
    release_stage: "production",
    use_logger: true,
    api_key: System.get_env("BUGSNAG_API_KEY")

  config :sign_dict, SignDictWeb.Mailer,
    adapter: Bamboo.SMTPAdapter,
    server: "smtp.mailbox.org",
    port: 465,
    username: "mail@signdict.org",
    password: System.get_env("SMTP_PASSWORD"),
    tls: :if_available,
    ssl: true,
    retries: 1

  config :sign_dict, :jw_player,
    api_key: System.get_env("JW_PLAYER_API_KEY"),
    api_secret: System.get_env("JW_PLAYER_API_SECRET")

  config :sign_dict, :wps_importer,
    url: System.get_env("WPS_IMPORT_ROOM"),
    domain: System.get_env("WPS_IMPORT_DOMAIN")

  config :sign_dict, :wps_sign_importer, url: System.get_env("WPS_SIGN_IMPORT_ROOM")

  config :ua_inspector,
    database_path: System.get_env("UA_INSPECTOR_PATH")
end
