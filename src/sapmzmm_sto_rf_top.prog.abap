*&---------------------------------------------------------------------*
*& Include SAPMZMM_STO_RF_TOP                       - Module Pool      SAPMZMM_STO_RF
*&---------------------------------------------------------------------*
PROGRAM sapmzmm_sto_rf.

TYPES: BEGIN OF ty_list,
         charg TYPE charg_d,  "Batch
         batch TYPE zb1_btch,
         qty   TYPE zquan,
       END OF ty_list,

       BEGIN OF ty_b1batch,
         matnr    TYPE matnr,
         plant    TYPE werks_d,
         stge_loc TYPE lgort_d,
         uom      TYPE zuom,
         b1_batch TYPE zb1_btch,
         batch    TYPE charg_d,
*         user_s   TYPE /pra/rsp_system_user,
         matkl    TYPE matkl,
         wgbez    TYPE wgbez,
       END OF ty_b1batch.

CONSTANTS: c_back(4) TYPE c VALUE 'BACK',
           c_exit(4) TYPE c VALUE 'EXIT',
           c_canc(4) TYPE c VALUE 'CANC'.

DATA: ok_9001         TYPE sy-ucomm,
      gv_fwhs         TYPE werks_d,
      gv_tstore       TYPE werks_d,
      gv_batch(30)    TYPE c,
      gv_qty(15)      TYPE c,
      gv_cnt          TYPE i,
      gv_check        TYPE c,

      gs_list         TYPE ty_list,
      gt_list         TYPE TABLE OF ty_list,
      gt_b1batch      TYPE TABLE OF ty_b1batch,

      gv_sn1          TYPE c,
      gv_sn2          TYPE c,
      gv_sn3          TYPE c,
      gv_sn4          TYPE c,
      gv_sn5          TYPE c,
      gv_sn6          TYPE c,
      gv_sn7          TYPE c,
      gv_sn8          TYPE c,
      gv_sn9          TYPE c,
      gv_sn10(2)      TYPE c,
      gv_sn11(2)      TYPE c,
      gv_sn12(2)      TYPE c,
      gv_sn13(2)      TYPE c,
      gv_sn14(2)      TYPE c,
      gv_sn15(2)      TYPE c,

      gv_batch1(30)   TYPE c,
      gv_batch2(30)   TYPE c,
      gv_batch3(30)   TYPE c,
      gv_batch4(30)   TYPE c,
      gv_batch5(30)   TYPE c,
      gv_batch6(30)   TYPE c,
      gv_batch7(30)   TYPE c,
      gv_batch8(30)   TYPE c,
      gv_batch9(30)   TYPE c,
      gv_batch10(30)  TYPE c,
      gv_batch11(30)  TYPE c,
      gv_batch12(30)  TYPE c,
      gv_batch13(30)  TYPE c,
      gv_batch14(30)  TYPE c,
      gv_batch15(30)  TYPE c,

      gv_qty1(15)     TYPE c,
      gv_qty2(15)     TYPE c,
      gv_qty3(15)     TYPE c,
      gv_qty4(15)     TYPE c,
      gv_qty5(15)     TYPE c,
      gv_qty6(15)     TYPE c,
      gv_qty7(15)     TYPE c,
      gv_qty8(15)     TYPE c,
      gv_qty9(15)     TYPE c,
      gv_qty10(15)    TYPE c,
      gv_qty11(15)    TYPE c,
      gv_qty12(15)    TYPE c,
      gv_qty13(15)    TYPE c,
      gv_qty14(15)    TYPE c,
      gv_qty15(15)    TYPE c,

      gv_catg1(15)    TYPE c,
      gv_catg2(15)    TYPE c,
      gv_catg3(15)    TYPE c,
      gv_catg4(15)    TYPE c,
      gv_catg5(15)    TYPE c,
      gv_catg6(15)    TYPE c,
      gv_catg7(15)    TYPE c,
      gv_catg8(15)    TYPE c,
      gv_catg9(15)    TYPE c,
      gv_catg10(15)   TYPE c,
      gv_catg11(15)   TYPE c,
      gv_catg12(15)   TYPE c,
      gv_catg13(15)   TYPE c,
      gv_catg14(15)   TYPE c,
      gv_catg15(15)   TYPE c,

      gv_sbatch1(15)  TYPE c,
      gv_sbatch2(15)  TYPE c,
      gv_sbatch3(15)  TYPE c,
      gv_sbatch4(15)  TYPE c,
      gv_sbatch5(15)  TYPE c,
      gv_sbatch6(15)  TYPE c,
      gv_sbatch7(15)  TYPE c,
      gv_sbatch8(15)  TYPE c,
      gv_sbatch9(15)  TYPE c,
      gv_sbatch10(15) TYPE c,
      gv_sbatch11(15) TYPE c,
      gv_sbatch12(15) TYPE c,
      gv_sbatch13(15) TYPE c,
      gv_sbatch14(15) TYPE c,
      gv_sbatch15(15) TYPE c,

      gv_item1(15)    TYPE c,
      gv_item2(15)    TYPE c,
      gv_item3(15)    TYPE c,
      gv_item4(15)    TYPE c,
      gv_item5(15)    TYPE c,
      gv_item6(15)    TYPE c,
      gv_item7(15)    TYPE c,
      gv_item8(15)    TYPE c,
      gv_item9(15)    TYPE c,
      gv_item10(15)   TYPE c,
      gv_item11(15)   TYPE c,
      gv_item12(15)   TYPE c,
      gv_item13(15)   TYPE c,
      gv_item14(15)   TYPE c,
      gv_item15(15)   TYPE c.
