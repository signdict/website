defmodule SignDictWeb.Api.RegisterView do
  use SignDictWeb, :view

  def render(page_name, param)

  def render("create.json", %{errors: errors}) do
    %{error: errors_to_map(errors)}
  end

  def render("create.json", %{user: user}) do
    SignDict.Serializer.to_map(user)
  end

  defp errors_to_map(errors) do
    errors
    |> Enum.map(fn {field, detail} ->
      {field, SignDictWeb.ErrorHelpers.translate_error(detail)}
    end)
    |> Enum.into(%{})
  end
end
