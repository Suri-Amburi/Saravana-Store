*&---------------------------------------------------------------------*
*& Include          SAPMZMM_DIALYPRICE_CHNG_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GOODS_MOVEMENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM goods_movement .
  DATA : lw_goodsmvt_header	TYPE bapi2017_gm_head_01,
         lv_goodsmvt_code	  TYPE bapi2017_gm_code,
         li_goodsmvt_item   TYPE TABLE OF bapi2017_gm_item_create,
         lw_goodsmvt_item   TYPE bapi2017_gm_item_create,
         li_return          TYPE TABLE OF bapiret2,
         lw_return          TYPE bapiret2,
         lv_matdoc          TYPE bapi2017_gm_head_ret-mat_doc,

         lv_matdocumentyear TYPE bapi2017_gm_head_ret-doc_year,
         lt_matlist         TYPE TABLE OF ty_matlist.

  FIELD-SYMBOLS : <ls_item>          TYPE ty_matlist,
                  <ls_goodsmvt_item> TYPE bapi2017_gm_item_create.
************** >>>  start of changes by sjena on 07.02.2020 14:07:41 <<< **************
  REFRESH : li_goodsmvt_item,lt_matlist,li_return.
  CLEAR : lw_goodsmvt_item,lw_return,lw_goodsmvt_header,lv_matdoc.
************** >>>  end of changes by sjena on 07.02.2020 14:07:44 <<< **************
  lt_matlist[] = gt_matlist[].
  SORT lt_matlist BY trnsqty.
  DELETE lt_matlist WHERE avlstck IS INITIAL .
  DELETE lt_matlist WHERE trnsqty IS INITIAL.
  READ TABLE lt_matlist ASSIGNING FIELD-SYMBOL(<ls_matlis>) WITH KEY sellprice = 0.
  IF sy-subrc = 0 AND gv_rstore <> c_mess.
    DATA(lv_msg) = 'Selling price is 0 for '  && <ls_matlis>-matnr.
    MESSAGE lv_msg TYPE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
***  Start of Changes By Suri : 23.04.2020
***  For Mess
*** For Mess - Consumption - 201 Movement Type
  IF gv_rstore = c_mess.
*** Get GL Account & Cost Center Details
    SELECT SINGLE * FROM zgl_acc_t INTO @DATA(ls_gl) WHERE werks = @gv_splant AND wwgha = @c_class.
*** FILL THE BAPI HEADER STRUCTURE DETAILS
    lw_goodsmvt_header-pstng_date       = sy-datum.
    lw_goodsmvt_header-doc_date         = sy-datum.
    lw_goodsmvt_header-pr_uname         = sy-uname.
    lw_goodsmvt_header-ver_gr_gi_slip   = 1.
    lv_goodsmvt_code                    = c_03.
    LOOP AT lt_matlist ASSIGNING <ls_item>.
      APPEND INITIAL LINE TO li_goodsmvt_item ASSIGNING <ls_goodsmvt_item>.
      <ls_goodsmvt_item>-material     = <ls_goodsmvt_item>-material_long   = <ls_item>-matnr.
      <ls_goodsmvt_item>-move_type    = c_201.
      <ls_goodsmvt_item>-plant        = <ls_item>-splant.
      <ls_goodsmvt_item>-stge_loc     = <ls_item>-sstloc.
      <ls_goodsmvt_item>-entry_qnt    = <ls_item>-trnsqty.
      <ls_goodsmvt_item>-entry_uom    = <ls_item>-meins.
      <ls_goodsmvt_item>-gl_account   = ls_gl-gl_account.
      <ls_goodsmvt_item>-costcenter   = ls_gl-costcenter.
    ENDLOOP.
  ELSE.
*** For 303
    lw_goodsmvt_header-pstng_date = sy-datum.
    lw_goodsmvt_header-doc_date   = sy-datum.
    lv_goodsmvt_code              = '04'.
    LOOP AT lt_matlist INTO DATA(wa_item).
      lw_goodsmvt_item-material       = wa_item-matnr.   "|{ wa_item-matnr ALPHA = IN }|.
      lw_goodsmvt_item-plant          = wa_item-splant.
      lw_goodsmvt_item-stge_loc       = wa_item-sstloc.
      lw_goodsmvt_item-move_type      = '303'.
      lw_goodsmvt_item-entry_qnt      = wa_item-trnsqty.
      lw_goodsmvt_item-entry_uom      = wa_item-meins.
