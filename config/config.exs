# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :sign_dict,
  ecto_repos: [SignDict.Repo]

# Configures the endpoint
config :sign_dict, SignDict.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "wxZpIUhB1jFBI2uxI2r6HOJUEwVgQ3rYGqtXS2ODZq0fQNC9lNbFOy7IFVr9T7M4",
  render_errors: [view: SignDict.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SignDict.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "SignDict",
  ttl: {30, :days},
  verify_issuer: true, # optional
  secret_key: "ogqsU0chmc/6sNe2piXqwHpGldTcZUXhql6HNQusM2kLQOZI/0dm0oz7xlVW3VmJ",
  serializer: SignDict.GuardianSerializer

# For now the default is german. We might want to
# do something smarter later where we detect the language
# sent from the browser to set a reasonable default
config :sign_dict, SignDict.Gettext, default_locale: "de"

config :canary, repo: SignDict.Repo,
  unauthorized_handler: {SignDict.GuardianErrorHandler, :handle_unauthorized},
  not_found_handler: {SignDict.GuardianErrorHandler, :handle_resource_not_found}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

