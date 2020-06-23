*&---------------------------------------------------------------------*
*& Include ZSAPMP_MM_PO_CREATE1_TOP                 - Module Pool      ZSAPMP_MM_PO_CREATE1
*&---------------------------------------------------------------------*
PROGRAM ZSAPMP_MM_PO_CREATE1.

TABLES : MARA .

TYPES : BEGIN OF TY_EKKO,
          EBELN	TYPE EBELN , "Purchasing Document Number
          AEDAT TYPE 	ERDAT   , "Date on which the record was created
        END OF TY_EKKO.

TYPES : BEGIN OF TY_EKPO,
          EBELN TYPE EBELN , "  Purchasing Document Number
          EBELP TYPE EBELP, "Item Number of Purchasing Document
          AEDAT TYPE PAEDT  , "  Purchasing Document Item Change Date
          MENGE TYPE BSTMG, "  Purchase Order Quantity
          MEINS TYPE  BSTME , "Purchase Order Unit of Measure
        END OF TY_EKPO.

TYPES : BEGIN OF TY_LFA1,
          LIFNR     TYPE LIFNR  , "ACCOUNT NUMBER OF VENDOR OR CREDITOR
          LAND1     TYPE LAND1_GP, "Country Key
          NAME1     TYPE NAME1_GP  , "  Name 1
          ADRNR     TYPE ADRNR  , "Address
          STCD3     TYPE STCD3,
          REGIO     TYPE LFA1-REGIO,
          VEN_CLASS TYPE LFA1-VEN_CLASS,
        END OF TY_LFA1.

TYPES : BEGIN OF TY_MARA,
          MATNR TYPE MATNR  , "  Material Number
          MATKL TYPE MATKL , "Material Group
          MEINS TYPE MEINS , "  Base Unit of Measure
          TAKLV TYPE MARA-TAKLV,
        END OF TY_MARA.
*
TYPES: BEGIN OF TY_MARC,
         MATNR TYPE MATNR,
         WERKS TYPE WERKS_D,
         STEUC TYPE STEUC,
       END OF TY_MARC.




TYPES : BEGIN OF TY_MAKT,
          MATNR TYPE MATNR  , "Material Number
          SPRAS TYPE SPRAS  , "Language Key
          MAKTX TYPE MAKTX  , "Material description
        END OF TY_MAKT.

TYPES : BEGIN OF TY_A900,
          KAPPL  TYPE KAPPL , "  Application
          KSCHL	 TYPE KSCHA	, "Condition type
          WKREG	 TYPE WKREG	, "Region in which plant is located
          REGIO	 TYPE REGIO	, "Region (State, Province, County)
          TAXK1  TYPE TAXK1, "  Tax Classification 1 for Customer
          TAXM1	 TYPE TAXM1	, "Tax classification material
          STEUC	 TYPE STEUC	, "Control code for consumption taxes in foreign trade
          KFRST	 TYPE KFRST	, "Release status
          DATBI  TYPE KODATBI , "  Validity end date of the condition record
          DATAB  TYPE KODATAB , "  Validity start date of the condition record
          KBSTAT TYPE KBSTAT, " Processing status for conditions
          KNUMH  TYPE KNUMH , "  Condition record number
        END OF TY_A900.

TYPES : BEGIN OF TY_A792 ,
          KAPPL	    TYPE KAPPL,
          KSCHL	    TYPE KSCHA,
          LLAND	    TYPE LLAND,
          REGIO	    TYPE REGIO,
          WKREG	    TYPE WKREG,
          VEN_CLASS TYPE J_1IGTAKLD,
          TAXIM	    TYPE TAXIM1,
          STEUC	    TYPE STEUC,
          KFRST	    TYPE KFRST,
          DATBI	    TYPE KODATBI,
          DATAB	    TYPE KODATAB,
          KBSTAT    TYPE KBSTAT,
          KNUMH	    TYPE KNUMH,
        END OF TY_A792 .

TYPES : BEGIN OF TY_A603 ,
          KAPPL	 TYPE KAPPL,
          KSCHL	 TYPE KSCHA,
          LIFNR	 TYPE ELIFN,
          MATNR	 TYPE MATNR,
          KFRST	 TYPE KFRST,
          DATBI	 TYPE KODATBI,
          DATAB	 TYPE KODATAB,
          KBSTAT TYPE KBSTAT,
          KNUMH	 TYPE KNUMH,
        END OF TY_A603 .
TYPES : BEGIN OF TY_KONP,
          KNUMH    TYPE KNUMH,
          KOPOS    TYPE KOPOS,
          KAPPL    TYPE KONP-KAPPL,
          KSCHL    TYPE KSCHA,
          KBETR    TYPE KBETR_KOND,
          LOEVM_KO TYPE KONP-LOEVM_KO,
        END OF TY_KONP.

TYPES : BEGIN OF TY_ADRC,
          ADDRNUMBER TYPE AD_ADDRNUM,
          DATE_FROM	 TYPE AD_DATE_FR,
          NATION     TYPE AD_NATION,
          NAME1	     TYPE AD_NAME1,
          CITY1	     TYPE AD_CITY1,
          POST_CODE1 TYPE AD_PSTCD1,
          STREET     TYPE AD_STREET,
          COUNTRY	   TYPE LAND1,
          REGION     TYPE REGIO,
          STR_SUPPL1 TYPE AD_STRSPP1,
          STR_SUPPL2 TYPE AD_STRSPP2,
        END OF TY_ADRC .

TYPES : BEGIN OF TY_T001W,
          WERKS TYPE WERKS_D,
          ADRNR TYPE ADRNR,
          EKORG	TYPE EKORG,
          REGIO TYPE T001W-REGIO,
        END OF TY_T001W.

TYPES : BEGIN OF TY_F4TAB ,
          MATNR TYPE MATNR,
          MAKTX TYPE MAKTX,
          MATKL TYPE MATKL,
        END   OF TY_F4TAB .

TYPES : BEGIN OF TY_T001K,
          BWKEY TYPE BWKEY,
          BUKRS TYPE BUKRS,
        END OF TY_T001K.

TYPES : BEGIN OF TY_EINE,
          INFNR TYPE INFNR,
          EKORG TYPE EKORG,
          ESOKZ TYPE ESOKZ,
          WERKS TYPE EWERK,
          PRDAT TYPE PRGBI,
          MWSKZ TYPE MWSKZ,
          NETPR TYPE IPREI,
        END OF TY_EINE .

TYPES  : BEGIN OF TY_EINA ,
           INFNR TYPE INFNR,
           MATNR TYPE MATNR,
           MATKL TYPE MATKL,
           LIFNR TYPE ELIFN,
         END OF TY_EINA.

TYPES : BEGIN OF TY_A003,
          KAPPL TYPE KAPPL,
          KSCHL TYPE KSCHA,
          ALAND TYPE ALAND,
          MWSKZ TYPE MWSKZ,
          KNUMH TYPE KNUMH,
        END OF TY_A003.

*TYPES : BEGIN OF TY_PRCD_ELEMENTS ,
*          KNUMV type KNUMV,
*          KPOSN type KPOSN,
*          STUNR type STUNR,
*          ZAEHK type VFPRC_COND_COUNT,
*          KWERT type VFPRC_ELEMENT_VALUE,
*          KBETR type VFPRC_ELEMENT_AMOUNT,
*        END OF TY_PRCD_ELEMENTS .

