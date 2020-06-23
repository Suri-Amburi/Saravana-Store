FUNCTION INIT_MGD2_.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"--------------------------------------------------------------------
* Einstieg in das Programm, dem der Bildbaustein zugeordnet ist
* - Holen der zentralen Steuerungsparameter beim 1. Aufruf des Programms
* - Holen der Steuerungsdaten für den speziellen Bildbaustein

   PERFORM INIT_BAUSTEIN.

ENDFUNCTION.
