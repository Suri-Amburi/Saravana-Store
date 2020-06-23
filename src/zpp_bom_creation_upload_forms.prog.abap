*&---------------------------------------------------------------------*
*& Include          ZPP_IBOM_CREATION_C02_SUBFORMS
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
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_TA_FLATFILE  text
*----------------------------------------------------------------------*

FORM get_data  CHANGING git_file TYPE gty_t_file.

  DATA : i_type    TYPE truxs_t_text_data.

  DATA:lv_file TYPE rlgrap-filename.


*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ename EQ 'XLSX' OR ename EQ 'XLS'.

    REFRESH git_file[].

    lv_file = p_file.

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
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GIT_FILE  text
*----------------------------------------------------------------------*
FORM process_data  USING    p_git_file.

  DATA: fld(20)  TYPE c,  fld1(20) TYPE c, fld2(20) TYPE c, fld3(20) TYPE c, fld4(20) TYPE c,
        cnt(2)   TYPE n, lv_line TYPE i,
        msg_text TYPE string.

  FIELD-SYMBOLS:<fs_flatfile>    TYPE gty_file,
                <fs_flatfile_it> TYPE gty_file,
                <fs_flatfile1>   TYPE gty_file.

  git_file_it[] = git_file_i[] = git_file[].
  DELETE ADJACENT DUPLICATES FROM git_file COMPARING matnr.
*    DELETE ADJACENT DUPLICATES FROM git_file_i COMPARING matnr posnr.

  LOOP AT git_file ASSIGNING <fs_flatfile>.

    PERFORM bdc_dynpro      USING 'SAPLCSDI' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RC29N-STLAL'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                   '/00'.
    PERFORM bdc_field       USING 'RC29N-MATNR'
                                  <fs_flatfile>-matnr .
    PERFORM bdc_field      USING 'RC29N-WERKS'
                                   <fs_flatfile>-werks .
    PERFORM bdc_field       USING 'RC29N-STLAN'
                                   <fs_flatfile>-stlan.
    PERFORM bdc_field       USING 'RC29N-STLAL'
                                   <fs_flatfile>-stlal.

    PERFORM bdc_dynpro      USING 'SAPLCSDI' '0110'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RC29K-BMENG'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                   '/00'.
    PERFORM bdc_field      USING 'RC29K-BMENG'
                                  <fs_flatfile>-bmeng.
*                                    wa_table-bmeng .

    PERFORM bdc_dynpro      USING 'SAPLCSDI' '0111'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                   '/00'.

    cnt = 01.
    LOOP AT git_file_it ASSIGNING <fs_flatfile1> WHERE matnr = <fs_flatfile>-matnr
                                                   AND werks = <fs_flatfile>-werks
                                                   AND stlal = <fs_flatfile>-stlal
                                                   AND stlan = <fs_flatfile>-stlan.

      IF <fs_flatfile1> IS ASSIGNED.


        PERFORM bdc_dynpro      USING 'SAPLCSDI' '0140'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                       '/00'.

        CONCATENATE 'RC29P-IDNRK('cnt')' INTO fld.
        CONDENSE fld.
        PERFORM bdc_field       USING  fld
                                       <fs_flatfile1>-idnrk.

        CONCATENATE 'RC29P-MENGE('cnt')' INTO fld1.
        CONDENSE fld1.
        PERFORM bdc_field       USING  fld1
                                       <fs_flatfile1>-menge.

        CONCATENATE 'RC29P-MEINS('cnt')' INTO fld2.
        CONDENSE fld2.
        PERFORM bdc_field       USING  fld2
                                       <fs_flatfile1>-meins.



        CONCATENATE 'RC29P-POSTP('cnt')' INTO fld3.
        CONDENSE fld3.
        PERFORM bdc_field       USING  fld3
                                       <fs_flatfile1>-postp.

        PERFORM bdc_dynpro      USING 'SAPLCSDI' '0130'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                       '/00'.
        PERFORM bdc_field       USING 'RC29P-IDNRK'
                                       <fs_flatfile1>-idnrk.
        PERFORM bdc_field       USING 'RC29P-MENGE'
                                       <fs_flatfile1>-menge.
        PERFORM bdc_field       USING 'RC29P-MEINS'
                                       <fs_flatfile1>-meins.
        PERFORM bdc_field       USING 'RC29P-AUSCH'                    """""""
                                       <fs_flatfile1>-ausch.
        PERFORM bdc_field       USING 'RC29P-AVOAU'                    """""""
                                       <fs_flatfile1>-avoau.
        PERFORM bdc_field       USING 'RC29P-NETAU'                    """""""
                                       <fs_flatfile1>-netau.

        PERFORM bdc_dynpro      USING 'SAPLCSDI' '0131'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                       '/00'.

