*&---------------------------------------------------------------------*
*& Include          ZMM_GRPO_STORES_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

**************************Category*****************
  SELECT     CLINT
             KLART
             CLASS
             VONDT
             BISDT
             WWSKZ FROM KLAH INTO TABLE IT_KLAH
             WHERE WWSKZ = '0'
             AND   KLART = '026' .
*            AND CLASS = CATEGORY.
*  ENDIF.
  IF IT_KLAH IS NOT INITIAL.
    SELECT OBJEK
           MAFID
           KLART
           CLINT
           ADZHL
           DATUB FROM KSSK INTO TABLE IT_KSSK
           FOR ALL ENTRIES IN IT_KLAH
            WHERE CLINT = IT_KLAH-CLINT.
  ENDIF.

  LOOP AT IT_KSSK INTO WA_KSSK .
    WA_KSSK1-OBJEK1 = WA_KSSK-OBJEK .
    SHIFT WA_KSSK-OBJEK LEFT DELETING LEADING '0'.
    WA_KSSK1-OBJEK = WA_KSSK-OBJEK .
    APPEND WA_KSSK1 TO IT_KSSK1 .
    CLEAR WA_KSSK1 .
  ENDLOOP.

  IF IT_KSSK1 IS NOT INITIAL .
    SELECT CLINT
           KLART
           CLASS
           VONDT
           BISDT
           WWSKZ FROM KLAH INTO TABLE IT_KLAH1
           FOR ALL ENTRIES IN IT_KSSK1
           WHERE CLINT = IT_KSSK1-OBJEK
           AND WWSKZ = '1'.
  ENDIF.
*  IT_KLAH1[] = IT_KLAH[] .
  IF IT_KLAH1 IS NOT INITIAL .
    SELECT MATNR
           MATKL FROM MARA INTO TABLE IT_MARA
           FOR ALL ENTRIES IN IT_KLAH1
           WHERE MATKL = IT_KLAH1-CLASS.

  ENDIF.

  IF IT_MARA IS NOT  INITIAL .
******************     COMMENTED ON (11-2-20)        **********************************
**********    SELECT ZINW_T_ITEM~QR_CODE  ,     " commented on (4-1-20)
**********           ZINW_T_ITEM~EBELN ,
**********           ZINW_T_ITEM~EBELP ,
**********           ZINW_T_ITEM~MATNR ,
**********           ZINW_T_ITEM~WERKS ,
**********           ZINW_T_ITEM~MENGE_P ,
**********           ZINW_T_ITEM~NETWR_P,      " ADDED (11-2-20)
**********           ZINW_T_ITEM~NETPR_GP,      " ADDED (11-2-20)
**********           ZINW_T_HDR~INWD_DOC  ,
**********           ZINW_T_HDR~MBLNR  ,
**********           ZINW_T_HDR~LIFNR     ,
**********           ZINW_T_HDR~BILL_DATE ,
**********           ZINW_T_HDR~PUR_TOTAL ,
**********           ZINW_T_HDR~PUR_TAX ,
**********           ZINW_T_HDR~NET_AMT ,
**********           ZINW_T_HDR~ERDATE    ,
**********           ZINW_T_HDR~ACT_NO_BUD ,
***********           ZINW_T_STATUS~QR_CODE,
**********           LFA1~NAME1 ,
**********           MKPF~BLDAT
**********           FROM ZINW_T_ITEM AS ZINW_T_ITEM
***********           LEFT OUTER JOIN ZINW_T_STATUS AS ZINW_T_STATUS ON ZINW_T_status~QR_CODE =  ZINW_T_ITEM~QR_CODE
**********           LEFT OUTER JOIN ZINW_T_HDR AS ZINW_T_HDR ON ZINW_T_HDR~QR_CODE =  ZINW_T_ITEM~QR_CODE   " commenetd on (4-1-20)
**********           LEFT OUTER JOIN LFA1 AS LFA1 ON LFA1~LIFNR = ZINW_T_HDR~LIFNR
**********           LEFT OUTER JOIN MKPF AS MKPF ON MKPF~MBLNR  = ZINW_T_HDR~MBLNR
**********
**********           INTO TABLE @DATA(IT_ZINW)
**********           FOR ALL ENTRIES IN @IT_MARA
**********           WHERE  ZINW_T_ITEM~MATNR = @IT_MARA-MATNR
**********           AND  ZINW_T_ITEM~WERKS IN @S_PLANT
**********           AND  ZINW_T_HDR~ERDATE  IN @S_DATE
**********           AND  ZINW_T_HDR~STATUS GE '04' .
*           AND ZINW_T_HDR~MBLNR = '5000001934'.