TYPES : BEGIN OF TY_ITAB,
          MATNR TYPE MARA-MATNR,
          MATKL TYPE MARA-MATKL,
          MAKTX TYPE MAKT-MAKTX,
        END OF TY_ITAB.

TYPES : BEGIN OF TY_F4H_MATNR,
          MATNR TYPE MATNR,
          MATKL TYPE MATKL,
          MAKTX TYPE MAKTX,
          MEINS TYPE MARA-MEINS,
        END OF TY_F4H_MATNR.

TYPES : BEGIN OF TY_F4H_MATKL,
          MATNR TYPE MATNR,
          MATKL TYPE MATKL,
          WGBEZ TYPE T023T-WGBEZ,
*          MEINS TYPE MARA-MEINS,
        END OF TY_F4H_MATKL.

DATA : L_ERROR(100) TYPE C,
       COL          TYPE LVC_S_COL,
       ROW          TYPE LVC_S_ROID.

DATA : LV_% TYPE KBETR_KOND.
DATA : LV_LEAD TYPE DLYDY,
       VENDOR  TYPE LIFNR.
DATA : IT_F4H_MATNR TYPE TABLE OF TY_F4H_MATNR,
       WA_F4H_MATNR TYPE TY_F4H_MATNR.

DATA : IT_F4H_MATKL TYPE TABLE OF TY_F4H_MATKL,
       WA_F4H_MATKL TYPE TY_F4H_MATKL.

DATA : IT_EKKO   TYPE TABLE OF TY_EKKO,
       WA_EKKO   TYPE TY_EKKO,
       IT_T001K  TYPE TABLE OF TY_T001K,
       WA_T001K  TYPE TY_T001K,
       WA_T026Z  TYPE T026Z,
       IT_EKPO   TYPE TABLE OF TY_EKPO,
       WA_EKPO   TYPE TY_EKPO,
       IT_KONP   TYPE TABLE OF TY_KONP,
       IT_KONP1  TYPE TABLE OF TY_KONP,
       WA_KONP   TYPE TY_KONP,
       WA_KONP1  TYPE TY_KONP,
       IT_MARA   TYPE TABLE OF TY_MARA,
       IT_MARA1  TYPE TABLE OF TY_MARA,
       WA_MARA   TYPE TY_MARA,
       IT_MARC   TYPE TABLE OF TY_MARC,
       WA_MARC   TYPE TY_MARC,
       IT_ADRC   TYPE TABLE OF TY_ADRC,
       WA_ADRC   TYPE TY_ADRC,
       WA_ADRC1  TYPE TY_ADRC,
       IT_ITAB   TYPE TABLE OF TY_ITAB,
       IT_ITAB1  TYPE TABLE OF TY_ITAB,
       WA_ITAB   TYPE TY_ITAB,
       IT_MAKT   TYPE TABLE OF TY_MAKT,
       WA_MAKT   TYPE TY_MAKT,
       IT_ITEM   TYPE STANDARD TABLE OF  ZPO_ITEM,
       IT_F41    TYPE TABLE OF DFIES,
       IT_RET    TYPE TABLE OF DDSHRETVAL,
       IT_ITEM1  TYPE STANDARD TABLE OF  ZPO_ITEM,
       WA_ITEM   TYPE ZPO_ITEM,
       WA_ITEM1  TYPE ZPO_ITEM,
       IT_LFA1   TYPE TABLE OF TY_LFA1,
       WA_LFA1   TYPE TY_LFA1,
       WA_T500W  TYPE T500W,
       WA_HEADER TYPE ZPO_HEADER,
       WA_T001W  TYPE TY_T001W,
       IT_EINE   TYPE TABLE OF TY_EINE,
       IT_EINA   TYPE TABLE OF TY_EINA,
       WA_EINA   TYPE TY_EINA,
       WA_EINE   TYPE TY_EINE,
       IT_A900   TYPE TABLE OF TY_A900,
       WA_A900   TYPE TY_A900,
       IT_A792   TYPE TABLE OF TY_A792,
       WA_A792   TYPE TY_A792,
       IT_T023T  TYPE TABLE OF T023T,
       WA_T023T  TYPE T023T,
       IT_A603   TYPE TABLE OF TY_A603,
       WA_A603   TYPE TY_A603.

DATA : LV_WERKS TYPE WERKS_D .
DATA : LV_LGORT TYPE LGORT_D .
DATA : LV_EKGRP TYPE EKGRP .
DATA : LV_ISSUE(20) TYPE C .
DATA : LV_ATTESTED(20) TYPE C .
DATA : LV_VENDOR(20) TYPE C .
DATA : LV_VENDOR1 TYPE LIFNR .
FIELD-SYMBOLS: <ITAB> TYPE LVC_T_MODI.
DATA : IT_WHG01 TYPE TABLE OF WGH01 .
DATA : WA_WHG01 TYPE  WGH01 .

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC1' ITSELF
*CONTROLS: TC1 TYPE TABLEVIEW USING SCREEN 9000.

*&SPWIZARD: LINES OF TABLECONTROL 'TC1'
DATA:     G_TC1_LINES  LIKE SY-LOOPC.

DATA:     OK_CODE LIKE SY-UCOMM.

DATA : HEADER  LIKE BAPIMEPOHEADER,
       HEADERX LIKE BAPIMEPOHEADERX.
*       vendor_addr like BAPIMEPOADDRVENDOR .

DATA : ITEM        TYPE TABLE OF BAPIMEPOITEM  WITH HEADER LINE,
       POSCHEDULE  TYPE TABLE OF BAPIMEPOSCHEDULE WITH HEADER LINE,
       POSCHEDULEX TYPE TABLE OF BAPIMEPOSCHEDULX WITH HEADER LINE,
       ITEMX       TYPE TABLE OF BAPIMEPOITEMX  WITH HEADER LINE,
       RETURN      TYPE TABLE OF BAPIRET2,
       WA_RETURN   TYPE  BAPIRET2.
DATA : IBAPICONDX TYPE TABLE OF BAPIMEPOCONDX WITH HEADER LINE.
DATA : IBAPICOND TYPE TABLE OF BAPIMEPOCOND WITH HEADER LINE .
DATA : LV_EBELN TYPE EBELN .
DATA : LV_SUC(255) TYPE C .

DATA: NUM      TYPE I.
DATA: NUM1      TYPE I.

DATA: IT1_BAPI_POHEADER  LIKE BAPI_TE_MEPOHEADER,
      IT1_BAPI_POHEADERX LIKE BAPI_TE_MEPOHEADERX,
      IT_EXTENSIONIN     TYPE TABLE OF BAPIPAREX,
      WA_EXTENSIONIN     TYPE BAPIPAREX.

DATA : TY_TOOLBAR      TYPE STB_BUTTON.
DATA: CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GRID             TYPE REF TO CL_GUI_ALV_GRID,
      GS_LAYOUT        TYPE LVC_S_LAYO,
      GS_FIELDCAT      TYPE LVC_S_FCAT,
      GI_FIELDCAT      TYPE LVC_T_FCAT,
      MYCONTAINER      TYPE SCRFNAME VALUE 'MYCONTAINER'.

DATA : GT_F4 TYPE LVC_T_F4 WITH HEADER LINE,
       GS_F4 TYPE LVC_S_F4.