*        PERFORM bdc_dynpro      USING 'SAPLCSDI' '0138'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'
*                                       '/00'.
        IF cnt = 02.

          PERFORM bdc_dynpro      USING 'SAPLCSDI' '0140'.
          PERFORM bdc_field       USING 'BDC_OKCODE'
                                         '=FCNP'.

        ENDIF.

        IF cnt = 01.
          cnt = cnt + 1.
        ENDIF.
      ENDIF.
*        CLEAR: wa_data.
    ENDLOOP.

    PERFORM bdc_dynpro      USING 'SAPLCSDI' '0140'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                   '=FCBU'.

    REFRESH it_messtab.
    CALL TRANSACTION 'CS01' USING it_bdcdata
                            MODE  ctumode
                            UPDATE cupdate
                            MESSAGES INTO it_messtab.

    REFRESH: it_bdcdata.
    DESCRIBE TABLE it_messtab LINES lv_line.
    READ TABLE it_messtab INTO wa_messtab INDEX lv_line.


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

*        wa_log-intid = 'INT213'.
*        gwa_display-erdat = lv_date.
*        gwa_display-erzet = lv_time.
*        gwa_display-ernam = sy-uname.
      gwa_display-matnr    = <fs_flatfile>-matnr.
      gwa_display-werks    = <fs_flatfile>-werks.
      MOVE-CORRESPONDING wa_messtab TO gwa_display.
      gwa_display-message1 = msg_text.
      gwa_display-sno = lv_sqno.

      APPEND gwa_display TO git_display.
      CLEAR:gwa_display, msg_text.
    ENDLOOP.

  ENDLOOP.

**        gwa_display-sno      = <fs_flatfile>-sno.
*    gwa_display-matnr    = <fs_flatfile>-matnr.
*    gwa_display-werks    = <fs_flatfile>-werks.
*    gwa_display-bom_no   = lv_bom_no.
**        gwa_display-knnam    = <fs_flatfile1>-knnam.
*    gwa_display-message1  = 'BOM creation Failed'.
*    append gwa_display to git_display.

