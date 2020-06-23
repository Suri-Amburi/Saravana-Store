*&---------------------------------------------------------------------*
*& Include          SAPMZINWORD_DOC_T01
*&---------------------------------------------------------------------*

*** Data Decleration
*** types
TYPE-POOLS  : icon , slis.
TYPES :
  BEGIN OF ty_marc,
    matnr TYPE marc-matnr,
    steuc TYPE marc-steuc,
    stawn TYPE marc-stawn,
  END OF ty_marc.

TYPES :
  BEGIN OF ty_900,
    steuc TYPE a900-steuc,
    knumh TYPE a900-knumh,
    kbetr TYPE konp-kbetr,
  END OF ty_900.

TYPES :
  BEGIN OF ty_ekko,
    ebeln TYPE ekko-ebeln,
    aedat TYPE ekko-aedat,
    bsart TYPE esart,
    zbd1t TYPE dzbdet,
    lifnr TYPE ekko-lifnr,
    knumv TYPE ekko-knumv,
    frgke TYPE ekko-frgke,
    eindt TYPE eindt,
  END OF ty_ekko.

TYPES :
  BEGIN OF ty_mara,
    matnr    TYPE matnr,
    brand_id TYPE wrf_brand_id,
    ena11    TYPE ean11,
    numtp    TYPE numtp,
    xchpf    TYPE xchpf,
  END OF ty_mara.

*** TYPES DECLARATION FOR PO ITEM DATA
TYPES:
  BEGIN OF ty_ekpo,
    ebeln          TYPE ebeln,
    ebelp          TYPE ebelp,
    matnr          TYPE matnr,
    werks          TYPE werks_d,
    lgort          TYPE lgort_d,
    matkl          TYPE matkl,
    menge          TYPE bstmg,
    meins          TYPE bstme,
    netpr          TYPE bprei,
    netwr          TYPE bwert,
    mwskz          TYPE mwskz,
    uebto          TYPE uebto,
    ean11          TYPE ean11,
    zzset_material TYPE matnr,
    maktx          TYPE maktx,
    open_qty       TYPE bstmg,
  END OF ty_ekpo,

  BEGIN OF ty_item_scr,
    sno            TYPE int2,
    mandt          TYPE zinw_t_item-mandt,
    qr_code        TYPE zinw_t_item-qr_code,
    ebeln          TYPE zinw_t_item-ebeln,
    ebelp          TYPE zinw_t_item-ebelp,
    matnr          TYPE zinw_t_item-matnr,
    lgort          TYPE zinw_t_item-lgort,
    werks          TYPE zinw_t_item-werks,
    maktx          TYPE zinw_t_item-maktx,
    matkl          TYPE zinw_t_item-matkl,
    ean11          TYPE zinw_t_item-ean11,
    menge          TYPE zinw_t_item-menge,
    menge_p        TYPE zinw_t_item-menge_p,
    meins          TYPE zinw_t_item-meins,
    no_roll        TYPE zinw_t_item-no_roll,
    open_qty       TYPE zinw_t_item-open_qty,
    netpr_p        TYPE zinw_t_item-netpr_p,
    steuc          TYPE zinw_t_item-steuc,
    kbetr          TYPE zinw_t_item-kbetr,
    netpr_gp       TYPE zinw_t_item-netpr_gp,
    netwr_p        TYPE zinw_t_item-netwr_p,
    margn          TYPE zinw_t_item-margn,
    discount       TYPE zinw_t_item-discount,
    menge_s        TYPE zinw_t_item-menge_s,
    netpr_s        TYPE zinw_t_item-netpr_s,
    netpr_gs       TYPE zinw_t_item-netpr_gs,
    netwr_s        TYPE zinw_t_item-netwr_s,
    mat_cat        TYPE zinw_t_item-mat_cat,
    zzset_material TYPE zinw_t_item-zzset_material,
    discount2      TYPE zinw_t_item-discount,
    discount3      TYPE netwr,
    Freight        TYPE netwr,
  END OF ty_item_scr,

  BEGIN OF ty_prcd,
    knumv TYPE prcd_elements-knumv,
    kposn TYPE prcd_elements-kposn,
    kschl TYPE prcd_elements-kschl,
    kawrt TYPE prcd_elements-kawrt,
    knumh TYPE prcd_elements-knumh,
    kbetr TYPE prcd_elements-kbetr,
    kwert TYPE prcd_elements-kwert,
  END OF ty_prcd.
