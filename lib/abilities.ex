defimpl Canada.Can, for: SignDict.User do
  alias SignDict.User

  def can?(%User{role: "admin"}, _, _), do: true

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
