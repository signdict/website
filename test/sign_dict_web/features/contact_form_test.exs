# defmodule SignDict.ContactFormTest do
#   use SignDict.AcceptanceCase, async: false
#   use Bamboo.Test, shared: true
#   import SignDict.Factory
#
#   @tag wallaby: true
#   test "sends a text via the contact form with logged in user", %{session: session} do
#     insert(:user, %{
#       email: "elisa@example.com",
#       password: "correct_password",
#       password_confirmation: "correct_password"
#     })
#
#     session
#     |> visit("/")
#     |> resize_window(1200, 600)
#     |> click(Query.link("Sign in"))
#     |> find(Query.css(".login-form"), fn form ->
#       form
#       |> fill_in(Query.text_field("session_email"), with: "elisa@example.com")
#       |> fill_in(Query.text_field("session_password"), with: "correct_password")
#       |> click(Query.button("Log in"))
#     end)
#     |> visit("/contact")
#     |> find(Query.css(".contact-form"), fn form ->
#       form
#       |> fill_in(Query.text_field("contact_email"), with: "elisa@example.com")
#       |> fill_in(Query.text_field("contact_content"), with: "content")
#       |> click(Query.button("Sent"))
#     end)
#     |> has_text?("The email was sent")
#
#     assert_email_delivered_with(
#       subject: "[signdict] New message via contact form",
#       to: [{"Bodo", "mail@signdict.org"}]
#     )
#   end
# end
