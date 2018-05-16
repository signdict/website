defmodule SignDict.ListTest do
  use SignDict.ModelCase

  import SignDict.Factory

  alias SignDict.List

  @valid_attrs %{
    name: "some content",
    description: "some description",
    sort_order: "manual",
    type: "categorie-list"
  }
  @invalid_attrs %{}

  describe "admin_changeset" do
    test "admin_changeset with valid attributes" do
      changeset = List.admin_changeset(%List{}, @valid_attrs)
      assert changeset.valid?
    end

    test "admin_changeset with invalid attributes" do
      changeset = List.admin_changeset(%List{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "entries/1" do
    test "returns list entries in order of their sort id" do
      list = insert(:list, sort_order: "manual")
      entry_without_video = insert(:entry, text: "Remove Me")
      list_entry_1 = insert(:list_entry, list: list, sort_order: 2)
      list_entry_2 = insert(:list_entry, list: list, sort_order: 3)
      list_entry_3 = insert(:list_entry, list: list, sort_order: 1)
      insert(:list_entry, list: list, sort_order: 4, entry: entry_without_video)

      assert Enum.map(List.entries(list), & &1.id) == [
               list_entry_3.id,
               list_entry_1.id,
               list_entry_2.id
             ]
    end

    test "returns list entries in alphabetical order" do
      list = insert(:list, sort_order: "alphabetical_asc")
      entry_1 = insert(:entry_with_current_video, text: "Cherry")
      entry_2 = insert(:entry_with_current_video, text: "Banana")
      entry_3 = insert(:entry_with_current_video, text: "Apple")
      entry_4 = insert(:entry, text: "Remove Me")
      list_entry_1 = insert(:list_entry, list: list, sort_order: 1, entry: entry_1)
      list_entry_2 = insert(:list_entry, list: list, sort_order: 2, entry: entry_2)
      list_entry_3 = insert(:list_entry, list: list, sort_order: 3, entry: entry_3)
      insert(:list_entry, list: list, sort_order: 4, entry: entry_4)

      assert Enum.map(List.entries(list), & &1.id) == [
               list_entry_3.id,
               list_entry_2.id,
               list_entry_1.id
             ]
    end

    test "returns list entries in reversed alphabetical order" do
      list = insert(:list, sort_order: "alphabetical_desc")
      entry_1 = insert(:entry_with_current_video, text: "Cherry")
      entry_2 = insert(:entry_with_current_video, text: "Banana")
      entry_3 = insert(:entry_with_current_video, text: "Apple")
      entry_4 = insert(:entry, text: "Remove Me")
      list_entry_1 = insert(:list_entry, list: list, sort_order: 1, entry: entry_1)
      list_entry_2 = insert(:list_entry, list: list, sort_order: 2, entry: entry_2)
      list_entry_3 = insert(:list_entry, list: list, sort_order: 3, entry: entry_3)
      insert(:list_entry, list: list, sort_order: 4, entry: entry_4)

      assert Enum.map(List.entries(list), & &1.id) == [
               list_entry_1.id,
               list_entry_2.id,
               list_entry_3.id
             ]
    end
  end

  describe "remove_entry/1" do
    test "it removes an item and updates the sort order" do
      list = insert(:list, sort_order: "alphabetical_desc")
      entry_1 = insert(:entry_with_current_video, text: "Cherry")
      entry_2 = insert(:entry_with_current_video, text: "Banana")
      entry_3 = insert(:entry_with_current_video, text: "Apple")
      list_entry_1 = insert(:list_entry, list: list, sort_order: 1, entry: entry_1)
      list_entry_2 = insert(:list_entry, list: list, sort_order: 2, entry: entry_2)
      list_entry_3 = insert(:list_entry, list: list, sort_order: 3, entry: entry_3)

      List.remove_entry(list_entry_2)

      assert Enum.map(List.entries(list), &{&1.id, &1.sort_order}) == [
               {list_entry_1.id, 1},
               {list_entry_3.id, 2}
             ]
    end
  end

  describe "move_entry/2" do
    setup do
      list = insert(:list, sort_order: "manual")
      list_entry_1 = insert(:list_entry, list: list, sort_order: 1)
      list_entry_2 = insert(:list_entry, list: list, sort_order: 2)
      list_entry_3 = insert(:list_entry, list: list, sort_order: 3)

      %{
        list: list,
        list_entry_1: list_entry_1,
        list_entry_2: list_entry_2,
        list_entry_3: list_entry_3
      }
    end

    test "it moves a list entry up", %{
      list: list,
      list_entry_1: list_entry_1,
      list_entry_2: list_entry_2,
      list_entry_3: list_entry_3
    } do
      list_entry_2 = List.move_entry(list_entry_2, -1)

      assert Enum.map(List.entries(list), &{&1.id, &1.sort_order}) == [
               {list_entry_2.id, 1},
               {list_entry_1.id, 2},
               {list_entry_3.id, 3}
             ]
    end

    test "it moves a list entry down", %{
      list: list,
      list_entry_1: list_entry_1,
      list_entry_2: list_entry_2,
      list_entry_3: list_entry_3
    } do
      list_entry_2 = List.move_entry(list_entry_2, 1)

      assert Enum.map(List.entries(list), &{&1.id, &1.sort_order}) == [
               {list_entry_1.id, 1},
               {list_entry_3.id, 2},
               {list_entry_2.id, 3}
             ]
    end

    test "it does not move the entry if it is the first", %{
      list: list,
      list_entry_1: list_entry_1,
      list_entry_2: list_entry_2,
      list_entry_3: list_entry_3
    } do
      list_entry_1 = List.move_entry(list_entry_1, -1)

      assert Enum.map(List.entries(list), &{&1.id, &1.sort_order}) == [
               {list_entry_1.id, 1},
               {list_entry_2.id, 2},
               {list_entry_3.id, 3}
             ]
    end

    test "it does not move the entry if it is the last", %{
      list: list,
      list_entry_1: list_entry_1,
      list_entry_2: list_entry_2,
      list_entry_3: list_entry_3
    } do
      list_entry_3 = List.move_entry(list_entry_3, 1)

      assert Enum.map(List.entries(list), &{&1.id, &1.sort_order}) == [
               {list_entry_1.id, 1},
               {list_entry_2.id, 2},
               {list_entry_3.id, 3}
             ]
    end
  end

  describe "list_with_entry/2" do
    test "it returns the lists for an entry" do
      list_entry_1 = insert(:list_entry)
      list_entry_2 = insert(:list_entry)

      assert List.lists_with_entry(list_entry_1.entry) == [list_entry_1.list]
      assert List.lists_with_entry(list_entry_2.entry) == [list_entry_2.list]
    end
  end

  describe "Phoenix.Param" do
    test "it creates a nice permalink for the list" do
      assert Phoenix.Param.to_param(%List{id: 1, name: "My name is my castle!"}) ==
               "1-my-name-is-my-castle"
    end
  end
end
