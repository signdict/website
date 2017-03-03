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

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
