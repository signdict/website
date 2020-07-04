defmodule SignDict.EntryControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias SignDict.Analytics.VideoAnalytic
  alias SignDict.Entry
  alias SignDict.Vote
  alias SignDict.Video

  describe "show/2 entry attributes" do
    setup do
      entry = insert(:entry)
      user_1 = insert(:user, %{name: "User 1"})
      user_2 = insert(:user, %{name: "User 2"})
      user_3 = insert(:user, %{name: "User 3"})
      video_1 = insert(:video, %{state: "published", user: user_1, entry: entry})
      video_2 = insert(:video, %{state: "published", user: user_2, entry: entry})
      {:ok, _vote} = %Vote{user: user_1, video: video_1} |> Repo.insert()
      {:ok, _vote} = %Vote{user: user_2, video: video_1} |> Repo.insert()
      {:ok, _vote} = %Vote{user: user_3, video: video_2} |> Repo.insert()

      {
        :ok,
        entry: entry,
        user_1: user_1,
        user_2: user_2,
        user_3: user_3,
        video_1: video_1,
        video_2: video_2
      }
    end

    test "it redirects to search if the id could not be found", %{conn: conn} do
      conn = get(conn, entry_path(conn, :show, "99999-nach-hause"))
      assert redirected_to(conn) == search_path(conn, :index, q: "nach hause")
    end

    test "it redirect to the search if no number is in the id", %{conn: conn} do
      conn = get(conn, entry_path(conn, :show, "nach-hause"))
      assert redirected_to(conn) == search_path(conn, :index, q: "nach hause")
    end

    test "it redirect if the entry does not have any videos and no video id is given", %{
      conn: conn
    } do
      entry = insert(:entry)
      conn = get(conn, entry_path(conn, :show, entry))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) == "Sorry, I could not find an entry for this."
    end

    test "it redirect if the entry does not have any videos and a video id is given", %{
      conn: conn
    } do
      entry = insert(:entry)
      conn = get(conn, entry_video_path(conn, :show, entry, 1))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) == "Sorry, I could not find an entry for this."
    end

    test "it redirect if the entry does exist and a video id is given", %{conn: conn} do
      conn = get(conn, entry_video_path(conn, :show, "131231312-entry", 1_234_567_890))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) == "Sorry, I could not find an entry for this."
    end

    test "redirects to the entry page if the linked video does not exist", %{
      conn: conn,
      entry: entry
    } do
      conn = get(conn, entry_video_path(conn, :show, entry, 1_234_567_890))
      assert redirected_to(conn) == entry_path(conn, :show, entry)
    end

    test "shows the highest voted video if no video is given", %{conn: conn, entry: entry} do
      conn = get(conn, entry_path(conn, :show, entry))
      assert html_response(conn, 200) =~ entry.description
      assert html_response(conn, 200) =~ entry.text
      assert html_response(conn, 200) =~ entry.type
      assert html_response(conn, 200) =~ "User 1"
    end

    test "shows the voted video if the user voted one", %{conn: conn, entry: entry, user_3: user} do
      conn =
        conn
        |> guardian_login(user)
        |> get(entry_path(conn, :show, entry))

      assert html_response(conn, 200) =~ entry.description
      assert html_response(conn, 200) =~ entry.text
      assert html_response(conn, 200) =~ entry.type
      assert html_response(conn, 200) =~ "User 2"
    end

    test "shows a specific video if given in the url", %{conn: conn, entry: entry, video_2: video} do
      conn = get(conn, entry_video_path(conn, :show, entry, video))
      assert html_response(conn, 200) =~ entry.description
      assert html_response(conn, 200) =~ entry.text
      assert html_response(conn, 200) =~ entry.type
      assert html_response(conn, 200) =~ "User 2"
    end

    test "enqueus sign_writing refresh if never run ", %{conn: conn, entry: entry} do
      get(conn, entry_path(conn, :show, entry))
      entry_id = entry.id

      assert_received {:mock_exq, "sign_writings", SignDict.Worker.RefreshSignWritings,
                       [^entry_id]}
    end

    test "enqueus sign_writing refresh if never run with video in the url ", %{
      conn: conn,
      entry: entry,
      video_2: video
    } do
      get(conn, entry_video_path(conn, :show, entry, video))
      entry_id = entry.id

      assert_received {:mock_exq, "sign_writings", SignDict.Worker.RefreshSignWritings,
                       [^entry_id]}
    end

    test "does not enque if younger than three days", %{conn: conn} do
      entry = insert(:entry, deleges_updated_at: Timex.shift(Timex.now(), days: -1))

      get(conn, entry_path(conn, :show, entry))
      entry_id = entry.id

      refute_received {:mock_exq, "sign_writings", SignDict.Worker.RefreshSignWritings,
                       [^entry_id]}
    end

    test "does not enqueue if all videos have a sign_writing attached to it", %{
      conn: conn,
      entry: entry,
      video_1: video_one,
      video_2: video_two
    } do
      Video.changeset_uploader(video_one, %{
        sign_writing: %Plug.Upload{
          content_type: "image/png",
          filename: "file.png",
          path: "test/fixtures/images/russland.png"
        }
      })
      |> SignDict.Repo.update!()

      Video.changeset_uploader(video_two, %{
        sign_writing: %Plug.Upload{
          content_type: "image/png",
          filename: "file.png",
          path: "test/fixtures/images/russland.png"
        }
      })
      |> SignDict.Repo.update!()

      get(conn, entry_path(conn, :show, entry))

      entry_id = entry.id

      refute_received {:mock_exq, "sign_writings", SignDict.Worker.RefreshSignWritings,
                       [^entry_id]}
    end

    test "it searches if entry is for other domain and no video is given", %{conn: conn} do
      domain = insert(:domain, domain: "example.com")
      entry = insert(:entry_with_current_video, text: "Apple", domains: [domain])

      conn = get(conn, entry_path(conn, :show, entry))
      assert redirected_to(conn) == search_path(conn, :index, q: "apple")
    end

    test "it redirects if entry is for other domain", %{conn: conn} do
      domain = insert(:domain, domain: "example.com")
      entry = insert(:entry_with_current_video, text: "Apple", domains: [domain])

      conn = get(conn, entry_video_path(conn, :show, entry, entry.current_video_id))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) == "Sorry, I could not find an entry for this."
    end

    test "increases the view count", %{conn: conn, entry: entry, user_1: user, video_1: video} do
      conn |> guardian_login(user) |> get(entry_video_path(conn, :show, entry, video))

      video = Repo.get!(Video, video.id)
      assert video.view_count == 1

      entry = Repo.get!(Entry, entry.id)
      assert entry.view_count == 1

      assert Repo.get_by(VideoAnalytic, video_id: video.id, entry_id: entry.id, user_id: user.id) !=
               nil
    end

    test "increases the view count for an anonymous user", %{
      conn: conn,
      entry: entry,
      video_1: video
    } do
      conn |> get(entry_video_path(conn, :show, entry, video))

      video = Repo.get!(Video, video.id)
      assert video.view_count == 1

      entry = Repo.get!(Entry, entry.id)
      assert entry.view_count == 1

      assert Repo.get_by(VideoAnalytic, video_id: video.id, entry_id: entry.id) !=
               nil
    end
  end

  describe "new/2" do
    test "it renders the form", %{conn: conn} do
      conn =
        conn
        |> get(entry_path(conn, :new))

      assert html_response(conn, 200) =~ "Add new entry"
    end
  end

  describe "create/2" do
    test "it redirects to the record page if entry could be stored", %{conn: conn} do
      language = SignDict.Factory.find_or_insert_language("DGS")
      domain = insert(:domain)

      conn =
        conn
        |> post(
          entry_path(conn, :create),
          entry: %{
            text: "New Entry",
            description: "New description",
            type: "word",
            language_id: language.id
          }
        )

      entry = Repo.get_by!(Entry, text: "New Entry") |> Repo.preload(:domains)
      assert entry.domains == [domain]
      assert redirected_to(conn) == recorder_path(conn, :index, entry.id)
    end

    test "it redirects to an already existing page if the entry was already in the database", %{
      conn: conn
    } do
      {:ok, language} = SignDict.Factory.find_or_build_language("DGS") |> Repo.insert()
      entry = insert(:entry, text: "Another excelent entry", description: "", type: "word")

      conn =
        conn
        |> post(
          entry_path(conn, :create),
          entry: %{
            text: "Another excelent entry",
            description: "",
            type: "word",
            language_id: language.id
          }
        )

      assert redirected_to(conn) == recorder_path(conn, :index, entry.id)
    end

    test "it shows the form if the validation of the entry failed", %{conn: conn} do
      insert(:domain)

      conn =
        conn
        |> post(
          entry_path(conn, :create),
          entry: %{
            text: "",
            description: "",
            type: "word"
          }
        )

      assert html_response(conn, 200) =~ "Add new entry"
    end
  end

  describe "index/2" do
    test "it shows only entries for a certain letter", %{conn: conn} do
      insert(:entry_with_current_video, text: "Sloth")
      insert(:entry_with_current_video, text: "Marmot")

      domain = insert(:domain, domain: "example.com")
      insert(:entry_with_current_video, text: "Snake", domains: [domain])

      conn =
        conn
        |> get(entry_path(conn, :index), letter: "S")

      body = html_response(conn, 200)
      assert body =~ "Sloth"
      refute body =~ "Marmot"
      refute body =~ "Snake"
    end
  end

  describe "latest/2" do
    test "it shows newest videos first", %{conn: conn} do
      insert(:entry_with_current_video, text: "Sloth")
      insert(:entry_with_current_video, text: "Marmot")

      domain = insert(:domain, domain: "example.com")
      insert(:entry_with_current_video, text: "Snake", domains: [domain])

      conn =
        conn
        |> get(entry_path(conn, :latest))

      body = html_response(conn, 200)
      assert Regex.match?(~r/entry.*sloth.*entry.*marmot/s, body)
      refute Regex.match?(~r/marmot.*sloth/s, body)
      refute body =~ "Snake"
    end
  end
end
