*&---------------------------------------------------------------------*
*& Include SAPMZLOAD_NC_TOP                         - Module Pool      SAPMZLOAD_NC
*&---------------------------------------------------------------------*
program sapmzload_nc.

**** Screen Fields Variables****
**** 9001 ******

data : gv_exidv          type exidv,
       gv_vbeln          type vbeln,
       gv_ebeln          type ebeln,
       gv_tot            type i,
       gv_pen            type i,
       gv_scn            type i,
       gv_veh            type signi,
       gv_icon_name      type char30,
       gv_icon_9999(132),
       gv_text           type char10.

*** Global Declaration

data: ok_code1 type sy-ucomm,
      ok_code2 type sy-ucomm,
      gv_matdoc type BAPI2017_GM_HEAD_RET-MAT_DOC.

*** Types Declaration

types: begin of ty_vekp,
         venum    type venum,      "Internal Handling Unit Number
         exidv    type exidv,      "External Handling Unit Identification
         vhilm    type vhilm,      "Packaging Materials
         vpobjkey type vpobjkey,   "Key for Object to Which the Handling Unit is Assigned
         zzmblnr  type mblnr,      "Number of Material Document
         zzdate   type erdat,      "Date on which the record was created
         zztime   type uzeit,      "Time
       end of ty_vekp,
       ty_t_vekp type standard table of ty_vekp.

types: begin of ty_temp,
         venum type venum,      "Internal Handling Unit Number
         exidv type exidv,      "External Handling Unit Identification
       end of ty_temp,
       ty_t_temp type standard table of ty_temp.

types : begin of ty_mess,
          err   type char1,
          mess1 type char20,
          mess2 type char20,
          mess3 type char20,
          mess4 type char20,
          mess5 type char20,
        end of ty_mess.

types : begin of ty_lips,
          vbeln type vbeln,
          posnr type posnr,
          vgbel type vgbel,
          vgpos type vgpos,
        end of ty_lips,
        ty_t_lips type STANDARD TABLE OF ty_lips.

*** GLobal Internal Tabel and Work Area

data: gi_vekp type ty_t_vekp,
      gi_temp type ty_t_temp,
      gw_mess type ty_mess,
      gi_vepo type standard table of vepo,
      gw_vepo type vepo,
      gw_lips type ty_lips,
      gi_lips type ty_t_lips.
