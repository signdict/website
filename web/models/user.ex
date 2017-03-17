defmodule SignDict.User do
  use SignDict.Web, :model

  alias Comeonin.Bcrypt
  alias Ecto.Changeset

  @roles ~w(user admin)

  schema "users" do
    field :email, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string

    field :name, :string
    field :biography, :string

    field :role, :string

    field :password_reset_token, :string
    field :password_reset_unencrypted, :string, virtual: true

    timestamps()
  end

  def roles do
    @roles
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:email, :name, :biography, :password,
                     :password_confirmation])
    |> validate_required([:email, :name])
    |> validate_email
    |> validate_password_if_present
  end

  def admin_changeset(user, params \\ %{}) do
    user
    |> cast(params, [:email, :name, :biography, :password, :password_confirmation, :role])
    |> validate_required([:email, :name])
    |> validate_email
    |> validate_password_if_present
  end

  def register_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :password, :password_confirmation,
                     :name, :biography])
    |> validate_required([:email, :name, :password, :password_confirmation])
    |> validate_email
    |> validate_password
  end

  def create_reset_password_changeset(struct) do
    unencrypted_token = SecureRandom.urlsafe_base64(32)
    encrypted_token = Bcrypt.hashpwsalt(unencrypted_token)

    struct
    |> change
    |> put_change(:password_reset_unencrypted, unencrypted_token)
    |> put_change(:password_reset_token, encrypted_token)
  end

  def reset_password_changeset(struct, params) do
    struct
    |> cast(params, [:password, :password_confirmation,
                     :password_reset_unencrypted])
    |> validate_required([:password, :password_confirmation])
    |> validate_token
    |> validate_password
  end

  defp validate_token(%{valid?: false} = changeset), do: changeset
  defp validate_token(%{valid?: true} = changeset) do
    {:ok, reset_unencrypted} =
      Changeset.fetch_change(changeset, :password_reset_unencrypted)
    {_, reset_encrypted}     =
      Changeset.fetch_field(changeset, :password_reset_token)
    token_matches = Bcrypt.checkpw(reset_unencrypted, reset_encrypted)
    do_validate_token(token_matches, changeset)
  end

  defp do_validate_token(true, changeset), do: changeset
  defp do_validate_token(false, changeset) do
    Changeset.add_error changeset, :password_reset_token, "invalid"
  end

  defp validate_email(changeset) do
    changeset
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  defp validate_password_if_present(changeset) do
    if get_change(changeset, :password, "") != "" ||
       get_change(changeset, :password_confirmation, "") != "" ||
       changeset.data.password_hash == nil do
      changeset
      |> validate_required([:password, :password_confirmation])
      |> validate_password
    else
      changeset
    end
  end

  defp validate_password(changeset) do
    changeset
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> hash_password()
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
