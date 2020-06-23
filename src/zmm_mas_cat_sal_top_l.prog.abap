*&---------------------------------------------------------------------*
*& Include          ZMM_MAS_CAT_SAL_TOP_L
*&---------------------------------------------------------------------*
*TABLES : mara.
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
       END OF ty_gt1,

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


DATA : gt_data   TYPE TABLE OF ty_data,
       gt_data1  TYPE TABLE OF ty_gt1,
       gt_data2 TYPE TABLE OF ty_gt1,
       gt_data3 TYPE TABLE OF ty_gt1,
       gs_data2  TYPE  ty_gt1,
       gs_data1  TYPE  ty_gt1,
       it_mara   TYPE TABLE OF ty_mara,
       it_mbew   TYPE TABLE OF ty_mbew,
*       it_final  TYPE TABLE OF ty_final,
       it_final1 TYPE TABLE OF ty_final,
*       wa_final  TYPE ty_final,
       wa_final1 TYPE ty_final,
       it_mard   TYPE TABLE OF ty_mard.
DATA : lv_matkl TYPE mara-matkl,
       lv_plant TYPE werks_d."bwkey.
data : WA_ADR    TYPE ZADD_STR.

DATA : IT_FINAL TYPE TABLE OF ZMCSTOCK_S,
       WA_FINAL TYPE ZMCSTOCK_S,
       IT_FINAL2 TYPE TABLE OF ZMCSTOCK_S,
       WA_FINAL2 TYPE ZMCSTOCK_S,
       it_hdr TYPE TABLE OF ZMCSTOCK_HDR,
       wa_hdr TYPE ZMCSTOCK_HDR,
       IT_T001W TYPE TABLE OF TY_T001W,
       WA_T001W TYPE TY_T001W,
       it_adrc TYPE TABLE OF ty_adrc ,
       wa_adrc TYPE ty_adrc,
       w_adrc TYPE ty_adrc.

DATA : F_NAME TYPE RS38L_FNAM.

 DATA : gv_zzprice_frm TYPE mara-zzprice_frm,
       gv_size        TYPE mara-size1.

DATA : r_to   TYPE RANGE OF mara-zzprice_to WITH HEADER LINE,
       r_from TYPE RANGE OF mara-zzprice_frm WITH HEADER LINE,
       r_size TYPE RANGE OF mara-size1 WITH HEADER LINE.

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

*DATA : wa_layout TYPE slis_layout_alv .
*wa_layout-zebra = 'X' .
*wa_layout-colwidth_optimize = 'X' .

*DATA: it_events TYPE  slis_t_event,
*      wa_events TYPE slis_alv_event.

DATA: gt_events     TYPE slis_t_event.
DATA : PLANT       TYPE T001W-NAME1.
DATA:
  gd_tab_group TYPE slis_t_sp_group_alv,
  gd_layout    TYPE slis_layout_alv,
  gd_repid     LIKE sy-repid.

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




