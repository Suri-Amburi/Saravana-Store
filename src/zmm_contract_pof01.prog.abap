*&---------------------------------------------------------------------*
*& Include          ZMM_CONTRACT_POF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form RETRIEVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM retrieve_data .
  SELECT ebeln
           bukrs
           bsart
           aedat
           spras
           lifnr
           ekgrp
           bedat
           knumv
           approver1
           FROM ekko
           INTO TABLE it_ekko
           WHERE ebeln = p_ebeln AND bsart = 'ZPRO' AND spras = 'EN'.
  IF it_ekko IS NOT INITIAL.
    SELECT ebeln
           ebelp
           werks
           matnr
           mwskz
           menge
           meins
           netpr
           peinh
           zzset_material
           netwr
           bukrs
           retpo FROM ekpo
           INTO TABLE it_ekpo
           FOR ALL ENTRIES IN it_ekko
          WHERE ebeln = it_ekko-ebeln.
    SELECT lifnr
           land1
           name1
           ort01
           regio
           stras
           stcd3
           adrnr
           FROM lfa1 INTO TABLE it_lfa1
        FOR ALL ENTRIES IN it_ekko
          WHERE lifnr = it_ekko-lifnr.
  ENDIF.
  IF it_ekpo IS NOT INITIAL.
    SELECT werks
           name1
           stras
           ort01
           land1
           adrnr
           FROM t001w INTO TABLE it_t001w
           FOR ALL ENTRIES IN it_ekpo
           WHERE werks = it_ekpo-werks.
*    SELECT LIFNR
*           LAND1
*           NAME1
*           ORT01
*           REGIO
*           STRAS
*           STCD3
*           ADRNR
*           FROM LFA1 INTO TABLE IT_LFA1
*           FOR ALL ENTRIES IN IT_EKPO
*           WHERE WERKS = IT_EKPO-WERKS.
    SELECT matnr
           ean11
           matkl FROM mara INTO TABLE it_mara
           FOR ALL ENTRIES IN it_ekpo
           WHERE matnr = it_ekpo-matnr.
    SELECT matnr
           spras
           maktx
           FROM makt INTO TABLE it_makt
           FOR ALL ENTRIES IN it_ekpo
           WHERE matnr = it_ekpo-matnr.

  ENDIF.
  SELECT addrnumber
         name1
         city1
         street
         str_suppl1
         str_suppl2
         country
         langu
         region
         post_code1
         FROM adrc
         INTO TABLE it_adrc
         FOR ALL ENTRIES IN it_t001w
         WHERE addrnumber = it_t001w-adrnr.


IF it_ekko IS NOT INITIAL .
       SELECT bukrs
              adrnr
              FROM t001
              INTO TABLE it_t001
              FOR ALL ENTRIES IN it_ekko
              WHERE bukrs = it_ekko-bukrs.
*
       SELECT bukrs
              gstin
              FROM j_1bbranch
              INTO TABLE it_j_1bbranch
              FOR ALL ENTRIES IN it_ekko
              WHERE bukrs = it_ekko-bukrs.