*** Table Decleration
DATA :
  lt_item     TYPE STANDARD TABLE OF zinw_t_item,
  lt_item_scr TYPE STANDARD TABLE OF ty_item_scr,
  lt_marc     TYPE STANDARD TABLE OF ty_marc,
  lt_900      TYPE STANDARD TABLE OF ty_900,
  lt_ekpo     TYPE STANDARD TABLE OF ty_ekpo,
  lt_mara     TYPE STANDARD TABLE OF ty_mara,
  lt_tax_code TYPE TABLE OF a003,
  lt_konp     TYPE TABLE OF konp,
  lt_prcd     TYPE TABLE OF ty_prcd,
  wa_hdr      TYPE zinw_t_hdr,
  wa_item     TYPE zinw_t_item,
  wa_item_scr TYPE ty_item_scr,
  ls_item_scr TYPE ty_item_scr,
  ls_status   TYPE zinw_t_status,
  wa_ekko     TYPE ty_ekko,
  wa_approve  TYPE zinvoice_t_app,
  wa_payment  TYPE zqr_t_add.

DATA :
  p_ebeln            TYPE ekko-ebeln,
  p_qr_code          TYPE zinw_t_hdr-qr_code,
  ok_code            TYPE sy-ucomm,
  lv_mod(1)          VALUE 'D',
  lv_tax_cat(4),
  lv_tax_%           TYPE konp-kbetr,
  lv_error(1),
  lv_status          TYPE val_text,
  lv_bsart           TYPE ekko-bsart,
  lv_cur_field(20),
  lv_cur_value(20),
  lv_trns            TYPE lfa1-name1,
  lv_soe_des(20),
  lv_gr_date         TYPE datum,
  lv_approval        TYPE memoryid,
  lv_prof%           TYPE kbetr,
  lv_prof_amt        TYPE kbetr,
  lv_net_pay         TYPE bwert,
  lv_grc_prof        TYPE bwert,
  lv_grc_prof%       TYPE bwert,
  lv_net_selling     TYPE bwert,
  lv_hdr_discount    TYPE bwert,
  lv_group           TYPE klah-class,
  lv_group_margin(1).

FIELD-SYMBOLS :
  <ls_item>     TYPE zinw_t_item,
  <ls_item_scr> TYPE ty_item_scr,
  <ls_prcd>     TYPE ty_prcd.

*** Constants
CONSTANTS :
  c_reg                TYPE regio VALUE '33',
  c_plnt               TYPE wkreg VALUE '33',
  c_x(1)               VALUE 'X',
  c_b(2)               VALUE '01',
  c_s(2)               VALUE '02',
  c_e(2)               VALUE '03',
  c_g(2)               VALUE '04',
  c_zlop(4)            VALUE 'ZLOP',
  c_3000               TYPE   bwert VALUE 3000,
  c_ztat(4)            VALUE 'ZTAT',
  c_zret(4)            VALUE 'ZRET',
  c_03(2)              VALUE '03',
  c_01(2)              VALUE '01',
  c_05(2)              VALUE '05',
  c_d(2)               VALUE 'D',
  c_e1(2)              VALUE 'E',
  c_back(4)            VALUE 'BACK',
  c_cancel(6)          VALUE 'CANCEL',
  c_print(5)           VALUE 'PRINT',
  c_exit(4)            VALUE 'EXIT',
  c_clear(5)           VALUE 'CLEAR',
  c_edit(4)            VALUE 'EDIT',
  c_save(4)            VALUE 'SAVE',
  c_display(7)         VALUE 'DISPLAY',
  c_refresh(7)         VALUE 'REFRESH',
  c_enter(6)           VALUE 'ENTER',
  c_debit(5)           VALUE 'DEBIT',
  c_debit_d(7)         VALUE 'DEBIT_D',
  c_tat(3)             VALUE 'TAT',
  c_tat_d(5)           VALUE 'TAT_D',
  c_math(4)            VALUE 'MATH',
  c_qr01(4)            VALUE 'QR01',
  c_qr03(4)            VALUE 'QR03',
  c_qr04(4)            VALUE 'QR04',
  c_qr05(4)            VALUE 'QR05',
  c_qr_code(7)         VALUE 'QR_CODE',
  c_es_code(20)        VALUE 'SHORTAGE_EXCESS',
  c_es01(4)            VALUE 'ES01',
  c_set(3)             VALUE 'SET',
  c_zdis(4)            VALUE 'ZDIS',
  c_zmkp(4)            VALUE 'ZMKP',
  c_zkp0(4)            VALUE 'ZKP0',
  c_zmrp(4)            VALUE 'ZMRP',
  c_zean(4)            VALUE 'ZEAN',
  c_close(5)           VALUE 'CLOSE',
  c_inv(3)             VALUE 'INV',
  c_apr1(4)            VALUE 'APR1',
  c_apr2(4)            VALUE 'APR2',
  c_apr3(4)            VALUE 'APR3',
  c_pay(4)             VALUE 'PAY',
  c_payment(7)         VALUE 'PAYMENT',
  c_approval1(20)      VALUE 'ZINV_APPROVAL_1',
  c_approval2(20)      VALUE 'ZINV_APPROVAL_2',
  c_approval3(20)      VALUE 'ZINV_APPROVAL_3',
  c_grpo_p(10)         VALUE 'GRPO_P',
  c_grpo_s(10)         VALUE 'GRPO_S',
  c_trns(10)           VALUE 'TRNS',
  c_pay_adv(10)        VALUE 'PAY_ADV',
  c_auditor(10)        VALUE 'AUDITOR',
  c_qr_new(2)          VALUE '01',
  c_m(1)               VALUE 'M',
  c_fv(30)             VALUE 'FRUITSANDVEGETABLE',
  c_consumables(30)    VALUE 'CONSUMABLES',
  c_zds1(4)            VALUE 'ZDS1',
  c_zds2(4)            VALUE 'ZDS2',
  c_zds3(4)            VALUE 'ZDS3',
  c_zfrb(4)            VALUE 'ZFRB',
  c_pbxx(4)            VALUE 'PBXX',
  c_wotb(4)            VALUE 'WOTB',
  c_kg(4)              VALUE 'KG',
  c_kgm(4)             VALUE 'KGM',
  c_zzgroup_margin(14) VALUE 'ZZGROUP_MARGIN'.