*  DATA: fl_warning    TYPE capiflag-flwarning,
*
*        wa_stko_api01 TYPE stko_api01,               "Header Structure
*
*        wa_stpo_api01 TYPE stpo_api01,               "BOM Item
*        it_stpo_api01 TYPE TABLE OF stpo_api01,
*
*        wa_csdep_dat  TYPE csdep_dat,
*        it_csdep_dat  TYPE TABLE OF csdep_dat,
*
*        it_csdep_desc TYPE TABLE OF csdep_desc,
*        wa_csdep_desc TYPE csdep_desc,
*        it_csdep_ord  TYPE TABLE OF csdep_ord,
*        wa_csdep_ord  TYPE csdep_ord,
*        it_csdep_sorc TYPE TABLE OF csdep_sorc,
*        wa_csdep_sorc TYPE csdep_sorc,
*        it_csdep_doc  TYPE TABLE OF csdep_doc.
*
*
*  DATA : lv_bom_no TYPE stko_api02-bom_no,
*         cnt_item  TYPE i.
*
*********************************************************
**Background job Venkatesh
*  DATA: lv_file TYPE string,
*        ls_file TYPE gty_file.
*  IF sy-batch = 'X'.
*
*    CASE sy-sysid.
*      WHEN 'AED'.
*        lv_file = '/usr/sap/AED/D10/work/ZMAT_CLS.txt'.
*      WHEN 'AEQ'.
*        lv_file = '/usr/sap/AEQ/D20/work/ZMAT_CLS.txt'.
*      WHEN 'AEP'.
*        lv_file = '/usr/sap/AEP/D00/work/ZMAT_CLS.txt'.
*    ENDCASE.
*
*    TRY.
*        OPEN DATASET lv_file FOR INPUT IN BINARY MODE.
*        DO.
*          CLEAR ls_file .
*          READ DATASET lv_file INTO ls_file.
*          IF sy-subrc = 0.
*            APPEND ls_file TO git_file.
*            CLEAR ls_file.
*          ELSE.
*            EXIT.
*          ENDIF.
*        ENDDO.
*      CATCH cx_root.
*    ENDTRY.
*    CLOSE DATASET lv_file.
*    DELETE DATASET lv_file.
*  ENDIF.
*
********************************************************
*
*  IF git_file[] IS NOT INITIAL.
*
*    git_file_it[] = git_file_i[] = git_file[].
*    DELETE ADJACENT DUPLICATES FROM git_file COMPARING matnr.
*    DELETE ADJACENT DUPLICATES FROM git_file_i COMPARING matnr posnr.
**BREAK KNOWDURI.
*    LOOP AT git_file ASSIGNING <fs_flatfile>.  "WHERE id = 'H'.
*      CLEAR lv_bom_no.
*      IF <fs_flatfile> IS ASSIGNED.
*
*        lv_matnr   = <fs_flatfile>-matnr.        "Material (BTCI) with Conversion MATN2
*        lv_werks   = <fs_flatfile>-werks.         "Plant
*        lv_stlan   = <fs_flatfile>-stlan.           "STLAN
*        lv_stlal   = <fs_flatfile>-stlal.           "Alternative BOM
*        lv_datuv   = <fs_flatfile>-datuv.        "Valid-From Date (BTCI)
**      CSAP_MBOM-DATUB   = <fs_flatfile>-DATUB.        "Valid to date (BTCI)
*
**BOM Header
*        wa_stko_api01-bom_text = <fs_flatfile>-ztext.         "BOM text
*        wa_stko_api01-alt_text = <fs_flatfile>-stktx.          "Alternative BOM Text
*        wa_stko_api01-base_quan = <fs_flatfile>-bmeng.      "Base quantity (BTCI)
*
*
**BOM ITEM ALL DATA
*        LOOP AT git_file_i ASSIGNING <fs_flatfile1> WHERE matnr = <fs_flatfile>-matnr.
*          " AND id = 'C'.
*          cnt_item = cnt_item + 1.
*
*          IF <fs_flatfile1> IS ASSIGNED.
*            wa_stpo_api01-item_no = <fs_flatfile1>-posnr.           "BOM Item Number
*            wa_stpo_api01-item_categ = <fs_flatfile1>-postp.        "Item category (bill of material)
*            wa_stpo_api01-component = <fs_flatfile1>-idnrk.      "Component (BTCI) with Conversion MATN2
*            wa_stpo_api01-comp_qty = <fs_flatfile1>-menge.       "Component quantity (BTCI)
*            wa_stpo_api01-comp_unit = <fs_flatfile1>-meins.       "Component quantity (BTCI)
*            wa_stpo_api01-sortstring = <fs_flatfile1>-sortf.        "Sort String
*            wa_stpo_api01-fixed_qty = <fs_flatfile1>-fmeng.         "Fixed qty
*            wa_stpo_api01-item_text1 = <fs_flatfile1>-potx1.        "BOM Item Text (Line 1)
*            wa_stpo_api01-item_text2 = <fs_flatfile1>-potx2.        "BOM item text (line 2)
*            wa_stpo_api01-spproctype = <fs_flatfile1>-itsob.     "Special procurement type for BOM item
*            wa_stpo_api01-spare_part = <fs_flatfile1>-erskz.        "Indicator: spare part
*            wa_stpo_api01-rel_cost = <fs_flatfile1>-rel_cost.        "Indicator: item relevant to costing
*
*            APPEND wa_stpo_api01 TO it_stpo_api01.
*            CLEAR: wa_stpo_api01.
*
*            wa_csdep_dat-item_node = cnt_item.
*            wa_csdep_dat-dep_intern = <fs_flatfile1>-knnam.
*            wa_csdep_dat-dep_extern = <fs_flatfile1>-knnam.
*
*            APPEND wa_csdep_dat TO it_csdep_dat.
*            CLEAR: wa_csdep_dat.
*
*
*            wa_csdep_ord-item_node = cnt_item.
*            wa_csdep_ord-dep_intern = <fs_flatfile1>-knnam.
*            wa_csdep_ord-dep_extern = <fs_flatfile1>-knnam.
*
*            APPEND wa_csdep_ord TO it_csdep_ord.
*            CLEAR: wa_csdep_ord.
*
*            wa_csdep_desc-item_node = cnt_item.
*            wa_csdep_desc-dep_intern = <fs_flatfile1>-knnam.
*            wa_csdep_desc-dep_extern = <fs_flatfile1>-knnam.
*            wa_csdep_desc-descript   = <fs_flatfile1>-knktx.
*
*            APPEND wa_csdep_desc TO it_csdep_desc.
*            CLEAR: wa_csdep_desc.
*          ENDIF.
*  endloop.

