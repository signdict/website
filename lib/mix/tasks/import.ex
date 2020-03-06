defmodule Mix.Tasks.Importer do
  use Mix.Task

  alias SignDict.Importer.JsonImporter

  @shortdoc "Imports videos with json files to the database"
  @moduledoc ~S"""
  This will import the json files and the video specified
  in those files into the database. It also will move the
  files to the upload directory so that the transcoder can
  find them.
  """
  def run([]) do
    IO.puts("Please specify the path with the json files")
  end

  def run([path]) do
    Mix.Task.run("app.start")
    IO.puts("Importing Files...")

    Enum.each(Path.wildcard(Path.join(path, "**/*.json")), fn file ->
      IO.puts(file)
      JsonImporter.import_json(file)
    end)
  end
end
