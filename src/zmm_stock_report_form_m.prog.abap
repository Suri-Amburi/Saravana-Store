*&---------------------------------------------------------------------*
*& Include          ZMM_STOCK_REPORT_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CATEGORY_WISE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM CATEGORY_WISE .
*
*  SELECT SINGLE  CLINT
*            KLART
*            CLASS
*            VONDT
*            BISDT
*            WWSKZ FROM KLAH INTO WA_KLAH
*            WHERE WWSKZ = '0'
*            AND KLART = '026'
*            AND CLASS = CATEGORY .
**  ENDIF.
*  IF WA_KLAH IS NOT INITIAL.
*    SELECT OBJEK
*           MAFID
*           KLART
*           CLINT
*           ADZHL
*           DATUB FROM KSSK INTO TABLE IT_KSSK
*            WHERE CLINT = WA_KLAH-CLINT.
*  ENDIF.
*
*  LOOP AT IT_KSSK INTO WA_KSSK .
*    SHIFT WA_KSSK-OBJEK LEFT DELETING LEADING '0'.
*    WA_KSSK1-OBJEK = WA_KSSK-OBJEK .
*    APPEND WA_KSSK1 TO IT_KSSK1 .
*    CLEAR WA_KSSK1 .
*  ENDLOOP.
*
*  IF IT_KSSK1 IS NOT INITIAL .
*    SELECT CLINT
*           KLART
*           CLASS
*           VONDT
*           BISDT
*           WWSKZ FROM KLAH INTO TABLE IT_KLAH
*           FOR ALL ENTRIES IN IT_KSSK1
*           WHERE CLINT = IT_KSSK1-OBJEK
*            AND WWSKZ = '1'.
*  ENDIF.
*  IT_KLAH1[] = IT_KLAH[] .
*  IF IT_KLAH IS NOT INITIAL .
*    SELECT MATNR
*           MATKL FROM MARA INTO TABLE IT_MARA
*           FOR ALL ENTRIES IN IT_KLAH1
*           WHERE MATKL = IT_KLAH1-CLASS .
*
*  ENDIF.
*
*  IF  IT_MARA IS NOT INITIAL .
*    SELECT MBLNR
*           MJAHR
*           ZEILE
*           BWART
*           MATNR
*           WERKS
*           LIFNR FROM MSEG INTO TABLE IT_MSEG
*           FOR ALL ENTRIES IN IT_MARA
*           WHERE  MATNR = IT_MARA-MATNR AND BWART = '101'
*           . ""101 OR 103 FOR UNRESTRICTED
*  ENDIF.
*
*  IF IT_MSEG IS NOT INITIAL .
*    SELECT MATNR
*           BWKEY
*           BWTAR
*           VERPR
*           STPRS  FROM MBEW INTO TABLE IT_MBEW
*            FOR ALL ENTRIES IN IT_MSEG
*            WHERE MATNR = IT_MSEG-MATNR AND BWKEY = IT_MSEG-WERKS .    " VALUATION TABLE
*
*    SELECT  MATNR
*            WERKS
*            LGORT
*            LFGJA
*            LABST FROM MARD INTO TABLE IT_MARD
*            FOR ALL ENTRIES IN IT_MSEG
*             WHERE MATNR = IT_MSEG-MATNR AND WERKS  = IT_MSEG-WERKS.    "WITHOUT BATCH STOCK
*  ENDIF.
*
*
*  IT_MSEG1[] = IT_MSEG[] .
*  DELETE ADJACENT DUPLICATES FROM IT_MSEG1 COMPARING WERKS . ""single plant
**  IT_MSEG2[] = IT_MSEG[] .
**  DELETE ADJACENT DUPLICATES FROM IT_MSEG2 COMPARING LIFNR . ""single vendor
*
*  IF IT_MSEG2 IS NOT INITIAL .
*    SELECT LIFNR
*           LAND1
*           NAME1 FROM LFA1 INTO TABLE IT_LFA1
*          FOR ALL ENTRIES IN IT_MSEG2
*          WHERE LIFNR = IT_MSEG2-LIFNR .
*  ENDIF.
*
*
*
**  LOOP AT it_klah INTO wa_klah .
**    LOOP AT it_kssk INTO wa_kssk where objek = wa_klah-clint .
**
**    ENDLOOP.
**  ENDLOOP.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form DISPLAY_C
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
*FORM DISPLAY_C .
*
*
*

