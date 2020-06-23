*&---------------------------------------------------------------------*
*& Include SAPMZUNLOAD_NC_TOP                       - Module Pool      SAPMZUNLOAD_NC
*&---------------------------------------------------------------------*
PROGRAM SAPMZUNLOAD_NC.

DATA : gv_scanval TYPE exidv .

DATA: i_bdcdata TYPE TABLE OF bdcdata,
      w_bdcdata TYPE bdcdata,
      ctu_param TYPE ctu_params.
DATA : gv_exidv TYPE exidv,
       gv_vbeln TYPE vbeln,
       gv_unvel TYPE unvel.

DATA: it_messtab TYPE TABLE OF bdcmsgcoll,
      wa_messtab TYPE bdcmsgcoll,
*        wa_log TYPE zint_log,
      messtab1   LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.

DATA: ctumode LIKE ctu_params-dismode VALUE 'N',
      cupdate LIKE ctu_params-updmode VALUE 'A'.

CONSTANTS: ac                  VALUE 'C',
           ad                  VALUE 'D',
           ae                  VALUE 'E',
           ax                  VALUE 'X',

           aaok                TYPE syucomm VALUE 'AAOK',
           aano                TYPE syucomm VALUE 'AANO',

           back                TYPE syucomm VALUE 'BACK',
           exec                TYPE syucomm VALUE 'EXEC',
           fpage               TYPE syucomm VALUE 'FPAGE',
           ppage               TYPE syucomm VALUE 'PPAGE',
           npage               TYPE syucomm VALUE 'NPAGE',
           lpage               TYPE syucomm VALUE 'LPAGE',

           screen_no_shipments TYPE i VALUE 6.

DATA aucomm TYPE syucomm.

TYPES: BEGIN OF svttk,
         tknum TYPE tknum,
         signi TYPE signi,
       END OF svttk.

TYPES: BEGIN OF svttp,
         tknum TYPE tknum,
         tpnum TYPE  tpnum,
         vbeln TYPE vbeln_vl,
       END OF svttp.

TYPES: BEGIN OF slikp,
         vbeln TYPE vbeln_vl,
         vstel TYPE vstel,
       END OF slikp.

TYPES : BEGIN OF ty_tknum,
          vbeln TYPE vbeln_vl,
          tknum TYPE tknum,
        END OF ty_tknum.



DATA: xvttk    TYPE TABLE OF svttk WITH HEADER LINE,
      gt_vttp  TYPE TABLE OF svttp WITH HEADER LINE,
      gt_likp  TYPE TABLE OF slikp WITH HEADER LINE,
      gt_tknum TYPE TABLE OF ty_tknum WITH HEADER LINE.

DATA: amesag(220),
      mesag1      TYPE char25,
      mesag2      TYPE char25,
      mesag3      TYPE char25,
      mesag4      TYPE char25,
      mesag5      TYPE char25,
      mesag6      TYPE char25,
      mesag7      TYPE char25,

      aicon       TYPE icon-id,
      mark(1)     TYPE c.

DATA: spr01, spn01(31),
      spr02, spn02(31),
      spr03, spn03(31),
      spr04, spn04(31),
      spr05, spn05(31),
      spr06, spn06(31),
      spr07, spn07(31),
      spr08, spn08(31),
      spr09, spn09(31),
      spr10, spn10(31),
      spr11, spn11(31),
      spr12, spn12(31),
      spr13, spn13(31),
      spr14, spn14(31),
      spr15, spn15(31),
      spr16, spn16(31),
      spr17, spn17(31),
      spr18, spn18(31),
      spr19, spn19(31),
      spr20, spn20(31).

DATA: currp    TYPE i,
      lastp    TYPE i,
      total    TYPE i,
      tempa(2) TYPE n.

DATA afield TYPE char20.

FIELD-SYMBOLS <afs>.

DATA: atknum  TYPE vttk-tknum,
      aexidv  TYPE vekp-exidv,
      atplst  TYPE vttk-tplst,
      svstel  TYPE likp-vstel,
      svstel2 TYPE likp-vstel,
      svstel3 TYPE likp-vstel,
      asubrc  TYPE sysubrc,
      ssubrc  TYPE sysubrc.

DATA: BEGIN OF xvttp OCCURS 0,
        vbeln TYPE vttp-vbeln,
      END OF xvttp.

DATA: BEGIN OF xvepo OCCURS 0,
        venum TYPE vepo-venum,
        vepos TYPE vepo-vepos,
        vbeln TYPE vepo-vbeln,
        objnr TYPE husstat-objnr,
      END OF xvepo.

DATA: BEGIN OF xvekp OCCURS 0,
        venum  TYPE vekp-venum,
        exidv  TYPE vekp-exidv,
        exidv2 TYPE vekp-exidv2,
        uevel  TYPE vekp-uevel,
        pallet TYPE vekp-exidv,
      END OF xvekp.

DATA: BEGIN OF xlhus OCCURS 0,
        objnr TYPE husstat-objnr,
        stat  TYPE husstat-stat,
        inact TYPE husstat-inact,
      END OF xlhus.

DATA: totall_hus TYPE i,
      loaded_hus TYPE i.

DATA: adalen TYPE sydatum,
      adalbg TYPE sydatum.

DATA :gv_count TYPE sy-tabix,                  " Count for intial data fetch
      gv_from  TYPE sy-tabix,                  " Count From
      gv_to    TYPE sy-tabix.                  " Count To

TYPES : BEGIN OF ty_ship,
          1slnum TYPE sy-tabix,    " 1st Row Serial Number
          1tknum TYPE tknum,       " 1st Row Shipment Number
          1signi TYPE signi,       " 1st Row Container ID
          2slnum TYPE sy-tabix,    " 2nd Row Serial Number
          2tknum TYPE tknum,       " 2nd Row Shipment Number
          2signi TYPE signi,       " 2nd Row Container ID
          3slnum TYPE sy-tabix,    " 3rd Row Serial Number
          3tknum TYPE tknum,       " 3rd Row Shipment Number
          3signi TYPE signi,       " 3rd Row Container ID
          4slnum TYPE sy-tabix,    " 4th Row Serial Number
          4tknum TYPE tknum,       " 4th Row Shipment Number
          4signi TYPE signi,       " 4th Row Container ID
          5slnum TYPE sy-tabix,    " 5th Row Serial Number
          5tknum TYPE tknum,       " 5th Row Shipment Number
          5signi TYPE signi,       " 5th Row Container ID
          6slnum TYPE sy-tabix,    " 6th Row Serial Number
          6tknum TYPE tknum,       " 6th Row Shipment Number
          6signi TYPE signi,       " 6th Row Container ID
          7slnum TYPE sy-tabix,    " 7th Row Serial Number
          7tknum TYPE tknum,       " 7th Row Shipment Number
          7signi TYPE signi,       " 7th Row Container ID
        END OF ty_ship.
DATA : gs_ship         TYPE ty_ship .                 " Open Shipement List Fields
DATA : gv_sel  TYPE char3 ,                     " Line Selection Field
       gv_line TYPE sy-tabix.                  " Lines

DATA : notify_bell_signal(1) TYPE n .   " added by sjena on 270918
