defmodule SignDict.Services.VideoImporter do
  alias Ecto.UUID
  alias SignDict.Video

  def store_file(path, filename) do
    file = "#{UUID.generate()}-#{Path.basename(filename)}"
    file_with_path = Path.join([paths_for_file(file), file])
    target_file = Video.file_path(file_with_path)

    File.mkdir_p(Path.dirname(target_file)) |> IO.inspect
    if {:error, :exdev} === File.rename(path, target_file) do
      File.copy(path, target_file)
      File.rm(path)
    end
    file_with_path
  end

  defp paths_for_file(filename) do
    Path.join([
      String.slice(filename, 0..1),
      String.slice(filename, 2..3),
      String.slice(filename, 4..5)
    ])
  end
end
