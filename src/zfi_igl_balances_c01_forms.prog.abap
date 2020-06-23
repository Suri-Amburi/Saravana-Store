*&---------------------------------------------------------------------*
*& Include          ZFI_IGL_BALANCES_C01_FORMS
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  GET_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_FILE  text
*----------------------------------------------------------------------*
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

    DELETE fp_i_exceltab FROM 1 TO 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


  ELSE.
    MESSAGE e398(00) WITH 'INVALID FILE TYPE'  .            "#EC *

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
         lv_date1    TYPE char8,
         lv_date2    TYPE char8,
         lv_date3    TYPE char8,
         lv_date4    TYPE char8,
         lv_sno      TYPE i VALUE 2,
         lw_exceltab TYPE ty_exceltab.
*********************************************************

  DATA: wa_extension TYPE bapiextc,
        it_extension TYPE STANDARD TABLE OF bapiextc.

***********************************************


  LOOP AT fp_i_exceltab INTO lw_exceltab.
    lv_sno = lv_sno + 1.

    REPLACE ALL OCCURRENCES OF '.' IN lw_exceltab-bldat    WITH '/'.
    REPLACE ALL OCCURRENCES OF '-' IN lw_exceltab-bldat    WITH '/'.
    REPLACE ALL OCCURRENCES OF '.' IN lw_exceltab-budat    WITH '/'.
    REPLACE ALL OCCURRENCES OF '-' IN lw_exceltab-budat    WITH '/'.
    REPLACE ALL OCCURRENCES OF '.' IN lw_exceltab-valdate  WITH '/'.
    REPLACE ALL OCCURRENCES OF '-' IN lw_exceltab-valdate  WITH '/'.
    REPLACE ALL OCCURRENCES OF '.' IN lw_exceltab-valdate2 WITH '/'.
    REPLACE ALL OCCURRENCES OF '-' IN lw_exceltab-valdate2 WITH '/'.

    SPLIT lw_exceltab-bldat AT '/' INTO lv_monc lv_datc lv_year.
    lv_mon = lv_monc.
    lv_dat = lv_datc.
    CONCATENATE lv_year lv_dat lv_mon  INTO lv_date1.
    CONDENSE lv_date1.
    CLEAR : lv_year, lv_mon, lv_dat, lv_monc, lv_datc.

    SPLIT lw_exceltab-budat AT '/' INTO lv_monc lv_datc lv_year.
    lv_mon = lv_monc.
    lv_dat = lv_datc.
    CONCATENATE lv_year lv_dat lv_mon  INTO lv_date2.
    CONDENSE lv_date2.
    CLEAR : lv_year, lv_mon, lv_dat, lv_monc, lv_datc.

    SPLIT lw_exceltab-valdate AT '/' INTO lv_monc lv_datc lv_year.
    lv_mon = lv_monc.
    lv_dat = lv_datc.
    CONCATENATE lv_year lv_dat lv_mon  INTO lv_date3.
    CONDENSE lv_date3.
    CLEAR : lv_year, lv_mon, lv_dat, lv_monc, lv_datc.

    SPLIT lw_exceltab-valdate2 AT '/' INTO lv_monc lv_datc lv_year.
    lv_mon = lv_monc.
    lv_dat = lv_datc.
    CONCATENATE lv_year lv_dat lv_mon  INTO lv_date4.
    CONDENSE lv_date4.
    CLEAR : lv_year, lv_mon, lv_dat, lv_monc, lv_datc.

    wa_header-username = sy-uname.
    wa_header-header_txt = lw_exceltab-bktxt.
    wa_header-comp_code = lw_exceltab-bukrs.
    wa_header-doc_date = lv_date1."LW_EXCELTAB-BLDAT.
    wa_header-pstng_date = lv_date2."LW_EXCELTAB-BUDAT.
    wa_header-doc_type = lw_exceltab-blart.
    wa_header-ref_doc_no = lw_exceltab-xblnr.


    wa_curr-itemno_acc = '1'.
    wa_curr-currency = lw_exceltab-waers.
    wa_curr-exch_rate = lw_exceltab-kursf.
