defmodule SignDict.ContactFormTest do
  use SignDict.AcceptanceCase, async: false
  use Bamboo.Test, shared: :true

  test "sends a text via the contact form", %{session: session} do
    session
    |> visit("/contact")
    |> find(Query.css(".contact-form"), fn(form) ->
      form
      |> fill_in(Query.text_field("contact_email"), with: "elisa@example.com")
      |> fill_in(Query.text_field("contact_content"), with: "content")
      |> click(Query.button("Sent"))
    end)
    |> has_text?("The email was sent")

    assert_delivered_with(subject: "[signdict] New message via contact form", to: [{"Bodo", "bodo@tasche.me"}])
  end

end
