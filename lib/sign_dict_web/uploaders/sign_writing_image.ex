defmodule SignDictWeb.SignWritingImage do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:original]

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  end

  def filename(version, _) do
    version
  end

  def storage_dir(_version, {_file, scope}) do
    Path.join([
      "uploads",
      "sign_writing",
      "#{scope.id}"
    ])
  end
end
