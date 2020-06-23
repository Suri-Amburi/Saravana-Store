*&---------------------------------------------------------------------*
*& Include          SAPMZ_GRPO_VESSELS_T01
*&---------------------------------------------------------------------*

*** Types
TYPES :
*** PO item Details
  BEGIN OF TY_ITEM,
    QR_CODE TYPE ZQR_CODE,
    EBELN   TYPE EBELN,
    EBELP   TYPE EBELP,
    MATNR   TYPE MATNR,
    MAKTX   TYPE MAKTX,
    MENGE_S TYPE MENGE_D,
    BPRME   TYPE MEINS,
    MENGE_T TYPE ZMENGE_P,
    LMEIN   TYPE LAGME,
    LGORT   TYPE LGORT_D,
    WERKS   TYPE WERKS_D,
  END OF TY_ITEM.

*** Table Declerations
DATA :
  GT_ITEM     TYPE STANDARD TABLE OF TY_ITEM,
  GS_HEADER   TYPE ZINW_T_HDR,
  GT_EXCLUDE  TYPE UI_FUNCTIONS,
  GS_LAYO     TYPE LVC_S_LAYO,
  GT_FIELDCAT TYPE LVC_T_FCAT.

*** Object References
DATA :
  GR_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
  GR_GRID      TYPE REF TO CL_GUI_ALV_GRID.

*** Event Class
CLASS EVENT_CLASS DEFINITION DEFERRED.
DATA :
  GR_EVENT TYPE REF TO EVENT_CLASS.

*** Data Declerations
DATA :
  OK_9001  TYPE SY-UCOMM,
  GV_BSART TYPE ESART.

*** Field Symbols
FIELD-SYMBOLS :
  <GS_ITEM> TYPE TY_ITEM.

CONSTANTS:
  C_BACK         TYPE SY-UCOMM VALUE 'BACK',
  C_CANCEL       TYPE SY-UCOMM VALUE 'CANCEL',
  C_EXIT         TYPE SY-UCOMM VALUE 'EXIT',
  C_POST         TYPE SY-UCOMM VALUE 'POST',
  C_X(1)         VALUE 'X',
  C_E(1)         VALUE 'E',
  C_S(1)         VALUE 'S',
  C_MVT_IND_B(1) VALUE 'B',
  C_MVT_01(2)    VALUE '01',
  C_02(2)        VALUE '02',
  C_ZVOS(4)      VALUE 'ZVOS',
  C_ZVLO(4)      VALUE 'ZVLO',
  C_LABEL(5)     VALUE 'LABEL',
  C_GRPO_S(4)    VALUE 'GR_S',
  C_GRPO_P(4)    VALUE 'GR_P',
  C_01(2)        VALUE '01',
  C_03(2)        VALUE '03',
  C_04(2)        VALUE '04',
  C_QR03(4)      VALUE 'QR03',
  C_QR04(4)      VALUE 'QR04',
  C_QR_CODE(7)   VALUE 'QR_CODE',
  C_ZTAT(4)      VALUE 'ZTAT',
  C_SOE(4)       VALUE 'SOE',
  C_SE01(4)      VALUE 'SE01',
  C_107(4)       VALUE '107',
  C_101(4)       VALUE '101',
  C_ZKP0(4)      VALUE 'ZKP0'.


*** Event Handeler Class
CLASS EVENT_CLASS DEFINITION.
  PUBLIC SECTION.
    METHODS: HANDLE_DATA_CHANGED
                FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED.
ENDCLASS.

*** Class Implemntation
CLASS EVENT_CLASS IMPLEMENTATION.
  METHOD HANDLE_DATA_CHANGED.
*    DATA : ERROR_IN_DATA(1).
*    LOOP AT ER_DATA_CHANGED->MT_MOD_CELLS ASSIGNING FIELD-SYMBOL(<X_MOD_CELLS>).
*      READ TABLE GT_ITEM ASSIGNING <GS_ITEM> INDEX <X_MOD_CELLS>-ROW_ID.
*      IF SY-SUBRC = 0.
**        IF <GS_ITEM>-MENGE_S < <X_MOD_CELLS>-VALUE.
**          CALL METHOD ER_DATA_CHANGED->ADD_PROTOCOL_ENTRY
**            EXPORTING
**              I_MSGID     = 'ZMSG_CLS'
**              I_MSGTY     = 'E'
**              I_MSGNO     = '004'
**              I_FIELDNAME = <X_MOD_CELLS>-FIELDNAME
**              I_ROW_ID    = <X_MOD_CELLS>-ROW_ID.
**          ERROR_IN_DATA = 'X'.
**          EXIT.
**        ENDIF.
*      ENDIF.
*    ENDLOOP.
**** Refreshing Table Data
*    IF GR_GRID IS BOUND.
*      DATA: IS_STABLE TYPE LVC_S_STBL, LV_LINES TYPE INT2.
*      IS_STABLE = 'XX'.
*      IF GR_GRID IS BOUND.
*        CALL METHOD GR_GRID->REFRESH_TABLE_DISPLAY
*          EXPORTING
*            IS_STABLE = IS_STABLE               " With Stable Rows/Columns
*          EXCEPTIONS
*            FINISHED  = 1                       " Display was Ended (by Export)
*            OTHERS    = 2.
*        IF SY-SUBRC <> 0.
*          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
**** Display Errors
*    CHECK ERROR_IN_DATA IS NOT INITIAL .
*    CALL METHOD ER_DATA_CHANGED->DISPLAY_PROTOCOL( ).
  ENDMETHOD.
ENDCLASS.
