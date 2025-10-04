defmodule SignDictWeb.VideoSignWritingImage do
  use Waffle.Definition
  use Waffle.Ecto.Definition

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
      "video_sign_writing",
      "#{scope.id}"
    ])
  end
end