*** reference to custom container: neccessary to bind ALV Control
DATA :
  custom_container TYPE REF TO cl_gui_custom_container,
  grid             TYPE REF TO cl_gui_alv_grid,
  ls_print         TYPE lvc_s_prnt,
  ls_layout        TYPE lvc_s_layo,
  lt_layout        LIKE TABLE OF ls_layout,
  mycontainer      TYPE scrfname VALUE 'MYCONTAINER',
  ls_fieldcat      TYPE lvc_s_fcat,
  lt_fieldcat      TYPE lvc_t_fcat.

*** Declaration for excluding toolbar buttons
DATA :
  ls_exclude   TYPE ui_func,
  lt_tlbr_excl TYPE ui_functions.

*** Declaration for toolbar buttons
DATA :
  ty_toolbar     TYPE stb_button,
  e_object       TYPE REF TO cl_alv_event_toolbar_set,
  io_alv_toolbar TYPE REF TO cl_alv_event_toolbar_set.

*** Event Class
CLASS event_class DEFINITION DEFERRED.
DATA :
  lr_event TYPE REF TO event_class.

CLASS event_class DEFINITION.
  PUBLIC SECTION.
    METHODS: handle_data_changed
                FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed.

ENDCLASS.            "LCL_EVENT_RECEIVER DEFINITION

*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS event_class IMPLEMENTATION.

  METHOD handle_data_changed.
    CLEAR : lv_error.
    DATA  : lv_field TYPE lvc_fname.
    DATA  : is_stable TYPE lvc_s_stbl, lv_lines TYPE int2.
    DATA  : lv_tx TYPE p DECIMALS 5.
    DATA  : lv_tax TYPE p DECIMALS 5.
    DATA  : lv_dis TYPE p DECIMALS 5.
    DATA  : lv_dis1 TYPE p DECIMALS 5.
    DATA  : lv_dis2 TYPE p DECIMALS 5.
    DATA  : lv_dis3 TYPE p DECIMALS 5.
    DATA  : lv_frt TYPE p DECIMALS 5.
    DATA  : lv_price TYPE p DECIMALS 5.

    CLEAR : lv_dis, lv_dis1, lv_dis2, lv_dis3, lv_frt, lv_tax.
*** Event is triggered when data is changed in the output
    is_stable = 'XX'.
*** Refreshing Data with Cusrsor Hold
    IF grid IS BOUND.
      CALL METHOD grid->refresh_table_display
        EXPORTING
          is_stable = is_stable        " With Stable Rows/Columns
*         i_soft_refresh = 'X'         " Without Sort, Filter, etc.
        EXCEPTIONS
          finished  = 1                " Display was Ended (by Export)
          OTHERS    = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

    FIELD-SYMBOLS: <fs> TYPE any.
    LOOP AT er_data_changed->mt_mod_cells ASSIGNING FIELD-SYMBOL(<x_mod_cells>).
      READ TABLE lt_item_scr ASSIGNING <ls_item_scr> INDEX <x_mod_cells>-row_id.
      IF sy-subrc = 0.
        IF <x_mod_cells>-fieldname = 'MENGE_P'.
