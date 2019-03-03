defmodule SignDict.Worker.RefreshSignWritingsTest do
  use SignDict.ModelCase

  import SignDict.Factory

  alias SignDict.Worker.RefreshSignWritings

  defmodule FetchDelegesDataForEntryMock do
    def fetch_for(entry) do
      send(self(), {:for_entry, entry.id})
      :done
    end
  end

  describe "perform/2" do
    test "it fetches the images" do
      entry_id = insert(:entry).id
      RefreshSignWritings.perform(entry_id, FetchDelegesDataForEntryMock)
      assert_received {:for_entry, ^entry_id}
    end
  end
end