*ENDFORM.
*&---------------------------------------------------------------------*
*& Form VENDOR_WISE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VENDOR_WISE .

*  IF CATEGORY IS NOT INITIAL .
*    SELECT SINGLE CLINT
*            KLART
*            CLASS
*            VONDT
*            BISDT
*            WWSKZ FROM KLAH INTO  WA_KLAH
*            WHERE CLASS = CATEGORY
*             AND  WWSKZ = '0'
*             AND KLART = '026'.
*  ENDIF.
*  IF WA_KLAH IS NOT INITIAL.
*    SELECT OBJEK
*           MAFID
*           KLART
*           CLINT
*           ADZHL
*           DATUB FROM KSSK INTO TABLE IT_KSSK
*            WHERE CLINT = WA_KLAH-CLINT.
*  ENDIF.
*
*  LOOP AT IT_KSSK INTO WA_KSSK .
*    SHIFT WA_KSSK-OBJEK LEFT DELETING LEADING '0'.
*    WA_KSSK1-OBJEK = WA_KSSK-OBJEK .
*    APPEND WA_KSSK1 TO IT_KSSK1 .
*    CLEAR WA_KSSK1 .
*  ENDLOOP.
*
*  IF IT_KSSK1 IS NOT INITIAL .
*    SELECT CLINT
*           KLART
*           CLASS
*           VONDT
*           BISDT
*           WWSKZ FROM KLAH INTO TABLE IT_KLAH
*           FOR ALL ENTRIES IN IT_KSSK1
*           WHERE CLINT = IT_KSSK1-OBJEK
*           AND WWSKZ = '1'.
*  ENDIF.
*
*  IT_KLAH1[] = IT_KLAH[] .
*  IF IT_KLAH IS NOT INITIAL AND CATEGORY IS NOT INITIAL.
*    SELECT MATNR
*           MATKL FROM MARA INTO TABLE IT_MARA
*           FOR ALL ENTRIES IN IT_KLAH1
*           WHERE MATKL = IT_KLAH1-CLASS   .          ""OR MATKL IN GROUP .
*
*  ENDIF.
*
*  IF GROUP IS NOT INITIAL AND CATEGORY IS INITIAL.
*    SELECT MATNR
*           MATKL FROM MARA INTO TABLE IT_MARA
**           FOR ALL ENTRIES IN IT_KLAH1
*           WHERE MATKL IN GROUP.
*  ENDIF.
*
*
*  BREAK BREDDY.
*  IF  IT_MARA IS NOT INITIAL .
*    SELECT MBLNR
*           MJAHR
*           ZEILE
*           BWART
*           MATNR
*           WERKS
*           LIFNR FROM MSEG INTO TABLE IT_MSEG
*           FOR ALL ENTRIES IN IT_MARA
*           WHERE MATNR = IT_MARA-MATNR AND BWART IN ( '101'  , '107' ,  '202'  , '642'  ).
*  ENDIF.
*
*  IF IT_MARA IS NOT INITIAL.
*    SELECT MBLNR
*           MJAHR
*           ZEILE
*           BWART
*           MATNR
*           WERKS
*           LIFNR FROM MSEG INTO TABLE IT_MSEG_M
*           FOR ALL ENTRIES IN IT_MARA
*           WHERE MATNR = IT_MARA-MATNR AND BWART IN ( '102'  , '108' ,  '201'  , '251' , '641'  ).
*
*
*  ENDIF.
*
*  IF IT_MSEG IS NOT INITIAL .
*    SELECT MATNR
*           BWKEY
*           BWTAR
*           VERPR
*           STPRS  FROM MBEW INTO TABLE IT_MBEW
*            FOR ALL ENTRIES IN IT_MSEG
*            WHERE MATNR = IT_MSEG-MATNR AND BWKEY = IT_MSEG-WERKS .
*
*    SELECT  MATNR
*            WERKS
*            LGORT
*            LFGJA
*            LABST FROM MARD INTO TABLE IT_MARD
*            FOR ALL ENTRIES IN IT_MSEG
*             WHERE MATNR = IT_MSEG-MATNR AND WERKS  = IT_MSEG-WERKS.
*  ENDIF.
*
*
*  IT_MSEG1[] = IT_MSEG[] .
*  SORT IT_MSEG1 DESCENDING BY LIFNR WERKS MATNR .
*  DELETE ADJACENT DUPLICATES FROM IT_MSEG1 COMPARING LIFNR WERKS MATNR. ""single plant
*  IT_MSEG2[] = IT_MSEG[] .
*  SORT IT_MSEG2 DESCENDING BY LIFNR.
*  DELETE ADJACENT DUPLICATES FROM IT_MSEG2 COMPARING LIFNR. ""single vendor
*
*  IF IT_MSEG2 IS NOT INITIAL .
*    SELECT LIFNR
*           LAND1
*           NAME1 FROM LFA1 INTO TABLE IT_LFA1
*          FOR ALL ENTRIES IN IT_MSEG2
*          WHERE LIFNR = IT_MSEG2-LIFNR .
*  ENDIF.
*
*
**  LOOP AT IT_MSEG2 INTO WA_MSEG2 .
**    WA_FINAL-LIFNR = WA_MSEG2-LIFNR .
**    LOOP AT IT_MSEG1 INTO WA_MSEG1 WHERE LIFNR = WA_MSEG2-LIFNR  .
**      LOOP AT IT_MARD INTO WA_MARD WHERE WERKS = WA_MSEG1-WERKS AND LIFNR = WA_MSEG2-LIFNR  .
**        WA_FINAL-LABST = WA_MARD-LABST +  WA_FINAL-LABST .
**        WA_FINAL-WERKS = WA_MARD-WERKS .
**        READ TABLE IT_MBEW INTO WA_MBEW WITH KEY MATNR = WA_MARD-MATNR BWKEY = WA_MARD-WERKS.
**        IF SY-SUBRC = 0.
**          WA_FINAL-VALUE = ( WA_MBEW-VERPR * WA_MARD-LABST ) + WA_FINAL-VALUE .
**        ENDIF.
**      ENDLOOP.
**      APPEND WA_FINAL TO IT_FINAL.
**      CLEAR WA_FINAL .
**    ENDLOOP.
**  ENDLOOP.
*
*
*  BREAK BREDDY .
*  LOOP AT IT_MSEG2 INTO WA_MSEG2 .
*    WA_FINAL-LIFNR = WA_MSEG2-LIFNR .
*    LOOP AT IT_MSEG1 INTO WA_MSEG1 WHERE LIFNR = WA_MSEG2-LIFNR AND WERKS = WA_MSEG2-WERKS  .
*      LOOP AT IT_MARD INTO WA_MARD WHERE WERKS = WA_MSEG2-WERKS  AND MATNR = WA_MSEG1-MATNR .
*        WA_FINAL-LABST = WA_MARD-LABST +  WA_FINAL-LABST .
*        WA_FINAL-WERKS = WA_MARD-WERKS .
*        READ TABLE IT_MBEW INTO WA_MBEW WITH KEY MATNR = WA_MARD-MATNR BWKEY = WA_MARD-WERKS.
*        IF SY-SUBRC = 0.
*          WA_FINAL-VALUE = ( WA_MBEW-VERPR * WA_MARD-LABST ) + WA_FINAL-VALUE .
*        ENDIF.
*      ENDLOOP.
*    ENDLOOP.
*    APPEND WA_FINAL TO IT_FINAL.
*    CLEAR WA_FINAL .
*  ENDLOOP.


  IF CATEGORY IS NOT INITIAL OR GROUP IS NOT INITIAL.
    SELECT SINGLE  CLINT
            KLART
            CLASS
            VONDT
            BISDT
            WWSKZ FROM KLAH INTO WA_KLAH
            WHERE CLASS = CATEGORY
             AND  WWSKZ = '0'
             AND KLART = '026'.