*        CALL FUNCTION 'CSAP_MAT_BOM_CREATE'
*          EXPORTING
*            material           = lv_matnr
*            plant              = lv_werks
*            bom_usage          = lv_stlan
*            valid_from         = lv_datuv
**           CHANGE_NO          =
**           REVISION_LEVEL     =  LV_STLAL
*            i_stko             = wa_stko_api01
**           FL_NO_CHANGE_DOC   = ' '
*            fl_commit_and_wait = ' '
**           FL_CAD             = ' '
**           FL_DEFAULT_VALUES  = 'X'
**           FL_RECURSIVE       = ' '
*          IMPORTING
*            fl_warning         = fl_warning
*            bom_no             = lv_bom_no
*          TABLES
*            t_stpo             = it_stpo_api01
**           t_dep_data         = it_csdep_dat
**           t_dep_descr        = it_csdep_desc
**           t_dep_order        = it_csdep_ord
**           t_dep_source       = it_csdep_sorc
**           t_dep_doc          = it_csdep_doc
**           T_LTX_LINE         =
**           T_STPU             =
**           T_SGT_BOMC         =
*          EXCEPTIONS
*            error              = 1
*            OTHERS             = 2.
*        IF sy-subrc <> 0.
** Implement suitable error handling here
*        ENDIF.



*break-point.
*  if lv_bom_no is not initial.  "Success

**********************************************************************
**Assigning dependency to BOM components
**********************************************************************
*          PERFORM DEPENDENCY_ASSIGN.

*          REFRESH: IT_BDCDATA.
*          READ TABLE IT_MESSTAB WITH KEY MSGTYP = 'E' TRANSPORTING NO FIELDS.

*          IF SY-SUBRC NE 0.

*        gwa_display-sno      = <fs_flatfile>-sno.
*    gwa_display-matnr    = lv_matnr.
*    gwa_display-werks    = lv_werks.
*    gwa_display-bom_no   = lv_bom_no.
**        gwa_display-knnam    = <fs_flatfile1>-knnam.
*    gwa_display-message1  = 'BOM created successfully'.
**            GWA_DISPLAY-MESSAGE2  = 'Dependancy assigned successfully'.
*
*    append gwa_display to git_display.
*    clear gwa_display.
*
*
**        call function 'BAPI_TRANSACTION_COMMIT'
**          exporting
**            wait = 'X'.
*
*    call function 'DEQUEUE_ALL'.
*
*
*  else.  "Failed
*
**        gwa_display-sno      = <fs_flatfile>-sno.
*    gwa_display-matnr    = <fs_flatfile>-matnr.
*    gwa_display-werks    = <fs_flatfile>-werks.
*    gwa_display-bom_no   = lv_bom_no.
**        gwa_display-knnam    = <fs_flatfile1>-knnam.
*    gwa_display-message1  = 'BOM creation Failed'.
*    append gwa_display to git_display.
*    clear gwa_display.
*
**        ENDIF.
*
*  endif.
*  clear: wa_stko_api01, cnt_item.
*  refresh: it_stpo_api01.
*endif.
*endloop.
*
*endif.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATLOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM field_catlog .

  PERFORM create_fieldcat USING:
        '01' '01' 'sno'       'GIT_DISPLAY' 'L' 'SNO',
        '01' '02' 'matnr'     'GIT_DISPLAY' 'L' 'MATERIAL',
        '01' '03' 'werks'     'GIT_DISPLAY' 'L' 'PLANT',
        '01' '04' 'bom_no'    'GIT_DISPLAY' 'L' 'BOM NUMBER',
        '01' '05' 'message1'  'GIT_DISPLAY' 'L' 'MESSAGE',
        '01' '06' 'message2'  'GIT_DISPLAY' 'L' 'MESSAGE'.
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
*&      Form  DISPLAY_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_output .

  DATA: l_repid TYPE syrepid .

*  IF it_error IS NOT INITIAL.
  IF git_display IS NOT INITIAL.


    wa_layout-zebra = 'X'.
    wa_layout-colwidth_optimize = 'X'.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