*
         SELECT eknam
                ekgrp
                FROM t024
                INTO TABLE it_t024
                FOR ALL ENTRIES IN it_ekko
                WHERE ekgrp = it_ekko-ekgrp.
           ENDIF.

  SELECT  a~matnr
         SUM( a~menge )
          a~meins
          a~ebeln
          b~maktx  INTO TABLE it_matdoc FROM matdoc AS a INNER JOIN makt AS b
                   ON ( a~matnr = b~matnr AND b~spras = sy-langu )
                   WHERE a~ebeln = p_ebeln
                   AND   a~xauto <> 'X'
                   AND   a~bwart = '541' GROUP BY a~matnr a~meins a~ebeln b~maktx.


  READ TABLE it_ekko INTO wa_ekko INDEX 1.
  wa_hdr-ebeln = wa_ekko-ebeln.
  wa_hdr-bedat = wa_ekko-bedat.
  wa_hdr-approver1 = wa_ekko-approver1.
  READ TABLE it_adrc INTO wa_adrc INDEX 1." WITH KEY ADDRNUMBER = WA_T001W-ADRNR.
  wa_hdr-addrnumber = wa_adrc-addrnumber.
  wa_hdr-name1       = wa_adrc-name1        .
  wa_hdr-city1       = wa_adrc-city1        .
  wa_hdr-street      = wa_adrc-street       .
  wa_hdr-str_suppl1  = wa_adrc-str_suppl1   .
  wa_hdr-str_suppl2  = wa_adrc-str_suppl2   .
  wa_hdr-country     = wa_adrc-country      .
  wa_hdr-langu       = wa_adrc-langu        .
  wa_hdr-region      = wa_adrc-region       .
  wa_hdr-post_code1  = wa_adrc-post_code1   .
  READ TABLE it_lfa1 INTO wa_lfa1  INDEX 1.
  wa_hdr-v_lifnr    =   wa_lfa1-lifnr   .
  wa_hdr-v_land1    =   wa_lfa1-land1   .
  wa_hdr-v_name1    =   wa_lfa1-name1   .
  wa_hdr-v_ort01    =   wa_lfa1-ort01   .
  wa_hdr-v_regio    =   wa_lfa1-regio   .
  wa_hdr-v_stras    =   wa_lfa1-stras   .
  wa_hdr-v_stcd3    =   wa_lfa1-stcd3   .
  wa_hdr-v_adrnr    =   wa_lfa1-adrnr   .
  READ TABLE it_j_1bbranch INTO wa_j_1bbranch INDEX 1.
  wa_hdr-gstin     =  wa_j_1bbranch-gstin.

*  READ TABLE it_matdoc ASSIGNING FIELD-SYMBOL(<fs1>) WITH KEY xblnr = wa_hdr-ebeln.
*   IF sy-subrc = 0.
*     wa_hdr-cmaktx = <fs1>-maktx.
*     wa_hdr-cmenge = <fs1>-menge.
*     wa_hdr-cmeins  = <fs1>-meins.
*   ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_data .
  LOOP AT it_ekpo INTO wa_ekpo.
    sl_no = sl_no + 1.
    wa_zmain-sl_no = sl_no.
    wa_zmain-menge = wa_ekpo-menge.
    wa_zmain-meins = wa_ekpo-meins.

    READ TABLE it_mara INTO wa_mara WITH KEY matnr = wa_ekpo-matnr.
    IF sy-subrc = 0 .
      wa_zmain-matnr = wa_mara-matnr.
      wa_zmain-matkl = wa_mara-matkl.
      wa_zmain-ean11 = wa_mara-ean11.
    ENDIF.
    READ TABLE it_makt INTO wa_makt WITH KEY matnr = wa_ekpo-matnr.
    IF sy-subrc = 0.
      wa_zmain-maktx = wa_makt-maktx.
    ENDIF .
    tot_qty = tot_qty + wa_ekpo-menge.
    wa_zmain-tot_qty = tot_qty.

    APPEND wa_zmain TO it_zmain .
    CLEAR : wa_zmain.
  ENDLOOP.
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
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'ZCONTRACT_PO'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      fm_name            = f_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

 qr_code = p_ebeln.

  CALL FUNCTION f_name
    EXPORTING
*     ARCHIVE_INDEX    =
*     ARCHIVE_INDEX_TAB          =
*     ARCHIVE_PARAMETERS         =
*     CONTROL_PARAMETERS         =
*     MAIL_APPL_OBJ    =
*     MAIL_RECIPIENT   =
*     MAIL_SENDER      =
*     OUTPUT_OPTIONS   =
*     USER_SETTINGS    = 'X'
      wa_hdr           = wa_hdr
      qr_code          = qr_code
*  IMPORTING
*     DOCUMENT_OUTPUT_INFO       =
*     JOB_OUTPUT_INFO  =
*     JOB_OUTPUT_OPTIONS         =
    TABLES
      it_item          = it_zmain
      it_matdoc        = it_matdoc
    EXCEPTIONS
      formatting_error = 1
      internal_error   = 2
      send_error       = 3
      user_canceled    = 4
      OTHERS           = 5.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