*****************    added on (4-1-20)    *****************
 BREAK CLIKHITHA.
    SELECT "ZINW_T_STATUS~QR_CODE,
          ZINW_T_STATUS~QR_CODE,          " added on (4-1-20)
           ZINW_T_STATUS~STATUS_VALUE,      " added on (4-1-20)
           ZINW_T_STATUS~CREATED_DATE,      " added on (4-1-20)
*           ZINW_T_ITEM~QR_CODE  ,     " commented on (4-1-20)
           ZINW_T_ITEM~EBELN ,
           ZINW_T_ITEM~EBELP ,
           ZINW_T_ITEM~MATNR ,
           ZINW_T_ITEM~WERKS ,
           ZINW_T_ITEM~MENGE_P ,
           ZINW_T_ITEM~NETWR_P,      " ADDED (11-2-20)
           ZINW_T_ITEM~NETPR_GP,      " ADDED (11-2-20)
*           ZINW_T_STATUS~QR_CODE,          " added on (4-1-20)
*           ZINW_T_STATUS~STATUS_VALUE,      " added on (4-1-20)
*           ZINW_T_STATUS~CREATED_DATE,      " added on (4-1-20)
           ZINW_T_HDR~INWD_DOC  ,
           ZINW_T_HDR~MBLNR  ,
           ZINW_T_HDR~LIFNR     ,
           ZINW_T_HDR~BILL_DATE ,
           ZINW_T_HDR~PUR_TOTAL ,
           ZINW_T_HDR~PUR_TAX ,
           ZINW_T_HDR~NET_AMT ,
           ZINW_T_HDR~ERDATE    ,
           ZINW_T_HDR~ACT_NO_BUD ,
*           ZINW_T_STATUS~QR_CODE,
           LFA1~NAME1 ,
           MKPF~BLDAT
          FROM ZINW_T_STATUS AS ZINW_T_STATUS
           LEFT OUTER JOIN ZINW_T_ITEM AS ZINW_T_ITEM ON ZINW_T_ITEM~QR_CODE =  ZINW_T_STATUS~QR_CODE
           LEFT OUTER JOIN ZINW_T_HDR AS ZINW_T_HDR ON ZINW_T_HDR~QR_CODE =  ZINW_T_status~QR_CODE


*
*           FROM ZINW_T_ITEM AS ZINW_T_ITEM
*           LEFT OUTER JOIN ZINW_T_STATUS AS ZINW_T_STATUS ON ZINW_T_status~QR_CODE =  ZINW_T_ITEM~QR_CODE
*           LEFT OUTER JOIN ZINW_T_HDR AS ZINW_T_HDR ON ZINW_T_HDR~QR_CODE =  ZINW_T_status~QR_CODE   " commenetd on (4-1-20)
           LEFT OUTER JOIN LFA1 AS LFA1 ON LFA1~LIFNR = ZINW_T_HDR~LIFNR
           LEFT OUTER JOIN MKPF AS MKPF ON MKPF~MBLNR  = ZINW_T_HDR~MBLNR

           INTO TABLE @DATA(IT_ZINW)
           FOR ALL ENTRIES IN @IT_MARA
           WHERE  ZINW_T_STATUS~STATUS_VALUE = 'QR04'
           AND ZINW_T_ITEM~MATNR = @IT_MARA-MATNR
           AND  ZINW_T_ITEM~WERKS IN @S_PLANT
           AND  ZINW_T_STATUS~CREATED_DATE  IN @S_DATE.
*           AND  ZINW_T_STATUS~STATUS_VALUE GE 'QR04' .
*************************           END (11-2-20)     ****************************
  ENDIF.
  SORT IT_ZINW  ASCENDING BY  MBLNR .
  BREAK BREDDY .