**  ***********************************************
*TABLES : mara.
*SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001 .
*
*SELECT-OPTIONS : s_matkl FOR lv_matkl ,
*                 S_PLANT FOR LV_PLANT NO INTERVALS no-EXTENSION,
*                 s_size  FOR gv_size  NO INTERVALS NO-EXTENSION,
*                 s_from  FOR gv_zzprice_frm NO INTERVALS NO-EXTENSION.
*
*SELECTION-SCREEN : END OF BLOCK b1 .
**if s_matkl is NOT INITIAL.
**BREAK CLIKHITHA..
*CHECK S_PLANT[] IS NOT INITIAL.
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_size-low.
**endif.
**  if s_matkl is NOT INITIAL.
*  DATA : return TYPE TABLE OF ddshretval.
*  CHECK s_matkl[] IS NOT INITIAL.
*  s_matkl = s_matkl[ 1 ].
**BREAK CLIKHITHA.
*  SELECT size1 FROM mara INTO TABLE @DATA(lt_size) WHERE matkl = @s_matkl-low.
*  SORT lt_size AS TEXT BY size1.
*  DELETE ADJACENT DUPLICATES FROM lt_size COMPARING size1.
**BREAK CLIKHITHA.
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
**     DDIC_STRUCTURE         = ' '
*      RETFIELD               = 'SIZE1'
**     PVALKEY                = ' '
* DYNPROFIELD                 = 'S_SIZE'
*     DYNPPROG                = sy-repid
*     DYNPNR                  = sy-dynnr
**     DYNPROFIELD            = 'S_SIZE'
**     STEPL                  = 0
**     WINDOW_TITLE           =
**     VALUE                  = ' '
**     VALUE_ORG              = 'S'
*     MULTIPLE_CHOICE         = 'X'
*     VALUE_ORG               = 'S'
**     DISPLAY                = ' '
**     CALLBACK_PROGRAM       = ' '
**     CALLBACK_FORM          = ' '
**     CALLBACK_METHOD        =
**     MARK_TAB               =
**   IMPORTING
**     USER_RESET             =
*    TABLES
*      VALUE_TAB              = lt_size
**     FIELD_TAB              =
*     RETURN_TAB             = return.
**     DYNPFLD_MAPPING        =
**   EXCEPTIONS
**     PARAMETER_ERROR        = 1
**     NO_VALUES_FOUND        = 2
**     OTHERS                 = 3
*            .
**  IF SY-SUBRC <> 0.
*** Implement suitable error handling here
**  ENDIF.
*  CLEAR s_size. REFRESH : s_size[] , r_size.
*  LOOP AT return ASSIGNING FIELD-SYMBOL(<ls_return>).
*    s_size-sign = 'I'.
*    s_size-option = 'EQ'.
*    s_size-low = <ls_return>-fieldval.
*    append s_size to s_size[].
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_return>-fieldval ) TO r_size[].
*  ENDLOOP.
**  endif.
**BREAK CLIKHITHA.
*  AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_from-low.
**    if s_matkl is NOT INITIAL.
*  DATA : return TYPE TABLE OF ddshretval.
**  CHECK s_size[] IS NOT INITIAL.
**  BREAK CLIKHITHA.
*  SELECT  zzprice_frm , zzprice_to FROM mara INTO TABLE @DATA(lt_price) WHERE matkl = @s_matkl-low AND size1 IN @s_size[].
*  SORT lt_price BY zzprice_frm zzprice_to.
*  DELETE ADJACENT DUPLICATES FROM lt_price COMPARING zzprice_frm zzprice_to.
*
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
**     DDIC_STRUCTURE         = ' '
*      RETFIELD               = 'SIZE1'
**     PVALKEY                = ' '
*     DYNPROFIELD            = 'S_FROM'
*     DYNPPROG               = sy-repid
*     DYNPNR                 = sy-dynnr
**     DYNPROFIELD            = 'S_FROM'
**     STEPL                  = 0
**     WINDOW_TITLE           =
**     VALUE                  = ' '
**     VALUE_ORG              = 'S'
*     MULTIPLE_CHOICE        = 'X'
*     VALUE_ORG              = 'S'
**     DISPLAY                = ' '
**     CALLBACK_PROGRAM       = ' '
**     CALLBACK_FORM          = ' '
**     CALLBACK_METHOD        =
**     MARK_TAB               =
**   IMPORTING
**     USER_RESET             =
*    TABLES
*      VALUE_TAB              = lt_price
**     FIELD_TAB              =
*     RETURN_TAB             = return.
**     DYNPFLD_MAPPING        =
**   EXCEPTIONS
**     PARAMETER_ERROR        = 1
**     NO_VALUES_FOUND        = 2
**     OTHERS                 = 3
*            .
**  IF SY-SUBRC <> 0.
*** Implement suitable error handling here
**  ENDIF.
*  CLEAR s_from. REFRESH :s_from[] , r_to[].
**BREAK CLIKHITHA.
*  LOOP AT return ASSIGNING FIELD-SYMBOL(<ls_return>).
*    REPLACE ALL OCCURRENCES OF ',' IN <ls_return>-fieldval WITH ''.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_return>-fieldval ) TO r_to[].
*  ENDLOOP.
*
*  DELETE lt_price WHERE zzprice_to NOT IN r_to.
*  LOOP AT lt_price ASSIGNING FIELD-SYMBOL(<ls_price>).
*    IF SY-SUBRC = 0.
*    REPLACE ALL OCCURRENCES OF ',' IN <ls_return>-fieldval WITH ''.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_price>-zzprice_frm ) TO r_from[].
*    s_from-sign = 'I'.
*    s_from-option = 'EQ'.
*    s_from-low = <ls_price>-zzprice_frm.
*    append s_from to s_from[].
*    ENDIF.
*  ENDLOOP.
*
**AT SELECTION-SCREEN OUTPUT.
*  LOOP AT SCREEN.
*    IF screen-name = '%_S_SIZE_%_APP_%-VALU_PUSH' OR screen-name = '%_S_FROM_%_APP_%-VALU_PUSH'.
**      screen-invisible = '1'.
**      MODIFY SCREEN.
*    ENDIF.
*    ENDLOOP.
**endif.
***    LOOP AT SCREEN.
**    IF screen-name = '%_S_FROM_%_APP_%-VALU_PUSH' ."OR screen-name = '%_S_FROM_%_APP_%-VALU_PUSH'.
***      screen-invisible = '1'.
***      MODIFY SCREEN.
**    ENDIF.
**    ENDLOOP.
**************************************************