*       I_INTERFACE_CHECK  = ' '
*       I_BYPASSING_BUFFER = ' '
*       I_BUFFER_ACTIVE    = ' '
        i_callback_program = l_repid
*       I_CALLBACK_PF_STATUS_SET          = ' '
*       I_CALLBACK_USER_COMMAND           = ' '
*       I_CALLBACK_TOP_OF_PAGE            = ' '
*       I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*       I_CALLBACK_HTML_END_OF_LIST       = ' '
*       I_STRUCTURE_NAME   =
*       I_BACKGROUND_ID    = ' '
*       I_GRID_TITLE       =
*       I_GRID_SETTINGS    =
        is_layout          = wa_layout
        it_fieldcat        = it_fieldcat
*       IT_EXCLUDING       =
*       IT_SPECIAL_GROUPS  =
*       IT_SORT            =
*       IT_FILTER          =
*       IS_SEL_HIDE        =
*       I_DEFAULT          = 'X'
        i_save             = 'X'
*       IS_VARIANT         =
*       IT_EVENTS          =
*       IT_EVENT_EXIT      =
*       IS_PRINT           =
*       IS_REPREP_ID       =
*       I_SCREEN_START_COLUMN             = 0
*       I_SCREEN_START_LINE               = 0
*       I_SCREEN_END_COLUMN               = 0
*       I_SCREEN_END_LINE  = 0
*       I_HTML_HEIGHT_TOP  = 0
*       I_HTML_HEIGHT_END  = 0
*       IT_ALV_GRAPHICS    =
*       IT_HYPERLINK       =
*       IT_ADD_FIELDCAT    =
*       IT_EXCEPT_QINFO    =
*       IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*       E_EXIT_CAUSED_BY_CALLER           =
*       ES_EXIT_CAUSED_BY_USER            =
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
FORM bdc_field  USING   fnam fval.

  CLEAR wa_bdcdata.
  wa_bdcdata-fnam = fnam.
  wa_bdcdata-fval = fval.
  APPEND wa_bdcdata TO it_bdcdata.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DEPENDENCY_ASSIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM dependency_assign .

  DATA: fld(20)  TYPE c,  fld1(20) TYPE c, fld2(20) TYPE c, fld3(20) TYPE c, fld4(20) TYPE c,
        cnt(2)   TYPE n, lv_line TYPE i,
        msg_text TYPE string.

  FIELD-SYMBOLS:<fs_flatfile>    TYPE gty_file,
                <fs_flatfile_it> TYPE gty_file,
                <fs_flatfile1>   TYPE gty_file.
*clear: <fs_flatfile>, <fs_flatfile1>.
*git_file_it[] = git_file_i[].
*delete ADJACENT DUPLICATES FROM git_file_it COMPARING posnr.

  LOOP AT git_file ASSIGNING <fs_flatfile> WHERE matnr = lv_matnr.
    IF <fs_flatfile> IS ASSIGNED.

      PERFORM bdc_dynpro      USING 'SAPLCSDI' '0100'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'RC29N-STLAL'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                     '/00'.

      PERFORM bdc_field       USING 'RC29N-MATNR'
                                     <fs_flatfile>-matnr.
      PERFORM bdc_field      USING 'RC29N-WERKS'
                                     <fs_flatfile>-werks.
      PERFORM bdc_field       USING 'RC29N-STLAN'
                                     <fs_flatfile>-stlan.


      LOOP AT git_file_i ASSIGNING <fs_flatfile1> WHERE matnr = <fs_flatfile>-matnr.

        PERFORM bdc_dynpro      USING 'SAPLCSDI' '0150'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                       '=SETP'.
        PERFORM bdc_dynpro      USING 'SAPLCSDI' '0708'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                       '=CLWI'.
        PERFORM bdc_field       USING 'RC29P-SELPO'
                                       <fs_flatfile1>-posnr.

        PERFORM bdc_dynpro      USING 'SAPLCSDI' '0150'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                       '=WIZU'.
        PERFORM bdc_field       USING 'RC29P-AUSKZ(01)'
                                           'X'.       "<fs_flatfile>-posnr.

        LOOP AT git_file_it ASSIGNING <fs_flatfile_it> WHERE matnr = <fs_flatfile>-matnr
                                                         AND posnr = <fs_flatfile1>-posnr.
          cnt = cnt + 1.

          PERFORM bdc_dynpro      USING 'SAPLCUKD' '0130'.
          PERFORM bdc_field       USING 'BDC_OKCODE'
                                         '/00'.
          CONCATENATE 'RCUKD-KNNAM('cnt')' INTO fld.
          CONDENSE fld.
          PERFORM bdc_field       USING  fld
                                         <fs_flatfile_it>-knnam.

        ENDLOOP.
        CLEAR: cnt.

        PERFORM bdc_dynpro      USING 'SAPLCUKD' '0130'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                 '=BACK'.

      ENDLOOP.
    ENDIF.
  ENDLOOP.

  PERFORM bdc_dynpro      USING 'SAPLCSDI' '0150'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                 '=FCBU'.

  REFRESH: it_messtab.

  CALL TRANSACTION 'CS02' USING it_bdcdata
                          MODE  ctumode
                          UPDATE cupdate
                          MESSAGES INTO it_messtab.


ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  CHECK_FILE_PATH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_file_path .

  DATA:lv_file TYPE string,
       lv_res  TYPE char1.

  CHECK sy-batch = ' '.

  lv_file = p_file.

  CALL METHOD cl_gui_frontend_services=>file_exist
    EXPORTING
      file                 = lv_file
    RECEIVING
      result               = lv_res
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      wrong_parameter      = 3
      not_supported_by_gui = 4
      OTHERS               = 5.

  IF lv_res = ' '.
    MESSAGE 'Check File Path'  TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_BACKGROUND_JOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_background_job .

  DATA : i_type    TYPE truxs_t_text_data.
  DATA:ls_file TYPE gty_file.

  DATA:lv_file TYPE string.

  DATA:lv_file2 TYPE rlgrap-filename.

  CHECK pv_bg = 'X'.

