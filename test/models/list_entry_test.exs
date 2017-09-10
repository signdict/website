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
      attributes = Map.merge(@valid_attrs, %{entry_id: list_entry.entry_id})
      insert(:list_entry, entry: list_entry.entry)

      changeset = ListEntry.changeset(%ListEntry{}, attributes)
      refute changeset.valid?
    end
  end

end
