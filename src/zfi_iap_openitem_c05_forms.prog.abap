*&---------------------------------------------------------------------*
*& Include          ZFI_IAP_OPENITEM_C05_FORMS
*&---------------------------------------------------------------------*
FORM get_filename  CHANGING fp_p_file TYPE localfile.

  DATA: li_filetable    TYPE filetable,
        lx_filetable    TYPE file_table,
        lv_return_code  TYPE i,
        lv_window_title TYPE string.

  lv_window_title = TEXT-002.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = lv_window_title
*     DEFAULT_EXTENSION       =
*     DEFAULT_FILENAME        =
*     FILE_FILTER             =
*     WITH_ENCODING           =
*     INITIAL_DIRECTORY       =
*     MULTISELECTION          =
    CHANGING
      file_table              = li_filetable
      rc                      = lv_return_code
*     USER_ACTION             =
*     FILE_ENCODING           =
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  READ TABLE   li_filetable INTO lx_filetable INDEX 1.
*
  fp_p_file = lx_filetable-filename.



*  SPLIT FILENAME AND EXTENSION NAME TO VALIDATE FILETYPE
  SPLIT fp_p_file AT '.' INTO fname ename.
  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE ename TO UPPER CASE.

ENDFORM.                    " GET_FILENAME


*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_EXCELTAB  text
*----------------------------------------------------------------------*
FORM get_data  CHANGING fp_i_exceltab TYPE ty_t_exceltab.

  DATA : li_temp     TYPE TABLE OF alsmex_tabline,
         lw_temp     TYPE alsmex_tabline,
         lw_exceltab TYPE ty_exceltab,
         lv_mat      TYPE matnr,
         lw_intern   TYPE  kcde_cells,
         li_intern   TYPE STANDARD TABLE OF kcde_cells,
         lv_index    TYPE i,
         i_type      TYPE truxs_t_text_data.


*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ename EQ 'XLSX' OR ename EQ 'XLS'.

    REFRESH fp_i_exceltab[].


*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
*       I_FIELD_SEPERATOR    =
*       I_LINE_HEADER        =
        i_tab_raw_data       = i_type
        i_filename           = p_file
      TABLES
        i_tab_converted_data = fp_i_exceltab[]
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.

    DELETE fp_i_exceltab INDEX 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


  ELSE.
    MESSAGE e398(00) WITH 'Invalid File Type'  .            "#EC *

*
  ENDIF.


ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_EXCELTAB  text
*----------------------------------------------------------------------*
FORM process_data  USING    fp_i_exceltab TYPE ty_t_exceltab.

  DATA : lv_count    TYPE i,
         lv_datc     TYPE char2,
         lv_dat      TYPE numc2,
         lv_monc     TYPE char2,
         lv_mon      TYPE numc2,
         lv_year     TYPE char4,
         lv_date     TYPE char8,
         lv_date1    TYPE char8,
         lv_date2    TYPE char8,
         lv_sno      TYPE i VALUE 1,
         lw_exceltab TYPE ty_exceltab.

  DATA:wa_documentheader TYPE bapiache09,
       wa_accountgl      TYPE bapiacgl09,
       wa_accountpayable TYPE bapiacap09,
       wa_currencyamount TYPE bapiaccr09,
       wa_return         TYPE bapiret2,

       i_accountgl       TYPE TABLE OF bapiacgl09,
       i_accountpayable  TYPE TABLE OF bapiacap09,
       i_currencyamount  TYPE TABLE OF bapiaccr09,
       i_return          TYPE TABLE OF bapiret2.

*BREAK-POINT.
  LOOP AT fp_i_exceltab INTO lw_exceltab.
    lv_sno = lv_sno + 1.

    REPLACE ALL OCCURRENCES OF '.' IN lw_exceltab-bldat WITH '/'.
    REPLACE ALL OCCURRENCES OF '-' IN lw_exceltab-bldat WITH '/'.
    REPLACE ALL OCCURRENCES OF '.' IN lw_exceltab-budat WITH '/'.
    REPLACE ALL OCCURRENCES OF '-' IN lw_exceltab-budat WITH '/'.

    SPLIT lw_exceltab-bldat AT '/' INTO lv_monc lv_datc lv_year.
    lv_mon = lv_monc.
    lv_dat = lv_datc.
    CONCATENATE lv_year lv_dat lv_mon INTO lv_date1.
    CONDENSE lv_date1.
    CLEAR : lv_year, lv_mon, lv_dat, lv_monc, lv_datc.

    SPLIT lw_exceltab-budat AT '/' INTO lv_monc lv_datc lv_year.
    lv_mon = lv_monc.
    lv_dat = lv_datc.
    CONCATENATE lv_year lv_dat lv_mon INTO lv_date2.
    CONDENSE lv_date2.
    CLEAR : lv_year, lv_mon, lv_dat, lv_monc, lv_datc.

