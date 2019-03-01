defmodule SignDict.Services.FetchDelegesDataFroEntryTest do
  use SignDict.ModelCase, async: true
  import SignDict.Factory
  alias SignDict.Entry
  alias SignDict.Services.FetchDelegesDataFroEntry

  describe "fetch_for/1" do
    test "it will load all datasets into the database and updates the images" do
      entry = insert(:entry, text: "Hallo")
      FetchDelegesDataFroEntry.fetch_for(entry)

      # TODO: test result
    end

    test "it will not update anything if last update younger than three days" do
      # todo: implement
    end

    test "does not update image if image is not modified" do
      # todo: implement
    end

    test "only update images that are active" do
    end

    test "delete items that are no longer returend by the deleges api" do
      # todo: implement
    end
  end
end
