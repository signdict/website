defmodule SignDict.Schema.EntryTest do
  use SignDict.ConnCase, async: true
  import SignDict.Factory
  alias SignDict.Test.Helpers.Absinthe, as: AbsintheHelper

  describe "Get entry by ID" do
    test "Successfully returns entry", %{conn: conn} do
      entry = insert(:entry_with_current_video)

      query = """
      {
        entry(id: #{entry.id}) {
          text
          description
          type
          videos{
            copyright
            license
            originalHref
            videoUrl
            thumbnailUrl
            user{
              name
            }
          }
          current_video{
            copyright
            license
            originalHref
            videoUrl
            thumbnailUrl
            user{
              name
            }
          }
          language{
            iso6393
            longName
            shortName
          }
        }
      }
      """

      response =
        conn
        |> post(api_path(), AbsintheHelper.query_skeleton(query, "entry"))
        |> json_response(200)

      assert(
        %{
          "data" => %{
            "entry" => %{
              "language" => entry.language |> expected_language(),
              "videos" => entry.videos |> Enum.map(fn v -> expected_entry_video(v) end),
              "current_video" => entry.current_video |> expected_entry_video(),
              "text" => "#{entry.text}",
              "description" => "#{entry.description}",
              "type" => "#{entry.type}"
            }
          }
        } == response
      )
    end

    test "Returns message if entry not found", %{conn: conn} do
      query = """
      {
        entry(id: 10000000) {
          text
        }
      }
      """

      response =
        conn
        |> post(api_path(), AbsintheHelper.query_skeleton(query, "entry"))
        |> json_response(200)

      assert(
        %{
          "data" => %{"entry" => nil},
          "errors" => [
            %{
              "message" => "Not found",
              "path" => ["entry"]
            }
          ]
        } = response
      )
    end
  end

  describe "Search entry by word" do
    test "Successfully returns entry", %{conn: conn} do
      entry_1 = insert(:entry_with_current_video, text: "Zug")
      insert(:entry_with_current_video, text: "Eisenbahn")

      query = """
      {
        search(word: "Zug") {
          text
          description
          type
          videos{
            copyright
            license
            originalHref
            videoUrl
            thumbnailUrl
            user{
              name
            }
          }
          current_video{
            copyright
            license
            originalHref
            videoUrl
            thumbnailUrl
            user{
              name
            }
          }
          language{
            iso6393
            longName
            shortName
          }
        }
      }
      """

      response =
        conn
        |> post(api_path(), AbsintheHelper.query_skeleton(query, "search"))
        |> json_response(200)

      assert(
        %{
          "data" => %{
            "search" => [
              %{
                "language" => expected_language(entry_1.language),
                "videos" => entry_1.videos |> Enum.map(fn v -> expected_entry_video(v) end),
                "current_video" => entry_1.current_video |> expected_entry_video(),
                "text" => "#{entry_1.text}",
                "description" => "#{entry_1.description}",
                "type" => "#{entry_1.type}"
              }
            ]
          }
        } == response
      )
    end

    test "returns all entries for letter 'Z'", %{conn: conn} do
      insert(:entry_with_current_video, text: "Zug")
      insert(:entry_with_current_video, text: "Zahnpasta")
      insert(:entry_with_current_video, text: "Zirkel")
      insert(:entry_with_current_video, text: "Elefant")

      query = """
      {
        search(letter: "Z") {
          text
        }
      }
      """

      response =
        conn
        |> post(api_path(), AbsintheHelper.query_skeleton(query, "search"))
        |> json_response(200)

      assert(
        %{
          "data" => %{
            "search" => [
              %{"text" => "Zahnpasta"},
              %{"text" => "Zirkel"},
              %{"text" => "Zug"}
            ]
          }
        } == response
      )
    end
  end

  defp expected_entry_video(video) do
    %{
      "copyright" => "#{video.copyright}",
      "license" => "#{video.license}",
      "originalHref" => "#{video.original_href}",
      "thumbnailUrl" => "#{video.thumbnail_url}",
      "videoUrl" => "#{video.video_url}",
      "user" => %{
        "name" => "#{video.user.name}"
      }
    }
  end

  defp expected_language(language) do
    %{
      "iso6393" => "#{language.iso6393}",
      "longName" => "#{language.long_name}",
      "shortName" => "#{language.short_name}"
    }
  end

  defp api_path do
    "/api/graphql"
  end
end
