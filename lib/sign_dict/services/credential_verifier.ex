defmodule SignDict.Services.CredentialVerifier do
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  import SignDict.Gettext

  alias SignDict.User
  alias SignDict.Repo

  def verify(email, password) when is_binary(email) and is_binary(password) do
    with {:ok, user} <- find_by_email(email),
      do: verify_password(password, user)
  end

  defp find_by_email(email) when is_binary(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        dummy_checkpw()
        {:error, gettext("Invalid email address or password")}
      user ->
        {:ok, user}
    end

  end

  defp verify_password(password, %User{} = user) when is_binary(password) do
    if checkpw(password, user.password_hash) do
      {:ok, user}
    else
      {:error, gettext("Invalid email address or password")}
    end
  end
end
