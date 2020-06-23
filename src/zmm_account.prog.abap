*&---------------------------------------------------------------------*
*& Report ZMM_ACCOUNT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_ACCOUNT.

TABLES  : BSEG , BKPF ,LFA1 .

TYPES: BEGIN OF TY_BSEG,
       bukrs   TYPE bukrs,
       belnr   TYPE belnr_d,
       gjahr   TYPE gjahr,
       buzei   TYPE buzei,
       lifnr   TYPE bseg-lifnr,
       h_budat TYPE budat,
       shkzg   TYPE shkzg,
       dmbtr   TYPE dmbtr,
       sgtxt   TYPE sgtxt,
       KOART    TYPE   KOART ,
      END OF TY_BSEG,

      BEGIN OF TY_BKPF,
          bukrs TYPE bukrs,
          belnr TYPE belnr_d,
          gjahr TYPE gjahr,
          BLART TYPE 	BLART ,
        END OF TY_BKPF ,

        BEGIN OF TY_LFA1,
          LIFNR TYPE LIFNR    ,
           NAME1 TYPE NAME1_GP ,
          END OF TY_LFA1 .


DATA: f_name TYPE rs38l_fnam.

DATA: it_fieldcat  TYPE TABLE OF slis_fieldcat_alv,
      it_fieldcat1 TYPE TABLE OF slis_fieldcat_alv,
      wa_fieldcat  TYPE slis_fieldcat_alv,
      wa_layout    TYPE slis_layout_alv,
      it_events    TYPE slis_t_event,
      wa_events    LIKE LINE OF it_events,
      it_sort      TYPE slis_t_sortinfo_alv,
      wa_sort      TYPE slis_sortinfo_alv.


 DATA : IT_BSEG TYPE TABLE OF TY_BSEG ,
       WA_BSEG TYPE TY_BSEG ,
       IT_BKPF TYPE TABLE OF TY_BKPF,
       WA_BKPF TYPE TY_BKPF ,
       IT_LFA1 TYPE TABLE OF TY_LFA1,
       WA_LFA1 TYPE TY_LFA1,
       IT_FINAL TYPE TABLE OF ZIMP_ACCOUNT ,
       WA_FINAL TYPE ZIMP_ACCOUNT,
       IT_ITEM TYPE TABLE OF ZIMP_ACCOUNTITEM ,
       WA_ITEM TYPE ZIMP_ACCOUNTITEM.
*        it_item = DATA(lt_item) .
       DATA : LS_ITEM TYPE I .
*DATA : WA_FINAL-H_BUDAT.


SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
  PARAMETERS : P_BUKRS TYPE  BSEG-BUKRS ,
               P_LIFNR TYPE  BSEG-LIFNR ,
               P_GJAHR TYPE  BSEG-GJAHR .
  SELECT-OPTIONS : S_BUDAT FOR BSEG-H_BUDAT .

  SELECTION-SCREEN : END OF BLOCK b1.

  START-OF-SELECTION .

  SELECT
    bukrs
    belnr
    gjahr
    buzei
    lifnr
    h_budat
    shkzg
    dmbtr
    sgtxt
    KOART
    FROM BSEG INTO TABLE IT_BSEG
    WHERE bukrs = P_BUKRS AND lifnr = P_LIFNR AND gjahr = P_GJAHR AND H_BUDAT IN S_BUDAT .""AND koart = 'K' .

    IF IT_BSEG IS NOT INITIAL.
      SELECT
        bukrs
        belnr
        gjahr

        FROM BKPF INTO TABLE IT_BKPF FOR ALL ENTRIES IN IT_BSEG WHERE BUKRS = IT_BSEG-BUKRS

       AND  BLART  IN ('RE' , 'ZH' , 'KR') .

      ENDIF.

     IF IT_BSEG IS NOT INITIAL .
       SELECT
         LIFNR
          NAME1
         FROM LFA1 INTO TABLE IT_LFA1 FOR ALL ENTRIES IN IT_BSEG WHERE LIFNR = IT_BSEG-LIFNR .

         ENDIF.

         END-OF-SELECTION.

*DATA  : LV_CREDIT TYPE DMBTR ,
*       LV_DEBIT TYPE DMBTR ,
      DATA : LV_CREDIT_TOT TYPE DMBTR ,
             LV_DEBIT_TOT TYPE DMBTR .
