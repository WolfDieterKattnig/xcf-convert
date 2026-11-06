# -*- coding: utf-8 -*-
# xcf_convert.py - Kern von xcfconvert.bat
#
# Wandelt GIMP-XCF-Dateien mit GIMP 3.x in ein Zielbildformat um.
# Die Ebenen werden in korrekter Reihenfolge mit allen Ebenenmodi
# zusammengesetzt; Transparenz und Farbprofile bleiben erhalten
# (bei Formaten ohne Transparenz, z.B. JPG, stellt GIMP automatisch
# einen weissen Hintergrund dahinter).
#
# Uebergabe per Umgebungsvariablen (setzt xcfconvert.bat):
#   XCF_SRC    Quelldatei (.xcf) oder Ordner mit .xcf-Dateien.
#              Leer = alle .xcf-Dateien aus SRCDIR.
#   XCF_FORMAT Zielformat als Endung, z.B. png, jpg, webp, tif ...
#   SRCDIR     Standardordner, wenn XCF_SRC leer ist.
#
# Manueller Aufruf (ohne bat):
#   "C:\Program Files\GIMP 3\bin\gimp-console-3.exe" -i -c -n ^
#       --batch-interpreter=python-fu-eval ^
#       -b "exec(open(r'Pfad\zu\xcf_convert.py').read())" --quit

import glob
import os

# Gimp wird von GIMP's python-eval mitgebracht, Gio muss importiert werden:
from gi.repository import Gio

fmt = (os.environ.get('XCF_FORMAT') or 'png').strip().lower().lstrip('.')
src = (os.environ.get('XCF_SRC') or '').strip().strip('"')
folder = os.environ.get('SRCDIR') or os.getcwd()

files = []
if src:
    if os.path.isdir(src):
        folder = src
        files = sorted(glob.glob(os.path.join(src, '*.xcf')))
    elif os.path.isfile(src):
        files = [src]
    elif os.path.isfile(src + '.xcf'):
        files = [src + '.xcf']
    else:
        print('FEHLER: Quelle nicht gefunden: %s' % src)
else:
    files = sorted(glob.glob(os.path.join(folder, '*.xcf')))

print('Zielformat: %s   |   %d XCF-Datei(en)' % (fmt, len(files)))
ok = 0
for f in files:
    out = os.path.splitext(f)[0] + '.' + fmt
    try:
        img = Gimp.file_load(Gimp.RunMode.NONINTERACTIVE, Gio.File.new_for_path(f))
        # Gimp.file_save erkennt das Format an der Dateiendung und verwendet
        # denselben Exporter wie "Datei -> Exportieren" in der GIMP-Oberflaeche:
        Gimp.file_save(Gimp.RunMode.NONINTERACTIVE, img, Gio.File.new_for_path(out), None)
        img.delete()
        print('OK:  %s -> %s' % (os.path.basename(f), os.path.basename(out)))
        ok += 1
    except Exception as e:
        print('FEHLER bei %s: %s' % (os.path.basename(f), e))

print('FERTIG: %d von %d konvertiert' % (ok, len(files)))
if ok < len(files):
    print('Unterstuetzte Formate: alles, was GIMP exportieren kann '
          '(png, jpg, jpeg, tif, tiff, bmp, webp, ...)')
