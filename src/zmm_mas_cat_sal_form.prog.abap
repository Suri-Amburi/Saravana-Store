*&---------------------------------------------------------------------*
*& Include          ZMM_MAS_CAT_SAL_FORM
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

  BREAK BREDDY .
*  IF S_PLANT IS NOT INITIAL AND S_MATKL IS NOT INITIAL.

    SELECT
     MARA~MATNR ,
     MARA~MATKL ,
*       MARD~WERKS ,
     MBEW~BWKEY ,
     MBEW~LBKUM ,
     MBEW~SALK3  INTO TABLE @GT_DATA
     FROM MARA AS MARA
*    INNER JOIN MARD AS MARD ON MARA~MATNR = MARD~MATNR
     INNER JOIN MBEW AS MBEW ON MARA~MATNR = MBEW~MATNR
*      FOR ALL ENTRIES IN @IT_MARA
     WHERE MARA~MATKL IN @S_MATKL
    AND  MBEW~BWKEY IN ('SSCP' , 'SSPO' , 'SSPU' , 'SSTN' , 'SSWH' )
*     AND MBEW~BWKEY IN @S_PLANT
     AND MBEW~LBKUM <> '0'
     AND BWTAR = ' ' .
*endif .
*  ELSEIF  S_PLANT IS NOT INITIAL AND S_MATKL IS INITIAL.
*    SELECT
*      MARA~MATNR ,
*      MARA~MATKL ,
**    MARD~WERKS ,
*      MBEW~BWKEY ,
*      MBEW~LBKUM ,
*      MBEW~SALK3  INTO TABLE @GT_DATA
*      FROM MARA AS MARA
**    INNER JOIN MARD AS MARD ON MARA~MATNR = MARD~MATNR
*      INNER JOIN MBEW AS MBEW ON MARA~MATNR = MBEW~MATNR
**      FOR ALL ENTRIES IN @IT_MARA
*        WHERE MARA~MATKL IN @S_MATKL
*        AND  MBEW~BWKEY IN @S_PLANT
**      AND MBEW~BWKEY = 'SSWH'
*        AND MBEW~LBKUM <> '0'
*        AND BWTAR = ' ' .
*  ELSEIF  S_PLANT IS  INITIAL AND S_MATKL IS INITIAL.
*    SELECT
*      MARA~MATNR ,
*      MARA~MATKL ,
**    MARD~WERKS ,
*      MBEW~BWKEY ,
*      MBEW~LBKUM ,
*      MBEW~SALK3  INTO TABLE @GT_DATA
*      FROM MARA AS MARA
**    INNER JOIN MARD AS MARD ON MARA~MATNR = MARD~MATNR
*      INNER JOIN MBEW AS MBEW ON MARA~MATNR = MBEW~MATNR
**      FOR ALL ENTRIES IN @IT_MARA
**        WHERE MARA~MATKL IN @S_MATKL
*       WHERE  MBEW~BWKEY IN ('SSCP' , 'SSPO' , 'SSPU' , 'SSTN' , 'SSWH' )
**      AND MBEW~BWKEY = 'SSWH'
*        AND MBEW~LBKUM <> '0'
*        AND BWTAR = ' ' .
*
*  ENDIF .
  DATA : LV_AMT TYPE SALK3 .
*  DATA(GT_DATA1) = GT_DATA[] .
  SORT GT_DATA BY MATKL BWKEY.
*  DELETE ADJACENT DUPLICATES FROM GT_DATA1 COMPARING MATKL BWKEY .
*  LOOP AT GT_DATA1 ASSIGNING FIELD-SYMBOL(<GS_DATA1>).
*    WA_FINAL-MATKL = <GS_DATA1>-MATKL .
*    WA_FINAL-BWKEY = <GS_DATA1>-BWKEY .

    LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<GS_DATA>) . ""WHERE MATKL = <GS_DATA1>-MATKL AND BWKEY = <GS_DATA1>-BWKEY.
      WA_FINAL-MATKL = <GS_DATA>-MATKL .
      WA_FINAL-BWKEY = <GS_DATA>-BWKEY .
      WA_FINAL-LBKUM = <GS_DATA>-LBKUM .
      WA_FINAL-SALK3 = <GS_DATA>-SALK3 .
*      LV_AMT  = LV_AMT + <GS_DATA>-SALK3 .
      APPEND WA_FINAL TO IT_FINAL .
      CLEAR : WA_FINAL .

*    ENDLOOP.


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
  WA_FIELDCAT-FIELDNAME = 'MATKL'.
  WA_FIELDCAT-SELTEXT_M = 'Group'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.


  WA_FIELDCAT-FIELDNAME = 'BWKEY'.
  WA_FIELDCAT-SELTEXT_M = 'Plant'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  WA_FIELDCAT-FIELDNAME = 'LBKUM'.
  WA_FIELDCAT-SELTEXT_M = 'Quantity'.
  WA_FIELDCAT-DO_SUM = 'X'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  WA_FIELDCAT-FIELDNAME = 'SALK3'.
  WA_FIELDCAT-SELTEXT_M = 'Amount'.
  WA_FIELDCAT-DO_SUM = 'X'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

*FORM CALC_SUBTOT .
  WA_SORT-FIELDNAME = 'MATKL'.
  WA_SORT-UP = 'X'.
  WA_SORT-SUBTOT = 'X '.
  WA_SORT-TABNAME = 'IT_FINAL' .
  APPEND WA_SORT TO IT_SORT .
  CLEAR WA_SORT .
*
  WA_SORT-FIELDNAME = 'BWKEY'.
  WA_SORT-UP = 'X'.
  WA_SORT-SUBTOT = 'X '.
  WA_SORT-TABNAME = 'IT_FINAL' .
  APPEND WA_SORT TO IT_SORT .
  CLEAR : WA_SORT .
*ENDFORM.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_BUFFER_ACTIVE    = ' '
      I_CALLBACK_PROGRAM = SY-REPID
      IS_LAYOUT          = WA_LAYOUT
*     I_CALLBACK_HTML_TOP_OF_PAGE = 'TOP_OF_PAGE'
      IT_FIELDCAT        = IT_FIELDCAT
      IT_SORT            = IT_SORT
      I_DEFAULT          = 'X'
      I_SAVE             = 'A'
*     IS_VARIANT         = WVARI
    TABLES
      T_OUTTAB           = IT_FINAL
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
