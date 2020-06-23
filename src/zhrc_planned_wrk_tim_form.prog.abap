*&---------------------------------------------------------------------*
*& Include          ZHRC_PLANNED_WRK_TIM_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

if p_file IS NOT INITIAL .
****FM for BOM Data***********
    call function 'TEXT_CONVERT_XLS_TO_SAP'
      exporting
*       I_FIELD_SEPERATOR    =
        i_line_header        = 'X'
        i_tab_raw_data       = it_type
        i_filename           = p_file
      tables
        i_tab_converted_data = gt_data
      exceptions
        conversion_failed    = 1
        others               = 2.

    if sy-subrc <> 0.
* Implement suitable error handling here
    endif.
   ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM bdc_data .

  if p_file IS NOT INITIAL.
    if gt_data is not initial.

      loop at gt_data into wa_data.
        perform bdc_dynpro      using 'SAPMP50A' '1000'.
        perform bdc_field       using 'BDC_OKCODE'
                              '=INS'.
        perform bdc_field       using 'RP50G-PERNR'
                              wa_data-pernr. " emp no
        perform bdc_field       using 'RP50G-TIMR6'
                              'X'.
        perform bdc_field       using 'BDC_CURSOR'
                              'RP50G-SUBTY'.
        perform bdc_field       using 'RP50G-CHOIC'
                              '7'.        "Fixed
        perform bdc_dynpro      using 'MP000700' '2000'.
        perform bdc_field       using 'BDC_CURSOR'
                              'P0007-SCHKZ'.

        perform bdc_field       using 'BDC_OKCODE'
                              'UPD'.
        perform bdc_field       using 'P0007-BEGDA'
                              wa_data-begda.
        perform bdc_field       using 'P0007-ENDDA'
                              wa_data-endda.
       perform bdc_field       using 'P0007-SCHKZ'
                              wa_data-schkz.
       perform bdc_field       using 'P0007-ZTERF'
                              wa_data-zterf.
*       perform bdc_field       using 'P0007-EMPCT'
*                              '  100.00'.

       refresh: it_messtab.
        call transaction 'PA30' using it_bdcdata
                         mode   ctumode
                         update cupdate
                         messages into it_messtab.
        refresh it_bdcdata.


        loop at it_messtab into wa_messtab.

          wa_log-PERNR = wa_data-PERNR.

          call function 'FORMAT_MESSAGE'
            exporting
              id        = wa_messtab-msgid
              lang      = 'E'
              no        = wa_messtab-msgnr
              v1        = wa_messtab-msgv1
              v2        = wa_messtab-msgv2
              v3        = wa_messtab-msgv3
              v4        = wa_messtab-msgv4
            importing
              msg       = wa_log-msg_text
            exceptions
              not_found = 1
              others    = 2.
          if sy-subrc <> 0.
* Implement suitable error handling here
          endif.

          move-corresponding wa_messtab to wa_log.
          append wa_log to it_log.
          clear : wa_log, wa_data.
        endloop.

     ENDLOOP.

    endif.

    endif.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_DYNPRO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM bdc_dynpro  USING program dynpro.


  clear wa_bdcdata.
  wa_bdcdata-program  = program.
  wa_bdcdata-dynpro   = dynpro.
  wa_bdcdata-dynbegin = 'X'.
  append wa_bdcdata to it_bdcdata.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form BDC_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM bdc_field  USING fnam fval.

    if fval is not initial.
    clear wa_bdcdata.
    wa_bdcdata-fnam = fnam.
    wa_bdcdata-fval = fval.

    SHIFT wa_bdcdata-fval LEFT DELETING LEADING space.
    append wa_bdcdata to it_bdcdata.
ENDIF.
ENDFORM.


