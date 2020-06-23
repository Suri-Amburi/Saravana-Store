*&---------------------------------------------------------------------*
*& Include          SAPMZLOAD_TOP
*&---------------------------------------------------------------------*

PROGRAM sapmzload.
**** Screen Fields Variables****
**** 9001 ******

DATA : gv_exidv          TYPE exidv,
       gv_vbeln          TYPE vbeln,
       gv_ebeln          TYPE ebeln,
       gv_tot            TYPE i,
       gv_pen            TYPE i,
       gv_scn            TYPE i,
       gv_veh            TYPE signi,
       gv_icon_name      TYPE char30,
       gv_icon_9999(132),
       gv_text           TYPE char10,
       gv_charg          TYPE char20,
       gv_rem            TYPE char6,
       gv_total          TYPE char6,
       gv_totno          TYPE char6,
       gv_totqty         TYPE VEMNG,
       gv_x              TYPE c.

*** Global Declaration

DATA: ok_code1  TYPE sy-ucomm,
      ok_code2  TYPE sy-ucomm,
      gv_matdoc TYPE bapi2017_gm_head_ret-mat_doc.

*** Types Declaration

TYPES: BEGIN OF ty_vekp,
         venum    TYPE venum,      "Internal Handling Unit Number
         exidv    TYPE exidv,      "External Handling Unit Identification
         vhilm    TYPE vhilm,      "Packaging Materials
         vpobjkey TYPE vpobjkey,   "Key for Object to Which the Handling Unit is Assigned
         zzmblnr  TYPE mblnr,      "Number of Material Document
         zzdate   TYPE erdat,      "Date on which the record was created
         zztime   TYPE uzeit,      "Time
       END OF ty_vekp,
       ty_t_vekp TYPE STANDARD TABLE OF ty_vekp.

TYPES: BEGIN OF ty_temp,
         venum TYPE venum,      "Internal Handling Unit Number
         exidv TYPE exidv,      "External Handling Unit Identification
       END OF ty_temp,
       ty_t_temp TYPE STANDARD TABLE OF ty_temp.

TYPES : BEGIN OF ty_mess,
          err   TYPE char1,
          mess1 TYPE char20,
          mess2 TYPE char20,
          mess3 TYPE char20,
          mess4 TYPE char20,
          mess5 TYPE char20,
        END OF ty_mess.

TYPES : BEGIN OF ty_lips,
          vbeln TYPE vbeln,
          posnr TYPE posnr,
          vgbel TYPE vgbel,
          vgpos TYPE vgpos,
          matnr TYPE matnr,
          lfimg TYPE lfimg,
          werks TYPE werks_d,
          charg TYPE charg_d,
          meins TYPE meins,
          pstyv TYPE pstyv_vl,
        END OF ty_lips,
        ty_t_lips TYPE STANDARD TABLE OF ty_lips,


        BEGIN OF ty_likp,
          vbeln  TYPE vbeln_vl,
          kunnr  TYPE kunwe,
          END OF ty_likp,
     ty_t_likp TYPE STANDARD TABLE OF ty_likp,

        BEGIN OF ty_vttp,
          tknum TYPE tknum,
          tpnum TYPE tpnum,
          vbeln TYPE vbeln_vl,
        END OF ty_vttp,
        ty_t_vttp TYPE STANDARD TABLE OF ty_vttp,

     BEGIN OF ty_vepo,
       exidv TYPE exidv,
       venum TYPE venum,
       vepos TYPE vepos,
       charg TYPE charg_d,
       vemng TYPE vemng,
     END OF ty_vepo,

     BEGIN OF ty_final,
       exidv TYPE exidv,
       venum TYPE venum,
       vepos TYPE vepos,
       charg TYPE charg_d,
       vemng TYPE vemng,
       menge TYPE menge_d,
       mark  TYPE c,
     END OF ty_final.
*** GLobal Internal Tabel and Work Area

DATA: gi_vekp TYPE ty_t_vekp,
      gi_temp TYPE ty_t_temp,
      gw_temp TYPE ty_temp,
      gw_mess TYPE ty_mess,
      gi_vepo TYPE STANDARD TABLE OF vepo,
      gw_vepo TYPE vepo,
      gw_lips TYPE ty_lips,
      gw_lips1 TYPE ty_lips,
      gw_likp TYPE ty_likp,
      it_likp TYPE ty_t_likp,
      gi_lips TYPE ty_t_lips,
      gi_lips1 TYPE ty_t_lips,
      it_vttp TYPE ty_t_vttp,
      wa_vttp TYPE ty_vttp,
      it_vepo TYPE TABLE OF ty_vepo,
      it_final TYPE TABLE OF ty_final,
      wa_final TYPE ty_final,
      it_fin3 TYPE TABLE OF ty_final,
      wa_fin3 TYPE ty_final.
