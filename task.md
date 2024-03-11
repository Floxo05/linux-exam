# Prüfung Linux 12.03.

## Aufgabe 14 Dubletten

Es sollen Dubletten (Files mit gleichem Inhalt) gefunden werden, auch wenn ihre Namen verschieden sind. Eine der Dubletten ist sinnvoll zu ersetzen.



- Dubletten: 
    - Dateien mit gleichem Inhalt. 
    - können Unterschiedliche Namen haben
    - können in verschiedenen Verzeichnissen liegen
- Idee zum Finden:
    - Hashwerte aus dem Inhalt der Dateien erstellen. 
    - => Sobald es doppelte Werte gibt, haben die Dateien den gleichen Inhalt und sollen ersetzt werden
- Idee zum Ersetzen:
    - Dateien durch Links ersetzen, um Speicherplatz zu sparen
    - Problem: 
        - Wie entscheidet man welche Datei man als Originaldatei behält 
    - Lösung:
        - Alle Dateien, von denen es Dubletten gibt, auslagern
        - Und alle Dubletten durch ein Link auf die neue Datei ersetzen