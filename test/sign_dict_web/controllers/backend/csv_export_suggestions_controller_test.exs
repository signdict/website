defmodule SignDictWeb.Backend.CSVExportSuggestionsControllerTest do
  use SignDict.ConnCase
  use Bamboo.Test, shared: true

  import SignDict.Factory
  alias SignDict.Suggestions

  describe "show/2" do
    test "it downloads a csv file", %{conn: conn} do
      user = insert(:user)
      domain = insert(:domain)

      {:ok, suggestion} = Suggestions.suggest_word(domain, user, "Grandpa")

      conn =
        conn
        |> guardian_login(insert(:statistic_user))
        |> get(Helpers.backend_csv_export_suggestions_path(conn, :show))

      assert response_content_type(conn, :csv) =~ "charset=utf-8"

      body = response(conn, 200)

      assert body ==
               "Word,Description,Time\r\n#{suggestion.word},#{suggestion.description},#{Timex.format!(suggestion.inserted_at, "%Y-%0m-%0dT%H:%M:%S", :strftime)}\r\n"
    end

    test "it redirects to root if the user is not allowed to do this", %{conn: conn} do
      insert(:domain, domain: "signdict.org")

      conn =
        conn
        |> guardian_login(insert(:user))
        |> get(Helpers.backend_csv_export_suggestions_path(conn, :show))

      assert redirected_to(conn, 302) == "/"
    end
  end
end
