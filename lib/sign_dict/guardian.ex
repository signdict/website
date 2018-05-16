defmodule SignDict.Guardian do
  use Guardian, otp_app: :sign_dict

  alias SignDict.Repo
  alias SignDict.User

  def subject_for_token(user = %User{}, _claims), do: {:ok, "User:#{user.id}"}
  def subject_for_token(_, _), do: {:error, "Unknown resource type"}

  def resource_from_claims(%{"sub" => "User:" <> id}), do: {:ok, Repo.get(User, id)}
  def resource_from_claims(_), do: {:error, "Unknown resource type"}
end
