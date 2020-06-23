*&---------------------------------------------------------------------*
*&      Module  OK_CODE_MEINH_II  INPUT
*&---------------------------------------------------------------------*
*       Restliche OK-CODEs bearbeiten.                                 *
*       - Blättern
*----------------------------------------------------------------------*
MODULE OK_CODE_MEINH_II INPUT.

* JW/4.6A: Zurücksortierung - Anfang
* WS Abwicklung: zusätzliche Sortierung nach Sort-Regel/Verwendungs-KZ
  if bildflag is initial.
     SORT MEINH BY KZBME DESCENDING MESRT ASCENDING
                                    KZWSO ASCENDING
                                    MEINH ASCENDING.
  endif.
* JW/4.6A: Zurücksortierung - Ende

* Wenn Bildflag außerhalb bereits gesetzt wurde und im Bildbaustein die
* Aktion Blättern im Bildbaustein angewählt wurde, darf das Blättern
* nicht ausgeführt werden (sonst werden ungeprüfte Daten fortge-
* schrieben).
  IF NOT ME_BILDFLAG_OLD IS INITIAL AND
     ( RMMZU-OKCODE = FCODE_MEFP OR
       RMMZU-OKCODE = FCODE_MEPP OR
       RMMZU-OKCODE = FCODE_MENP OR
       RMMZU-OKCODE = FCODE_MELP  ).
    CLEAR RMMZU-OKCODE.
  ENDIF.

* AHE: 16.07.96 - A
* Umstellung auf Table-Control
  IF ME_BILDFLAG_OLD IS INITIAL.
*   Blättern erlauben für Table-Control
    IF NOT FLG_TC IS INITIAL.
      CASE SY-DYNNR.
        WHEN DP_8020.
          ME_ERSTE_ZEILE = TC_ME_8020-TOP_LINE - 1.
*       wurde geblättert mit TabCtrl ?
          IF TC_ME_8020-TOP_LINE NE TC_ME_TOPL_BUF.
            TC_ME_TOPL_BUF = TC_ME_8020-TOP_LINE.
            PERFORM PARAM_SET.
          ENDIF.

        WHEN DP_8021.
          ME_ERSTE_ZEILE = TC_ME_8021-TOP_LINE - 1.
*       wurde geblättert mit TabCtrl ?
          IF TC_ME_8021-TOP_LINE NE TC_ME_TOPL_BUF.
            TC_ME_TOPL_BUF = TC_ME_8021-TOP_LINE.
            PERFORM PARAM_SET.
          ENDIF.

      WHEN DP_8022.             "jw 20.11.98
        ME_ERSTE_ZEILE = TC_ME_8022-TOP_LINE - 1.
*       wurde geblättert mit tabctrl ?
        IF TC_ME_8022-TOP_LINE NE TC_ME_TOPL_BUF.
          TC_ME_TOPL_BUF = TC_ME_8022-TOP_LINE.
          PERFORM PARAM_SET.
        ENDIF.

      WHEN DP_8024.             " Note 745304
        ME_ERSTE_ZEILE = TC_ME_8024-TOP_LINE - 1.
*       wurde geblättert mit tabctrl ?
        IF TC_ME_8024-TOP_LINE NE TC_ME_TOPL_BUF.
          TC_ME_TOPL_BUF = TC_ME_8024-TOP_LINE.
          PERFORM PARAM_SET.
        ENDIF.

      ENDCASE.
    ENDIF.
* ELSE.
* evtuelles Blättern mit TCtrl wieder zurücksetzen
*   CASE SY-DYNNR.
*     WHEN DP_8020.
*         TC_ME_8020-TOP_LINE = TC_ME_TOPL_BUF.
*         ME_ERSTE_ZEILE = TC_ME_8020-TOP_LINE - 1.
*
*     WHEN DP_8021.
*         TC_ME_8021-TOP_LINE = TC_ME_TOPL_BUF.
*         ME_ERSTE_ZEILE = TC_ME_8021-TOP_LINE - 1.
*
*     WHEN DP_8022.
*         TC_ME_8022-TOP_LINE = TC_ME_TOPL_BUF.
*         ME_ERSTE_ZEILE = TC_ME_8022-TOP_LINE - 1.
*   ENDCASE.

  ENDIF.
* AHE: 16.07.96 - E

  PERFORM OK_CODE_MEINH.

* note 700229
  IF NOT BILDFLAG IS INITIAL AND NOT NOT_SET_OLD_MEINH = 'N'.
    NOT_SET_OLD_MEINH = 'X'.
  ELSE.
    CLEAR NOT_SET_OLD_MEINH.
  ENDIF.

ENDMODULE.                             " OK_CODE_MEINH_II  INPUT