DATA : GTR_F4 TYPE LVC_T_F4,
       GSR_F4 TYPE LVC_S_F4.

DATA :GS_EXCLUDE   TYPE UI_FUNC,
      GT_TLBR_EXCL TYPE UI_FUNCTIONS.
***************************Event Defnition**************************
CLASS CL_EVENT_REC DEFINITION DEFERRED.
CLASS CL_EVENT_REC1 DEFINITION DEFERRED.

DATA: G_VERIFIER TYPE REF TO CL_EVENT_REC.
DATA: G_VERIFIER1 TYPE REF TO CL_EVENT_REC1.
DATA : LV_SL_NO TYPE POSNR .


CLASS CL_EVENT_REC1 DEFINITION .

  PUBLIC SECTION.
*  types: BEGIN OF ty_key,
*           WCAT TYPE ZWCAT,
*           WST  TYPE ZWASTE_N,
*         END OF ty_key.
*
* types: it_key TYPE STANDARD TABLE OF ty_key,
*       it_tab TYPE STANDARD TABLE OF ty_waste.
*  data: er_data_changed type ref to cl_alv_changed_data_protocol.
    METHODS: HANDLE_DATA_CHANGED
                  FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED.


*  METHODs: get_inserted_rows
*            EXPORTING
*              inserted_rows TYPE it_key.
*
*  methods:get_deleted_rows
*            EXPORTING
*              deleted_rows TYPE it_tab.
*
*  methods:refresh_delta_table.
*
*  methods: set_table_is_initial.
*
*  methods: set_table_is_not_initial.
*
*  methods: table_is_initial
*                returning value(initial) type char01.

*  PRIVATE SECTION.
*
    DATA: ERROR_IN_DATA TYPE C.
**          inserted_rows TYPE it_key,
**          initial_table type c,
**          deleted_rows TYPE STANDARD TABLE OF ty_waste.
**
**    methods: perform_semantic_checks
**             importing
**                pr_data_changed type ref to cl_alv_changed_data_protocol.
**
*    METHODS: CHECK_DOUBLE_ENTRIES
*      IMPORTING
*        PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

ENDCLASS.

CLASS CL_EVENT_REC1 IMPLEMENTATION.

  METHOD HANDLE_DATA_CHANGED.
*    BREAK-POINT.
    IF ER_DATA_CHANGED->MT_INSERTED_ROWS IS NOT INITIAL.

      RETURN.
    ENDIF.

    IF ER_DATA_CHANGED->MT_DELETED_ROWS IS NOT INITIAL.
      PERFORM DELETE USING ER_DATA_CHANGED.
*      BREAK BREDDY.
*      LV_SL_NO = 10 .
*      DELETE IT_ITEM WHERE MATNR IS  INITIAL .
*      LOOP AT IT_ITEM INTO WA_ITEM.
*        WA_ITEM-SL_NO = LV_SL_NO .
*        LV_SL_NO = LV_SL_NO + 10 .
*        MODIFY IT_ITEM FROM WA_ITEM TRANSPORTING sl_no .
*      ENDLOOP.
*      IF GRID IS BOUND.
*        CALL METHOD GRID->REFRESH_TABLE_DISPLAY.
*      ENDIF.
      RETURN.
    ENDIF.

    PERFORM DATA_CHANGED USING ER_DATA_CHANGED.
*    ERROR_IN_DATA = SPACE .
**    CALL METHOD ER_DATA_CHANGED->REFRESH_PROTOCOL .
*
**    CALL METHOD CHECK_DOUBLE_ENTRIES( ER_DATA_CHANGED ) .
**   call method perform_semantic_checks( er_data_changed ).
*    IF ERROR_IN_DATA = 'X'.
*      CALL METHOD ER_DATA_CHANGED->DISPLAY_PROTOCOL
*        EXPORTING
*          I_DISPLAY_TOOLBAR = ABAP_TRUE.
*    ENDIF.
*  ENDMETHOD.
*  METHOD CHECK_DOUBLE_ENTRIES.
*
  ENDMETHOD.

ENDCLASS .


CLASS CL_EVENT_REC DEFINITION.

  PUBLIC SECTION .


    METHODS : ON_F4 FOR EVENT ONF4 OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                  E_FIELDNAME
                  E_FIELDVALUE
                  ES_ROW_NO
                  ER_EVENT_DATA
                  ET_BAD_CELLS
                  E_DISPLAY .

    METHODS : VALIDATE FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED .


ENDCLASS .


CLASS CL_EVENT_REC IMPLEMENTATION .


  METHOD ON_F4.
*    BREAK-POINT.
    BREAK BREDDY .
    IF E_FIELDNAME = 'MATKL' .
      DATA: LS_F4H      TYPE TY_F4H_MATNR,
            LS_RET      TYPE DDSHRETVAL,
            W_CAT(2)    TYPE C,
            LS_MODI     TYPE LVC_S_MODI,
            LS_FIN_DISP LIKE LINE OF IT_ITEM,
            WA_RET      TYPE DDSHRETVAL.
*      wa_wst TYPE ty_f4h.

      REFRESH: IT_F41,  IT_F4H_MATNR , IT_RET.
      READ TABLE IT_ITEM INTO WA_ITEM INDEX ES_ROW_NO-ROW_ID .
      CHECK SY-SUBRC = 0 . "AND wa_item-MATNR IS NOT INITIAL.
      REFRESH: IT_RET.
*      SELECT MARA~MATNR MARA~MATKL T023T~WGBEZ  INTO TABLE IT_F4H_MATKL FROM
*      T023T AS T023T INNER JOIN
*      MARA AS MARA ON
*      MARA~MATKL = T023T~MATKL
*      FOR ALL ENTRIES IN IT_MARA
*      WHERE t023t~matkl = IT_MAra-Matkl.

      IF WA_ITEM-MATNR IS INITIAL.
        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
          EXPORTING
*           DDIC_STRUCTURE  = ' '
            RETFIELD        = 'MATKL'
*           PVALKEY         = ' '
            DYNPPROG        = SY-REPID
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'MATKL'
*           STEPL           = 0
*           WINDOW_TITLE    =
*           VALUE           = ' '
            VALUE_ORG       = 'S'
*           MULTIPLE_CHOICE = ' '
*           DISPLAY         = ' '
*           CALLBACK_PROGRAM       = ' '
*           CALLBACK_FORM   = ' '
*           CALLBACK_METHOD =
*           MARK_TAB        =
*        IMPORTING
*           USER_RESET      =
          TABLES
            VALUE_TAB       = IT_T023T "IT_F4H_MATKL
            FIELD_TAB       = IT_F41
            RETURN_TAB      = IT_RET
*           DYNPFLD_MAPPING =
          EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.
        IF SY-SUBRC <> 0.
* Implement suitable error handling here
*       endif.
        ELSE.
          READ TABLE IT_RET INTO WA_RET INDEX 1.
          ASSIGN ER_EVENT_DATA->M_DATA->* TO <ITAB>.
          READ TABLE IT_ITEM INDEX ES_ROW_NO-ROW_ID INTO LS_FIN_DISP.
          LS_MODI-ROW_ID = ES_ROW_NO-ROW_ID.
          LS_MODI-FIELDNAME = 'MATKL'.
          READ TABLE IT_T023T INTO WA_T023T WITH KEY MATKL = WA_RET-FIELDVAL .
          LS_MODI-VALUE = WA_T023T-WGBEZ .
          APPEND LS_MODI TO <ITAB>.

        ENDIF.
        ER_EVENT_DATA->M_EVENT_HANDLED = 'X' .
      ELSE.