*  ELSE .
*    MESSAGE 'Enter the value' TYPE 'I' DISPLAY LIKE 'I' .
  ENDIF.



  IF WA_KLAH IS NOT INITIAL.
    SELECT OBJEK
           MAFID
           KLART
           CLINT
           ADZHL
           DATUB FROM KSSK INTO TABLE IT_KSSK
            WHERE CLINT = WA_KLAH-CLINT.
  ENDIF.

  LOOP AT IT_KSSK INTO WA_KSSK .
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
           WWSKZ FROM KLAH INTO TABLE IT_KLAH
           FOR ALL ENTRIES IN IT_KSSK1
           WHERE CLINT = IT_KSSK1-OBJEK
           AND WWSKZ = '1'.
  ENDIF.

  IT_KLAH1[] = IT_KLAH[] .
  IF IT_KLAH IS NOT INITIAL AND GROUP IS NOT INITIAL AND CATEGORY IS NOT INITIAL.
    SELECT MATNR
           MATKL FROM MARA INTO TABLE IT_MARA
           FOR ALL ENTRIES IN IT_KLAH1
           WHERE MATKL = IT_KLAH1-CLASS
           AND MATKL = GROUP.

  ELSEIF  GROUP IS NOT INITIAL .

    SELECT MATNR
       MATKL FROM MARA INTO TABLE IT_MARA
