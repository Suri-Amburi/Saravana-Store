*&---------------------------------------------------------------------*
*&      Module  DATENUEBERNAHME_EAN  INPUT
*&---------------------------------------------------------------------*
*   Übernehmen der Ean-Spezifischen Daten in die Tabelle MEINH         *
*   Die Daten zur Basis-ME werden zusätzlich in die Tabelle MARA       *
*   übernommen.                                                        *
*----------------------------------------------------------------------*
MODULE DATENUEBERNAHME_EAN INPUT.

* Gleiche Abfrage wie bei Prüfungen cfo/7.2./96
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CHECK SMEINH-MEINH NE SPACE.

* note 1034796: do GTIN variant check before data transfer MARA<>MEINH
  IF rmmzu-okcode NE fcode_mede.
*   Prüfung auf  GTIN_VARIANT
    CALL FUNCTION 'MARA_GTIN_VARIANT'
      EXPORTING
        meinh                    = meinh
* note 1111084: loop on screen for all uoms, so no need to give the
* whole MEINH table to the BAdI BADI_GTIN_VARIANT
*    TABLES
*      MEINH_TAB              = MEINH
    CHANGING
       gtin_variant              = meinh-gtin_variant
      EXCEPTIONS
        gtin_variant_wrong       = 2
        ean_missing              = 3
            .
  CASE SY-SUBRC.
    WHEN '3'.
      SET CURSOR FIELD 'SMEINH-EAN11'.
        MESSAGE e553(MM).
    WHEN '2'.
      SET CURSOR FIELD 'SMEINH-GTIN_VARIANT'.
      MESSAGE E552(MM).
  ENDCASE.
  ENDIF.

*--- Übernehmen der Eingabe.
  MODIFY meinh INDEX me_akt_zeile.

  CHECK bildflag IS INITIAL.
  CHECK rmmzu-okcode NE fcode_mede.

*--- Aktuelle Zeile Meinh nach Smeinh übernehmen.
  MOVE meinh TO smeinh.
  CALL FUNCTION 'DATENUEBERNAHME_EAN'
    EXPORTING
      wmara    = mara
      p_smeinh = smeinh
    IMPORTING
      wmara    = mara
    TABLES
      ptab     = ptab.

ENDMODULE.                             " DATENUEBERNAHME_EAN  INPUT
*&---------------------------------------------------------------------*
*&      Module  MLEA_GET_SUB  INPUT
*&---------------------------------------------------------------------*
*       Relevant data for the screen is read from the buffer for each  *
*       function group, and set in an intermediate buffer              *
*----------------------------------------------------------------------*
MODULE MLEA_GET_SUB INPUT.

  PERFORM MLEA_GET_SUB IN PROGRAM (GV_PROG) IF FOUND.

ENDMODULE.                 " MLEA_GET_SUB  INPUT
*&---------------------------------------------------------------------*
*&      Module  EAN_TMLEA_AKT_MEINH  INPUT
*&---------------------------------------------------------------------*
* EAN-Lieferantenbezug-Handling
*----------------------------------------------------------------------*
MODULE EAN_TMLEA_AKT_MEINH INPUT.
* EAN-Lieferantenbezug-Handling
* Wenn ein Abfrage-Pop-UP mit "NEIN" verlassen wurde, darf die EAN
* nicht geändert werden
  PERFORM EAN_TMLEA_AKT_MEINH IN PROGRAM (GV_PROG) IF FOUND.
ENDMODULE.                 " EAN_TMLEA_AKT_MEINH  INPUT
*&---------------------------------------------------------------------*
*&      Module  MLEA_SET_SUB  INPUT
*&---------------------------------------------------------------------*
*       Any data changes are checked and retured to intermediate buffer*
*----------------------------------------------------------------------*
MODULE MLEA_SET_SUB INPUT.

  PERFORM MLEA_SET_SUB IN PROGRAM (GV_PROG) IF FOUND.

ENDMODULE.                 " MLEA_SET_SUB  INPUT
*&---------------------------------------------------------------------*
*&      Module  EAN_CONSISTENCY_CHECK_MARA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EAN_CONSISTENCY_CHECK_MARA INPUT.

  CHECK bildflag IS INITIAL.      "note 1548838, required for main views

  PERFORM EAN_CONSISTENCY_CHECK_MARA IN PROGRAM (GV_PROG) IF FOUND.

ENDMODULE.                 " EAN_CONSISTENCY_CHECK_MARA  INPUT
*&---------------------------------------------------------------------*
*&      Module  EAN_CONSISTENCY_CHECK_MARM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EAN_CONSISTENCY_CHECK_MARM INPUT.

  PERFORM EAN_CONSISTENCY_CHECK_MARM IN PROGRAM (GV_PROG) IF FOUND.

ENDMODULE.                 " EAN_CONSISTENCY_CHECK_MARM  INPUT
