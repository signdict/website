defmodule SignDict.Importer.JsonImporterTest do
  use ExUnit.Case, async: true
  import SignDict.Factory

  alias SignDict.Importer.JsonImporter
  alias SignDict.Entry
  alias SignDict.Repo
  alias SignDict.User
  alias SignDict.Video

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SignDict.Repo)
  end

  setup_all do
    on_exit fn ->
      File.rm_rf "test/uploads/video_upload"
    end
  end

  describe "import_json/1" do
    setup do
      working_path = Path.join([System.tmp_dir, "video_" <> Integer.to_string(System.unique_integer([:positive]))])
      File.mkdir(working_path)
      Enum.each(Path.wildcard("test/fixtures/videos/*"), fn(file) ->
        File.cp(file, Path.join([working_path, Path.basename(file)]))
      end)

      on_exit fn ->
        File.rm_rf working_path
      end

      {:ok,
        path: working_path,
        entry_without_description: insert(:entry, %{text: "Zug", description: nil}),
        entry_with_description:    insert(:entry, %{text: "Zug", description: "Eisenbahn"}),
        user:                      insert(:user,  %{name: "Gebärden lernen"})
      }
    end

    test "it imports the data into the video", %{path: path} do
      video = JsonImporter.import_json(Path.join(path, "Zug.json"))
      assert video.copyright              == "Henrike Maria Falke - Gebärden lernen"
      assert video.license                == "by-nc-sa/3.0/de"
      assert video.original_href          == "http://www.gebaerdenlernen.de/index.php?article_id=176"
      assert video.metadata[:source_json] == %{
        "author" => "Henrike Maria Falke",
        "author_link" => "http://www.gebaerdenlernen.de",
        "description" => "Eisenbahn",
        "filename" => "gebaerdenlernen/Zug.mp4",
        "license" => "by-nc-sa/3.0/de",
        "source" => "Gebärden lernen",
        "tags" => [],
        "text" => "Zug",
        "word_link" =>
        "http://www.gebaerdenlernen.de/index.php?article_id=176"
      }
      assert File.exists?(Path.join([Application.get_env(:sign_dict, :upload_path), "video_upload", video.metadata[:source_mp4]]))
      assert video.entry.text        == "Zug"
      assert video.entry.description == "Eisenbahn"
      assert video.user.name         == "Gebärden lernen"
      assert Video.current_state(video) == :uploaded
    end

    test "it does use an already existing entry and adds the video to it", %{path: path, entry_with_description: entry} do
      video = JsonImporter.import_json(Path.join(path, "Zug.json"))
      assert Entry |> Repo.aggregate(:count, :id) == 2
      assert video.entry_id == entry.id
    end

    test "It also uses the correct entry when a description is not available", %{path: path, entry_without_description: entry}  do
      video = JsonImporter.import_json(Path.join(path, "Zug2.json"))
      assert Entry |> Repo.aggregate(:count, :id) == 2
      assert video.entry_id == entry.id
    end

    test "it assigns the video to the correct user", %{path: path, user: user} do
      video = JsonImporter.import_json(Path.join(path, "Zug.json"))
      assert User |> Repo.aggregate(:count, :id) == 1
      assert video.user_id == user.id
    end

    test "it creates a new user if it does not exist yet", %{path: path} do
      video = JsonImporter.import_json(Path.join(path, "Zug2.json"))
      assert User |> Repo.aggregate(:count, :id) == 2
      assert video.user.name == "dgs.wikisign.org"
    end
  end
end
