*&---------------------------------------------------------------------*
*& Include          ZSAPMP_MM_GOODS_RETURN_PO_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CHECK_LIFNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_LIFNR INPUT.
  BREAK BREDDY .
  IF IT_FINAL IS NOT INITIAL .
    IF LV_BATCH IS NOT INITIAL AND LV_PLANT IS NOT INITIAL.

********changes done by bhavani 13.12.2019***************

*      SELECT
*       ZB1_BATCH_T~B1_BATCH ,
*       ZB1_BATCH_T~B1_VENDOR ,
*       ZB1_BATCH_T~S4_BATCH FROM ZB1_BATCH_T INTO TABLE @DATA(IT_ZB1_BATCH_T)
*                            WHERE B1_BATCH = @LV_BATCH .
*
*
*
*      READ TABLE IT_ZB1_BATCH_T ASSIGNING FIELD-SYMBOL(<LS_ZB1_BATCH_T>) WITH KEY B1_BATCH = LV_BATCH .
*      IF SY-SUBRC NE 0.
      SELECT
        BWART
        MATNR
        WERKS
        CHARG
        LIFNR
        EBELN FROM MSEG INTO TABLE IT_LIF
              WHERE CHARG = LV_BATCH
              AND   WERKS = LV_PLANT.


      IF IT_LIF IS NOT INITIAL .
        SELECT  EKKO~EBELN,
                EKKO~EKGRP FROM EKKO INTO TABLE @DATA(IT_EKKO1)
                 FOR ALL ENTRIES IN @IT_LIF
                 WHERE EBELN =  @IT_LIF-EBELN .
      ENDIF .


      READ TABLE IT_LIF ASSIGNING FIELD-SYMBOL(<LS_BATCH>) WITH KEY CHARG = LV_BATCH WERKS = LV_PLANT.
      IF SY-SUBRC NE 0.
        SELECT
        ZB1_BATCH_T~B1_BATCH ,
        ZB1_BATCH_T~B1_VENDOR ,
        ZB1_BATCH_T~S4_BATCH FROM ZB1_BATCH_T INTO TABLE @DATA(IT_ZB1_BATCH_T)
                             WHERE B1_BATCH = @LV_BATCH .
        READ TABLE IT_ZB1_BATCH_T ASSIGNING FIELD-SYMBOL(<LS_ZB1_BATCH_T>) INDEX 1 .
        IF SY-SUBRC = 0 .
          SELECT SINGLE
          MBEW~MATNR ,
          MBEW~BWKEY ,
          MBEW~BWTAR  FROM MBEW INTO @DATA(LS_MBEW)
                   WHERE BWTAR = @<LS_ZB1_BATCH_T>-S4_BATCH
                   AND BWKEY = @LV_PLANT.
        ENDIF .

        IF LS_MBEW IS NOT INITIAL.
          SELECT SINGLE
          MARA~MATNR ,
          MARA~MATKL FROM MARA INTO  @DATA(LS_MARA)
                     WHERE MATNR = @LS_MBEW-MATNR .
        ENDIF.


        IF LS_MARA-MATKL IS NOT INITIAL.
          CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
            EXPORTING
              MATKL       = LS_MARA-MATKL
              SPRAS       = SY-LANGU
            TABLES
              O_WGH01     = IT_O_WGH01
            EXCEPTIONS
              NO_BASIS_MG = 1
              NO_MG_HIER  = 2
              OTHERS      = 3.
          IF SY-SUBRC <> 0.
* Implement suitable error handling here
          ENDIF.

        ENDIF.

        READ TABLE IT_O_WGH01 INTO WA_O_WGH01 INDEX 1.
        IF SY-SUBRC = 0.
          SELECT SINGLE
            T024~EKGRP,
            T024~EKNAM FROM T024 INTO @DATA(WA_T024)
                       WHERE EKNAM = @WA_O_WGH01-WWGHA .
        ENDIF.


*        READ TABLE IT_ZB1_BATCH_T ASSIGNING FIELD-SYMBOL(<LS_ZB1_BATCH_T>) WITH KEY B1_BATCH = LV_BATCH .
*        IF SY-SUBRC = 0.
        IF <LS_ZB1_BATCH_T>-B1_VENDOR IS NOT INITIAL .
          READ TABLE IT_FINAL ASSIGNING FIELD-SYMBOL(<LS_FIL>) WITH KEY LIFNR =  <LS_ZB1_BATCH_T>-B1_VENDOR.
          IF SY-SUBRC NE 0.
            MESSAGE 'Vendor is different for this Batch' TYPE  'E' .
          ENDIF.
        ENDIF.
*        ENDIF.

        IF WA_T024-EKGRP IS NOT INITIAL.
          READ TABLE IT_FINAL ASSIGNING FIELD-SYMBOL(<LS_EKGRP>) WITH KEY EKGRP =  WA_T024-EKGRP.
          IF SY-SUBRC NE 0.
            MESSAGE 'Purchase Group is different for this Batch' TYPE  'E' .
          ENDIF.
        ENDIF.
        IF LS_MBEW-BWKEY <> LV_PLANT.
          MESSAGE 'Plant is different for this Batch' TYPE 'E' .

        ENDIF.
      ELSE.

        IF IT_LIF IS NOT INITIAL.
          READ TABLE IT_LIF ASSIGNING FIELD-SYMBOL(<LS_LIF1>) INDEX 1 .
          IF SY-SUBRC = 0.
            READ TABLE IT_FINAL ASSIGNING FIELD-SYMBOL(<LS_LIF>) WITH KEY LIFNR =  <LS_LIF1>-LIFNR.
            IF SY-SUBRC NE 0.
              MESSAGE 'Vendor is different for this Batch' TYPE  'E' .
            ENDIF.
            READ TABLE IT_FINAL ASSIGNING FIELD-SYMBOL(<LS_LIF_P>) WITH KEY WERKS =  <LS_LIF1>-WERKS .
            IF SY-SUBRC NE 0.
              MESSAGE 'Plant is different for this Batch' TYPE  'E' .
            ENDIF.
          ENDIF.

          READ TABLE IT_EKKO1 ASSIGNING FIELD-SYMBOL(<LS_EKKO1>) WITH KEY EBELN = <LS_LIF1>-EBELN .
          IF SY-SUBRC = 0.
            READ TABLE IT_FINAL ASSIGNING FIELD-SYMBOL(<LS_GRP>) WITH KEY EKGRP =  <LS_EKKO1>-EKGRP.
            IF SY-SUBRC NE 0.
              MESSAGE 'Purchase Group is different for this Batch' TYPE  'E' .
            ENDIF.
          ENDIF.
        ENDIF .

      ENDIF.