*    lw_goodsmvt_item-po_number      = wa_item-ebeln.
*    lw_goodsmvt_item-po_item        = wa_item-ebelp.
      lw_goodsmvt_item-move_mat       = wa_item-matnr.     "|{ wa_item-matnr ALPHA = IN }|.
      lw_goodsmvt_item-move_plant     = wa_item-rstore.
      lw_goodsmvt_item-move_stloc     = wa_item-rstloc.
      lw_goodsmvt_item-mvt_ind        = ' '.
      APPEND lw_goodsmvt_item TO li_goodsmvt_item.
    ENDLOOP.
  ENDIF.
  BREAK samburi.
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = lw_goodsmvt_header
      goodsmvt_code    = lv_goodsmvt_code
    IMPORTING
      materialdocument = lv_matdoc
      matdocumentyear  = lv_matdocumentyear
    TABLES
      goodsmvt_item    = li_goodsmvt_item
      return           = li_return.

  IF lv_matdoc IS NOT INITIAL.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    IF gv_splant <> c_mess.
      PERFORM update_condition.
    ENDIF.

    MESSAGE lv_matdoc && 'Goods transfer successful ' TYPE 'S'.
    "Call Transfer Order Form
    SUBMIT zmm_transfer_order WITH p_mblnr = lv_matdoc
                              WITH p_mjahr = lv_matdocumentyear
                              AND RETURN .

  ELSE.
    "Goods Movement Failed
    MESSAGE 'Goods transfer failed' TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MATLIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_matlist .
  TYPES: lt_tab1 TYPE STANDARD TABLE OF char90 WITH EMPTY KEY,
         lt_tab2 TYPE STANDARD TABLE OF char30 WITH EMPTY KEY,
         BEGIN OF ty_objek,
           objek TYPE clint,
         END OF ty_objek,
         BEGIN OF ty_matkl,
           class TYPE matkl,
         END OF ty_matkl.
  DATA: lt_matkl   TYPE STANDARD TABLE OF ty_matkl,
        lt_ksskt   TYPE STANDARD TABLE OF ty_objek,
        ls_matlist TYPE ty_matlist,
        lv_sno     TYPE i,
        lv_margin  TYPE bprei,
        lv_sydatum TYPE datum.

  CONSTANTS : c_zmkp(4) VALUE 'ZMKP'.
  lv_sydatum = sy-datum - 60.
  CHECK gv_rstore IS NOT INITIAL.
  IF gv_rstore = c_mess.
    PERFORM get_stcok_deatils.
  ELSE.
    SELECT SINGLE clint FROM klah INTO gv_clint WHERE class = c_class.
    IF sy-subrc = 0 AND gv_clint IS NOT INITIAL.
      SELECT kssk~objek, kssk~clint FROM kssk
        INNER JOIN klah ON klah~clint = kssk~clint
        INTO TABLE @DATA(lt_kssk) WHERE klah~clint = @gv_clint.
      CHECK lt_kssk IS NOT INITIAL.
      lt_ksskt = VALUE lt_tab1( FOR ls_tab1 IN lt_kssk ( ls_tab1-objek ) ).
      SELECT clint, class FROM klah
        INTO TABLE @DATA(lt_klah) FOR ALL ENTRIES IN @lt_ksskt
        WHERE clint = @lt_ksskt-objek.

      lt_matkl = VALUE lt_tab2( FOR ls_tab2 IN lt_klah ( ls_tab2-class ) ).

      SELECT mara~matnr, mara~matkl, mara~meins, makt~maktx FROM mara
        INNER JOIN makt ON makt~matnr = mara~matnr
        INTO TABLE @DATA(lt_mara) FOR ALL ENTRIES IN @lt_matkl
        WHERE matkl = @lt_matkl-class.

      SELECT mseg~mblnr, mseg~mjahr, ekko~aedat, ekko~lifnr, ekpo~ebeln, ekpo~ebelp, ekpo~matnr, ekpo~matkl, ekpo~werks, ekpo~lgort, ekpo~menge, ekpo~netpr
        FROM nsdm_v_mseg AS mseg
        INNER JOIN ekpo AS ekpo ON ekpo~ebeln = mseg~ebeln AND ekpo~ebelp = mseg~ebelp
        INNER JOIN  ekko AS ekko ON ekko~ebeln = ekpo~ebeln
        INTO TABLE @DATA(lt_ekpo) FOR ALL ENTRIES IN @lt_mara
        WHERE mseg~matnr = @lt_mara-matnr AND mseg~werks = @gv_splant AND ekko~loekz <> 'X' AND mseg~cpudt_mkpf BETWEEN @lv_sydatum AND @sy-datum AND mseg~bwart = '101'.

      IF lt_ekpo IS NOT INITIAL.
