*&---------------------------------------------------------------------*
*& Include          ZMM_SOURCE_LIST_C06_SUB
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form GET_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      <--P_P_FILE  text
*&---------------------------------------------------------------------*
form get_filename  changing p_p_file.

  data: li_filetable    type filetable,    "FILENAMETABLE
        lx_filetable    type file_table,   "FILETABLE
        lv_return_code  type i,
        lv_window_title type string.

  call method cl_gui_frontend_services=>file_open_dialog
    exporting
      window_title            = lv_window_title
    changing
      file_table              = li_filetable
      rc                      = lv_return_code
    exceptions
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      others                  = 5.

  read table  li_filetable into lx_filetable index 1.
  p_p_file = lx_filetable-filename.


  split p_p_file at '.' into fname ename.
  set locale language sy-langu.
  translate ename to upper case.

endform.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      <--P_GIT_FILE  text
*&---------------------------------------------------------------------*
form get_data  changing p_git_file.

  data : i_type    type truxs_t_text_data.

  data:lv_file type rlgrap-filename.


*****  PROCEED ONLY IF ITS A VALID FILETYPE.

  if ename eq 'XLSX' or ename eq 'XLS'.

    refresh git_file[].

    lv_file = p_file.

*****   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL.

    call function 'TEXT_CONVERT_XLS_TO_SAP'
      exporting
        i_tab_raw_data       = i_type
        i_filename           = lv_file
      tables
        i_tab_converted_data = git_file[]
      exceptions
        conversion_failed    = 1
        others               = 2.


    delete git_file from 1 to 2.

  else.
    message e398(00) with 'Invalid File Type'  .
  endif.

  if git_file is initial.
    message 'No records to upload' type 'E'.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_GIT_FILE  text
*&---------------------------------------------------------------------*
form process_data  using    p_git_file.

  data: fld(20)  type c,
        fld1(20) type c,
        fld2(20) type c,
        fld3(20) type c,
        fld4(20) type c,
        fld5(20) type c,
        fld6(20) type c,
        fld7(20) type c,
        fld8(20) type c,
        fld9(20) type c,
        cnt(2)   type n,
        cnt1(2)  type n,
        msg_text type string.

  sort git_file[] by matnr. " werks vornr.

  git_file_d[] = git_file_i[] = git_file[].

  delete adjacent duplicates from git_file comparing matnr." werks.
*  delete adjacent duplicates from git_file_i comparing matnr .

*BREAK TBAREKAR.
  loop at git_file into gwa_file.                           "LOOP all records and pass one by one to BDC



    perform bdc_dynpro      using 'SAPLMEOR' '0200'.
    perform bdc_field       using 'BDC_CURSOR'
                            'EORD-MATNR'.
    perform bdc_field       using 'BDC_OKCODE'
                            '/00'.
    perform bdc_field       using 'EORD-MATNR'
                            gwa_file-matnr.
    perform bdc_field       using 'EORD-WERKS'
                            gwa_file-werks.

    clear cnt1.
    loop at git_file_i into gwa_file_i where matnr = gwa_file-matnr.

      cnt = cnt + 1.

*    cnt1 = cnt1 + 1.
      perform bdc_dynpro      using 'SAPLMEOR' '0205'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'EORD-AUTET(01)'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '/00'.

      clear fld1.
      concatenate   'EORD-VDATU('cnt')' into fld1.
      condense fld1.

      clear fld2.
      concatenate   'EORD-BDATU('cnt')' into fld2.
      condense fld2.

      clear fld3.
      concatenate   'EORD-LIFNR('cnt')' into fld3.
      condense fld3.

      clear fld4.
      concatenate   'EORD-EKORG('cnt')' into fld4.
      condense fld4.

*        CLEAR fld5.
*        CONCATENATE   'EORD-RESWK('cnt')' INTO fld5.
*        CONDENSE fld5.

      clear fld5.
      concatenate   'EORD-MEINS('cnt')' into fld5.
      condense fld5.

      clear fld6.
      concatenate   'RM06W-FESKZ('cnt')' into fld6.
      condense fld6.

        CLEAR fld7.
        CONCATENATE   'EORD-NOTKZ('cnt')' INTO fld7.
        CONDENSE fld7.

      clear fld8.
      concatenate   'EORD-AUTET('cnt')' into fld8.
      condense fld8.



      perform bdc_field       using  fld1
                                     gwa_file_i-vdatu.
      perform bdc_field       using  fld2
                                     gwa_file_i-bdatu.
      "start for umesh code

*      clear:lv_sortl,lv_lifnr.
*      lv_sortl   = gwa_file-lifnr.
*      select single lifnr from lfa1 into lv_lifnr where sortl = lv_sortl.

      perform bdc_field       using  fld3
                                     gwa_file_i-lifnr.
