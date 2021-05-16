defmodule SignDict.Importer.Wps.MockController do
  use Plug.Router

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Poison

  plug Plug.Static,
    at: "/videos",
    from: "test/fixtures/videos",
    only: ~w(Zug.mp4 Zug2.mp4)

  plug Plug.Static,
    at: "/images",
    from: "test/fixtures/images",
    only: ~w(russland.png)

  plug :match
  plug :dispatch

  get "/sign_writing" do
    date =
      conn.params["lastRequestedDate"]
      |> Timex.parse!("%F %H:%M:%S", :strftime)
      |> NaiveDateTime.to_date()

    case date do
      ~D[2020-01-01] ->
        success(conn, [])

      ~D[2020-02-01] ->
        success(conn, [
          %{
            "videoUrl" => ["http://localhost:8081/videos/Zug.mp4"],
            "documentId" => "123123123:12",
            "metadata" => %{
              "Fachbegriff" => "Rechnen"
            }
          }
        ])

      ~D[2020-03-01] ->
        success(conn, [
          %{
            "videoUrl" => ["http://localhost:8081/videos/Zug.mp4"],
            "documentId" => "123123123:12",
            "gebaerdenSchriftUrl" => [],
            "metadata" => %{
              "Fachbegriff" => "Rechnen"
            }
          }
        ])

      ~D[2020-04-01] ->
        Plug.Conn.send_resp(conn, 200, "")

      ~D[2020-05-01] ->
        success(conn, [
          %{
            "documentId" => "123123123:12",
            "deleted" => "true"
          }
        ])

      ~D[2020-06-01] ->
        success(conn, [
          %{
            "videoUrl" => ["http://localhost:8081/videos/Another.mp4"],
            "documentId" => "123123123:12",
            "gebaerdenSchriftUrl" => [],
            "metadata" => %{
              "Fachbegriff" => "Rechnen"
            }
          }
        ])

      _ ->
        success(conn, [
          %{
            "videoUrl" => ["http://localhost:8081/videos/Zug.mp4"],
            "documentId" => "4347009787320352:59",
            "gebaerdenSchriftUrl" => ["http://localhost:8081/images/russland.png"],
            "metadata" => %{
              "Fachbegriff" => "Zug",
              "Filmproduzent:" => "Jung-Woo Kim",
              "CC / Ort:" => "MPI",
              "Aufnahmedatum:" => "2019-09-23 00:00:00",
              "Bedeutungsnummer:" => "1",
              "Herkunft:" => [
                "neu",
                "international"
              ],
              "Anwendungsbereich:" => [
                "Akademie",
                "Schule"
              ],
              "Freigabedatum:" => "",
              "Sprache:" => [
                "DGS",
                "BSL"
              ],
              "Wiktionary:" => "https://de.wiktionary.org/wiki/anorganisch",
              "Empfehlung:" => "",
              "Wikipedia:" => "https://de.wikipedia.org/wiki/Anorganische_Chemie",
              "Fachgebiet:" => [
                "Chemie",
                "Geowissenschaft",
                "Informatik"
              ],
              "Gebärdender:" => "Robert Jasko",
              "Hochladedatum:" => "2020-03-23 00:00:00"
            }
          }
        ])
    end
  end

  defp success(conn, body) do
    conn
    |> Plug.Conn.send_resp(200, Poison.encode!(body))
  end
end