*    IF IT_ZB1_BATCH_T is NOT INITIAL.

*      SELECT SINGLE
*        MBEW~MATNR ,
*        MBEW~BWKEY ,
*        MBEW~BWTAR  FROM MBEW INTO @DATA(LS_MBEW)
*                    WHERE BWTAR = @LV_BATCH .
*
*      IF LS_MBEW IS NOT INITIAL.
*        SELECT SINGLE
*        MARA~MATNR ,
*        MARA~MATKL FROM MARA INTO  @DATA(LS_MARA)
*                   WHERE MATNR = @LS_MBEW-MATNR .
*      ENDIF.
*
*
*      IF LS_MARA-MATKL IS NOT INITIAL.
*        CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
*          EXPORTING
*            MATKL       = LS_MARA-MATKL
*            SPRAS       = SY-LANGU
*          TABLES
*            O_WGH01     = IT_O_WGH01
*          EXCEPTIONS
*            NO_BASIS_MG = 1
*            NO_MG_HIER  = 2
*            OTHERS      = 3.
*        IF SY-SUBRC <> 0.
** Implement suitable error handling here
*        ENDIF.
*
*      ENDIF.
*
*      READ TABLE IT_O_WGH01 INTO WA_O_WGH01 INDEX 1.
*      IF SY-SUBRC = 0.
*        SELECT SINGLE
*          T024~EKGRP,
*          T024~EKNAM FROM T024 INTO @DATA(WA_T024)
*                     WHERE EKNAM = @WA_O_WGH01-WWGHA .
*      ENDIF.
*
*
*
*      IF <LS_ZB1_BATCH_T>-B1_VENDOR IS NOT INITIAL .
*        READ TABLE IT_FINAL ASSIGNING FIELD-SYMBOL(<LS_FIL>) WITH KEY LIFNR =  <LS_ZB1_BATCH_T>-B1_VENDOR.
*        IF SY-SUBRC NE 0.
*          MESSAGE 'Vendor is different for this Batch' TYPE  'E' .
*        ENDIF.
*      ENDIF.
*
*      IF WA_T024-EKGRP IS NOT INITIAL.
*        READ TABLE IT_FINAL ASSIGNING FIELD-SYMBOL(<LS_EKGRP>) WITH KEY EKGRP =  WA_T024-EKGRP.
*        IF SY-SUBRC NE 0.
*          MESSAGE 'Purchase Group is different for this Batch' TYPE  'E' .
*        ENDIF.
    ENDIF.
  ENDIF.






ENDMODULE.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
*  BREAK BREDDY .



  IF LV_BATCH IS NOT INITIAL AND LV_PLANT IS NOT INITIAL .

    SELECT
      BWART
      MATNR
      WERKS
      CHARG
      LIFNR
      EBELN FROM MSEG INTO TABLE IT_MSEG
            WHERE CHARG = LV_BATCH
            AND BWART IN ( '101' , '107' )
            AND CHARG NE ' '.


    IF IT_MSEG IS INITIAL.

      SELECT
        ZB1_BATCH_T~B1_BATCH ,
        ZB1_BATCH_T~B1_VENDOR ,
        ZB1_BATCH_T~S4_BATCH FROM ZB1_BATCH_T INTO TABLE @DATA(LT_ZB1_BATCH_T)
                             WHERE B1_BATCH = @LV_BATCH .
    ENDIF .


    IF IT_MSEG IS NOT INITIAL.
      SELECT
       EKKO~EBELN,
       EKKO~EKGRP FROM EKKO INTO TABLE @DATA(IT_EKKO)
             FOR ALL ENTRIES IN @IT_MSEG
             WHERE EBELN =  @IT_MSEG-EBELN .

      SELECT
         MATNR
         BWKEY
         BWTAR
         VERPR FROM MBEW INTO TABLE IT_MBEW
               FOR ALL ENTRIES IN IT_MSEG
               WHERE BWTAR = IT_MSEG-CHARG
               AND   MATNR = IT_MSEG-MATNR
               AND   BWKEY = LV_PLANT.
      SELECT
        LFA1~LIFNR ,
        LFA1~NAME1 FROM LFA1 INTO TABLE @DATA(IT_LFA1)
                   FOR ALL ENTRIES IN @IT_MSEG
                   WHERE LIFNR = @IT_MSEG-LIFNR .


    ELSE.

      IF LT_ZB1_BATCH_T IS NOT INITIAL .
        SELECT
           MBEW~MATNR ,
           MBEW~BWKEY ,
           MBEW~BWTAR ,
           MBEW~VERPR FROM MBEW INTO TABLE @DATA(LT_MBEW)
                 FOR ALL ENTRIES IN @LT_ZB1_BATCH_T
                 WHERE BWTAR = @LT_ZB1_BATCH_T-S4_BATCH
                 AND   BWKEY = @LV_PLANT.
        SELECT
          LFA1~LIFNR ,
          LFA1~NAME1 FROM LFA1 INTO TABLE @DATA(LT_LFA1)
                     FOR ALL ENTRIES IN @LT_ZB1_BATCH_T
                     WHERE LIFNR = @LT_ZB1_BATCH_T-B1_VENDOR .

      ENDIF.

      IF LT_MBEW IS NOT INITIAL.
        SELECT
        MARA~MATNR ,
        MARA~MATKL FROM MARA INTO TABLE  @DATA(LT_MARA)
                   FOR ALL ENTRIES IN @LT_MBEW
                   WHERE MATNR = @LT_MBEW-MATNR .
      ENDIF.
      READ TABLE LT_MARA ASSIGNING FIELD-SYMBOL(<LS_MARA_B>) INDEX 1 .
      IF SY-SUBRC = 0 .
        IF <LS_MARA_B>-MATKL IS NOT INITIAL.
          CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
            EXPORTING
              MATKL       = <LS_MARA_B>-MATKL
              SPRAS       = SY-LANGU
            TABLES
              O_WGH01     = IT_O_WGH01_B
            EXCEPTIONS
              NO_BASIS_MG = 1
              NO_MG_HIER  = 2
              OTHERS      = 3.
          IF SY-SUBRC <> 0.
