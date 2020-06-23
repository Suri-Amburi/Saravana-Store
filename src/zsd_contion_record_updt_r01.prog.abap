*&---------------------------------------------------------------------*
*& Report ZSD_CONTION_RECORD_U_R01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsd_contion_record_updt_r01.

TYPES : BEGIN OF ty_conrec,
          kschl	  TYPE char4,
          werks	  TYPE char4,
          vrkme	  TYPE char4,
          matnr	  TYPE char40,
          mat_cat TYPE char40,
          batch	  TYPE char10,
          kbetr	  TYPE char16,
          konwa	  TYPE char40,
          sernp	  TYPE char40,
          ean11	  TYPE char40,
        END OF ty_conrec,

        st_conrec TYPE ty_conrec.

DATA : lt_con_rec    TYPE TABLE OF ty_conrec, "zcon_rec_t,
       gv_ctumode(1) VALUE 'N',
       gv_cupdate(1) VALUE 'A'.

DATA:fname TYPE localfile,
     ename TYPE char4.


DATA : bdcdata   LIKE bdcdata    OCCURS 0 WITH HEADER LINE,
       messtab01 TYPE TABLE OF bdcmsgcoll,
       messtab   LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.

FIELD-SYMBOLS : <ls_con_rec> TYPE ty_conrec."zcon_rec_t.
CONSTANTS : c_b(2) VALUE '01',
            c_s(2) VALUE '02',
            c_e(2) VALUE '03',
            c_g(2) VALUE '04'.



*--> Input_screen -> sjena <- 08.02.2020 20:01:54

SELECTION-SCREEN : BEGIN OF BLOCK s1 WITH FRAME TITLE TEXT-001 .
PARAMETERS : p_file TYPE rlgrap-filename OBLIGATORY.
SELECTION-SCREEN END OF BLOCK s1.

*--> Subroutine_call -> sjena <- 18.05.2019 20:04:39
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.

AT SELECTION-SCREEN ON p_file.
  PERFORM check_file_path.

  PERFORM get_data ."CHANGING lt_con_rec.
  CHECK lt_con_rec IS NOT INITIAL.
***  SELECT * FROM zcon_rec_t INTO TABLE lt_con_rec.
  LOOP AT lt_con_rec ASSIGNING <ls_con_rec>.
    CASE <ls_con_rec>-mat_cat.
      WHEN c_b.
        PERFORM upload_condtion_record_b.
      WHEN c_s.
*      PERFORM UPLOAD_CONDTION_RECORD_S.
      WHEN c_e.
*      PERFORM UPLOAD_CONDTION_RECORD_E.
      WHEN c_g.
*      PERFORM UPLOAD_CONDTION_RECORD_G.
    ENDCASE.
  ENDLOOP.
  CHECK messtab01 IS NOT INITIAL.
  PERFORM display_log.
