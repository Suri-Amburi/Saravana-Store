*&---------------------------------------------------------------------*
*& Include          SAPMZMAT_TRANSFER_F01
*&---------------------------------------------------------------------*

FORM goods_mvt .

  CALL FUNCTION 'MESSAGES_INITIALIZE'
    EXCEPTIONS
      log_not_active       = 1
      wrong_identification = 2
      OTHERS               = 3.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
      WHEN 2.
      WHEN 3.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.
******************************************************************************************
  SELECT matnr charg licha  FROM mch1 INTO TABLE it_mch1 FOR ALL ENTRIES IN it_item
         WHERE  charg = it_item-charg2
         AND    matnr = it_item-matnr2.

  wa_goodsmvt_header-pstng_date = wa_header-budat.
  wa_goodsmvt_header-doc_date   = sy-datum.
  wa_goodsmvt_code = '06'.
  CLEAR it_goodsmvt_item.
  LOOP AT it_item INTO wa_item.
    wa_goodsmvt_item-move_type     = '309'.
*    wa_goodsmvt_item-spec_stock    = 'Q'.
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          input  = wa_item-matnr
*        IMPORTING
*          output = wa_item-matnr.

*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          input  = wa_item-matnr2
*        IMPORTING
*          output = wa_item-matnr2.


    wa_goodsmvt_item-material_long     = wa_item-matnr.
    wa_goodsmvt_item-move_mat_long     = wa_item-matnr2.
    wa_goodsmvt_item-entry_qnt     = wa_item-menge.
    wa_goodsmvt_item-entry_uom     = wa_item-meins.
    wa_goodsmvt_item-plant         = wa_item-werks.
*  wa_goodsmvt_item-move_plant    = wa_item-werks2.
    wa_goodsmvt_item-stge_loc      = wa_item-lgort.
    wa_goodsmvt_item-move_stloc      = wa_item-lgort2.
    wa_goodsmvt_item-batch         = wa_item-charg.
    wa_goodsmvt_item-move_batch    = wa_item-charg2.
*    wa_goodsmvt_item-val_wbs_elem  = wa_item-pspnr.
*    wa_goodsmvt_item-wbs_elem      = wa_item-pspnr.


    READ TABLE it_mch1 INTO wa_mch1 WITH KEY charg = wa_item-charg2 matnr = wa_item-matnr2.
    IF sy-subrc <> 0.



      wa_material-material_long = wa_item-matnr2.
      wa_batch-batch            = wa_item-charg2.
      wa_plant-plant            = wa_item-werks.
      wa_batchattributes-vendrbatch = wa_item-licha.

      CALL FUNCTION 'BAPI_BATCH_CREATE'
        EXPORTING
*         material        = wa_material-material_long
          batch           = wa_batch-batch
          plant           = wa_plant-plant
          batchattributes = wa_batchattributes
*         BATCHCONTROLFIELDS         =
*         BATCHSTORAGELOCATION       =
*         INTERNALNUMBERCOM          =
*         EXTENSION1      =
*         MATERIAL_EVG    =
          material_long   = wa_material-material_long
        IMPORTING
          batch           = wa_batch2-batch
          batchattributes = wa_batchattributes2
        TABLES
          return          = it_return.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' .

    ENDIF.
      wa_goodsmvt_item-val_type       = wa_item-charg.

    APPEND wa_goodsmvt_item TO it_goodsmvt_item.
  ENDLOOP.
***************************************************************************************

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = wa_goodsmvt_header
      goodsmvt_code    = wa_goodsmvt_code
*     TESTRUN          = ' '
*     GOODSMVT_REF_EWM =
*     GOODSMVT_PRINT_CTRL           =
    IMPORTING
      goodsmvt_headret = wa_goodsmvt_headret
*     MATERIALDOCUMENT =
*     MATDOCUMENTYEAR  =
    TABLES
      goodsmvt_item    = it_goodsmvt_item
*     GOODSMVT_SERIALNUMBER         =
      return           = it_return
*     GOODSMVT_SERV_PART_DATA       =
*     EXTENSIONIN      =
*    GOODSMVT_ITEM_CWM             =..
    .
  IF wa_goodsmvt_headret-mat_doc IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    CLEAR: it_item, p_file.

    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        arbgb                  = 'MIGO'
        msgty                  = 'S'
        msgv1                  = wa_goodsmvt_headret-mat_doc
        msgv2                  = wa_goodsmvt_headret-doc_year
        msgv3                  = ''
        msgv4                  = ''
        txtnr                  = '012'
      EXCEPTIONS
        message_type_not_valid = 1
        not_active             = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 1.
        WHEN 2.
        WHEN 3.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.



  ELSEIF it_return IS NOT INITIAL.

    PERFORM e_m.                     "for showing error message

  ENDIF.
