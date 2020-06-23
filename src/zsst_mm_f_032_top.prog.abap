*&---------------------------------------------------------------------*
*& Include          ZSST_MM_F_032_TOP
*&---------------------------------------------------------------------*

TABLES EKKO.
DATA  : FM_NAME  TYPE RS38l_FNAM .

TYPES : BEGIN OF TY_EKKO,
          EBELN TYPE EKKO-EBELN,
          AEDAT TYPE EKKO-AEDAT,
          EKGRP TYPE EKKO-EKGRP,
*          LIFNR TYPE EKKO-LIFNR,
          BSART TYPE EKKO-BSART,
          EBELP TYPE EKPO-EBELP,
          RETPO TYPE EKPO-RETPO,
          NETWR TYPE EKPO-NETWR,
          MENGE TYPE EKPO-MENGE,
        END OF TY_EKKO,

        BEGIN OF TY_EK,
          EBELN TYPE EKKO-EBELN,
          AEDAT TYPE EKKO-AEDAT,
          EKGRP TYPE EKKO-EKGRP,
          LIFNR TYPE EKKO-LIFNR,
          BSART TYPE EKKO-BSART,
        END OF TY_EK,

        BEGIN OF TY_EKGRP,
          EKGRP TYPE EKKO-EKGRP,
        END OF TY_EKGRP,

        BEGIN OF TY_EKPO,
          EBELN TYPE EKPO-EBELN,
          NETWR TYPE EKPO-NETWR,
          MENGE TYPE EKPO-MENGE,
        END OF TY_EKPO,

        BEGIN OF TY_T024,
          EKGRP TYPE T024-EKGRP,
          EKNAM TYPE T024-EKNAM,
        END OF TY_T024,

        BEGIN OF TY_T001W,
          WERKS TYPE T001W-WERKS,
          ADRNR TYPE T001W-ADRNR,
        END OF TY_T001W,

        BEGIN OF TY_ADRC,
          ADDRNUMBER  TYPE ADRC-ADDRNUMBER   ,
          NAME1       TYPE ADRC-NAME1        ,
          NAME2       TYPE ADRC-NAME2        ,
          STREET      TYPE ADRC-STREET       ,
          STR_SUPPL1  TYPE ADRC-STR_SUPPL1   ,
          CITY1       TYPE ADRC-CITY1        ,
          POST_CODE1  TYPE ADRC-POST_CODE1   ,
          BEZEI       TYPE T005U-BEZEI       ,
        END OF TY_ADRC,

        BEGIN OF TY_EMAIL,
          MAIL TYPE ADR6-SMTP_ADDR,
        END OF TY_EMAIL,
*
*        BEGIN OF TY_LFA1,
*          LIFNR TYPE LFA1-LIFNR,
*          NAME1 TYPE LFA1-NAME1,
*          ORT01 TYPE LFA1-ORT01,
*        END OF TY_LFA1,
*
*        BEGIN OF TY_SLT,
*          SR_NO   TYPE INT4      ,
*          VEN_NO  TYPE LFA1-LIFNR,
*          DESC    TYPE LFA1-NAME1,
*          LOC     TYPE LFA1-ORT01,
*          EBELN   TYPE EKKO-EBELN,
*          MENGE   TYPE EKPO-MENGE,
*          NETWR   TYPE EKPO-NETWR,
*        END OF TY_SLT,

        BEGIN OF TY_FINAL,
          GROUP  TYPE T024-EKNAM,
          NO_PO  TYPE INT4      ,
          OR_QTY TYPE EKPO-MENGE,
          NTWR   TYPE EKPO-NETWR,
        END OF TY_FINAL.

DATA  : SR_NO       TYPE INT4,
        TOT_QTY     TYPE EKPO-MENGE,
        TOT_PO      TYPE INT4,
        TOT_NTWR    TYPE EKPO-NETWR,
        LV_LIFNR    TYPE EKKO-LIFNR,
        LV_FIELD    TYPE CHAR20.


DATA  : IT_EKKO   TYPE TABLE OF TY_EKKO             ,
        IT_EKPO   TYPE TABLE OF TY_EKPO             ,
        IT_EK     TYPE TABLE OF TY_EK               ,
        IT_EKGRP  TYPE TABLE OF TY_EKGRP            ,
        IT_T024   TYPE TABLE OF TY_T024             ,
        IT_T001W  TYPE TABLE OF TY_T001W            ,
        IT_ADRC   TYPE TABLE OF TY_ADRC             ,
        IT_EMAIL  TYPE TABLE OF TY_EMAIL            ,
*        IT_SLT    TYPE TABLE OF TY_SLT              ,
*        IT_LFA1   TYPE TABLE OF TY_LFA1              ,
*        IT_TABLE  TYPE REF   TO CL_SALV_TABLE       ,
*        IT_TAB    TYPE REF   TO CL_SALV_TABLE       ,
*        IT_EVENTS TYPE REF   TO CL_SALV_EVENTS_TABLE,
        IT_FINAL  TYPE TABLE OF ZSST_MM_F_032_STCT  .

DATA  : WA_EKKO   TYPE TY_EKKO           ,
        WA_EKPO   TYPE TY_EKPO           ,
        WA_EK     TYPE TY_EK             ,
        WA_EKGRP  TYPE TY_EKGRP          ,
        WA_T024   TYPE TY_T024           ,
        WA_T001W  TYPE TY_T001W          ,
        WA_ADRC   TYPE TY_ADRC           ,
        WA_ADR    TYPE  ZARC_STR         ,
        WA_EMAIL  TYPE  TY_EMAIL         ,
*        WA_SLT    TYPE TY_SLT            ,
*        WA_LFA1   TYPE TY_LFA1           ,
        WA_FINAL  TYPE ZSST_MM_F_032_STCT.

DATA: i_otf       TYPE itcoo    OCCURS 0 WITH HEADER LINE,
      i_tline     LIKE tline    OCCURS 0 WITH HEADER LINE,
      i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE,
      i_xstring   TYPE xstring,
* Objects to send mail.
      i_objpack   LIKE sopcklsti1 OCCURS 0 WITH HEADER LINE,
      i_objtxt    LIKE solisti1   OCCURS 0 WITH HEADER LINE,
      i_objbin    LIKE solix      OCCURS 0 WITH HEADER LINE,
      i_reclist   LIKE somlreci1  OCCURS 0 WITH HEADER LINE,
* Work Area declarations
      wa_objhead  TYPE soli_tab,
      w_ctrlop    TYPE ssfctrlop,
      w_compop    TYPE ssfcompop,
      w_return    TYPE ssfcrescl,
      wa_buffer   TYPE string,
* Variables declarations
      v_form_name TYPE rs38l_fnam,
      v_len_in    LIKE sood-objlen.

DATA: in_mailid TYPE ad_smtpadr.

data: lv_timestamp type timestamp.

GET TIME STAMP FIELD lv_timestamp.