*  LOOP AT IT_KLAH ASSIGNING FIELD-SYMBOL(<WA_KLAH>).
*    LOOP AT IT_KSSK ASSIGNING FIELD-SYMBOL(<WA_KSSK>) WHERE CLINT = <WA_KLAH>-CLINT .
*      SHIFT <WA_KSSK>-OBJEK LEFT DELETING LEADING '0'.
*      LOOP AT IT_KLAH1 ASSIGNING FIELD-SYMBOL(<WA_KLAH1>) WHERE CLINT = <WA_KSSK>-OBJEK .
*        LOOP AT IT_MARA ASSIGNING FIELD-SYMBOL(<WA_MARA>) WHERE MATKL = <WA_KLAH1>-CLASS .
*          LOOP AT IT_ZINW ASSIGNING FIELD-SYMBOL(<WA_ZINW>) WHERE matnr = <WA_MARA>-MATNR .
*
**    READ TABLE IT_ZINW ASSIGNING FIELD-SYMBOL(<WA_ZINW>) WITH KEY MATNR = WA_MARA-MATNR .
**    IF  SY-SUBRC = 0.
*
*
*            WA_FINAL-GRPO_V   =  <WA_ZINW>-PUR_TOTAL .
*            WA_FINAL-GRPO_WT  =  <WA_ZINW>-NET_AMT .
*            WA_FINAL-BUNDLE   =  <WA_ZINW>-ACT_NO_BUD .
*            WA_FINAL-QTY      =  <WA_ZINW>-MENGE .
***************************Screen2*************************
*            WA_FINAL1-GRPO_V  =  <WA_ZINW>-PUR_TOTAL .
*            WA_FINAL1-GRPO_WT =  <WA_ZINW>-NET_AMT .
*            WA_FINAL1-BUNDLE  =  <WA_ZINW>-ACT_NO_BUD .
*            WA_FINAL1-QTY     =  <WA_ZINW>-MENGE .
*            WA_FINAL1-LIFNR   =  <WA_ZINW>-LIFNR .
*            WA_FINAL1-GRPO    =  <WA_ZINW>-MBLNR .
*            WA_FINAL1-NAME1   =  <WA_ZINW>-NAME1 .
*            WA_FINAL1-WERKS   =  <WA_ZINW>-WERKS .
*            CLEAR : WA_MARA , WA_KLAH1 , WA_KLAH , WA_KSSK1 , WA_KSSK .
*            READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR   = <WA_ZINW>-MATNR .
*            READ TABLE IT_KLAH1 INTO WA_KLAH1 WITH KEY CLASS = WA_MARA-MATKL .
*            READ TABLE IT_KSSK1 INTO WA_KSSK1 WITH KEY OBJEK = WA_KLAH1-CLINT .
*            READ TABLE IT_KSSK INTO WA_KSSK WITH KEY OBJEK   = WA_KSSK1-OBJEK1 .
*            READ TABLE IT_KLAH INTO WA_KLAH WITH KEY CLINT   = WA_KSSK-CLINT .
*            IF SY-SUBRC = 0.
*              WA_FINAL-CATEGORY  = WA_KLAH-CLASS .
*              WA_FINAL1-CATEGORY = WA_KLAH-CLASS .
*            ENDIF.
*            COLLECT WA_FINAL INTO IT_FINAL .
**    APPEND WA_FINAL TO IT_FINAL .
*            CLEAR WA_FINAL .
*            APPEND WA_FINAL1 TO IT_FINAL1 .
*            CLEAR WA_FINAL1 .
**    ENDIF.
**    ENDLOOP.
*          ENDLOOP.
*        ENDLOOP.
*      ENDLOOP.
*    ENDLOOP.
*  ENDLOOP.
  IT_KLAHA[] = IT_KLAH[] .

  DATA(IT_ZINW1) = IT_ZINW[] .
  DATA(IT_ZINW2) = IT_ZINW[] .
  SORT IT_ZINW1 BY MBLNR .
  DELETE ADJACENT DUPLICATES FROM IT_ZINW1 COMPARING MBLNR .       " commented on (31-3-20)
****************  added on (31-3-20)   *****************
  break CLIKHITHA.
