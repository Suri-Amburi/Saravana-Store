*&---------------------------------------------------------------------*
*& Include          ZHR_I6789_INFOTYPE_CNV_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_FILE  text
*----------------------------------------------------------------------*
FORM get_filename CHANGING fp_p_file TYPE rlgrap-filename.

  DATA: li_filetable    TYPE filetable,
        lx_filetable    TYPE file_table,
        lv_return_code  TYPE i,
        lv_window_title TYPE string.

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
FORM get_data.

  DATA : i_type  TYPE truxs_t_text_data.

*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ename EQ 'XLSX' OR ename EQ 'XLS'.

    IF p_0006 IS NOT INITIAL.
*      lv_file = p_0006.

      REFRESH:it_0006[].

      CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
        EXPORTING
*         I_FIELD_SEPERATOR    =
*         I_LINE_HEADER        =
          i_tab_raw_data       = i_type
          i_filename           = p_0006 "lv_file
        TABLES
          i_tab_converted_data = it_0006[]
        EXCEPTIONS
          conversion_failed    = 1
          OTHERS               = 2.

      DELETE it_0006[] FROM 1 TO 3.

    ELSEIF p_0007 IS NOT INITIAL.
*      lv_file = p_0007.
      BREAK vpeddienti.
      REFRESH:it_0007[].

      CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
        EXPORTING
*         I_FIELD_SEPERATOR    =
*         I_LINE_HEADER        =
          i_tab_raw_data       = i_type
          i_filename           = p_0007 "lv_file
        TABLES
          i_tab_converted_data = it_0007[]
        EXCEPTIONS
          conversion_failed    = 1
          OTHERS               = 2.

      DELETE it_0007[] FROM 1 TO 3.

    ELSEIF p_0008 IS NOT INITIAL.

      REFRESH:it_0008[].

      CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
        EXPORTING
*         I_FIELD_SEPERATOR    =
*         I_LINE_HEADER        =
          i_tab_raw_data       = i_type
          i_filename           = p_0008
        TABLES
          i_tab_converted_data = it_0008[]
        EXCEPTIONS
          conversion_failed    = 1
          OTHERS               = 2.

      DELETE it_0008[] FROM 1 TO 3.

    ELSEIF p_0009 IS NOT INITIAL.

      REFRESH:it_0009[].

      CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
        EXPORTING
*         I_FIELD_SEPERATOR    =
*         I_LINE_HEADER        =
          i_tab_raw_data       = i_type
          i_filename           = p_0009
        TABLES
          i_tab_converted_data = it_0009[]
        EXCEPTIONS
          conversion_failed    = 1
          OTHERS               = 2.

      DELETE it_0009[] FROM 1 TO 3.

    ENDIF.

  ELSE.
    MESSAGE 'Invalid File Path' TYPE 'E'.
  ENDIF.

ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  PROCESS_IT6_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_it6_data USING it_0006 TYPE gty_t_0006.

  DATA:lwa_0006 TYPE p0006.

  FIELD-SYMBOLS <fs_0006> TYPE gty_0006.

  LOOP AT it_0006 ASSIGNING <fs_0006>.
    IF <fs_0006> IS ASSIGNED.

      lwa_0006-pernr = <fs_0006>-pernr.
      lwa_0006-subty = <fs_0006>-subty.

      CONCATENATE <fs_0006>-begda+6(4) <fs_0006>-begda+3(2) <fs_0006>-begda+0(2) INTO lv_begda.
      lwa_0006-begda = lv_begda.

      CONCATENATE <fs_0006>-endda+6(4) <fs_0006>-endda+3(2)  <fs_0006>-endda+0(2) INTO lv_endda.
      lwa_0006-endda = lv_endda.

      lwa_0006-stras = <fs_0006>-stras.
      lwa_0006-locat = <fs_0006>-locat.
      lwa_0006-pstlz = <fs_0006>-pstlz.
      lwa_0006-ort01 = <fs_0006>-ort01.
      lwa_0006-ort02 = <fs_0006>-ort02.
      lwa_0006-state = <fs_0006>-state.
      lwa_0006-land1 = <fs_0006>-land1.
      lwa_0006-telnr = <fs_0006>-telnr.
      lwa_0006-busrt = <fs_0006>-busrt.

      CALL FUNCTION 'BAPI_EMPLOYEE_ENQUEUE'
        EXPORTING
          number = <fs_0006>-pernr
