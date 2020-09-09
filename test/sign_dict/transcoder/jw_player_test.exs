defmodule SignDict.Transcoder.JwPlayerTest do
  use SignDict.ModelCase
  import SignDict.Factory

  alias SignDict.Video

  describe "upload_video/2" do
    defmodule ExqMock do
      def enqueue_in(_arg1, _arg2, time, module, params) do
        send(self(), {:enqueue_in, time, module, params})
      end
    end

    defmodule MockHTTPoisonUpload do
      def get!(url) do
        if String.starts_with?(url, "http://api.jwplatform.com/v1/videos/create") do
          %{
            body:
              "{\"status\": \"ok\", \"rate_limit\": {\"reset\": 1494102000, \"limit\": 60, \"remaining\": 59}, \"video\": {\"key\": \"m7xjXN0r\"}}"
          }
        end
      end
    end

    defmodule MockHTTPoisonUploadFailed do
      def get!(url) do
        if String.starts_with?(url, "http://api.jwplatform.com/v1/videos/create") do
          %{
            body:
              "{\"status\": \"error\", \"rate_limit\": {\"reset\": 1494102000, \"limit\": 60, \"remaining\": 59}}"
          }
        end
      end
    end

    test "it uploads a video" do
      video = insert(:video_with_entry, %{metadata: %{"source_mp4" => "Zug2.mp4"}})

      {state, _result} =
        SignDict.Transcoder.JwPlayer.upload_video(video, MockHTTPoisonUpload, ExqMock)

      video = Repo.get(Video, video.id)
      video_id = video.id
      assert state == :ok
      assert video.metadata["jw_video_id"] == "m7xjXN0r"

      assert video.metadata["jw_status"] == %{
               "rate_limit" => %{
                 "limit" => 60,
                 "remaining" => 59,
                 "reset" => 1_494_102_000
               },
               "status" => "ok",
               "video" => %{"key" => "m7xjXN0r"}
             }

      assert_received {:enqueue_in, 60, SignDict.Worker.CheckVideoStatus, [^video_id]}
    end

    test "if the upload fails, the video is updated accordingly" do
      video = insert(:video_with_entry, %{metadata: %{"source_mp4" => "Zug2.mp4"}})

      {state, _result} =
        SignDict.Transcoder.JwPlayer.upload_video(video, MockHTTPoisonUploadFailed)

      video = Repo.get(Video, video.id)
      video_id = video.id
      assert state == :error
      assert is_nil(video.metadata["jw_video_id"])

      assert video.metadata["jw_status"] == %{
               "rate_limit" => %{
                 "limit" => 60,
                 "remaining" => 59,
                 "reset" => 1_494_102_000
               },
               "status" => "error"
             }

      refute_received {:enqueue_in, 60, SignDict.Worker.CheckVideoStatus, [^video_id]}
    end
  end

  describe "check_status/2" do
    defmodule MockHTTPoisonDone do
      def get!(url) do
        cond do
          url == "https://cdn.jwplayer.com/v2/media/4OCxwoAI" ->
            %{
              body:
                "{\"feed_instance_id\":\"cf789865-e28f-4d3c-b390-b7c44dabd19d\",\"title\":\"Zug\",\"kind\":\"Single Item\",\"playlist\":[{\"mediaid\":\"4OCxwoAI\",\"description\":\"\",\"pubdate\":1493273662,\"title\":\"Zug\",\"image\":\"https://cdn.jwplayer.com/thumbs/4OCxwoAI-720.jpg\",\"sources\":[{\"width\":480,\"type\":\"application/vnd.apple.mpegurl\",\"file\":\"https://cdn.jwplayer.com/manifests/4OCxwoAI.m3u8\",\"height\":360},{\"width\":320,\"height\":240,\"type\":\"video/mp4\",\"file\":\"https://cdn.jwplayer.com/videos/4OCxwoAI-xgdDoosc.mp4\",\"label\":\"180p\"},{\"width\":480,\"height\":360,\"type\":\"video/mp4\",\"file\":\"https://cdn.jwplayer.com/videos/4OCxwoAI-cqrEIsCv.mp4\",\"label\":\"270p\"}],\"tracks\":[{\"kind\":\"thumbnails\",\"file\":\"https://cdn.jwplayer.com/strips/4OCxwoAI-120.vtt\"}],\"link\":\"https://cdn.jwplayer.com/previews/4OCxwoAI\",\"duration\":6}],\"description\":\"\"}"
            }

          true ->
            %{
              body:
                "{\"status\": \"ok\", \"rate_limit\": {\"reset\": 1494093660, \"limit\": 60, \"remaining\": 59}, \"video\": {\"trim_out_point\": null, \"duration\": \"6.84\", \"size\": \"1135854\", \"trim_in_point\": null, \"sourceurl\": null, \"sourcetype\": \"file\", \"title\": \"Zug\", \"tags\": null, \"custom\": {}, \"status\": \"ready\", \"updated\": 1493273792, \"description\": null, \"views\": 7, \"sourceformat\": null, \"mediatype\": \"video\", \"link\": null, \"key\": \"4OCxwoAI\", \"date\": 1493273662, \"md5\": \"fab44d8176b00d4d38b902281d3f2a0b\", \"expires_date\": null, \"author\": null, \"error\": null, \"upload_session_id\": null}}"
            }
        end
      end
    end

    defmodule MockHTTPoisonTranscoding do
      def get!(_url) do
        %{
          body:
            "{\"status\": \"ok\", \"rate_limit\": {\"reset\": 1494093660, \"limit\": 60, \"remaining\": 59}, \"video\": {\"trim_out_point\": null, \"duration\": \"6.84\", \"size\": \"1135854\", \"trim_in_point\": null, \"sourceurl\": null, \"sourcetype\": \"file\", \"title\": \"Zug\", \"tags\": null, \"custom\": {}, \"status\": \"processing\", \"updated\": 1493273792, \"description\": null, \"views\": 7, \"sourceformat\": null, \"mediatype\": \"video\", \"link\": null, \"key\": \"4OCxwoAI\", \"date\": 1493273662, \"md5\": \"fab44d8176b00d4d38b902281d3f2a0b\", \"expires_date\": null, \"author\": null, \"error\": null, \"upload_session_id\": null}}"
        }
      end
    end

    defmodule MockHTTPoisonError do
      def get!(_url) do
        %{
          body:
            "{\"status\": \"ok\", \"rate_limit\": {\"reset\": 1494093660, \"limit\": 60, \"remaining\": 59}, \"video\": {\"trim_out_point\": null, \"duration\": \"6.84\", \"size\": \"1135854\", \"trim_in_point\": null, \"sourceurl\": null, \"sourcetype\": \"file\", \"title\": \"Zug\", \"tags\": null, \"custom\": {}, \"status\": \"error\", \"updated\": 1493273792, \"description\": null, \"views\": 7, \"sourceformat\": null, \"mediatype\": \"video\", \"link\": null, \"key\": \"4OCxwoAI\", \"date\": 1493273662, \"md5\": \"fab44d8176b00d4d38b902281d3f2a0b\", \"expires_date\": null, \"author\": null, \"error\": null, \"upload_session_id\": null}}"
        }
      end
    end

    test "it returns :done and updates the video url and thumbnail if the video is done" do
      video = insert(:video_with_entry, %{metadata: %{"jw_video_id" => "4OCxwoAI"}})
      result = SignDict.Transcoder.JwPlayer.check_status(video, MockHTTPoisonDone)
      video = Repo.get(Video, video.id)
      assert result == :done
      assert video.video_url == "https://cdn.jwplayer.com/videos/4OCxwoAI-cqrEIsCv.mp4"
      assert video.thumbnail_url == "https://cdn.jwplayer.com/thumbs/4OCxwoAI-720.jpg"

      assert video.metadata == %{
               "jw_status" => %{
                 "description" => "",
                 "feed_instance_id" => "cf789865-e28f-4d3c-b390-b7c44dabd19d",
                 "kind" => "Single Item",
                 "playlist" => [
                   %{
                     "description" => "",
                     "duration" => 6,
                     "image" => "https://cdn.jwplayer.com/thumbs/4OCxwoAI-720.jpg",
                     "link" => "https://cdn.jwplayer.com/previews/4OCxwoAI",
                     "mediaid" => "4OCxwoAI",
                     "pubdate" => 1_493_273_662,
                     "sources" => [
                       %{
                         "file" => "https://cdn.jwplayer.com/manifests/4OCxwoAI.m3u8",
                         "height" => 360,
                         "type" => "application/vnd.apple.mpegurl",
                         "width" => 480
                       },
                       %{
                         "file" => "https://cdn.jwplayer.com/videos/4OCxwoAI-xgdDoosc.mp4",
                         "height" => 240,
                         "label" => "180p",
                         "type" => "video/mp4",
                         "width" => 320
                       },
                       %{
                         "file" => "https://cdn.jwplayer.com/videos/4OCxwoAI-cqrEIsCv.mp4",
                         "height" => 360,
                         "label" => "270p",
                         "type" => "video/mp4",
                         "width" => 480
                       }
                     ],
                     "title" => "Zug",
                     "tracks" => [
                       %{
                         "file" => "https://cdn.jwplayer.com/strips/4OCxwoAI-120.vtt",
                         "kind" => "thumbnails"
                       }
                     ]
                   }
                 ],
                 "title" => "Zug"
               },
               "jw_video_id" => "4OCxwoAI"
             }
    end

    test "it does not crash if the jwplayed service renders an empty playlist" do
      video = insert(:video_with_entry, %{metadata: %{"jw_video_id" => "empty_playlist"}})
      result = SignDict.Transcoder.JwPlayer.check_status(video, MockHTTPoisonDone)
      assert result == :done
    end

    test "it returns :transcoding when the video is still in progress" do
      video =
        insert(:video_with_entry, %{
          video_url: nil,
          thumbnail_url: nil,
          metadata: %{"jw_video_id" => "4OCxwoAI"}
        })

      result = SignDict.Transcoder.JwPlayer.check_status(video, MockHTTPoisonTranscoding)
      video = Repo.get(Video, video.id)
      assert result == :transcoding
      assert is_nil(video.video_url)
      assert is_nil(video.thumbnail_url)

      assert video.metadata == %{
               "jw_status" => %{
                 "rate_limit" => %{
                   "limit" => 60,
                   "remaining" => 59,
                   "reset" => 1_494_093_660
                 },
                 "status" => "ok",
                 "video" => %{
                   "author" => nil,
                   "custom" => %{},
                   "date" => 1_493_273_662,
                   "description" => nil,
                   "duration" => "6.84",
                   "error" => nil,
                   "expires_date" => nil,
                   "key" => "4OCxwoAI",
                   "link" => nil,
                   "md5" => "fab44d8176b00d4d38b902281d3f2a0b",
                   "mediatype" => "video",
                   "size" => "1135854",
                   "sourceformat" => nil,
                   "sourcetype" => "file",
                   "sourceurl" => nil,
                   "status" => "processing",
                   "tags" => nil,
                   "title" => "Zug",
                   "trim_in_point" => nil,
                   "trim_out_point" => nil,
                   "updated" => 1_493_273_792,
                   "upload_session_id" => nil,
                   "views" => 7
                 }
               },
               "jw_video_id" => "4OCxwoAI"
             }
    end

    test "it returns :error if the status code is unknown" do
      video =
        insert(:video_with_entry, %{
          video_url: nil,
          thumbnail_url: nil,
          metadata: %{"jw_video_id" => "4OCxwoAI"}
        })

      result = SignDict.Transcoder.JwPlayer.check_status(video, MockHTTPoisonError)
      video = Repo.get(Video, video.id)
      assert result == :error
      assert is_nil(video.video_url)
      assert is_nil(video.thumbnail_url)

      assert video.metadata == %{
               "jw_status" => %{
                 "rate_limit" => %{
                   "limit" => 60,
                   "remaining" => 59,
                   "reset" => 1_494_093_660
                 },
                 "status" => "ok",
                 "video" => %{
                   "author" => nil,
                   "custom" => %{},
                   "date" => 1_493_273_662,
                   "description" => nil,
                   "duration" => "6.84",
                   "error" => nil,
                   "expires_date" => nil,
                   "key" => "4OCxwoAI",
                   "link" => nil,
                   "md5" => "fab44d8176b00d4d38b902281d3f2a0b",
                   "mediatype" => "video",
                   "size" => "1135854",
                   "sourceformat" => nil,
                   "sourcetype" => "file",
                   "sourceurl" => nil,
                   "status" => "error",
                   "tags" => nil,
                   "title" => "Zug",
                   "trim_in_point" => nil,
                   "trim_out_point" => nil,
                   "updated" => 1_493_273_792,
                   "upload_session_id" => nil,
                   "views" => 7
                 }
               },
               "jw_video_id" => "4OCxwoAI"
             }
    end
  end
end
