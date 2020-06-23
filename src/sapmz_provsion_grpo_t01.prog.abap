*&---------------------------------------------------------------------*
*& Include          SAPMZ_FV_PROCESS_T01
*&---------------------------------------------------------------------*

*** Types
TYPES :
*** PO Header Details
  BEGIN OF TY_HDR,
    EBELN       TYPE EBELN,
    LIFNR       TYPE LIFNR,
    NAME1       TYPE NAME1_GP,
    LGORT       TYPE LGORT_D,
    WERKS       TYPE WERKS_D,
    MBLNR_541   TYPE MBLNR,
    MBLNR_101   TYPE MBLNR,
    MBLNR_542   TYPE MBLNR,
    MBLNR_201   TYPE MBLNR,
    COND_REC(1),
  END OF TY_HDR,

*** PO item Details
  BEGIN OF TY_ITEM,
    EBELN   TYPE EBELN,
    EBELP   TYPE EBELP,
    MATNR   TYPE MATNR,
    MAKTX   TYPE MAKTX,
    pur_amt TYPE BPREI,
    MENGE   TYPE MENGE_D,
    MEINS   TYPE MEINS,
    NETPR_S TYPE BPREI,
    MENGE_R TYPE int4,
*    MENGE_R TYPE MENGE_D,
  END OF TY_ITEM,

*** MSEG Details
  BEGIN OF TY_MSEG,
    EBELN   TYPE EBELN,
    EBELP   TYPE EBELP,
    MATNR   TYPE MATNR,
    TXZ01   TYPE TXZ01,
    MENGE   TYPE MENGE_D,
    MEINS   TYPE MEINS,
    CHARG   TYPE CHARG_D,
    LIFNR   TYPE LIFNR,
    WERKS   TYPE WERKS_D,
    M_MATNR TYPE MATNR,
    M_MAKTX TYPE MAKTX,
    M_MENGE TYPE MENGE_D,
    M_MEINS TYPE MEINS,
    KBETR   TYPE KBETR,
  END OF TY_MSEG.

*** Table Declerations
DATA :
  GT_ITEM     TYPE STANDARD TABLE OF TY_ITEM,
  GT_MSEG     TYPE STANDARD TABLE OF TY_MSEG,
  GS_ITEM     TYPE TY_ITEM,
  GS_HDR      TYPE TY_HDR,
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
  OK_9001      TYPE SY-UCOMM,
  GV_BSART     TYPE ESART,
  GV_EBELN     TYPE EBELN,
  GV_SUBRC     TYPE SY-SUBRC,
  GV_MBLNR_101 TYPE MBLNR,
  GV_MBLNR_541 TYPE MBLNR,
  gv_diff(1).

*** Field Symbols
FIELD-SYMBOLS :
  <GS_ITEM> TYPE TY_ITEM.

CONSTANTS:
  C_BACK         TYPE SY-UCOMM VALUE 'BACK',
  C_CANCEL       TYPE SY-UCOMM VALUE 'CANCEL',
  C_EXIT         TYPE SY-UCOMM VALUE 'EXIT',
  C_SAVE         TYPE SY-UCOMM VALUE 'SAVE',
  C_ENTER        TYPE SY-UCOMM VALUE 'ENTER',
  C_X(1)         VALUE 'X',
  C_E(1)         VALUE 'E',
  C_S(1)         VALUE 'S',
  C_MVT_IND_B(1) VALUE 'B',
  C_MVT_01(2)    VALUE '01',
  C_MVT_04(2)    VALUE '04',
  C_MVT_03(2)    VALUE '03',
  C_MVT_06(2)    VALUE '06',
  C_101(3)       VALUE '101',
  C_541(3)       VALUE '541',
  C_542(3)       VALUE '542',
  C_543(3)       VALUE '543',
  C_201(3)       VALUE '201',
  C_ZKP0(4)      VALUE 'ZKP0'.

DATA :
  BDCDATA TYPE BDCDATA    OCCURS 0 WITH HEADER LINE,
  MESSTAB TYPE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.

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
    DATA : IS_STABLE   TYPE LVC_S_STBL, LV_LINES TYPE INT2,
           LV_FIELD    TYPE LVC_FNAME,
           LV_ERROR(1).

*** Event is triggered when data is changed in the output
    IS_STABLE = 'XX'.
*** Refreshing Data with Cusrsor Hold
    IF GR_GRID IS BOUND.
      CALL METHOD GR_GRID->REFRESH_TABLE_DISPLAY
        EXPORTING
          IS_STABLE = IS_STABLE        " With Stable Rows/Columns
        EXCEPTIONS
          FINISHED  = 1                " Display was Ended (by Export)
          OTHERS    = 2.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.
BREAK samburi.
    LOOP AT ER_DATA_CHANGED->MT_MOD_CELLS ASSIGNING FIELD-SYMBOL(<X_MOD_CELLS>).
      READ TABLE GT_ITEM ASSIGNING <GS_ITEM> INDEX <X_MOD_CELLS>-ROW_ID.
      CHECK SY-SUBRC = 0.
***     Material Validation
      CLEAR : LV_FIELD.
      CASE <X_MOD_CELLS>-FIELDNAME.
        WHEN 'MENGE_R'.
          IF <GS_ITEM>-menge < <X_MOD_CELLS>-value.
            LV_FIELD = 'MENGE_R'.
            CALL METHOD ER_DATA_CHANGED->ADD_PROTOCOL_ENTRY
              EXPORTING
                I_MSGID     = 'ZMSG_CLS'
                I_MSGTY     = 'E'
                I_MSGNO     = '090'
                I_FIELDNAME = LV_FIELD
                I_ROW_ID    = <X_MOD_CELLS>-ROW_ID.
            CLEAR : <X_MOD_CELLS>-VALUE.
            LV_ERROR = 'X'.
            EXIT.
          ELSE.
            <GS_ITEM>-menge_r = <X_MOD_CELLS>-VALUE.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
