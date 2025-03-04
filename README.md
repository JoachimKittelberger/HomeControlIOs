#  HomeControl

[Markdown Erklärung](https://www.markdownguide.org/cheat-sheet/)

[heise Erklärung](https://www.heise.de/mac-and-i/downloads/65/1/1/6/7/1/0/3/Markdown-CheatSheet-Deutsch.pdf)

## Architecture

### Kommunikation mit der Steuerung
**Lesen und schreiben von Werten**  
Für die Kommunikation mit der Steuerung werden für jeden Aufrauf ein PLCDataAccessEntry erstellt, das dann in die PLCDataAccessQueue gestellt wird. Dabei wird eine eindeutige ID erstellt und in der telegramID abgespeichert. Diese wird der Steuerung als comRef übergeben und kann beim Empfangen der Nachrichten dann als eindeutige Zuordnung des PLCDataAccessEntry verwendet werden
In der Funktion udpSocket(:didReceive) wird die comRef ausgelesen und anhand dieser in der PLCDataAccessQueue nach der entsprechenden telegramID gesucht, um den zugehörigen PLCDataAccessEntry zu finden und weiter zu bearbeiten
Den Jet32-Read-Funktionen kann optional ein Delegate mitgegeben werden, das beim Return aus der Steuerung aufgerufen wird. Ist dieses Delegate nicht gesetz, wird das Standard-Delegate aufgerufen
Der interne Ablauf beim lesen ist folgender:
Watch
- **PLCComMgr.readIntRegister**
  - **Jet32Watch.readIntRegister**
    - **Connectivity.sendMessage(:replyHandler:errorHandler)**
    
Kommt dann auf iPhone an in
- **Connectivity.session.didReceiveMessage(:session:didReceiveMessage:replyHandler)**

oder bei 
- **Connectivity.session.didReceiveMessage(:session:didReceiveMessage)**

Dort wird message verarbeitet und dann z.B. über 
- **PLCComMgr.shared.readIntRegister(:::delegate)**

der aktuelle Wert von der Steuerung geholt. Es wird dem Delegate der Zeiger auf die eigene Klasse mitgegeben. Dabei wird eine DispatchSemaphore verwendet, um auf das Ergebnis des readIntRegister-Aufrufs zu warten.
Der readIntRegister-Aufruf liefert asynchron in
- **Connectivity.didReceiveReadIntRegister**

zurück. Diese Funktion wird über das übergebene delegate in der Funktion
- **udpSocket(::didReceive)**

aufgerufen. Dort wird dann der zurückgelesene Wert global gespeichert und über die Semaphore die Thread-Fortführung in der Funktion
- **Connectivity.session.didReceiveMessage(:session:didReceiveMessage:replyHandler)**

freigegeben.
### Möglichkeit 1:
Der Rückgabewert wird dann in eine responseMessage verpackt und über **seesion.sendMessage(message:nil:error)** wieder an die Watch zurückgesendet

Dort kommt das Ergebnis in
- **Connectivity.session(didReceiveMessage)**

an und wird dann der Funktion
- **PLCComMgr.shared.getDelegate()?.didReceiveReadIntRegister()**

als "Callback" zurückgegeben.

### Möglichkeit 2
Der Rückgabewert wird dann in eine responseMessage verpackt und über **replyHandler(responseMessage))** wieder an die Watch zurückgesendet

Dort kommt das Ergebnis in
- **Jet32Watch.readIntRegister**

in der Closure an an und wird dann der Funktion
- **self.delegate?.didReceiveReadIntRegister()**

als "Callback" zurückgegeben.

In der Callback-Funktion kann dann z.B. eine State-Variable in der entsprechenden View, die ihren delegate gesetzt hat, aktualisiert werden.





## Umgesetzte Features
* [x] Function Jet32.udpSocket(didReceive) des GCDAsyncUdpSocketDelegates überarbeiten und mit allen Datentypen testen
* [x] Prüfen, was bei den Schreibbefehlen zurück gegeben wird. Evtl. Delegate vereinfachen
* [x] ReadFlags in Watch
* [x] WriteRegister und WriteFlags in Watch
* [x] Bei SetFlag noch die PLCDataAccessQueue verwenden
* [x] Jet32Delegate wird nicht wirklich sauber verwendet. Wir dnur in Views aufgerufen
* [x] Evtl. von ReplyHandler bei iPhone auf direktes Senden umstellen, da dies vermutlich performanter ist. -> geht auch nicht schneller
* [x] Jet32SyncExample.swift einbauen oder rauswerfen  
* [x] Bei erstmaligem Laden der neuen Werte und setzen in den Controls, diesen das erste Mal nicht wieder in die Steuerung zurückschreiben
* [x] Synchrones lesen nochmals anschauen, ob an der richtigen Stelle Semaphore verwendet wird
* [x] LifeCycle der App tracen (Beispiele bei RayWenderlich)
* [x] Timeout bei Sync-Calls mit Timeout aus Settings umsetzen. Aktuell hardcoded auf 4s



## TODO
* [ ] Complication erstellen, mit der die App vom Zifferblatt aus gestartet werden kann. WidgetKit und Complication unter iOS und watchOS
- Anzeige im Widget: Sonne/Dunkel, Wind/Kein Wind
- Datenaustausch mit
  - AppGroups, Shared UserDefaults. Name: group.bundleidentiefer
  - widgetURL, onOpenURL
  - Notifications?
  - in App: WidgetCenter.shared.reloadAllTimeLines() -> Widget wird neu geladen und timeline-Function wird ausgeführt


* [ ] Info-Seite erstellen
* [ ] Versionsnummer beim Build oder manuell inkrementieren und in Info-Seite und beim Start anzeigen
* [ ] Auf Watch Möglichkeit schaffen, Verbindung zum iPhone zu testen und Elemente nur enablen, wenn Verbindung da ist.
* [ ] Umgang mit Notification, NotifiactionCenter.Publish -> onReceive(...)
