defmodule SignDict.EntryTest do
  use SignDict.ModelCase
  import SignDict.Factory

  alias SignDict.Entry
  alias SignDict.Video

  @valid_attrs %{description: "some content", text: "some content", type: "word"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    language = insert :language_dgs
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
      video = %{build(:video) | entry: entry} |> Repo.insert!
      vote  = %SignDict.Vote{video: video, user: insert(:user)} |> Repo.insert!
      voted_video = Entry.voted_video(vote.video.entry, vote.user)
      assert voted_video.id == video.id
      assert Ecto.assoc_loaded? voted_video.user
    end
  end

  describe "update_current_video/1" do

    test "updates to the highest rated video" do
      user   = insert(:user)
      entry  = insert(:entry)
      {:ok, _video1} = %{build(:video_published) | entry: entry} |> Repo.insert
      {:ok, video2}  = %{build(:video_published) | entry: entry} |> Repo.insert
      %SignDict.Vote{user: user, video: video2} |> Repo.insert
      entry = Entry.update_current_video(entry)
      assert entry.current_video.id == video2.id
    end

    test "tests that it only uses videos in production state" do
      user   = insert(:user)
      entry  = insert(:entry)
      {:ok, video1} = %{build(:video) | state: "deleted", entry: entry} |> Repo.insert
      {:ok, video2} = %{build(:video_published) | entry: entry} |> Repo.insert
      %SignDict.Vote{user: user, video: video1} |> Repo.insert
      entry = Entry.update_current_video(entry)
      assert entry.current_video.id == video2.id
    end

  end

  # TODO: test search/1

  describe "Phoenix.Param" do
    test "it creates a nice permalink for the entry" do
      assert Phoenix.Param.to_param(%Entry{id: 1, text: "My name is my castle!"}) == "1-my-name-is-my-castle"
    end
  end
end