***   For Tatkal PO
***   Quantity Should be Same as Open Quantity
          IF lv_bsart = c_ztat.
            <ls_item_scr>-menge_p = <x_mod_cells>-value.
            IF <ls_item_scr>-menge <> <ls_item_scr>-menge_p.
              CALL METHOD er_data_changed->add_protocol_entry
                EXPORTING
                  i_msgid     = 'ZMSG_CLS'
                  i_msgty     = 'E'
                  i_msgno     = '034'
                  i_fieldname = <x_mod_cells>-fieldname
                  i_row_id    = <x_mod_cells>-row_id.
              CLEAR : <x_mod_cells>-value, <ls_item_scr>-menge_p.
              lv_error = 'X'.
              EXIT.
            ENDIF.
          ENDIF.
*** Purchage Tax Amount
          <ls_item_scr>-menge_p = <x_mod_cells>-value.
          READ TABLE lt_ekpo ASSIGNING FIELD-SYMBOL(<ls_ekpo>) WITH KEY ebeln = <ls_item_scr>-ebeln ebelp = <ls_item_scr>-ebelp.
          IF sy-subrc = 0.
            CLEAR : <ls_item_scr>-netpr_gp.
            IF <ls_ekpo>-zzset_material IS NOT INITIAL.
              DATA(lv_matnr) = <ls_ekpo>-matnr.
              DATA(lt_set_lines) = lt_ekpo.
              DELETE lt_set_lines WHERE zzset_material <> <ls_ekpo>-zzset_material.
              SORT   lt_set_lines BY zzset_material matnr.
              DELETE ADJACENT DUPLICATES FROM lt_set_lines COMPARING zzset_material matnr.
              lv_lines = lines( lt_set_lines ).
***         For Checking Input Quantity is matches with Set Values
              DATA(lv_mod) = <x_mod_cells>-value MOD lv_lines.
              IF lv_mod <> 0.
                CALL METHOD er_data_changed->add_protocol_entry
                  EXPORTING
                    i_msgid     = 'ZMSG_CLS'
                    i_msgty     = 'E'
                    i_msgno     = '061'
                    i_fieldname = <x_mod_cells>-fieldname
                    i_row_id    = <x_mod_cells>-row_id.
                CLEAR : <x_mod_cells>-value, <ls_item_scr>-menge_p.
                lv_error = 'X'.
                EXIT.
              ENDIF.
            ENDIF.
            LOOP AT lt_tax_code ASSIGNING FIELD-SYMBOL(<ls_tax_code>) WHERE mwskz = <ls_ekpo>-mwskz.
              IF <ls_tax_code>-kschl = 'JIIG'.
                READ TABLE lt_konp ASSIGNING FIELD-SYMBOL(<ls_konp>) WITH KEY knumh = <ls_tax_code>-knumh.
                IF sy-subrc = 0.
                  lv_tx = <ls_konp>-kbetr / 10.
*                  IF <ls_item_scr>-discount IS NOT INITIAL OR <ls_item_scr>-discount2 IS NOT INITIAL OR <ls_item_scr>-discount3 IS NOT INITIAL.
*                    READ TABLE lt_prcd ASSIGNING <ls_prcd> WITH KEY kschl = c_wotb kposn = <ls_item_scr>-ebelp.
*                    IF sy-subrc IS INITIAL.
**                      lv_price = <ls_ekpo>-netpr * <ls_item_scr>-menge_p.
**                      lv_dis1  = ( lv_price * <ls_item_scr>-discount ) / 100.
*                      lv_price = <ls_ekpo>-netpr * <ls_item_scr>-menge_p.
*                    ENDIF.
****                Tax Calculation
*                    lv_tax =  ( <ls_konp>-kbetr * ( lv_price - lv_dis ) )  / 1000.
*                  ELSE.
                  lv_price =  <ls_ekpo>-netpr * <ls_item_scr>-menge_p.
                  lv_tax =  ( <ls_konp>-kbetr * lv_price ) / 1000 .