* Implement suitable error handling here
          ENDIF.

        ENDIF.
      ENDIF.

      READ TABLE IT_O_WGH01_B INTO WA_O_WGH01 INDEX 1.
      IF SY-SUBRC = 0.
        SELECT SINGLE
          T024~EKGRP,
          T024~EKNAM FROM T024 INTO @DATA(WA_T024_B)
                     WHERE EKNAM = @WA_O_WGH01_B-WWGHA .
      ENDIF.

    ENDIF.


    IF IT_MSEG IS NOT INITIAL.
      LOOP AT IT_MSEG INTO WA_MSEG.

        WA_FINAL-MATNR = WA_MSEG-MATNR .
        WA_FINAL-LIFNR = WA_MSEG-LIFNR .
        WA_FINAL-WERKS = WA_MSEG-WERKS.
        WA_FINAL-CHARG = LV_BATCH.
        WA_FINAL-TAX_PER = ' '.
        WA_FINAL-TAX_VAL = ' '.
        READ TABLE IT_LFA1 ASSIGNING FIELD-SYMBOL(<LS_LFA1>) WITH KEY LIFNR = WA_MSEG-LIFNR .
        IF SY-SUBRC = 0.

          WA_FINAL-NAME1 = <LS_LFA1>-NAME1 .

        ENDIF.
        READ TABLE IT_EKKO ASSIGNING FIELD-SYMBOL(<LS_EKKO>) WITH KEY EBELN = WA_MSEG-EBELN .
        IF SY-SUBRC = 0.
          WA_FINAL-EKGRP = <LS_EKKO>-EKGRP.
        ENDIF.

        READ TABLE IT_MBEW INTO WA_MBEW WITH KEY BWTAR = WA_MSEG-CHARG .
        IF SY-SUBRC = 0.
          WA_FINAL-VERPR =  WA_MBEW-VERPR .
        ENDIF.

        READ TABLE IT_FINAL ASSIGNING FIELD-SYMBOL(<LS_FINAL>) WITH KEY CHARG = LV_BATCH.

        IF SY-SUBRC = 0.
          WA_FINAL-QUANTITY = <LS_FINAL>-QUANTITY + 1.
          WA_FINAL-VALUE = WA_FINAL-QUANTITY * WA_MBEW-VERPR  .
          MODIFY TABLE IT_FINAL FROM WA_FINAL TRANSPORTING QUANTITY VALUE .
        ELSE .
          WA_FINAL-QUANTITY = 1.
          WA_FINAL-VALUE = WA_FINAL-QUANTITY * WA_MBEW-VERPR  .
          APPEND WA_FINAL TO IT_FINAL .
          CLEAR : WA_FINAL .
        ENDIF.
      ENDLOOP.

    ELSE .

      LOOP AT LT_MBEW ASSIGNING FIELD-SYMBOL(<LS_MBEW_B>).
        WA_FINAL-VERPR =  <LS_MBEW_B>-VERPR .
        WA_FINAL-MATNR = <LS_MBEW_B>-MATNR .
        READ TABLE LT_ZB1_BATCH_T ASSIGNING FIELD-SYMBOL(<LS_ZB1_BATCH_T_B>) WITH KEY B1_BATCH = LV_BATCH .
        IF SY-SUBRC = 0 .
          WA_FINAL-LIFNR = <LS_ZB1_BATCH_T_B>-B1_VENDOR .
        ENDIF .
        WA_FINAL-WERKS = LV_PLANT.
        WA_FINAL-CHARG = LV_BATCH.
        WA_FINAL-TAX_PER = ' '.
        WA_FINAL-TAX_VAL = ' '.
        READ TABLE LT_LFA1 ASSIGNING FIELD-SYMBOL(<LS_LFA1_B>) WITH KEY LIFNR = <LS_ZB1_BATCH_T_B>-B1_VENDOR .
        IF SY-SUBRC = 0.

          WA_FINAL-NAME1 = <LS_LFA1_B>-NAME1 .

        ENDIF.
*        READ TABLE IT_EKKO ASSIGNING FIELD-SYMBOL(<LS_EKKO>) WITH KEY EBELN = WA_MSEG-EBELN .
*        IF SY-SUBRC = 0.
        WA_FINAL-EKGRP = WA_T024_B-EKGRP.
*        ENDIF.

