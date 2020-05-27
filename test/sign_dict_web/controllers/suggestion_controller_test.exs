defmodule SignDict.SuggestionControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory
  alias SignDict.Suggestions.Suggestion

  test "it should show a page", %{conn: conn} do
    conn = get(conn, suggestion_path(conn, :index))
    assert html_response(conn, 200) =~ "Suggest a new word"
  end

  test "it should create a new suggetion", %{conn: conn} do
    domain = insert(:domain)

    conn =
      post(
        conn,
        suggestion_path(conn, :create),
        suggestion: %{"word" => "Grandmother", "description" => "The mother of the mother"}
      )

    assert get_flash(conn, :info) ==
             "Thanks for suggesting a new entry."

    assert redirected_to(conn, 302) == "/"

    entry = Repo.get_by!(Suggestion, word: "Grandmother") |> Repo.preload(:domain)
    assert entry.user_id == nil
    assert entry.domain == domain
    assert entry.word == "Grandmother"
    assert entry.description == "The mother of the mother"
  end

  test "it should create a new suggetion and stores the user", %{conn: conn} do
    domain = insert(:domain)
    user = insert(:user)

    conn =
      conn
      |> guardian_login(user)
      |> post(
        suggestion_path(conn, :create),
        suggestion: %{"word" => "Grandmother", "description" => "The mother of the mother"}
      )

    assert get_flash(conn, :info) ==
             "Thanks for suggesting a new entry."

    assert redirected_to(conn, 302) == "/"

    entry = Repo.get_by!(Suggestion, word: "Grandmother") |> Repo.preload(:domain)
    assert entry.user_id == user.id
    assert entry.domain == domain
    assert entry.word == "Grandmother"
    assert entry.description == "The mother of the mother"
  end
end
