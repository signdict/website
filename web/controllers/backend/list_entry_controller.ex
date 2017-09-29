defmodule SignDict.Backend.ListEntryController do
  use SignDict.Web, :controller
  alias SignDict.List
  alias SignDict.ListEntry

  plug :load_and_authorize_resource, model: ListEntry, except: :index

  def create(conn, %{"list_entry" => list_entry_params, "list_id" => list_id}) do
    {:ok, list_id} = SignDict.Permalink.cast(list_id)
    changeset = ListEntry.changeset(%ListEntry{}, Map.merge(%{"list_id" => list_id}, list_entry_params))

    case Repo.insert(changeset) do
      {:ok, _list} ->
        conn
        |> put_flash(:info, gettext("Entry added successfully."))
        |> redirect(to: backend_list_path(conn, :show, list_id))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, gettext("Entry could not be added."))
        |> redirect(to: backend_list_path(conn, :show, list_id))
    end
  end

  def delete(conn, %{"list_id" => list_id}) do
    List.remove_entry(conn.assigns.list_entry)

    conn
    |> put_flash(:info, gettext("List entry deleted successfully."))
    |> redirect(to: backend_list_path(conn, :show, list_id))
  end

  def move_up(conn, %{"list_id" => list_id}) do
    List.move_entry(conn.assigns.list_entry, -1)
    conn
    |> put_flash(:info, gettext("List entry moved up."))
    |> redirect(to: backend_list_path(conn, :show, list_id))
  end

  def move_down(conn, %{"list_id" => list_id}) do
    List.move_entry(conn.assigns.list_entry, 1)
    conn
    |> put_flash(:info, gettext("List entry moved down."))
    |> redirect(to: backend_list_path(conn, :show, list_id))
  end

end
