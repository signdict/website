defimpl Canada.Can, for: SignDict.User do
  alias SignDict.User

  def can?(%User{role: "admin"}, _, _), do: true

  def can?(%User{}, _, _), do: false
end
