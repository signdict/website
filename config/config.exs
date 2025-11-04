# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

# General application configuration
config :sign_dict, SignDictWeb.Endpoint, generators: [timestamp_type: :utc_datetime]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :sign_dict, SignDict.Guardian,
  # optional
  allowed_algos: ["HS512"],
  issuer: "SignDict",
  ttl: {30, :days},
  # optional
  verify_issuer: true,
  secret_key: "ogqsU0chmc/6sNe2piXqwHpGldTcZUXhql6HNQusM2kLQOZI/0dm0oz7xlVW3VmJ"

# For now the default is german. We might want to
# do something smarter later where we detect the language
# sent from the browser to set a reasonable default
config :sign_dict, SignDictWeb.Gettext, default_locale: "de"

config :canary,
  repo: SignDict.Repo,
  unauthorized_handler: {SignDictWeb.GuardianErrorHandler, :handle_unauthorized},
  not_found_handler: {SignDictWeb.GuardianErrorHandler, :handle_resource_not_found}

config :sign_dict, SignDictWeb.Mailer, adapter: Bamboo.LocalAdapter

config :bugsnag,
  release_stage: "development",
  use_logger: false,
  exception_filter: SignDict.ExceptionFilter

config :waffle, storage: Waffle.Storage.Local

config :sign_dict, :upload_path, "./uploads"

config :scrivener_html,
  routes_helper: SignDictWeb.Router.Helpers,
  # If you use a single view style everywhere, you can configure it here. See View Styles below for more info.
  view_style: :bootstrap

config :exq,
  scheduler_enable: true,
  queues: [
    # the transcoder queue is rate limited by jw_player => only 1 worker
    {"transcoder", 1},
    {"default", 3},
    {"sign_writings", 1}
  ],
  json_library: Jason

config :exq_ui, server: false

config :sign_dict, :jw_player,
  api_key: "API_KEY",
  api_secret: "API_SECRET"

config :sign_dict, :wps_importer, url: "http://localhost:8081/pi_json", domain: "test.local"

config :sign_dict, :wps_sign_importer, url: "http://localhost:8081/sign_writing"

config :sign_dict, :queue, library: Exq

config :phoenix, :json_library, Jason

config :ua_inspector,
  database_path: "priv/ua_inspector"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
