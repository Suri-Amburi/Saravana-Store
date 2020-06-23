*&---------------------------------------------------------------------*
*& Include ZMM_CONTRACT_POTOP                       - Report ZMM_CONTRACT_PO
*&---------------------------------------------------------------------*
REPORT zmm_contract_po.
TYPES : BEGIN OF ty_ekpo,
          ebeln          TYPE ebeln,                              "Purchasing Document Number
          ebelp          TYPE ebelp,                              "Item Number of Purchasing Document
          werks          TYPE ewerk,                              "Plant
          matnr          TYPE matnr,                              "Material Number
          mwskz          TYPE mwskz,                              "Tax on Sales/Purchases Code
          menge          TYPE bstmg,                              "Purchase Order Quantity
          meins          TYPE ekpo-meins,
          netpr          TYPE bprei,                              "Net Price in Purchasing Document (in Document Currency)
          peinh          TYPE epein,                              "Price unit
          zzset_material TYPE ekpo-zzset_material,
          netwr          TYPE bwert,                              "Net Order Value in PO Currency
          bukrs          TYPE bukrs,
          retpo          TYPE retpo,
*          APPROVER1
        END OF ty_ekpo,

        BEGIN OF ty_ekko,
          ebeln     TYPE ebeln,                               "Purchasing Document Number
          bukrs     TYPE bukrs,                                " Company Code
          bsart     TYPE esart,
          aedat     TYPE erdat,
          spras     TYPE ekko-spras,
          lifnr     TYPE elifn,                               "Vendor's account number
          ekgrp     TYPE ekko-ekgrp,
          bedat     TYPE ebdat,                               "Purchasing Document Date
          knumv     TYPE  knumv,                               "Number of the Document Condition
          approver1 TYPE zpprover1,
        END OF ty_ekko,

        BEGIN OF ty_lfa1,
          lifnr TYPE lifnr,                                "Account Number of Vendor or Creditor
          land1 TYPE land1_gp,                             "Country Key
          name1 TYPE name1_gp,                             "Name 1
          ort01 TYPE ort01_gp,                             "City
          regio TYPE regio,                                "Region (State, Province, County)
          stras TYPE stras_gp,                             "Street and House Number
          stcd3 TYPE stcd3,                                "Tax Number 3
          adrnr TYPE adrnr,
        END OF ty_lfa1,

        BEGIN OF ty_t001w,
          werks TYPE werks_d,                            "Plant
          name1 TYPE name1,                              "Name
          stras TYPE stras,                              "Street and House Number
          ort01 TYPE ort01,                              "City
          land1 TYPE land1,                              "Country Key
          adrnr TYPE adrnr,
        END OF ty_t001w,

        BEGIN OF ty_mara,
          matnr TYPE mara-matnr,
          ean11 TYPE mara-ean11,
          matkl TYPE mara-matkl,
        END OF ty_mara,

        BEGIN OF ty_makt,
          matnr TYPE matnr,                                "Material Number
          spras TYPE spras,                                "Language Key
          maktx TYPE maktx,                                "Material description
        END OF ty_makt,

        BEGIN OF ty_t001,
          bukrs TYPE t001-bukrs,
          adrnr TYPE t001-adrnr,
        END OF ty_t001,

        BEGIN OF ty_t024,
          eknam TYPE t024-eknam,
          ekgrp TYPE t024-ekgrp,
        END OF ty_t024,

        BEGIN OF ty_t023t,
          matkl   TYPE t023t-matkl,
          wgbez   TYPE t023t-wgbez,
          wgbez60 TYPE t023t-wgbez60,
        END OF ty_t023t,

        BEGIN OF ty_j_1bbranch,
          bukrs TYPE j_1bbranch-bukrs,                                  "COMPANY CODE
          gstin TYPE j_1igstcd3,                             "GST NO
        END OF ty_j_1bbranch,

        BEGIN OF ty_adr6,
          addrnumber TYPE ad_addrnum,
          smtp_addr  TYPE ad_smtpadr,
        END OF ty_adr6,

        BEGIN OF ty_adrc,
          addrnumber TYPE  adrc-addrnumber,
          name1      TYPE adrc-name1,
          city1      TYPE adrc-city1,
          street     TYPE adrc-street,
          str_suppl1 TYPE adrc-str_suppl1,
          str_suppl2 TYPE adrc-str_suppl2,
          country    TYPE adrc-country,
          langu      TYPE adrc-langu,
          region     TYPE adrc-region,
          post_code1 TYPE adrc-post_code1,
        END OF ty_adrc.

DATA : it_ekko       TYPE TABLE OF ty_ekko,
       wa_ekko       TYPE ty_ekko,

       it_ekpo       TYPE TABLE OF ty_ekpo,
       wa_ekpo       TYPE ty_ekpo,

       it_lfa1       TYPE TABLE OF ty_lfa1,
       wa_lfa1       TYPE ty_lfa1,

       it_t001w      TYPE TABLE OF ty_t001w,
       wa_t001w      TYPE ty_t001w,

       it_mara       TYPE TABLE OF ty_mara,
       wa_mara       TYPE ty_mara,

       it_makt       TYPE TABLE OF ty_makt,
       wa_makt       TYPE ty_makt,

       it_t001       TYPE TABLE OF ty_t001,
       wa_t001       TYPE ty_t001,

       it_t024       TYPE TABLE OF ty_t024,
       wa_t024       TYPE ty_t024,

       it_t023t      TYPE TABLE OF ty_t023t,
       wa_t023t      TYPE ty_t023t,

       it_j_1bbranch TYPE TABLE OF ty_j_1bbranch,
       wa_j_1bbranch TYPE ty_j_1bbranch,

       it_adr6       TYPE TABLE OF ty_adr6,
       wa_adr6       TYPE ty_adr6,

       it_adrc       TYPE TABLE OF ty_adrc,
       wa_adrc       TYPE ty_adrc.

DATA : it_zmain   TYPE TABLE OF zitem_contract,
       it_matdoc   TYPE TABLE OF zjb_matdoc,
       wa_zmain   TYPE zitem_contract,

       it_hdr     TYPE TABLE OF zhdr_contract,
       wa_hdr     TYPE zhdr_contract,
       sl_no(100) TYPE c,
       tot_qty    TYPE ekpo-menge.

DATA : f_name TYPE rs38l_fnam.
       DATA : qr_code TYPE zqr_code.

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
PARAMETERS : p_ebeln TYPE ebeln.
SELECTION-SCREEN END OF BLOCK a1.