*  loop at it_ZINW1 ASSIGNING FIELD-SYMBOL(<wa_zinw2>) .
*    wa_final4-qty = wa_final4-qty + <wa_zinw2>-menge.
*    wa_final4-GRPO_V = wa_final4-GRPO_V + <wa_zinw2>-netwr_p.
*    APPEND : wa_final4 TO it_final4.
*    CLEAR : wa_final4.
*
*    ENDLOOP.
****************  end(31-3-20)   *******************

  DELETE ADJACENT DUPLICATES FROM IT_ZINW COMPARING MBLNR .
  LOOP AT IT_ZINW ASSIGNING FIELD-SYMBOL(<WA_ZINW>)." WHERE MBLNR = <wa_zinw2>-MBLNR.
*    READ TABLE IT_ZINW ASSIGNING FIELD-SYMBOL(<WA_ZINW>) WITH KEY MATNR = WA_MARA-MATNR .
*    IF  SY-SUBRC = 0.


    WA_FINAL-GRPO_V   =  <WA_ZINW>-PUR_TOTAL .       " COMMENTED ON (11-2-20)
*      WA_FINAL-GRPO_V   =  <WA_ZINW>-NETWR_P.          " ADDED ON (11-2-20)
    WA_FINAL-GRPO_WT  =  <WA_ZINW>-NET_AMT .         " COMMENTED ON (14-2-20)
*     WA_FINAL-GRPO_WT  =  <WA_ZINW>-NETPR_GP + <WA_ZINW>-NETWR_P.         " ADDED ON (14-2-20)
    WA_FINAL-BUNDLE   =  <WA_ZINW>-ACT_NO_BUD .
*    WA_FINAL-QTY      =  <WA_ZINW>-MENGE ."+ WA_FINAL-QTY.    " COMMENTED ON (31-3-20)

**************************Screen2*************************
*    LOOP AT IT_ZINW1 ASSIGNING FIELD-SYMBOL(<WA_ZINW1>) WHERE MBLNR = <WA_ZINW>-MBLNR .
    WA_FINAL1-GRPO_V  =  <WA_ZINW>-PUR_TOTAL .      " COMMENTED ON (11-2-20)
*    WA_FINAL1-GRPO_V   =  <WA_ZINW>-NETWR_P.            " ADDED ON (11-2-20)
    WA_FINAL1-QR_CODE  =  <WA_ZINW>-QR_CODE .
    WA_FINAL1-GRPO_WT =  <WA_ZINW>-NET_AMT .
    WA_FINAL1-BUNDLE  =  <WA_ZINW>-ACT_NO_BUD .
********    WA_FINAL1-QTY     =  <WA_ZINW>-MENGE_P .
    WA_FINAL1-LIFNR   =  <WA_ZINW>-LIFNR .
    WA_FINAL1-GRPO    =  <WA_ZINW>-MBLNR .
    WA_FINAL1-NAME1   =  <WA_ZINW>-NAME1 .
    WA_FINAL1-WERKS   =  <WA_ZINW>-WERKS .
    WA_FINAL1-BLDAT   =  <WA_ZINW>-BLDAT.
    WA_FINAL1-MATNR   =  <WA_ZINW>-MATNR.

    CLEAR : WA_MARA , WA_KLAH1 , WA_KLAH , WA_KSSK1 , WA_KSSK .
    READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR   = <WA_ZINW>-MATNR .
    READ TABLE IT_KLAH1 INTO WA_KLAH1 WITH KEY CLASS = WA_MARA-MATKL .
    READ TABLE IT_KSSK1 INTO WA_KSSK1 WITH KEY OBJEK = WA_KLAH1-CLINT .
    READ TABLE IT_KSSK INTO WA_KSSK WITH KEY OBJEK   = WA_KSSK1-OBJEK1 .
    READ TABLE IT_KLAH INTO WA_KLAH WITH KEY CLINT   = WA_KSSK-CLINT .
**************    ADDED ON (31-3-20)
    LOOP AT IT_ZINW2 ASSIGNING FIELD-SYMBOL(<WA_ZINW3>) WHERE MBLNR = <WA_ZINW>-MBLNR .
      IF SY-SUBRC = 0.

    WA_FINAL-QTY = WA_FINAL-QTY + <WA_ZINW3>-MENGE_p.
    WA_FINAL1-QTY = WA_FINAL1-QTY + <WA_ZINW3>-MENGE_p.
        ENDIF.
        ENDLOOP.