*        IT_MARA1[] = IT_MARA[] .
        DELETE IT_F4H_MATKL WHERE MATNR <> WA_ITEM-MATNR .
        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
          EXPORTING
*           DDIC_STRUCTURE  = ' '
            RETFIELD        = 'MATKL'
*           PVALKEY         = ' '
            DYNPPROG        = SY-REPID
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'MATKL'
*           STEPL           = 0
*           WINDOW_TITLE    =
*           VALUE           = ' '
            VALUE_ORG       = 'S'
*           MULTIPLE_CHOICE = ' '
*           DISPLAY         = ' '
*           CALLBACK_PROGRAM       = ' '
*           CALLBACK_FORM   = ' '
*           CALLBACK_METHOD =
*           MARK_TAB        =
*        IMPORTING
*           USER_RESET      =
          TABLES
            VALUE_TAB       = IT_T023T "IT_F4H_MATKL
            FIELD_TAB       = IT_F41
            RETURN_TAB      = IT_RET
*           DYNPFLD_MAPPING =
          EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.
        IF SY-SUBRC <> 0.
* Implement suitable error handling here
*       endif.
        ELSE.
          READ TABLE IT_RET INTO WA_RET INDEX 1.
          ASSIGN ER_EVENT_DATA->M_DATA->* TO <ITAB>.
          READ TABLE IT_ITEM INDEX ES_ROW_NO-ROW_ID INTO LS_FIN_DISP.
          LS_MODI-ROW_ID = ES_ROW_NO-ROW_ID.
          LS_MODI-FIELDNAME = 'MATKL'.
          READ TABLE IT_T023T INTO WA_T023T WITH KEY MATKL = WA_RET-FIELDVAL .
          LS_MODI-VALUE = WA_T023T-WGBEZ .
*          LS_MODI-VALUE = WA_RET-FIELDVAL.
          APPEND LS_MODI TO <ITAB>.

        ENDIF.
        ER_EVENT_DATA->M_EVENT_HANDLED = 'X' .

      ENDIF.
    ELSEIF E_FIELDNAME = 'MATNR'.
*      DATA: LS_F4H      TYPE TY_F4H_MATNR,
*            LS_RET      TYPE DDSHRETVAL,
*            W_CAT(2)    TYPE C,
*            LS_MODI     TYPE LVC_S_MODI,
*            LS_FIN_DISP LIKE LINE OF IT_ITEM,
*            WA_RET      TYPE DDSHRETVAL.
*      wa_wst TYPE ty_f4h.

      REFRESH: IT_F41,  IT_F4H_MATNR , IT_RET.
      READ TABLE IT_ITEM INTO WA_ITEM INDEX ES_ROW_NO-ROW_ID .
      CHECK SY-SUBRC = 0 . "AND wa_item-MATNR IS NOT INITIAL.
      REFRESH: IT_RET.

      REFRESH : IT_F4H_MATNR ,  IT_WHG01.
      SELECT MARA~MATNR MARA~MATKL MAKT~MAKTX MARA~MEINS  INTO TABLE IT_F4H_MATNR FROM
      MARA AS MARA INNER JOIN
      MAKT AS MAKT ON
      MARA~MATNR = MAKT~MATNR
      FOR ALL ENTRIES IN IT_MAKT
      WHERE MAKT~MATNR = IT_MAKT-MATNR.
      IF WA_ITEM-MATKL IS INITIAL.

        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
          EXPORTING
*           DDIC_STRUCTURE  = ' '
            RETFIELD        = 'MATNR'
*           PVALKEY         = ' '
            DYNPPROG        = SY-REPID
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'MATNR'
*           STEPL           = 0
*           WINDOW_TITLE    =
*           VALUE           = ' '
            VALUE_ORG       = 'S'
*           MULTIPLE_CHOICE = ' '
*           DISPLAY         = ' '
*           CALLBACK_PROGRAM       = ' '
*           CALLBACK_FORM   = ' '
*           CALLBACK_METHOD =
*           MARK_TAB        =
*        IMPORTING
*           USER_RESET      =
          TABLES
            VALUE_TAB       = IT_F4H_MATNR
            FIELD_TAB       = IT_F41
            RETURN_TAB      = IT_RET
*           DYNPFLD_MAPPING =
          EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.
        IF SY-SUBRC <> 0.
*        IF IT_RET IS INITIAL .
* Implement suitable error handling here
*       endif.
*          ASSIGN ER_EVENT_DATA->M_DATA->* TO <ITAB>.
*          READ TABLE IT_ITEM INDEX ES_ROW_NO-ROW_ID INTO LS_FIN_DISP.
*          LS_MODI-ROW_ID = ES_ROW_NO-ROW_ID.
*          LS_MODI-FIELDNAME = 'MATNR'.
*          LS_MODI-VALUE =   E_FIELDVALUE.
*          APPEND LS_MODI TO <ITAB>.
*          return .

        ELSE.
          READ TABLE IT_RET INTO WA_RET INDEX 1.
          ASSIGN ER_EVENT_DATA->M_DATA->* TO <ITAB>.
          READ TABLE IT_ITEM INDEX ES_ROW_NO-ROW_ID INTO LS_FIN_DISP.
          LS_MODI-ROW_ID = ES_ROW_NO-ROW_ID.
          LS_MODI-FIELDNAME = 'MATNR'.
          LS_MODI-VALUE = WA_RET-FIELDVAL.
          APPEND LS_MODI TO <ITAB>.
          ER_EVENT_DATA->M_EVENT_HANDLED = 'X' .
        ENDIF.


      ELSEIF WA_ITEM-MATKL IS NOT INITIAL .
*        BREAK-POINT.
        READ TABLE IT_T023T INTO WA_T023T WITH KEY WGBEZ = WA_ITEM-MATKL .
        DELETE IT_F4H_MATNR WHERE MATKL <> WA_T023T-MATKL .

        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
          EXPORTING
*           DDIC_STRUCTURE  = ' '
            RETFIELD        = 'MATNR'
*           PVALKEY         = ' '
            DYNPPROG        = SY-REPID
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'MATNR'
*           STEPL           = 0
*           WINDOW_TITLE    =
*           VALUE           = ' '
            VALUE_ORG       = 'S'
*           MULTIPLE_CHOICE = ' '
*           DISPLAY         = ' '
*           CALLBACK_PROGRAM       = ' '
*           CALLBACK_FORM   = ' '
*           CALLBACK_METHOD =
*           MARK_TAB        =
*        IMPORTING
*           USER_RESET      =
          TABLES
            VALUE_TAB       = IT_F4H_MATNR
            FIELD_TAB       = IT_F41
            RETURN_TAB      = IT_RET
*           DYNPFLD_MAPPING =
          EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.
        IF SY-SUBRC <> 0.
