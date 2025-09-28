defmodule SignDict.UserControllerTest do
  use SignDict.ConnCase
  use Bamboo.Test, shared: true

  import SignDict.Factory

  @valid_attrs %{
    email: "elisa@example.com",
    password: "valid_password",
    password_confirmation: "valid_password",
    name: "user name",
    biography: "some content"
  }
  @invalid_attrs %{}

  describe "new/2" do
    test "renders form for new resources", %{conn: conn} do
      conn = get(conn, user_path(conn, :new))
      assert html_response(conn, 200) =~ "Email"
    end
  end

  describe "create/2" do
    test "creates a user with valid form data", %{conn: conn} do
      conn =
        post(conn, user_path(conn, :create), %{
          "user" => @valid_attrs,
          "g-recaptcha-response" => "working"
        })

      assert redirected_to(conn) == "/"
      assert Repo.get_by(SignDict.User, unconfirmed_email: "elisa@example.com")
    end

    test "does not creates a user with valid form data and invalid recaptcha", %{conn: conn} do
      conn =
        post(conn, user_path(conn, :create), %{
          "user" => @valid_attrs,
          "g-recaptcha-response" => "wrong"
        })

      assert redirected_to(conn) == "/users/new"
      refute Repo.get_by(SignDict.User, unconfirmed_email: "elisa@example.com")
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, user_path(conn, :create), %{
          "user" => @invalid_attrs,
          "g-recaptcha-response" => "working"
        })

      assert html_response(conn, 200) =~ "Email"
    end

    test "it sends an email to confirm the user email address", %{conn: conn} do
      post(conn, user_path(conn, :create), %{
        "user" => @valid_attrs,
        "g-recaptcha-response" => "working"
      })

      assert_email_delivered_with(
        subject: "Please confirm your email address",
        to: [{"user name", "elisa@example.com"}]
      )
    end

    test "it does not register newsletter if user does not want it", %{conn: conn} do
      post(
        conn,
        user_path(conn, :create),
        %{
          "user" => Map.merge(@valid_attrs, %{want_newsletter: false}),
          "g-recaptcha-response" => "working"
        }
      )

      refute_received {:mock_chimp, "f96556b89f", "elisa@example.com",
                       %{"FULL_NAME" => "user name"}}
    end

    test "it registers the user to the newsletter if wanted", %{conn: conn} do
      post(
        conn,
        user_path(conn, :create),
        %{
          "user" => Map.merge(@valid_attrs, %{want_newsletter: true}),
          "g-recaptcha-response" => "working"
        }
      )

      assert_received {:mock_chimp, "f96556b89f", "elisa@example.com",
                       %{"FULL_NAME" => "user name"}}
    end
  end

  describe "show/2" do
    test "it shows the user even if logged out", %{conn: conn} do
      user = insert(:user)
      conn = get(conn, user_path(conn, :show, user))
      assert html_response(conn, 200) =~ user.name
    end

    test "it shows the entries of that specific user", %{conn: conn} do
      insert(:video_with_entry)
      video_a = insert(:video_with_entry)
      video_b = insert(:video_with_entry, %{user: video_a.user})
      _video_c = insert(:video_with_entry, %{user: video_a.user, state: "uploaded"})
      conn = get(conn, user_path(conn, :show, video_a.user))
      assert html_response(conn, 200) =~ video_a.user.name
      assert conn.assigns.videos.total_entries == 2

      assert Enum.sort([video_b.id, video_a.id]) ==
               Enum.map(conn.assigns.videos.entries, fn v -> v.id end) |> Enum.sort()
    end

    test "it does not show entries from a wrong domain", %{conn: conn} do
      domain = insert(:domain, domain: "example.com")
      entry = insert(:entry_with_current_video, text: "Apple", domains: [domain])

      conn = get(conn, user_path(conn, :show, entry.current_video.user))
      assert html_response(conn, 200) =~ entry.current_video.user.name

      assert conn.assigns.videos.total_entries == 0
    end
  end

  describe "edit/2" do
    test "it redirects if user is not the same user", %{conn: conn} do
      insert(:user)

      conn =
        conn
        |> guardian_login(insert(:user))
        |> get(SignDictWeb.Router.Helpers.backend_video_path(conn, :index))

      assert redirected_to(conn, 302) == "/"
    end

    test "it redirects if user is not logged in", %{conn: conn} do
      user = insert(:user)
      conn = get(conn, user_path(conn, :edit, user))
      assert redirected_to(conn, 302) == "/"
    end

    test "it lets you edit the user if you are that user", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> guardian_login(user)
        |> get(SignDictWeb.Router.Helpers.user_path(conn, :edit, user))

      assert html_response(conn, 200) =~ "Email"
    end
  end

  describe "update/2" do
    test "it redirects if user is not the same user", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> guardian_login(insert(:user))
        |> patch(SignDictWeb.Router.Helpers.user_path(conn, :update, user), user: @valid_attrs)

      assert redirected_to(conn, 302) == "/"
    end

    test "it redirects if user is not logged in", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> patch(SignDictWeb.Router.Helpers.user_path(conn, :update, user), user: @valid_attrs)

      assert redirected_to(conn, 302) == "/"
    end

    test "it lets you update the user if you are that user", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> guardian_login(user)
        |> patch(SignDictWeb.Router.Helpers.user_path(conn, :update, user), user: @valid_attrs)

      assert redirected_to(conn) == user_path(conn, :show, Repo.get(SignDict.User, user.id))
      assert Repo.get_by(SignDict.User, unconfirmed_email: "elisa@example.com")
    end

    test "rerenders the forms if you had errors", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> guardian_login(user)
        |> patch(SignDictWeb.Router.Helpers.user_path(conn, :update, user), user: %{email: "invalidemail"})

      assert html_response(conn, 200) =~ "Email"
    end

    test "it sends an email to confirm the changed user email address", %{conn: conn} do
      user = insert(:user, email: "another@example.com")

      conn
      |> guardian_login(user)
      |> patch(SignDictWeb.Router.Helpers.user_path(conn, :update, user), user: @valid_attrs)

      assert_email_delivered_with(
        subject: "Please confirm the change of your email address",
        to: [{"user name", "elisa@example.com"}]
      )
    end

    test "it does not sent an email if the user did not change", %{conn: conn} do
      user = insert(:user, email: "elisa@example.com")

      conn =
        conn
        |> guardian_login(user)
        |> patch(SignDictWeb.Router.Helpers.user_path(conn, :update, user), user: @valid_attrs)

      assert redirected_to(conn) == user_path(conn, :show, Repo.get(SignDict.User, user.id))
      user = Repo.get_by(SignDict.User, id: user.id)
      refute_delivered_email(SignDictWeb.Email.confirm_email_change(user))
    end
  end
end
