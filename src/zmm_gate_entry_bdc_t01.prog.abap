*&---------------------------------------------------------------------*
*& Include          ZMM_GATE_ENTRY_BDC_T01
*&---------------------------------------------------------------------*
TYPES :
     BEGIN OF TY_FILE,
       LR_NO(20),
       TRANSPORTER_CODE(10),
       SMALL_BUNDLES(10),
       BIG_BUNDLES(10),
       MSGTYP(1),
       MSG(255),
       PO_NUMBER(10),
       END OF TY_FILE.

       DATA:
  GT_FILE     TYPE  STANDARD TABLE OF TY_FILE,
  GG_FILE TYPE TY_FILE,
  T_FILE      TYPE  STANDARD TABLE OF TY_FILE,
  IT_FILE TYPE TABLE OF  TY_FILE,
  WA_FILE TYPE TY_FILE,
  FNAME       TYPE LOCALFILE,
  ENAME       TYPE CHAR4,
*  GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
  GT_BDCDATA  TYPE TABLE OF BDCDATA,
  CTUMODE     LIKE CTU_PARAMS-DISMODE VALUE 'N',
  CUPDATE     LIKE CTU_PARAMS-UPDMODE VALUE 'S'.





*       DATA :

*CONSTANTS :
*  C_X(1) VALUE 'X',
*  C_E(1) VALUE 'E'.

DATA :
  P_LR_NO          TYPE ZLR,
  P_TRNS           TYPE ZTRANS,
  P_QR_CODE        TYPE ZQR_CODE,
  GS_INWD_HDR      TYPE ZINW_T_HDR,
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
  GV_BSART         TYPE BSART,
  R_LP(1),
  R_OP(1).
*  MSGTYP(1),
*  MSG(255).


CONSTANTS :
  C_X(1)       VALUE 'X',
  C_SAVE(4)    VALUE 'SAVE',
  C_BACK(4)    VALUE 'BACK',
  C_EXIT(4)    VALUE 'EXIT',
  C_CANCEL(6)  VALUE 'CANCEL',
  C_EXECUTE(3) VALUE 'EXE',
  C_RB(3)      VALUE 'RB',
  C_DOC        TYPE BSART  VALUE 'ZTSR',
  C_01(2)      VALUE '01',
  C_QR_CODE(7) VALUE 'QR_CODE',
  C_QR02(4)    VALUE 'QR02',
  C_02(4)      VALUE '02',
  C_D(1)       VALUE 'D',
  C_9(1)       VALUE '9',    " Service
  C_K(1)       VALUE 'K',    " Cost Center
  C_ZTAT(4)    VALUE 'ZTAT',
  C_ZLOP(4)    VALUE 'ZLOP'.

TYPES :
  BEGIN OF TY_FINAL,
    QR_CODE      TYPE ZINW_T_HDR-QR_CODE,
    INWD_DOC     TYPE ZINW_T_HDR-INWD_DOC,
    EBELN        TYPE ZINW_T_HDR-EBELN,
    LIFNR        TYPE ZINW_T_HDR-LIFNR,
    NAME1        TYPE ZINW_T_HDR-NAME1,
    STATUS       TYPE ZINW_T_HDR-STATUS,
    BILL_NUM     TYPE ZINW_T_HDR-BILL_NUM,
    TRNS         TYPE ZINW_T_HDR-TRNS,
    LR_NO        TYPE ZINW_T_HDR-LR_NO,
    ACT_NO_BUD   TYPE ZINW_T_HDR-ACT_NO_BUD,
*    RCV_NO_BUD   TYPE ZINW_T_HDR-RCV_NO_BUD,
    BK_STATION   TYPE ZINW_T_HDR-BK_STATION,
    SMALL_BUNDLE TYPE ZINW_T_HDR-SMALL_BUNDLE,
    BIG_BUNDLE   TYPE ZINW_T_HDR-BIG_BUNDLE,
    FRT_NO       TYPE ZINW_T_HDR-FRT_NO,
    FRT_AMT      TYPE ZINW_T_HDR-FRT_AMT,

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
   GL_HDR TYPE  TY_FINAL,
  GS_HDR TYPE TY_FINAL.

DATA : GT_PRICE TYPE STANDARD TABLE OF TY_PRICE.


  TYPES:BEGIN OF GTY_DISPLAY,
        LR_NO            TYPE ZLR,
        TRANSPORTER_CODE TYPE ZTRANS,
        SMALL_BUNDLES    TYPE CHAR10,
        BIG_BUNDLES      TYPE CHAR10,
        PO_NUM           TYPE CHAR10,
        TYPE             TYPE BAPI_MTYPE,
        MESSAGE          TYPE BAPIRET2-MESSAGE,
        PO_NUMBER        TYPE CHAR10,
      END OF GTY_DISPLAY,
      GTY_T_DISPLAY TYPE STANDARD TABLE OF GTY_DISPLAY.

DATA: GWA_DISPLAY TYPE GTY_DISPLAY,
      GIT_DISPLAY TYPE GTY_T_DISPLAY.


DATA:
  HEADER               LIKE BAPIMEPOHEADER,
  HEADERX              LIKE BAPIMEPOHEADERX,
  ITEM                 TYPE TABLE OF BAPIMEPOITEM  WITH HEADER LINE,
  POSCHEDULE           TYPE TABLE OF BAPIMEPOSCHEDULE WITH HEADER LINE,
  POSCHEDULEX          TYPE TABLE OF BAPIMEPOSCHEDULX WITH HEADER LINE,
  ITEMX                TYPE TABLE OF BAPIMEPOITEMX  WITH HEADER LINE,
  RETURN               TYPE TABLE OF BAPIRET2,
  wa_return            TYPE BAPIRET2,
  POSERVICES           TYPE TABLE OF BAPIESLLC,
  LS_POSERVICES        TYPE BAPIESLLC,
  POSRVACCESSVALUES    TYPE TABLE OF  BAPIESKLC,
  LS_POSRVACCESSVALUES TYPE BAPIESKLC,
  POACCOUNT            TYPE TABLE OF BAPIMEPOACCOUNT,
  LS_POACCOUNT         TYPE BAPIMEPOACCOUNT,
  POACCOUNTX           TYPE TABLE OF  BAPIMEPOACCOUNTX,
  LS_POACCOUNTX        TYPE  BAPIMEPOACCOUNTX.