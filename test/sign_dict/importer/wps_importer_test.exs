defmodule SignDict.Importer.WpsImporterTest do
  use SignDict.ModelCase
  import SignDict.Factory

  alias SignDict.Importer.WpsImporter
  alias SignDict.Importer.ImporterConfig
  alias SignDict.Entry
  alias SignDict.Repo
  alias SignDict.Video

  setup_all do
    on_exit(fn ->
      File.rm_rf("test/uploads/video_upload")
    end)
  end

  describe "import_json/1" do
    defmodule ExqMock do
      def enqueue(_arg1, _arg2, module, params) do
        send(self(), {:enqueue, module, params})
      end
    end

    setup do
      entry = insert(:entry, %{text: "Zug"})
      user = insert(:user, %{name: "WPS"})

      Repo.insert!(%Video{
        copyright: "sign2mint",
        license: "by-nc-sa/3.0/de",
        original_href: "https://delegs.de/",
        metadata: %{
          source_json: %{
            "videoUrl" => "http://localhost:8081/videos/Zug.mp4",
            "dokumentId" => "123123123:12",
            "fachbegriff" => "Zug"
          },
          source_mp4: "source.mp4"
        },
        user: user,
        entry: entry,
        state: "uploaded",
        external_id: "123123123:12",
        auto_publish: true
      })

      {:ok, entry: entry, user: user}
    end

    test "it imports the data into the video" do
      videos = WpsImporter.import_json(ExqMock)

      assert length(videos) == 1

      video = List.first(videos)

      video_id = video.id
      assert video.copyright == "sign2mint"
      assert video.license == "by-nc-sa/3.0/de"
      assert video.original_href == "https://delegs.de/"
      assert video.auto_publish == true
      assert video.external_id == "4347009787320352:59"

      assert video.metadata[:source_json] == %{
               "dokumentId" => "4347009787320352:59",
               "fachbegriff" => "Pi",
               "videoUrl" => "http://localhost:8081/videos/Zug.mp4"
             }

      assert File.exists?(
               Path.join([
                 Application.get_env(:sign_dict, :upload_path),
                 "video_upload",
                 video.metadata[:source_mp4]
               ])
             )

      assert video.entry.text == "Pi"
      assert video.entry.description == ""
      assert video.user.name == "WPS"
      assert List.first(video.entry.domains).domain == "test.local"
      assert Video.current_state(video) == :uploaded
      assert_received {:enqueue, SignDict.Worker.TranscodeVideo, [^video_id]}

      config = ImporterConfig.for("WPS")
      {:ok, last_parsed} = Timex.parse(config.configuration["last_requested"], "{ISO:Extended:Z}")

      assert DateTime.compare(last_parsed, Timex.shift(Timex.now(), minutes: -1)) == :gt
    end

    test "it requests the videos with the last processing time" do
      start_time = Timex.parse!("2020-01-01T12:30:30+00:00", "%FT%T%:z", :strftime)

      %ImporterConfig{}
      |> ImporterConfig.changeset(%{
        name: "WPS",
        configuration: %{last_requested: start_time}
      })
      |> Repo.insert!()

      videos = WpsImporter.import_json(ExqMock)
      assert length(videos) == 0
    end

    test "does not crash on empty response via the api" do
      start_time = Timex.parse!("2020-04-01T12:30:30+00:00", "%FT%T%:z", :strftime)

      %ImporterConfig{}
      |> ImporterConfig.changeset(%{
        name: "WPS",
        configuration: %{last_requested: start_time}
      })
      |> Repo.insert!()

      videos = WpsImporter.import_json(ExqMock)
      assert length(videos) == 0
    end

    test "it moves the video to another entry if the word changes and does not trigger a retranscode" do
      start_time = Timex.parse!("2020-02-01T12:30:30+00:00", "%FT%T%:z", :strftime)

      %ImporterConfig{}
      |> ImporterConfig.changeset(%{
        name: "WPS",
        configuration: %{last_requested: start_time}
      })
      |> Repo.insert!()

      videos = WpsImporter.import_json(ExqMock)
      video = List.first(videos)
      video_id = video.id

      assert length(videos) == 1

      assert 1 ==
               Video
               |> where(external_id: "123123123:12")
               |> Repo.aggregate(:count, :id)

      entry =
        Entry
        |> Repo.get_by(text: "Zug")
        |> Repo.preload(:videos)

      assert entry.current_video_id == nil
      assert entry.videos == []

      assert video.metadata["source_json"] == %{
               "videoUrl" => "http://localhost:8081/videos/Zug.mp4",
               "dokumentId" => "123123123:12",
               "fachbegriff" => "Rechnen",
               "gebaerdenSchriftUrl" => "http://localhost:8081/images/russland.png"
             }

      new_entry = Repo.get(Entry, video.entry_id) |> Repo.preload(:videos)

      assert new_entry.id != entry.id
      assert new_entry.text == "Rechnen"
      assert List.first(new_entry.videos).id == video_id

      assert File.exists?(
               Path.join([
                 "uploads",
                 "video_sign_writing",
                 Integer.to_string(video.id),
                 "original.png"
               ])
             )

      refute_received {:enqueue, SignDict.Worker.TranscodeVideo, [^video_id]}
    end

    test "it only retranscodes the video if only the url changes" do
      start_time = Timex.parse!("2020-03-01T12:30:30+00:00", "%FT%T%:z", :strftime)

      %ImporterConfig{}
      |> ImporterConfig.changeset(%{
        name: "WPS",
        configuration: %{last_requested: start_time}
      })
      |> Repo.insert!()

      videos = WpsImporter.import_json(ExqMock)
      video = List.first(videos)
      video_id = video.id

      assert length(videos) == 1

      assert video.state == "uploaded"

      assert File.exists?(
               Path.join([
                 Application.get_env(:sign_dict, :upload_path),
                 "video_upload",
                 video.metadata["source_mp4"]
               ])
             )

      assert 1 ==
               Video
               |> where(external_id: "123123123:12")
               |> Repo.aggregate(:count, :id)

      assert_received {:enqueue, SignDict.Worker.TranscodeVideo, [^video_id]}
    end

    test "it deleted the file if it is marked for deletion" do
      start_time = Timex.parse!("2020-05-01T12:30:30+00:00", "%FT%T%:z", :strftime)

      %ImporterConfig{}
      |> ImporterConfig.changeset(%{
        name: "WPS",
        configuration: %{last_requested: start_time}
      })
      |> Repo.insert!()

      videos = WpsImporter.import_json(ExqMock)
      video = List.first(videos)

      assert length(videos) == 1

      assert video.state == "deleted"

      assert 1 ==
               Video
               |> where(external_id: "123123123:12")
               |> Repo.aggregate(:count, :id)

      new_entry = Repo.get(Entry, video.entry_id) |> Repo.preload(:videos)

      assert new_entry.text == "Zug"
      assert new_entry.current_video_id == nil
      assert List.first(new_entry.videos).id == video.id
      assert List.first(new_entry.videos).state == "deleted"
    end
  end
end