*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ename EQ 'XLSX' OR ename EQ 'XLS'.

    REFRESH git_file[].

    lv_file2 = p_file.

*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
*       I_FIELD_SEPERATOR    =
*       I_LINE_HEADER        =
        i_tab_raw_data       = i_type
        i_filename           = lv_file
      TABLES
        i_tab_converted_data = git_file[]
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.

    DELETE git_file[] FROM 1 TO 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ELSE.
    MESSAGE e398(00) WITH 'Invalid File Type'  .
  ENDIF.

  IF git_file[] IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.

  CASE sy-sysid.
    WHEN 'AED'.
      lv_file = '/usr/sap/AED/D10/work/ZBOM_CS01.txt'.
    WHEN 'AEQ'.
      lv_file = '/usr/sap/AEQ/D20/work/ZBOM_CS01.txt'.
    WHEN 'AEP'.
      lv_file = '/usr/sap/AEP/D00/work/ZBOM_CS01.txt'.
  ENDCASE.

  TRY.

      DELETE DATASET lv_file.

      OPEN DATASET lv_file FOR OUTPUT IN BINARY MODE.

      LOOP AT git_file INTO ls_file .
        TRANSFER ls_file TO lv_file.
      ENDLOOP.

    CATCH cx_root.

  ENDTRY.

  CLOSE DATASET lv_file.

  DATA:lv_jobcount TYPE tbtcjob-jobcount.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = 'BOM_CREATION'
    IMPORTING
      jobcount         = lv_jobcount
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.

  DATA:lv_authcknam TYPE tbtcjob-authcknam.

  lv_authcknam = sy-uname.

  CALL FUNCTION 'JOB_SUBMIT'
    EXPORTING
      authcknam               = lv_authcknam
      jobcount                = lv_jobcount
      jobname                 = 'BOM_CREATION'
      report                  = sy-repid
    EXCEPTIONS
      bad_priparams           = 1
      bad_xpgflags            = 2
      invalid_jobdata         = 3
      jobname_missing         = 4
      job_notex               = 5
      job_submit_failed       = 6
      lock_failed             = 7
      program_missing         = 8
      prog_abap_and_extpg_set = 9
      OTHERS                  = 10.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobcount             = lv_jobcount
      jobname              = 'BOM_CREATION'
      strtimmed            = 'X'
    EXCEPTIONS
      cant_start_immediate = 1
      invalid_startdate    = 2
      jobname_missing      = 3
      job_close_failed     = 4
      job_nosteps          = 5
      job_notex            = 6
      lock_failed          = 7
      invalid_target       = 8
      OTHERS               = 9.

  MESSAGE 'Background job start' TYPE 'S'.

ENDFORM.
