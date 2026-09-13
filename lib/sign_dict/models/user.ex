defmodule SignDict.User do
  import Exgravatar

  use SignDictWeb, :model
  use Waffle.Ecto.Schema
  use Gettext, backend: SignDictWeb.Gettext

  alias SignDictWeb.Avatar
  alias SignDict.Repo
  alias SignDict.User

  @all_flags ~w(recording)
  @roles ~w(user admin editor statistic)

  @primary_key {:id, SignDict.Permalink, autogenerate: true}
  schema "users" do
    field(:email, :string)

    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
    field(:password_hash, :string)

    field(:name, :string)
    field(:biography, :string)

    field(:role, :string)

    field(:password_reset_token, :string)
    field(:password_reset_unencrypted, :string, virtual: true)

    field(:avatar, SignDictWeb.Avatar.Type)

    field(:unconfirmed_email, :string)
    field(:confirmation_token, :string)
    field(:confirmation_token_unencrypted, :string, virtual: true)
    field(:confirmed_at, :utc_datetime)
    field(:confirmation_sent_at, :utc_datetime)

    field(:flags, {:array, :string})

    field(:locale, :string)

    has_many(:videos, SignDict.Video)

    timestamps()
  end

  def roles, do: @roles

  def all_flags, do: @all_flags

  def avatar_url(user)

  def avatar_url(user = %SignDict.User{avatar: avatar}) when avatar != nil do
    Avatar.url({avatar, user}, :thumb)
  end

  def avatar_url(user = %SignDict.User{email: email}) when email != nil do
    gravatar_url(user.email, s: 256)
  end

  def avatar_url(_user), do: ""

  def admin?(struct) do
    struct.role == "admin"
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:email, :name, :biography, :password, :password_confirmation, :locale])
    |> cast_attachments(params, [:avatar])
    |> validate_required([:email, :name])
    |> validate_email
    |> validate_password_if_present
    |> validate_email_not_used
  end

  def register_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :email,
      :password,
      :password_confirmation,
      :name,
      :biography
    ])
    |> validate_required([:email, :name, :password, :password_confirmation])
    |> validate_email
    |> validate_password
    |> validate_email_not_used
  end

  def validate_email_not_used(changeset) do
    if email_already_used?(changeset) do
      add_error(changeset, :email, gettext("already used"))
    else
      changeset
    end
  end

  defp email_already_used?(changeset) do
    {_source, user_id} = fetch_field(changeset, :id)
    {_source, email} = fetch_field(changeset, :email)
    do_email_already_used?(user_id, email)
  end

  defp do_email_already_used?(user_id, email) when is_nil(user_id) and is_nil(email) do
    false
  end

  defp do_email_already_used?(user_id, email) when is_nil(user_id) do
    count =
      User
      |> where([user], user.email == ^email or user.unconfirmed_email == ^email)
      |> Repo.aggregate(:count, :id)

    count > 0
  end

  defp do_email_already_used?(user_id, email) do
    count =
      User
      |> where(
        [user],
        (user.id != ^user_id and user.email == ^email) or user.unconfirmed_email == ^email
      )
      |> Repo.aggregate(:count, :id)

    count > 0
  end

  def admin_changeset(user, params \\ %{}) do
    user
    |> cast(params, [:email, :name, :biography, :password, :password_confirmation, :role, :flags])
    |> cast_attachments(params, [:avatar])
    |> validate_required([:email, :name])
    |> validate_email
    |> clean_flags_if_empty(params)
    |> validate_password_if_present
  end

  defp clean_flags_if_empty(changeset, params) do
    if params != %{} && get_change(changeset, :flags, []) == [] do
      changeset
      |> put_change(:flags, [])
    else
      changeset
    end
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

  defp hash_password(changeset = %{valid?: false}), do: changeset

  defp hash_password(changeset = %{valid?: true}) do
    hashed_password =
      changeset
      |> get_field(:password)
      |> Bcrypt.hash_pwd_salt()

    changeset
    |> put_change(:password_hash, hashed_password)
  end

  def has_flag?(user, _flag) when is_nil(user) do
    false
  end

  def has_flag?(user, flag) do
    Enum.member?(user.flags || [], flag)
  end
end

defimpl Phoenix.Param, for: SignDict.User do
  def to_param(%{name: name, id: id}) do
    SignDict.Permalink.to_permalink(id, name)
  end
end

defimpl SignDict.Serializer, for: SignDict.User do
  alias SignDict.User

  def to_map(user) do
    %{
      user: %{
        id: user.id,
        name: user.name,
        email: user.email || user.unconfirmed_email,
        avatar: User.avatar_url(user)
      }
    }
  end
end
