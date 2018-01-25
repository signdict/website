defimpl Canada.Can, for: SignDict.User do
  alias SignDict.Entry
  alias SignDict.User
  alias SignDict.Video

  def can?(%User{role: "admin"}, _, _), do: true

  def can?(%User{role: "editor"}, :show_backend, _), do: true

  def can?(%User{role: "editor"}, action, %Video{})
      when action in [:index, :new, :create, :show, :edit, :update, :delete],
      do: true

  def can?(%User{role: "editor"}, action, %Entry{})
      when action in [:index, :new, :create, :show, :edit, :update, :delete],
      do: true

  def can?(%User{}, action, %User{}) when action in [:show], do: true
  def can?(%User{id: user_id}, _, %User{id: user_id}), do: true

  def can?(%User{}, _, _), do: false
end

defimpl Canada.Can, for: Atom do
  alias SignDict.User

  def can?(nil, :new, User), do: true
  def can?(nil, :create, User), do: true
  def can?(nil, :show, %User{}), do: true

  def can?(nil, _, _), do: false
end
