*&---------------------------------------------------------------------*
*& Report ZSD_CONTION_RECORD_U_R01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsd_contion_record_u_r01.

DATA : lt_con_rec    TYPE TABLE OF zcon_rec_t,
       gv_ctumode(1) VALUE 'N',
       gv_cupdate(1) VALUE 'A'.

DATA : bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE,
       messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.

FIELD-SYMBOLS : <ls_con_rec> TYPE zcon_rec_t.
CONSTANTS : c_b(2) VALUE '01',
            c_s(2) VALUE '02',
            c_e(2) VALUE '03',
            c_g(2) VALUE '04'.

SELECT * FROM zcon_rec_t INTO TABLE lt_con_rec.
DATA(lv_date) = sy-datum+6(2) && '.' && sy-datum+4(2) && '.' && sy-datum+0(4) .
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
""""""""""""""ADDED BY SKN ON 28.02.20220"""""""""""""""""""""""""
 IF <ls_con_rec>-vrkme IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input               = <ls_con_rec>-vrkme
       language             = sy-langu
     IMPORTING
       output               = <ls_con_rec>-vrkme.
    IF sy-subrc <> 0.
*     Implement suitable error handling here
    ENDIF.
ENDIF.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

  READ TABLE messtab ASSIGNING FIELD-SYMBOL(<ls_messtab>) WITH KEY msgtyp = 'E'.
  IF sy-subrc <> 0.
    READ TABLE messtab ASSIGNING <ls_messtab> WITH KEY msgtyp = 'S' msgid = 'VK' msgnr = '023'.
    IF sy-subrc = 0.
      PERFORM delete_entry.
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
  DELETE FROM zcon_rec_t WHERE werks = <ls_con_rec>-werks AND matnr = <ls_con_rec>-matnr AND batch = <ls_con_rec>-batch.
ENDFORM.
