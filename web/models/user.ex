defmodule SignDict.User do
  use SignDict.Web, :model

  alias Comeonin.Bcrypt

  schema "users" do
    field :email, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string

    field :name, :string
    field :biography, :string

    field :role, :string

    field :password_reset_token, :string
    field :password_reset_uncrypted, :string, virtual: true

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def register_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :password, :password_confirmation,
                     :name, :biography])
    |> validate_required([:email, :password, :password_confirmation, :name])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> hash_password()
    |> unique_constraint(:email)
  end

  def reset_password_changeset(struct) do
    unencrypted_token = SecureRandom.urlsafe_base64(32)
    encrypted_token = Bcrypt.hashpwsalt(unencrypted_token)

    struct
    |> change
    |> put_change(:password_reset_uncrypted, unencrypted_token)
    |> put_change(:password_reset_token, encrypted_token)
  end

  defp hash_password(%{valid?: false} = changeset), do: changeset
  defp hash_password(%{valid?: true} = changeset) do
    hashed_password =
      changeset
      |> get_field(:password)
      |> Bcrypt.hashpwsalt()

    changeset
    |> put_change(:password_hash, hashed_password)
  end
end