*                  ENDIF.

                  ADD lv_tax TO <ls_item_scr>-netpr_gp.
                  <ls_item_scr>-kbetr = <ls_konp>-kbetr / 10.
                  EXIT.
                ENDIF.
              ELSEIF <ls_tax_code>-kschl = 'JICG' OR <ls_tax_code>-kschl = 'JISG'.
                READ TABLE lt_konp ASSIGNING <ls_konp> WITH KEY knumh = <ls_tax_code>-knumh.
                IF sy-subrc = 0.
                  CLEAR :lv_tax.
                  lv_price =  <ls_ekpo>-netpr * <ls_item_scr>-menge_p.
                  lv_tax =  ( <ls_konp>-kbetr * lv_price ) / 1000 .
                  ADD lv_tax TO <ls_item_scr>-netpr_gp.
                  lv_tx  = <ls_konp>-kbetr / 5.
                  <ls_item_scr>-kbetr = <ls_konp>-kbetr / 5.
                ENDIF.
              ENDIF.
            ENDLOOP.

            IF <ls_ekpo>-zzset_material IS NOT INITIAL.
              <ls_item_scr>-netpr_gp =  <ls_item_scr>-netpr_gp * lv_lines.
            ENDIF.
          ENDIF.

          IF <ls_item_scr>-menge_p LE <ls_item_scr>-open_qty.
***       Selling Qty
            <ls_item_scr>-menge_s = <ls_item_scr>-menge_p.
***       Purchage Rate
            <ls_item_scr>-netwr_p = <ls_item_scr>-menge_p * <ls_item_scr>-netpr_p.
***       Purchage Tax
*          <LS_ITEM>-NETPR_GP = ( <LS_ITEM>-NETWR_P * LV_TX ) / 100.

***       HSN Code
            READ TABLE lt_marc ASSIGNING FIELD-SYMBOL(<ls_marc>) WITH KEY matnr = <ls_item_scr>-matnr.
            IF sy-subrc = 0.
              <ls_item_scr>-steuc = <ls_marc>-steuc.
            ENDIF.
***       For Consumbles : Selling Price is Not required
            IF lv_group <> c_consumables.
***       Discount
***       Checking MRP Condition record Maintained or Not / EAN Managed material
              IF lv_matnr IS INITIAL.
                lv_matnr = <ls_item_scr>-matnr.
              ENDIF.
              SELECT SINGLE matnr , meins FROM mara INTO @DATA(ls_meins) WHERE matnr = @lv_matnr.
*          READ TABLE LT_MARA ASSIGNING FIELD-SYMBOL(<LS_MARA>) WITH KEY MATNR = <LS_ITEM>-MATNR.
***        Margin / Discount / MRP
              READ TABLE lt_mara ASSIGNING FIELD-SYMBOL(<ls_mara>) WITH KEY matnr = lv_matnr.
              IF sy-subrc = 0.
                IF <ls_mara>-ena11 IS NOT INITIAL.
****         EAN Managed - Branded : Material / EAN Level
*                  SELECT SINGLE konp~kbetr FROM konp
*                         INNER JOIN a516 AS a516 ON konp~knumh = a516~knumh INTO @DATA(lv_sprice)
*                         WHERE a516~kschl = @c_zkp0 AND a516~matnr = @<ls_item_scr>-matnr AND a516~ean11 = @<ls_item_scr>-ean11
*                         AND a516~datab LE @sy-datum AND a516~datbi GE @sy-datum AND konp~loevm_ko = @space.
***         EAN Managed - Branded : Plant / Material : 11.06.2020 : 12:30:00
                  SELECT SINGLE konp~kbetr FROM konp
                         INNER JOIN a406 AS a406 ON konp~knumh = a406~knumh INTO @DATA(lv_sprice)
                         WHERE a406~kschl = @c_zean AND a406~matnr = @<ls_item_scr>-matnr AND a406~WERKS = @<ls_item_scr>-werks
                         AND a406~datab LE @sy-datum AND a406~datbi GE @sy-datum AND konp~loevm_ko = @space.

                  IF sy-subrc <> 0.
***            Selling Price is not Maintained
                    CLEAR : lv_field.
                    lv_field = 'MATNR'.
                    CALL METHOD er_data_changed->add_protocol_entry
                      EXPORTING
                        i_msgid     = 'ZMSG_CLS'
                        i_msgty     = 'E'
                        i_msgno     = '067'
                        i_fieldname = lv_field
                        i_row_id    = <x_mod_cells>-row_id.
                    CLEAR : <x_mod_cells>-value.
                    lv_error = 'X'.
                    EXIT.
                  ENDIF.
***       SELLING PRICE WITH PURCHAGE TAX
*                <ls_item>-discount = <ls_item>-discount / 10.
                  <ls_item_scr>-netpr_s = lv_sprice.
                  <ls_item_scr>-netpr_s = ceil( <ls_item_scr>-netpr_s ).
***       Selling Amount
                  <ls_item_scr>-netwr_s =  <ls_item_scr>-menge_s * <ls_item_scr>-netpr_s.