*    SPLIT lw_exceltab-zfbdt AT '.' INTO lv_monc lv_datc lv_year.
*    lv_mon = lv_monc.
*    lv_dat = lv_datc.
*    CONCATENATE lv_year lv_dat lv_mon INTO lv_date.
*    CONDENSE lv_date.
*    CLEAR : lv_year, lv_mon, lv_dat, lv_monc, lv_datc.

    REFRESH : i_accountgl,
              i_accountpayable,
              i_currencyamount,
              i_return.

    CLEAR : wa_documentheader,
            wa_accountgl,
            wa_accountpayable,
            wa_currencyamount,
            wa_return.

    CONDENSE:lw_exceltab-blart,lw_exceltab-xblnr,lw_exceltab-bukrs,
             lw_exceltab-newbs,lw_exceltab-newko,lw_exceltab-wrbtr,lw_exceltab-bupla,lw_exceltab-zuonr,lw_exceltab-gsber,
             lw_exceltab-lifnr,lw_exceltab-bupla1,lw_exceltab-zuonr1,lw_exceltab-gsber1,
             lw_exceltab-zterm.


    wa_documentheader-bus_act    = 'RFBU'.
    wa_documentheader-username   = sy-uname.
    wa_documentheader-comp_code  = lw_exceltab-bukrs.
    wa_documentheader-doc_date   = lv_date1.
    wa_documentheader-pstng_date = lv_date2.
    wa_documentheader-ref_doc_no = lw_exceltab-xblnr.
    wa_documentheader-doc_type   = lw_exceltab-blart.   "'KZ'.
    wa_documentheader-header_txt = lw_exceltab-sgtxt.

    wa_accountpayable-itemno_acc  = '0000000001'.
    wa_accountpayable-vendor_no   = lw_exceltab-lifnr.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_accountpayable-vendor_no
      IMPORTING
        output = wa_accountpayable-vendor_no.

    wa_accountpayable-comp_code     = lw_exceltab-bukrs.  "31 to 38 credit(-) , 21 to 28 debit (+)
*    wa_accountpayable-sp_gl_ind     = 'A'.
    wa_accountpayable-businessplace = lw_exceltab-bupla.
    wa_accountpayable-sectioncode   = lw_exceltab-secco.
    wa_accountpayable-bus_area      = lw_exceltab-gsber.
    wa_accountpayable-alloc_nmbr    = lw_exceltab-zuonr.
    wa_accountpayable-item_text     = lw_exceltab-sgtxt.
    wa_accountpayable-bline_date    = lv_date2.