*******************        END (31-3-20)
    IF SY-SUBRC = 0.
      DELETE IT_KLAHA WHERE CLINT = WA_KLAH-CLINT .
      WA_FINAL-CATEGORY  = WA_KLAH-CLASS .
      WA_FINAL1-CATEGORY = WA_KLAH-CLASS .
    ENDIF.
*      BREAK BREDDY .
*      ENDLOOP .
    READ TABLE IT_FINAL1 ASSIGNING FIELD-SYMBOL(<WA_FINAL>) WITH KEY  GRPO =   <WA_ZINW>-MBLNR .
    IF SY-SUBRC <> 0 .
      WA_FINAL-GRPO_N = 1 .
    ENDIF.

    COLLECT WA_FINAL INTO IT_FINAL .
*    APPEND WA_FINAL TO IT_FINAL .
    CLEAR WA_FINAL .
    APPEND WA_FINAL1 TO IT_FINAL1 .

    CLEAR WA_FINAL1 .
*    ENDIF.
  ENDLOOP.
*  ENDLOOP.    " ADDED ON (31-3-20)
*ENDLOOP.
  LOOP AT  IT_KLAHA ASSIGNING FIELD-SYMBOL(<WA_KLAHA>) .
    WA_FINAL-CATEGORY = <WA_KLAHA>-CLASS .
    APPEND WA_FINAL TO IT_FINAL .
    CLEAR WA_FINAL .
  ENDLOOP.
  BREAK BREDDY .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY .
  DATA : WA_LAYOUT   TYPE SLIS_LAYOUT_ALV.
  DATA: IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
        WA_FIELDCAT TYPE SLIS_FIELDCAT_ALV.
*        WVARI       TYPE DISVARIANT.

  DATA: IT_SORT TYPE SLIS_T_SORTINFO_ALV,
        WA_SORT TYPE SLIS_SORTINFO_ALV.

  WA_FIELDCAT-FIELDNAME = 'CATEGORY'.
  WA_FIELDCAT-SELTEXT_L =  'Group'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR   WA_FIELDCAT  .

  WA_FIELDCAT-FIELDNAME = 'GRPO_V'.
  WA_FIELDCAT-SELTEXT_L = 'Value Of GRPO'.
  WA_FIELDCAT-DO_SUM = 'X' .
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR   WA_FIELDCAT  .

  WA_FIELDCAT-FIELDNAME = 'GRPO_WT'.
  WA_FIELDCAT-SELTEXT_L = 'Value Of GRPO WT'.
  WA_FIELDCAT-DO_SUM = 'X' .
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR   WA_FIELDCAT  .

  WA_FIELDCAT-FIELDNAME = 'BUNDLE'.
  WA_FIELDCAT-SELTEXT_L = 'No. Of Bundle'.
  WA_FIELDCAT-DO_SUM = 'X' .
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR   WA_FIELDCAT  .

  WA_FIELDCAT-FIELDNAME = 'QTY'.
  WA_FIELDCAT-SELTEXT_L = 'No. Of Peices'.
  WA_FIELDCAT-DO_SUM = 'X' .
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR   WA_FIELDCAT  .

  WA_FIELDCAT-FIELDNAME = 'GRPO_N'.
  WA_FIELDCAT-SELTEXT_L = 'Number Of GRPO'.
  WA_FIELDCAT-DO_SUM = 'X' .
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR   WA_FIELDCAT  .

  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_BUFFER_ACTIVE         = ' '
      I_CALLBACK_PROGRAM      = SY-REPID
      IS_LAYOUT               = WA_LAYOUT
      I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
*     I_CALLBACK_HTML_TOP_OF_PAGE = 'TOP_OF_PAGE'
      IT_FIELDCAT             = IT_FIELDCAT
      IT_SORT                 = IT_SORT
      I_DEFAULT               = 'X'
      I_SAVE                  = 'A'
    TABLES
      T_OUTTAB                = IT_FINAL
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.

