defmodule SignDict.Services.FetchDelegesDataForEntryTest do
  use SignDict.ModelCase, async: true
  import SignDict.Factory
  alias SignDict.Entry
  alias SignDict.SignWriting
  alias SignDict.Services.FetchDelegesDataForEntry

  defmodule MockPoison do
    def get!("https://server.delegs.de/delegseditor/signwritingeditor/signitems?word=Hallo") do
      %{
        status_code: 200,
        body:
          "([{\"id\":\"388\",\"word\":\"Hallo\",\"width\":\"78\"},{\"id\":\"921\",\"word\":\"hallo\",\"width\":\"77\"}])"
      }
    end

    def get!("https://server.delegs.de/delegseditor/signwritingeditor/signitems?word=NotActive") do
      %{
        status_code: 200,
        body:
          "([{\"id\":\"388\",\"word\":\"Hallo\",\"width\":\"78\"},{\"id\":\"331\",\"word\":\"NotActive\",\"width\":\"77\"}])"
      }
    end

    def get!("https://server.delegs.de/delegseditor/signwritingeditor/signitems?word=NotModified") do
      %{
        status_code: 200,
        body: "([{\"id\":\"999\",\"word\":\"NotModified\",\"width\":\"78\"}])"
      }
    end

    def get!(
          "https://server.delegs.de/delegseditor/signwritingeditor/signimages?upperId=388&lowerId=Hallo&signlocale=DGS",
          _opts
        ) do
      %{
        status_code: 200,
        body: "IMAGE"
      }
    end

    def get!(
          "https://server.delegs.de/delegseditor/signwritingeditor/signimages?upperId=921&lowerId=hallo&signlocale=DGS",
          _opts
        ) do
      %{
        status_code: 200,
        body: "IMAGE"
      }
    end

    def get!(
          "https://server.delegs.de/delegseditor/signwritingeditor/signimages?upperId=999&lowerId=NotModified&signlocale=DGS",
          _opts
        ) do
      %{
        status_code: 302
      }
    end
  end

  describe "fetch_for/1" do
    test "it will load all datasets into the database and updates the images" do
      entry = insert(:entry, text: "Hallo")
      FetchDelegesDataForEntry.fetch_for(entry, MockPoison)

      entry = Repo.get(Entry, entry.id) |> Repo.preload(:sign_writings)

      assert entry.deleges_updated_at != nil
      assert Enum.count(entry.sign_writings) == 2

      [first, second] = Enum.sort_by(entry.sign_writings, & &1.deleges_id)

      assert first.word == "Hallo"
      assert first.deleges_id == 388
      assert first.state == "active"
      assert second.word == "hallo"
      assert second.deleges_id == 921
      assert second.state == "active"
    end

    test "does not update image if image is not modified" do
      entry = insert(:entry, text: "NotModified")
      FetchDelegesDataForEntry.fetch_for(entry, MockPoison)

      entry = Repo.get(Entry, entry.id) |> Repo.preload(:sign_writings)

      assert entry.deleges_updated_at != nil
      assert Enum.count(entry.sign_writings) == 1

      first = List.first(entry.sign_writings)

      assert first.word == "NotModified"
      assert first.deleges_id == 999
      assert first.image == nil
      assert first.state == "active"
    end

    test "only update images that are active" do
      entry = insert(:entry, text: "NotActive")

      %SignWriting{}
      |> SignWriting.changeset(%{
        deleges_id: 331,
        width: 100,
        word: "NotActive",
        entry_id: entry.id,
        state: "wrong"
      })
      |> Repo.insert!()

      FetchDelegesDataForEntry.fetch_for(entry, MockPoison)

      entry = Repo.get(Entry, entry.id) |> Repo.preload(:sign_writings)

      assert entry.deleges_updated_at != nil
      assert Enum.count(entry.sign_writings) == 2

      [first, second] = Enum.sort_by(entry.sign_writings, & &1.deleges_id)

      assert first.word == "NotActive"
      assert first.deleges_id == 331
      assert first.state == "wrong"
      assert first.image == nil
      assert second.word == "Hallo"
      assert second.deleges_id == 388
      assert second.state == "active"
      assert second.image != nil
    end

    test "delete items that are no longer returend by the deleges api" do
      entry = insert(:entry, text: "Hallo")

      %SignWriting{}
      |> SignWriting.changeset(%{
        deleges_id: 0,
        width: 100,
        word: "Hallo",
        entry_id: entry.id
      })
      |> Repo.insert!()

      FetchDelegesDataForEntry.fetch_for(entry, MockPoison)

      entry = Repo.get(Entry, entry.id) |> Repo.preload(:sign_writings)

      assert entry.deleges_updated_at != nil
      assert Enum.count(entry.sign_writings) == 2

      [first, second] = Enum.sort_by(entry.sign_writings, & &1.deleges_id)

      assert first.deleges_id == 388
      assert second.deleges_id == 921
    end
  end
end