*                                     lv_lifnr.

      "end of code

      perform bdc_field       using  fld4
                                     gwa_file_i-ekorg.
      perform bdc_field       using  fld5
                                     gwa_file_i-meins.
      perform bdc_field       using  fld6
                                     gwa_file_i-feskz.
      perform bdc_field       using  fld7
                                     gwa_file_i-NOTKZ.
      perform bdc_field       using  fld8
                                     gwa_file_i-autet.
      CLEAR:gwa_file_i.
    endloop.

    perform bdc_dynpro      using 'SAPLMEOR' '0205'.
    perform bdc_field       using 'BDC_CURSOR'
                                   'EORD-VDATU(01)'.
    perform bdc_field       using 'BDC_OKCODE'
                                    '=BU'.

    call transaction 'ME01'  using  it_bdcdata            "table field structure
                             mode   ctumode               "N- No Screen Mode
                             update cupdate               "S-Synchronous
                             messages into it_msgcoll.    "Collecting messages in the SAP System
    refresh it_bdcdata.

    loop at it_msgcoll into wa_msgcoll.

      call function 'FORMAT_MESSAGE'
        exporting
          id        = wa_msgcoll-msgid
          lang      = 'EN'
          no        = wa_msgcoll-msgnr
          v1        = wa_msgcoll-msgv1
          v2        = wa_msgcoll-msgv2
          v3        = sy-msgv3
          v4        = sy-msgv4
        importing
          msg       = msg_text
        exceptions
          not_found = 1
          others    = 2.
      if sy-subrc <> 0.
* Implement suitable error handling here
      endif.

      move-corresponding wa_msgcoll to wa_log.
      wa_log-matnr = gwa_file-matnr.
      wa_log-msg_text = msg_text.
      append wa_log to it_log.
      clear:wa_log,wa_msgcoll,msg_text.

    endloop.
    clear:gwa_file,cnt.
    refresh it_msgcoll.

  endloop.

endform.

*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0203   text
*      -->P_0204   text
*----------------------------------------------------------------------*
form bdc_dynpro  using program dynpro.
  clear wa_bdcdata.
  wa_bdcdata-program  = program.  "program
  wa_bdcdata-dynpro   = dynpro.   "screen
  wa_bdcdata-dynbegin = 'X'.      "begin
  append wa_bdcdata to it_bdcdata.
endform.
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0208   text
*      -->P_0209   text
*----------------------------------------------------------------------*
form bdc_field  using fnam fval.

  clear wa_bdcdata.
  wa_bdcdata-fnam = fnam.        "field name
  wa_bdcdata-fval = fval.        "field value
  append wa_bdcdata to it_bdcdata.

endform.
*&---------------------------------------------------------------------*
*& Form FIELD_CATLOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form field_catlog .

  perform create_fieldcat using:

   '01' '01' 'MATNR'    'IT_LOG' 'L' 'Material No',
*     '01' '02' 'TCODE'    'IT_LOG' 'L' 'TCODE',
*     '01' '03' 'DYNAME'   'IT_LOG' 'L' 'DYNAME',
*     '01' '04' 'DYNUMB'   'IT_LOG' 'L' 'DYNUMB',
*     '01' '02' 'MSGTYP'   'IT_LOG' 'L' 'MSGTYP',
*     '01' '06' 'MSGSPRA'  'IT_LOG' 'L' 'MSGSPRA',
   '01' '03' 'MSGID'    'IT_LOG' 'L' 'MSGID',
   '01' '04' 'MSGNR'    'IT_LOG' 'L' 'MSGNR',
   '01' '05' 'MSGV1'    'IT_LOG' 'L' 'MSGV1',
   '01' '06' 'MSGV2'    'IT_LOG' 'L' 'MSGV2',
   '01' '07' 'MSGV3'    'IT_LOG' 'L' 'MSGV3',
   '01' '08' 'MSGV4'    'IT_LOG' 'L' 'MSGV4',
   '01' '09' 'ENV'      'IT_LOG' 'L' 'ENV',
   '01' '10' 'FLDNAME'  'IT_LOG' 'L' 'FLDNAME',
   '01' '11' 'MSG_TEXT'  'IT_LOG' 'L' 'Message'.


endform.
*&---------------------------------------------------------------------*
*&      Form  CREATE_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0403   text
*      -->P_0404   text
*      -->P_0405   text
*      -->P_0406   text
*      -->P_0407   text
*      -->P_0408   text
*----------------------------------------------------------------------*
form create_fieldcat using fp_rowpos    type sycurow
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

  clear wa_fcat.

endform.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form display_alv .

  if it_log is not initial.

    wa_layout-zebra = 'X'.
    wa_layout-colwidth_optimize = 'X'.

    call function 'REUSE_ALV_GRID_DISPLAY'
      exporting
        is_layout     = wa_layout
        it_fieldcat   = it_fieldcat
        i_save        = 'X'
      tables
        t_outtab      = it_log
      exceptions
        program_error = 1
        others        = 2.
    if sy-subrc <> 0.
* MESSAGE 'ERROR IN ALV DISPLAY'(010) TYPE 'I'.
    endif.
  endif.

endform.