FORM USER_COMMAND USING  R_UCOMM LIKE SY-UCOMM RS_SELFIELD TYPE SLIS_SELFIELD.



  CASE R_UCOMM.
    WHEN '&IC1'.
      BREAK BREDDY .
      CASE RS_SELFIELD-FIELDNAME.
        WHEN 'CATEGORY' OR 'GRPO_V' OR 'QTY' OR 'GRPO_WT' OR 'BUNDLE'  OR 'GRPO_N'.
          REFRESH : IT_FINAL2 , IT_FINAL3 .
          BREAK CLIKHITHA.
          IT_FINAL3[] = IT_FINAL1[] .

          CLEAR WA_FINAL .
          READ TABLE IT_FINAL INTO WA_FINAL INDEX RS_SELFIELD-TABINDEX .
*          DELETE IT_FINAL2 WHERE CATEGORY <>  WA_FINAL-CATEGORY .
          DELETE IT_FINAL3 WHERE CATEGORY <>  WA_FINAL-CATEGORY .

          IT_BUN[] = IT_FINAL3 .
          SORT IT_FINAL3 BY GRPO .
          DELETE ADJACENT DUPLICATES FROM IT_FINAL3 COMPARING GRPO .

          SELECT
           ZINW_T_HDR~QR_CODE ,
           ZINW_T_HDR~MBLNR FROM ZINW_T_HDR INTO TABLE @DATA(IT_GATE)
                            FOR ALL ENTRIES IN @IT_FINAL3
                            WHERE MBLNR = @IT_FINAL3-GRPO .
          IF IT_GATE IS NOT INITIAL.
            SELECT
              ZINW_T_STATUS~QR_CODE ,
              ZINW_T_STATUS~STATUS_VALUE ,
              ZINW_T_STATUS~CREATED_DATE FROM ZINW_T_STATUS INTO TABLE @DATA(IT_STATUS)
                                         FOR ALL ENTRIES IN @IT_GATE
                                         WHERE QR_CODE = @IT_GATE-QR_CODE
                                         AND  STATUS_VALUE = 'QR02'.


          ENDIF.

          LOOP AT IT_FINAL3 ASSIGNING FIELD-SYMBOL(<LS_FINAL1>).

            WA_FINAL2-LIFNR   =  <LS_FINAL1>-LIFNR .
            WA_FINAL2-GRPO    =  <LS_FINAL1>-GRPO .
            READ TABLE IT_GATE ASSIGNING FIELD-SYMBOL(<LS_GATE>) WITH KEY MBLNR = <LS_FINAL1>-GRPO .
            IF SY-SUBRC = 0.
              READ TABLE IT_STATUS ASSIGNING FIELD-SYMBOL(<LS_STATUS>) WITH KEY QR_CODE = <LS_GATE>-QR_CODE .
              IF SY-SUBRC = 0.
                WA_FINAL2-GATE_ENTRY    =  <LS_STATUS>-CREATED_DATE  .
              ENDIF.

            ENDIF.

            WA_FINAL2-NAME1   =  <LS_FINAL1>-NAME1 .
            WA_FINAL2-WERKS   =  <LS_FINAL1>-WERKS .
            WA_FINAL2-BLDAT   =  <LS_FINAL1>-BLDAT .
            WA_FINAL2-MATNR   =  <LS_FINAL1>-MATNR .
            LOOP AT IT_BUN ASSIGNING FIELD-SYMBOL(<LS_BUN>) WHERE GRPO = <LS_FINAL1>-GRPO.
              WA_FINAL2-BUNDLE  =  <LS_BUN>-BUNDLE + WA_FINAL2-BUNDLE .
              WA_FINAL2-GRPO_V  =   <LS_BUN>-GRPO_V + WA_FINAL2-GRPO_V.
              WA_FINAL2-GRPO_WT =   <LS_BUN>-GRPO_WT + WA_FINAL2-GRPO_WT.
              WA_FINAL2-QTY     =   <LS_BUN>-QTY + WA_FINAL2-QTY .
*              **************    ADDED ON (31-3-20)
*    LOOP AT IT_FINAL1 ASSIGNING FIELD-SYMBOL(<WA_ZI>) WHERE GRPO = <LS_FINAL1>-QTY .
*      IF SY-SUBRC = 0.
**
*    WA_FINAL2-QTY = WA_FINAL-QTY + <LS_FINAL1>-QTY.
*        ENDIF.
*        ENDLOOP.
*******************        END (31-3-20)
            ENDLOOP.
            APPEND WA_FINAL2 TO IT_FINAL2 .
            CLEAR: WA_FINAL2 .
          ENDLOOP.

          IF IT_FINAL2 IS NOT INITIAL .
            PERFORM CAT_DETAIL .
          ENDIF.

      ENDCASE .