***       Selling Price GST
                  <ls_item_scr>-netpr_gs = ( <ls_item_scr>-netwr_s / ( lv_tx + 100 ) ) * lv_tx .
                ELSEIF <ls_mara>-xchpf = c_x.
***         Batach Managed - Branded
                  CLEAR :lv_sprice.
                  SELECT SINGLE konp~kbetr FROM konp
                         INNER JOIN a502 AS a502 ON konp~knumh = a502~knumh INTO @lv_sprice
                         WHERE a502~kschl = @c_zkp0 AND a502~matnr = @<ls_item_scr>-matnr AND a502~datab LE @sy-datum AND a502~datbi GE @sy-datum AND konp~loevm_ko = @space.
                  IF sy-subrc <> 0.
***            Selling Price is not Maintained
                    CLEAR : lv_field.
                    lv_field = 'MATNR'.
                    CALL METHOD er_data_changed->add_protocol_entry
                      EXPORTING
                        i_msgid     = 'ZMSG_CLS'
                        i_msgty     = 'E'
                        i_msgno     = '067'
                        i_fieldname = lv_field
                        i_row_id    = <x_mod_cells>-row_id.
                    CLEAR : <x_mod_cells>-value.
                    lv_error = 'X'.
                    EXIT.
                  ENDIF.

***       SELLING PRICE WITH PURCHAGE TAX
*              <ls_item>-discount = <ls_item>-discount / 10.
*            <LS_ITEM>-NETPR_S = LV_MRP  + ( ( <LS_ITEM>-DISCOUNT * LV_MRP ) / 100 ).
                  <ls_item_scr>-netpr_s = lv_sprice.
                  <ls_item_scr>-netpr_s = ceil( <ls_item_scr>-netpr_s ).
***       Selling Amount
                  <ls_item_scr>-netwr_s =  <ls_item_scr>-menge_s * <ls_item_scr>-netpr_s.
***       Selling Price GST
                  <ls_item_scr>-netpr_gs = ( <ls_item_scr>-netwr_s / ( lv_tx + 100 ) ) * lv_tx .
*            SELECT SINGLE KONP~KBETR FROM KONP
*                   INNER JOIN A515 AS A515 ON KONP~KNUMH = A515~KNUMH INTO @DATA(LV_MRP)
*                   WHERE A515~KSCHL = @C_ZMRP AND A515~MATNR = @<LS_ITEM>-MATNR AND A515~DATAB LE @SY-DATUM AND A515~DATBI GE @SY-DATUM.
*            IF SY-SUBRC = 0.
*              SELECT SINGLE KONP~KBETR FROM KONP
*                     INNER JOIN A515 AS A515 ON KONP~KNUMH = A515~KNUMH INTO @<LS_ITEM>-DISCOUNT
*                     WHERE A515~KSCHL = @C_ZDIS AND A515~MATNR = @<LS_ITEM>-MATNR AND A515~DATAB LE @SY-DATUM AND A515~DATBI GE @SY-DATUM.
*              IF SY-SUBRC <> 0.
*                CLEAR : LV_FIELD.
*                LV_FIELD = 'MATNR'.
*                CALL METHOD ER_DATA_CHANGED->ADD_PROTOCOL_ENTRY
*                  EXPORTING
*                    I_MSGID     = 'ZMSG_CLS'
*                    I_MSGTY     = 'E'
*                    I_MSGNO     = '042'
*                    I_FIELDNAME = LV_FIELD
*                    I_ROW_ID    = <X_MOD_CELLS>-ROW_ID.
*                CLEAR : <X_MOD_CELLS>-VALUE.
*                LV_ERROR = 'X'.
*                EXIT.
                ENDIF.
              ELSE.
***       Margin
***        Only Group / Vendor Margin     " Added on 18.03.2020
                IF lv_group_margin IS NOT INITIAL.
                  SELECT SINGLE
                         CASE WHEN @<ls_item_scr>-netpr_p LT 675 THEN konp~kbetr
                              WHEN @<ls_item_scr>-netpr_p GE 675 THEN konp~kbetr + 120
                         END AS kbetr
                         FROM konp
                         INNER JOIN a524 ON konp~knumh = a524~knumh INTO @<ls_item_scr>-margn
                         WHERE a524~lifnr = @wa_hdr-lifnr AND a524~zzgroup = @lv_group
                         AND   a524~kschl = @c_zmkp AND datab LE @sy-datum AND datbi GE @sy-datum AND loevm_ko = @space.
                ELSE.

