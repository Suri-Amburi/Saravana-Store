*&---------------------------------------------------------------------*
*& Include          ZMM_VC_STOCK_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GETDATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GETDATA .
  BREAK BREDDY .
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
  DATA : IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
         WA_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
         WVARI       TYPE DISVARIANT.

  DATA: IT_SORT TYPE SLIS_T_SORTINFO_ALV,
        WA_SORT TYPE SLIS_SORTINFO_ALV.
  TYPE-POOLS : SLIS.
  DATA : WA_LAYOUT TYPE SLIS_LAYOUT_ALV .
  WA_LAYOUT-ZEBRA = 'X' .
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X' .
  WA_FIELDCAT-FIELDNAME = 'LIFNR'.
  WA_FIELDCAT-SELTEXT_M = 'Vendor'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  WA_FIELDCAT-FIELDNAME = 'BWKEY'.
  WA_FIELDCAT-SELTEXT_M =  'Plant'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  WA_FIELDCAT-FIELDNAME = 'LBKUM'.
  WA_FIELDCAT-SELTEXT_M = 'Quantity'.
  WA_FIELDCAT-DO_SUM = 'X'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  WA_FIELDCAT-FIELDNAME = 'SALK3'.
  WA_FIELDCAT-SELTEXT_M = 'Amount'.
  WA_FIELDCAT-DO_SUM = 'X'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_BUFFER_ACTIVE             = ' '
      I_CALLBACK_PROGRAM          = SY-REPID
      IS_LAYOUT                   = WA_LAYOUT
      I_CALLBACK_HTML_TOP_OF_PAGE = 'TOP_OF_PAGE'
      IT_FIELDCAT                 = IT_FIELDCAT
      IT_SORT                     = IT_SORT
      I_DEFAULT                   = 'X'
      I_SAVE                      = 'A'
      IS_VARIANT                  = WVARI
    TABLES
      T_OUTTAB                    = IT_FINAL
    EXCEPTIONS
      PROGRAM_ERROR               = 1
      OTHERS                      = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.
FORM TOP_OF_PAGE USING TOP TYPE REF TO CL_DD_DOCUMENT.

  DATA: LV_TOP  TYPE SDYDO_TEXT_ELEMENT,
        LV_DATE TYPE SDYDO_TEXT_ELEMENT,
        LV_CAT  TYPE SDYDO_TEXT_ELEMENT,
        LV_GP   TYPE SDYDO_TEXT_ELEMENT,
        SEP     TYPE C VALUE ' ',
        DOT     TYPE C VALUE '.',
        YYYY1   TYPE CHAR4,
        MM1     TYPE CHAR2,
        DD1     TYPE CHAR2,
        DATE1   TYPE CHAR10,
        YYYY2   TYPE CHAR4,
        MM2     TYPE CHAR2,
        DD2     TYPE CHAR2,
        DATE2   TYPE CHAR10.

  LV_TOP = 'VENDOR CATEGORY STOCK REPORT'.

  CALL METHOD TOP->ADD_TEXT
    EXPORTING
      TEXT      = LV_TOP
      SAP_STYLE = 'HEADING'.
*     to move to next line
  CALL METHOD TOP->NEW_LINE.
*  DATA(LV_S) = '-' .
  IF CATEGORY IS NOT INITIAL AND GROUP IS NOT INITIAL.
    CONCATENATE CATEGORY GROUP INTO LV_CAT SEPARATED BY '-' .

  ELSEIF GROUP IS NOT INITIAL .
    LV_CAT = GROUP .
  ELSEIF CATEGORY IS NOT INITIAL .
    LV_CAT = CATEGORY .

  ENDIF.



*  CONCATENATE  CATEGORY LV_GP INTO LV_CAT .  "SEPARATED BY '-' .
  CALL METHOD TOP->ADD_TEXT
    EXPORTING
      TEXT      = LV_CAT
      SAP_STYLE = 'HEADING'.

ENDFORM .