*&---------------------------------------------------------------------*
*& Form UPLOAD_CONDTION_RECORD_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM upload_condtion_record_b .
  REFRESH : messtab, bdcdata.

  DATA(lv_date) = sy-datum+6(2) && '.' && sy-datum+4(2) && '.' && sy-datum+0(4) .

  PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'RV13A-KSCHL'
                                <ls_con_rec>-kschl.
  PERFORM bdc_dynpro      USING 'SAPLV14A' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'.
  PERFORM bdc_field       USING 'RV130-SELKZ(01)'
                                ''.
  PERFORM bdc_field       USING 'RV130-SELKZ(02)'
                                'X'.
  PERFORM bdc_dynpro      USING 'SAPMV13A' '1511'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RV13A-DATBI(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'KOMG-MATNR(01)'
                                <ls_con_rec>-matnr.
  PERFORM bdc_field       USING 'KOMG-CHARG(01)'
                                <ls_con_rec>-batch.
  PERFORM bdc_field       USING 'KONP-KBETR(01)'
                                <ls_con_rec>-kbetr.
  PERFORM bdc_field       USING 'KONP-KONWA(01)'
                                <ls_con_rec>-konwa.
  PERFORM bdc_field       USING 'KONP-KPEIN(01)'
                                '    1'.
  PERFORM bdc_field       USING 'KONP-KMEIN(01)'
                                <ls_con_rec>-vrkme.
  PERFORM bdc_field       USING 'RV13A-KRECH(01)'
                                ''.
  PERFORM bdc_field       USING 'RV13A-DATAB(01)'
                                lv_date.
  PERFORM bdc_field       USING 'RV13A-DATBI(01)'
                                '31.12.9999'.
  PERFORM bdc_dynpro      USING 'SAPMV13A' '1511'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.

  CALL TRANSACTION 'VK11'
           USING  bdcdata
           MODE   gv_ctumode
           UPDATE gv_cupdate
           MESSAGES INTO messtab.

  APPEND LINES OF messtab TO messtab01.
  READ TABLE messtab ASSIGNING FIELD-SYMBOL(<ls_messtab>) WITH KEY msgtyp = 'E'.
  IF sy-subrc <> 0.
    READ TABLE messtab ASSIGNING <ls_messtab> WITH KEY msgtyp = 'S' msgid = 'VK' msgnr = '023'.
    IF sy-subrc = 0.
****      PERFORM delete_entry.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPLOAD_CONDTION_RECORD_S
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM upload_condtion_record_s.
  REFRESH : messtab, bdcdata.
  PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE' '/00'.
  PERFORM bdc_field       USING 'RV13A-KSCHL' <ls_con_rec>-kschl.  "'ZKP0'.
  PERFORM bdc_dynpro      USING 'SAPLV14A' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE' '=WEIT'.
  PERFORM bdc_field       USING 'RV130-SELKZ(03)' 'X'.
  PERFORM bdc_dynpro      USING 'SAPMV13A' '1512'.
  PERFORM bdc_field       USING 'BDC_OKCODE' '/00'.
  PERFORM bdc_field       USING 'KOMG-MATNR' <ls_con_rec>-matnr."'10501-2XL'.
  PERFORM bdc_field       USING 'KOMG-ZZSERNR(01)' <ls_con_rec>-sernp. "'3'.
  PERFORM bdc_field       USING 'KOMG-KBSTAT(01)' ''.
  PERFORM bdc_field       USING 'KONP-KBETR(01)' <ls_con_rec>-kbetr. " '             200'.
  PERFORM bdc_field       USING 'KONP-KONWA(01)' <ls_con_rec>-konwa.
  PERFORM bdc_field       USING 'KONP-KMEIN(01)' <ls_con_rec>-vrkme.
  PERFORM bdc_field       USING 'RV13A-DATAB(01)' '25.04.2019'.
  PERFORM bdc_field       USING 'RV13A-DATBI(01)' ''.
  PERFORM bdc_dynpro      USING 'SAPMV13A' '1512'.
  PERFORM bdc_field       USING 'BDC_OKCODE' '=SICH'.

  CALL TRANSACTION 'VK11'
         USING bdcdata
         MODE   gv_ctumode " 'A' CTUMODE
         UPDATE gv_cupdate " 'L' " CUPDATE
         MESSAGES INTO messtab.

  READ TABLE messtab ASSIGNING FIELD-SYMBOL(<ls_messtab>) WITH KEY msgtyp = 'E'.
  IF sy-subrc <> 0.
    READ TABLE messtab ASSIGNING <ls_messtab> WITH KEY msgtyp = 'S' msgid = 'VK' msgnr = '023'.
    IF sy-subrc = 0.
      PERFORM delete_entry.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPLOAD_CONDTION_RECORD_E
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM upload_condtion_record_e.
  REFRESH : messtab, bdcdata.
  DATA(lv_date) = sy-datum+6(2) && '.' && sy-datum+4(2) && '.' && sy-datum+0(4) .
*  PERFORM BDC_DYNPRO      USING 'SAPMV13A' '0100'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE' '/00'.
*  PERFORM BDC_FIELD       USING 'RV13A-KSCHL' <LS_CON_REC>-KSCHL ." 'ZKP0'.
*  PERFORM BDC_DYNPRO      USING 'SAPLV14A' '0100'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE' '=WEIT'.
*  PERFORM BDC_FIELD       USING 'RV130-SELKZ(01)' ''.
*  PERFORM BDC_FIELD       USING 'RV130-SELKZ(03)' 'X'.
*  PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1507'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE' '/00'.
*  PERFORM BDC_FIELD       USING 'KOMG-WERKS'     <LS_CON_REC>-WERKS ." 'SFCP'.
*  PERFORM BDC_FIELD       USING 'KOMG-EAN11(01)' <LS_CON_REC>-MATNR . "  'SST51001'.
*  PERFORM BDC_FIELD       USING 'KOMG-VRKME(01)' <LS_CON_REC>-VRKME . " 'EA'.
*  PERFORM BDC_FIELD       USING 'KONP-KBETR(01)' <LS_CON_REC>-KBETR . "'              10'.
*  PERFORM BDC_FIELD       USING 'KONP-KONWA(01)' 'INR'.
*  PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1507'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE' '=SICH'.

*  PERFORM BDC_DYNPRO      USING 'SAPMV13A' '0100'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE' '/00'.
*  PERFORM BDC_FIELD       USING 'RV13A-KSCHL' <LS_CON_REC>-KSCHL.
*  PERFORM BDC_DYNPRO      USING 'SAPLV14A' '0100'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE' '=WEIT'.
*  PERFORM BDC_FIELD       USING 'RV130-SELKZ(04)' 'X'.
*  PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1516'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE' '/00'.
*  PERFORM BDC_FIELD       USING 'KOMG-MATNR'      <LS_CON_REC>-MATNR.
*  PERFORM BDC_FIELD       USING 'KOMG-EAN11(01)'  <LS_CON_REC>-EAN11.
*  PERFORM BDC_FIELD       USING 'KONP-KBETR(01)'  <LS_CON_REC>-KBETR.
*  PERFORM BDC_FIELD       USING 'KONP-KONWA(01)'  <LS_CON_REC>-KONWA.
*  PERFORM BDC_FIELD       USING 'KONP-KMEIN(01)'  <LS_CON_REC>-VRKME.
*  PERFORM BDC_FIELD       USING 'RV13A-DATAB(01)' LV_DATE.
*  PERFORM BDC_FIELD       USING 'RV13A-DATBI(01)' '31.12.9999'.
*  PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1516'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE' '=SICH'.

  PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'  '/00'.
  PERFORM bdc_field       USING 'RV13A-KSCHL'
                                <ls_con_rec>-kschl.
  PERFORM bdc_dynpro      USING 'SAPLV14A' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'.
  PERFORM bdc_field       USING 'RV130-SELKZ(01)'
                                ''.
  PERFORM bdc_field       USING 'RV130-SELKZ(04)' 'X'.
  PERFORM bdc_dynpro      USING 'SAPMV13A' '1516'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'KOMG-MATNR(01)'
                                <ls_con_rec>-matnr.
  PERFORM bdc_field       USING 'KOMG-EAN11(01)'
                                <ls_con_rec>-ean11.
  PERFORM bdc_field       USING 'KONP-KBETR(01)'
                                <ls_con_rec>-kbetr.
  PERFORM bdc_field       USING 'KONP-KONWA(01)'
                                <ls_con_rec>-konwa.
  PERFORM bdc_field       USING 'KONP-KPEIN(01)'
                                '    1'.
  PERFORM bdc_field       USING 'KONP-KMEIN(01)'
                                <ls_con_rec>-vrkme.
  PERFORM bdc_field       USING 'RV13A-DATAB(01)'
                                lv_date.
  PERFORM bdc_field       USING 'RV13A-DATBI(01)'
                                '31.12.9999'.
  PERFORM bdc_dynpro      USING 'SAPMV13A' '1516'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'KOMG-MATNR(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.

  CALL TRANSACTION 'VK11'
           USING bdcdata
           MODE   gv_ctumode " 'A' CTUMODE
           UPDATE gv_cupdate " 'L' " CUPDATE
           MESSAGES INTO messtab.

  READ TABLE messtab ASSIGNING FIELD-SYMBOL(<ls_messtab>) WITH KEY msgtyp = 'E'.
  IF sy-subrc <> 0.
    READ TABLE messtab ASSIGNING <ls_messtab> WITH KEY msgtyp = 'S' msgid = 'VK' msgnr = '023'.
    IF sy-subrc = 0.
      PERFORM delete_entry.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPLOAD_CONDTION_RECORD_G
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
FORM upload_condtion_record_g.
  REFRESH : messtab, bdcdata.
  DATA(lv_date) = sy-datum+6(2) && '.' && sy-datum+4(2) && '.' && sy-datum+0(4) .
*  PERFORM BDC_DYNPRO      USING 'SAPMV13A' '0100'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE' '/00'.
*  PERFORM BDC_FIELD       USING 'RV13A-KSCHL'
*                                'ZKP0'.
*  PERFORM BDC_DYNPRO      USING 'SAPLV14A' '0100'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE' '=WEIT'.
*  PERFORM BDC_FIELD       USING 'RV130-SELKZ(01)' 'X'.
*  PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1504'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                '/00'.
*  PERFORM BDC_FIELD       USING 'KOMG-WERKS'
*                                <LS_CON_REC>-WERKS.
*  PERFORM BDC_FIELD       USING 'KOMG-MATNR(01)'
*                                 <LS_CON_REC>-MATNR.
*  PERFORM BDC_FIELD       USING 'KOMG-VRKME(01)'
*                                 <LS_CON_REC>-VRKME.
*  PERFORM BDC_FIELD       USING 'KONP-KBETR(01)'
*                                    <LS_CON_REC>-KBETR.
*  PERFORM BDC_FIELD       USING 'KONP-KONWA(01)'
*                                'INR'.
*  PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1504'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*         '=SICH'.

*  PERFORM BDC_DYNPRO      USING 'SAPMV13A' '0100'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE' '/00'.
*  PERFORM BDC_FIELD       USING 'RV13A-KSCHL' <LS_CON_REC>-KSCHL.
*  PERFORM BDC_DYNPRO      USING 'SAPLV14A' '0100'.
*  PERFORM BDC_FIELD       USING 'BDC_CURSOR' 'RV130-SELKZ(01)'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE' '=WEIT'.
*  PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1515'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE' '/00'.
*  PERFORM BDC_FIELD       USING 'KOMG-MATNR(01)' <LS_CON_REC>-MATNR.
*  PERFORM BDC_FIELD       USING 'KONP-KBETR(01)' <LS_CON_REC>-KBETR.
*  PERFORM BDC_FIELD       USING 'KONP-KONWA(01)' <LS_CON_REC>-KONWA.
*  PERFORM BDC_FIELD       USING 'KONP-KMEIN(01)' <LS_CON_REC>-VRKME.
*  PERFORM BDC_FIELD       USING 'RV13A-DATAB(01)' LV_DATE.
*  PERFORM BDC_FIELD       USING 'RV13A-DATBI(01)' '31.12.9999'.
*  PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1515'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE' '=SICH'.

  PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'RV13A-KSCHL'
                                <ls_con_rec>-kschl.
  PERFORM bdc_dynpro      USING 'SAPLV14A' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'.
  PERFORM bdc_dynpro      USING 'SAPMV13A' '1515'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'KOMG-MATNR(01)'
                                <ls_con_rec>-matnr.
  PERFORM bdc_field       USING 'KONP-KBETR(01)'
                                <ls_con_rec>-kbetr.
  PERFORM bdc_field       USING 'KONP-KONWA(01)'
                                <ls_con_rec>-konwa. "'INR' ."<LS_CON_REC>-'.
  PERFORM bdc_field       USING 'KONP-KPEIN(01)'
                                '    1'.
  PERFORM bdc_field       USING 'KONP-KMEIN(01)'
                                <ls_con_rec>-vrkme.
  PERFORM bdc_field       USING 'RV13A-KRECH(01)'
                                ''.
  PERFORM bdc_field       USING 'RV13A-DATAB(01)'
                                lv_date.
  PERFORM bdc_field       USING 'RV13A-DATBI(01)'
                                '31.12.9999'.
  PERFORM bdc_dynpro      USING 'SAPMV13A' '1515'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'KOMG-MATNR(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.

  CALL TRANSACTION 'VK11'
           USING bdcdata
           MODE   gv_ctumode  " 'A' CTUMODE
           UPDATE gv_cupdate  "'L' " CUPDATE
           MESSAGES INTO messtab.

  READ TABLE messtab ASSIGNING FIELD-SYMBOL(<ls_messtab>) WITH KEY msgtyp = 'E'.
  IF sy-subrc <> 0.
    READ TABLE messtab ASSIGNING <ls_messtab> WITH KEY msgtyp = 'S' msgid = 'VK' msgnr = '023'.
    IF sy-subrc = 0.
      PERFORM delete_entry.
    ENDIF.
  ENDIF.

ENDFORM.

FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.

FORM bdc_field USING fnam fval.
  IF fval IS NOT INITIAL.
    CLEAR bdcdata.
    bdcdata-fnam = fnam.
    bdcdata-fval = fval.
    SHIFT bdcdata-fval LEFT DELETING LEADING space.
    APPEND bdcdata.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_ENTRY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_entry .
****  DELETE FROM zcon_rec_t WHERE werks = <ls_con_rec>-werks AND matnr = <ls_con_rec>-matnr AND batch = <ls_con_rec>-batch.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_FILE
*&---------------------------------------------------------------------*
FORM get_filename  CHANGING p_p_file.
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
  p_p_file = lx_filetable-filename.


  SPLIT p_p_file AT '.' INTO fname ename.
  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE ename TO UPPER CASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_FILE_PATH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
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
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_CON_REC
*&---------------------------------------------------------------------*
FORM get_data ." CHANGING lt_con_rec TYPE st_conrec.
  DATA : i_type    TYPE truxs_t_text_data.

  DATA:lv_file TYPE rlgrap-filename.


*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ename EQ 'XLSX' OR ename EQ 'XLS'.

    lv_file = p_file.

*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_tab_raw_data       = i_type
        i_filename           = lv_file
      TABLES
        i_tab_converted_data = lt_con_rec
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.

    DELETE lt_con_rec FROM 1 TO 2.

  ELSE.
    MESSAGE e398(00) WITH 'Invalid File Type'  .
  ENDIF.

  IF lt_con_rec[] IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_log .

*--> output_alv_factory_data -> sjena <- 18.05.2019 20:23:11
  DATA : lr_alv TYPE REF TO cl_salv_table,
         it_raw TYPE truxs_t_text_data.

*   local data
  DATA: lo_dock TYPE REF TO cl_gui_docking_container,
        lo_cont TYPE REF TO cl_gui_container,
        lo_alv  TYPE REF TO cl_salv_table.

  DATA: lo_cols TYPE REF TO cl_salv_columns.
  DATA: lo_events TYPE REF TO cl_salv_events_table.
  DATA: lr_functions TYPE REF TO cl_salv_functions.
  DATA: lo_h_label TYPE REF TO cl_salv_form_label,
        lo_h_flow  TYPE REF TO cl_salv_form_layout_flow,
        lo_header  TYPE REF TO cl_salv_form_layout_grid,
        lr_layout  TYPE REF TO salv_s_layout.


** Declaration for Global Display Settings
  DATA : gr_display TYPE REF TO cl_salv_display_settings,
         lv_title   TYPE lvc_title.

** declaration for ALV Columns
  DATA : gr_columns    TYPE REF TO cl_salv_columns_table,
         gr_column     TYPE REF TO cl_salv_column,
         lt_column_ref TYPE salv_t_column_ref,
         ls_column_ref TYPE salv_s_column_ref.

** Declaration for Aggregate Function Settings
  DATA : gr_aggr    TYPE REF TO cl_salv_aggregations.

** Declaration for Sort Function Settings
  DATA : gr_sort    TYPE REF TO cl_salv_sorts.

** Declaration for Table Selection settings
  DATA : gr_select  TYPE REF TO cl_salv_selections.

** Declaration for Top of List settings
  DATA : gr_content TYPE REF TO cl_salv_form_element.

  DATA: lo_layout TYPE REF TO cl_salv_layout,
*            lf_variant TYPE slis_vari,
        ls_key    TYPE salv_s_layout_key.


  TRY.
      cl_salv_table=>factory(
  EXPORTING
  list_display   = if_salv_c_bool_sap=>false    " ALV Displayed in List Mode
*    r_container    =     " Abstract Container for GUI Controls
*    container_name =
        IMPORTING
        r_salv_table   = lr_alv   " Basis Class Simple ALV Tables
        CHANGING
        t_table        = messtab01[]
                                ).

      lo_cols = lr_alv->get_columns( ).

*    *   set the Column optimization
      lo_cols->set_optimize( 'X' ).
      gr_display = lr_alv->get_display_settings( ).
      gr_display->set_striped_pattern( cl_salv_display_settings=>true ).

** header object
*      CREATE OBJECT lo_header.
*      lo_h_label = lo_header->create_label( row = 1 column = 1 ).
*      lo_h_label->set_text( 'Incomplete Pallet Carton Details' ).
*      lr_alv->set_top_of_list( lo_header ).

*      GET layout object
      lo_layout = lr_alv->get_layout( ).
*   set Layout save restriction
*   1. Set Layout Key .. Unique key identifies the Differenet ALVs
      ls_key-report = sy-repid.
      lo_layout->set_key( ls_key ).
*   2. Remove Save layout the restriction.
*    lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
      lo_layout->set_save_restriction( cl_salv_layout=>restrict_none ).

      lr_functions = lr_alv->get_functions( ) .
      lr_functions->set_all( abap_true ).

*      CALL METHOD lr_alv->set_screen_status(
*        EXPORTING
*          report        = sy-repid
*          pfstatus      = 'PF_STAT'
*          set_functions = lr_alv->c_functions_all ).

    CATCH cx_salv_msg.    "
  ENDTRY .
  lr_alv->display( ).
ENDFORM.
