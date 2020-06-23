FUNCTION ZMERCHANDISE_HIER_DET.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(ET_DISPLAY) TYPE  ZMAT_DISP_TT
*"----------------------------------------------------------------------

*  DATA: IT_O_WGH01  TYPE TABLE OF WGH01,
**        IT_MARA     TYPE TABLE OF MARA,
**        WA_MARA     TYPE  MARA,
*        WA_O_WGH01  TYPE WGH01,
  DATA : WA_MER_DISP TYPE ZMER_DISP .
*        LV_NAME     TYPE THEAD-TDNAME,
*        LV_NAME1    TYPE THEAD-TDNAME,
*        IT_LINES    TYPE TABLE OF TLINE WITH HEADER LINE.
**  BREAK BREDDY.
***  SELECT MARA~MATNR, MARA~MATKL FROM MARA INTO TABLE @DATA(IT_MARA) WHERE ERSDA BETWEEN @IM_DATE_FROM AND @IM_DATE_TO. "OR LAEDA BETWEEN @IM_DATE_FROM AND @IM_DATE_TO .
*****  SELECT SINGLE * FROM WGH01 INTO  WA_O_WGH01 WHERE MATKL = wa_MARA-MATKL.
***  LOOP AT IT_MARA ASSIGNING FIELD-SYMBOL(<WA_MARA>).
***
***    CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
***      EXPORTING
***        MATKL       = <WA_MARA>-MATKL
***        SPRAS       = SY-LANGU
***      TABLES
***        O_WGH01     = IT_O_WGH01
***      EXCEPTIONS
***        NO_BASIS_MG = 1
***        NO_MG_HIER  = 2
***        OTHERS      = 3.
***    IF SY-SUBRC <> 0.
**** Implement suitable error handling here
***    ENDIF.
***
***    READ TABLE IT_O_WGH01 INTO WA_O_WGH01 INDEX 1.
***    IF SY-SUBRC = 0.
***
***      WA_MER_DISP-GROUP_ID = WA_O_WGH01-WWGHA.
***      WA_MER_DISP-GROUP_DESC = WA_O_WGH01-WWGHB.
***
***    ENDIF.
***    APPEND WA_MER_DISP TO ET_DISPLAY.
***    CLEAR : WA_MER_DISP.
*
**BREAK BREDDY.
*  SELECT * FROM T023T INTO TABLE @DATA(LT_T023T) WHERE SPRAS = @SY-LANGU.
*  IF SY-SUBRC EQ 0.
*    LOOP AT LT_T023T ASSIGNING FIELD-SYMBOL(<LS_T023T>).
*      CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
*        EXPORTING
*          MATKL       = <LS_T023T>-MATKL
*          SPRAS       = SY-LANGU
*        TABLES
*          O_WGH01     = IT_O_WGH01
*        EXCEPTIONS
*          NO_BASIS_MG = 1
*          NO_MG_HIER  = 2
*          OTHERS      = 3.
*      IF SY-SUBRC <> 0.
** Implement suitable error handling here
*      ENDIF.
**BREAK breddy.
**      DELETE IT_O_WGH01 WHERE MATKL EQ SPACE AND WWGHB EQ SPACE.
*      READ TABLE IT_O_WGH01 INTO WA_O_WGH01 INDEX 1.
*      IF SY-SUBRC = 0.
*
*        WA_MER_DISP-GROUP_ID = WA_O_WGH01-WWGHA.
*        WA_MER_DISP-GROUP_DESC = WA_O_WGH01-WWGHB.
*      ENDIF.
**      BREAK BREDDY.
*      refresh :IT_LINES[].
*
*      clear lv_name1.
*       IF WA_O_WGH01-WWGHA  IS NOT INITIAL.
*      CONCATENATE '026' WA_O_WGH01-WWGHA INTO LV_NAME1.
*
*        CALL FUNCTION 'READ_TEXT'
*          EXPORTING
**           CLIENT                  = SY-MANDT
*            ID                      = '0000'
*            LANGUAGE                = 'E'
*            NAME                    = LV_NAME1
*            OBJECT                  = 'KLAT'
**           ARCHIVE_HANDLE          = 0
**           LOCAL_CAT               = ' '
**       IMPORTING
**           HEADER                  =
**           OLD_LINE_COUNTER        =
*          TABLES
*            LINES                   = IT_LINES[]
*          EXCEPTIONS
*            ID                      = 1
*            LANGUAGE                = 2
*            NAME                    = 3
*            NOT_FOUND               = 4
*            OBJECT                  = 5
*            REFERENCE_CHECK         = 6
*            WRONG_ACCESS_TO_ARCHIVE = 7
*            OTHERS                  = 8.
*        IF SY-SUBRC <> 0.
** Implement suitable error handling here
*        ENDIF.
*
*        LOOP AT IT_LINES.
*
*          CONCATENATE IT_LINES-TDLINE WA_MER_DISP-PG_DESC INTO WA_MER_DISP-PG_DESC.
*          CLEAR IT_LINES .
*
*        ENDLOOP.
*      ENDIF.
*      IF WA_MER_DISP-GROUP_DESC CA '*'.
*
*      ELSE .
*
*        APPEND WA_MER_DISP TO ET_DISPLAY.
*        CLEAR : WA_MER_DISP.
*      ENDIF.
*
*    ENDLOOP.
*
*    DELETE ET_DISPLAY WHERE GROUP_ID IS INITIAL AND GROUP_DESC IS INITIAL.
*    SORT ET_DISPLAY BY GROUP_ID.
*    DELETE ADJACENT DUPLICATES FROM ET_DISPLAY COMPARING GROUP_ID.
*
*
*
*
*  ENDIF.

         SELECT
         KLAH~KLART,
         KLAH~WWSKZ,
         KLAH~CLASS  FROM KLAH INTO TABLE @DATA(IT_KLAH)
                     WHERE KLART = '026'
                     AND   WWSKZ = '0' .


  IF IT_KLAH IS NOT INITIAL.

    SELECT
      T024~EKGRP,
      T024~EKNAM FROM T024 INTO TABLE @DATA(IT_T024)
                 FOR ALL ENTRIES IN @IT_KLAH
                 WHERE EKNAM = @IT_KLAH-CLASS .

  ENDIF.

  LOOP AT IT_KLAH ASSIGNING FIELD-SYMBOL(<LS_KLAH>).

    WA_MER_DISP-GROUP_ID   = <LS_KLAH>-CLASS .
    WA_MER_DISP-GROUP_DESC = <LS_KLAH>-CLASS .


    READ TABLE IT_T024 ASSIGNING FIELD-SYMBOL(<LS_T024>) WITH KEY EKNAM = <LS_KLAH>-CLASS .
    IF SY-SUBRC = 0.

      WA_MER_DISP-PG_DESC = <LS_T024>-EKGRP .

    ENDIF.

    APPEND WA_MER_DISP TO ET_DISPLAY .
    CLEAR  WA_MER_DISP .
  ENDLOOP.





ENDFUNCTION.
