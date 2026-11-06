# xcf-convert

XCF-Dateien (GIMP-Projekte) per Doppelklick oder Kommandozeile in PNG, JPG,
WebP, TIF, BMP … umwandeln – automatisch mit **GIMP 3** im Batch-Modus.

Dadurch stimmen **Farben, Ebenenreihenfolge, Ebenenmodi und Transparenz**
genau wie in der GIMP-Vorlage (kein ImageMagick o. Ä. nötig).

## Voraussetzungen

- Windows
- [GIMP 3](https://www.gimp.org/downloads/) (getestet mit 3.2.4)

## Schnellstart

1. `xcfconvert.ini` öffnen und ggf. den **GIMP-Pfad** prüfen/anpassen
2. `xcfconvert.bat` **doppelklicken** – alle `.xcf`-Dateien im Ordner werden
   zu `.png` konvertiert

## Verwendung

```text
xcfconvert.bat                       alle .xcf im Script-Ordner  -> .png
xcfconvert.bat C:\Mein\Ordner        alle .xcf im angegebenen Ordner
xcfconvert.bat C:\Pfad\Logo.xcf      nur diese eine Datei
xcfconvert.bat --format jpg          Zielformat wählen (png, jpg, webp, ...)
xcfconvert.bat C:\Ordner --format=webp
xcfconvert.bat --help                Hilfe
```

> **Hinweis:** `--format jpg` und `--format=jpg` sind beide möglich
> (Windows-cmd trennt Argumente normalerweise an `=` – das Script
> fängt das ab).

Als Format ist alles erlaubt, was GIMP exportieren kann (die Endung entscheidet):
`png`, `jpg`, `jpeg`, `tif`, `tiff`, `bmp`, `webp`, …

> **Hinweis:** Formate ohne Transparenz (z. B. JPG) bekommen automatisch
> einen weißen Hintergrund.

## Konfiguration (`xcfconvert.ini`)

```ini
gimp_path=C:\Program Files\GIMP 3\bin\gimp-console-3.exe
format=png
```

| Schlüssel   | Bedeutung                                            |
|-------------|------------------------------------------------------|
| `gimp_path` | Pfad zu `gimp-console-3.exe`                         |
| `format`    | Standardformat, wenn `--format` nicht angegeben wird |

## Dateien

| Datei            | Zweck                                        |
|------------------|----------------------------------------------|
| `xcfconvert.bat` | Startprogramm (Batch, inkl. Argumente/ini)   |
| `xcf_convert.py` | Konvertierungslogik (GIMP 3 Python-Fu)       |
| `xcfconvert.ini` | Konfiguration (GIMP-Pfad, Standardformat)    |

## Technischer Hintergrund

GIMP 3 wird ohne Oberfläche gestartet:

```bat
"C:\Program Files\GIMP 3\bin\gimp-console-3.exe" -i -c -n ^
    --batch-interpreter=python-fu-eval ^
    -b "exec(open(r'xcf_convert.py').read())" --quit
```

Das Python-Script lädt jede XCF-Datei mit `Gimp.file_load` und speichert sie
mit `Gimp.file_save` – exakt derselbe Weg wie „Datei → Exportieren" in der
GIMP-Oberfläche.

## Lizenz

Frei nutzbar – Attribution nicht nötig, aber gern gesehen. 🙂