FORM fieldcatlog_design.

  if P_FILE IS NOT INITIAL.
    perform create_fieldcat using:

         '01' '01' 'PERNR'    'IT_LOG' 'L' 'EMPLOYEE_NO',
         '01' '02' 'TCODE'    'IT_LOG' 'L' 'TCODE',
         '01' '03' 'DYNAME'   'IT_LOG' 'L' 'DYNAME',
         '01' '04' 'DYNUMB'   'IT_LOG' 'L' 'DYNUMB',
         '01' '05' 'MSGTYP'   'IT_LOG' 'L' 'MSGTYP',
         '01' '06' 'MSGSPRA'  'IT_LOG' 'L' 'MSGSPRA',
         '01' '07' 'MSGID'    'IT_LOG' 'L' 'MSGID',
         '01' '08' 'MSGNR'    'IT_LOG' 'L' 'MSGNR',
         '01' '09' 'MSGV1'    'IT_LOG' 'L' 'MSGV1',
         '01' '10' 'MSGV2'    'IT_LOG' 'L' 'MSGV2',
         '01' '11' 'MSGV3'    'IT_LOG' 'L' 'MSGV3',
         '01' '12' 'MSGV4'    'IT_LOG' 'L' 'MSGV4',
         '01' '13' 'ENV'      'IT_LOG' 'L' 'ENV',
         '01' '14' 'FLDNAME'  'IT_LOG' 'L' 'FLDNAME',
         '01' '15' 'MSG_TEXT'  'IT_LOG' 'L' 'MESSAGE'.

  ENDIF.



ENDFORM.

*&---------------------------------------------------------------------*
*& Form CREATE_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM create_fieldcat  USING  fp_rowpos    type sycurow
                            fp_colpos    type sycucol
                            fp_fldnam    type fieldname
                            fp_tabnam    type tabname
                            fp_justif    type char1
                            fp_seltext   type dd03p-scrtext_l.

data: wa_fcat    type  slis_fieldcat_alv.
  wa_fcat-row_pos        =  fp_rowpos.     "Row
  wa_fcat-col_pos        =  fp_colpos.     "Column
  wa_fcat-fieldname      =  fp_fldnam.     "Field Name
  wa_fcat-tabname        =  fp_tabnam.     "Internal Table Name
  wa_fcat-just           =  fp_justif.     "Screen Justified
  wa_fcat-seltext_l      =  fp_seltext.    "Field Text

  append wa_fcat to it_fieldcat.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display .
   data: l_repid type syrepid .

  if p_file IS NOT INITIAL.

    if it_log is not initial.

      wa_layout-zebra = 'X'.
      wa_layout-colwidth_optimize = 'X'.

      call function 'REUSE_ALV_GRID_DISPLAY'
        exporting
*         I_INTERFACE_CHECK  = ' '
*         I_BYPASSING_BUFFER = ' '
*         I_BUFFER_ACTIVE    = ' '
*         i_callback_program = l_repid
*         I_CALLBACK_PF_STATUS_SET          = ' '
*         I_CALLBACK_USER_COMMAND           = ' '
*         I_CALLBACK_TOP_OF_PAGE            = ' '
*         I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*         I_CALLBACK_HTML_END_OF_LIST       = ' '
*         I_STRUCTURE_NAME   =
*         I_BACKGROUND_ID    = ' '
*         I_GRID_TITLE  =
*         I_GRID_SETTINGS    =
          is_layout     = wa_layout
          it_fieldcat   = it_fieldcat
*         IT_EXCLUDING  =
*         IT_SPECIAL_GROUPS  =
*         IT_SORT       =
*         IT_FILTER     =
*         IS_SEL_HIDE   =
*         I_DEFAULT     = 'X'
          i_save        = 'X'
*         IS_VARIANT    =
*         IT_EVENTS     =
*         IT_EVENT_EXIT =
*         IS_PRINT      =
*         IS_REPREP_ID  =
*         I_SCREEN_START_COLUMN             = 0
*         I_SCREEN_START_LINE               = 0
*         I_SCREEN_END_COLUMN               = 0
*         I_SCREEN_END_LINE  = 0
*         I_HTML_HEIGHT_TOP  = 0
*         I_HTML_HEIGHT_END  = 0
*         IT_ALV_GRAPHICS    =
*         IT_HYPERLINK  =
*         IT_ADD_FIELDCAT    =
*         IT_EXCEPT_QINFO    =
*         IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*         E_EXIT_CAUSED_BY_CALLER           =
*         ES_EXIT_CAUSED_BY_USER            =
        tables
          t_outtab      = it_log
        exceptions
          program_error = 1
          others        = 2.
      if sy-subrc <> 0.
* MESSAGE 'ERROR IN ALV DISPLAY'(010) TYPE 'I'.
      endif.
    endif.
    endif.


ENDFORM.
