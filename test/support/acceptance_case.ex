# defmodule SignDict.AcceptanceCase do
#   use ExUnit.CaseTemplate
#
#   using do
#     quote do
#       use Wallaby.DSL
#
#       alias SignDict.Repo
#       import Ecto
#       import Ecto.Changeset
#       import Ecto.Query
#
#       import SignDictWeb.Router.Helpers
#
#       def assert_alert(page, text) do
#         page
#         |> find(Wallaby.Query.css(".sc-alert--success"), fn notification ->
#           assert notification
#                  |> has_text?(text)
#         end)
#       end
#     end
#   end
#
#   setup tags do
#     :ok = Ecto.Adapters.SQL.Sandbox.checkout(SignDict.Repo)
#
#     unless tags[:async] do
#       Ecto.Adapters.SQL.Sandbox.mode(SignDict.Repo, {:shared, self()})
#     end
#
#     metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(SignDict.Repo, self())
#     {:ok, session} = Wallaby.start_session(metadata: metadata)
#     {:ok, session: session}
#   end
# end
