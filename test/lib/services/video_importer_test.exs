defmodule SignDict.Services.VideoImporterTest do
  use SignDict.ModelCase, async: true

  alias SignDict.Services.VideoImporter

  describe "store_file/1" do
    setup do
      working_path =
        Path.join([
          System.tmp_dir(),
          "upload_" <> Integer.to_string(System.unique_integer([:positive]))
        ])

      video_file = Path.join([working_path, "Zug.mp4"])
      File.mkdir(working_path)
      File.cp("test/fixtures/videos/Zug.mp4", video_file)

      on_exit(fn ->
        File.rm_rf(Path.expand(Application.get_env(:sign_dict, :upload_path)))
        File.rm_rf(working_path)
      end)

      %{
        video_file: video_file
      }
    end

    test "it copies a file to a new path", %{video_file: video_file} do
      target_file = VideoImporter.store_file(video_file, "Zug.mp4")

      video_path =
        Path.join([
          Application.get_env(:sign_dict, :upload_path),
          "video_upload",
          target_file
        ])

      IO.puts video_path
      assert File.exists?(video_path)
      assert length(String.split(target_file, "/")) == 4
      assert String.ends_with?(target_file, "Zug.mp4")
    end
  end
end
