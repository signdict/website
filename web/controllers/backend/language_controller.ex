defmodule SignDict.Backend.LanguageController do
  use SignDict.Web, :controller
  alias SignDict.Language

  plug :load_and_authorize_resource, model: Language, except: :index

  def index(conn, _params) do
    languages = Language |> order_by(asc: :short_name) |> Repo.all
    render(conn, "index.html", languages: languages)
  end

  def new(conn, _params) do
    changeset = Language.changeset(%Language{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"language" => language_params}) do
    changeset = Language.changeset(%Language{}, language_params)

    case Repo.insert(changeset) do
      {:ok, _language} ->
        conn
        |> put_flash(:info, gettext("Language created successfully."))
        |> redirect(to: backend_language_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _params) do
    render(conn, "show.html", language: conn.assigns.language)
  end

  def edit(conn, _params) do
    language = conn.assigns.language
    changeset = Language.changeset(language)
    render(conn, "edit.html", language: language, changeset: changeset)
  end

  def update(conn, %{"id" => _id, "language" => language_params}) do
    language = conn.assigns.language
    changeset = Language.changeset(language, language_params)

    case Repo.update(changeset) do
      {:ok, language} ->
        conn
        |> put_flash(:info, gettext("Language updated successfully."))
        |> redirect(to: backend_language_path(conn, :show, language))
      {:error, changeset} ->
        render(conn, "edit.html", language: language, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    Repo.delete!(conn.assigns.language)

    conn
    |> put_flash(:info, gettext("Language deleted successfully."))
    |> redirect(to: backend_language_path(conn, :index))
  end
end