*       FOR ALL ENTRIES IN IT_KLAH1
*       WHERE MATKL = IT_KLAH1-CLASS
       WHERE MATKL = GROUP.

  ELSEIF IT_KLAH IS NOT INITIAL AND  CATEGORY IS NOT INITIAL.
    SELECT MATNR
           MATKL FROM MARA INTO TABLE IT_MARA
           FOR ALL ENTRIES IN IT_KLAH1
           WHERE MATKL = IT_KLAH1-CLASS .
*           AND MATKL = GROUP.

  ENDIF.





  IF IT_MARA IS NOT INITIAL .
    SELECT
      MBEW~MATNR ,
      MBEW~BWKEY ,
      MBEW~LBKUM ,
      MBEW~SALK3 ,
      A502~LIFNR ,
      A502~KSCHL ,
      KONP~KNUMH
      INTO TABLE @GT_DATA
      FROM MBEW AS MBEW
*      INNER JOIN MBEW AS MBEW ON MARA~MATNR = MBEW~MATNR
      INNER JOIN A502 AS A502 ON MBEW~MATNR = A502~MATNR
      LEFT OUTER JOIN  KONP AS KONP ON A502~KNUMH  = KONP~KNUMH
      FOR ALL ENTRIES IN @IT_MARA
      WHERE MBEW~MATNR = @IT_MARA-MATNR
*      WHERE MBEW~MATNR = '150004-125 GM'
      AND  MBEW~BWKEY IN ('SSCP' , 'SSPO' , 'SSPU' , 'SSTN' , 'SSWH' )
*      AND MBEW~BWKEY = 'SSWH'
      AND MBEW~LBKUM <> '0'
      AND BWTAR = ' '
      AND DATAB LE @SY-DATUM
      AND DATBI GE @SY-DATUM
      AND KONP~LOEVM_KO = ' '.
  ENDIF .


*  IF IT_MARA IS NOT INITIAL.
*
*    SELECT
*      MATNR
*      BWKEY
*      LBKUM
*      SALK3 FROM MBEW INTO TABLE IT_MBEW
*                 FOR ALL ENTRIES IN IT_MARA
*                WHERE MATNR = IT_MARA-MATNR
*               AND MBEW~BWKEY = 'SSWH'
*                AND MBEW~LBKUM <> '0'
*          AND BWTAR = ' '.
*  ENDIF.

  DATA(GT_DATA_M) = GT_DATA[] .
  SORT GT_DATA BY LIFNR BWKEY .
  DELETE ADJACENT DUPLICATES FROM GT_DATA COMPARING LIFNR BWKEY .

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<LS_DATA>).
    WA_FINAL-LIFNR = <LS_DATA>-LIFNR .
    WA_FINAL-BWKEY = <LS_DATA>-BWKEY .

    LOOP AT GT_DATA_M ASSIGNING FIELD-SYMBOL(<LS_DATA_M>) WHERE LIFNR = <LS_DATA>-LIFNR AND BWKEY = <LS_DATA>-BWKEY.

      WA_FINAL-LBKUM = <LS_DATA_M>-LBKUM +  WA_FINAL-LBKUM .
      WA_FINAL-SALK3 = <LS_DATA_M>-SALK3 +  WA_FINAL-SALK3 .

    ENDLOOP.

    APPEND WA_FINAL TO IT_FINAL.
    CLEAR : WA_FINAL.



  ENDLOOP.

  BREAK BREDDY .



*  DATA : TEXT01 TYPE CHAR10,
*         TEXT02 TYPE CHAR10.
*
*  TEXT01 = 'VALUE' .
*  TEXT02 = 'QUANTITY'.
  IT_FINAL1[] = IT_FINAL[] .
  SORT IT_FINAL1 BY  BWKEY .
  DELETE ADJACENT DUPLICATES FROM IT_FINAL1 COMPARING  BWKEY.


  SELECT
    T001W~WERKS ,
    T001W~NAME1 FROM T001W INTO TABLE @DATA(IT_T001W)