***       Plant / Vendor / Class Level Margin - 1st priority    " Added on : 26.03.2020 : 10.50.00
                  SELECT SINGLE konp~kbetr FROM konp
                         INNER JOIN a525 AS a525 ON konp~knumh = a525~knumh INTO <ls_item_scr>-margn
                         WHERE a525~zzgroup = lv_group AND a525~lifnr = wa_hdr-lifnr AND a525~werks = <ls_item_scr>-werks
                         AND   a525~kschl = c_zmkp AND datab LE sy-datum AND datbi GE sy-datum AND loevm_ko = space.
                  IF sy-subrc IS NOT INITIAL.
***       Plant / Vendor / Material Level Margin - 2st priority    " Added on : 13.03.2020 : 16.10.00
                    SELECT SINGLE konp~kbetr FROM konp
                           INNER JOIN a363 AS a363 ON konp~knumh = a363~knumh INTO <ls_item_scr>-margn
                           WHERE a363~matnr = <ls_item_scr>-matnr AND a363~lifnr = wa_hdr-lifnr AND a363~werks = <ls_item_scr>-werks
                           AND   a363~kschl = c_zmkp AND datab LE sy-datum AND datbi GE sy-datum AND loevm_ko = space.
                    IF sy-subrc IS NOT INITIAL.
*                IF ls_meins-meins = c_kg OR ls_meins-meins = c_kgm.
***       Material Margin
                      SELECT SINGLE konp~kbetr FROM konp
                             INNER JOIN a515 AS a515 ON konp~knumh = a515~knumh INTO <ls_item_scr>-margn
                             WHERE a515~matnr = <ls_item_scr>-matnr
                             AND   a515~kschl = c_zmkp AND datab LE sy-datum AND datbi GE sy-datum AND loevm_ko = space.
                      IF sy-subrc IS NOT INITIAL.
***       Vendor & Material Margin
                        SELECT SINGLE konp~kbetr FROM konp
                               INNER JOIN a502 ON konp~knumh = a502~knumh INTO <ls_item_scr>-margn
                               WHERE a502~lifnr = wa_hdr-lifnr AND a502~matnr = <ls_item_scr>-matnr
                               AND   a502~kschl = c_zmkp AND datab LE sy-datum AND datbi GE sy-datum AND loevm_ko = space.
                        IF sy-subrc IS NOT INITIAL.
***       Vendor & Material Group Margin
                          SELECT SINGLE konp~kbetr FROM konp
                                 INNER JOIN a503 ON konp~knumh = a503~knumh INTO <ls_item_scr>-margn
                                 WHERE a503~matkl = <ls_item_scr>-matkl AND a503~lifnr = wa_hdr-lifnr
                                 AND a503~kschl = c_zmkp AND datab LE sy-datum AND datbi GE sy-datum AND loevm_ko = space.
                          IF sy-subrc IS NOT INITIAL.
***       Vendor Margin
                            SELECT SINGLE konp~kbetr FROM konp
                                   INNER JOIN a501 ON konp~knumh = a501~knumh INTO <ls_item_scr>-margn
                                   WHERE a501~lifnr = wa_hdr-lifnr
                                   AND a501~kschl = c_zmkp AND datab LE sy-datum AND datbi GE sy-datum AND loevm_ko = space.
                          ENDIF.  " Vendor Margin
                        ENDIF.    " Vendor & Material Group Margin
                      ENDIF.      " Vendor & Material Margin
                    ENDIF.        " Material Margin Margin
                  ENDIF.          " Plant Vendor & Class Margin
                ENDIF.            " Only Group & Vendor Margin

                IF <ls_item_scr>-margn IS INITIAL.
                  CLEAR : lv_field.
                  lv_field = 'MATNR'.
                  CALL METHOD er_data_changed->add_protocol_entry
                    EXPORTING
                      i_msgid     = 'ZMSG_CLS'
                      i_msgty     = 'E'
                      i_msgno     = '015'
                      i_fieldname = lv_field
                      i_row_id    = <x_mod_cells>-row_id.
                  CLEAR : <x_mod_cells>-value, <ls_item_scr>-menge_p.
                  lv_error = 'X'.
                  EXIT.
                ELSE.
***       SELLING GST TAX CODE
                  IF <ls_item_scr>-margn IS NOT INITIAL.
                    <ls_item_scr>-margn = <ls_item_scr>-margn / 10.
***       Selling Price with purchage tax
                    <ls_item_scr>-netpr_s = ( ( <ls_item_scr>-margn * <ls_item_scr>-netpr_p ) / 100 ) + <ls_item_scr>-netpr_p.
                    <ls_item_scr>-netpr_s = ceil( <ls_item_scr>-netpr_s ).
