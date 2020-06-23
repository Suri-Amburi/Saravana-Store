*------------------------------------------------------------------
* MEINH_aktualisieren
*Die EAN-Spez. Daten der bisherigen Basis-ME werden, falls vorhanden,
*in die neue Basis-ME übernommen.
*Die neue Basis-ME wird in die Tabelle MEINH aufgenommen, die
*alte Basis-ME wird aus der Tabelle MEINH gelöscht.
* War noch kein Eintrag zur Basis-Me vorhanden (nur bei Neuanlage
* auf dem 1. Bild möglich - ansonsten bereits durch Material_lesen
* oder durch Pflege des 1. Bildes gewährleistet), wird dieser erzeugt.
*------------------------------------------------------------------
FORM MEINH_AKTUALISIEREN.

  CLEAR FLAG3.
  LOOP AT MEINH WHERE KZBME NE SPACE.
    MOVE MARA-MEINS TO MEINH-MEINH.
    PERFORM EANDATEN_BME USING FLAG3.
    INSERT MEINH.
    DELETE MEINH.
  ENDLOOP.
  IF NOT FLAG3 IS INITIAL AND T130M-AKTYP EQ AKTYPH.
*---- EAN-Daten zur alten ME vorhanden - beim Ändern wird stattdessen
*---- Popup gesendet
    "Note 1877124
    CALL FUNCTION 'ME_CHECK_T160M'
      EXPORTING
        I_ARBGB = 'M3'
        I_MSGNR = '341'
        I_MSGVS = '00'
      EXCEPTIONS
        NOTHING = 01
        WARNING = 02
        ERROR   = 03.
    CASE SY-SUBRC.
      WHEN 1.
      WHEN 2 OR 3.
        MESSAGE W341(M3).
    ENDCASE.
  ENDIF.
  IF SY-SUBRC NE 0.
*--- Noch kein Eintrag zur Basis-ME vorhanden -------------------------
    CLEAR MEINH.
    MEINH-MEINH = MARA-MEINS.
    MEINH-UMREN = 1.
    MEINH-UMREZ = 1.
    MEINH-KZBME = X.
    APPEND MEINH.         "sort nicht nötig, da MEINH leer sein muß
  ENDIF.

ENDFORM.