* IMPORTING
*         RETURN =
        .

      CALL FUNCTION 'HR_INFOTYPE_OPERATION'
        EXPORTING
          infty     = '0006'
          number    = <fs_0006>-pernr
          subtype   = '1'
*         OBJECTID  =
*         LOCKINDICATOR          =
*         VALIDITYEND            =
*         VALIDITYBEGIN          =
*         RECORDNUMBER           =
          record    = lwa_0006
          operation = 'INS'
*         TCLAS     = 'A'
*         DIALOG_MODE            = '0'
*         NOCOMMIT  =
*         VIEW_IDENTIFIER        =
*         SECONDARY_RECORD       =
        IMPORTING
          return    = gwa_return.
*         KEY       =
      .
      IF gwa_return-message IS NOT INITIAL .
        gwa_display-type = gwa_return-type.
        gwa_display-pernr = <fs_0006>-pernr.
        gwa_display-infty = '0006'.
        gwa_display-msg = gwa_return-message.
        APPEND gwa_display TO git_display.
        CLEAR gwa_display.
      ELSE.
        gwa_display-type = 'S'.
        gwa_display-pernr = <fs_0006>-pernr.
        gwa_display-infty = '0006'.
        gwa_display-msg = 'Successfully updated'.
        APPEND gwa_display TO git_display.
        CLEAR gwa_display.
      ENDIF.

      CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
        EXPORTING
          number = <fs_0006>-pernr
* IMPORTING
*         RETURN =
        .
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PROCESS_IT7_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_it7_data USING it_0007 TYPE gty_t_0007.

  DATA:lwa_0007 TYPE p0007,
       lv_pernr TYPE p0007-pernr.

  FIELD-SYMBOLS <fs_0007> TYPE gty_0007.
  BREAK vpeddienti.
  LOOP AT it_0007 ASSIGNING <fs_0007>.
    IF <fs_0007> IS ASSIGNED.

      lwa_0007-pernr = <fs_0007>-pernr.
*      w_0006-subty = <fs_0007>-subty.

      CONCATENATE <fs_0007>-begda+6(4)
             <fs_0007>-begda+3(2)
             <fs_0007>-begda+0(2)
           INTO lv_begda.
      lwa_0007-begda = lv_begda.

      CONCATENATE <fs_0007>-endda+6(4)
             <fs_0007>-endda+3(2)
             <fs_0007>-endda+0(2)
           INTO lv_endda.
      lwa_0007-endda = lv_endda.
      lwa_0007-schkz = <fs_0007>-schkz.
      lwa_0007-zterf = <fs_0007>-zterf.
      lwa_0007-empct = <fs_0007>-empct.
      lwa_0007-arbst = <fs_0007>-arbst.
      lwa_0007-wkwdy = <fs_0007>-wkwdy.

      lv_pernr = <fs_0007>-pernr.

      CALL FUNCTION 'BAPI_EMPLOYEE_ENQUEUE'
        EXPORTING
          number = lv_pernr " <fs_0007>-pernr
* IMPORTING
*         RETURN =
        .
      BREAK vpeddienti.
      CALL FUNCTION 'HR_INFOTYPE_OPERATION'
        EXPORTING
          infty     = '0007'
          number    = lv_pernr    "<fs_0007>-pernr
*         SUBTYPE   = '01'
*         OBJECTID  =
*         LOCKINDICATOR          =
*         VALIDITYEND            =
*         VALIDITYBEGIN          =
*         RECORDNUMBER           =
          record    = lwa_0007
          operation = 'INS'