*      PERFORM GET_PO_DATA USING RS_SELFIELD .
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CAT_DETAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CAT_DETAIL .


  DATA: IT_FCAT1  TYPE SLIS_T_FIELDCAT_ALV,
        WA_FCAT1  TYPE SLIS_FIELDCAT_ALV,
        IT_EVENT1 TYPE SLIS_T_EVENT,
        WA_EVENT1 TYPE SLIS_ALV_EVENT.

  DATA WA_LAYOUT1 TYPE SLIS_LAYOUT_ALV.
  WA_LAYOUT1-COLWIDTH_OPTIMIZE = 'X'.
  WA_LAYOUT1-ZEBRA = 'X'.



  WA_FCAT1-FIELDNAME = 'WERKS'.
  WA_FCAT1-SELTEXT_M = 'Plant'.
*  WA_FCAT1-DO_SUM    = 'X' .
  APPEND  WA_FCAT1 TO IT_FCAT1.
  CLEAR :WA_FCAT1 .

  WA_FCAT1-FIELDNAME = 'LIFNR'.
  WA_FCAT1-SELTEXT_M = 'Vendor Code'.
*  WA_FCAT1-DO_SUM    = 'X' .
  APPEND  WA_FCAT1 TO IT_FCAT1.
  CLEAR :WA_FCAT1 .

  WA_FCAT1-FIELDNAME = 'NAME1'.
  WA_FCAT1-SELTEXT_M = 'Vendor Name'.
*  WA_FCAT1-DO_SUM    = 'X' .
  APPEND  WA_FCAT1 TO IT_FCAT1.
  CLEAR :WA_FCAT1 .


  WA_FCAT1-FIELDNAME = 'BLDAT'.
  WA_FCAT1-SELTEXT_M = 'GRPO Date' .
  WA_FCAT1-DO_SUM    = 'X' .
  APPEND  WA_FCAT1 TO IT_FCAT1.
  CLEAR :WA_FCAT1 .

  WA_FCAT1-FIELDNAME = 'GATE_ENTRY'.
  WA_FCAT1-SELTEXT_L =  'Gate Entry Date'.
  APPEND  WA_FCAT1 TO IT_FCAT1.
  CLEAR    WA_FCAT1 .

  WA_FCAT1-FIELDNAME = 'GRPO'.
  WA_FCAT1-SELTEXT_M = 'Grpo number '.
*  WA_FCAT1-DO_SUM    = 'X' .
  APPEND  WA_FCAT1 TO IT_FCAT1.
  CLEAR :WA_FCAT1 .

  WA_FCAT1-FIELDNAME = 'BUNDLE'.
  WA_FCAT1-SELTEXT_M = 'No. Of Bundles'.
  WA_FCAT1-DO_SUM    = 'X' .
  APPEND  WA_FCAT1 TO IT_FCAT1.
  CLEAR :WA_FCAT1 .

  WA_FCAT1-FIELDNAME = 'QTY'.
  WA_FCAT1-SELTEXT_M = 'No. of piece'.
  WA_FCAT1-DO_SUM    = 'X' .
  APPEND  WA_FCAT1 TO IT_FCAT1.
  CLEAR :WA_FCAT1 .

  WA_FCAT1-FIELDNAME = 'GRPO_V'.
  WA_FCAT1-SELTEXT_M = 'Amount Bef. Tax'.
  WA_FCAT1-DO_SUM    = 'X' .
  APPEND  WA_FCAT1 TO IT_FCAT1.
  CLEAR :WA_FCAT1 .

  WA_FCAT1-FIELDNAME = 'GRPO_WT'.
  WA_FCAT1-SELTEXT_M = 'Amount Aft. Tax'.
  WA_FCAT1-DO_SUM    = 'X' .
  APPEND  WA_FCAT1 TO IT_FCAT1.
  CLEAR :WA_FCAT1 .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-REPID
      IS_LAYOUT          = WA_LAYOUT1
      IT_FIELDCAT        = IT_FCAT1
    TABLES
      T_OUTTAB           = IT_FINAL2
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
ENDFORM.
