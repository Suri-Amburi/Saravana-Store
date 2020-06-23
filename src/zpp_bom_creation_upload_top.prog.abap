*&---------------------------------------------------------------------*
*& Include          ZPP_IBOM_CREATION_C02_TOP
*&---------------------------------------------------------------------*

TYPES:BEGIN OF gty_file,
*        sno(5),
*        id(1),             "Collumn ID
        matnr(40) TYPE c,         "Header Material
        werks(4)  TYPE c,         "Plant
        stlan(1)  TYPE c,         "BOM Usage
        stlal(2)  TYPE c,         "Alternative BOM
        datuv(10) TYPE c,         "Valid From Date
        datub(10) TYPE c,        "Valid To Date
*  BOM Header
        ztext(40) TYPE c,         "BOM text
        stktx(40) TYPE c,         "Alt text
        bmeng(13) TYPE c,         "Base quantity
*  BOM : General Item Overview
       posnr(4)  TYPE c,         "BOM Item Number
       postp(10) TYPE c,         "Item Category
       idnrk(40) TYPE c,         "BOM Component
       menge(18) TYPE c,         "Component Quantity
       meins(3)  TYPE c,         "uom
       ausch(8)  TYPE c,         "Scrap
       avoau(8)  TYPE c,         "Operation scrap
       netau(1)  TYPE c,         "NET INDICATORS
       sortf(10) TYPE c,         "Sort String
*BOM ITEM ALL DATA
      fmeng(1)  TYPE c,         "Fixed quanity
      potx1(40) TYPE c,         "BOM item text line 1
      potx2(40) TYPE c,         "BOM item text line  2
      itsob(2)  TYPE c,         "Special Procurement
      erskz(1)  TYPE c,         "Spare part indicator
      rel_cost(1) TYPE c,      "Costing Indicator
      knnam(30) TYPE c,         "Dependency Name
      knktx(30) TYPE c,         "Dependency Description


*        sample,
END OF gty_file,
gty_t_file TYPE STANDARD TABLE OF gty_file.


DATA:gwa_file    TYPE gty_file,
     git_file    TYPE gty_t_file,
     git_file_i  TYPE gty_t_file,
     git_file_it TYPE gty_t_file.

DATA:fname TYPE localfile,
     ename TYPE char4,
     cnt   TYPE i.

TYPES:BEGIN OF gty_display,
        sno      TYPE i,
        matnr    TYPE matnr,
        werks    TYPE werks,
        bom_no   TYPE stko_api02-bom_no,
        message1 TYPE message,
        message2 TYPE message,
      END OF gty_display,
      gty_t_display TYPE STANDARD TABLE OF gty_display.

DATA: gwa_display TYPE gty_display,
      git_display TYPE gty_t_display,
      lv_date     TYPE dats,
      lv_time     TYPE tims,
      lv_sqno(6)  TYPE n,

      it_fieldcat TYPE slis_t_fieldcat_alv,
      wa_layout   TYPE slis_layout_alv.

DATA: it_bdcdata TYPE TABLE OF bdcdata,
      wa_bdcdata TYPE bdcdata.
DATA: it_messtab TYPE TABLE OF bdcmsgcoll,
      wa_messtab TYPE bdcmsgcoll,
*        wa_log TYPE zint_log,
      messtab1   LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
DATA: ctumode LIKE ctu_params-dismode VALUE 'N',
      cupdate LIKE ctu_params-updmode VALUE 'A'.

DATA: lv_matnr TYPE csap_mbom-matnr,          " Material BOM Initial Screen Data
      lv_werks TYPE csap_mbom-werks,
      lv_stlan TYPE csap_mbom-stlan,
      lv_stlal TYPE csap_mbom-stlal,
      lv_datuv TYPE csap_mbom-datuv.