*    wa_accountpayable-pmnt_block    = lw_exceltab-zlspr.
    wa_accountpayable-pmnttrms = lw_exceltab-zterm.


    APPEND wa_accountpayable TO i_accountpayable.
    CLEAR wa_accountpayable.
    wa_currencyamount-itemno_acc = '0000000001'.
    IF lw_exceltab-newbs = 31 OR lw_exceltab-newbs = 32 OR lw_exceltab-newbs = 33 OR lw_exceltab-newbs = 34 OR
       lw_exceltab-newbs = 35 OR lw_exceltab-newbs = 36 OR lw_exceltab-newbs = 37 OR lw_exceltab-newbs = 38.

      wa_currencyamount-amt_doccur = lw_exceltab-wrbtr * -1.

    ELSE.
      wa_currencyamount-amt_doccur = lw_exceltab-wrbtr.
    ENDIF.

    wa_currencyamount-currency   = lw_exceltab-waers.
    wa_currencyamount-exch_rate = lw_exceltab-kursf.
    APPEND wa_currencyamount TO i_currencyamount.
    CLEAR wa_currencyamount.

    wa_accountgl-itemno_acc = '0000000002'.
    wa_accountgl-gl_account = lw_exceltab-newko.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_accountgl-gl_account
      IMPORTING
        output = wa_accountgl-gl_account.
    wa_accountgl-comp_code  = lw_exceltab-bukrs.
    wa_accountgl-bus_area   = lw_exceltab-gsber1.
    wa_accountgl-item_text  = lw_exceltab-sgtxt1.
    wa_accountgl-alloc_nmbr = lw_exceltab-zuonr1.
    APPEND wa_accountgl TO i_accountgl.
    CLEAR wa_accountgl.

    wa_currencyamount-itemno_acc = '0000000002'.
    IF lw_exceltab-newbs1 = 50.
      wa_currencyamount-amt_doccur = lw_exceltab-wrbtr1 * -1.
    ENDIF.

    IF lw_exceltab-newbs1 = 40.
      wa_currencyamount-amt_doccur = lw_exceltab-wrbtr1.
    ENDIF.

    wa_currencyamount-currency   = lw_exceltab-waers.
    wa_currencyamount-exch_rate = lw_exceltab-kursf.
    APPEND wa_currencyamount TO i_currencyamount.
    CLEAR wa_currencyamount.


*    BREAK-POINT.

    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
      EXPORTING
        documentheader = wa_documentheader
      TABLES
        accountgl      = i_accountgl
        accountpayable = i_accountpayable
        currencyamount = i_currencyamount
        return         = i_return.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'
* IMPORTING
*       RETURN        =
      .

    LOOP AT i_return INTO wa_return.
      IF wa_return-type EQ 'E'.
        wa_errmsg-sno = lv_sno.
        wa_errmsg-msgtyp = wa_return-type.
*        wa_errmsg-xblnr = wa_return-ref_doc_no.
*        wa_errmsg-bktxt = wa_return-header_txt.
        wa_errmsg-messg = wa_return-message.
        APPEND wa_errmsg TO i_errmsg.
        CLEAR wa_errmsg.
        CLEAR wa_msg.

      ELSEIF wa_return-type EQ 'S'.
        DATA : lv_str1 TYPE string VALUE 'Document',
               lv_str2 TYPE string,
               lv_str3 TYPE string VALUE 'was posted in company code',
               lv_str4 TYPE string.

        lv_str2 = wa_return-message_v2+0(10).
        lv_str4 = wa_return-message_v2+10(4).

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = lv_str2
          IMPORTING
            output = lv_str2.

        CONCATENATE lv_str1 lv_str2 lv_str3 lv_str4 INTO wa_errmsg-messg SEPARATED BY space.

        wa_errmsg-sno = lv_sno.
        wa_errmsg-msgtyp = wa_return-type.
*        wa_errmsg-xblnr = wa_header-ref_doc_no.
*        wa_errmsg-bktxt = wa_header-header_txt.
        wa_errmsg-docnum = lv_str2.
        APPEND wa_errmsg TO i_errmsg.
        CLEAR : lv_str2, lv_str4.
        CLEAR wa_errmsg.
        CLEAR wa_msg.
      ENDIF.
    ENDLOOP.

    CLEAR : lv_date1, lv_date2.
    CLEAR lw_exceltab.
*    CLEAR wa_header.
*    REFRESH i_item[].
*    REFRESH i_curr[].
    REFRESH i_msgt[].

  ENDLOOP.

ENDFORM.                    " PROCESS_DATA
*&---------------------------------------------------------------------*
*&      Form  ERRMSG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MSG  text
*----------------------------------------------------------------------*
FORM errmsg  USING    fp_i_errmsg TYPE ty_t_errmsg.

  PERFORM build_fieldcat CHANGING i_fieldcatalog.

ENDFORM.                    " ERRMSG
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_FIELDCATALOG  text
*----------------------------------------------------------------------*
FORM build_fieldcat  CHANGING fp_i_fieldcat TYPE slis_t_fieldcat_alv.

  PERFORM fieldcat USING '1' 'SNO'    'Line No'              '4'   CHANGING fp_i_fieldcat.
  PERFORM fieldcat USING '2' 'DOCNUM' 'Document Number'      '15'  CHANGING fp_i_fieldcat.