*        IF IT_RET IS INITIAL .
* Implement suitable error handling here
*           ASSIGN ER_EVENT_DATA->M_DATA->* TO <ITAB>.
*          READ TABLE IT_ITEM INDEX ES_ROW_NO-ROW_ID INTO LS_FIN_DISP.
*          LS_MODI-ROW_ID = ES_ROW_NO-ROW_ID.
*          LS_MODI-FIELDNAME = 'MATNR'.
*          LS_MODI-VALUE =   E_FIELDVALUE.
*          APPEND LS_MODI TO <ITAB>.
*          return .

        ELSE.
          READ TABLE IT_RET INTO WA_RET INDEX 1.
          ASSIGN ER_EVENT_DATA->M_DATA->* TO <ITAB>.
          READ TABLE IT_ITEM INDEX ES_ROW_NO-ROW_ID INTO LS_FIN_DISP.
          LS_MODI-ROW_ID = ES_ROW_NO-ROW_ID.
          LS_MODI-FIELDNAME = 'MATNR'.
          LS_MODI-VALUE = WA_RET-FIELDVAL.
          APPEND LS_MODI TO <ITAB>.
          ER_EVENT_DATA->M_EVENT_HANDLED = 'X' .
        ENDIF.




      ENDIF.

    ENDIF.
  ENDMETHOD .


*************declaration for f4 help************

*******************

******************************************
*************declaration for f4 help************



  METHOD VALIDATE.
    DATA: LS_GOOD TYPE LVC_S_MODI,
          L_MATNR TYPE MATNR,
          L_MAKTX TYPE MAKTX,
          L_MEINS TYPE MEINS,
          L_LINE  TYPE I,
          MATNR_D TYPE MATNR.

    BREAK breddy .
    LOOP AT ER_DATA_CHANGED->MT_GOOD_CELLS INTO LS_GOOD .
*      BREAK-POINT.
      CASE LS_GOOD-FIELDNAME .
        WHEN 'matnr' .
          CALL METHOD ER_DATA_CHANGED->GET_CELL_VALUE
            EXPORTING
              I_ROW_ID    = LS_GOOD-ROW_ID  " Row ID
*             I_TABIX     =     " Table Index
              I_FIELDNAME = LS_GOOD-FIELDNAME " Field Name
            IMPORTING
              E_VALUE     = MATNR_D.  " Cell Content
          IF MATNR_D IS NOT INITIAL.
            SELECT SINGLE MATNR FROM MARA INTO L_MATNR
                              WHERE MATNR = MATNR_D
                              AND MTART = 'HAWA' .

            IF SY-SUBRC <> 0 .
              COL-FIELDNAME = LS_GOOD-FIELDNAME .
              ROW-ROW_ID = LS_GOOD-ROW_ID .
              MOVE TEXT-004 TO L_ERROR.

              CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
                EXPORTING
                  I_ROW_ID    = LS_GOOD-ROW_ID  " Row ID
*                 I_TABIX     =     " Row Index
                  I_FIELDNAME = 'MAKTX'  " Field Name
                  I_VALUE     = ' '. " Value

            ELSE .
              CLEAR L_MAKTX .

              SELECT SINGLE MAKTX FROM MAKT INTO L_MAKTX WHERE SPRAS = SY-LANGU AND MATNR = L_MATNR.
              IF SY-SUBRC = 0.
                CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
                  EXPORTING
                    I_ROW_ID    = LS_GOOD-ROW_ID
                    I_FIELDNAME = 'MAKTX'
                    I_VALUE     = L_MAKTX.
              ENDIF.

              SELECT SINGLE MEINS FROM MARA INTO L_MEINS WHERE MATNR = L_MATNR.
              IF SY-SUBRC = 0.
                CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
                  EXPORTING
                    I_ROW_ID    = LS_GOOD-ROW_ID
                    I_FIELDNAME = 'MEINS'
                    I_VALUE     = L_MEINS.
              ENDIF.


            ENDIF.
          ENDIF.

*        WHEN .
*        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD .

ENDCLASS .
**&---------------------------------------------------------------------*
**& Form DATA_CHANGED
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**&      --> ER_DATA_CHANGED
**&---------------------------------------------------------------------*
FORM DATA_CHANGED  USING    P_ER_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL .
*  BREAK-POINT.
*  delete it_item where sl_no is  INITIAL .
*  sort it_item ASCENDING BY sl_no.
  DATA : LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA LS_STYLEROW TYPE LVC_S_STYL .
  DATA LT_STYLETAB TYPE LVC_T_STYL .
  DATA: C_MATKL TYPE T023T-WGBEZ .
  DATA: MATKL TYPE MATKL.
  DATA : IT_TAX TYPE ZTAX_T .
  DATA : WA_TAX TYPE ZTAX_S .
  DATA : C_MATNR   TYPE MATNR,
         C_MENGE   TYPE MENGE_D,
         C_SLNO(4) TYPE I,
         C_MAKTX   TYPE MAKTX,
         C_DISC    TYPE NETPR,
         C_NETPR   TYPE NETPR.
  CLEAR : LS_MOD_CELLS .
  LOOP AT P_ER_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    CASE LS_MOD_CELLS-FIELDNAME.
      WHEN 'MATNR'.
*        BREAK-POINT .
        CALL METHOD P_ER_DATA_CHANGED->GET_CELL_VALUE
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = 'MATNR'
          IMPORTING
            E_VALUE     = C_MATNR.

        CALL METHOD P_ER_DATA_CHANGED->GET_CELL_VALUE
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = 'SL_NO'
          IMPORTING
            E_VALUE     = C_SLNO.

*         BREAK-POINT.
*****************************test*************************
*   IF IT_ITEM IS not INITIAL .
*      REFRESH it_item1 .
*      it_item1[] = it_item .
*      DELETE IT_ITEM1 WHERE MATNR IS INITIAL AND MAKTX IS INITIAL .
*      CLEAR WA_ITEM1.
*      sort it_item1 DESCENDING BY SL_NO .
*      READ TABLE IT_ITEM1 INTO WA_ITEM1 INDEX 1 .
*      IF WA_ITEM1-SL_NO MOD 5 = 0 .
*        WA_ITEM-SL_NO = WA_ITEM1-SL_NO .
*        DO 5 TIMES.
*        WA_ITEM-SL_NO = 10 + WA_ITEM-SL_NO .
*        APPEND  wa_item TO IT_ITEM  .
*
*      ENDDO.
*      ENDIF.
*
**      WA_ITEM-SL_NO = 10 .
**      clear wa_item .
*    ENDIF.
*********************************************************
        IF C_MATNR IS NOT INITIAL.

          READ TABLE IT_MAKT INTO WA_MAKT WITH KEY MATNR = C_MATNR .
          IF SY-SUBRC = 0 .
            WA_ITEM-MATNR = C_MATNR .
            WA_ITEM-MAKTX = WA_MAKT-MAKTX .

            READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = C_MATNR."index es_row_no-row_id .
            IF SY-SUBRC = 0.
              WA_ITEM-MATKL_C = WA_MARA-MATKL .

              CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
                EXPORTING
                  INPUT          = WA_MARA-MEINS
                  LANGUAGE       = SY-LANGU
                IMPORTING
*                 LONG_TEXT      =
                  OUTPUT         = WA_ITEM-MEINS
*                 SHORT_TEXT     =
                EXCEPTIONS
                  UNIT_NOT_FOUND = 1
                  OTHERS         = 2.
              IF SY-SUBRC <> 0.
* Implement suitable error handling here
              ENDIF.
*
*              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*                EXPORTING
*                  INPUT  = WA_MARA-MEINS
*                IMPORTING
*                  OUTPUT = WA_ITEM-MEINS.



