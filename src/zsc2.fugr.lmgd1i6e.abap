*&---------------------------------------------------------------------*
*&      Module  PREPARE_EAN_ZUS  INPUT
*&---------------------------------------------------------------------*
*       Sortiert die interne Tabelle und setzt Flag zum bereinigen
*       der Tabelle, falls mindestens einmal vorkommt, daß eine
*       EAN zu einer Mengeneinheit doppelt eingetragen wurde.
*----------------------------------------------------------------------*
MODULE PREPARE_EAN_ZUS INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  CLEAR: HILFS_EAN, HILFS_MEEIN.

* Falls doppelte Einträge innerhalb einer Mengeneinheit vorkommen,
* Flag setzen, um MEAN_ME_TAB nachzubearbeiten.
* Abfrage ist korrekt, da MEAN_ME_TAB sortiert ist nach EAN.
  IF MEAN_ME_TAB_CHECK IS INITIAL.
    LOOP AT MEAN_ME_TAB.
      IF  ( MEAN_ME_TAB-EAN11 = HILFS_EAN    AND
            NOT MEAN_ME_TAB-EAN11 IS INITIAL AND
            MEAN_ME_TAB-MEINH = HILFS_MEEIN ).
        MEAN_ME_TAB_CHECK = X.
      ELSE.
        HILFS_EAN   = MEAN_ME_TAB-EAN11.
        HILFS_MEEIN = MEAN_ME_TAB-MEINH.
      ENDIF.

* Wenn eine MEINH keine EAN zugeordnet hat, darf auch das KZ Haupt-EAN
* nicht gesetzt sein -> MEAN_ME_TAB wird nachbearbeitet.
* --> in Modul CLEAN_MEINH behandelt
      IF MEAN_ME_TAB-EAN11 IS INITIAL.
        "AND NOT MEAN_ME_TAB-HPEAN IS INITIAL.           "note 2015371
        MEAN_ME_TAB_CHECK = X.
      ENDIF.

* evtl. Sparen einiger redundanter Loop-Steps
      IF NOT MEAN_ME_TAB_CHECK IS INITIAL.
        EXIT.
      ENDIF.

    ENDLOOP.
  ENDIF.

ENDMODULE.                             " PREPARE_EAN_ZUS  INPUT
