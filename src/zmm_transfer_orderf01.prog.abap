*&---------------------------------------------------------------------*
*& Include          ZMM_TRANSFER_ORDERF01
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

  SELECT SINGLE bwart FROM mseg INTO @DATA(lv_bwart) WHERE mblnr = @p_mblnr .

  IF lv_bwart = '303'.
    SELECT mblnr
           mjahr
           zeile
           bwart
           matnr
           werks
           lgort
           lifnr
           kunnr
           shkzg
           charg
           menge
           meins
           erfmg
           umwrk
           budat_mkpf
           cputm_mkpf
           usnam_mkpf
           FROM mseg
           INTO TABLE it_mseg
           WHERE mblnr =  p_mblnr AND bwart = '303'  AND shkzg = 'H'.
  ELSEIF lv_bwart = '305'.
    SELECT mblnr
           mjahr
           zeile
           bwart
           matnr
           werks
           lgort
           lifnr
           kunnr
           shkzg
           charg
           menge
           meins
           erfmg
           umwrk
           budat_mkpf
           cputm_mkpf
           usnam_mkpf
           FROM mseg
           INTO TABLE it_mseg
           WHERE mblnr =  p_mblnr AND bwart = '305' .

ELSEIF lv_bwart = '201'.
    SELECT mblnr
           mjahr
           zeile
           bwart
           matnr
           werks
           lgort
           lifnr
           kunnr
           shkzg
           charg
           menge
           meins
           erfmg
           umwrk
           budat_mkpf
           cputm_mkpf
           usnam_mkpf
           FROM mseg
           INTO TABLE it_mseg
           WHERE mblnr =  p_mblnr AND bwart = '201' .


  ENDIF.

  IF it_mseg IS NOT INITIAL.
    SELECT werks
           name1
           stras
           ort01
           land1
           adrnr
           j_1bbranch
           FROM t001w
           INTO TABLE it_t001w
           FOR ALL ENTRIES IN it_mseg
           WHERE werks = it_mseg-werks.

    SELECT werks
         name1
         stras
         ort01
         land1
         adrnr
         j_1bbranch
         FROM t001w
         INTO TABLE it_t001w2
         FOR ALL ENTRIES IN it_mseg
         WHERE werks = it_mseg-umwrk.

    SELECT matnr
      ean11
       FROM mara
      INTO TABLE it_mara
      FOR ALL ENTRIES IN it_mseg
      WHERE matnr = it_mseg-matnr.

    SELECT matnr
           spras
           maktx
           FROM makt
           INTO TABLE it_makt
           FOR ALL ENTRIES IN it_mara
           WHERE matnr = it_mara-matnr.
  ENDIF.

  IF it_t001w IS NOT INITIAL.
    SELECT bukrs
           branch
           gstin FROM j_1bbranch
           INTO TABLE it_j_1bbranch
           FOR ALL ENTRIES IN it_t001w
           WHERE branch = it_t001w-j_1bbranch .

    SELECT addrnumber
           name1
           city1
           street
           str_suppl1
           str_suppl2
           country
           langu
           region
           post_code1 FROM adrc
          INTO TABLE it_adrc
          FOR ALL ENTRIES IN it_t001w
          WHERE addrnumber = it_t001w-adrnr.
  ENDIF.




*  SELECT LIFNR
*         NAME1
*         FROM LFA1
*         INTO TABLE IT_LFA1
*         FOR ALL ENTRIES IN IT_MSEG
*         WHERE LIFNR = IT_MSEG-LIFNR.

  READ TABLE it_mseg INTO wa_mseg INDEX 1.
  wa_hdr-mblnr = wa_mseg-mblnr.
  wa_hdr-mjahr = wa_mseg-mjahr.
  wa_hdr-werks = wa_mseg-meins.
  wa_hdr-lifnr = wa_mseg-lifnr.
  wa_hdr-budat_mkpf = wa_mseg-budat_mkpf.
  wa_hdr-cputm_mkpf = wa_mseg-cputm_mkpf.
  wa_hdr-usnam_mkpf = wa_mseg-usnam_mkpf.

  READ TABLE it_j_1bbranch INTO wa_j_1bbranch INDEX 1.
  wa_hdr-gstin = wa_j_1bbranch-gstin.
  READ TABLE it_adrc INTO wa_adrc INDEX 1.
  wa_hdr-name1 = wa_adrc-name1.
*  CONDENSE : WA_HDR-NAME1.
  wa_hdr-post_code1 = wa_adrc-post_code1.
  wa_hdr-city1 = wa_adrc-city1.
*  READ TABLE IT_LFA1 INTO WA_LFA1 INDEX 1.
*  WA_HDR-V_NAME1 = WA_LFA1-NAME1.
  READ TABLE it_t001w2 INTO wa_t001w2 INDEX 1.
  wa_hdr-v_name1 = wa_t001w2-name1.


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
  LOOP AT it_mseg INTO wa_mseg.
    sl_no = sl_no + 1.
    wa_zmain-sl_no = sl_no.
    wa_zmain-menge = wa_mseg-menge.
    wa_zmain-meins = wa_mseg-meins.
    READ TABLE it_mara INTO wa_mara WITH KEY matnr = wa_mseg-matnr.
    wa_zmain-matnr = wa_mara-matnr.
    READ TABLE it_makt INTO wa_makt WITH KEY matnr = wa_mara-matnr.
    wa_zmain-maktx = wa_makt-maktx.
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
      formname           = 'ZTRAN_NOTE'
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
  CONCATENATE p_mblnr p_mjahr INTO qr_code SEPARATED BY '-'.
*  QR_CODE = P_MBLNR.
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
*     LV_QR_CODE       = P_QR
      wa_hdr           = wa_hdr
      qr_code          = qr_code
* IMPORTING
*     DOCUMENT_OUTPUT_INFO       =
*     JOB_OUTPUT_INFO  =
*     JOB_OUTPUT_OPTIONS         =
    TABLES
      it_item          = it_zmain
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