*              WA_ITEM-MEINS = WA_MARA-MEINS .
              SELECT SINGLE WGBEZ FROM T023T INTO WA_ITEM-MATKL WHERE MATKL = WA_MARA-MATKL
                                                                      AND SPRAS = SY-LANGU .

*BREAK-POINT.


              CLEAR : WA_EINA , WA_EINE .
*            IF wa_header-lifnr is not INITIAL .
              SELECT SINGLE  INFNR
                             MATNR
                             MATKL
                             LIFNR
                             FROM EINA INTO WA_EINA
                             WHERE MATNR = C_MATNR
                             AND LIFNR = WA_HEADER-LIFNR.
*             else .
**               CALL SCREEN 9000 .
*               SET CURSOR FIELD WA_HEADER-LIFNR .
*               MESSAGE 'Enter vendor number' type 'E' DISPLAY LIKE 'S'.
*               RETURN .
*            ENDIF.

              IF WA_EINA IS NOT INITIAL.
                SELECT SINGLE  INFNR
                               EKORG
                               ESOKZ
                               WERKS
                               PRDAT
                               MWSKZ
                               NETPR
                               FROM EINE INTO WA_EINE
                               WHERE INFNR = WA_EINA-INFNR AND PRDAT GE SY-DATUM .
                IF WA_EINE IS NOT INITIAL.
                  WA_ITEM-NETPR = WA_EINE-NETPR .
                  WA_ITEM-TAX_CODE = WA_EINE-MWSKZ .
                ENDIF.
              ENDIF.

              IF WA_HEADER-LIFNR IS NOT INITIAL.
                SELECT  KAPPL
                        KSCHL
                        LIFNR
                        MATNR
                        KFRST
                        DATBI
                        DATAB
                        KBSTAT
                        KNUMH
                FROM A603 INTO TABLE IT_A603
                WHERE MATNR = C_MATNR AND LIFNR = WA_HEADER-LIFNR AND DATBI GE SY-DATUM .
                IF IT_A603 IS NOT INITIAL .
                  SELECT KNUMH
                        KOPOS
                        KAPPL
                        KSCHL
                        KBETR
                        LOEVM_KO
                   FROM KONP INTO TABLE IT_KONP1
                FOR  ALL ENTRIES IN IT_A603
                WHERE KNUMH = IT_A603-KNUMH .
                ENDIF.


                CLEAR : WA_KONP1 .
                LOOP AT IT_KONP1 INTO WA_KONP1 WHERE LOEVM_KO <> 'X'.
                  CASE WA_KONP1-KSCHL.
                    WHEN 'ZDS1'.
                      WA_ITEM-DISC1 = WA_KONP1-KBETR / 10 .
                    WHEN 'ZDS2'.
                      WA_ITEM-DISC2 = WA_KONP1-KBETR / 10 .
                    WHEN 'ZDS3'.
                      WA_ITEM-DISC3 = WA_KONP1-KBETR / 10 .
*                    WHEN 'ZDS4'.
*                      WA_ITEM-DISC4 = WA_KONP1-KBETR.
                    WHEN 'ZMRP'.
                      WA_ITEM-MRP = WA_KONP1-KBETR .
                  ENDCASE.
                ENDLOOP.
                CLEAR WA_KONP1.
                REFRESH IT_KONP1 .
*            else.

              ENDIF.
              READ TABLE IT_MARC INTO WA_MARC WITH KEY MATNR = C_MATNR .
              IF SY-SUBRC  = 0 .
                WA_ITEM-STEUC = WA_MARC-STEUC .
                BREAK BREDDY .
                CALL METHOD ZCL_GST=>GET_GST_PER
                  EXPORTING
                    I_MATNR = C_MATNR   " Material Number
                    I_LIFNR = WA_LFA1-LIFNR   " Account Number of Vendor or Creditor
                  IMPORTING
                    ET_TAX  = IT_TAX.  " Tax Table type
*                CLEAR LV_% .
*                LOOP AT IT_A792 INTO WA_A792 WHERE STEUC = WA_MARC-STEUC AND DATBI  > SY-DATUM
*                                             AND REGIO = WA_LFA1-REGIO
*                                             AND WKREG = WA_T001W-REGIO.
**                                                                         AND VEN_CLASS = WA_LFA1-VEN_CLASS
**                                                                         AND TAXIM = WA_MARA-TAKLV .
*                  CLEAR WA_KONP .
*                  READ TABLE IT_KONP INTO WA_KONP WITH KEY KNUMH = WA_A792-KNUMH KAPPL = 'TX' LOEVM_KO = ' '.
*                  IF SY-SUBRC = 0.
*                    IF WA_KONP-KSCHL = 'JICG' OR WA_KONP-KSCHL = 'JIIG' OR WA_KONP-KSCHL = 'JISG'.
*                      LV_% = WA_KONP-KBETR / 10 .
*                      WA_ITEM-GST% = WA_ITEM-GST% + LV_% .
*                    ENDIF.
*                  ENDIF.
*
*                ENDLOOP.
*              ELSE .
*                CLEAR : WA_ITEM-STEUC , WA_ITEM-GST% .
                IF  IT_TAX IS NOT INITIAL .
                  LOOP AT  IT_TAX INTO WA_TAX.
                    LV_% = WA_TAX-TAX / 10 .
                    WA_ITEM-GST% = WA_ITEM-GST% + LV_% .
                  ENDLOOP.

                ENDIF.
              ENDIF.
              DATA : LV_DISVAL   TYPE NETPR,
                     LV_DISVAL1  TYPE NETPR,
                     LV_GSTONMRP TYPE NETPR,
                     LV_DISVAL2  TYPE NETPR.
*             CLEAR WA_ITEM-NETPR.
              IF WA_ITEM-NETPR IS INITIAL .

                LV_DISVAL = WA_ITEM-MRP + ( WA_ITEM-MRP * WA_ITEM-DISC1 / 100 ) .
                LV_DISVAL1 = LV_DISVAL  + ( LV_DISVAL * WA_ITEM-DISC2 / 100 ) .
                LV_DISVAL2 = LV_DISVAL1  + ( LV_DISVAL1 * WA_ITEM-DISC3 / 100 ) .
                LV_GSTONMRP = LV_DISVAL2 - ( LV_DISVAL2 / ( 100 + WA_ITEM-GST% ) * WA_ITEM-GST% ) .
                WA_ITEM-NETPR = LV_GSTONMRP.

              ENDIF.
*                  IF wa_item-disc4 is not INITIAL .
*                 WA_ITEM-NETPR = LV_DISVAL2 - WA_ITEM-DISC4 .
*              ENDIF.\
*              BREAK-POINT.


              CLEAR IT_WHG01 .
              CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
                EXPORTING
                  MATKL       = WA_ITEM-MATKL_C
                  SPRAS       = SY-LANGU
                TABLES
                  O_WGH01     = IT_WHG01
                EXCEPTIONS
                  NO_BASIS_MG = 1
                  NO_MG_HIER  = 2
                  OTHERS      = 3.
              IF SY-SUBRC <> 0.
* Implement suitable error handling here
              ENDIF.
              READ TABLE IT_WHG01 INTO WA_WHG01 INDEX 1 .
              IF SY-SUBRC = 0.
                WA_ITEM-PARENT_CODE = WA_WHG01-WWGHB .
              ENDIF.
