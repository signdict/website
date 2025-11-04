import Config

config :sign_dict, :environment, :prod

# Do not print debug messages in production
config :logger, level: :info

config :sign_dict, :upload_path, "/var/signdict/uploads"

config :phoenix, :serve_endpoints, true
