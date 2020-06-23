*----------------------------------------------------------------------*
*   INCLUDE LMGD1I7M                                                   *
*----------------------------------------------------------------------*
*   Überprüfung der Hierarchie: stimmt mesub?
*   Neuberechnung von azsub oder umren und umrez
*   Rel. 4.6A JW
*----------------------------------------------------------------------*

MODULE ME_SUB_STRUKTUR_PRUEFEN.

* check me_doppeintrag_ges is initial. -> faengt Doppeleintraege nicht
* ab, da nur Doppeleintraege auf dem angezeigten Ausschnitt des Table
* Controls erkannt werden.
PERFORM ME_SUB_STRUKTUR_PRUEFEN.

ENDMODULE.