*************************
              REFRESH IT_ITEM1 .
              IT_ITEM1[] = IT_ITEM[] .
              DELETE  IT_ITEM1 WHERE MATNR IS INITIAL  OR MAKTX IS INITIAL ."COMPARING MATNR .
              SORT IT_ITEM1 DESCENDING BY SL_NO .
              CLEAR WA_ITEM1 .
              READ TABLE IT_ITEM1 INTO WA_ITEM1 WITH KEY MATNR = C_MATNR ."WITH KEY MATNR = C_MATNR .
*              DELETE it_item1 where matnr <> c_matnr .
              IF WA_ITEM1 IS NOT INITIAL.
*              data : i(2) type i .
*              DESCRIBE TABLE it_item1 LINES i .
*              if i > 1 .
                MESSAGE 'Material is already exist..' TYPE 'I' DISPLAY LIKE 'E'.
*                  RETURN .
              ELSE .

                CALL METHOD P_ER_DATA_CHANGED->GET_CELL_VALUE
                  EXPORTING
                    I_ROW_ID    = LS_MOD_CELLS-ROW_ID
                    I_FIELDNAME = 'MAKTX'
                  IMPORTING
                    E_VALUE     = C_MAKTX.
                IF C_SLNO IS NOT INITIAL AND C_MAKTX IS NOT INITIAL .
                  MODIFY IT_ITEM FROM WA_ITEM TRANSPORTING MATNR
                                                         PARENT_CODE
                                                         GST%
                                                         NETPR
                                                         DISC1
                                                         DISC2
                                                         DISC3
                                                         DISC4
                                                         GST
                                                         MAKTX
                                                         MATKL
                                                         MEINS
                                                         MENGE
                                                         MRP
                                                         STEUC
                                                         WHERE SL_NO = C_SLNO .

                  CLEAR C_SLNO .
                ELSE.
*                CLEAR C_SLNO .
                  REFRESH IT_ITEM1 .
                  IT_ITEM1[] = IT_ITEM[] .
                  DELETE  IT_ITEM1 WHERE MATNR IS INITIAL  OR MAKTX IS INITIAL ."COMPARING MATNR .
                  SORT IT_ITEM1 DESCENDING BY SL_NO .
                  CLEAR WA_ITEM1 .
                  READ TABLE IT_ITEM1 INTO WA_ITEM1 INDEX 1."WITH KEY MATNR = C_MATNR .
                  IF WA_ITEM1 IS INITIAL.
                    MODIFY IT_ITEM FROM WA_ITEM TRANSPORTING MATNR
                                                          PARENT_CODE
                                                          GST%
                                                          NETPR
                                                          DISC1
                                                          DISC2
                                                          DISC3
                                                          DISC4
                                                          GST
                                                          MAKTX
                                                          MATKL
                                                          MEINS
                                                          MENGE
                                                          MRP
                                                          STEUC
                                                          WHERE SL_NO = 10.
                  ELSEIF WA_ITEM1-SL_NO > C_SLNO .
*                IF WA_ITEM1-SL_NO IS NOT INITIAL.
*                  SORT IT_ITEM1 DESCENDING BY SL_NO .
*                SORT IT_ITEM ASCENDING BY SL_NO .
*                  READ TABLE IT_ITEM1 INTO WA_ITEM1 INDEX 1.
*                  C_SLNO = WA_ITEM1-SL_NO + 10 .
                    MODIFY IT_ITEM FROM WA_ITEM TRANSPORTING MATNR
                                                         PARENT_CODE
                                                         GST%
                                                         NETPR
                                                         DISC1
                                                         DISC2
                                                         DISC3
                                                         DISC4
                                                         GST
                                                         MAKTX
                                                         MATKL
                                                         MEINS
                                                         MENGE
                                                         MRP
                                                         STEUC
                                                         WHERE SL_NO = C_SLNO .
                  ELSE.
                    C_SLNO = WA_ITEM1-SL_NO + 10 .
                    MODIFY IT_ITEM FROM WA_ITEM TRANSPORTING MATNR
                                                         PARENT_CODE
                                                         GST%
                                                         NETPR
                                                         DISC1
                                                         DISC2
                                                         DISC3
                                                         DISC4
                                                         GST
                                                         MAKTX
                                                         MATKL
                                                         MEINS
                                                         MENGE
                                                         MRP
                                                         STEUC
                                                         WHERE SL_NO = C_SLNO .
                  ENDIF.
*                  MODIFY IT_ITEM FROM WA_ITEM INDEX LS_MOD_CELLS-ROW_ID  .
******************************
*              BREAK-POINT.
*              CALL METHOD P_ER_DATA_CHANGED->GET_CELL_VALUE
*                EXPORTING
*                  I_ROW_ID    = LS_MOD_CELLS-ROW_ID
*                  I_FIELDNAME = 'SL_NO'
*                IMPORTING
*                  E_VALUE     = C_SLNO.
*              IF C_SLNO IS NOT INITIAL.
*                READ TABLE IT_ITEM INTO WA_ITEM1 WITH KEY SL_NO = C_SLNO .
**              CLEAR WA_ITEM .
*                WA_ITEM-SL_NO = C_SLNO .
*                MODIFY IT_ITEM FROM WA_ITEM TRANSPORTING MATNR
*                                                         PARENT_CODE
*                                                         GST%
*                                                         NETPR
*                                                         DISC1
*                                                         DISC2
*                                                         DISC3
*                                                         DISC4
*                                                         GST
*                                                         MAKTX
*                                                         MATKL
*                                                         MEINS
*                                                         MENGE
*                                                         WHERE SL_NO = C_SLNO .
                  "INDEX LS_MOD_CELLS-ROW_ID  .

*              ELSE .
*                IT_ITEM1[] = IT_ITEM[] .
*                SORT IT_ITEM1 DESCENDING BY SL_NO .
*                DELETE ADJACENT DUPLICATES FROM IT_ITEM1 COMPARING MATNR .
*                CLEAR WA_ITEM1 .
*                READ TABLE IT_ITEM1 INTO WA_ITEM1 WITH KEY MATNR = C_MATNR .
*                IF WA_ITEM1-SL_NO IS INITIAL.
*                  SORT IT_ITEM1 DESCENDING BY SL_NO .
**                SORT IT_ITEM ASCENDING BY SL_NO .
*                  READ TABLE IT_ITEM1 INTO WA_ITEM1 INDEX 1.
*                  WA_ITEM-SL_NO = WA_ITEM1-SL_NO + 10 .
*                  MODIFY IT_ITEM FROM WA_ITEM INDEX LS_MOD_CELLS-ROW_ID  .
*                ELSE .
*                  MESSAGE 'Material is already exist..' TYPE 'I' DISPLAY LIKE 'E'.
*                  RETURN .
                ENDIF.
              ENDIF.



            ENDIF.
*           sort it_item ASCENDING by sl_no .
          ELSE.
            IF SY-SUBRC <> 0 .
              CALL METHOD P_ER_DATA_CHANGED->ADD_PROTOCOL_ENTRY
                EXPORTING
                  I_MSGID     = 'ZFI'
                  I_MSGNO     = '999'
                  I_MSGTY     = 'E'
                  I_MSGV1     = ''
                  I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
                  I_ROW_ID    = LS_MOD_CELLS-ROW_ID.
              EXIT.
            ENDIF.
            CLEAR  WA_ITEM .
