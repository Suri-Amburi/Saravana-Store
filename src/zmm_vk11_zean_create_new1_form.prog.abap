*&---------------------------------------------------------------------*
*& Include          ZMM_VK11_ZEAN_CREATE_NEW1_FORM
*&---------------------------------------------------------------------*

FORM get_filename  CHANGING fp_p_file TYPE string.

  DATA: li_filetable    TYPE filetable,
        lx_filetable    TYPE file_table,
        lv_return_code  TYPE i,
        lv_window_title TYPE string.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = lv_window_title
    CHANGING
      file_table              = li_filetable
      rc                      = lv_return_code
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  READ TABLE  li_filetable INTO lx_filetable INDEX 1.
  fp_p_file = lx_filetable-filename.

*  SPLIT FILENAME AND EXTENSION NAME TO VALIDATE FILETYPE
  SPLIT fp_p_file AT '.' INTO fname ename.
  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE ename TO UPPER CASE.

ENDFORM.

FORM get_data  CHANGING git_file TYPE gty_t_file.

  DATA : i_type    TYPE truxs_t_text_data.

  DATA:lv_file TYPE rlgrap-filename.
  BREAK ppadhy.

*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ename EQ 'XLSX' OR ename EQ 'XLS'.

    REFRESH git_file[].

    lv_file = p_file.
*    BREAK-POINT.
*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_tab_raw_data       = i_type
        i_filename           = lv_file
      TABLES
        i_tab_converted_data = git_file[]
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.


    DELETE git_file FROM 1 TO 2.

  ELSE.
    MESSAGE e398(00) WITH 'Invalid File Type'  .
  ENDIF.

  IF git_file IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.


ENDFORM.


FORM process_data  USING    p_git_file.
  DATA: fld(20)  TYPE c,  fld1(20) TYPE c, fld2(20) TYPE c, fld3(20) TYPE c, fld4(20) TYPE c,
        cnt(2)   TYPE n, lv_line TYPE i,
        msg_text TYPE string.

  FIELD-SYMBOLS:<fs_flatfile>    TYPE gty_file,
                <fs_flatfile_it> TYPE gty_file,
                <fs_flatfile1>   TYPE gty_file.

  git_file_it[] = git_file_i[] = git_file[].
  DELETE ADJACENT DUPLICATES FROM git_file COMPARING matnr ean11.

  LOOP AT git_file ASSIGNING <fs_flatfile>.



    IF p1 = 'X'.                                                                  "ZEAN Plant material

      PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'RV13A-KSCHL'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'RV13A-KSCHL'
                                    <fs_flatfile>-kschl."'ZEAN'.
      PERFORM bdc_dynpro      USING 'SAPMV13A' '1406'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'KONP-KONWA(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'KOMG-WERKS'
                                    <fs_flatfile>-werks."'SSPO'.
      PERFORM bdc_field       USING 'KOMG-MATNR(01)'
                                    <fs_flatfile>-matnr."'286413-NO 5'.
      PERFORM bdc_field       USING 'KONP-KBETR(01)'
                                    <fs_flatfile>-kbetr."'             101'.
      PERFORM bdc_field       USING 'KONP-KONWA(01)'
                                    <fs_flatfile>-konwa."'INR'.
      PERFORM bdc_dynpro      USING 'SAPMV13A' '1406'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'KOMG-MATNR(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=SICH'.

      REFRESH it_messtab.
      CALL TRANSACTION 'VK11' USING it_bdcdata
                              MODE  ctumode
                              UPDATE cupdate
                              MESSAGES INTO it_messtab.
      WAIT UP TO '0.05' SECONDS.
      REFRESH: it_bdcdata.

    ELSEIF p2 = 'X'.              "ZMRP

      PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'RV13A-KSCHL'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'RV13A-KSCHL'
                                    <fs_flatfile>-kschl."'zmrp'.
      PERFORM bdc_dynpro      USING 'SAPMV13A' '1515'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'KONP-KONWA(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'KOMG-MATNR(01)'
                                    <fs_flatfile>-matnr."'286413-NO 5'.
      PERFORM bdc_field       USING 'KONP-KBETR(01)'
                                    <fs_flatfile>-kbetr."'             101'.
      PERFORM bdc_field       USING 'KONP-KONWA(01)'
                                    <fs_flatfile>-konwa."'inr'.
      PERFORM bdc_dynpro      USING 'SAPMV13A' '1515'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'KOMG-MATNR(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=SICH'.


      REFRESH it_messtab.
      CALL TRANSACTION 'VK11' USING it_bdcdata
                              MODE  ctumode
                              UPDATE cupdate
                              MESSAGES INTO it_messtab.
      WAIT UP TO '0.05' SECONDS.
      REFRESH: it_bdcdata.

    ENDIF.

    LOOP AT it_messtab INTO wa_messtab.

      CALL FUNCTION 'FORMAT_MESSAGE'
        EXPORTING
          id        = wa_messtab-msgid
          lang      = 'EN'
          no        = wa_messtab-msgnr
          v1        = wa_messtab-msgv1
          v2        = wa_messtab-msgv2
          v3        = wa_messtab-msgv3
          v4        = wa_messtab-msgv4
        IMPORTING
          msg       = msg_text
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      lv_sqno = lv_sqno + 1.

      gwa_display-lifnr = <fs_flatfile>-lifnr.
      gwa_display-matnr = <fs_flatfile>-matnr.
      gwa_display-werks = <fs_flatfile>-werks.
      gwa_display-charg = <fs_flatfile>-charg.
      gwa_display-ean11 = <fs_flatfile>-ean11.
      gwa_display-matkl = <fs_flatfile>-matkl.
      gwa_display-kschl = <fs_flatfile>-kschl.
      MOVE-CORRESPONDING wa_messtab TO gwa_display.
      gwa_display-message1 = msg_text.
      gwa_display-message2 = wa_messtab-msgtyp.
      gwa_display-sno = lv_sqno.

      APPEND gwa_display TO git_display.
      CLEAR:gwa_display, msg_text.
    ENDLOOP.

  ENDLOOP.

