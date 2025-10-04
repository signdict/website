defmodule SignDict do
  use Application

  alias SignDictWeb.Endpoint

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, args) do
    # Define workers and child supervisors to be supervised
    default_children = [
      # Start the Ecto repository
      {SignDict.Repo, []},
      # Start the endpoint when the application starts
      {Endpoint, []},
      # Workers ->
      # worker(SignDict.WpsCronjob, [])

      {Phoenix.PubSub, [name: SignDict.PubSub, adapter: Phoenix.PubSub.PG2]}
    ]

    # 21:27:37.788 [warning] The :pubsub key in your SignDictWeb.Endpoint is deprecated.
    #
    # You must now start the pubsub in your application supervision tree.
    # Go to lib/my_app/application.ex and add the following:
    #
    #
    # Now, back in your config files in config/*, you can remove the :pubsub
    # key and add the :pubsub_server key, with the PubSub name:
    # pubsub_server: SignDict.PubSub
    children =
      case args do
        [env: :prod] ->
          default_children

        [env: :test] ->
          default_children ++
            [
              {Plug.Cowboy,
               scheme: :http, plug: SignDict.Importer.Wps.MockController, options: [port: 8081]}
            ]

        [env: :dev] ->
          default_children

        [_] ->
          default_children
      end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SignDict.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