*    WHERE WERKS LIKE 'S%' .
    WHERE WERKS IN ( 'SSCP' , 'SSPO' , 'SSPU' , 'SSTN' , 'SSWH' ) .
*    FOR ALL ENTRIES IN @IT_FINAL1
*    WHERE WERKS = @IT_FINAL1-WERKS .

  WRITE : 01 'LIFNR'  , 07 'WERKS' .
  DATA : LV_FIELD TYPE CHAR20 .
  DATA : LV_NUM(03)   TYPE I .


  WA_FIELDCAT-FIELDNAME = 'LIFNR'.
  WA_FIELDCAT-SELTEXT_M = 'VENDOR NAME'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR : WA_FIELDCAT .
  BREAK BREDDY .
  DATA : GV_CHAR TYPE CHAR2 .
*  LOOP AT IT_FINAL1 INTO WA_FINAL1 .

*    READ TABLE IT_T001W ASSIGNING FIELD-SYMBOL(<LS_T001W>) WITH KEY WERKS = WA_FINAL1-WERKS .
*    IF SY-SUBRC = 0.
*      LV_FIELD = <LS_T001W>-NAME1 .
*    ENDIF.

  LOOP AT IT_T001W  ASSIGNING FIELD-SYMBOL(<LS_T001W>) .
    IF <LS_T001W>-WERKS IS NOT INITIAL .
      ADD 1 TO LV_NUM .
      GV_CHAR = LV_NUM .
      GV_CHAR = |{ GV_CHAR  ALPHA = IN }|.
      WA_FIELDCAT-FIELDNAME = |W{ GV_CHAR }Q|.
      WA_FIELDCAT-SELTEXT_M =  |{ <LS_T001W>-WERKS } { 'Quantity' } | ."<LS_T001W>-NAME1.
      APPEND WA_FIELDCAT TO IT_FIELDCAT.
      WA_FIELDCAT-FIELDNAME = |W{ GV_CHAR }V|.
      WA_FIELDCAT-SELTEXT_M = |{ <LS_T001W>-WERKS } { 'Value' } | .                        ""<LS_T001W>-NAME1.
      APPEND WA_FIELDCAT TO IT_FIELDCAT.
      GS_TAB-SL_NO = LV_NUM .
      GS_TAB-PLANT = <LS_T001W>-WERKS .
      APPEND GS_TAB TO GT_TAB .
      CLEAR : GS_TAB .
    ENDIF .
  ENDLOOP.


  WA_FIELDCAT-FIELDNAME = 'CUM'.
  WA_FIELDCAT-SELTEXT_M = 'Cummulative Quantity'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR : WA_FIELDCAT .

  WA_FIELDCAT-FIELDNAME = 'CUM1'.
  WA_FIELDCAT-SELTEXT_M = 'Cummulative Value'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR : WA_FIELDCAT .


  BREAK BREDDY .
  SORT IT_FINAL BY LIFNR .

  LOOP AT IT_FINAL ASSIGNING FIELD-SYMBOL(<LS_TABLE>).

    GS_TABLE-LIFNR = <LS_TABLE>-LIFNR .
    READ TABLE GT_TAB ASSIGNING FIELD-SYMBOL(<LS_TAB>) WITH KEY PLANT = <LS_TABLE>-BWKEY .

    IF <LS_TAB>-SL_NO = '1' .

      ADD <LS_TABLE>-LBKUM  TO GS_TABLE-W01Q   .
      ADD <LS_TABLE>-SALK3 TO GS_TABLE-W01V.

    ELSEIF <LS_TAB>-SL_NO = '2' .

      ADD <LS_TABLE>-LBKUM  TO GS_TABLE-W02Q   .
      ADD <LS_TABLE>-SALK3 TO GS_TABLE-W02V.

    ELSEIF <LS_TAB>-SL_NO = '3' .

      ADD <LS_TABLE>-LBKUM  TO GS_TABLE-W03Q   .
      ADD <LS_TABLE>-SALK3 TO GS_TABLE-W03V.

    ELSEIF <LS_TAB>-SL_NO = '4' .

      ADD <LS_TABLE>-LBKUM  TO GS_TABLE-W04Q.
      ADD <LS_TABLE>-SALK3 TO GS_TABLE-W04V.

    ELSEIF <LS_TAB>-SL_NO = '5' .

      ADD <LS_TABLE>-LBKUM  TO GS_TABLE-W05Q.
      ADD <LS_TABLE>-SALK3 TO GS_TABLE-W05V.

    ELSEIF <LS_TAB>-SL_NO = '6' .

      ADD <LS_TABLE>-LBKUM  TO GS_TABLE-W06Q.
      ADD <LS_TABLE>-SALK3 TO GS_TABLE-W06V.

    ELSEIF <LS_TAB>-SL_NO = '7' .

      ADD <LS_TABLE>-LBKUM  TO GS_TABLE-W07Q.
      ADD <LS_TABLE>-SALK3 TO GS_TABLE-W07V.

    ELSEIF <LS_TAB>-SL_NO = '8' .

      ADD <LS_TABLE>-LBKUM  TO GS_TABLE-W08Q.
      ADD <LS_TABLE>-SALK3 TO GS_TABLE-W08V.

    ELSEIF <LS_TAB>-SL_NO = '9' .

      ADD <LS_TABLE>-LBKUM  TO GS_TABLE-W09Q.
      ADD <LS_TABLE>-SALK3 TO GS_TABLE-W09V.

    ELSEIF <LS_TAB>-SL_NO = '10' .

      ADD <LS_TABLE>-LBKUM  TO GS_TABLE-W010Q.
      ADD <LS_TABLE>-SALK3 TO GS_TABLE-W010V.

    ENDIF .

    ADD <LS_TABLE>-LBKUM  TO GS_TABLE-CUM.
    ADD <LS_TABLE>-SALK3 TO GS_TABLE-CUM1.


    AT END OF LIFNR .
      APPEND GS_TABLE TO GT_TABLE .
      CLEAR : GS_TABLE .

    ENDAT .

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_V
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_V .

  WA_EVENTS-NAME = SLIS_EV_TOP_OF_PAGE .
  WA_EVENTS-FORM = 'TOP_PAGE'.
  WA_EVENTS-FORM = 'TOP_OF_PAGE'.
  APPEND WA_EVENTS TO IT_EVENTS.
  CLEAR WA_EVENTS.

  BREAK BREDDY .
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-REPID
      IS_LAYOUT          = WA_LAYOUT
      IT_FIELDCAT        = IT_FCAT
      IT_EVENTS          = IT_EVENTS
      I_DEFAULT          = 'X'
      I_SAVE             = 'U'
    TABLES
      T_OUTTAB           = IT_FINAL
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM TOP_OF_PAGE .
  BREAK BREDDY .

  WRITE : / SY-ULINE.
  WRITE : SY-VLINE , (07)'Group :', (24)CATEGORY  , SY-VLINE.
  WRITE : / SY-ULINE.
  WRITE : SY-VLINE , (15)'Category Code :', (16)GROUP LEFT-JUSTIFIED, SY-VLINE.
