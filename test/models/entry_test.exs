defmodule SignDict.EntryTest do
  use SignDict.ModelCase
  import SignDict.Factory

  alias SignDict.Entry
  alias SignDict.Video

  @valid_attrs %{description: "some content", text: "some content", type: "word"}
  @invalid_attrs %{}

  describe "changeset/2" do
    test "changeset with valid attributes" do
      language = find_or_insert_language("dgs")
      changeset = Entry.changeset(%Entry{}, Map.merge(@valid_attrs,  %{language_id: language.id}))
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Entry.changeset(%Entry{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "changeset with invalid value for type attribute" do
      changeset = Entry.changeset(%Entry{}, Map.merge(@valid_attrs, %{type: "somthing_invalid"}))
      refute changeset.valid?
    end

    test "entry is invalid if two entries have the same text and description" do
      insert :entry, text: "some content", description: "some content"
      changeset = Entry.changeset(%Entry{}, @valid_attrs)
      {:error, changeset} = Repo.insert(changeset)
      refute changeset.valid?
    end

    test "entry is valid if two entries have the same text but different descriptions" do
      language = find_or_insert_language("dgs")
      insert :entry, text: "some content", description: "some content"
      changeset = Entry.changeset(%Entry{}, Map.merge(@valid_attrs, %{description: "other content", language_id: language.id}))
      assert {:ok, _changeset} = Repo.insert(changeset)
    end

    test "it truncates the text and description before inserting or testing uniqueness" do
      language = find_or_insert_language("dgs")
      insert :entry, text: "some content", description: "some content"
      changeset = Entry.changeset(%Entry{}, Map.merge(@valid_attrs, %{text: " some content ", description: " some content ", language_id: language.id}))
      assert {:error, _changeset} = Repo.insert(changeset)
    end

    test "it replaces nil with an empty string for description" do
      changeset = Entry.changeset(%Entry{}, Map.merge(@valid_attrs, %{description: nil}))
      assert {:changes, ""} == Ecto.Changeset.fetch_field(changeset, :description)
    end
  end

  describe "to_string/1" do
    test "returns only the text if no description is given" do
      assert Entry.to_string(%Entry{text: "Example"}) == "Example"
    end

    test "returns only the text if description is empty" do
      assert Entry.to_string(%Entry{text: "Example", description: ""}) == "Example"
    end

    test "returns name and description if description is given" do
      assert Entry.to_string(%Entry{text: "Example", description: "This is it"}) == "Example (This is it)"
    end
  end

  describe "voted_video/2" do
    test "returns an empty video if user is nil" do
      assert Entry.voted_video(%Entry{}, nil) == %Video{id: nil}
    end

    test "returns the video with the user preloaded" do
      entry = insert(:entry)
      video = insert(:video, %{entry: entry})
      vote  = %SignDict.Vote{video: video, user: insert(:user)} |> Repo.insert!
      voted_video = Entry.voted_video(vote.video.entry, vote.user)
      assert voted_video.id == video.id
      assert Ecto.assoc_loaded? voted_video.user
      assert voted_video.vote_count == 1
    end
  end

  describe "update_current_video/1" do

    test "updates to the highest rated video" do
      user    = insert(:user)
      entry   = insert(:entry)
      _video1 = insert(:video_published, %{entry: entry})
      video2  = insert(:video_published, %{entry: entry})
      %SignDict.Vote{user: user, video: video2} |> Repo.insert
      entry = Entry.update_current_video(entry)
      assert entry.current_video.id == video2.id
    end

    test "tests that it only uses videos in production state" do
      user   = insert(:user)
      entry  = insert(:entry)
      video1 = insert(:video, %{state: "deleted", entry: entry})
      video2 = insert(:video_published, %{entry: entry})
      %SignDict.Vote{user: user, video: video1} |> Repo.insert
      entry = Entry.update_current_video(entry)
      assert entry.current_video.id == video2.id
    end

  end

  describe "search/1" do
    setup do
      train_entry = insert(:entry, %{text: "train"})
      insert(:video_published, %{entry: train_entry})
      Entry.update_current_video(train_entry)

      hotel_entry = insert(:entry, %{text: "hôtel"})
      insert(:video_published, %{entry: hotel_entry})
      Entry.update_current_video(hotel_entry)

      tree_entry  = insert(:entry, %{text: "tree"})
      insert(:video, %{entry: tree_entry})
      Entry.update_current_video(tree_entry)

      houseboat_entry  = insert(:entry, %{text: "hausboot"})
      insert(:video_published, %{entry: houseboat_entry})
      Entry.update_current_video(houseboat_entry)

      house_entry  = insert(:entry, %{text: "haus"})
      insert(:video_published, %{entry: house_entry})
      Entry.update_current_video(house_entry)

      {:ok, train: train_entry, tree: tree_entry, hotel: hotel_entry,
        house: house_entry, house_boat: houseboat_entry}
    end

    test "it returns the correct entry when searching for a word and only uses entries with published videos", %{train: train} do
      assert Enum.map(Entry.search("de", "tr"), &(&1.id)) == Enum.map([train], &(&1.id))
    end

    test "it also finds words with accents when using without", %{hotel: hotel} do
      assert Enum.map(Entry.search("de", "hotel"), &(&1.id)) == Enum.map([hotel], &(&1.id))
    end

    test "it returns the results with the best match first", %{house: house, house_boat: house_boat} do
      assert Enum.map(Entry.search("de", "haus"), &(&1.id)) == Enum.map([house, house_boat], &(&1.id))
    end

    test "it also finds the singular when searching for plural forms", %{house: house, house_boat: house_boat} do
      assert Enum.map(Entry.search("de", "häuser"), &(&1.id)) == Enum.map([house, house_boat], &(&1.id))
    end
  end

  describe "find_by_changeset/1" do

    test "it finds an entry based on the new changeset" do
      language = find_or_insert_language("dgs")
      changeset = Entry.changeset(%Entry{}, Map.merge(@valid_attrs,  %{language_id: language.id}))
      {:ok, entry} = changeset |> Repo.insert
      assert entry == Entry.find_by_changeset(changeset)
    end

    test "it returns nil if the changeset could not be found" do
      insert :entry
      language = find_or_insert_language("dgs")
      changeset = Entry.changeset(%Entry{}, Map.merge(@valid_attrs,  %{language_id: language.id}))
      assert nil == Entry.find_by_changeset(changeset)
    end

    test "it returns nil if the changeset is not valid" do
      changeset = Entry.changeset(%Entry{}, %{})
      assert Entry.find_by_changeset(changeset) == nil
    end

  end

  describe "active_entries/0" do

    test "it returns only entries with current_videos" do
      insert(:entry, %{text: "Dog"})
      sheep_entry = insert(:entry, %{text: "Sheep"})
      insert(:video_published, %{entry: sheep_entry})
      Entry.update_current_video(sheep_entry)

      entries = Entry.active_entries |> Repo.all

      assert [sheep_entry.id] == Enum.map(entries, fn(x) -> x.id end)
    end

  end

  describe "for_letter/2" do
    setup do
      entry_alpaca = insert(:entry, %{text: "Alpaca"})
      insert(:video_published, %{entry: entry_alpaca})
      Entry.update_current_video(entry_alpaca)

      entry_hedgehog = insert(:entry, %{text: "Hedgehog"})
      insert(:video_published, %{entry: entry_hedgehog})
      Entry.update_current_video(entry_hedgehog)

      entry_1978 = insert(:entry, %{text: "1978"})
      insert(:video_published, %{entry: entry_1978})
      Entry.update_current_video(entry_1978)

      %{
        entry_hedgehog: entry_hedgehog,
        entry_1978: entry_1978,
        entry_alpaca: entry_alpaca
      }
    end

    test "it returns only entries starting with a letter", %{entry_hedgehog: hedgehog} do
      entries = Entry.for_letter(Entry, "H") |> Repo.all
      assert [hedgehog.id] == Enum.map(entries, fn(x) -> x.id end)
    end

    test "it returns entries with numbers", %{entry_1978: entry_1978} do
      entries = Entry.for_letter(Entry, "0-9") |> Repo.all
      assert [entry_1978.id] == Enum.map(entries, fn(x) -> x.id end)
    end

    test "it returns entries with A when nothing matches", %{entry_alpaca: entry_alpaca} do
      entries = Entry.for_letter(Entry, "error") |> Repo.all
      assert [entry_alpaca.id] == Enum.map(entries, fn(x) -> x.id end)
    end
  end

  describe "Phoenix.Param" do
    test "it creates a nice permalink for the entry" do
      assert Phoenix.Param.to_param(%Entry{id: 1, text: "My name is my castle!"}) == "1-my-name-is-my-castle"
    end
  end
end
