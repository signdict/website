defmodule SignDict.Importer.Wps.WiktionaryTest do
  use SignDict.ModelCase

  alias SignDict.Importer.Wps.Wiktionary

  defmodule MockHttPoison do
    def get!(
          "https://de.wiktionary.org/w/api.php?action=parse&page=anorganisch&prop=wikitext&formatversion=2&format=json"
        ) do
      %{
        status_code: 200,
        body:
          "{\"parse\":{\"title\":\"anorganisch\",\"pageid\":262465,\"wikitext\":\"== anorganisch ({{Sprache|Deutsch}}) ==\n=== {{Wortart|Adjektiv|Deutsch}} ===\n\n{{Deutsch Adjektiv Übersicht\n|Positiv=anorganisch\n|Komparativ=anorganischer\n|Superlativ=anorganischsten\n}}\n\n{{Worttrennung}}\n:an·or·ga·nisch, {{Komp.}} an·or·ga·ni·scher, {{Sup.}} am an·or·ga·nischs·ten\n\n{{Aussprache}}\n:{{IPA}} {{Lautschrift|ˈanʔɔʁˌɡaːnɪʃ}}\n:{{Hörbeispiele}} {{Audio|De-anorganisch.ogg}}\n\n{{Bedeutungen}}\n:[1] ''[[Chemie]], [[Biologie]]:'' zum unbelebten [[Teil]] der [[Natur]] [[gehörend]]; nicht von [[Lebewesen]] [[stammend]]; nicht zum belebten [[Teil]] der [[Natur]] [[gehörend]];\n:[2] nicht nach [[bestimmten]], [[natürlichen]] [[Regeln]] [[ablaufend]]\n:[3] ''[[Linguistik]], von Lauten oder Buchstaben:'' ohne [[morphologisch]]e Notwendigkeit, zumeist aus [[phonologisch]]en [[Gründen]] [[eingeschoben]]\n\n{{Abkürzungen}}\n:[[anorg.]]\n\n{{Ursprung}}\n:[[Derivation]] ([[Ableitung]]) des [[Adjektivs]] ''[[organisch]]'' mit dem [[Präfix]] ''[[an-]]''\n\n{{Synonyme}}\n:[1] [[leblos]], [[künstlich]], [[synthetisch]], [[unbelebt]], [[unorganisch]]\n:[2] [[ungeordnet]], [[ungegliedert]], [[unsystematisch]], [[zufällig]]\n:[3] [[eingefügt]], [[eingeschoben]], [[epenthetisch]]\n\n{{Gegenwörter}}\n:[1] [[belebt]], [[organisch]]\n:[2] [[geordnet]], [[gegliedert]], [[planmäßig]], [[systematisch]]\n:[3] [[grammatisch]] ([[grammatikalisch]])\n\n{{Beispiele}}\n:[1] Tübingen und München gelang es, in der ''anorganischen'' Chemie unter die ersten zehn zu kommen, Freiburg und Mainz in der organischen und Polymerchemie.<ref>{{Per-Zeit Online | Online=http://www.zeit.de/2003/29/B-Championship | Autor=Andreas Sentker | Titel=Ackern im Mittelfeld | Nummer=29 | Tag=10 | Monat=Juli | Jahr=2003 }}</ref>\n:[1] In der Atomphysik vereinigten sich in den ersten Jahrzehnten des 20. Jahrhunderts die Disziplinen der Chemie und Physik, und Heisenbergs Quantentheorie leistete das, was Weizsäcker die »Vereinheitlichung der Grundgesetze« im ''anorganischen'' Bereich nannte.<ref>{{Per-Zeit Online | Online=http://www.zeit.de/2007/19/Ein_Sternkundiger | Autor=Elisabeth von Thadden | Titel=Nachruf: Ein Sternkundiger | Nummer=19 | Tag=3 | Monat=Mai | Jahr=2007 }}</ref>\n:[1] Organische Moleküle kann man zum Beispiel mithilfe der so genannten PCR tausendfach kopieren - ein entsprechendes Verfahren für ''anorganische'' Moleküle wäre revolutionär.<ref>{{Per-Zeit Online | Online=http://www.zeit.de/2002/45/200245_personal_fabrica.xml | Autor=Christoph Drösser | Titel=Technik: Rückkehr des Realen | Nummer=45 | Tag=13 | Monat=September | Jahr=2006 }}</ref>\n:[1] Ein Begriff von Erdgeschichte entstand allerdings erst in der Zeit der Französischen Revolution, und so erschienen die Versteinerungen nicht als Relikte organischen Lebens, sondern als ''anorganische'' Schöpfungen.<ref>{{Per-Zeit Online | Online=http://www.zeit.de/2003/24/Der_Vulvastein_l_9fgt_ | Autor=Hans-Volkmar Findeisen | Titel=Naturgeschichte: Der Vulvastein lügt! | Nummer=24 | Tag=5 | Monat=Juni | Jahr=2003 }}</ref>\n:[2] ''Anorganisch'' und menschenfern, tief unter der Oberfläche der Technik und der bearbeiteten Tonquellen, sind meist nicht mehr als zwei klingende Phänomene zur selben Zeit zu hören, die aber akribisch organisiert sind.<ref>{{Per-Zeit Online | Online=http://www.zeit.de/online/2005/46/tietchens | Autor=Sebastian Reier | Titel=Klangforschung: Kauz mit Sittich | Tag=17 | Monat=April | Jahr=2007 }}</ref>\n:[2] Die Bewegungen des Kinos waren für Sternberg ''anorganisch''.<ref>{{Per-Zeit Online | Online=http://www.zeit.de/2002/01/Die_Pokerspielerin_und_ihre_Landschaft/komplettansicht | Autor=Ilse Aichinger | Titel=Die Pokerspielerin und ihre Landschaft | Nummer=01/2002 | Tag=27 | Monat=Dezember | Jahr=2001 }}</ref>\n:[3] Die Einfügung von „t“ im Wort „wesen'''t'''lich“ ist ''anorganisch,'' weil sie keine morphologische Funktion besitzt.\n\n{{Charakteristische Wortkombinationen}}\n:[1] die [[anorganische Chemie|''anorganische'' Chemie]]; ''anorganische'' [[Grundstoff]]e, [[Materialien]], [[Salze]], [[Säuren]], [[Stoffe]], [[Substanzen]]; ein ''anorganischer'' [[Abfall]]\n:[2] ein ''anorganisches'' [[Wachstum]]; eine ''anorganische'' [[Entwicklung]]\n:[3] ein ''anorganischer'' [[Einschub]]\n\n{{Wortbildungen}}\n:[1] [[Anorganiker]]\n\n==== {{Übersetzungen}} ====\n{{Ü-Tabelle|Ü-links=\n*{{zh-tw}}: [1] {{Üt|zh|無機|wújī}}\n*{{zh-cn}}: [1] {{Üt|zh|无机|wújī}}\n*{{en}}: [1] {{Ü|en|inorganic}}, {{Ü|en|inanimate}}; [2] {{Ü|en|random}}, {{Ü|en|haphazard}}; [3] {{Ü|en|epenthetic}}\n*{{eo}}: [1–3] {{Ü|eo|anorgana}}\n*{{fr}}: [1] {{Ü|fr|inorganique}}; [2] {{Ü|fr|aléatoire}}, {{Ü|fr|stochastique}}; [3] {{Ü|fr|épenthétique}}\n*{{ka}}: [1] {{Üt|ka|არაორგანული|araorganuli}}\n*{{el}}: [1] {{Üt|el|ανόργανος|anorgnaos}}; [2] {{Üt|el|ακατάστατος|akatastatos}}, {{Üt|el|τυχαίος|tychaios}}; [3] {{Üt|el|επενθετικός|epenthetikos}}\n*{{it}}: [1, 2] {{Ü|it|inorganico}}; [2] {{Ü|it|disorganico}}; [3] {{Ü|it|epentetico}}\n*{{ja}}: [1] {{Üt|ja|無機の|mukino}}\n*{{hr}}: [1] {{Ü|hr|anorganski}}, {{Ü|hr|neživ}}; [2] {{Ü|hr|nesređen}}, {{Ü|hr|slučajan}}; [3] {{Ü|hr|epentetski}}\n|Ü-rechts=\n*{{nl}}: [1, 3] {{Ü|nl|anorganisch}}; [2] {{Ü|nl|ongeordend}}, {{Ü|nl|toevallig}}; [3] {{Ü|nl|epenthetisch}}\n*{{pl}}: [1] {{Ü|pl|nieorganiczny}}; [2] {{Ü|pl|chaotyczny}}, {{Ü|pl|nieuporządkowany}}, {{Ü|pl|przypadkowy}}; [3] {{Ü|pl|epentetyczny}}\n*{{ru}}: [1] {{Üt|ru|неорганический|njeorganitschjeskij}}; [2] {{Üt|ru|случайный|slutschajnyj}}; [3] {{Üt|ru|вставной|wstawnoj}}\n*{{sv}}: [1, 2] {{Ü|sv|oorganisk}}\n*{{sk}}: [1] {{Ü|sk|anorganický}}, {{Ü|sk|neústrojný}}; [2] {{Ü|sk|neusporiadaný}}, {{Ü|sk|náhodný}}\n*{{es}}: [1] {{Ü|es|inorgánico}}; [2] {{Ü|es|casual}}, {{Ü|es|ocasional}}, {{Ü|es|desordenado}}; [3] {{Ü|es|epentético}}\n*{{cs}}: [1] {{Ü|cs|anorganický}}, {{Ü|cs|neživý}}; [2] {{Ü|cs|neuspořádaný}}, {{Ü|cs|náhodný}}\n*{{tr}}: [1] {{Ü|tr|anorganik}}, {{Ü|tr|cansiz}}\n*{{vi}}: [1] {{Ü|vi|vô cơ}}\n}}\n\n{{Referenzen}}\n:[1–3] {{Lit-Duden: Großes Fremdwörterbuch|A=4}}, Seite 106, Eintrag „anorganisch“.\n:[1] {{Ref-DWDS|anorganisch}}\n:[1, 2] {{Ref-UniLeipzig|anorganisch}}\n:[1] {{Ref-FreeDictionary|anorganisch}}\n\n{{Quellen}}\n\n{{Ähnlichkeiten 1|[[unorganisch]]}}\"}}"
      }
    end

    def get!(
          "https://de.wiktionary.org/w/api.php?action=parse&page=Spannung&prop=wikitext&formatversion=2&format=json"
        ) do
      %{
        status_code: 200,
        body:
          "{\"parse\":{\"title\":\"Spannung\",\"pageid\":39150,\"wikitext\":\"== Spannung ({{Sprache|Deutsch}}) ==\n=== {{Wortart|Substantiv|Deutsch}}, {{f}} ===\n\n{{Deutsch Substantiv Übersicht\n|Genus=f\n|Nominativ Singular=Spannung\n|Nominativ Plural=Spannungen\n|Genitiv Singular=Spannung\n|Genitiv Plural=Spannungen\n|Dativ Singular=Spannung\n|Dativ Plural=Spannungen\n|Akkusativ Singular=Spannung\n|Akkusativ Plural=Spannungen\n}}\n\n{{Worttrennung}}\n:Span·nung, {{Pl.}} Span·nun·gen\n\n{{Aussprache}}\n:{{IPA}} {{Lautschrift|ˈʃpanʊŋ}}\n:{{Hörbeispiele}} {{Audio|De-Spannung.ogg}}\n:{{Reime}} {{Reim|anʊŋ|Deutsch}}\n\n{{Bedeutungen}}\n:[1] {{K|Physik|Elektrizität}} (»elektrische Spannung«) die (nutzbare) Potenzialdifferenz zwischen zwei Orten im elektrischen Feld\n:[2] {{K|Physik|Mechanik}} (»mechanische Spannung«) die nutzbare Potentialdifferenz zwischen zwei Formzuständen im Kraftfeld\n:[3] {{K|Psychologie}} das Gefühl in Form eines Konflikts nach einer emotional aufladenden Situation\n:[4] {{K|Physiologie}} Anspannung/Verspannung als Zwischenresultat einer zu bewältigenden Problemlage\n:[5] {{K|Unterhaltung}} Ergebnis einer Spielhandlung, welches im Publikum Interesse auslöst\n\n\"}}"
      }
    end

    def get!(
          "https://de.wiktionary.org/w/api.php?action=parse&page=unknown_word&prop=wikitext&formatversion=2&format=json"
        ) do
      %{
        status_code: 404,
        body: ""
      }
    end
  end

  describe "extract_description/2" do
    test "it downloads the json and parses out the correct description" do
      assert Wiktionary.extract_description(
               "https://de.wiktionary.org/wiki/anorganisch",
               "1",
               MockHttPoison
             ) ==
               "Chemie, Biologie: zum unbelebten Teil der Natur gehörend; nicht von Lebewesen stammend; nicht zum belebten Teil der Natur gehörend;"

      assert Wiktionary.extract_description(
               "https://de.wiktionary.org/wiki/anorganisch",
               "2",
               MockHttPoison
             ) == "nicht nach bestimmten, natürlichen Regeln ablaufend"

      assert Wiktionary.extract_description(
               "https://de.wiktionary.org/wiki/anorganisch",
               "3",
               MockHttPoison
             ) ==
               "Linguistik, von Lauten oder Buchstaben: ohne morphologische Notwendigkeit, zumeist aus phonologischen Gründen eingeschoben"

      assert Wiktionary.extract_description(
               "https://de.wiktionary.org/wiki/Spannung",
               "1",
               MockHttPoison
             ) ==
               "Physik, Elektrizität: (»elektrische Spannung«) die (nutzbare) Potenzialdifferenz zwischen zwei Orten im elektrischen Feld"
    end

    test "returns empty if definition cannot be found" do
      assert Wiktionary.extract_description(
               "https://de.wiktionary.org/wiki/anorganisch",
               "100",
               MockHttPoison
             ) == ""
    end

    test "returns empty if url does not resolve" do
      assert Wiktionary.extract_description(
               "https://de.wiktionary.org/wiki/unknown_word",
               "1",
               MockHttPoison
             ) == ""
    end
  end
end