*  ENDLOOP.

  CALL FUNCTION 'MESSAGES_STOP'
    EXCEPTIONS
      a_message = 1
      e_message = 2
      i_message = 3
      w_message = 4
      OTHERS    = 5.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
      WHEN 2.
      WHEN 3.
      WHEN 4.
      WHEN 5.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.

  CALL FUNCTION 'MESSAGES_SHOW'
    EXPORTING
      show_linno         = '*'
    EXCEPTIONS
      inconsistent_range = 1
      no_messages        = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
      WHEN 2.
      WHEN 3.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.
*  ENDLOOP.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form E_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM e_m .
  LOOP AT it_return INTO wa_return.

    ls_smesg-arbgb = wa_return-id.
    ls_smesg-msgty = wa_return-type.
    ls_smesg-msgv1 = wa_return-message_v1.
    ls_smesg-msgv2 = wa_return-message_v2.
    ls_smesg-msgv3 = wa_return-message_v3.
    ls_smesg-msgv4 = wa_return-message_v4.
    ls_smesg-txtnr = wa_return-number.

    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        arbgb                  = ls_smesg-arbgb
        msgty                  = ls_smesg-msgty
        msgv1                  = ls_smesg-msgv1
        msgv2                  = ls_smesg-msgv2
        msgv3                  = ls_smesg-msgv3
        msgv4                  = ls_smesg-msgv4
        txtnr                  = ls_smesg-txtnr
      EXCEPTIONS
        message_type_not_valid = 1
        not_active             = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 1.
        WHEN 2.
        WHEN 3.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.


  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validate_item .
  DATA:lv_meins  TYPE meins,
       lv_werks  TYPE werks_d,
       lv_charg  TYPE charg_d,
       lv_lgort  TYPE lgort_d,
       lv_lgort1 TYPE lgort_d,
       lv_clabs  TYPE labst,
       lv_meins2 TYPE meins_d,
       lv_mtart  TYPE mtart,
       lv_licha  TYPE lichn.


  IF wa_item-matnr IS INITIAL.
    lv_c = 'WA_ITEM-MATNR'.
    SET CURSOR FIELD lv_c.
    MESSAGE 'ENTER MATERIAL' TYPE 'E'.
  ELSEIF wa_item-matnr IS NOT INITIAL.
    SELECT SINGLE meins FROM mara INTO lv_meins
      WHERE matnr = wa_item-matnr.
    IF sy-subrc NE 0.
      lv_c = 'WA_ITEM-MATNR'.
      SET CURSOR FIELD lv_c.
      MESSAGE TEXT-101 TYPE 'E'.
    ENDIF.
  ENDIF.

*****  IF wa_item-charg IS INITIAL.
*****    lv_c = 'WA_ITEM-CHARG'.
*****    SET CURSOR FIELD lv_c.
*****    MESSAGE 'ENTER BATCH' TYPE 'E'.
*****  ELSEIF wa_item-charg IS NOT INITIAL.
*****    SELECT SINGLE charg FROM mch1 INTO lv_charg
*****      WHERE charg = wa_item-charg
*****      AND   matnr = wa_item-matnr.
*****    IF sy-subrc NE 0.
*****      lv_c = 'WA_ITEM-CHARG'.
*****      SET CURSOR FIELD lv_c.
*****      MESSAGE TEXT-105 TYPE 'E'.
*****    ENDIF.
*****  ENDIF.


