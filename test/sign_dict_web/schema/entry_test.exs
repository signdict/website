defmodule SignDict.Schema.EntryTest do
  use SignDict.ConnCase, async: true
  import SignDict.Factory
  alias SignDict.Test.Helpers.Absinthe, as: AbsintheHelper

  describe "Get all entries" do
    test "Paginates entries", %{conn: conn} do
      domain = insert(:domain, domain: "example.com")
      insert(:entry_with_current_video, text: "Apple", domains: [domain])

      insert(:entry_with_current_video, text: "Coconuts")
      insert(:entry_with_current_video, text: "Bananas")
      entry_3 = insert(:entry_with_current_video, text: "Blueberries")
      entry_4 = insert(:entry, text: "Grapes")

      query = """
        {
          index(perPage: 2, page: 2){
          current_video{
            id
            copyright
            license
            originalHref
            videoUrl
            updatedAt
            thumbnailUrl
              user{
                name
              }
            }
            description
            id
            language{
              iso6393
              longName
              shortName
            }
            text
            type
            url
            videos{
              id
              copyright
              license
              originalHref
              videoUrl
              thumbnailUrl
              updatedAt
              user{
                name
              }
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
            "index" => [
              %{
                "language" => entry_3.language |> expected_language(),
                "videos" => entry_3.videos |> Enum.map(fn v -> expected_entry_video(v) end),
                "current_video" => entry_3.current_video |> expected_entry_video(),
                "text" => "#{entry_3.text}",
                "description" => "#{entry_3.description}",
                "type" => "#{entry_3.type}",
                "url" => "https://signdict.org/entry/#{entry_3.id}",
                "id" => entry_3.id
              },
              %{
                "language" => entry_4.language |> expected_language(),
                "videos" => [],
                "current_video" => nil,
                "text" => "#{entry_4.text}",
                "description" => "#{entry_4.description}",
                "type" => "#{entry_4.type}",
                "url" => "https://signdict.org/entry/#{entry_4.id}",
                "id" => entry_4.id
              }
            ]
          }
        } == response
      )
    end

    test "does not throw error when index is below 1", %{conn: conn} do
      query = """
        {
          index(perPage: 2, page: 0){
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
          "data" => %{"index" => nil},
          "errors" => [
            %{
              "locations" => [%{"column" => 0, "line" => 2}],
              "message" => "Page must be >= 1",
              "path" => ["index"]
            }
          ]
        } == response
      )
    end
  end

  describe "Get entry by ID" do
    test "Successfully returns entry", %{conn: conn} do
      entry = insert(:entry_with_current_video)

      query = """
      {
        entry(id: #{entry.id}) {
          id
          text
          description
          type
          url
          videos{
            id
            copyright
            license
            originalHref
            videoUrl
            thumbnailUrl
            updatedAt
            user{
              name
            }
          }
          current_video{
            id
            copyright
            license
            originalHref
            videoUrl
            thumbnailUrl
            updatedAt
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
              "videos" =>
                entry.videos
                |> Enum.sort_by(&Map.fetch(&1, :id))
                |> Enum.reverse()
                |> Enum.map(fn v -> expected_entry_video(v) end),
              "current_video" => entry.current_video |> expected_entry_video(),
              "text" => "#{entry.text}",
              "description" => "#{entry.description}",
              "type" => "#{entry.type}",
              "url" => "https://signdict.org/entry/#{entry.id}",
              "id" => entry.id
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

    test "Returns message if entry not found for signdict domain", %{conn: conn} do
      domain = insert(:domain, domain: "example.com")
      entry = insert(:entry_with_current_video, text: "Apple", domains: [domain])

      query = """
      {
        entry(id: #{entry.id}) {
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

    test "Returns message if entry id is missing", %{conn: conn} do
      insert(:domain, domain: "example.com")

      query = """
      {
        entry {
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
              "message" => "parameter 'id' missing",
              "path" => ["entry"]
            }
          ]
        } = response
      )
    end
  end

  describe "Search entry by word" do
    test "Successfully returns entry", %{conn: conn} do
      domain = insert(:domain, domain: "example.com")
      insert(:entry_with_current_video, text: "Zugfahrt", domains: [domain])

      entry_1 = insert(:entry_with_current_video, text: "Zug")
      insert(:entry_with_current_video, text: "Eisenbahn")

      query = """
      {
        search(word: "Zug") {
          id
          text
          description
          type
          url
          videos{
            id
            copyright
            license
            originalHref
            videoUrl
            thumbnailUrl
            updatedAt
            user{
              name
            }
          }
          current_video{
            id
            copyright
            license
            originalHref
            videoUrl
            thumbnailUrl
            updatedAt
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
                "videos" =>
                  entry_1.videos
                  |> Enum.sort_by(&Map.fetch(&1, :id))
                  |> Enum.reverse()
                  |> Enum.map(fn v -> expected_entry_video(v) end),
                "current_video" => entry_1.current_video |> expected_entry_video(),
                "text" => "#{entry_1.text}",
                "description" => "#{entry_1.description}",
                "type" => "#{entry_1.type}",
                "id" => entry_1.id,
                "url" => "https://signdict.org/entry/#{entry_1.id}"
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

      domain = insert(:domain, domain: "example.com")
      insert(:entry_with_current_video, text: "Zugfahrt", domains: [domain])

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

    test "returns all entries matching search text", %{conn: conn} do
      insert(:entry_with_current_video, text: "Familie")
      insert(:entry_with_current_video, text: "Familienfest")
      domain = insert(:domain, domain: "example.com")
      insert(:entry_with_current_video, text: "Familienausflug", domains: [domain])

      query = """
      {
        search(word: "Familie") {
          text
        }
      }
      """

      response =
        conn
        |> post(api_path(), AbsintheHelper.query_skeleton(query, "search"))
        |> json_response(200)

      assert(
        ["Familie", "Familienfest"] ==
          response["data"]["search"]
          |> Enum.map(&Map.get(&1, "text"))
          |> Enum.sort()
      )
    end
  end

  defp expected_entry_video(video) do
    %{
      "id" => video.id,
      "copyright" => "#{video.copyright}",
      "license" => "#{video.license}",
      "originalHref" => "#{video.original_href}",
      "thumbnailUrl" => "#{video.thumbnail_url}",
      "videoUrl" => "#{video.video_url}",
      "updatedAt" => "#{video.updated_at}",
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
    "/graphql-api/graphql"
  end
end