*         SORT it_bseg BY h_budat .

    LOOP AT IT_BSEG INTO WA_BSEG .
      WA_FINAL-BUKRS = WA_BSEG-BUKRS .
      WA_FINAL-LIFNR = WA_BSEG-LIFNR .
      WA_FINAL-GJAHR = WA_BSEG-GJAHR .
      WA_FINAL-H_BUDAT = WA_BSEG-H_BUDAT.
      WA_FINAL-OPBALANCE = WA_ITEM-TOTDEBIT - WA_ITEM-CREDIT .
      WA_ITEM-BELNR = WA_BSEG-BELNR .
      WA_ITEM-H_BUDAT = WA_BSEG-H_BUDAT.
      WA_ITEM-SGTXT = WA_BSEG-SGTXT .

      IF WA_BSEG-KOART EQ 'K' .
        IF WA_BSEG-SHKZG EQ 'H' .
            WA_ITEM-CREDIT = WA_BSEG-DMBTR .
            ELSEIF WA_BSEG-SHKZG EQ 'S'.
              WA_ITEM-DEBIT = WA_BSEG-DMBTR * ( -1 ).
            ENDIF.
        ENDIF.
        WA_ITEM-BALANCE = WA_FINAL-OPBALANCE - WA_ITEM-DEBIT - WA_ITEM-CREDIT .

      READ TABLE IT_LFA1 INTO WA_LFA1 WITH KEY LIFNR = WA_BSEG-LIFNR .
    IF SY-SUBRC = 0.
        WA_FINAL-NAME1 = WA_LFA1-NAME1 .
    ENDIF.
      READ TABLE IT_BKPF INTO WA_BKPF WITH  KEY GJAHR = WA_BSEG-GJAHR .
      IF SY-SUBRC = 0.
        WA_FINAL-BLART = WA_BKPF-BLART .

        ENDIF.
    LV_credit_tot = LV_credit_tot + wa_item-credit.
    WA_ITEM-TOTCREDIT = LV_credit_tot .

    LV_DEBIT_TOT = LV_DEBIT_TOT + WA_ITEM-DEBIT .
    WA_ITEM-TOTDEBIT = LV_DEBIT_TOT .


     APPEND wa_item TO it_item.
    CLEAR wa_item.
      ENDLOOP.


*    DATA : t_line        LIKE wa_FINAL-info.
*
*       wa_FINAL-typ  = 'S'.
*  wa_FINAL-key = 'Date: '.
*
*  CONCATENATE  sy-datum+6(2) '.'
*               sy-datum+4(2) '.'
*               sy-datum(4) INTO wa_FINAL-info.   "todays date
*  APPEND WA_FINAL TO IT_FINAL.
*  CLEAR: WA_FINAL.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
     I_CALLBACK_PROGRAM                = sy-repid
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE                      =
*     I_GRID_SETTINGS                   =
     IS_LAYOUT                         = wa_layout
     IT_FIELDCAT                       = it_fieldcat
*     IT_EXCLUDING                      =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT                           =
*     IT_FILTER                         =
*     IS_SEL_HIDE                       =
*     I_DEFAULT                         = 'X'
*     I_SAVE                            = ' '
*     IS_VARIANT                        =
*     IT_EVENTS                         =
*     IT_EVENT_EXIT                     =
*     IS_PRINT                          =
*     IS_REPREP_ID                      =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0
*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   =
*     IT_HYPERLINK                      =
*     IT_ADD_FIELDCAT                   =
*     IT_EXCEPT_QINFO                   =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER           =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      T_OUTTAB                          = it_item
   EXCEPTIONS
     PROGRAM_ERROR                     = 1
     OTHERS                            = 2
            .
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  FORM get_fieldcat .

  CONSTANTS: lc_lifnr   TYPE slis_fieldname VALUE 'LIFNR',
             lc_belnr   TYPE slis_fieldname VALUE 'BELNR',
             lc_budat   TYPE slis_fieldname VALUE 'H_BUDAT',
             lc_sgtxt   TYPE slis_fieldname VALUE 'SGTXT',
*             lc_gsber   TYPE slis_fieldname VALUE 'GSBER',
             lc_koart   TYPE slis_fieldname VALUE 'KOART',
