defmodule SignDictWeb.SuggestionController do
  @moduledoc """
  """
  use SignDictWeb, :controller
  

  alias SignDict.Domain
  alias SignDict.Suggestions

  def index(conn, params) do
    render(conn, "index.html",
      changeset: Suggestions.changeset(),
      word: params["word"],
      layout: {SignDictWeb.LayoutView, "empty.html"}
    )
  end

  def create(conn = %{assigns: %{current_user: current_user}}, %{
        "suggestion" => %{"description" => description, "word" => word}
      }) do
    domain = Domain.for(conn.host)

    case SignDict.Suggestions.suggest_word(domain, current_user, word, description) do
      {:ok, _suggestion} ->
        conn
        |> put_flash(:info, gettext("Thanks for suggesting a new entry."))
        |> redirect(to: Router.Helpers.page_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, gettext("There were problems saving your entry"))
        |> render("index.html",
          changeset: changeset,
          word: word,
          layout: {SignDictWeb.LayoutView, "empty.html"}
        )
    end
  end
end
