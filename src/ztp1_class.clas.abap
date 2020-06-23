CLASS ZTP1_CLASS DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES:IF_AMDP_MARKER_HDB.

    TYPES : BEGIN OF TY_MARA,
          MATNR TYPE MATNR  , "  Material Number
          MATKL TYPE MATKL , "Material Group
          MEINS TYPE MEINS , "  Base Unit of Measure
          TAKLV TYPE MARA-TAKLV,
          WERKS TYPE WERKS_D,
          STEUC TYPE STEUC,
          SPRAS TYPE SPRAS  , "Language Key
          MAKTX TYPE MAKTX  , "Material description
        END OF TY_MARA.

TYPES : BEGIN OF TY_EINE,
          MATNR TYPE MATNR,
          MATKL TYPE MATKL,
          LIFNR TYPE ELIFN,
          INFNR TYPE INFNR,
          EKORG TYPE EKORG,
          ESOKZ TYPE ESOKZ,
          WERKS TYPE EWERK,
          PRDAT TYPE PRGBI,
          MWSKZ TYPE MWSKZ,
          NETPR TYPE IPREI,
        END OF TY_EINE .

 types : begin of ty_a603 ,
          KAPPL    TYPE KAPPL,
          KSCHL  TYPE KSCHA,
          LIFNR  TYPE ELIFN,
          MATNR  TYPE MATNR,
          KFRST  TYPE KFRST,
          DATBI  TYPE KODATBI,
          DATAB  TYPE KODATAB,
          KBSTAT TYPE KBSTAT,
          KNUMH  TYPE KNUMH,
          KOPOS    TYPE KOPOS,
          KBETR    TYPE KBETR_KOND,
          LOEVM_KO TYPE KONP-LOEVM_KO,
         END OF ty_a603 .

  TYPES :   it_mara1 type STANDARD TABLE OF ty_mara .
  TYPES : IT_EINE1 TYPE STANDARD TABLE OF ty_eine .
  types : it_a6031 type STANDARD TABLE Of ty_a603 .
    class-methods get_data
    IMPORTING
       VALUE(lv_matnr) type mara-matnr
       value(lv_lifnr) type lfa1-lifnr
EXPORTING
      VALUE(it_mara1) TYPE IT_MARA1
      value(it_eine2) type it_eine1
      value(it_a6031) type it_a6031 .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTP1_CLASS IMPLEMENTATION.


METHOD get_data  by database procedure
                 for hdb
                 language sqlscript
                 options read-only
                 using Mara MARC makt EINA EINE a603 konp.

it_mara1 = select mara.MATNR ,
                  mara.MATKL ,
                  mara.MEINS ,
                  mara.TAKLV ,
                  marc.WERKS ,
                  marc.STEUC ,
                  makt.SPRAS ,
                  makt.MAKTX
                  from mara as mara
                  inner join marc as marc on mara.matnr = marc.matnr
                  inner join makt as makt on mara.matnr = makt.matnr
                  where mara.matnr = lv_matnr and makt.spras = 'EN' ;

it_eine2 = select eina.MATNR ,
                  eina.MATKL ,
                  eina.LIFNR ,
                  eine.INFNR ,
                  eine.EKORG ,
                  eine.ESOKZ ,
                  eine.WERKS ,
                  eine.PRDAT ,
                  eine.MWSKZ ,
                  eine.NETPR
                   from eina as eina
                   inner join eine as eine on eina.infnr = eine.infnr
                   where EINA.matnr  = lv_matnr and EINA.lifnr = lv_lifnr ;

 it_a6031 = select a603.KAPPL,
                   a603.KSCHL ,
                   a603.LIFNR ,
                   a603.MATNR  ,
                   a603.KFRST  ,
                   a603.DATBI ,
                   a603.DATAB ,
                   a603.KBSTAT,
                   a603.KNUMH,
                   konp.KOPOS ,
                   konp.KBETR  ,
                   konp.LOEVM_KO
                   from a603 as a603
                   inner join konp as konp on a603.knumh = konp.knumh
                   where a603.matnr  = lv_matnr and a603.lifnr = lv_lifnr ;

endmethod.
ENDCLASS.