*        READ TABLE IT_MBEW INTO WA_MBEW WITH KEY BWTAR = WA_MSEG-CHARG .
*        IF SY-SUBRC = 0.
*
*        ENDIF.

        READ TABLE IT_FINAL ASSIGNING FIELD-SYMBOL(<LS_FINAL_B>) WITH KEY CHARG = LV_BATCH.
        IF SY-SUBRC = 0.
          WA_FINAL-QUANTITY = <LS_FINAL_B>-QUANTITY + 1.
          WA_FINAL-VALUE = WA_FINAL-QUANTITY * <LS_MBEW_B>-VERPR  .
          MODIFY TABLE IT_FINAL FROM WA_FINAL TRANSPORTING QUANTITY VALUE .
        ELSE .
          WA_FINAL-QUANTITY = 1.
          WA_FINAL-VALUE = WA_FINAL-QUANTITY * <LS_MBEW_B>-VERPR  .
          APPEND WA_FINAL TO IT_FINAL .
          CLEAR : WA_FINAL .
        ENDIF.
      ENDLOOP.


    ENDIF.

  ENDIF.

  CLEAR : LV_BATCH  .
  IF GRID IS BOUND.
*    DATA LS_STABLE TYPE LVC_S_STBL.

    CALL METHOD GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = LS_STABLE   " With Stable Rows/Columns
*       i_soft_refresh =     " Without Sort, Filter, etc.
      EXCEPTIONS
        FINISHED  = 1
        OTHERS    = 2.
    IF SY-SUBRC <> 0.
    ENDIF.
  ENDIF.

  IF CONTAINER IS INITIAL.
    PERFORM SETUP_ALV.
  ENDIF.
  PERFORM FILL_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SETUP_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SETUP_ALV .

  CREATE OBJECT CONTAINER
    EXPORTING
      CONTAINER_NAME = 'CONTAINER'.
  CREATE OBJECT GRID
    EXPORTING
      I_PARENT = CONTAINER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FILL_GRID .

  REFRESH LT_FIELDCAT.
  DATA: WA_FC  TYPE  LVC_S_FCAT.

  WA_FC-COL_POS   = '1'.
  WA_FC-FIELDNAME = 'MATNR'.
  WA_FC-TABNAME   = 'IT_FINAL'.
  WA_FC-SCRTEXT_L = 'Material Code'.
  APPEND WA_FC TO LT_FIELDCAT.
  CLEAR WA_FC.

  WA_FC-COL_POS   = '2'.
  WA_FC-FIELDNAME = 'LIFNR'.
  WA_FC-TABNAME   = 'IT_FINAL'.
  WA_FC-SCRTEXT_L = 'Vendor'.
  APPEND WA_FC TO LT_FIELDCAT.
  CLEAR WA_FC.


  WA_FC-COL_POS   = '3'.
  WA_FC-FIELDNAME = 'NAME1'.
  WA_FC-TABNAME   = 'IT_FINAL'.
  WA_FC-SCRTEXT_L = 'Vendor Name'.
  APPEND WA_FC TO LT_FIELDCAT.
  CLEAR WA_FC.


  WA_FC-COL_POS   = '4'.
  WA_FC-FIELDNAME = 'WERKS'.
  WA_FC-TABNAME   = 'IT_FINAL'.
  WA_FC-SCRTEXT_L = 'Plant'.
  APPEND WA_FC TO LT_FIELDCAT.
  CLEAR WA_FC.

  WA_FC-COL_POS   = '5'.
  WA_FC-FIELDNAME = 'QUANTITY'.
  WA_FC-TABNAME   = 'IT_FINAL'.
  WA_FC-SCRTEXT_L = 'Quantity'.
  APPEND WA_FC TO LT_FIELDCAT.
  CLEAR WA_FC.


  WA_FC-COL_POS   = '6'.
  WA_FC-FIELDNAME = 'VERPR'.
  WA_FC-TABNAME   = 'IT_FINAL'.
  WA_FC-SCRTEXT_L = 'Price'.
  APPEND WA_FC TO LT_FIELDCAT.
  CLEAR WA_FC.

  WA_FC-COL_POS   = '7'.
  WA_FC-FIELDNAME = 'VALUE'.
  WA_FC-TABNAME   = 'IT_FINAL'.
  WA_FC-SCRTEXT_L = 'Value'.
  APPEND WA_FC TO LT_FIELDCAT.
  CLEAR WA_FC.

  WA_FC-COL_POS   = '8'.
  WA_FC-FIELDNAME = 'TAX_PER'.
  WA_FC-TABNAME   = 'IT_FINAL'.
  WA_FC-SCRTEXT_L = 'Tax Value'.
  APPEND WA_FC TO LT_FIELDCAT.
  CLEAR WA_FC.

  WA_FC-COL_POS   = '9'.
  WA_FC-FIELDNAME = 'TAX_VAL'.
  WA_FC-TABNAME   = 'IT_FINAL'.
  WA_FC-SCRTEXT_L = 'Total Value'.
  APPEND WA_FC TO LT_FIELDCAT.
  CLEAR WA_FC.


  PERFORM EXCLUDE_TB_FUNCTIONS CHANGING LT_EXCLUDE.

  CALL METHOD GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IT_TOOLBAR_EXCLUDING          = LT_EXCLUDE
      IS_LAYOUT                     = LW_LAYO
    CHANGING
      IT_OUTTAB                     = IT_FINAL[] "it_item[]
      IT_FIELDCATALOG               = LT_FIELDCAT
*     IT_SORT                       = IT_SORT[]
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

  IF SY-SUBRC <> 0.
*   IMPLEMENT SUITABLE ERROR HANDLING HERE
  ENDIF.

  IF GRID IS BOUND.
    LS_STABLE-ROW = 'X'.
    LS_STABLE-COL = 'X'.
    CALL METHOD GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = LS_STABLE   " With Stable Rows/Columns
*       i_soft_refresh =     " Without Sort, Filter, etc.
      EXCEPTIONS
        FINISHED  = 1
        OTHERS    = 2.
    IF SY-SUBRC <> 0.
    ENDIF .
  ENDIF .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_EXCLUDE