*         TCLAS     = 'A'
*         DIALOG_MODE            = '0'
*         NOCOMMIT  =
*         VIEW_IDENTIFIER        =
*         SECONDARY_RECORD       =
        IMPORTING
          return    = gwa_return
*         KEY       =
        .
      IF gwa_return-message IS NOT INITIAL .
        gwa_display-type = gwa_return-type.
        gwa_display-pernr = <fs_0007>-pernr.
        gwa_display-infty = '0007'.
        gwa_display-msg = gwa_return-message.
        APPEND gwa_display TO git_display.
        CLEAR gwa_display.
      ELSE.
        gwa_display-type = 'S'.
        gwa_display-pernr = <fs_0007>-pernr.
        gwa_display-infty = '0007'.
        gwa_display-msg = 'Successfully updated'.
        APPEND gwa_display TO git_display.
        CLEAR gwa_display.
      ENDIF.

      CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
        EXPORTING
          number = lv_pernr   "<fs_0007>-pernr
* IMPORTING
*         RETURN =
        .
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PROCESS_IT8_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_it8_data USING it_0008 TYPE gty_t_0008.

  DATA:lwa_0008 TYPE p0008,
       lv_pernr TYPE p0008-pernr.

  FIELD-SYMBOLS <fs_0008> TYPE gty_0008.

  LOOP AT it_0008 ASSIGNING <fs_0008>.
    IF <fs_0008> IS ASSIGNED.
      lwa_0008-pernr = <fs_0008>-pernr.
*      w_0006-subty = wa_0007-subty.

      CONCATENATE <fs_0008>-begda+6(4)
             <fs_0008>-begda+3(2)
             <fs_0008>-begda+0(2)
           INTO lv_begda.
      lwa_0008-begda = lv_begda.

      CONCATENATE <fs_0008>-endda+6(4)
             <fs_0008>-endda+3(2)
             <fs_0008>-endda+0(2)
           INTO lv_endda.
      lwa_0008-endda = lv_endda.
      lwa_0008-trfar = <fs_0008>-trfar.
      lwa_0008-bsgrd = <fs_0008>-bsgrd.
      lwa_0008-trfgb = <fs_0008>-trfgb.
      lwa_0008-divgv = <fs_0008>-divgv.
      lwa_0008-trfgr = <fs_0008>-trfgr.
      lwa_0008-trfst = <fs_0008>-trfst.
      lwa_0008-ancur = <fs_0008>-ancur.
      lwa_0008-waers = <fs_0008>-waers.

      lwa_0008-lga01     =    <fs_0008>-lga01.
      lwa_0008-bet01     =    <fs_0008>-bet01.
      lwa_0008-lga02     =    <fs_0008>-lga02.
      lwa_0008-bet02     =    <fs_0008>-bet02.
      lwa_0008-lga03     =    <fs_0008>-lga03.
      lwa_0008-bet03     =    <fs_0008>-bet03.
      lwa_0008-lga04     =    <fs_0008>-lga04.
      lwa_0008-bet04     =    <fs_0008>-bet04.
      lwa_0008-lga05     =    <fs_0008>-lga05.
      lwa_0008-bet05     =    <fs_0008>-bet05.
      lwa_0008-lga06     =    <fs_0008>-lga06.
      lwa_0008-bet06     =    <fs_0008>-bet06.
      lwa_0008-lga07     =    <fs_0008>-lga07.
      lwa_0008-bet07     =    <fs_0008>-bet07.
      lwa_0008-lga08     =    <fs_0008>-lga08.
      lwa_0008-bet08     =    <fs_0008>-bet08.
      lwa_0008-lga09     =    <fs_0008>-lga09.
      lwa_0008-bet09     =    <fs_0008>-bet09.
      lwa_0008-lga10     =    <fs_0008>-lga10.
      lwa_0008-bet10     =    <fs_0008>-bet10.
      lwa_0008-lga11     =    <fs_0008>-lga11.
      lwa_0008-bet11     =    <fs_0008>-bet11.
      lwa_0008-lga12     =    <fs_0008>-lga12.
      lwa_0008-bet12     =    <fs_0008>-bet12.
      lwa_0008-lga13     =    <fs_0008>-lga13.
      lwa_0008-bet13     =    <fs_0008>-bet13.
      lwa_0008-lga14     =    <fs_0008>-lga14.
      lwa_0008-bet14     =    <fs_0008>-bet14.
      lwa_0008-lga15     =    <fs_0008>-lga15.
      lwa_0008-bet16     =    <fs_0008>-bet16.
      lwa_0008-lga16     =    <fs_0008>-lga16.
      lwa_0008-bet16     =    <fs_0008>-bet16.
      lwa_0008-lga17     =    <fs_0008>-lga17.
      lwa_0008-bet17     =    <fs_0008>-bet17.
      lwa_0008-lga18     =    <fs_0008>-lga18.
      lwa_0008-bet18     =    <fs_0008>-bet18.
      lwa_0008-lga19     =    <fs_0008>-lga19.
      lwa_0008-bet19     =    <fs_0008>-bet19.
      lwa_0008-lga20     =    <fs_0008>-lga20.
      lwa_0008-bet20     =    <fs_0008>-bet20.


      lv_pernr = <fs_0008>-pernr.
      CALL FUNCTION 'BAPI_EMPLOYEE_ENQUEUE'
        EXPORTING
          number = lv_pernr
