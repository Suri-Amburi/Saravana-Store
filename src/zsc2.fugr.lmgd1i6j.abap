*&---------------------------------------------------------------------*
*&      Module  OKCODE_EAN_ZUS  INPUT
*&---------------------------------------------------------------------*
MODULE OKCODE_EAN_ZUS INPUT.

* Wenn Bildflag außerhalb bereits gesetzt wurde und im Bildbaustein die
* Aktion Blättern im Bildbaustein angewählt wurde, darf das Blättern
* nicht ausgeführt werden (sonst werden ungeprüfte Daten fortge-
* schrieben).
  IF NOT EAN_BILDFLAG_OLD IS INITIAL AND
     ( RMMZU-OKCODE = FCODE_EAFP OR
       RMMZU-OKCODE = FCODE_EAPP OR
       RMMZU-OKCODE = FCODE_EANP OR
       RMMZU-OKCODE = FCODE_EALP  ).
    CLEAR RMMZU-OKCODE.                " kein Blättern ! !
  ENDIF.

* AHE: 15.07.96 - A
* Umstellung auf Table-Control
  IF EAN_BILDFLAG_OLD IS INITIAL.
*   Blättern erlauben für Table-Control
    IF NOT FLG_TC IS INITIAL.
      EAN_ERSTE_ZEILE = TC_EAN-TOP_LINE - 1.
*   wurde geblättert mit TabCtrl ?
      IF TC_EAN-TOP_LINE NE TC_EAN_TOPL_BUF.
        TC_EAN_TOPL_BUF = TC_EAN-TOP_LINE.
        PERFORM PARAM_SET.
      ENDIF.
    ENDIF.
  ENDIF.
* AHE. 15.07.96 - E

  PERFORM OK_CODE_EAN_ZUS.

ENDMODULE.                             " OKCODE_EAN_ZUS  INPUT