*  PERFORM fieldcat USING '3' 'XBLNR'  'Reference'            '16'  CHANGING fp_i_fieldcat.
*  PERFORM fieldcat USING '4' 'BKTXT'  'Document Header Text' '25'  CHANGING fp_i_fieldcat.
  PERFORM fieldcat USING '5' 'MESSG'  'Messages Log'         '80' CHANGING fp_i_fieldcat.

  PERFORM disp_errmsg USING i_errmsg.

ENDFORM.                    " BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0531   text
*      -->P_0532   text
*      -->P_0533   text
*      -->P_0534   text
*      <--P_FP_I_FIELDCATALOG  text
*----------------------------------------------------------------------*
FORM fieldcat  USING    p_pos1 TYPE sycucol
                        p_fname1 TYPE slis_fieldname
                        p_stxt1 TYPE scrtext_l
                        p_outl1 TYPE dd03p-outputlen
               CHANGING fp_i_fieldcatalog TYPE slis_t_fieldcat_alv.

  DATA : lw_fieldcat TYPE slis_fieldcat_alv.


  lw_fieldcat-col_pos = p_pos1.
  lw_fieldcat-fieldname = p_fname1.
  lw_fieldcat-seltext_l = p_stxt1.
  lw_fieldcat-tabname = 'I_ERRMSG'.
  lw_fieldcat-outputlen = p_outl1.
  APPEND lw_fieldcat TO fp_i_fieldcatalog.
  CLEAR lw_fieldcat.

ENDFORM.                    " FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  DISP_ERRMSG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ERRMSG  text
*----------------------------------------------------------------------*
FORM disp_errmsg  USING    fp_i_errmsg TYPE ty_t_errmsg.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK           = ' '
*     I_BYPASSING_BUFFER          = ' '
*     I_BUFFER_ACTIVE             = ' '
      i_callback_program          = sy-cprog
*     I_CALLBACK_PF_STATUS_SET    = ' '
*     I_CALLBACK_USER_COMMAND     = ' '
*     I_CALLBACK_TOP_OF_PAGE      = ' '
      i_callback_html_top_of_page = 'TOP_OF_PAGE'
*     I_CALLBACK_HTML_END_OF_LIST = ' '
*     I_STRUCTURE_NAME            =
*     I_BACKGROUND_ID             = ' '
*     I_GRID_TITLE                =
*     I_GRID_SETTINGS             =
*     IS_LAYOUT                   =
      it_fieldcat                 = i_fieldcatalog
*     IT_EXCLUDING                =
*     IT_SPECIAL_GROUPS           =
*     IT_SORT                     =
*     IT_FILTER                   =
*     IS_SEL_HIDE                 =
      i_default                   = 'X'
*     I_SAVE                      = ' '
*     IS_VARIANT                  =
*     IT_EVENTS                   =
*     IT_EVENT_EXIT               =
*     IS_PRINT                    =
*     IS_REPREP_ID                =
*     I_SCREEN_START_COLUMN       = 0
*     I_SCREEN_START_LINE         = 0
*     I_SCREEN_END_COLUMN         = 0
*     I_SCREEN_END_LINE           = 0
*     I_HTML_HEIGHT_TOP           = 0
*     I_HTML_HEIGHT_END           = 0
*     IT_ALV_GRAPHICS             =
*     IT_HYPERLINK                =
*     IT_ADD_FIELDCAT             =
*     IT_EXCEPT_QINFO             =
*     IR_SALV_FULLSCREEN_ADAPTER  =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER     =
*     ES_EXIT_CAUSED_BY_USER      =
    TABLES
      t_outtab                    = fp_i_errmsg
    EXCEPTIONS
      program_error               = 1
      OTHERS                      = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.                    " DISP_ERRMSG
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->TOP        text
*----------------------------------------------------------------------*
FORM top_of_page USING top TYPE REF TO cl_dd_document.      "#EC CALLED

  CALL METHOD top->add_gap    "method to provide space in heading
    EXPORTING
      width = 130.


  CALL METHOD top->add_text    "method to provide heading
    EXPORTING
      text      = 'Return Messages Log'
      sap_style = 'HEADING'.


ENDFORM. " TOP_OF_PAGE