***       Selling Amount
                    <ls_item_scr>-netwr_s =  <ls_item_scr>-menge_s * <ls_item_scr>-netpr_s.
***       Selling Price GST
                    <ls_item_scr>-netpr_gs = ( <ls_item_scr>-netwr_s / ( lv_tx + 100 ) ) * lv_tx .
                  ENDIF.
                ENDIF. " Margin
              ENDIF.   " Mara
            ENDIF.  " Not Consumbles
          ELSE.
***       Error  : Entered PO Quantity greater than Open PO Quantity
            CALL METHOD er_data_changed->add_protocol_entry
              EXPORTING
                i_msgid     = 'ZMSG_CLS'
                i_msgty     = 'E'
                i_msgno     = '004'
                i_fieldname = <x_mod_cells>-fieldname
                i_row_id    = <x_mod_cells>-row_id.
            CLEAR : <x_mod_cells>-value.
            lv_error = 'X'.
            EXIT.
          ENDIF. " Open Qty
        ELSEIF <x_mod_cells>-fieldname = 'NO_ROLL'.
          <ls_item_scr>-no_roll = <x_mod_cells>-value.
        ENDIF.   " ROW_ID
      ENDIF.   " ROW_ID
    ENDLOOP.

    IF grid IS BOUND AND lv_error IS INITIAL.
*      REFRESH lt_item_scr.
*      MOVE-CORRESPONDING lt_item TO lt_item_scr.
      LOOP AT lt_item_scr ASSIGNING <ls_item_scr>.
        <ls_item_scr>-sno = sy-tabix.
      ENDLOOP.

      CALL METHOD grid->refresh_table_display
        EXPORTING
          is_stable = is_stable        " With Stable Rows/Columns
        EXCEPTIONS
          finished  = 1                " Display was Ended (by Export)
          OTHERS    = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
***    Update Totals
    IF lv_error IS INITIAL.
      CLEAR : wa_hdr-total, wa_hdr-pur_total,wa_hdr-net_amt,wa_hdr-t_gst, wa_hdr-pur_tax ,
              lv_net_selling , lv_net_pay, lv_prof_amt, lv_grc_prof,lv_grc_prof% , wa_hdr-discount,lv_hdr_discount.
      SORT lt_ekpo BY ebeln ebelp.
      LOOP AT lt_item_scr ASSIGNING <ls_item_scr>.
        IF <ls_item_scr>-menge_p IS NOT INITIAL.
          ADD <ls_item_scr>-netwr_s  TO wa_hdr-total.
          ADD <ls_item_scr>-netwr_p  TO wa_hdr-pur_total.
          ADD <ls_item_scr>-netpr_gs TO wa_hdr-t_gst.
          ADD <ls_item_scr>-netpr_gp TO wa_hdr-pur_tax.
*          lv_dis = ( ( <ls_item_scr>-discount * <ls_item_scr>-netpr_p ) / 100 ) * <ls_item_scr>-menge_p.
          READ TABLE lt_ekpo ASSIGNING <ls_ekpo> WITH KEY ebeln = <ls_item_scr>-ebeln ebelp = <ls_item_scr>-ebelp BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            lv_dis = ( <ls_item_scr>-netpr_p - <ls_ekpo>-netpr  ) * <ls_item_scr>-menge_p .
          ENDIF.
          ADD  lv_dis TO lv_hdr_discount.
        ENDIF.
      ENDLOOP.

      wa_hdr-net_amt   = lv_net_pay = wa_hdr-pur_total + wa_hdr-pur_tax + wa_hdr-packing_charge - wa_hdr-discount - lv_hdr_discount.
      lv_net_selling   = wa_hdr-total - wa_hdr-t_gst.
      lv_grc_prof      = wa_hdr-total - wa_hdr-pur_total.
      lv_prof_amt      = wa_hdr-total - wa_hdr-net_amt.
      IF wa_hdr-net_amt IS NOT INITIAL.
        lv_prof%       = ( lv_prof_amt * 100 ) / wa_hdr-net_amt.
      ENDIF.
      IF wa_hdr-net_amt IS NOT INITIAL.
        lv_grc_prof%       = ( lv_grc_prof * 100 ) / wa_hdr-pur_total.
      ENDIF.

****   To Refresh the Main Screen
*      CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*        EXPORTING
*          NEW_CODE = 'REFRESH'.
    ELSE.
      CALL METHOD er_data_changed->display_protocol( ).
    ENDIF.
    CLEAR :lv_error.
  ENDMETHOD.
ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION
