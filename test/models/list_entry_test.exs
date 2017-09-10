defmodule SignDict.ListEntryTest do
  use SignDict.ModelCase

  import SignDict.Factory
  alias SignDict.ListEntry

  @valid_attrs %{sort_order: 42, list_id: 1, entry_id: 1}
  @invalid_attrs %{}

  describe "changeeset/1" do
    test "changeset with valid attributes" do
      entry = insert :entry
      insert(:video_published, %{entry: entry})
      SignDict.Entry.update_current_video(entry)
      attributes = Map.merge(@valid_attrs, %{entry_id: entry.id})

      changeset = ListEntry.changeset(%ListEntry{}, attributes)
      assert changeset.valid?
    end

    test "is not valid if entry does not have current video" do
      entry = insert :entry
      attributes = Map.merge(@valid_attrs, %{entry_id: entry.id})

      changeset = ListEntry.changeset(%ListEntry{}, attributes)
      refute changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = ListEntry.changeset(%ListEntry{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "is not valid if entry already exists in list" do
      list_entry = insert :list_entry
      attributes = Map.merge(@valid_attrs, %{list_id: list_entry.list_id, entry_id: list_entry.entry_id, sort_order: 2})
      insert(:list_entry, entry: list_entry.entry)

      changeset = ListEntry.changeset(%ListEntry{}, attributes)
      assert {:error, _changeset} = Repo.insert(changeset)
    end

    test "it checks if the sort order is unique" do
      list_entry = insert :list_entry, sort_order: 1
      entry      = insert :entry_with_current_video
      attributes = Map.merge(@valid_attrs, %{list_id: list_entry.list_id, entry_id: entry.id, sort_order: 1})
      insert(:list_entry, entry: list_entry.entry)

      changeset = ListEntry.changeset(%ListEntry{}, attributes)
      assert {:error, _changeset} = Repo.insert(changeset)
    end

    test "it adds a new sort order entry" do
      list_entry = insert :list_entry, sort_order: 1
      entry      = insert :entry_with_current_video
      attributes = %{list_id: list_entry.list_id, entry_id: entry.id, sort_order: nil}
      insert(:list_entry, entry: list_entry.entry)

      changeset = ListEntry.changeset(%ListEntry{}, attributes)
      assert {:ok, _changeset} = Repo.insert(changeset)

      new_entry = SignDict.Repo.get_by(ListEntry, list_id: list_entry.list_id, entry_id: entry.id)
      assert new_entry.sort_order == 2
    end
  end

end