* IMPORTING
*         RETURN =
        .

      CALL FUNCTION 'HR_INFOTYPE_OPERATION'
        EXPORTING
          infty     = '0008'
          number    = lv_pernr    " <fs_0008>-pernr
*         SUBTYPE   = '01'
*         OBJECTID  =
*         LOCKINDICATOR          =
*         VALIDITYEND            =
*         VALIDITYBEGIN          =
*         RECORDNUMBER           =
          record    = lwa_0008
          operation = 'INS'
*         TCLAS     = 'A'
*         DIALOG_MODE            = '0'
*         NOCOMMIT  =
*         VIEW_IDENTIFIER        =
*         SECONDARY_RECORD       =
        IMPORTING
          return    = gwa_return
*         KEY       =
        .
      IF gwa_return-message IS NOT INITIAL .
        gwa_display-type = gwa_return-type.
        gwa_display-pernr = <fs_0008>-pernr.
        gwa_display-infty = '0008'.
        gwa_display-msg = gwa_return-message.
        APPEND gwa_display TO git_display.
        CLEAR gwa_display.
      ELSE.
        gwa_display-type = 'S'.
        gwa_display-pernr = <fs_0008>-pernr.
        gwa_display-infty = '0008'.
        gwa_display-msg = 'Successfully updated'.
        APPEND gwa_display TO git_display.
        CLEAR gwa_display.
      ENDIF.

      CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
        EXPORTING
          number = lv_pernr " <fs_0008>-pernr
* IMPORTING
*         RETURN =
        .

    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PROCESS_IT9_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_it9_data USING it_0009 TYPE gty_t_0009.

  DATA:lwa_0009 TYPE p0009,
       lv_pernr TYPE PERNR_D.

  FIELD-SYMBOLS <fs_0009> TYPE gty_0009.

  LOOP AT it_0009 ASSIGNING <fs_0009>.
    IF <fs_0009> IS ASSIGNED.
      lwa_0009-pernr = <fs_0009>-pernr.
      lv_pernr = <fs_0009>-pernr.
