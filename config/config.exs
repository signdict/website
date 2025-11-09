# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :sign_dict,
  ecto_repos: [SignDict.Repo],
  generators: [timestamp_type: :utc_datetime]

config :sign_dict, :upload_path, "./uploads"

# Configures the endpoint
config :sign_dict, SignDictWeb.Endpoint,
  url: [host: "localhost"],
  # adapter: Bandit.PhoenixAdapter,
  render_errors: [view: SignDictWeb.ErrorView, accepts: ~w(html json)],
  # render_errors: [
  #   formats: [html: SignDictWeb.ErrorHTML, json: SignDictWeb.ErrorJSON],
  #   layout: false
  # ],
  http: [
    # Enable IPv6 and bind on all interfaces.
    # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
    # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
    # foERROR! the application :sign_dict has a different value set for key SignDictWeb.Endpoint during runtime compared to compile time. Since this application environment entry was marked as compile time, this difference can lead to different behavior than expected:r details about using IPv6 vs IPv4 and loopback vs public addresses.
    ip: {0, 0, 0, 0, 0, 0, 0, 0},
    port: "4000"
  ],
  check_origin: [
    "//localhost",
    "//signdict.org",
    "//www.signdict.org"
  ],
  pubsub_server: SignDict.PubSub,
  live_view: [signing_salt: "BxiN0kuF"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :sign_dict, SignDictWeb.Mailer, adapter: Bamboo.LocalAdapter

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Guardian, Authentication framework
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

config :bugsnag,
  release_stage: "development",
  use_logger: false,
  exception_filter: SignDict.ExceptionFilter

config :waffle, storage: Waffle.Storage.Local

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

config :ua_inspector,
  database_path: "priv/ua_inspector"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
