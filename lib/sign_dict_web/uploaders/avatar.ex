defmodule SignDictWeb.Avatar do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:original, :thumb]

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  end

  def filename(version, _) do
    version
  end

  def storage_dir(_version, {_file, scope}) do
    "uploads/user/avatars/#{scope.id}"
  end

end
