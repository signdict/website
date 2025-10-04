defmodule SignDictWeb.ContactControllerTest do
  use SignDict.ConnCase
  use Bamboo.Test

  import SignDict.Factory

  describe "create/2" do
    test "it shows an error if the recaptcha is not valid", %{conn: conn} do
      conn =
        conn
        |> post(
          Helpers.contact_path(
            conn,
            :create,
            %{
              "contact" => %{"content" => "content", "email" => "alice@example.com"},
              "g-recaptcha-response" => "wrong"
            }
          )
        )

      assert get_flash(conn, :error) == "The recaptcha was wrong, email not sent."
      assert_no_emails_delivered()
    end

    test "it sends an email if the recaptcha was correct", %{conn: conn} do
      conn =
        conn
        |> post(
          Helpers.contact_path(
            conn,
            :create,
            %{
              "contact" => %{"content" => "content", "email" => "alice@example.com"},
              "g-recaptcha-response" => "working"
            }
          )
        )

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) == "The email was sent."

      assert_email_delivered_with(
        subject: "[signdict] New message via contact form",
        to: [{"Bodo", "mail@signdict.org"}]
      )
    end

    test "it sends an email if the user is logged in and ignores the recaptcha", %{conn: conn} do
      conn =
        conn
        |> guardian_login(insert(:user))
        |> post(
          Helpers.contact_path(
            conn,
            :create,
            %{
              "contact" => %{"content" => "content", "email" => "alice@example.com"},
              "g-recaptcha-response" => "wrong"
            }
          )
        )

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) == "The email was sent."

      assert_email_delivered_with(
        subject: "[signdict] New message via contact form",
        to: [{"Bodo", "mail@signdict.org"}]
      )
    end
  end
end
