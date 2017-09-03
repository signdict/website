defmodule SignDict.Backend.ListController do
  use SignDict.Web, :controller
  alias SignDict.List

  plug :load_and_authorize_resource, model: List, except: :index

  def index(conn, params) do
    lists = load_lists(conn, params)
    render(conn, "index.html", lists: lists)
  end

  def new(conn, _params) do
    changeset = List.admin_changeset(%List{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"list" => list_params}) do
    changeset = List.admin_changeset(%List{}, list_params)

    case Repo.insert(changeset) do
      {:ok, _list} ->
        conn
        |> put_flash(:info, gettext("List created successfully."))
        |> redirect(to: backend_list_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _params) do
    list = conn.assigns.list
    render(conn, "show.html", list: list)
  end

  def edit(conn, _params) do
    list = conn.assigns.list
    changeset = List.admin_changeset(list)
    render(conn, "edit.html", list: list, changeset: changeset)
  end

  def update(conn, %{"id" => _id, "list" => list_params}) do
    list = conn.assigns.list
    changeset = List.admin_changeset(list, list_params)

    case Repo.update(changeset) do
      {:ok, list} ->
        conn
        |> put_flash(:info, gettext("List updated successfully."))
        |> redirect(to: backend_list_path(conn, :show, list))
      {:error, changeset} ->
        render(conn, "edit.html", list: list, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    Repo.delete!(conn.assigns.list)

    conn
    |> put_flash(:info, gettext("List deleted successfully."))
    |> redirect(to: backend_list_path(conn, :index))
  end

  defp load_lists(conn, params) do
    if Canada.Can.can?(conn.assigns.current_user, :show, %List{}) do
      List |> order_by(:name) |> Repo.paginate(params)
    else
      %Scrivener.Page{
        entries: [], page_number: 1, page_size: 25, total_entries: 0,
        total_pages: 1
      }
    end
  end
end