*      w_0006-subty = wa_0007-subty.

      CONCATENATE <fs_0009>-begda+6(4)
             <fs_0009>-begda+3(2)
             <fs_0009>-begda+0(2)
           INTO lv_begda.
      lwa_0009-begda = lv_begda.

      CONCATENATE <fs_0009>-endda+6(4)
             <fs_0009>-endda+3(2)
             <fs_0009>-endda+0(2)
           INTO lv_endda.
      lwa_0009-endda = lv_endda.
      lwa_0009-bnksa = <fs_0009>-bnksa.
      lwa_0009-emftx = <fs_0009>-emftx.
      lwa_0009-bkplz = <fs_0009>-bkplz.
      lwa_0009-bkort = <fs_0009>-bkort.
      lwa_0009-banks = <fs_0009>-banks.
      lwa_0009-bankl = <fs_0009>-bankl.
      lwa_0009-bankn = <fs_0009>-bankn.
      lwa_0009-zlsch = <fs_0009>-zlsch.
      lwa_0009-waers = <fs_0009>-waers.

      CALL FUNCTION 'BAPI_EMPLOYEE_ENQUEUE'
        EXPORTING
          number = lv_pernr "<fs_0009>-pernr
* IMPORTING
*         RETURN =
        .

      CALL FUNCTION 'HR_INFOTYPE_OPERATION'
        EXPORTING
          infty     = '0009'
          number    = lv_pernr "<fs_0009>-pernr
*         SUBTYPE   = '01'
*         OBJECTID  =
*         LOCKINDICATOR          =
*         VALIDITYEND            =
*         VALIDITYBEGIN          =
*         RECORDNUMBER           =
          record    = lwa_0009
          operation = 'INS'
*         TCLAS     = 'A'
*         DIALOG_MODE            = '0'
*         NOCOMMIT  =
*         VIEW_IDENTIFIER        =
*         SECONDARY_RECORD       =
        IMPORTING
          return    = gwa_return
*         KEY       =
        .
      IF gwa_return-message IS NOT INITIAL .
        gwa_display-type = gwa_return-type.
        gwa_display-pernr = <fs_0009>-pernr.
        gwa_display-infty = '0009'.
        gwa_display-msg = gwa_return-message.
        APPEND gwa_display TO git_display.
        CLEAR gwa_display.
      ELSE.
        gwa_display-type = 'S'.
        gwa_display-pernr = <fs_0009>-pernr.
        gwa_display-infty = '0009'.
        gwa_display-msg = 'Successfully updated'.
        APPEND gwa_display TO git_display.
        CLEAR gwa_display.
      ENDIF.

      CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
        EXPORTING
          number = lv_pernr
* IMPORTING
*         RETURN =
        .

    ENDIF.
    CLEAR: lv_pernr.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_data.

  DATA :lwa_layout TYPE slis_layout_alv,
        wa_fcat    TYPE slis_fieldcat_alv,
        it_fcat    TYPE slis_t_fieldcat_alv.

  wa_fcat-fieldname = 'TYPE'.
  wa_fcat-seltext_m = 'Type'.
  wa_fcat-tabname = 'GIT_DISPLAY'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'PERNR'.
  wa_fcat-seltext_m = 'Emp Number'.
  wa_fcat-tabname = 'GIT_DISPLAY'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'INFTY'.
  wa_fcat-seltext_m = 'Infotype'.
  wa_fcat-tabname = 'GIT_DISPLAY'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'MSG'.
  wa_fcat-seltext_m = 'Message'.
  wa_fcat-tabname = 'GIT_DISPLAY'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.


  lwa_layout-zebra = 'X'.
  lwa_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
*     I_CALLBACK_PROGRAM                = ' '
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE  =
*     I_GRID_SETTINGS                   =
      is_layout     = lwa_layout
      it_fieldcat   = it_fcat
*     IT_EXCLUDING  =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT       =
*     IT_FILTER     =
*     IS_SEL_HIDE   =
      i_default     = 'X'
      i_save        = 'X'
*     IS_VARIANT    =
*     IT_EVENTS     =
*     IT_EVENT_EXIT =
*     IS_PRINT      =
*     IS_REPREP_ID  =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0
*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   =
*     IT_HYPERLINK  =
*     IT_ADD_FIELDCAT                   =
*     IT_EXCEPT_QINFO                   =
*     IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      t_outtab      = git_display
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
