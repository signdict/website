Enum.each([:ex_machina, :wallaby], fn app ->
  Application.ensure_all_started(app)
end)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(SignDict.Repo, :manual)

Application.put_env(:wallaby, :base_url, SignDict.Endpoint.url())