*       SY-VLINE, (10) 'Plant'   CENTERED,
*       SY-VLINE, (20) 'Plant1'  CENTERED,
*       SY-VLINE, (30) 'Plant2'  LEFT-JUSTIFIED,SY-VLINE.
*SY-VLINE.

  WRITE: / SY-ULINE.
  WRITE: / SY-VLINE ,(07) 'VENDOR' CENTERED , SY-VLINE ,(22) 'SSTN' CENTERED,  SY-VLINE.", (26) 'SSPU' CENTERED , SY-VLINE . ""(20) 'SSWH' CENTERED , 89 SY-VLINE , (20) 'SSCP' CENTERED ,
  "" 111 SY-VLINE , (20) 'SSPO' CENTERED , 133 SY-VLINE , (20) 'SFPO' CENTERED , 155 SY-VLINE , (20) 'SFPU' CENTERED , 177 SY-VLINE.
*  WRITE: / SY-VLINE , 23 'QUANTITY' ,33 SY-VLINE, 34 'VALUE', 46 'QUANTITY', 56 SY-VLINE, 57 'VALUE', 69 'QUANTITY' , 79 SY-VLINE , 80 'VALUE' , 91 'QUANTITY' , 101 SY-VLINE , 102 'VALUE'
*  , 113 'QUANTITY' , 123 SY-VLINE , 124 'VALUE' , 135 'QUANTITY' , 145 SY-VLINE , 146 'VALUE' , 157 'QUANTITY' , 167 SY-VLINE , 169 'VALUE' , 177 SY-VLINE .
*  WRITE: / SY-ULINE(177) .

  FORMAT COLOR COL_HEADING.

