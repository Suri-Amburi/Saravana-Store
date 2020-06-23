*&---------------------------------------------------------------------*
*& Include          ZFI_ACCOUNTANT_DIARY_FORM
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
*******************************upto date 30 of ssame month *******************************


*****ex: p_date = 16.04.2019(20190416) / p_date+0(4) = 2019 /p_date+4(2) = 04 / 30 lv_edate = 30.04.2019
*  BREAK BREDDY.

*  CALL FUNCTION 'HR_E_NUM_OF_DAYS_OF_MONTH'
*    EXPORTING
*      P_FECHA        = S_DATE
*    IMPORTING
*      NUMBER_OF_DAYS = LV_DAYS.
*  LV_DAY =    LV_DAYS - S_DATE+6(2) .
*
*  D = LV_DAYS.
*  CONDENSE LV_DAY .
*  CONDENSE D .
*  D = 30.
*   CONDENSE D .
*  LV_DAYS = LV_DAY .
*  CONCATENATE S_DATE+0(4) S_DATE+4(2) D INTO LV_EDATE .

******************************************************************************************
***************************************date + 30 days **************************
*  CALL FUNCTION 'FIAPPL_ADD_DAYS_TO_DATE'
*    EXPORTING
*      I_DATE      = S_DATE
*      I_DAYS      = 30
*      SIGNUM      = '+'
*    IMPORTING
*      E_CALC_DATE = LV_EDATE.`

BREAK breddy .
  LV_DAYS = 30.

*  CONDENSE LV_DAYS.

*  CONCATENATE S_DATE+0(4) S_DATE+4(2) D INTO LV_EDATE.
***************************************AMDB CLASS ***************************
*  BREAK BREDDY .
  CALL METHOD ZACOUNTING_DAIRY_AMDP=>GET_ACC_DETAIL
    EXPORTING
      LV_DATE  = LV_SDATE
      LV_DATE1 = LV_EDATE
    IMPORTING
      IT_EKKO  = IT_EKKO.
  BREAK BREDDY.
  SELECT  EBELN
          EBELP
          ZEKKN
          VGABE
          GJAHR
          BELNR
          BUZEI
          BEWTP
          LFBNR FROM EKBE INTO TABLE IT_EKBE
          FOR ALL ENTRIES IN IT_EKKO
          WHERE EBELN = IT_EKKO-EBELN
          AND EBELP = IT_EKKO-EBELP .
*          AND BELNR = IT_EKKO-MBLNR.
*          AND LFBNR = IT_EKKO-MBLNR .
*          AND BEWTP <> 'Q' .




*  SELECT  EBELN
*          EBELP
*          ZEKKN
*          VGABE
*          GJAHR
*          BELNR
*          BUZEI
*          BEWTP
*          LFBNR FROM EKBE INTO TABLE IT_EKBE1
*          FOR ALL ENTRIES IN IT_EKKO
*          WHERE EBELN = IT_EKKO-EBELN
*          AND EBELP = IT_EKKO-EBELP
*          AND BELNR = IT_EKKO-MBLNR_103.
*          AND LFBNR = IT_EKKO-MBLNR_103 .
*          AND BEWTP <> 'Q' .
  IT_EKBE1[] = IT_EKBE[] .

  DELETE IT_EKBE1 WHERE BEWTP <> 'Q'.
  LOOP AT IT_EKBE1 INTO WA_EKBE1 .
    DELETE IT_EKBE WHERE EBELN = WA_EKBE1-EBELN .
  ENDLOOP.

*  DELETE ADJACENT DUPLICATES FROM IT_EKBE COMPARING EBELN .

*  BREAK BREDDY .
  DATA :  LV_SLNO TYPE I VALUE 1  .
  DATA : LV_D TYPE SY-DATUM .
*
*CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
*  EXPORTING
*    DATE            = S_DATE
*    DAYS            = '1'
*    MONTHS          = '00'
*   SIGNUM          = '-'
*    YEARS           = 0000
* IMPORTING
*   CALC_DATE       = LV_D
  .

*  LV_D = S_DATE .
*  DO LV_DAYS  TIMES.
*
*    WA_FINAL-SLNO =  LV_SLNO .
*    LV_SLNO = LV_SLNO + 1 .
*
**        CALL FUNCTION 'FIAPPL_ADD_DAYS_TO_DATE'
**      EXPORTING
**        I_DATE      = LV_DAYS
**        I_DAYS      = 1
**        SIGNUM      = '+'
**      IMPORTING
**        E_CALC_DATE = LV_D.
**    LOOP AT  IT_EKKO ASSIGNING FIELD-SYMBOL(<LS_EKKO>).
**      <LS_EKKO>-DUE_DATE =   <LS_EKKO>-GPRO_DATE + <LS_EKKO>-ZBD1T .
**    ENDLOOP.
*    BREAK BREDDY.
**    WA_FINAL-DATE = <LS_EKKO>-DUE_DATE.
*    PERFORM AMMOUNT_TOTAL USING LV_D.
*
*    CALL FUNCTION 'FIAPPL_ADD_DAYS_TO_DATE'
*      EXPORTING
*        I_DATE      = LV_D
*        I_DAYS      = 1
*        SIGNUM      = '+'
*      IMPORTING
*        E_CALC_DATE = LV_D.
*
*    WA_FINAL-AMOUNT = LV_AMOUNT .
*    APPEND WA_FINAL TO IT_FINAL .
*    CLEAR WA_FINAL .
*  ENDDO.

*  BREAK SAMBURI.
  BREAK BREDDY.
  REFRESH : IT_FINAL.
*** For calculating Due date
  LOOP AT  IT_EKKO ASSIGNING FIELD-SYMBOL(<LS_EKKO>).
    <LS_EKKO>-DUE_DATE =   <LS_EKKO>-CREATED_DATE + <LS_EKKO>-ZBD1T .
  ENDLOOP.
  DATA(LV_COUNT) = 0.
  DO LV_DAYS  TIMES.
    WA_FINAL-SLNO = SY-INDEX.
    WA_FINAL-DATE = S_DATE + SY-INDEX - 1 .
    PERFORM AMMOUNT_TOTAL USING WA_FINAL-DATE.
    IF SY-INDEX = 1.
      LOOP AT IT_EKKO ASSIGNING <LS_EKKO> WHERE DUE_DATE LE WA_FINAL-DATE.
        ADD <LS_EKKO>-NETPR_P TO WA_FINAL-AMOUNT.
      ENDLOOP.
    ELSE.
      LOOP AT IT_EKKO ASSIGNING <LS_EKKO> WHERE DUE_DATE = WA_FINAL-DATE.
        ADD <LS_EKKO>-NETWR_P TO WA_FINAL-AMOUNT.
      ENDLOOP.
    ENDIF.
    WA_FINAL-AMOUNT = LV_AMOUNT.
    WA_FINAL-CURRENCY  = 'INR'.
    APPEND WA_FINAL TO IT_FINAL.
    CLEAR: WA_FINAL.
  ENDDO.

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
*  BREAK BREDDY.
  IF IT_FINAL IS NOT INITIAL.

    PERFORM FIELD_CAT1 USING :
          '01' '01' 'SLNO'       'IT_FINAL' 'L' 'Sl no',
          '01' '02' 'DATE'       'IT_FINAL' 'L' 'Date',
          '01' '03' 'AMOUNT'     'IT_FINAL' 'L' 'Payable Amount',
          '01' '04' 'CURRENCY'   'IT_FINAL' 'L' 'Currency' .
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form AMMOUNT_TOTAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AMMOUNT_TOTAL USING LV_D TYPE SY-DATUM  .
  CLEAR LV_AMOUNT .
  LV_S = 1 .
  LOOP AT IT_EKKO INTO WA_EKKO WHERE DUE_DATE = LV_D .
    IF WA_EKKO-BSART = 'ZLOP' .
*            DELETE IT_EKBE1 WHERE BEWTP = 'Q'.
      READ TABLE IT_EKBE1 INTO WA_EKBE1 WITH KEY EBELN = WA_EKKO-EBELN
*                                               EBELP = WA_EKKO-EBELP
*                                               BELNR = WA_EKKO-MBLNR_103.
                                               LFBNR = WA_EKKO-MBLNR_103.

      IF SY-SUBRC  = 0.
        IF WA_EKBE1 IS NOT INITIAL .

          WA_FINAL1-SLNO    = LV_S .
          LV_S = LV_S + 1 .
*          WA_FINAL1-DATE      = WA_EKKO-GPRO_DATE .
          WA_FINAL1-DATE      = WA_EKKO-CREATED_DATE + WA_EKKO-ZBD1T .
          WA_FINAL1-INWD_DOC  = WA_EKKO-INWD_DOC .
          WA_FINAL1-REC_DATE  = WA_EKKO-REC_DATE .
          WA_FINAL1-AEDAT     = WA_EKKO-AEDAT .
          WA_FINAL1-AMOUNT    = WA_EKKO-NETWR_P  .
          WA_FINAL1-CURRENCY  = WA_EKKO-WAERS .
          WA_FINAL-CURRENCY   = WA_EKKO-WAERS .
          WA_FINAL1-EBELN     = WA_EKKO-EBELN .
          WA_FINAL1-EBELP     = WA_EKKO-EBELP .
          WA_FINAL1-LIFNR     = WA_EKKO-LIFNR .
          WA_FINAL1-NAME1     = WA_EKKO-NAME1 .
          WA_FINAL1-DUE_DATE   = WA_EKKO-DUE_DATE.
          IF WA_EKKO-BSART = 'ZLOP'.
            WA_FINAL1-GRPO_NO   = WA_EKKO-MBLNR_103 .
          ELSE .
            WA_FINAL1-GRPO_NO   = WA_EKKO-MBLNR .
          ENDIF.

          WA_FINAL1-CREATED_DATE = WA_EKKO-CREATED_DATE .
*          WA_FINAL1-MATKL     = WA_EKKO-MATKL .
*          LV_AMOUNT = LV_AMOUNT + WA_EKKO-NETPR_GP .
          LV_AMOUNT = LV_AMOUNT +  WA_EKKO-NETWR_P .
          CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
            EXPORTING
              MATKL       = WA_EKKO-MATKL
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
*BREAK breddy.
*      DELETE IT_O_WGH01 WHERE MATKL EQ SPACE AND WWGHB EQ SPACE.
          READ TABLE IT_O_WGH01 INTO WA_O_WGH01 INDEX 1.
          IF SY-SUBRC = 0.

            WA_FINAL1-MATKL = WA_O_WGH01-WWGHA.

          ENDIF.


          APPEND WA_FINAL1 TO IT_FINAL1 .
          CLEAR WA_FINAL1 .
        ENDIF.
      ENDIF.
    ELSE .
*      DELETE IT_EKBE WHERE BEWTP = 'Q'.
      READ TABLE IT_EKBE INTO WA_EKBE WITH KEY EBELN = WA_EKKO-EBELN
*                                            EBELP = WA_EKKO-EBELP
*                                            BELNR = WA_EKKO-MBLNR.
                                            LFBNR = WA_EKKO-MBLNR.

      IF SY-SUBRC  = 0 .
        IF WA_EKBE IS NOT INITIAL .

          WA_FINAL1-SLNO    = LV_S .
          LV_S = LV_S + 1 .


          WA_FINAL1-DATE      = WA_EKKO-CREATED_DATE.
          WA_FINAL1-AEDAT     = WA_EKKO-AEDAT .
          WA_FINAL1-AMOUNT    = WA_EKKO-NETWR_P.
          WA_FINAL1-CURRENCY  = WA_EKKO-WAERS .
          WA_FINAL-CURRENCY   = WA_EKKO-WAERS .
          WA_FINAL1-EBELN     = WA_EKKO-EBELN .
          WA_FINAL1-EBELP     = WA_EKKO-EBELP .
          WA_FINAL1-LIFNR     = WA_EKKO-LIFNR .
          WA_FINAL1-NAME1     = WA_EKKO-NAME1 .
          WA_FINAL1-INWD_DOC      = WA_EKKO-INWD_DOC .
          WA_FINAL1-REC_DATE     = WA_EKKO-REC_DATE .
          WA_FINAL1-DUE_DATE     = WA_EKKO-DUE_DATE .
          IF WA_EKKO-BSART = 'ZLOP'.
            WA_FINAL1-GRPO_NO   = WA_EKKO-MBLNR_103 .
          ELSE .
            WA_FINAL1-GRPO_NO   = WA_EKKO-MBLNR .
          ENDIF.

          WA_FINAL1-CREATED_DATE = WA_EKKO-CREATED_DATE .
*          WA_FINAL1-MATKL     = WA_EKKO-MATKL .
          CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
            EXPORTING
              MATKL       = WA_EKKO-MATKL
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
*BREAK breddy.
*      DELETE IT_O_WGH01 WHERE MATKL EQ SPACE AND WWGHB EQ SPACE.
          READ TABLE IT_O_WGH01 INTO WA_O_WGH01 INDEX 1.
          IF SY-SUBRC = 0.
            WA_FINAL1-MATKL = WA_O_WGH01-WWGHA.
          ENDIF.
          LV_AMOUNT = LV_AMOUNT + WA_EKKO-NETWR_P .
          APPEND WA_FINAL1 TO IT_FINAL1 .

          CLEAR WA_FINAL1 .
        ENDIF.
      ENDIF.
    ENDIF.
    CLEAR : WA_EKBE , WA_EKBE1 .
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELD_CAT1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FIELD_CAT .

  IF IT_FINAL IS NOT INITIAL.
    WA_LAYOUT-ZEBRA = 'X'.
    WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        I_BUFFER_ACTIVE         = ' '
        I_CALLBACK_PROGRAM      = SY-REPID
        I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
        IS_LAYOUT               = WA_LAYOUT
        IT_FIELDCAT             = IT_FIELDCAT
        I_SAVE                  = 'X'
      TABLES
        T_OUTTAB                = IT_FINAL
      EXCEPTIONS
        PROGRAM_ERROR           = 1
        OTHERS                  = 2.
    IF SY-SUBRC <> 0.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELD_CAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM FIELD_CAT1  USING     FP_ROWPOS    TYPE SYCUROW
                            FP_COLPOS    TYPE SYCUCOL
                            FP_FLDNAM    TYPE FIELDNAME
                            FP_TABNAM    TYPE TABNAME
                            FP_JUSTIF    TYPE CHAR1
                            FP_SELTEXT   TYPE DD03P-SCRTEXT_L.

  DATA: WA_FCAT    TYPE  SLIS_FIELDCAT_ALV.
  WA_FCAT-ROW_POS        =  FP_ROWPOS.     "Row
  WA_FCAT-COL_POS        =  FP_COLPOS.     "Column
  WA_FCAT-FIELDNAME      =  FP_FLDNAM.     "Field Name
  WA_FCAT-TABNAME        =  FP_TABNAM.     "Internal Table Name
  WA_FCAT-JUST           =  FP_JUSTIF.     "Screen Justified
  WA_FCAT-SELTEXT_L      =  FP_SELTEXT.    "Field Text
*  WA_FCAT-SUBTOT         =  'X'.
  APPEND WA_FCAT TO IT_FIELDCAT.
  CLEAR WA_FCAT.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM USER_COMMAND USING  SY-UCOMM
                      RS_SELFIELD TYPE SLIS_SELFIELD.

  CASE SY-UCOMM.
    WHEN '&IC1'.
*      BREAK BREDDY.
      IF  RS_SELFIELD-FIELDNAME = 'DATE'  AND RS_SELFIELD-VALUE <> ' '.
        IT_FINAL2[] = IT_FINAL1[] .
        DATA : LV_DATE TYPE SY-DATUM .

        CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
          EXPORTING
            DATE_EXTERNAL            = RS_SELFIELD-VALUE
*           ACCEPT_INITIAL_DATE      =
          IMPORTING
            DATE_INTERNAL            = LV_DATE
          EXCEPTIONS
            DATE_EXTERNAL_IS_INVALID = 1
            OTHERS                   = 2.
        IF SY-SUBRC <> 0.
* Implement suitable error handling here
        ENDIF.

        DELETE IT_FINAL2 WHERE DUE_DATE <> LV_DATE.



***            it_final3[] = it_final2[] .
***            sort it_final2 by ebeln ebelp .
***            delete ADJACENT DUPLICATES FROM it_final2 COMPARING ebeln ebelp .
***            LOOP AT it_final2 into wa_final2.
***              LOOP AT it_final3 into wa_final3 where ebeln = wa_final2-ebeln and ebelp = wa_final2-ebelp .
***                MOVE-CORRESPONDING wa_final2 TO wa_final3 .
***                ADD WA_FINAL3-AMOUNT TO amount .
***
***              ENDLOOP.
***              wa_final3-amount = amount  .
***              APPEND wa_final3 to it_final3 .
***              clear wa_final3 .
***
***            ENDLOOP.
        PERFORM DISPLAY1 .
        PERFORM BUILD_CAT .
      ENDIF .
  ENDCASE.
  REFRESH : IT_FINAL2 , IT_FIELDCAT1 .
ENDFORM .
*&---------------------------------------------------------------------*
*& Form DISPLAY1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY1 .
  IF IT_FINAL1 IS NOT INITIAL.

    PERFORM FIELD_CA1 USING :
          '01' '01' 'SLNO'       'IT_FINAL1' 'L' 'Sl No',
          '01' '02' 'DUE_DATE'       'IT_FINAL1' 'L' 'Due Date',
          '01' '03' 'EBELN'      'IT_FINAL1' 'L' 'PO Number',
          '01' '04' 'AEDAT'      'IT_FINAL1' 'L' 'PO Date' ,
          '01' '05' 'INWD_DOC'   'IT_FINAL1' 'L' 'Inward Doc',
          '01' '06' 'REC_DATE'   'IT_FINAL1' 'L' 'Inward Date',
          '01' '07' 'GRPO_NO'    'IT_FINAL1' 'L' 'GR Number',
          '01' '08' 'CREATED_DATE'  'IT_FINAL1' 'L' 'GR Date' ,
          '01' '09' 'MATKL'      'IT_FINAL1' 'L' 'Group',
          '01' '10' 'LIFNR'      'IT_FINAL1' 'L' 'Vendor',
          '01' '11' 'NAME2'      'IT_FINAL1' 'L' 'Vendor Name',
          '01' '12' 'AMOUNT'     'IT_FINAL1' 'L' 'Amount' ,
          '01' '13' 'CURRENCY'   'IT_FINAL1' 'L' 'Currency' .

*    APPEND WA_FIELDCAT TO IT_FIELDCAT.
*    CLEAR WA_FIELDCAT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BUILD_CAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BUILD_CAT .
  WA_LAYOUT1-ZEBRA = 'X'.
  WA_LAYOUT1-COLWIDTH_OPTIMIZE = 'X'.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_BUFFER_ACTIVE    = ' '
      I_CALLBACK_PROGRAM = SY-REPID
*     I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
      IS_LAYOUT          = WA_LAYOUT1
      IT_FIELDCAT        = IT_FIELDCAT1
      I_SAVE             = 'X'
    TABLES
      T_OUTTAB           = IT_FINAL2
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
  IF SY-SUBRC <> 0.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELD_CA1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM FIELD_CA1  USING     FP_ROWPOS    TYPE SYCUROW
                            FP_COLPOS    TYPE SYCUCOL
                            FP_FLDNAM    TYPE FIELDNAME
                            FP_TABNAM    TYPE TABNAME
                            FP_JUSTIF    TYPE CHAR1
                            FP_SELTEXT   TYPE DD03P-SCRTEXT_L.


  DATA: WA_FCAT    TYPE  SLIS_FIELDCAT_ALV.
  WA_FCAT-ROW_POS        =  FP_ROWPOS.     "Row
  WA_FCAT-COL_POS        =  FP_COLPOS.     "Column
  WA_FCAT-FIELDNAME      =  FP_FLDNAM.     "Field Name
  WA_FCAT-TABNAME        =  FP_TABNAM.     "Internal Table Name
  WA_FCAT-JUST           =  FP_JUSTIF.     "Screen Justified
  WA_FCAT-SELTEXT_L      =  FP_SELTEXT.    "Field Text
*  WA_FCAT-DO_SUM         =  'X'.
*  WA_FCAT-DO_SUM         =  DO_SUM .
*  IF WA_FCAT-FIELDNAME = ' AMOUNT ' .
*    DO_SUM        = 'X'.
*  ENDIF.
  APPEND WA_FCAT TO IT_FIELDCAT1.

  CLEAR WA_FCAT.
ENDFORM.