*    CONCATENATE '-' LW_EXCELTAB-WRBTR INTO LW_EXCELTAB-WRBTR.
*    CONDENSE LW_EXCELTAB-WRBTR.
    IF lw_exceltab-newbs = '50'.
      lw_exceltab-wrbtr = lw_exceltab-wrbtr * -1.
    ELSE.
      lw_exceltab-wrbtr = lw_exceltab-wrbtr.
    ENDIF.
*    LW_EXCELTAB-WRBTR = LW_EXCELTAB-WRBTR * -1.

    wa_curr-amt_doccur = lw_exceltab-wrbtr.
    APPEND wa_curr TO i_curr.
    CLEAR wa_curr.


    wa_curr-itemno_acc = '2'.
    wa_curr-currency = lw_exceltab-waers.
    wa_curr-exch_rate = lw_exceltab-kursf.
    IF lw_exceltab-newbs2 = '50'.
      wa_curr-amt_doccur = lw_exceltab-wrbtr2 * -1.
    ELSE.
      wa_curr-amt_doccur = lw_exceltab-wrbtr2.
    ENDIF.
*    WA_CURR-AMT_DOCCUR = LW_EXCELTAB-WRBTR2.
    APPEND wa_curr TO i_curr.
    CLEAR wa_curr.

    wa_item-itemno_acc = '1'.
    wa_item-gl_account = lw_exceltab-newko.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_item-gl_account
      IMPORTING
        output = wa_item-gl_account.

    wa_item-comp_code = lw_exceltab-bukrs.
    wa_item-pstng_date = lv_date2."LW_EXCELTAB-BUDAT.
    wa_item-doc_type = lw_exceltab-blart.
    wa_item-alloc_nmbr = lw_exceltab-zuonr.
    wa_item-item_text = lw_exceltab-sgtxt.
    wa_item-costcenter = lw_exceltab-kostl.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_item-costcenter
      IMPORTING
        output = wa_item-costcenter.

    wa_item-orderid = lw_exceltab-aufnr.
    wa_item-profit_ctr = lw_exceltab-prctr.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_item-profit_ctr
      IMPORTING
        output = wa_item-profit_ctr.

    wa_item-plant = lw_exceltab-werks.
    WA_ITEM-BUS_AREA = lw_exceltab-gsber2.
*    wa_item-PARTNER_SEGMENT = lv_date3.
    APPEND wa_item TO i_item.
    CLEAR wa_item.


    wa_item-itemno_acc = '2'.
    wa_item-gl_account = lw_exceltab-newko2.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_item-gl_account
      IMPORTING
        output = wa_item-gl_account.

    wa_item-comp_code = lw_exceltab-bukrs.
    wa_item-pstng_date = lv_date2."LW_EXCELTAB-BUDAT.
    wa_item-doc_type = lw_exceltab-blart.
    wa_item-alloc_nmbr = lw_exceltab-zuonr2.
    wa_item-item_text = lw_exceltab-sgtxt2.
    wa_item-costcenter = lw_exceltab-kostl2.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_item-costcenter
      IMPORTING
        output = wa_item-costcenter.

*    wa_item-orderid = lw_exceltab-aufnr2.
    wa_item-profit_ctr = lw_exceltab-prctr2.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_item-profit_ctr
      IMPORTING
        output = wa_item-profit_ctr.

    wa_item-plant = lw_exceltab-werks2.
*    wa_item-PARTNER_SEGMENT = lv_date4.
    WA_ITEM-BUS_AREA = lw_exceltab-gsber2.

    APPEND wa_item TO i_item.
    CLEAR wa_item.

***    wa_extension-field1 = '0000000001'.
***    wa_extension-field2 = lv_date3.
***    APPEND wa_extension TO it_extension.
***    CLEAR wa_extension.
***
***    wa_extension-field1 = '0000000002'.
***    wa_extension-field2 = lv_date4.
***    APPEND wa_extension TO it_extension.
***    CLEAR wa_extension.
***
***    CLEAR:lv_date3,lv_date4.

    CALL FUNCTION 'BAPI_ACC_GL_POSTING_POST'
      EXPORTING
        documentheader = wa_header