*             lc_bldat   TYPE slis_fieldname VALUE 'BLDAT',
             lc_debit   TYPE slis_fieldname VALUE 'DEBIT',
             lc_credit  TYPE slis_fieldname VALUE 'CREDIT',
             lc_tabname TYPE slis_tabname   VALUE 'IT_SELDATA'.

  PERFORM get_line_fieldcat USING  'SEL'      lc_tabname 'SELECT' 2.
  PERFORM get_line_fieldcat USING  lc_lifnr   lc_tabname 'Vendor' 12.
  PERFORM get_line_fieldcat USING  lc_budat   lc_tabname 'Posting  Date' 25.
  PERFORM get_line_fieldcat USING  lc_sgtxt   lc_tabname 'Particulars' 10.
  PERFORM get_line_fieldcat USING  lc_koart   lc_tabname 'Account Type' 35.
  PERFORM get_line_fieldcat USING  lc_belnr   lc_tabname 'Document No' 15.
*  PERFORM get_line_fieldcat USING  lc_bldat   lc_tabname 'Bill Date' 25.
  PERFORM get_line_fieldcat USING  lc_debit   lc_tabname 'Debit' 10.
  PERFORM get_line_fieldcat USING  lc_credit  lc_tabname 'Credit' 10.


ENDFORM.

FORM get_line_fieldcat  USING p_field   TYPE slis_fieldname
                              p_tabname TYPE slis_tabname
                              p_seltext TYPE slis_fieldcat_alv-seltext_l
                              p_outlen  TYPE slis_fieldcat_alv-outputlen.

  STATICS:  l_col_pos TYPE slis_fieldcat_alv-col_pos.
  ADD 1 TO l_col_pos.

  wa_fieldcat-col_pos        = l_col_pos.
  wa_fieldcat-fieldname      = p_field.
  wa_fieldcat-tabname        = p_tabname.
  wa_fieldcat-seltext_l      = p_seltext.
  wa_fieldcat-outputlen      = p_outlen.



  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

ENDFORM.

FORM top-of-page..

  DATA: t_header      TYPE slis_t_listheader,
        wa_header     TYPE slis_listheader,
        t_line        LIKE wa_header-info,
        lv_name1      TYPE name1,
        ld_lines      TYPE i,
        ld_linesc(10) TYPE c,
        lv_top(255)   TYPE c.


  wa_header-typ  = 'S' .
  wa_header-key = 'Date: '.

  CONCATENATE  sy-datum+6(2) '.'
               sy-datum+4(2) '.'
               sy-datum(4) INTO wa_header-info.   "todays date
  APPEND wa_header TO t_header.
  CLEAR: wa_header.

  wa_header-typ  = 'T' .
  wa_header-key = 'Time: '.
  CONCATENATE  Sy-uzeit+2(2) ':'

              Sy-uzeit(2) INTO wa_header-info.   "todays date
  APPEND wa_header TO t_header.
  CLEAR: wa_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_header.
ENDFORM.

*CALL FUNCTION 'ZMM_CONF_ACCOUNT'
*  EXPORTING
*    COMPANYCODE          = WA_FINAL-BUKRS .
*    VENDOR               = WA_FINAL-LIFNR .
*    POSTINGDATE          = WA_FINAL-H_BUDAT .
*    FISCALYEAR           = WA_FINAL-GJAHR .
* IMPORTING
*   DATE                 =  SY-DATUM.
*   TIME                 = SY-UZEIT.
*   POSTING              = WA_FINAL-H_BUDAT .
*   ACCOUNT              = WA_FINAL-LIFNR.
*   NAME                 = WA_FINAL-NAME1 .
*   OPNEINGBALANCE       = WA_FINAL-OPBALANCE.
*   DOCNUMBER            = WA_ITEM-BELNR.
*   PARTICULERS          = WA_ITEM-SGTXT.
*   DEBIT                = WA_ITEM-DEBIT.
*   CREDIT               = WA_ITEM-CREDIT.
*   BALANCE              = WA_ITEM-BALANCE.
*   FICISAL              = WA-FINAL-GJAHR .
*   COMPANY              = WA_FINAL-BUKRS.
*   DOCTYPE              = WA_FINAL-BLART.
**   AMT_IND              =
**   TEXT                 =
**   ACCTYPE              =
**   BEBIT_IND            =
          .

          .
