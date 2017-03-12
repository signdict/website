defmodule SignUp.AcceptanceCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL

      alias SignDict.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import SignDict.Router.Helpers
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SignDict.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(SignDict.Repo, {:shared, self()})
    end

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(SignDict.Repo, self())
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    {:ok, session: session}
  end
end