*&---------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS  CHANGING P_LT_EXCLUDE.

  DATA LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_FIND_MORE.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_SUM.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_AVERAGE.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_DETAIL.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_REFRESH.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_RPO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_RPO .
  DATA : LV_POITEM TYPE EBELP.
  DATA:
    HEADER    LIKE BAPIMEPOHEADER,
    HEADERX   LIKE BAPIMEPOHEADERX,
    ITEM      TYPE TABLE OF BAPIMEPOITEM  WITH HEADER LINE,
*  POSCHEDULE  TYPE TABLE OF BAPIMEPOSCHEDULE WITH HEADER LINE,
*  POSCHEDULEX TYPE TABLE OF BAPIMEPOSCHEDULX WITH HEADER LINE,
    ITEMX     TYPE TABLE OF BAPIMEPOITEMX  WITH HEADER LINE,
    IT_RETURN TYPE TABLE OF BAPIRET2.

  DATA : LV_TEBELN(40) TYPE C.
  DATA : LV_TEX(20) TYPE C.


  DATA : WA_HEADER TYPE THEAD.
*  BREAK BREDDY.
  READ TABLE IT_FINAL ASSIGNING FIELD-SYMBOL(<LS_RETPO>) INDEX 1 .

  SELECT SINGLE
   LFA1~ADRNR FROM LFA1 INTO @DATA(P_ADRNR)
              WHERE LIFNR = @<LS_RETPO>-LIFNR .

  SELECT SINGLE
    ADRC~ADDRNUMBER ,
    ADRC~CITY1 FROM ADRC INTO @DATA(WA_CITY)
               WHERE ADDRNUMBER = @P_ADRNR .

  SELECT
    MSEG~MATNR,
    MSEG~EBELN FROM MSEG INTO TABLE @DATA(IT_RMSEG)
               FOR ALL ENTRIES IN @IT_FINAL
               WHERE MATNR = @IT_FINAL-MATNR
               AND   CHARG = @IT_FINAL-CHARG
              AND    BWART IN ('101' , '107') .

  SELECT
    EKKO~EBELN,
    EKKO~EKGRP FROM EKKO INTO TABLE @DATA(IT_REKKO)
               FOR ALL ENTRIES IN @IT_RMSEG
               WHERE EBELN =  @IT_RMSEG-EBELN .

  SELECT SINGLE
       LFA1~REGIO FROM LFA1 INTO  @DATA(LS_LFA1)
         WHERE LIFNR = @<LS_RETPO>-LIFNR.



  SELECT
  A792~WKREG ,
  A792~REGIO ,
  A792~STEUC ,
  A792~KNUMH ,
  MARC~MATNR ,
  T001W~WERKS
   FROM MARC AS MARC
   INNER JOIN A792 AS A792 ON MARC~STEUC  = A792~STEUC
   INNER JOIN T001W AS T001W ON MARC~WERKS = T001W~WERKS
   INTO TABLE @DATA(IT_HSN)
   FOR ALL ENTRIES IN @IT_FINAL
   WHERE MARC~MATNR = @IT_FINAL-MATNR
   AND A792~REGIO   = @LS_LFA1
   AND T001W~WERKS = @IT_FINAL-WERKS.

  IF IT_HSN IS NOT INITIAL .
    SELECT
      KONP~KNUMH ,
      KONP~MWSK1 FROM KONP INTO TABLE @DATA(IT_KONP)
                 FOR ALL ENTRIES IN @IT_HSN
                 WHERE KNUMH = @IT_HSN-KNUMH .
  ENDIF .

  IF IT_FINAL IS NOT INITIAL.
    SELECT
      MARA~MEINS FROM MARA INTO TABLE @DATA(IT_MARA)
                 FOR ALL ENTRIES IN @IT_FINAL
                 WHERE MATNR = @IT_FINAL-MATNR.

  ENDIF.

  DATA : LV_DOC TYPE ESART .

  IF WA_CITY-CITY1 = 'Chennai'.

    LV_DOC = 'ZLOP' .

  ELSE .

    LV_DOC = 'ZOSP'.

  ENDIF.




  HEADER-COMP_CODE  = '1000'.
  HEADER-CREAT_DATE = SY-DATUM .
  HEADER-VENDOR     = <LS_RETPO>-LIFNR .
  HEADER-DOC_TYPE   = LV_DOC .
  HEADER-LANGU      = SY-LANGU .



  HEADER-PURCH_ORG = '1000'.
  READ TABLE IT_REKKO ASSIGNING FIELD-SYMBOL(<LS_REKKO>) INDEX 1 .
  IF SY-SUBRC = 0 .
    HEADER-PUR_GROUP = <LS_REKKO>-EKGRP .
  ENDIF .
  HEADERX-COMP_CODE = 'X'.
  HEADERX-CREAT_DATE = 'X'.
  HEADERX-VENDOR = 'X'.
  HEADERX-DOC_TYPE = 'X' .
  HEADERX-LANGU = 'X' .
  HEADERX-PURCH_ORG = 'X' .
  HEADERX-PUR_GROUP = 'X' .

  REFRESH ITEM.
  REFRESH ITEMX.
  BREAK BREDDY .
  LOOP AT IT_FINAL ASSIGNING FIELD-SYMBOL(<LS_ITEM>).

    LV_POITEM = LV_POITEM + 10.

    ITEM-PO_ITEM = ITEMX-PO_ITEM = LV_POITEM .
    READ TABLE IT_HSN ASSIGNING FIELD-SYMBOL(<LS_HSN1>) WITH KEY MATNR = <LS_ITEM>-MATNR .
    IF SY-SUBRC = 0.
      READ TABLE IT_KONP ASSIGNING FIELD-SYMBOL(<LS_KONP1>) WITH KEY KNUMH = <LS_HSN1>-KNUMH .
      IF SY-SUBRC = 0.

        ITEM-TAX_CODE = <LS_KONP1>-MWSK1.
