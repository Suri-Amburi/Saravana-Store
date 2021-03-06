*&---------------------------------------------------------------------*
*& Include          SAPMZ_GATEIN_LP_T01
*&---------------------------------------------------------------------*

DATA :
  P_QR_CODE        TYPE ZQR_CODE,
  GS_INWD_HDR      TYPE ZINW_T_HDR,
  GS_STATUS        TYPE ZINW_T_STATUS,
  OK_9000          TYPE SY-UCOMM,
  OK_9001          TYPE SY-UCOMM,
  CONTAINER        TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
  GRID             TYPE REF TO CL_GUI_ALV_GRID,
  MYCONTAINER      TYPE SCRFNAME VALUE 'MYCONTAINER',
  GT_EXCLUDE       TYPE UI_FUNCTIONS,
  GS_LAYO          TYPE LVC_S_LAYO,
  GT_FIELDCAT      TYPE LVC_T_FCAT,
  GV_SUBRC         TYPE SY-SUBRC,
  GV_CUR_FIELD(10),
  GV_CUR_VALUE(10),
  GV_EBELN         TYPE EBELN,
  GV_MOD(1),
  GV_BSART         TYPE BSART.

* Event Class
CLASS EVENT_CLASS DEFINITION DEFERRED.
DATA: GR_EVENT TYPE REF TO EVENT_CLASS.

** Event Handeler Class
CLASS EVENT_CLASS DEFINITION.
  PUBLIC SECTION.
    METHODS: HANDLE_DATA_CHANGED
                FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED.
ENDCLASS.

* Class Implemntation
CLASS EVENT_CLASS IMPLEMENTATION.
  METHOD HANDLE_DATA_CHANGED.
    DATA : ERROR_IN_DATA(1).
    BREAK SAMBURI.

*** Refreshing Table Data
    IF GRID IS BOUND.
      CALL METHOD GRID->REFRESH_TABLE_DISPLAY.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CONSTANTS :
  C_X(1)       VALUE 'X',
  C_SAVE(4)    VALUE 'SAVE',
  C_BACK(4)    VALUE 'BACK',
  C_EXIT(4)    VALUE 'EXIT',
  C_CANCEL(6)  VALUE 'CANCEL',
  C_EXECUTE(3) VALUE 'EXE',
  C_RB(3)      VALUE 'RB',
  C_DOC        TYPE BSART  VALUE 'NB',
  C_01(2)      VALUE '01',
  C_QR_CODE(7) VALUE 'QR_CODE',
  C_QR02(4)    VALUE 'QR02',
  C_02(4)      VALUE '02',
  C_04(4)      VALUE '04',
  C_D(1)       VALUE 'D',
  C_9(1)       VALUE '9',    " Service
  C_K(1)       VALUE 'K',    " Cost Center
  C_ZTAT(4)    VALUE 'ZTAT',
  C_ZLOP(4)    VALUE 'ZLOP'.

TYPES :
  BEGIN OF TY_FINAL,
    QR_CODE   TYPE ZINW_T_HDR-QR_CODE,
    INWD_DOC  TYPE ZINW_T_HDR-INWD_DOC,
    EBELN     TYPE ZINW_T_HDR-EBELN,
    LIFNR     TYPE ZINW_T_HDR-LIFNR,
    NAME1     TYPE ZINW_T_HDR-NAME1,
    PUR_TOTAL TYPE ZINW_T_HDR-PUR_TOTAL,
  END OF TY_FINAL,

  BEGIN OF TY_PRICE,
    LIFNR      TYPE A729-LIFNR,
    SRVPOS     TYPE A729-SRVPOS,
    USERF1_TXT TYPE A729-USERF1_TXT,
    KNUMH      TYPE A729-KNUMH,
    KBETR      TYPE KONP-KBETR,
  END OF TY_PRICE.

DATA :
  GT_HDR TYPE STANDARD TABLE OF TY_FINAL,
  GS_HDR TYPE TY_FINAL.
