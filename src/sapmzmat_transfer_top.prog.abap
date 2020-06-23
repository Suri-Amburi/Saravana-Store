*&---------------------------------------------------------------------*
*& Include SAPMZMAT_TRANSFER_TOP                    - Module Pool      SAPMZMAT_TRANSFER
*&---------------------------------------------------------------------*
PROGRAM SAPMZMAT_TRANSFER.

DATA:gt_type TYPE truxs_t_text_data.
CONTROLS tc1  TYPE TABLEVIEW USING SCREEN 1000.

TYPES: BEGIN OF ty_item,
         matnr  TYPE matnr,         "First material
         charg  TYPE charg_d,         "Batch
         licha  TYPE lichn,         "Supplier Batch
         werks  TYPE werks_d,       "plant
         lgort  TYPE lgort_d,       "Storage location
         menge  TYPE labst,       "quantity
         meins  TYPE meins,         "UOM
         matnr2 TYPE matnr,         "Second Material
         charg2 TYPE charg_d,         "Second material batch
         lgort2 TYPE lgort_d,        "Second material storage location
         pspnr  TYPE ps_posid,
         sel    TYPE c,
       END OF ty_item.

TYPES: BEGIN OF ty_smesg,
         arbgb TYPE arbgb,
         msgty TYPE msgty_co,
         msgv1 TYPE symsgv,
         msgv2 TYPE symsgv,
         msgv3 TYPE symsgv,
         msgv4 TYPE symsgv,
         txtnr TYPE msgnr,
       END OF ty_smesg.
TYPES: BEGIN OF ty_mch1,
         matnr TYPE matnr,
         charg TYPE charg_d,
         licha TYPE lichn,
       END OF ty_mch1.

DATA: p_file  TYPE rlgrap-filename,
      fname   TYPE localfile,
      ename   TYPE char4,
      it_item TYPE TABLE OF ty_item,
      wa_item TYPE ty_item,
      it_mch1 TYPE TABLE OF ty_mch1,
      wa_mch1 TYPE ty_mch1.

DATA: wa_material         TYPE bapibatchkey,
      wa_batch            TYPE bapibatchkey,
      wa_plant            TYPE bapibatchkey,
      wa_batchattributes  TYPE bapibatchatt,
      wa_batchattributes2 TYPE bapibatchatt,
      wa_batch2           TYPE bapibatchkey,
      wa_return           TYPE bapiret2,
      it_return           TYPE TABLE OF bapiret2.

DATA: wa_goodsmvt_header  TYPE  bapi2017_gm_head_01,
      it_goodsmvt_item    TYPE TABLE OF bapi2017_gm_item_create,
      wa_goodsmvt_item    TYPE  bapi2017_gm_item_create,
      it_return2          TYPE TABLE OF bapiret2,
      wa_return2          TYPE bapiret2,
      wa_goodsmvt_code    TYPE bapi2017_gm_code,
      wa_goodsmvt_headret TYPE bapi2017_gm_head_ret,
      ls_smesg            TYPE ty_smesg,
      lv_c(100)           TYPE c ,                    "local variable to store cursor position
      lv_licha            TYPE lichn,
      lv_cl1              TYPE i,
      wa_header-budat     TYPE budat,
      lv_charg1           TYPE charg_d.
