*&---------------------------------------------------------------------*
*& Include          ZGOODS_REPORT_MAINFORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form ZGOODS_REPORT_GETDATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ZGOODS_REPORT_GETDATA .
  SELECT
  BWART
   MBLNR
   BUDAT
   CPUDT
   BLDAT
   SGTXT
   BKTXT
   USNAM
   ZEILE
   MATBF
   MENGE
   MEINS
   WERKS
   EBELN
  LGORT_SID
  CHARG_SID
  FROM MATDOC  INTO TABLE IT_MATDOC
  WHERE MBLNR IN S_DOCN AND BUDAT IN S_GRN  AND BWART = '101' .

  IF IT_MATDOC IS NOT INITIAL .

    SELECT
      WERKS
      NAME1
      FROM T001W INTO TABLE IT_T001W
      FOR ALL ENTRIES IN IT_MATDOC WHERE WERKS = IT_MATDOC-WERKS .

      SELECT
        EBELN
        EKGRP
        LIFNR
        SPRAS
        FROM EKKO INTO TABLE IT_EKKO
        FOR ALL ENTRIES IN IT_MATDOC WHERE EBELN = IT_MATDOC-EBELN .

        ENDIF.
    IF IT_EKKO IS   NOT INITIAL.
      SELECT
         MATNR
         SPRAS
         MAKTX
        FROM MAKT INTO TABLE IT_MAKT
        FOR ALL ENTRIES IN IT_EKKO WHERE SPRAS = IT_EKKO-SPRAS .

        SELECT
          LIFNR
          NAME1
          FROM LFA1 INTO TABLE IT_LFA1
          FOR ALL ENTRIES IN IT_EKKO WHERE LIFNR = IT_EKKO-LIFNR .

          SELECT
             EKGRP
            EKNAM
            FROM T024 INTO TABLE IT_T024
            FOR ALL ENTRIES IN IT_EKKO WHERE EKGRP = IT_EKKO-EKGRP .

      endif .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ZGOODS_REPORT_PROCESSDATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ZGOODS_REPORT_PROCESSDATA .
*   BREAK-POINT .
      LOOP AT IT_MATDOC INTO WA_MATDOC .
        WA_HEADER-MBLNR = WA_MATDOC-MBLNR .
          WA_HEADER-BUDAT = WA_MATDOC-BUDAT .
        WA_HEADER-CPUDT = WA_MATDOC-CPUDT .
        WA_HEADER-BLDAT = WA_MATDOC-BLDAT .
        WA_HEADER-SGTXT = WA_MATDOC-SGTXT .
        WA_HEADER-BKTXT = WA_MATDOC-BKTXT .
        WA_HEADER-USNAM = WA_MATDOC-USNAM .
        WA_HEADER-WERKS = WA_MATDOC-WERKS .
        WA_HEADER-EBELN = WA_MATDOC-EBELN .

        READ TABLE IT_T001W INTO WA_T001W WITH KEY  WERKS = WA_MATDOC-WERKS .
        IF SY-SUBRC = 0 .
        WA_HEADER-NAME1 = WA_T001W-NAME1 .
       ENDIF.

       IF SY-SUBRC = 0 .
        READ TABLE IT_EKKO INTO WA_EKKO WITH KEY  EBELN = WA_MATDOC-EBELN .
        WA_HEADER-LIFNR = WA_EKKO-LIFNR .
        WA_HEADER-EKGRP = WA_EKKO-EKGRP .
        ENDIF.

       IF SY-SUBRC = 0 .
        READ TABLE IT_LFA1 INTO WA_LFA1 WITH KEY LIFNR = WA_EKKO-LIFNR .
        WA_HEADER-NAME = WA_LFA1-NAME1 .
       ENDIF.

      IF SY-SUBRC = 0 .
        READ TABLE IT_T024 INTO WA_T024 WITH KEY  EKGRP = WA_EKKO-EKGRP .
        WA_HEADER-EKNAM = WA_T024-EKNAM .
      ENDIF.
       PAGE = PAGE1 + 1 .
       WA_HEADER-PAGE = PAGE .

      ENDLOOP.
 BREAK-POINT .
     LOOP AT IT_MATDOC INTO WA_MATDOC .
       WA_FINAL-ZEILE = WA_MATDOC-ZEILE .
       WA_FINAL-MATBF = WA_MATDOC-MATBF .
       WA_FINAL-MENGE = WA_MATDOC-MENGE .
       WA_FINAL-MEINS = WA_MATDOC-MEINS .
       WA_FINAL-LGORT_SID = WA_MATDOC-LGORT_SID .
       WA_FINAL-CHARG_SID  = WA_MATDOC-CHARG_SID .
       WA_FINAL-SY_DATUM = SYST-DATUM .

       READ TABLE IT_MAKT INTO WA_MAKT WITH KEY SPRAS = WA_EKKO-SPRAS .
       IF SY-SUBRC = 0 .
       WA_FINAL-MAKTX = WA_MAKT-MAKTX .
       ENDIF.



       APPEND WA_FINAL TO IT_FINAL .
    CLEAR WA_FINAL.

       ENDLOOP.

       DATA : FM_NAME TYPE RS38L_FNAM.

       CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
         EXPORTING
           FORMNAME                 = 'ZGOODS_RECEIPT'
*          VARIANT                  = ' '
          DIRECT_CALL              = ' '
        IMPORTING
          FM_NAME                  = FM_NAME
        EXCEPTIONS
          NO_FORM                  = 1
          NO_FUNCTION_MODULE       = 2
          OTHERS                   = 3
                 .
       IF SY-SUBRC <> 0.
* Implement suitable error handling here
       ENDIF.



        CALL FUNCTION FM_NAME
          EXPORTING
            WA_HEADER = WA_HEADER
          TABLES
            IT_FINAL  = IT_FINAL.

ENDFORM.
