*------------------------------------------------------------------
*  Module MBEW-XLIFO.
*Die LIFO-Daten werden geprüft.
*------------------------------------------------------------------
MODULE MBEW-XLIFO.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG = SPACE.

  CALL FUNCTION 'MBEW_XLIFO'
       EXPORTING
            WMBEW_MATNR      = MBEW-MATNR          "ch zu 3.0D
            WMBEW_BWKEY      = MBEW-BWKEY          "ch zu 3.0D
            WMBEW_XLIFO      = MBEW-XLIFO
            WMBEW_MYPOL      = MBEW-MYPOL
            WMYMS_MYPOOL     = MYMS-MYPOOL
            SPERRMODUS       = SPERRMODUS_E         "ch zu 3.0D
            NEUFLAG          = NEUFLAG              "ch zu 3.0D
            FLG_RETAIL       = RMMG2-FLG_RETAIL            "note 1434151
       IMPORTING
            WMYMS_MYPOOL     = MYMS-MYPOOL          "ch zu 4.0
       TABLES
            PTAB_IN          = PTAB.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MYPOL_HELP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MYPOL_HELP INPUT.

  DATA: BEGIN OF LT_VALUE_TAB OCCURS 0,
          MYPOOL LIKE TPOOL-MYPOOL,
          POOLTEXT LIKE TSPOL-POOLTEXT,
        END OF LT_VALUE_TAB.

  DATA: LV_MYKEY_HELP LIKE RMMG1-MYKEY.
  DATA: LT_TPOOL LIKE TPOOL OCCURS 0 WITH HEADER LINE.
  DATA: LT_TSPOL LIKE TSPOL OCCURS 0 WITH HEADER LINE.

  CLEAR LT_VALUE_TAB.
  REFRESH LT_VALUE_TAB.

* Selektieren der Daten: Je nach LIFO-Bewertungsebene werden die Daten
* mit Buchungskreis bzw. Bewertungskreis = Werk selektiert.


  CALL FUNCTION 'TCURM_SINGLE_READ'
       IMPORTING
            WTCURM = TCURM.

  IF TCURM-MYKEY_CUS = LIFOBUKRS.
    LV_MYKEY_HELP = RMMG1-BUKRS.
  ENDIF.
  IF TCURM-MYKEY_CUS = LIFOBWKEY.
    LV_MYKEY_HELP = RMMG1-BWKEY.
  ENDIF.

  SELECT * FROM TPOOL INTO LT_TPOOL
        WHERE MYKEY = LV_MYKEY_HELP.
    IF SY-SUBRC = 0.
      SELECT * FROM TSPOL INTO LT_TSPOL
          WHERE SPRAS = SY-LANGU
          AND   MYKEY = LV_MYKEY_HELP
          AND   MYPOOL = LT_TPOOL-MYPOOL.
      ENDSELECT.
      LT_VALUE_TAB-MYPOOL = LT_TPOOL-MYPOOL.
      LT_VALUE_TAB-POOLTEXT = LT_TSPOL-POOLTEXT.
      APPEND LT_VALUE_TAB.
    ENDIF.
  ENDSELECT.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD    = 'MYPOOL'
            DYNPPROG    = 'SAPLMGD1'
            DYNPNR      = '2805'
            DYNPROFIELD = 'MYPOL'
            VALUE_ORG   = 'S'
            DISPLAY     = ' '
       TABLES
            VALUE_TAB   = LT_VALUE_TAB.




ENDMODULE.                             " MYPOL_HELP  INPUT