ENDFORM.

FORM field_catlog .
  PERFORM create_fieldcat USING:
        '01' '01' 'sno'       'GIT_DISPLAY' 'L' 'SNO',
        '01' '02' 'kschl'     'GIT_DISPLAY' 'L' 'condition Record',
        '01' '03' 'ean11'     'GIT_DISPLAY' 'L' 'EAN',
        '01' '04' 'lifnr'     'GIT_DISPLAY' 'L' 'Vendor',
        '01' '05' 'matnr'     'GIT_DISPLAY' 'L' 'Material',
        '01' '06' 'charg'     'GIT_DISPLAY' 'L' 'Batch',
        '01' '07' 'matkl'     'GIT_DISPLAY' 'L' 'Material Group',
        '01' '08' 'message1'  'GIT_DISPLAY' 'L' 'Message',
        '01' '05' 'message2'  'GIT_DISPLAY' 'L' 'Message Type'.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0383   text
*      -->P_0384   text
*      -->P_0385   text
*      -->P_0386   text
*      -->P_0387   text
*      -->P_0388   text
*----------------------------------------------------------------------*
FORM create_fieldcat  USING  fp_rowpos    TYPE sycurow
                            fp_colpos    TYPE sycucol
                            fp_fldnam    TYPE fieldname
                            fp_tabnam    TYPE tabname
                            fp_justif    TYPE char1
                            fp_seltext   TYPE dd03p-scrtext_l..


  DATA: wa_fcat    TYPE  slis_fieldcat_alv.
  wa_fcat-row_pos        =  fp_rowpos.     "Row
  wa_fcat-col_pos        =  fp_colpos.     "Column
  wa_fcat-fieldname      =  fp_fldnam.     "Field Name
  wa_fcat-tabname        =  fp_tabnam.     "Internal Table Name
  wa_fcat-just           =  fp_justif.     "Screen Justified
  wa_fcat-seltext_l      =  fp_seltext.    "Field Text

  APPEND wa_fcat TO it_fieldcat.

  CLEAR wa_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_output .

  DATA: l_repid TYPE syrepid .

*  IF it_error IS NOT INITIAL.
  IF git_display IS NOT INITIAL.


    wa_layout-zebra = 'X'.
    wa_layout-colwidth_optimize = 'X'.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = l_repid
        is_layout          = wa_layout
        it_fieldcat        = it_fieldcat
        i_save             = 'X'
      TABLES
        t_outtab           = git_display
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
* MESSAGE 'ERROR IN ALV DISPLAY'(010) TYPE 'I'.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0266   text
*      -->P_0267   text
*----------------------------------------------------------------------*
FORM bdc_dynpro  USING   program dynpro.
  CLEAR wa_bdcdata.
  wa_bdcdata-program  = program.
  wa_bdcdata-dynpro   = dynpro.
  wa_bdcdata-dynbegin = 'X'.
  APPEND wa_bdcdata TO it_bdcdata.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0415   text
*      -->P_<FS_FLATFILE1>_MENGE  text
*----------------------------------------------------------------------*
FORM bdc_field  USING fnam fval.
  CLEAR wa_bdcdata.
  wa_bdcdata-fnam = fnam.
  wa_bdcdata-fval = fval.
  APPEND wa_bdcdata TO it_bdcdata.
ENDFORM.
