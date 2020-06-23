*&---------------------------------------------------------------------*
*& Include          ZMM_MAS_CAT_SAL_TOP
*&---------------------------------------------------------------------*

TYPES : BEGIN OF ty_mara ,
          matnr TYPE matnr,
          matkl TYPE matkl,
        END OF ty_mara .

TYPES : BEGIN OF ty_mbew ,
          matnr TYPE matnr,
          bwkey TYPE bwkey,
          lbkum TYPE lbkum,
          salk3 TYPE salk3,
        END OF ty_mbew .

TYPES : BEGIN OF ty_mard ,
          werks TYPE werks_d,
          labst TYPE labst,
        END OF ty_mard .

TYPES : BEGIN OF ty_table ,
          matkl TYPE matkl,
          w01q  TYPE lbkum,
          w02q  TYPE lbkum,
          w03q  TYPE lbkum,
          w04q  TYPE lbkum,
          w05q  TYPE lbkum,
          w06q  TYPE lbkum,
          w07q  TYPE lbkum,
          w08q  TYPE lbkum,
          w09q  TYPE lbkum,
          w010q TYPE lbkum,
          w01v  TYPE salk3,
          w02v  TYPE salk3,
          w03v  TYPE salk3,
          w04v  TYPE salk3,
          w05v  TYPE salk3,
          w06v  TYPE salk3,
          w07v  TYPE salk3,
          w08v  TYPE salk3,
          w09v  TYPE salk3,
          w010v TYPE salk3,
          cum   TYPE lbkum,
          cum1  TYPE salk3,
        END OF ty_table .

TYPES : BEGIN OF ty_tab ,
          sl_no(03) TYPE i,
          plant     TYPE werks,
        END OF ty_tab .

TYPES : BEGIN OF ty_final ,
          matkl  TYPE matkl,
          wgbez  TYPE wgbez,
          bwkey  TYPE bwkey,
          lbkum1 TYPE p DECIMALS 2,
          lbkum2 TYPE p DECIMALS 2,
          lbkum3 TYPE p DECIMALS 2,
          lbkum4 TYPE p DECIMALS 2,
          lbkum5 TYPE p DECIMALS 2,
          lbkum6 TYPE p DECIMALS 2,
          salk1  TYPE p DECIMALS 2,
          salk2  TYPE p DECIMALS 2,
          salk3  TYPE p DECIMALS 2,
          salk4  TYPE p DECIMALS 2,
          salk5  TYPE p DECIMALS 2,
          salk6  TYPE p DECIMALS 2,
          cumv   TYPE p DECIMALS 2,
          cumq   TYPE p DECIMALS 2,
        END OF ty_final.

TYPES : BEGIN OF ty_data ,
          matnr TYPE matnr,
          matkl TYPE matkl,
*        WERKS TYPE WERKS_D ,
          bwkey TYPE bwkey ,        ""PLANT
          lbkum TYPE lbkum ,         ""QTY
          salk3 TYPE salk3 ,        ""AMOUNT
        END OF ty_data.

TYPES: BEGIN OF ty_gt1,
         matnr TYPE mara-matnr,
         matkl TYPE mara-matkl,
         bwkey TYPE mbew-bwkey,
         bwtar TYPE mbew-bwtar,
         lbkum TYPE mbew-lbkum,
         salk3 TYPE mbew-salk3,
         spras TYPE t023t-spras,
         wgbez TYPE t023t-wgbez,
       END OF ty_gt1.

DATA : gt_data   TYPE TABLE OF ty_data,
       gt_data1  TYPE TABLE OF ty_gt1,
       gs_data1  TYPE  ty_gt1,
       it_mara   TYPE TABLE OF ty_mara,
       it_mbew   TYPE TABLE OF ty_mbew,
       it_final  TYPE TABLE OF ty_final,
       it_final1 TYPE TABLE OF ty_final,
       wa_final  TYPE ty_final,
       wa_final1 TYPE ty_final,
       it_mard   TYPE TABLE OF ty_mard.
DATA : lv_matkl TYPE mara-matkl,
       lv_plant TYPE bwkey.

DATA : gt_table TYPE TABLE OF ty_table,
       gs_table TYPE ty_table,
       gt_tab   TYPE TABLE OF ty_tab,
       gs_tab   TYPE  ty_tab.

DATA : it_fcat TYPE slis_t_fieldcat_alv,
       wa_fcat TYPE slis_fieldcat_alv,
       wvari   TYPE disvariant.

DATA: it_sort TYPE slis_t_sortinfo_alv,
      wa_sort TYPE slis_sortinfo_alv.
TYPE-POOLS : slis.

DATA : wa_layout TYPE slis_layout_alv .
wa_layout-zebra = 'X' .
wa_layout-colwidth_optimize = 'X' .

DATA: it_events TYPE  slis_t_event,
      wa_events TYPE slis_alv_event.

DATA: gt_events     TYPE slis_t_event.

DATA:
  gd_tab_group TYPE slis_t_sp_group_alv,
  gd_layout    TYPE slis_layout_alv,
  gd_repid     LIKE sy-repid.
