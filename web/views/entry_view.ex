defmodule SignDict.EntryView do
  require SignDict.Gettext

  import Scrivener.HTML

  use SignDict.Web, :view

  def translated_types do
    SignDict.Entry.types
    |> Enum.map(&{do_translate(&1), &1})
  end

  defp do_translate(type)
  defp do_translate("word"),    do: gettext("entry.type.word")
  defp do_translate("phrase"),  do: gettext("entry.type.phrase")
  defp do_translate("example"), do: gettext("entry.type.example")
end
