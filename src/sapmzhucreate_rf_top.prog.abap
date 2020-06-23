*&---------------------------------------------------------------------*
*& Include SAPMZHUCREATE_RF_TOP                     - Module Pool      SAPMZHUCREATE_RF
*&---------------------------------------------------------------------*
PROGRAM sapmzhucreate_rf.


TYPES: BEGIN OF ty_final,
        charg TYPE char20,
        matnr TYPE matnr,
        menge TYPE menge_d,
      END OF ty_final.

TYPES : BEGIN OF ty_mess,
          err   TYPE char1,
          mess1 TYPE char20,
          mess2 TYPE char20,
          mess3 TYPE char20,
          mess4 TYPE char20,
          mess5 TYPE char20,
        END OF ty_mess.

DATA: lv_charg TYPE char20,
      lv_count TYPE char6,
      lv_werks TYPE werks_d,
      gv_icon_name  TYPE char30,
      gv_icon_9999(132),
      gv_text   TYPE char10,
      rad1 TYPE c,
      rad2 TYPE c.

DATA: it_final TYPE TABLE OF ty_final,
      wa_final TYPE ty_final,
      gw_mess  TYPE ty_mess,
      wa_fin   TYPE ty_final,
      it_fin   TYPE TABLE OF ty_final.

DATA: ok_code1 TYPE sy-ucomm,
      ok_code2 TYPE sy-ucomm,
      lv_matnr TYPE matnr,
      lv_sbatch TYPE char10.

CONSTANTS :   c_tray(5)   VALUE 'TRAY',
              c_bundle(6) VALUE 'BUNDLE'.

DATA: lw_head  TYPE bapihuhdrproposal,
     lv_exidv  TYPE bapihukey-hu_exid,
      li_ret1  TYPE STANDARD TABLE OF bapiret2,
      lw_ret1  TYPE bapiret2,
      li_iret  TYPE TABLE OF bapiret2,
      lw_itemp TYPE bapihuitmproposal,
      li_itemp TYPE TABLE OF bapihuitmproposal.