*            WA_ITEMX-TAX_CODE = 'X'.

      ENDIF.
    ENDIF.

*    ITEM-TAX_CODE = ' '.
*    ITEMX-TAX_CODE = 'X'.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = <LS_ITEM>-MATNR
      IMPORTING
        OUTPUT = <LS_ITEM>-MATNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = ITEM-PO_ITEM
      IMPORTING
        OUTPUT = ITEM-PO_ITEM.

    ITEM-MATERIAL_LONG  = <LS_ITEM>-MATNR.
    ITEM-PLANT     = <LS_ITEM>-WERKS.
    ITEM-QUANTITY  = <LS_ITEM>-QUANTITY.
    ITEM-NET_PRICE = <LS_ITEM>-VERPR.
    ITEM-STGE_LOC  = 'FG01'.
    ITEM-RET_ITEM  = 'X'.

*    ITEM-IR_IND        = 'X'.
*    ITEM-GR_BASEDIV         = 'X'.
    READ TABLE IT_MARA ASSIGNING FIELD-SYMBOL(<LS_MARA>) WITH KEY <LS_ITEM>-MATNR .
    IF SY-SUBRC = 0.
      ITEM-PO_UNIT  = <LS_MARA>-MEINS .
    ENDIF.

    ITEMX-MATERIAL_LONG    = 'X'.
    ITEMX-PLANT       = 'X'.
    ITEMX-QUANTITY    = 'X'.
    ITEMX-PO_UNIT     = 'X'.
    ITEMX-NET_PRICE   = 'X'.
    ITEMX-STGE_LOC    = 'X'.
    ITEMX-RET_ITEM    = 'X'.
    ITEMX-TAX_CODE    = 'X'.
    APPEND ITEM.
    APPEND ITEMX .
    CLEAR : ITEMX , ITEM.
  ENDLOOP.
  IF IT_KONP IS INITIAL .

    MESSAGE 'There is No Tax Code' TYPE 'E'  .



  ELSE .
*** Return PO Creation
    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        POHEADER         = HEADER
        POHEADERX        = HEADERX
*       NO_PRICE_FROM_PO = C_X
      IMPORTING
        EXPPURCHASEORDER = LV_EBELN
      TABLES
        RETURN           = IT_RETURN[]
        POITEM           = ITEM
        POITEMX          = ITEMX.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

*    LV_TEX = 'Created Successfully' .
*    CONCATENATE LV_EBELN LV_TEX  INTO LV_TEBELN SEPARATED BY SPACE.
*    IF LV_EBELN IS NOT INITIAL .
*      MESSAGE LV_TEBELN TYPE  'S' .
*    ENDIF.

  ENDIF.


  PERFORM GOODS_RETURN .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GOODS_RETURN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GOODS_RETURN .
  DATA : LV_TEX1(30) TYPE C.
  DATA : LV_MBLNR(40) TYPE C.
*** BAPI Structure Declaration
  DATA:
    LS_GMVT_HEADER  TYPE BAPI2017_GM_HEAD_01,
    LS_GMVT_ITEM    TYPE BAPI2017_GM_ITEM_CREATE,
    LS_GMVT_HEADRET TYPE BAPI2017_GM_HEAD_RET,
    LT_BAPIRET      TYPE STANDARD TABLE OF BAPIRET2,
    LT_GMVT_ITEM    TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
    LS_STATUS       TYPE ZINW_T_STATUS.
  FIELD-SYMBOLS :
    <LS_BAPIRET> TYPE BAPIRET2.
*  BREAK BREDDY .
  SELECT * FROM EKPO INTO TABLE @DATA(LT_EKPO) WHERE EBELN = @LV_EBELN.

*** FILL THE BAPI HEADER STRUCTURE DETAILS
  LS_GMVT_HEADER-PSTNG_DATE = SY-DATUM.
  LS_GMVT_HEADER-DOC_DATE   = SY-DATUM.
  LS_GMVT_HEADER-PR_UNAME   = SY-UNAME.

*** Looping the PO details.
  LOOP AT LT_EKPO ASSIGNING FIELD-SYMBOL(<LS_GRN>).
*** FILL THE BAPI ITEM STRUCTURE DETAILS
    LS_GMVT_ITEM-MATERIAL  = <LS_GRN>-MATNR.
    LS_GMVT_ITEM-MOVE_TYPE = '101'.
    LS_GMVT_ITEM-PO_NUMBER =  <LS_GRN>-EBELN.
    LS_GMVT_ITEM-PO_ITEM   = <LS_GRN>-EBELP.
    LS_GMVT_ITEM-ENTRY_QNT = <LS_GRN>-MENGE.
    LS_GMVT_ITEM-ENTRY_UOM = <LS_GRN>-MEINS.
    LS_GMVT_ITEM-PROD_DATE = SY-DATUM.
    LS_GMVT_ITEM-MVT_IND   = 'B'.
    LS_GMVT_ITEM-MOVE_REAS = '02'.
    READ TABLE IT_FINAL ASSIGNING FIELD-SYMBOL(<LS_ITEM_T>) WITH KEY  MATNR = <LS_GRN>-MATNR .

    IF SY-SUBRC = 0.
      LS_GMVT_ITEM-BATCH = <LS_ITEM_T>-CHARG.
      LS_GMVT_ITEM-STGE_LOC = 'FG01'.
      LS_GMVT_ITEM-PLANT = <LS_ITEM_T>-WERKS.
    ENDIF.
    APPEND LS_GMVT_ITEM TO LT_GMVT_ITEM.
    CLEAR LS_GMVT_ITEM.

  ENDLOOP .


*** Call the BAPI FM for GR posting
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = LS_GMVT_HEADER
      GOODSMVT_CODE    = '01'
    IMPORTING
      GOODSMVT_HEADRET = LS_GMVT_HEADRET
    TABLES
      GOODSMVT_ITEM    = LT_GMVT_ITEM
      RETURN           = LT_BAPIRET.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.

  GV_MBLNR_N = LS_GMVT_HEADRET-MAT_DOC.
*  LV_TEX1 = 'Created Successfully' .
*
**  CONCATENATE GV_MBLNR_N LV_TEX1 INTO LV_MBLNR SEPARATED BY SPACE.
*  IF GV_MBLNR_N IS NOT INITIAL .
*    MESSAGE LV_TEX1 TYPE  'S' .
*  ENDIF.
  PERFORM DEBIT_NOTE .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEBIT_NOTE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DEBIT_NOTE .
  DATA :
         LV_TEX2(30)       TYPE C.
  DATA :
    HEADERDATA              TYPE BAPI_INCINV_CREATE_HEADER,
    FISCALYEAR              TYPE BAPI_INCINV_FLD-FISC_YEAR,
    LS_ITEMDATA             TYPE BAPI_INCINV_CREATE_ITEM,
    LS_TAXDATA              TYPE BAPI_INCINV_CREATE_TAX,
    LS_VENDORITEMSPLITDATA  TYPE BAPI_INCINV_CREATE_VENDORSPLIT,
    ITEMDATA                TYPE STANDARD TABLE OF BAPI_INCINV_CREATE_ITEM,
    ITEMVENDORITEMSPLITDATA TYPE STANDARD TABLE OF BAPI_INCINV_CREATE_VENDORSPLIT,
    ITEMTAXDATA             TYPE STANDARD TABLE OF BAPI_INCINV_CREATE_TAX,
    RETURN                  TYPE STANDARD TABLE OF BAPIRET2,
    LV_TAX_AMOUNT           TYPE NETPR,
    LV_TAX_AMOUNT1          TYPE NETPR,
    LS_STATUS               TYPE ZINW_T_STATUS.
  DATA : INVOICEDOCNUMBER    TYPE BAPI_INCINV_FLD-INV_DOC_NO,
         INVOICEDOCNUMBER_DN TYPE BAPI_INCINV_FLD-INV_DOC_NO.
  DATA : LV_EBELP TYPE EBELP .
  BREAK BREDDY .
*** Header Data
  IF LV_EBELN IS NOT INITIAL.
    CLEAR   : HEADERDATA.
    REFRESH : ITEMDATA.
    SELECT EKKO~EBELN,
           EKKO~BUKRS,
           EKKO~WAERS,
           EKKO~LIFNR,
           EKKO~WKURS,
           EKPO~EBELP,
           EKPO~MATNR,
           EKPO~MWSKZ,
           EKPO~MENGE,
           EKPO~MEINS,
           EKPO~NETWR,
           EKPO~BRTWR,
           MATDOC~MBLNR,
           MATDOC~MJAHR,
           MATDOC~ZEILE,
           MATDOC~GSBER,
           A003~KNUMH,
           A003~KSCHL,
           KONP~KBETR
           INTO TABLE @DATA(LT_DEBIT)
           FROM EKKO AS EKKO
           INNER JOIN EKPO AS EKPO ON EKPO~EBELN = EKKO~EBELN
           INNER JOIN MATDOC AS MATDOC ON MATDOC~EBELN =  EKPO~EBELN AND MATDOC~EBELP = EKPO~EBELP
           LEFT  OUTER JOIN A003 AS A003 ON A003~MWSKZ =  EKPO~MWSKZ AND A003~KSCHL IN ( 'JIIG' , 'JICG' , 'JISG' )
           LEFT  OUTER JOIN KONP AS KONP ON KONP~KNUMH =  A003~KNUMH
           WHERE EKKO~EBELN = @LV_EBELN.

    READ TABLE LT_DEBIT ASSIGNING FIELD-SYMBOL(<LS_HED>) INDEX 1 .
    IF SY-SUBRC = 0.
      HEADERDATA-DOC_TYPE = 'RE' .
      HEADERDATA-DOC_DATE     = SY-DATUM.
      HEADERDATA-PSTNG_DATE   = SY-DATUM.
      HEADERDATA-BLINE_DATE   = SY-DATUM.
*      HEADERDATA-CALC_TAX_IND = 'X'.
      HEADERDATA-REF_DOC_NO   = LV_EBELN .              ""GS_HDR-INWD_DOC.
      HEADERDATA-DIFF_INV   = <LS_HED>-LIFNR .
      HEADERDATA-CURRENCY   = <LS_HED>-WAERS .
      HEADERDATA-CURRENCY_ISO   = <LS_HED>-WAERS .
      HEADERDATA-EXCH_RATE   = <LS_HED>-WKURS .
      HEADERDATA-GROSS_AMOUNT   = <LS_HED>-BRTWR .
*      HEADERDATA-CALC_TAX_IND   = 'X' .
      HEADERDATA-SECCO = HEADERDATA-BUSINESS_PLACE  = HEADERDATA-BUS_AREA = '1000'.