*     IMPORTING
*       OBJ_TYPE       =
*       OBJ_KEY        =
*       OBJ_SYS        =
      TABLES
        accountgl      = i_item
        currencyamount = i_curr
        return         = i_msgt
*        extension1     = it_extension.
    .

    LOOP AT i_msgt INTO wa_msg.
      IF wa_msg-type EQ 'E'.
        wa_errmsg-sno = lv_sno.
        wa_errmsg-msgtyp = wa_msg-type.
        wa_errmsg-xblnr = wa_header-ref_doc_no.
        wa_errmsg-bktxt = wa_header-header_txt.
        wa_errmsg-messg = wa_msg-message.
        APPEND wa_errmsg TO i_errmsg.
        CLEAR wa_errmsg.
        CLEAR wa_msg.

      ELSEIF wa_msg-type EQ 'S'.
        DATA : lv_str1 TYPE string VALUE 'Document',
               lv_str2 TYPE string,
               lv_str3 TYPE string VALUE 'was posted in company code',
               lv_str4 TYPE string.

        lv_str2 = wa_msg-message_v2+0(10).
        lv_str4 = wa_msg-message_v2+10(4).

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = lv_str2
          IMPORTING
            output = lv_str2.

        CONCATENATE lv_str1 lv_str2 lv_str3 lv_str4 INTO wa_errmsg-messg SEPARATED BY space.

        wa_errmsg-sno = lv_sno.
        wa_errmsg-msgtyp = wa_msg-type.
        wa_errmsg-xblnr = wa_header-ref_doc_no.
        wa_errmsg-bktxt = wa_header-header_txt.
        wa_errmsg-docnum = lv_str2.
        APPEND wa_errmsg TO i_errmsg.
        CLEAR : lv_str2, lv_str4.
        CLEAR wa_errmsg.
        CLEAR wa_msg.
      ENDIF.
    ENDLOOP.

    CLEAR : lv_date1, lv_date2,
            lw_exceltab,
            wa_header.

    REFRESH: i_item[],
             i_curr[],
             i_msgt[],
            it_extension[].

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'
*     IMPORTING
*       RETURN        =
      .

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

*  READ TABLE FP_I_ERRMSG INTO WA_ERRMSG WITH KEY MSGTYP = 'E'.
*  IF SY-SUBRC = 0.
*    MESSAGE I398(00) WITH 'GL ACCOUNT UPLOADED WITH ERRORS'.
  PERFORM build_fieldcat CHANGING i_fieldcatalog.

*    ELSE.
*      MESSAGE I398(00) WITH 'GL ACCOUNT UPLOADED SUCCESSFULLY'.
*      PERFORM BUILD_FIELDCAT CHANGING I_FIELDCATALOG.
*
*  ENDIF.

ENDFORM.                    " ERRMSG
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_FIELDCATALOG  text
*----------------------------------------------------------------------*
FORM build_fieldcat  CHANGING fp_i_fieldcat TYPE slis_t_fieldcat_alv.

  PERFORM fieldcat USING '1' 'SNO' 'LINE NO' '8' CHANGING fp_i_fieldcat.
  PERFORM fieldcat USING '3' 'XBLNR' 'REFERENCE' '16' CHANGING fp_i_fieldcat.
  PERFORM fieldcat USING '4' 'BKTXT' 'DOCUMENT HEADER TEXT' '25' CHANGING fp_i_fieldcat.
  PERFORM fieldcat USING '5' 'MESSG' 'MESSAGES LOG' '200' CHANGING fp_i_fieldcat.
  PERFORM fieldcat USING '2' 'DOCNUM' 'DOCUMENT NUMBER' '20' CHANGING fp_i_fieldcat.

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
      text      = 'RETURN MESSAGES LOG'
      sap_style = 'HEADING'.


ENDFORM. " TOP_OF_PAGE
