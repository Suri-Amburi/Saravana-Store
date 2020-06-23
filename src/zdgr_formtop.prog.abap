*&---------------------------------------------------------------------*
*& Include ZDGR_FORMTOP                             - Report ZDGR_FORM
*&---------------------------------------------------------------------*
REPORT ZDGR_FORM.
TYPES : BEGIN OF TY_KLAH ,
          CLINT TYPE CLINT,
          KLART TYPE KLASSENART,
          CLASS TYPE KLASSE_D,
          VONDT TYPE VONDAT,
          BISDT TYPE BISDAT,
          WWSKZ TYPE KLAH-WWSKZ,
        END OF TY_KLAH .

TYPES : BEGIN OF TY_KLAH1 ,
          CLINT TYPE CLINT,
          KLART TYPE KLASSENART,
          CLASS TYPE MATKL,
          VONDT TYPE VONDAT,
          BISDT TYPE BISDAT,
          WWSKZ TYPE KLAH-WWSKZ,
        END OF TY_KLAH1 .

TYPES : BEGIN OF TY_KSSK ,
          OBJEK TYPE CUOBN,
          MAFID TYPE KLMAF,
          KLART TYPE KLASSENART,
          CLINT TYPE CLINT,
          ADZHL TYPE ADZHL,
          DATUB TYPE DATUB,
        END OF TY_KSSK .

TYPES : BEGIN OF TY_KSSK1 ,
          OBJEK  TYPE CLINT,
          OBJEK1 TYPE KSSK-OBJEK,
        END OF TY_KSSK1 .

TYPES : BEGIN OF TY_MARA,
          MATNR TYPE MATNR,
          MATKL TYPE MATKL,
        END OF TY_MARA .

TYPES : BEGIN OF TY_ZINW_HDR ,
          QR_CODE	   TYPE ZQR_CODE,
          INWD_DOC   TYPE ZINWD_DOC,
          EBELN	     TYPE EBELN,
          LIFNR	     TYPE ELIFN,
          BILL_DATE	 TYPE ZBILL_DAT,
          ERDATE     TYPE ERDAT,
          ACT_NO_BUD TYPE ZNO_BUD,
        END OF TY_ZINW_HDR ,

        BEGIN OF TY_T001W,
          WERKS TYPE T001W-WERKS,
          ADRNR TYPE T001W-ADRNR,
          NAME1 TYPE T001W-NAME1,
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
        END OF TY_ADRC.

DATA : IT_KLAH    TYPE TABLE OF TY_KLAH,
       WA_KLAH    TYPE TY_KLAH,
       IT_KLAHA   TYPE TABLE OF TY_KLAH,
       WA_KLAHA   TYPE TY_KLAH,
       IT_KLAH1   TYPE TABLE OF TY_KLAH1,
       WA_KLAH1   TYPE TY_KLAH1,
       IT_KSSK1   TYPE TABLE OF TY_KSSK1,
       WA_KSSK1   TYPE TY_KSSK1,
       IT_KSSK    TYPE TABLE OF TY_KSSK,
       WA_KSSK    TYPE TY_KSSK,
       IT_MARA    TYPE TABLE OF TY_MARA,
       WA_MARA    TYPE TY_MARA,
       IT_INW_HDR TYPE TABLE OF TY_ZINW_HDR,
       WA_INW_HDR TYPE TY_ZINW_HDR,
       IT_T001W TYPE TABLE OF TY_T001W,
       WA_T001W TYPE TY_T001W,
       w_t001w TYPE TY_T001W,
       it_adrc TYPE TABLE OF ty_adrc ,
       wa_adrc TYPE ty_adrc.
*******************************Final Screen1****************************
TYPES : BEGIN OF TY_FINAL ,
          CATEGORY(20) TYPE C,
          WERKS        TYPE T001W-WERKS,
          GRPO_V       TYPE NETPR,
          GRPO_WT      TYPE NETPR,
          BUNDLE(10)   TYPE I,
          QTY          TYPE MENGE_D,
          LIFNR        TYPE LIFNR,
          NAME1        TYPE NAME1,
          GRPO         TYPE ZINWD_DOC,
          GRPO_N(5)    TYPE I,
          BLDAT        TYPE MKPF-BLDAT,
          MATNR        TYPE ZINW_T_ITEM-MATNR,
          QR_CODE      TYPE ZINW_T_ITEM-QR_CODE,
          GATE_ENTRY   TYPE ZINW_T_STATUS-CREATED_DATE,
        END OF TY_FINAL .
data :  IT_final TYPE TABLE OF ZDGR_ITEM,
        WA_final TYPE ZDGR_ITEM.

*DATA : IT_FINAL TYPE TABLE OF TY_FINAL,
*       WA_FINAL TYPE TY_FINAL.
DATA : IT_FINAL1 TYPE TABLE OF TY_FINAL,
       WA_FINAL1 TYPE TY_FINAL.
DATA : IT_FINAL2 TYPE TABLE OF TY_FINAL,
       IT_FINAL3 TYPE TABLE OF TY_FINAL,
       WA_FINAL3 TYPE TY_FINAL,
       it_final4 TYPE TABLE OF ty_final,
       WA_FINAL4 TYPE TY_FINAL,
       IT_BUN    TYPE TABLE OF TY_FINAL,
       WA_FINAL2 TYPE TY_FINAL,
*       WA_FINAL3 TYPE TY_FINAL,
       WA_ADR    TYPE  ZARC_STR         .
*************************************************************************

DATA :  LV_WERKS TYPE WERKS_D.
DATA :  LV_DATE TYPE ERDAT ,
        L_DATE TYPE ERDAT.
*data :  IT_MAIN TYPE TABLE OF ZDGR_ITEM,
*        WA_MAIN TYPE ZDGR_ITEM.

DATA : F_NAME TYPE RS38L_FNAM.
DATA : PLANT       TYPE T001W-NAME1.

*****************ADDED ON (28-3-20)   *************************
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
      LV_DOC_SUBJECT          TYPE SOOD-OBJDES,
      v_len_in    LIKE sood-objlen.

DATA: salutation TYPE string.
  DATA: body TYPE string.
  DATA: footer TYPE string.

  DATA: lo_send_request TYPE REF TO cl_bcs,
        lo_document     TYPE REF TO cl_document_bcs,
        lo_sender       TYPE REF TO if_sender_bcs,
        lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL,
        lt_message_body TYPE bcsy_text,
        lx_document_bcs TYPE REF TO cx_document_bcs,
        lv_sent_to_all  TYPE os_boolean.




*  constants:
*  abap_true      type abap_bool value 'X'.
*  data : is_output_options       TYPE ssfcompop.
****************END (28-3-20)  ************************