*** Material Margin
        SELECT a515~matnr , konp~kbetr FROM konp
               INNER JOIN a515 AS a515 ON konp~knumh = a515~knumh INTO TABLE @DATA(lt_konp_matnr)
               FOR ALL ENTRIES IN @lt_ekpo
               WHERE a515~matnr = @lt_ekpo-matnr
               AND a515~kschl = @c_zmkp AND datab LE @sy-datum AND datbi GE @sy-datum AND loevm_ko = @space.
      ENDIF.
*** For Latest PO
      SORT lt_ekpo BY mblnr DESCENDING.
*** End of Chanes By Suri : 14.02.2020
      SELECT matnr, werks, lgort, labst INTO TABLE @DATA(gt_mard) FROM mard
        FOR ALL ENTRIES IN @lt_mara
        WHERE matnr = @lt_mara-matnr AND werks = @gv_splant AND lgort = 'FG01' and labst > 0.

      "Sorting Required for binary search / Getting SY-SUBRC = 8 at the time of read
      SORT gt_mard BY matnr werks lgort.
*    SORT lt_konp BY matkl .
      SORT lt_konp_matnr BY matnr.
      REFRESH: gt_matlist.
      LOOP AT lt_mara INTO DATA(ls_mara).
        lv_sno = lv_sno + 1.
        ls_matlist-sno = lv_sno.
        ls_matlist-matnr = ls_mara-matnr.
        ls_matlist-maktx = ls_mara-maktx.
        ls_matlist-meins = ls_mara-meins.
        ls_matlist-matkl = ls_mara-matkl.  """ ADDDED ON 07.03.2020

        READ TABLE lt_ekpo INTO DATA(ls_ekpo) WITH KEY matnr = ls_mara-matnr werks = gv_splant.
        IF sy-subrc = 0.
          "Displaying Only Entries With Purchase Price
          ls_matlist-prchprice = ls_ekpo-netpr.
          READ TABLE lt_konp_matnr INTO DATA(ls_konp) WITH KEY matnr = ls_ekpo-matnr .
          IF sy-subrc IS INITIAL.
            lv_margin = ls_ekpo-netpr * ( ls_konp-kbetr / 10 ) / 100.
          ENDIF.
*** End of Changes By Suri : 14.02.2020
          ls_matlist-sellprice = ls_ekpo-netpr + lv_margin.
          ls_matlist-sellprice = ceil( ls_matlist-sellprice ).
          ls_matlist-ebeln     = ls_ekpo-ebeln.
          ls_matlist-ebelp     = ls_ekpo-ebelp.
          ls_matlist-splant    = gv_splant.
          ls_matlist-rstore    = gv_rstore.
          ls_matlist-sstloc    = ls_ekpo-lgort.
          ls_matlist-rstloc    = 'FG01'.
        ELSE.
          "Skip Purchase Order Not Avlbl. in system
          CLEAR : ls_matlist.
          CONTINUE.
        ENDIF.
        READ TABLE gt_mard INTO DATA(ls_mard) WITH KEY matnr = ls_mara-matnr werks = gv_splant lgort = 'FG01'.
        IF sy-subrc IS INITIAL.
          ls_matlist-avlstck = ls_mard-labst.
        ENDIF.
        APPEND ls_matlist TO gt_matlist.
        CLEAR: ls_matlist.
      ENDLOOP.
      SORT gt_matlist BY matnr avlstck.
    ENDIF.
    DELETE gt_matlist WHERE avlstck IS INITIAL.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_CONDITION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_condition .
  DATA: lt_matlst     TYPE TABLE OF ty_matlist,
        gv_ctumode(1) VALUE 'N',
        gv_cupdate(1) VALUE 'A',

        lv_sprice(20) TYPE c.
  DATA: lv_vkorg TYPE t001w-vkorg VALUE '1000',
        lv_vtweg TYPE t001w-vtweg VALUE '10',
        r_fisel  TYPE RANGE OF  werks_d,
        r_matnr  TYPE RANGE OF  matnr.

  FIELD-SYMBOLS : <ls_matlst> TYPE ty_matlist.
  lt_matlst[] = gt_matlist[].
  SORT lt_matlst BY trnsqty.
  DELETE lt_matlst WHERE avlstck IS INITIAL .
  DELETE lt_matlst WHERE trnsqty IS INITIAL.

  LOOP AT lt_matlst ASSIGNING <ls_matlst>.
    REFRESH : bdcdata , messcoll.
*    PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'RV13A-KSCHL'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '/00'.
*    PERFORM bdc_field       USING 'RV13A-KSCHL'
*                                  'ZF&V'.
*    PERFORM bdc_dynpro      USING 'SAPLV14A' '0100'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'RV130-SELKZ(06)'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '=WEIT'.
*    PERFORM bdc_field       USING 'RV130-SELKZ(01)'
*                                  ''.
*    PERFORM bdc_field       USING 'RV130-SELKZ(06)'
*                                  'X'.
*    PERFORM bdc_dynpro      USING 'SAPMV13A' '1406'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'KONP-KONWA(01)'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '/00'.
*    PERFORM bdc_field       USING 'KOMG-WERKS'
*                                  <ls_matlst>-rstore.
*    PERFORM bdc_field       USING 'KOMG-MATNR(01)'
*                                  <ls_matlst>-matnr.
*    lv_sprice = <ls_matlst>-sellprice.
*    CONDENSE: lv_sprice.
**    REPLACE  '.' WITH ',' INTO  lv_sprice.
*    PERFORM bdc_field       USING 'KONP-KBETR(01)'
*                                   lv_sprice.   "<ls_matlst>-sellprice.
*    PERFORM bdc_field       USING 'KONP-KONWA(01)'
*                                  'INR'.
*    PERFORM bdc_dynpro      USING 'SAPMV13A' '1406'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'KOMG-MATNR(01)'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '=SICH'.
**    BREAK-POINT.

*** Start of Changes By Suri : 11.02.2020
*** Material level
*    PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'RV13A-KSCHL'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '/00'.
*    PERFORM bdc_field       USING 'RV13A-KSCHL'
*                                  'ZWSI'.
*    PERFORM bdc_dynpro      USING 'SAPMV13A' '1515'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'KONP-KONWA(01)'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '/00'.
*    PERFORM bdc_field       USING 'KOMG-MATNR(01)'
*                                  <ls_matlst>-matnr.        "'A24220'.
*    lv_sprice = <ls_matlst>-sellprice.
*    CONDENSE: lv_sprice.
**    REPLACE  '.' WITH ',' INTO  lv_sprice.
*
*    PERFORM bdc_field       USING 'KONP-KBETR(01)'
*                                  lv_sprice .       "'              40'.
*    PERFORM bdc_field       USING 'KONP-KONWA(01)'
*                                  'INR'.
*    PERFORM bdc_dynpro      USING 'SAPMV13A' '1515'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'KOMG-MATNR(01)'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '=SICH'.

*** Start of Changes By Suri : 27.02.2020 : For Plant wise Price
    PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RV13A-KSCHL'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ANTA'.
    PERFORM bdc_field       USING 'RV13A-KSCHL'
                                  'ZSMP'.
    PERFORM bdc_dynpro      USING 'SAPLV14A' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RV130-SELKZ(06)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=WEIT'.
    PERFORM bdc_field       USING 'RV130-SELKZ(01)'
                                  ''.
    PERFORM bdc_field       USING 'RV130-SELKZ(06)'
                                  'X'.
    PERFORM bdc_dynpro      USING 'SAPMV13A' '1406'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KONP-KONWA(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'KOMG-WERKS'
                                  gv_rstore.                "'SSTN'.
    PERFORM bdc_field       USING 'KOMG-MATNR(01)'
                                  <ls_matlst>-matnr.        "'A24215'.
    lv_sprice = <ls_matlst>-sellprice.
    CONDENSE: lv_sprice.
*    REPLACE  '.' WITH ',' INTO  lv_sprice.
    PERFORM bdc_field       USING 'KONP-KBETR(01)'
                                  lv_sprice.
    PERFORM bdc_field       USING 'KONP-KONWA(01)'
                                  'inr'.
    PERFORM bdc_dynpro      USING 'SAPMV13A' '1406'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KOMG-MATNR(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=SICH'.
*** End of Changes By Suri : 27.02.2020
*** End of Changes By Suri : 11.02.2020
    CALL TRANSACTION 'VK11' WITH AUTHORITY-CHECK USING bdcdata
                          MODE   gv_ctumode
                          UPDATE gv_cupdate
                          MESSAGES INTO messcoll.
*    BREAK-POINT.
    DATA: l_mstring(480).
    LOOP AT messcoll INTO DATA(msg).
      MESSAGE ID     msg-msgid
              TYPE   msg-msgtyp
              NUMBER msg-msgnr
              INTO l_mstring
              WITH msg-msgv1
                   msg-msgv2
                   msg-msgv3
                   msg-msgv4.
*          WRITE: / MESSTAB-MSGTYP, L_MSTRING(250).
    ENDLOOP.
    APPEND VALUE #( low = <ls_matlst>-matnr option = 'EQ' sign = 'I' ) TO r_matnr.
  ENDLOOP.
*** Start of Change : Suri : 27.02.2020 : 12:04 PM
***********Trigget Material IDoc for price changes ****************
*  APPEND VALUE #( low = 'SSVG' option = 'EQ' sign = 'I' ) TO r_fisel.
*  SUBMIT zzrwdposan WITH pa_vkorg = lv_vkorg
*                    WITH pa_vtweg = lv_vtweg
*                    WITH so_fisel IN r_fisel[]
*                    WITH pa_art   = 'X'
*                    WITH so_matar IN r_matnr[]
*                    AND RETURN EXPORTING LIST TO MEMORY.
*** End of Change : Suri : 27.02.2020 : 12:04 PM
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
  DATA: lw_bdcdata TYPE bdcdata.
  lw_bdcdata-program  = program.
  lw_bdcdata-dynpro   = dynpro.
  lw_bdcdata-dynbegin = 'X'.
  APPEND lw_bdcdata TO bdcdata.
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
  DATA: lw_bdcdataf TYPE bdcdata.
*  IF fval <> nodata.
  lw_bdcdataf-fnam = fnam.
  lw_bdcdataf-fval = fval.
  APPEND lw_bdcdataf TO bdcdata.
*  ENDIF.
ENDFORM.


FORM get_stcok_deatils.

  FIELD-SYMBOLS : <ls_matlist> TYPE ty_matlist.

  SELECT
     mara~matnr,
     mara~meins,
     mara~matkl,
     makt~maktx,
     mard~lgort,
     mard~labst
     INTO TABLE @DATA(lt_stock)
     FROM mard AS mard
     INNER JOIN mara AS mara ON mara~matnr = mard~matnr
     INNER JOIN makt AS makt ON makt~matnr = mara~matnr
     INNER JOIN klah AS klah ON klah~klart = '026' AND  klah~class = mara~matkl    " Material Group
     INNER JOIN kssk AS kssk  ON kssk~objek = klah~clint
     INNER JOIN klah AS klah1 ON kssk~clint = klah1~clint                          " Hierarchy Group
     WHERE mard~werks = @gv_splant AND klah1~class = @c_class AND mard~labst > 0.

  FIELD-SYMBOLS : <ls_stock> LIKE LINE OF lt_stock.
  IF sy-subrc IS INITIAL.
    SORT lt_stock BY matnr.
    LOOP AT lt_stock ASSIGNING <ls_stock>.
      APPEND INITIAL LINE TO gt_matlist ASSIGNING <ls_matlist>.
      <ls_matlist>-avlstck = <ls_stock>-labst.
      <ls_matlist>-sstloc  = <ls_stock>-lgort.
      <ls_matlist>-matnr   = <ls_stock>-matnr.
      <ls_matlist>-maktx   = <ls_stock>-maktx.
      <ls_matlist>-matkl   = <ls_stock>-matkl.
      <ls_matlist>-meins   = <ls_stock>-meins.
      <ls_matlist>-splant  = gv_splant.
    ENDLOOP.
  ENDIF.
ENDFORM.