ENDFORM.
**&---------------------------------------------------------------------*
**& Form GT_EVENTS
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
*FORM GT_EVENTS .
**  DATA: IT_EVENTS TYPE  SLIS_T_EVENT,
**        WA_EVENTS TYPE SLIS_ALV_EVENT.
**
**  DATA : IT_FCAT TYPE SLIS_T_FIELDCAT_ALV .
**        WA_EVENTS TYPE SLIS_T_EVENT.
**  DATA: ls_EVENT    TYPE SLIS_T_EVENT.
*
**  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
**    EXPORTING
**      I_LIST_TYPE     = 0
**    IMPORTING
**      ET_EVENTS       = GT_EVENTS[]
**    EXCEPTIONS
**      LIST_TYPE_WRONG = 1
**      OTHERS          = 2.
**  IF SY-SUBRC <> 0.
*** Implement suitable error handling here
**  ENDIF.
***  DATA : LS_EVENT TYPE CHAR1 .
**  READ TABLE GT_EVENTS WITH KEY NAME =  SLIS_EV_TOP_OF_PAGE
**                             INTO LS_EVENT.
**
**
**  IF SY-SUBRC = 0.
**    MOVE 'TOP-OF-PAGE' TO LS_EVENT-FORM.
**    APPEND LS_EVENT TO GT_EVENTS.
**  ENDIF.
**
**
**  READ TABLE GT_EVENTS WITH KEY NAME =  SLIS_EV_END_OF_LIST
**                       INTO LS_EVENT.
**
**  IF SY-SUBRC = 0.
**    MOVE 'END_OF_LIST' TO LS_EVENT-FORM.
**    APPEND LS_EVENT TO GT_EVENTS.
**  ENDIF.
*
*
*
*
*  WA_EVENTS-NAME = SLIS_EV_TOP_OF_PAGE .
*  WA_EVENTS-FORM = 'TOP_OF_PAGE'.
*  APPEND WA_EVENTS TO IT_EVENTS.
*  CLEAR WA_EVENTS.
*  PERFORM FIELDCATALOG.
*
*  PERFORM DISP .
*ENDFORM .
*FORM DISP.
*  BREAK BREDDY .
*  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
*    EXPORTING
*      I_CALLBACK_PROGRAM = SY-REPID
*      IS_LAYOUT          = WA_LAYOUT
*      IT_FIELDCAT        = IT_FCAT
*      IT_EVENTS          = IT_EVENTS
*    TABLES
*      T_OUTTAB           = IT_FINAL
*    EXCEPTIONS
*      PROGRAM_ERROR      = 1
*      OTHERS             = 2.
*
*
*
**  PERFORM TOP.
*ENDFORM.                    " BUILD_EVENTS
***&---------------------------------------------------------------------*
***& Form DISP
***&---------------------------------------------------------------------*
***& text
***&---------------------------------------------------------------------*
***& -->  p1        text
***& <--  p2        text
***&---------------------------------------------------------------------*
**FORM DISP .
**
**
**  GD_REPID = SY-REPID.
**
**  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
**    EXPORTING
***     I_INTERFACE_CHECK       = ' '
***     I_BYPASSING_BUFFER      =
***     I_BUFFER_ACTIVE         = ' '
**      I_CALLBACK_PROGRAM      = GD_REPID
***     I_CALLBACK_PF_STATUS_SET       = ' '
**      I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
***     I_STRUCTURE_NAME        =
**      IS_LAYOUT               = GD_LAYOUT
**      IT_FIELDCAT             = FIELDCATALOG[]
***     IT_EXCLUDING            =
***     IT_SPECIAL_GROUPS       = gd_tabgroup
***     IT_SORT                 =
***     IT_FILTER               =
***     IS_SEL_HIDE             =
***     I_DEFAULT               = 'X'
**      I_SAVE                  = 'X'
***     IS_VARIANT              =
**      IT_EVENTS               = GT_EVENTS[]
***     IT_EVENT_EXIT           =
***     IS_PRINT                =
***     IS_REPREP_ID            =
***     I_SCREEN_START_COLUMN   = 0
***     I_SCREEN_START_LINE     = 0
***     I_SCREEN_END_COLUMN     = 0
***     I_SCREEN_END_LINE       = 0
***     IR_SALV_LIST_ADAPTER    =
***     IT_EXCEPT_QINFO         =
***     I_SUPPRESS_EMPTY_DATA   = ABAP_FALSE
***   IMPORTING
***     E_EXIT_CAUSED_BY_CALLER =
***     ES_EXIT_CAUSED_BY_USER  =
**    TABLES
**      T_OUTTAB                =
**    EXCEPTIONS
**      PROGRAM_ERROR           = 1
**      OTHERS                  = 2.
**  IF SY-SUBRC <> 0.
*** Implement suitable error handling here
**  ENDIF.
**
**  PERFORM TOP .
**ENDFORM.
**&---------------------------------------------------------------------*
**& Form TOP
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
*FORM TOP_OF_PAGE .
*  BREAK BREDDY .
*
**  WRITE : /
**       SY-VLINE, (10) 'Plant'   CENTERED,
**       SY-VLINE, (20) 'Plant1'  CENTERED,
**       SY-VLINE, (30) 'Plant2'  LEFT-JUSTIFIED,SY-VLINE.
*  WRITE: / SY-ULINE(65).
*  WRITE: / SY-VLINE ,(20) 'VENDOR' CENTERED ,21  SY-VLINE ,(20) 'SSTN' CENTERED,44  SY-VLINE, (20) 'SSPU' CENTERED , 65 SY-VLINE . ""(20) 'SSWH' CENTERED , 89 SY-VLINE , (20) 'SSCP' CENTERED ,
* "" 111 SY-VLINE , (20) 'SSPO' CENTERED , 133 SY-VLINE , (20) 'SFPO' CENTERED , 155 SY-VLINE , (20) 'SFPU' CENTERED , 177 SY-VLINE.
**  WRITE: / SY-VLINE , 23 'QUANTITY' ,33 SY-VLINE, 34 'VALUE', 46 'QUANTITY', 56 SY-VLINE, 57 'VALUE', 69 'QUANTITY' , 79 SY-VLINE , 80 'VALUE' , 91 'QUANTITY' , 101 SY-VLINE , 102 'VALUE'
**  , 113 'QUANTITY' , 123 SY-VLINE , 124 'VALUE' , 135 'QUANTITY' , 145 SY-VLINE , 146 'VALUE' , 157 'QUANTITY' , 167 SY-VLINE , 169 'VALUE' , 177 SY-VLINE .
**  WRITE: / SY-ULINE(177) .
*
*  FORMAT COLOR COL_HEADING.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form FIELDCATALOG
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
*FORM FIELDCATALOG .
*  BREAK BREDDY .
*
*
*
*  WA_FCAT-COL_POS  = 01.
*  WA_FCAT-FIELDNAME = 'LIFNR'.
**  WA_FCAT-SELTEXT_M = 'Vendor'.
*  WA_FCAT-TABNAME = 'IT_FINAL'.
*  WA_FCAT-OUTPUTLEN   = 20.
*  WA_FCAT-JUST        = 'C'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.
*
*  WA_FCAT-COL_POS  = 02.
*  WA_FCAT-FIELDNAME = 'LBKUM'.
*  WA_FCAT-SELTEXT_M = 'Quantity'.
*  WA_FCAT-TABNAME = 'IT_FINAL'.
*  WA_FCAT-OUTPUTLEN   = 20.
*  WA_FCAT-JUST        = 'C'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.
*
*  WA_FCAT-COL_POS  = 03.
*  WA_FCAT-FIELDNAME = 'SALK3'.
*  WA_FCAT-SELTEXT_M = 'Value'.
*  WA_FCAT-TABNAME = 'IT_FINAL'.
*  WA_FCAT-OUTPUTLEN            = 20.
*  WA_FCAT-JUST                 = 'C'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.
*
*
*
*
*
**  PERFORM TOP.
**
**
**  WA_EVENTS-NAME = SLIS_EV_TOP_OF_PAGE .
**  WA_EVENTS-FORM = 'TOP_OF_PAGE'.
**  APPEND WA_EVENTS TO IT_EVENTS.
**  CLEAR WA_EVENTS.
*
*
*
*
*
**  BREAK BREDDY .
**  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
**    EXPORTING
**      I_CALLBACK_PROGRAM = SY-REPID
**      IS_LAYOUT          = WA_LAYOUT
**      IT_FIELDCAT        = IT_FCAT
**      IT_EVENTS          = IT_EVENTS
**    TABLES
**      T_OUTTAB           = IT_FINAL
**    EXCEPTIONS
**      PROGRAM_ERROR      = 1
**      OTHERS             = 2.
*
*ENDFORM.
