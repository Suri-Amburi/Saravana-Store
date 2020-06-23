*&---------------------------------------------------------------------*
*& Include          SAPMZLOAD_NC_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE .

  DATA: LW_HEAD TYPE BAPI2017_GM_HEAD_01,
        LW_ITEM TYPE BAPI2017_GM_ITEM_CREATE,
        LI_ITEM TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
        LW_CODE TYPE BAPI2017_GM_CODE,
        LI_RET  TYPE STANDARD TABLE OF BAPIRET2,
        LW_RET  TYPE BAPIRET2,
        LW_VEKP TYPE TY_VEKP.

  CONSTANTS: C_01   TYPE CHAR2 VALUE '01',
             C_FG01 TYPE CHAR4 VALUE 'FG01',
             C_101  TYPE CHAR3 VALUE '101',
             C_B    TYPE CHAR1 VALUE 'B'.

*  BREAK NCHOUDHURY.
  IF GI_TEMP IS NOT INITIAL.

    SELECT *
      FROM VEPO
      INTO TABLE GI_VEPO
      FOR ALL ENTRIES IN GI_TEMP
      WHERE VENUM = GI_TEMP-VENUM.

    IF GI_VEPO IS NOT INITIAL.

      SELECT VBELN
             POSNR
             VGBEL
             VGPOS
        FROM LIPS
        INTO TABLE GI_LIPS
        FOR ALL ENTRIES IN GI_VEPO
        WHERE VBELN = GI_VEPO-VBELN
          AND POSNR = GI_VEPO-POSNR.

    ENDIF.
  ENDIF.

  IF GI_VEPO IS NOT INITIAL AND GI_LIPS IS NOT INITIAL.

***    Fill Header for BAPI

    LW_HEAD-PSTNG_DATE = SY-DATUM.
    LW_HEAD-DOC_DATE = SY-DATUM.
    LW_HEAD-REF_DOC_NO = GV_VBELN.
    LW_HEAD-REF_DOC_NO_LONG = GV_VBELN.

***    Fill Goods Movement Code

    LW_CODE-GM_CODE = C_01.

***   Fill Item Data.

    LOOP AT GI_VEPO INTO GW_VEPO.

      LW_ITEM-MATERIAL_LONG     =     GW_VEPO-MATNR.
      LW_ITEM-PLANT             =     GW_VEPO-WERKS.
      LW_ITEM-STGE_LOC          =     C_FG01.
      LW_ITEM-BATCH             =     GW_VEPO-CHARG.
      LW_ITEM-VAL_TYPE          =     GW_VEPO-CHARG.
      LW_ITEM-MOVE_TYPE         =     C_101.
      LW_ITEM-ENTRY_QNT         =     GW_VEPO-VEMNG.
      LW_ITEM-ENTRY_UOM         =     GW_VEPO-VEMEH.
*      lw_item-entry_uom_iso     =     gw_vepo-vemeh.
*      lw_item-po_pr_qnt         =     gw_vepo-vemng.
*      lw_item-orderpr_un        =     gw_vepo-vemeh.
*      lw_item-orderpr_un_iso    =     gw_vepo-vemeh.
      READ TABLE GI_LIPS INTO GW_LIPS WITH KEY VBELN = GW_VEPO-VBELN
                                               POSNR = GW_VEPO-POSNR.
      IF SY-SUBRC = 0.
        LW_ITEM-PO_NUMBER       =     GW_LIPS-VGBEL.
        LW_ITEM-PO_ITEM         =     GW_LIPS-VGPOS.
      ENDIF.
      LW_ITEM-MVT_IND           =     C_B.
      LW_ITEM-DELIV_NUMB        =     GW_VEPO-VBELN.
      LW_ITEM-DELIV_ITEM        =     GW_VEPO-POSNR.
      LW_ITEM-QUANTITY          =     GW_VEPO-VEMNG.
      LW_ITEM-BASE_UOM          =     GW_VEPO-VEMEH.

      APPEND LW_ITEM TO LI_ITEM.
      CLEAR LW_ITEM.
    ENDLOOP.

    IF LW_HEAD IS NOT INITIAL AND LI_ITEM IS NOT INITIAL.
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          GOODSMVT_HEADER  = LW_HEAD
          GOODSMVT_CODE    = LW_CODE
*         TESTRUN          = ' '
*         GOODSMVT_REF_EWM =
*         GOODSMVT_PRINT_CTRL           =
        IMPORTING
*         GOODSMVT_HEADRET =
          MATERIALDOCUMENT = GV_MATDOC
*         matdocumentyear  =
        TABLES
          GOODSMVT_ITEM    = LI_ITEM
*         GOODSMVT_SERIALNUMBER         =
          RETURN           = LI_RET
*         GOODSMVT_SERV_PART_DATA       =
*         EXTENSIONIN      =
*         GOODSMVT_ITEM_CWM             =
        .

      IF GV_MATDOC IS NOT INITIAL.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.

        LOOP AT GI_VEKP INTO LW_VEKP.
          UPDATE VEKP SET ZZMBLNR = GV_MATDOC
                          ZZDATE = SY-DATUM
                          ZZTIME = SY-UZEIT
                          WHERE VENUM = LW_VEKP-VENUM.
        ENDLOOP.

        CLEAR GW_MESS.
        GW_MESS-ERR = 'S'.
        GW_MESS-MESS1 = ' Unloading '.
        GW_MESS-MESS2 = ' Complete !! '.
        SET SCREEN 0.
        CALL SCREEN '9999'.
        EXIT.
      ELSE.
        READ TABLE LI_RET INTO LW_RET WITH KEY TYPE = 'E'.
        IF SY-SUBRC = 0.
          CLEAR GW_MESS.
          GW_MESS-ERR = 'E'.
          GW_MESS-MESS1 = LW_RET-MESSAGE+0(20).
          GW_MESS-MESS2 = LW_RET-MESSAGE+21(20).
          GW_MESS-MESS3 = LW_RET-MESSAGE+41(20).
          GW_MESS-MESS4 = LW_RET-MESSAGE+61(20).
          GW_MESS-MESS5 = LW_RET-MESSAGE+81(20).

          SET SCREEN 0.
          CALL SCREEN '9999'.
          EXIT.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ENTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ENTER .

  IF GV_EXIDV IS NOT INITIAL.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GLOBAL_VARIABLES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GLOBAL_VARIABLES .

  CLEAR: GV_EBELN, GV_EXIDV,GV_ICON_9999,GV_ICON_NAME,GV_MATDOC,GV_PEN,GV_SCN,GV_TEXT,
         GV_TOT, GV_VBELN, GV_VEH.

  CLEAR: GI_LIPS, GI_TEMP, GI_VEKP, GI_VEPO.

  CLEAR: GW_LIPS, GW_MESS, GW_VEPO.

ENDFORM.