*            MODIFY IT_ITEM FROM WA_ITEM INDEX LS_MOD_CELLS-ROW_ID  .
*put ur condition according to variable here, if the condition is not satisfied, then throw a message like this.
          ENDIF.
        ELSE.
*          clear wa_item .
*          wa_item-sl_no = c_slno .
          MODIFY IT_ITEM FROM WA_ITEM TRANSPORTING MATNR
                                                       PARENT_CODE
                                                       GST%
                                                       NETPR
                                                       DISC1
                                                       DISC2
                                                       DISC3
                                                       DISC4
                                                       GST
                                                       MAKTX
                                                       MATKL
                                                       MEINS
                                                       MENGE
                                                       AMOUNT
                                                       STEUC
                                                       MRP
                                                       WHERE SL_NO = C_SLNO .
        ENDIF.
*        E  NDIF.
      WHEN 'MENGE'.
        CALL METHOD P_ER_DATA_CHANGED->GET_CELL_VALUE
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = 'MENGE'
          IMPORTING
            E_VALUE     = C_MENGE.

*        C_MENGE = C_MENGE * 100 .

        CALL METHOD P_ER_DATA_CHANGED->GET_CELL_VALUE
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = 'MATNR'
          IMPORTING
            E_VALUE     = C_MATNR.

        READ TABLE IT_ITEM INTO WA_ITEM WITH KEY MATNR = C_MATNR .
        IF C_MENGE IS NOT INITIAL.
          WA_ITEM-MENGE = C_MENGE .
*          IF wa_item-disc4 is not INITIAL .
          WA_ITEM-AMOUNT = ( WA_ITEM-NETPR * C_MENGE ) - WA_ITEM-DISC4.
*          ENDIF.

        ENDIF.
        IF WA_ITEM-NETPR IS NOT INITIAL AND WA_ITEM-MENGE IS NOT INITIAL .
          WA_ITEM-GST = ( WA_ITEM-NETPR * WA_ITEM-MENGE ) * WA_ITEM-GST% / 100 .
          WA_ITEM-TOTAL = ( ( WA_ITEM-NETPR * WA_ITEM-MENGE ) + WA_ITEM-GST ) - WA_ITEM-DISC4.
        ENDIF.
        MODIFY IT_ITEM FROM WA_ITEM INDEX LS_MOD_CELLS-ROW_ID  .


      WHEN 'DISC4'.
        CALL METHOD P_ER_DATA_CHANGED->GET_CELL_VALUE
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = 'DISC4'
          IMPORTING
            E_VALUE     = C_DISC.

        CALL METHOD P_ER_DATA_CHANGED->GET_CELL_VALUE
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = 'AMOUNT'
          IMPORTING
            E_VALUE     = C_NETPR.

        CALL METHOD P_ER_DATA_CHANGED->GET_CELL_VALUE
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = 'SL_NO'
          IMPORTING
            E_VALUE     = C_SLNO.
        READ TABLE IT_ITEM INTO WA_ITEM WITH KEY SL_NO = C_SLNO .
        IF C_NETPR IS NOT INITIAL .
          WA_ITEM-AMOUNT = C_NETPR - C_DISC.
          WA_ITEM-DISC4 = C_DISC .
          WA_ITEM-TOTAL = WA_ITEM-TOTAL - C_DISC .
          MODIFY IT_ITEM FROM WA_ITEM TRANSPORTING AMOUNT
                                                   DISC4
                                                   TOTAL WHERE SL_NO = C_SLNO ."INDEX LS_MOD_CELLS-ROW_ID  .
        ENDIF.

      WHEN 'MATKL'.
        CLEAR WA_ITEM .
        CALL METHOD P_ER_DATA_CHANGED->GET_CELL_VALUE
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = 'MATKL'
          IMPORTING
            E_VALUE     = C_MATKL.

        READ TABLE IT_T023T INTO WA_T023T WITH KEY WGBEZ = C_MATKL.
        IF SY-SUBRC = 0.
          MATKL = WA_T023T-MATKL .

          CLEAR IT_WHG01 .
          CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
            EXPORTING
              MATKL       = MATKL
              SPRAS       = SY-LANGU
            TABLES
              O_WGH01     = IT_WHG01
            EXCEPTIONS
              NO_BASIS_MG = 1
              NO_MG_HIER  = 2
              OTHERS      = 3.
          IF SY-SUBRC <> 0.
* Implement suitable error handling here
          ENDIF.
          READ TABLE IT_WHG01 INTO WA_WHG01 INDEX 1 .
          IF SY-SUBRC = 0.
            WA_ITEM-PARENT_CODE = WA_WHG01-WWGHB .
          ENDIF.
*              BREAK-POINT.
          CALL METHOD P_ER_DATA_CHANGED->GET_CELL_VALUE
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = 'SL_NO'
            IMPORTING
              E_VALUE     = C_SLNO.
          IF C_SLNO IS NOT INITIAL.
            READ TABLE IT_ITEM INTO WA_ITEM1 WITH KEY SL_NO = C_SLNO .
*              CLEAR WA_ITEM .
            WA_ITEM-SL_NO = C_SLNO .
            MODIFY IT_ITEM FROM WA_ITEM TRANSPORTING MATNR
                                                     PARENT_CODE
                                                     GST%
                                                     NETPR
                                                     DISC1
                                                     DISC2
                                                     DISC3
                                                     DISC4
                                                     GST
                                                     MAKTX
                                                     MATKL
                                                     MEINS
                                                     MENGE
                                                     WHERE SL_NO = C_SLNO .
            ."INDEX LS_MOD_CELLS-ROW_ID  .

          ELSE .
            IT_ITEM1[] = IT_ITEM[] .
            SORT IT_ITEM1 DESCENDING BY SL_NO .
            CLEAR WA_ITEM1 .
            READ TABLE IT_ITEM1 INTO WA_ITEM1 WITH KEY MATKL = MATKL.
            IF WA_ITEM1-SL_NO IS INITIAL.
              SORT IT_ITEM1 DESCENDING BY SL_NO .
*                SORT IT_ITEM ASCENDING BY SL_NO .
              READ TABLE IT_ITEM1 INTO WA_ITEM1 INDEX 1.
              WA_ITEM-SL_NO = WA_ITEM1-SL_NO + 10 .
*              APPEND wa_item to it_item.
              MODIFY IT_ITEM FROM WA_ITEM  INDEX LS_MOD_CELLS-ROW_ID  .

            ENDIF.
          ENDIF.
        ELSE .
          IF SY-SUBRC <> 0 .
            CALL METHOD P_ER_DATA_CHANGED->ADD_PROTOCOL_ENTRY
              EXPORTING
                I_MSGID     = 'ZFI'
                I_MSGNO     = '999'
                I_MSGTY     = 'E'
                I_MSGV1     = 'Incorrect material group'
                I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
                I_ROW_ID    = LS_MOD_CELLS-ROW_ID.
            EXIT.
          ENDIF.
          CLEAR  WA_ITEM .
        ENDIF.
        CLEAR WA_ITEM .
    ENDCASE .
  ENDLOOP.


  CLEAR : WA_ITEM1 , WA_ITEM , LS_MOD_CELLS , IT_A603 , IT_KONP1 .
*  BREAK-POINT.
  IF GRID IS BOUND.
    CALL METHOD GRID->REFRESH_TABLE_DISPLAY.
  ENDIF.
ENDFORM.
