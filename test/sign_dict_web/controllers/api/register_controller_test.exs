defmodule SignDictWeb.Api.RegisterControllerTest do
  use SignDict.ConnCase
  use Bamboo.Test, shared: true

  alias SignDict.User

  @valid_attrs %{
    email: "elisa-register@example.com",
    password: "valid_password",
    password_confirmation: "valid_password",
    name: "user name",
    biography: "some content"
  }
  @invalid_attrs %{}

  describe "create/2" do
    test "creates a user with valid form data", %{conn: conn} do
      conn =
        post(conn, SignDictWeb.Router.Helpers.api_register_path(conn, :create),
          user: @valid_attrs
        )

      user = Repo.get_by(SignDict.User, unconfirmed_email: "elisa-register@example.com")
      json = json_response(conn, 200)
      assert Plug.Conn.get_session(conn, :registered_user_id) == user.id

      assert json == %{
               "user" => %{
                 "email" => "elisa-register@example.com",
                 "id" => user.id,
                 "name" => "user name",
                 "avatar" => User.avatar_url(user)
               }
             }
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, SignDictWeb.Router.Helpers.api_register_path(conn, :create),
          user: @invalid_attrs
        )

      json = json_response(conn, 400)

      assert json == %{
               "error" => %{
                 "email" => "can't be blank",
                 "name" => "can't be blank",
                 "password" => "can't be blank",
                 "password_confirmation" => "can't be blank"
               }
             }
    end

    test "it sends an email to confirm the user email address", %{conn: conn} do
      post(conn, SignDictWeb.Router.Helpers.api_register_path(conn, :create), user: @valid_attrs)

      assert_email_delivered_with(
        subject: "Please confirm your email address",
        to: [{"user name", "elisa-register@example.com"}]
      )
    end
  end
end
