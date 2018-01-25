defmodule SignDict.Services.CredentialVerifierTest do
  use SignDict.ModelCase, async: true

  import SignDict.Factory

  alias SignDict.Services.CredentialVerifier

  describe "verify/2" do
    setup do
      %{user: insert(:user)}
    end

    test "it returns {:ok, user} if the login was successfull", %{user: user} do
      {:ok, signed_in} = CredentialVerifier.verify(user.email, "correct_password")
      assert user.id == signed_in.id
    end

    test "it returns {:error, message} if the login failed", %{user: user} do
      assert {:error, _message} = CredentialVerifier.verify(user.email, "wrong_password")
    end

    test "it returns {:error, message} if the user does not exist" do
      assert {:error, _message} =
               CredentialVerifier.verify("not-available@example.com", "correct_password")
    end
  end
end