*** Item Data
      BREAK BREDDY .
      DATA(LT_DEBIT1) = LT_DEBIT[].
      SORT LT_DEBIT BY EBELN.
      DELETE ADJACENT DUPLICATES FROM LT_DEBIT COMPARING EBELN .
      LOOP AT LT_DEBIT ASSIGNING FIELD-SYMBOL(<LS_DEBIT>).
        LV_EBELP = <LS_DEBIT>-EBELP + LV_EBELP .
        LS_ITEMDATA-INVOICE_DOC_ITEM  =  SY-TABIX.
        LS_ITEMDATA-PO_NUMBER         = <LS_DEBIT>-EBELN.
        LS_ITEMDATA-PO_ITEM           =  <LS_DEBIT>-EBELP.
        LS_ITEMDATA-REF_DOC           = <LS_DEBIT>-MBLNR.
        LS_ITEMDATA-REF_DOC_YEAR      = <LS_DEBIT>-MJAHR.
        LS_ITEMDATA-REF_DOC_IT        = <LS_DEBIT>-ZEILE.

        LS_ITEMDATA-TAX_CODE          = <LS_DEBIT>-MWSKZ.
        LS_ITEMDATA-ITEM_AMOUNT       = <LS_DEBIT>-BRTWR.
        LS_ITEMDATA-QUANTITY          = <LS_DEBIT>-MENGE.
        LS_ITEMDATA-PO_PR_QNT          = <LS_DEBIT>-MENGE.
        LS_ITEMDATA-PO_UNIT           = <LS_DEBIT>-MEINS.
        LS_ITEMDATA-PO_UNIT_ISO           = <LS_DEBIT>-MEINS.
        LS_ITEMDATA-PO_PR_UOM            = <LS_DEBIT>-MEINS.
        LS_ITEMDATA-PO_PR_UOM_ISO           = <LS_DEBIT>-MEINS.
        HEADERDATA-COMP_CODE          = <LS_DEBIT>-BUKRS.
        HEADERDATA-CURRENCY           = <LS_DEBIT>-WAERS.
        BREAK BREDDY .
        LOOP AT LT_DEBIT1 ASSIGNING FIELD-SYMBOL(<LS_DEBIT1>) WHERE EBELN = <LS_DEBIT>-EBELN.

          IF <LS_DEBIT1>-KSCHL IS NOT INITIAL .
*** Tax Calculation
            IF <LS_DEBIT1>-KSCHL = 'JIIG'.
              LV_TAX_AMOUNT1 = ( LS_ITEMDATA-ITEM_AMOUNT *  <LS_DEBIT1>-KBETR / 10  ) / 100.
            ELSEIF <LS_DEBIT1>-KSCHL = 'JISG' OR <LS_DEBIT1>-KSCHL = 'JICG'.
              LV_TAX_AMOUNT1 =  ( LS_ITEMDATA-ITEM_AMOUNT *  <LS_DEBIT1>-KBETR / 10  ) / 100.
            ENDIF.
            LS_TAXDATA-TAX_CODE = <LS_DEBIT1>-MWSKZ .
            LS_TAXDATA-TAX_AMOUNT = LV_TAX_AMOUNT1.
            APPEND LS_TAXDATA TO ITEMTAXDATA .
            CLEAR : LS_TAXDATA .
          ENDIF .
          ADD  LV_TAX_AMOUNT1 TO HEADERDATA-GROSS_AMOUNT.
        ENDLOOP.


        APPEND LS_ITEMDATA TO ITEMDATA.
        CLEAR : LS_ITEMDATA.

        LS_VENDORITEMSPLITDATA-SPLIT_KEY = '000001'.
        LS_VENDORITEMSPLITDATA-SPLIT_AMOUNT = <LS_DEBIT>-BRTWR.
        APPEND LS_VENDORITEMSPLITDATA TO ITEMVENDORITEMSPLITDATA .
        CLEAR :LS_VENDORITEMSPLITDATA .
        READ TABLE IT_FINAL ASSIGNING FIELD-SYMBOL(<LS_TAX>)
         WITH KEY  MATNR = <LS_DEBIT>-MATNR .
        IF SY-SUBRC = 0.
          IF <LS_DEBIT1>-KSCHL = 'JISG' OR <LS_DEBIT1>-KSCHL = 'JICG'.
            ADD  LV_TAX_AMOUNT1 TO LV_TAX_AMOUNT1.
          ENDIF .
          <LS_TAX>-TAX_PER = LV_TAX_AMOUNT1 .
          <LS_TAX>-TAX_VAL = HEADERDATA-GROSS_AMOUNT .
          MODIFY IT_FINAL FROM <LS_TAX>  INDEX SY-TABIX TRANSPORTING TAX_PER TAX_VAL .
        ENDIF.


      ENDLOOP .

*  CLEAR : LV_BATCH .
      IF GRID IS BOUND.
*    DATA LS_STABLE TYPE LVC_S_STBL.

        CALL METHOD GRID->REFRESH_TABLE_DISPLAY
          EXPORTING
            IS_STABLE = LS_STABLE   " With Stable Rows/Columns
*           i_soft_refresh =     " Without Sort, Filter, etc.
          EXCEPTIONS
            FINISHED  = 1
            OTHERS    = 2.
        IF SY-SUBRC <> 0.
        ENDIF.
      ENDIF.

*** Create Debit Note
      CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
        EXPORTING
          HEADERDATA          = HEADERDATA                  " Header Data in Incoming Invoice (Create)
        IMPORTING
          INVOICEDOCNUMBER    = INVOICEDOCNUMBER_DN            " Document Number of an Invoice Document
          FISCALYEAR          = FISCALYEAR                  " Fiscal Year
        TABLES
          ITEMDATA            = ITEMDATA                    " Item Data in Incoming Invoice
          RETURN              = RETURN                    " Return Messages
          VENDORITEMSPLITDATA = ITEMVENDORITEMSPLITDATA
          TAXDATA             = ITEMTAXDATA.
      READ TABLE RETURN ASSIGNING FIELD-SYMBOL(<LS_RETURN>) WITH KEY TYPE = 'E'.
      IF SY-SUBRC <> 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.
        LV_DEBIT_NOTE = INVOICEDOCNUMBER_DN.


      ENDIF.
      LV_TEX2 = 'Created Successfully' .

*  CONCATENATE GV_MBLNR_N LV_TEX1 INTO LV_MBLNR SEPARATED BY SPACE.
      IF INVOICEDOCNUMBER_DN IS NOT INITIAL .
        MESSAGE LV_TEX2 TYPE  'S' .
      ENDIF.
    ENDIF .
  ENDIF .

ENDFORM.