*  IF wa_item-licha IS INITIAL.
*    lv_c = 'WA_ITEM-LICHA'.
*    SET CURSOR FIELD lv_c.
*    MESSAGE TEXT-114 TYPE 'E'.
* IF wa_item-licha IS NOT INITIAL.
*    SELECT SINGLE licha FROM mch1 INTO lv_licha
*      WHERE licha = wa_item-licha
*      AND charg = wa_item-charg
*      AND   matnr = wa_item-matnr.
*    IF sy-subrc NE 0.
*      lv_c = 'WA_ITEM-LICHA'.
*      SET CURSOR FIELD lv_c.
*      MESSAGE TEXT-115 TYPE 'E'.
*    ENDIF.
*  ENDIF.


  IF wa_item-werks IS INITIAL.
    lv_c = 'WA_ITEM-WERKS'.
    SET CURSOR FIELD lv_c.
    MESSAGE 'ENTER PLANT' TYPE 'E'.
  ELSEIF wa_item-werks IS NOT INITIAL.
    SELECT SINGLE werks FROM t001w INTO lv_werks
      WHERE werks = wa_item-werks.
    IF sy-subrc NE 0.
      lv_c = 'WA_ITEM-WERKS'.
      SET CURSOR FIELD lv_c.
      MESSAGE TEXT-103 TYPE 'E'.
    ENDIF.
  ENDIF.

  IF wa_item-lgort IS INITIAL.
    lv_c = 'WA_ITEM-LGORT'.
    SET CURSOR FIELD lv_c.
    MESSAGE 'ENTER ST.LOC'  TYPE 'E'.
  ELSEIF wa_item-lgort IS NOT INITIAL.
    SELECT SINGLE lgort FROM t001l INTO lv_lgort
      WHERE lgort = wa_item-lgort
      AND   werks = wa_item-werks.
    IF sy-subrc NE 0.
      lv_c = 'WA_ITEM-LGORT'.
      SET CURSOR FIELD lv_c.
      MESSAGE TEXT-107 TYPE 'E'.
    ENDIF.
  ENDIF.

*  IF wa_item-menge IS INITIAL.
*    lv_c = 'WA_ITEM-MENGE'.
*    SET CURSOR FIELD lv_c.
*    MESSAGE TEXT-108 TYPE 'E'.
*  ELSEIF wa_item-menge IS NOT INITIAL.
*    SELECT SINGLE prlab FROM mspr INTO lv_clabs
*      WHERE matnr = wa_item-matnr
*      AND   charg = wa_item-charg
*      AND   werks = wa_item-werks
*      AND   lgort = wa_item-lgort.
*    IF lv_clabs < wa_item-menge AND sy-ucomm <> 'DELT'.
*      lv_c = 'WA_ITEM-MENGE'.
*      SET CURSOR FIELD lv_c.
*      MESSAGE TEXT-109 TYPE 'E'.
*    ENDIF.
*  ENDIF.

  IF wa_item-meins IS INITIAL.
    lv_c = 'WA_ITEM-MEINS'.
    SET CURSOR FIELD lv_c.
    MESSAGE 'ENTER UOM' TYPE 'E'.
  ELSEIF wa_item-meins IS NOT INITIAL.
    SELECT SINGLE mtart FROM mara INTO lv_mtart
      WHERE meins = lv_meins
      AND   matnr = wa_item-matnr.
    IF sy-subrc NE 0.
      lv_c = 'WA_ITEM-MEINS'.
      SET CURSOR FIELD lv_c.
      MESSAGE TEXT-111 TYPE 'E'.
    ENDIF.
  ENDIF.

  IF wa_item-matnr2 IS INITIAL.
    lv_c = 'WA_ITEM-MATNR2'.
    SET CURSOR FIELD lv_c.
    MESSAGE 'ENTER MATERIAL2' TYPE 'E'.
  ELSEIF wa_item-matnr2 IS NOT INITIAL.
    SELECT SINGLE meins FROM mara INTO lv_meins2
      WHERE matnr = wa_item-matnr2.
    IF sy-subrc NE 0.
      lv_c = 'WA_ITEM-MATNR2'.
      SET CURSOR FIELD lv_c.
      MESSAGE TEXT-113 TYPE 'E'.
    ENDIF.
  ENDIF.

  IF wa_item-lgort2 IS INITIAL.
    lv_c = 'WA_ITEM-LGORT2'.
    SET CURSOR FIELD lv_c.
    MESSAGE 'ENTER ST.LOC 2' TYPE 'E'.
  ELSEIF wa_item-lgort2 IS NOT INITIAL.
    SELECT SINGLE lgort FROM t001l INTO lv_lgort1
      WHERE lgort = wa_item-lgort2
      AND   werks = wa_item-werks.
    IF sy-subrc NE 0.
      lv_c = 'WA_ITEM-LGORT2'.
      SET CURSOR FIELD lv_c.
      MESSAGE TEXT-107 TYPE 'E'.
    ENDIF.
  ENDIF.



ENDFORM.
