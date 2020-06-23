FUNCTION ZBAPI_PO_CREATE2.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_HEADER_TT) TYPE  ZPOHEADERT2
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_TT
*"     VALUE(EBELN) TYPE  EBELN
*"  TABLES
*"      PO_ITEM STRUCTURE  ZPOITEM
*"----------------------------------------------------------------------


  TYPES : BEGIN OF TY_EKPO,
            EBELN          TYPE EKPO-EBELN,
            EBELP          TYPE EKPO-EBELP,
            MENGE          TYPE EKPO-MENGE,
            WERKS          TYPE  EKPO-WERKS,
            MATNR          TYPE  EKPO-MATNR,
            MEINS          TYPE EKPO-MEINS,
            MATKL          TYPE EKPO-MATKL,
            NETPR          TYPE  EKPO-NETPR,
            ZZSET_MATERIAL TYPE EKPO-ZZSET_MATERIAL,
            WRF_CHARSTC2   TYPE EKPO-WRF_CHARSTC2,
          END OF TY_EKPO.

  DATA : HEADER  LIKE BAPIMEPOHEADER,
*         HEADER  LIKE BAPIMEPOHEADER,
         HEADERX LIKE BAPIMEPOHEADERX.
*       vendor_addr like BAPIMEPOADDRVENDOR .

**-> Begin Of Changes By NCHOUDHURY 09.04.2019 14:24:36

  DATA: BAPI_TE_PO   TYPE BAPI_TE_MEPOHEADER,
        IBAPI_TE_PO  TYPE BAPI_TE_MEPOHEADER,
        BAPI_TE_POX  TYPE BAPI_TE_MEPOHEADERX,
        IBAPI_TE_POX TYPE BAPI_TE_MEPOHEADERX.

**-> End Of Changes By NCHOUDHURY 09.04.2019 14:24:36
  DATA IT_TAX TYPE ZTAX_T .
  DATA WA_TAX TYPE ZTAX_S .

  DATA : ITEM                TYPE TABLE OF BAPIMEPOITEM  WITH HEADER LINE,
         POSCHEDULE          TYPE TABLE OF BAPIMEPOSCHEDULE WITH HEADER LINE,
         POSCHEDULEX         TYPE TABLE OF BAPIMEPOSCHEDULX WITH HEADER LINE,
         ITEMX               TYPE TABLE OF BAPIMEPOITEMX  WITH HEADER LINE,
         WA_ITEMX            TYPE BAPIMEPOITEMX,
         IT_RETURN           TYPE TABLE OF BAPIRET2,
         WA_RETURN           TYPE  BAPIRET2,
         EXTENSIONIN         TYPE TABLE OF BAPIPAREX,
         WA_EXTENSIONIN      TYPE  BAPIPAREX,
         POSERVICESTEXT      TYPE TABLE OF BAPIESLLTX,
         POTEXTITEM          TYPE TABLE OF BAPIMEPOTEXT,
         WA_POSERVICESTEXT   TYPE BAPIESLLTX,
         WA_POTEXTITEM       TYPE BAPIMEPOTEXT,
         WA_NO_PRICE_FROM_PO TYPE BAPIFLAG-BAPIFLAG.
*BREAK-POINT.

  DATA : LV_EBELN TYPE EBELN .
  DATA : WA_PO_ITEM TYPE ZPOITEM,
         WA_ITEM    TYPE BAPIMEPOITEM,
         WA_THEADER TYPE THEAD,
*         IT_LFA1    TYPE TABLE OF TY_LFA1,
*         WA_LFA1    TYPE TY_LFA1,
         WA_T500W   TYPE T500W.
*         WA_T001W   TYPE TY_T001W,
*         IT_A792    TYPE TABLE OF TY_A792,
*         WA_A792    TYPE TY_A792.

  DATA : WA_LINES TYPE  TLINE,
         LINES    TYPE TABLE OF TLINE,
         LV_TEXT  TYPE TDOBNAME,
         LV_MATNR TYPE CHAR40.
  DATA : LV_AMNT TYPE BAPICUREXT.
  DATA : IBAPICONDX TYPE TABLE OF BAPIMEPOCONDX WITH HEADER LINE.
  DATA : IBAPICOND TYPE TABLE OF BAPIMEPOCOND WITH HEADER LINE.
  DATA : IM_HEADER TYPE  ZPOHEADER2.
  DATA : LV_POITEM TYPE EBELP.

*  BREAK BREDDY.
  READ TABLE IM_HEADER_TT INTO IM_HEADER INDEX 1.
  IF SY-SUBRC = 0 .
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        INPUT  = IM_HEADER-LIFNR
*      IMPORTING
*        OUTPUT = IM_HEADER-LIFNR.


    HEADER-COMP_CODE = '1000'. "IM_HEADER-BUKRS. "'1000'.    "  ADDED ON (7-3-20)
    HEADERX-COMP_CODE = 'X'. "'1000'.
    HEADER-CREAT_DATE = IM_HEADER-AEDAT .
    HEADERX-CREAT_DATE = 'X' .
*    HEADER-VENDOR = IM_HEADER-LIFNR .
*    HEADERX-VENDOR = 'X' .
    HEADER-SUPPL_PLNT = IM_HEADER-DELIVERY_PLANT .
    HEADERX-SUPPL_PLNT = 'X' .
    HEADER-DOC_TYPE = IM_HEADER-POTYPE .
    HEADERX-DOC_TYPE = 'X' .
    HEADER-LANGU = SY-LANGU .
    HEADER-LANGU = 'X' .
    HEADER-PURCH_ORG = '9000'. "     IM_HEADER-EKORG .     "  ADDED ON (7-3-20)
    HEADERX-PURCH_ORG = 'X'.
    HEADER-PUR_GROUP =  IM_HEADER-EKGRP . "'001' .
    HEADERX-PUR_GROUP =  'X' . "'001' .
    HEADER-REF_1 = IM_HEADER-TRANNO.
    HEADERX-REF_1 = 'X'.
    BREAK BREDDY.
    CLEAR :LV_POITEM.
    LOOP AT PO_ITEM INTO WA_PO_ITEM.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = WA_PO_ITEM-MATNR
        IMPORTING
          OUTPUT = WA_PO_ITEM-MATNR.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = WA_PO_ITEM-EBELP
        IMPORTING
          OUTPUT = WA_PO_ITEM-EBELP.

*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          INPUT  = WA_PO_ITEM-MEINS
*        IMPORTING
*          OUTPUT = WA_PO_ITEM-MEINS.

*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          INPUT  = WA_PO_ITEM-MEINS
*        IMPORTING
*          OUTPUT = WA_PO_ITEM-MEINS.


*      LV_AMNT = WA_PO_ITEM-NETPR.
      LV_POITEM = LV_POITEM + 10.
      WA_PO_ITEM-EBELP = LV_POITEM.
      WA_ITEM-PO_ITEM = WA_PO_ITEM-EBELP.
      WA_ITEMX-PO_ITEM =   WA_PO_ITEM-EBELP.                                ""WA_PO_ITEM-EBELP.
      WA_ITEMX-PO_ITEMX =  'X'.                                ""WA_PO_ITEM-EBELP.
****   Start of changes by Suri : 05.04.2019
      SHIFT WA_PO_ITEM-MATNR LEFT DELETING LEADING '0'.
****   End of changes by Suri : 05.04.2019
      WA_ITEM-MATERIAL = WA_PO_ITEM-MATNR.
      WA_ITEMX-MATERIAL = 'X'.
      WA_ITEM-QUANTITY = WA_PO_ITEM-MENGE.
      WA_ITEMX-QUANTITY = 'X'.
      WA_ITEM-PO_UNIT = WA_PO_ITEM-MEINS.
      WA_ITEMX-PO_UNIT = 'X'.
      WA_ITEM-PLANT = WA_PO_ITEM-WERKS.
      WA_ITEMX-PLANT = 'X'.
      WA_ITEM-STGE_LOC = 'FG01'."WA_PO_ITEM-LGORT .       " "  ADDED ON (7-3-20)
      WA_ITEMX-STGE_LOC = 'X' .
      WA_ITEM-MATL_GROUP = WA_PO_ITEM-MATKL.
      WA_ITEMX-MATL_GROUP = 'X'.
      WA_ITEM-NET_PRICE = WA_PO_ITEM-NETPR.
*      WA_ITEM-PO_PRICE = '2'.
      WA_ITEMX-NET_PRICE = 'X'.
*      WA_ITEMX-PO_PRICE = 'X'.
      WA_ITEM-PRICE_UNIT = WA_PO_ITEM-PEINH.
      WA_ITEMX-PRICE_UNIT = 'X'.
*      WA_ITEM-GR_IND = 'X'.
      WA_ITEM-PLAN_DEL = WA_PO_ITEM-PLAN_DEL.
      WA_ITEMX-PLAN_DEL = 'X'.
*      WA_ITEM-IR_IND = 'X'.
*      WA_ITEMX-IR_IND = 'X'.
*      WA_ITEM-GR_BASEDIV = 'X'.
      WA_ITEM-GI_BASED_GR = 'X'.
*      WA_ITEMX-GR_BASEDIV = 'X'.
      WA_ITEMX-GI_BASED_GR = 'X'.
*    BREAK SAMBURI.

      WA_POTEXTITEM-PO_ITEM = WA_PO_ITEM-EBELP.
      WA_POTEXTITEM-TEXT_ID = 'F03'.
      WA_POTEXTITEM-TEXT_FORM = '*'.
      WA_POTEXTITEM-TEXT_LINE = WA_PO_ITEM-REMARKS.
      APPEND WA_POTEXTITEM TO POTEXTITEM.
      WA_POTEXTITEM-PO_ITEM = WA_PO_ITEM-EBELP.
      WA_POTEXTITEM-TEXT_ID = 'F07'.
      WA_POTEXTITEM-TEXT_FORM = '*'.
      WA_POTEXTITEM-TEXT_LINE = WA_PO_ITEM-STYLE.
      APPEND WA_POTEXTITEM TO POTEXTITEM.
      WA_POTEXTITEM-PO_ITEM = WA_PO_ITEM-EBELP.
      WA_POTEXTITEM-TEXT_ID = 'F08'.
      WA_POTEXTITEM-TEXT_FORM = '*'.
      WA_POTEXTITEM-TEXT_LINE = WA_PO_ITEM-COLOR.
      APPEND WA_POTEXTITEM TO POTEXTITEM.
      WA_ITEM-TAX_CODE = WA_PO_ITEM-TAX_CODE.
      WA_ITEMX-TAX_CODE = 'X'.
      APPEND WA_POTEXTITEM TO POTEXTITEM.

*      CALL METHOD ZCL_GST=>GET_GST_PER
*        EXPORTING
*          I_MATNR = WA_PO_ITEM-MATNR
*          I_LIFNR = IM_HEADER-LIFNR
*        IMPORTING
*          ET_TAX  = IT_TAX.
*
*      LOOP AT IT_TAX INTO WA_TAX.
*
*        IBAPICOND-ITM_NUMBER   = WA_PO_ITEM-EBELP.
*        IBAPICOND-COND_TYPE    = WA_TAX-COND_TYPE .
*        IBAPICOND-COND_VALUE   = WA_TAX-TAX .
*        IBAPICOND-CURRENCY     = WA_T500W-WAERS .
*        IBAPICOND-CHANGE_ID     = 'U' .
*
*
*        IBAPICONDX-ITM_NUMBER  = WA_PO_ITEM-EBELP.
*        IBAPICONDX-COND_TYPE   =  WA_TAX-COND_TYPE .
*        IBAPICONDX-COND_VALUE  = 'X'.
*        IBAPICONDX-CURRENCY    = 'X'.
*        IBAPICONDX-CHANGE_ID     = 'X' .
*        APPEND IBAPICOND .
*        APPEND IBAPICONDX.
*
*      ENDLOOP.


      APPEND WA_ITEM TO ITEM[].
      APPEND WA_ITEMX TO ITEMX[].
      CLEAR : WA_ITEM,WA_ITEMX.
*      BREAK BREDDY.
**-> Begin Of Changes By NCHOUDHURY 09.04.2019 14:23:54
      WA_EXTENSIONIN-STRUCTURE = 'BAPI_TE_MEPOHEADER'.
      BAPI_TE_PO-PO_NUMBER = ' '.
      BAPI_TE_PO-AGENT_NAME = IM_HEADER-ZAGENT.
      BAPI_TE_PO-USER_NAME = IM_HEADER-ZUNAME.
      BAPI_TE_PO-ERDATE = IM_HEADER-ZERDAT.
      BAPI_TE_PO-APPROVER1 = IM_HEADER-ZAPPROVER1.
      BAPI_TE_PO-APPROVER1_DT = IM_HEADER-ZAPPROVER1_DT.
      BAPI_TE_PO-APPROVER2 = IM_HEADER-ZAPPROVER2.
      BAPI_TE_PO-APPROVER2_DT = IM_HEADER-ZAPPROVER2_DT.
      BAPI_TE_PO-ZDAYS = IM_HEADER-ZDAYS.
      WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_PO.

      APPEND WA_EXTENSIONIN TO EXTENSIONIN.


      WA_EXTENSIONIN-STRUCTURE = 'BAPI_TE_MEPOHEADERX'.
      BAPI_TE_POX-PO_NUMBER = ' '.
      BAPI_TE_POX-AGENT_NAME = 'X'.
      BAPI_TE_POX-USER_NAME = 'X'.
      BAPI_TE_POX-ERDATE = 'X'.
      BAPI_TE_POX-APPROVER1 = 'X'.
      BAPI_TE_POX-APPROVER1_DT = 'X'.
      BAPI_TE_POX-APPROVER2 = 'X'.
      BAPI_TE_POX-APPROVER2_DT = 'X'.
      WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_POX.
      APPEND WA_EXTENSIONIN TO EXTENSIONIN.
      CLEAR WA_EXTENSIONIN.

*      WA_NO_PRICE_FROM_PO-BAPIFLAG = 'X'.
      MODIFY PO_ITEM FROM WA_PO_ITEM TRANSPORTING EBELP .
    ENDLOOP.
**-> End Of Changes By NCHOUDHURY 09.04.2019 14:23:54


**-> Begin Of Changes By NCHOUDHURY 09.04.2019 14:23:31



*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      INPUT         = IM_HEADER-ZDAYS
*   IMPORTING
*     OUTPUT        = IM_HEADER-ZDAYS
*     .
*
*  WA_EXTENSIONIN-VALUEPART1+0(8) = IM_HEADER-ZDAYS.
*  WA_EXTENSIONIN-VALUEPART1+8(30) = IM_HEADER-ZAGENT.
*  WA_EXTENSIONIN-VALUEPART1+38(30) = IM_HEADER-ZUNAME.
*  WA_EXTENSIONIN-VALUEPART1+68(8) = IM_HEADER-ZERDAT.
*  WA_EXTENSIONIN-VALUEPART1+76(20) = IM_HEADER-ZAPPROVER1.
*  WA_EXTENSIONIN-VALUEPART1+96(8) = IM_HEADER-ZAPPROVER1_DT.
*  WA_EXTENSIONIN-VALUEPART1+104(20) = IM_HEADER-ZAPPROVER2.
*  WA_EXTENSIONIN-VALUEPART1+124(8) = IM_HEADER-ZAPPROVER2_DT.
**  WA_EXTENSIONIN-ZAPPROVER2_DT+124(8) = IM_HEADER-ZAPPROVER2_DT.

*  APPEND WA_EXTENSIONIN TO EXTENSIONIN.
*  ENDLOOP.

**-> End Of Changes By NCHOUDHURY 09.04.2019 14:23:31

*  BREAK-POINT.
*    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
*      EXPORTING
*        INPUT          = WA_PO_ITEM-MEINS
*        LANGUAGE       = SY-LANGU
*      IMPORTING
**       LONG_TEXT      =
*        OUTPUT         = WA_PO_ITEM-MEINS
**       SHORT_TEXT     =
*      EXCEPTIONS
*        UNIT_NOT_FOUND = 1
*        OTHERS         = 2.
*    IF SY-SUBRC <> 0.
** Implement suitable error handling here
*    ENDIF.
*    BREAK BREDDY.
    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        POHEADER         = HEADER
        POHEADERX        = HEADERX
*       POADDRVENDOR     =
*       TESTRUN          =
*       MEMORY_UNCOMPLETE            =
*       MEMORY_COMPLETE  =
*       POEXPIMPHEADER   =
*       POEXPIMPHEADERX  =
*       VERSIONS         =
*       NO_MESSAGING     =
*       NO_MESSAGE_REQ   =
*       NO_AUTHORITY     =
        NO_PRICE_FROM_PO = 'X'
*       PARK_COMPLETE    =
*       PARK_UNCOMPLETE  =
      IMPORTING
        EXPPURCHASEORDER = LV_EBELN
*       EXPHEADER        =
*       EXPPOEXPIMPHEADER            =
      TABLES
        RETURN           = IT_RETURN[]
        POITEM           = ITEM[]
        POITEMX          = ITEMX[]
*       POADDRDELIVERY   =
*       POSCHEDULE       =
*       POSCHEDULEX      =
*       POACCOUNT        =
*       POACCOUNTPROFITSEGMENT       =
*       POACCOUNTX       =
*       POCONDHEADER     =
*       POCONDHEADERX    =
*       POCOND           =
*       POCONDX          =
*       POLIMITS         =
*       POCONTRACTLIMITS =
*       POSERVICES       =
*       POSRVACCESSVALUES            =
*       POSERVICESTEXT   = POSERVICESTEXT[]
        EXTENSIONIN      = EXTENSIONIN[]
*       EXTENSIONOUT     =
*       POEXPIMPITEM     =
*       POEXPIMPITEMX    =
*       POTEXTHEADER     =
        POTEXTITEM       = POTEXTITEM[]
*       ALLVERSIONS      =
*       POPARTNER        =
*       POCOMPONENTS     =
*       POCOMPONENTSX    =
*       POSHIPPING       =
*       POSHIPPINGX      =
*       POSHIPPINGEXP    =
*       SERIALNUMBER     =
*       SERIALNUMBERX    =
*       INVPLANHEADER    =
*       INVPLANHEADERX   =
*       INVPLANITEM      =
*       INVPLANITEMX     =
*       NFMETALLITMS     =
      .
    ET_RETURN  = IT_RETURN.
    EBELN = LV_EBELN.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

  ENDIF.
BREAK BREDDY.
*  IF LV_EBELN IS NOT INITIAL.
*
*
*    DATA: WA_EKKO        TYPE EKKO,
*          LV_ADRC        TYPE AD_ADDRNUM,
*          LV_ADRC1       TYPE ADRNR,
*          LV_ADRC2       TYPE ADRNR,
*          IT_POITEM      TYPE TABLE OF ZPOITEM,
*          WA_POITEM      TYPE ZPOITEM,
*          WA_POHEADER    TYPE ZPOHEADER,
**          WA_LFA1       TYPE LFA1,
*          IT_EKKO        TYPE TABLE OF EKKO,
**          WA_EKKO TYPE EKKO,
*          IT_EKPO        TYPE TABLE OF TY_EKPO,
*          WA_EKPO        TYPE  TY_EKPO,
**          WA_ADRC       TYPE ADRC,
*          IT_MARA        TYPE TABLE OF MARA,
*          WA_MARA        TYPE  MARA,
*          IT_MAKT        TYPE TABLE OF MAKT,
*          WA_MAKT        TYPE MAKT,
*          LV_WORDS(100)  TYPE C,
*          LV_ERNAME      TYPE ERNAM,
*          LV_BILL_D(30)  TYPE C,
*          LV_REF_PO(30)  TYPE C,
*          LV_RPO         TYPE EBELN,
*          LV_BILLD       TYPE ZBILL_DAT,
*          LV_HEADING(30) TYPE C.
*    DATA : LV_NAME   TYPE THEAD-TDNAME,
*           LV_NAME1  TYPE THEAD-TDNAME,
*           LV_NAME2  TYPE THEAD-TDNAME,
*           LV_NAME3  TYPE THEAD-TDNAME,
*           IT_LINES  TYPE TABLE OF TLINE WITH HEADER LINE,
*           IT_LINES2 TYPE TABLE OF TLINE WITH HEADER LINE,
*           IT_LINES3 TYPE TABLE OF TLINE WITH HEADER LINE.
*
*    DATA : P_AEDAT(10) TYPE C.
*    DATA  : FMNAME TYPE RS38L_FNAM.
*    DATA  : FM_NAME TYPE RS38L_FNAM.
*    DATA : SEND_REQUEST            TYPE REF TO CL_BCS,
*           V_SEND_REQUEST          TYPE REF TO CL_SAPUSER_BCS,
*           DOCUMENT                TYPE REF TO CL_DOCUMENT_BCS,
*           RECIPIENT               TYPE REF TO IF_RECIPIENT_BCS,
*           I_SENDER                TYPE REF TO IF_SENDER_BCS,
*           BCS_EXCEPTION           TYPE REF TO CX_BCS,
*           MAIN_TEXT               TYPE BCSY_TEXT,
*           LS_MAIN_TEXT            LIKE LINE OF MAIN_TEXT,
*           LS_TEXT                 TYPE SO_TEXT255,
*           LS_TEXT1                TYPE SO_TEXT255,
*           LS_TEXT2                TYPE SO_TEXT255,
*           BINARY_CONTENT          TYPE SOLIX_TAB,
*           SIZE                    TYPE SO_OBJ_LEN,
*           SENT_TO_ALL             TYPE OS_BOOLEAN,
*           SUBJECT                 TYPE SOOD-OBJDES,
*           I_SUB                   TYPE SO_OBJ_DES,
*           U,
**           FMNAME                  TYPE RS38L_FNAM,
*           LS_OUTPUTOP             TYPE SSFCOMPOP,
*           LT_PDF_DATA             TYPE SOLIX_TAB,
*           LT_PDF_DATA1            TYPE SOLIX_TAB,
*           LT_MAIL_BODY            TYPE SOLI_TAB,
*           LT_OBJTEXT              TYPE TABLE OF SOLISTI1,
*           LT_OBJPACK              TYPE TABLE OF SOPCKLSTI1,
*           LT_LINES                TYPE TABLE OF TLINE,
*           LT_LINES1               TYPE TABLE OF TLINE,
*           LT_RECORD               TYPE TABLE OF SOLISTI1,
*           LT_OTF                  TYPE TSFOTF,
*           LT_OTF1                 TYPE TSFOTF,
*           LT_MAIL_SENDER          TYPE BAPIADSMTP_T,
*           LT_MAIL_RECIPIENT       TYPE BAPIADSMTP_T,
*           LS_CTRLOP               TYPE SSFCTRLOP,
*           IS_CONTROL_PARAMETERS   TYPE SSFCTRLOP,
*           IS_OUTPUT_OPTIONS       TYPE SSFCOMPOP,
*           LS_DOCUMENT_OUTPUT_INFO TYPE SSFCRESPD,
*           LS_JOB_OUTPUT_INFO      TYPE SSFCRESCL,
*           LS_JOB_OUTPUT_OPTIONS   TYPE SSFCRESOP,
*           LV_OTF                  TYPE XSTRING,
*           LV_OTF1                 TYPE XSTRING,
*           LS_BIN_FILESIZE         TYPE SOOD-OBJLEN,
*           LS_BIN_FILESIZE1        TYPE SOOD-OBJLEN,
**           WA_ITOB                 TYPE ITOB,
*           LV_DOC_SUBJECT          TYPE SOOD-OBJDES,
*           LV_DOC_SUBJECT1         TYPE SOOD-OBJDES,
*           LT_RECLIST              TYPE BCSY_SMTPA,
*           LS_RECLIST              TYPE  AD_SMTPADR,
**           LS_SMAIL                TYPE ZSALES_EMAIL,
*           I_ADDRESS_STRING        TYPE ADR6-SMTP_ADDR,
*           ES_MSG(100)             TYPE C.
*    DATA : LV_A       TYPE C,
*           LV_B       TYPE C,
*           LV_C       TYPE C,
*           LV_DEL     TYPE SY-DATUM,
*           LV_DEL1    TYPE SY-DATUM,
*           LV_GSTIN_V TYPE STCD3,
*           LV_GSTIN_C TYPE STCD1,
*           LV_PDATE   TYPE T5A4A-DLYDY.
**    BREAK                   BREDDY.
*
**     wa_header-
*
*    BREAK BREDDY.
*    P_AEDAT  = SY-DATUM .
*
*    BREAK BREDDY.
*    CALL FUNCTION 'CONVERSION_EXIT_GDATE_OUTPUT'
*      EXPORTING
*        INPUT  = P_AEDAT
*      IMPORTING
*        OUTPUT = P_AEDAT.
**    READ TABLE IT_EKKO INTO WA_EKKO INDEX 1.
**    BREAK BREDDY.
**    IF WA_EKKO IS NOT INITIAL.
*    SELECT SINGLE NAME1, ADRNR , WERKS, STCD3 INTO @DATA(WA_LFA1) FROM LFA1
*          WHERE LIFNR = @HEADER-VENDOR.
*
*    IF LV_EBELN IS NOT INITIAL.
*      SELECT EKKO~EBELN EKKO~BUKRS EKKO~AEDAT EKKO~BEDAT EKKO~ERNAM EKKO~USER_NAME FROM EKKO  INTO  CORRESPONDING FIELDS OF TABLE IT_EKKO
*        WHERE EBELN = LV_EBELN .
*
**        ELSE.
**           SELECT * FROM ZINW_T_HDR INTO  @DATA(WA_ZINW_T_HDR) WHERE TAT_PO = LV_EBELN .            """TATKAL PO
*    ENDIF.
*
*    IF IT_EKKO IS NOT INITIAL.
*      SELECT  EKPO~EBELN , EKPO~EBELP , EKPO~MENGE , EKPO~WERKS  , EKPO~MATNR , EKPO~MEINS , EKPO~MATKL , EKPO~NETPR , EKPO~ZZSET_MATERIAL  ,
*        EKPO~WRF_CHARSTC2 FROM EKPO INTO TABLE  @IT_EKPO WHERE EBELN = @LV_EBELN.
*    ENDIF.
*    READ TABLE IT_EKKO INTO WA_EKKO INDEX 1.
*    READ TABLE IT_EKPO INTO WA_EKPO WITH KEY EBELN = LV_EBELN.
*
*    IF IT_EKPO IS NOT INITIAL.
*      SELECT SINGLE T001W~ADRNR  FROM T001W INTO @DATA(LV_PADRNR) WHERE WERKS = @WA_EKPO-WERKS.
*    ENDIF.
*
*    IF WA_EKKO IS NOT INITIAL.
*      SELECT SINGLE T001~BUKRS , T001~ADRNR FROM T001 INTO @DATA(WA_T001) WHERE BUKRS = @WA_EKKO-BUKRS.
*      SELECT SINGLE J_1BBRANCH~BUKRS, J_1BBRANCH~GSTIN FROM J_1BBRANCH INTO @DATA(WA_J_1BBRANCH) WHERE BUKRS = @WA_EKKO-BUKRS.
*
*    ENDIF.
*    LV_ADRC = WA_LFA1-ADRNR.
*    LV_ADRC1 = LV_PADRNR.
**    LV_ADRC2 = WA_T001-ADRNR.
*    LV_ADRC2 = LV_PADRNR.
*
**    ENDIF.
*    BREAK BREDDY.
*    SELECT MARA~MATNR  MARA~MATKL  MARA~ZZPO_ORDER_TXT  MARA~SIZE1 MARA~COLOR FROM MARA INTO CORRESPONDING FIELDS OF TABLE IT_MARA FOR ALL ENTRIES IN IT_EKPO WHERE MATNR = IT_EKPO-MATNR .
*    SELECT T023T~MATKL , T023T~WGBEZ , T023T~WGBEZ60 FROM T023T INTO TABLE @DATA(IT_T023T) FOR ALL ENTRIES IN @IT_EKPO WHERE MATKL = @IT_EKPO-MATKL.
*    SELECT * FROM MAKT INTO TABLE IT_MAKT
*      FOR ALL ENTRIES IN PO_ITEM
*      WHERE MATNR = PO_ITEM-MATNR AND SPRAS EQ SY-LANGU.
*
*    WA_POHEADER-AD_NAME = WA_LFA1-NAME1.
*    WA_POHEADER-LIFNR = HEADER-VENDOR.
*    WA_POHEADER-AEDAT =  WA_EKKO-AEDAT  .
*
**    IF WA_EKKO-USER_NAME IS INITIAL.
*    WA_POHEADER-ZUNAME = WA_EKKO-USER_NAME.
**    ELSE.
**      LV_ERNAME  =  WA_EKKO-ERNAM.
**    ENDIF.
*
*
*
*
**    WA_POHEADER-ZUNAME = IM_HEADER-ZUNAME.
*    LV_GSTIN_V = WA_LFA1-STCD3.
*    LV_GSTIN_C = WA_J_1BBRANCH-GSTIN.
**    WA_POHEADER-REF_PO =  WA_ZINW_T_HDR-EBELN.                             ""TATKAL PO
**    WA_POHEADER-BILL_TAT =  WA_ZINW_T_HDR-BILL_DATE.                      ""TATKAL PO BILL DATE
*    SELECT SINGLE EKET~EBELN , EKET~EINDT FROM EKET INTO @DATA(WA_EKET) WHERE EBELN = @LV_EBELN.
*    WA_POHEADER-DEL_BY = WA_EKET-EINDT.
*
**    BREAK BREDDY.
*
*
*    DATA : LV_NO TYPE CHAR10.
*
*    LOOP AT IT_EKPO INTO WA_EKPO.
**      LV_NO = LV_NO + 1.
**      WA_POITEM-ZSL = LV_NO.
*
**      READ TABLE IT_EKKO ASSIGNING FIELD-SYMBOL(<WA_EKKO>) WITH KEY EBELN = LV_EBELN.
**      IF <WA_EKKO> IS  ASSIGNED.
*
*
**        READ TABLE IT_EKPO ASSIGNING FIELD-SYMBOL(<WA_EKPO>) WITH KEY EBELN = WA_EKKO-EBELN.
*
***        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
***          EXPORTING
***            INPUT  = <WA_EKPO>-EBELP
***          IMPORTING
***            OUTPUT = <WA_EKPO>-EBELP.
*
**        SHIFT <WA_EKPO>-EBELP LEFT DELETING LEADING '0'.
*
**        WA_POITEM-EBELP =  <WA_EKPO>-EBELP.
*
**      ENDIF.
*      .
*
*
*      WA_POITEM-MENGE = WA_EKPO-MENGE.
*      WA_POITEM-NETPR = WA_EKPO-NETPR.
*      WA_POITEM-MT_GRP = WA_EKPO-MATKL.
*      WA_POITEM-NETAMT  = WA_EKPO-NETPR * WA_EKPO-MENGE.
*      ADD WA_POITEM-NETAMT TO WA_POHEADER-TOTAL.
*
*      LV_POITEM = LV_POITEM + 10.
*      WA_POITEM-EBELP = LV_POITEM.
*      CLEAR: WA_MAKT, WA_MARA.
**        READ TABLE IT_MAKT INTO WA_MAKT WITH  KEY MATNR = WA_PO_ITEM-MATNR .
*      READ TABLE IT_T023T ASSIGNING FIELD-SYMBOL(<WA_T023T>) WITH KEY MATKL = WA_EKPO-MATKL.
*      IF SY-SUBRC = 0.
*        WA_POITEM-WGBEZ = <WA_T023T>-WGBEZ60.
*      ENDIF.
*      REFRESH :IT_LINES[].
*
*      CLEAR LV_NAME1.
*      CONCATENATE LV_EBELN WA_EKPO-EBELP INTO LV_NAME1.
*      CALL FUNCTION 'READ_TEXT'
*        EXPORTING
**         CLIENT                  = SY-MANDT
*          ID                      = 'F03'
*          LANGUAGE                = 'E'
*          NAME                    = LV_NAME1
*          OBJECT                  = 'EKPO'
*        TABLES
*          LINES                   = IT_LINES[]
*        EXCEPTIONS
*          ID                      = 1
*          LANGUAGE                = 2
*          NAME                    = 3
*          NOT_FOUND               = 4
*          OBJECT                  = 5
*          REFERENCE_CHECK         = 6
*          WRONG_ACCESS_TO_ARCHIVE = 7
*          OTHERS                  = 8.
*      IF SY-SUBRC <> 0.
** Implement suitable error handling here
*      ENDIF.
*
*
*      LOOP AT IT_LINES.
*
*        CONCATENATE IT_LINES-TDLINE WA_POITEM-REMARKS INTO WA_POITEM-REMARKS .
*        CLEAR IT_LINES .
*
*      ENDLOOP.
*
*      REFRESH :IT_LINES[].
*
*      CLEAR LV_NAME1.
*      CONCATENATE LV_EBELN WA_EKPO-EBELP INTO LV_NAME2.
*      CALL FUNCTION 'READ_TEXT'
*        EXPORTING
**         CLIENT                  = SY-MANDT
*          ID                      = 'F07'
*          LANGUAGE                = 'E'
*          NAME                    = LV_NAME2
*          OBJECT                  = 'EKPO'
**         ARCHIVE_HANDLE          = 0
**         LOCAL_CAT               = ' '
**       IMPORTING
**         HEADER                  =
**         OLD_LINE_COUNTER        =
*        TABLES
*          LINES                   = IT_LINES2[]
*        EXCEPTIONS
*          ID                      = 1
*          LANGUAGE                = 2
*          NAME                    = 3
*          NOT_FOUND               = 4
*          OBJECT                  = 5
*          REFERENCE_CHECK         = 6
*          WRONG_ACCESS_TO_ARCHIVE = 7
*          OTHERS                  = 8.
*      IF SY-SUBRC <> 0.
** Implement suitable error handling here
*      ENDIF.
*
*
*      LOOP AT IT_LINES2.
*
*        CONCATENATE IT_LINES2-TDLINE WA_POITEM-STYLE INTO WA_POITEM-STYLE .
*        CLEAR IT_LINES2 .
*
*      ENDLOOP.
*      CLEAR : WA_MARA.
*      READ TABLE IT_MARA INTO WA_MARA WITH  KEY MATNR = WA_EKPO-MATNR .
*      WA_POITEM-SIZE = WA_MARA-SIZE1.
*      IF WA_MARA-COLOR IS NOT INITIAL.
*        WA_POITEM-COLOR = WA_MARA-COLOR.
*      ELSE.
*
*        REFRESH :IT_LINES3[].
*
*        CLEAR LV_NAME1.
*        CONCATENATE LV_EBELN WA_EKPO-EBELP INTO LV_NAME3.
*        CALL FUNCTION 'READ_TEXT'
*          EXPORTING
**           CLIENT                  = SY-MANDT
*            ID                      = 'F08'
*            LANGUAGE                = 'E'
*            NAME                    = LV_NAME3
*            OBJECT                  = 'EKPO'
**           ARCHIVE_HANDLE          = 0
**           LOCAL_CAT               = ' '
**       IMPORTING
**           HEADER                  =
**           OLD_LINE_COUNTER        =
*          TABLES
*            LINES                   = IT_LINES3[]
*          EXCEPTIONS
*            ID                      = 1
*            LANGUAGE                = 2
*            NAME                    = 3
*            NOT_FOUND               = 4
*            OBJECT                  = 5
*            REFERENCE_CHECK         = 6
*            WRONG_ACCESS_TO_ARCHIVE = 7
*            OTHERS                  = 8.
*        IF SY-SUBRC <> 0.
** Implement suitable error handling here
*        ENDIF.
*
*
*        LOOP AT IT_LINES3.
*
*          CONCATENATE IT_LINES3-TDLINE WA_POITEM-COLOR INTO WA_POITEM-COLOR .
*          CLEAR IT_LINES3 .
*
*        ENDLOOP.
*      ENDIF.
*
*
*      APPEND WA_POITEM TO IT_POITEM.
*      CLEAR : WA_POITEM.
**    ENDIF.
*    ENDLOOP.
**    CLEAR : LV_NO.
*    DATA : LV_AMT TYPE PC207-BETRG.
*    LV_AMT  = WA_POHEADER-TOTAL.
*    CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
*      EXPORTING
*        AMT_IN_NUM         = LV_AMT
*      IMPORTING
*        AMT_IN_WORDS       = LV_WORDS
*      EXCEPTIONS
*        DATA_TYPE_MISMATCH = 1
*        OTHERS             = 2.
*    IF SY-SUBRC <> 0.
** Implement suitable error handling here
*    ENDIF.
*
*    CALL FUNCTION 'FI_CONVERT_FIRSTCHARS_TOUPPER'
*      EXPORTING
*        INPUT_STRING  = LV_WORDS
**       SEPARATORS    = ' -.,;:'
*      IMPORTING
*        OUTPUT_STRING = LV_WORDS.
*
*
**
*    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*      EXPORTING
*        FORMNAME           = 'ZPURCHASE_ORDER_FORM'
**       VARIANT            = ' '
**       DIRECT_CALL        = ' '
*      IMPORTING
*        FM_NAME            = FMNAME
*      EXCEPTIONS
*        NO_FORM            = 1
*        NO_FUNCTION_MODULE = 2
*        OTHERS             = 3.
*    IF SY-SUBRC <> 0.
** Implement suitable error handling here
*    ENDIF.
**
*
*    LS_CTRLOP-GETOTF = ABAP_TRUE.
*    LS_CTRLOP-NO_DIALOG = 'X'.
*    LS_CTRLOP-LANGU = SY-LANGU.
*
*    LS_OUTPUTOP = IS_OUTPUT_OPTIONS.
*    LS_OUTPUTOP-TDNOPREV = ABAP_TRUE.
*    LS_OUTPUTOP-TDDEST  = 'LP01'.
*
*
*    CALL FUNCTION FMNAME
*      EXPORTING
*        CONTROL_PARAMETERS   = LS_CTRLOP
*        OUTPUT_OPTIONS       = LS_OUTPUTOP
*        WA_POHEADER          = WA_POHEADER
*        LV_EBELN             = LV_EBELN
*        LV_ADRC              = LV_ADRC
*        LV_ADRC1             = LV_ADRC1
*        LV_ADRC2             = LV_ADRC2
*        LV_WORDS             = LV_WORDS
*        LV_GSTIN_V           = LV_GSTIN_V
*        LV_GSTIN_C           = LV_GSTIN_C
*        LV_HEADING           = LV_HEADING
*        LV_BILLD             = LV_BILLD
*        LV_RPO               = LV_RPO
*        LV_REF_PO            = LV_REF_PO
*        LV_BILL_D            = LV_BILL_D
*        LV_ERNAME            = LV_ERNAME
*      IMPORTING
*        DOCUMENT_OUTPUT_INFO = LS_DOCUMENT_OUTPUT_INFO
*        JOB_OUTPUT_INFO      = LS_JOB_OUTPUT_INFO
*        JOB_OUTPUT_OPTIONS   = LS_JOB_OUTPUT_OPTIONS
*      TABLES
*        IT_POITEM            = IT_POITEM
*      EXCEPTIONS
*        FORMATTING_ERROR     = 1
*        INTERNAL_ERROR       = 2
*        SEND_ERROR           = 3
*        USER_CANCELED        = 4
*        OTHERS               = 5.
*    IF SY-SUBRC <> 0.
***           Implement suitable error handling here
**  ENDIF.
*
*    ELSE.
*
*      LT_OTF = LS_JOB_OUTPUT_INFO-OTFDATA.
*
**      BREAK-POINT.
*      CALL FUNCTION 'CONVERT_OTF'
*        EXPORTING
*          FORMAT                = 'PDF'
*          MAX_LINEWIDTH         = 132
*        IMPORTING
*          BIN_FILESIZE          = LS_BIN_FILESIZE
*          BIN_FILE              = LV_OTF
*        TABLES
*          OTF                   = LT_OTF
*          LINES                 = LT_LINES
*        EXCEPTIONS
*          ERR_MAX_LINEWIDTH     = 1
*          ERR_FORMAT            = 2
*          ERR_CONV_NOT_POSSIBLE = 3
*          ERR_BAD_OTF           = 4.
*
*    ENDIF.
*
*    CALL METHOD CL_DOCUMENT_BCS=>XSTRING_TO_SOLIX
*      EXPORTING
*        IP_XSTRING = LV_OTF
*      RECEIVING
*        RT_SOLIX   = LT_PDF_DATA.
*
*    TRY.
*        REFRESH MAIN_TEXT.
*
**-------- create persistent send request ------------------------
*        SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT = 'To,'.
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT = '<BR>'.
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT = 'All Concerned' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT = '<BR>'.
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT = '<BR>'.
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT = 'Sub: Purchase Order & Packing List release/amendment'.
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  '<BR>'.
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  '<BR>'.
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  'The following Purchase Order & Packing List is released/amendment. Please take necessary action:' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  '<BR>' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  '<BR>' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*        LS_TEXT =  | VENDOR NAME  : { WA_POHEADER-AD_NAME } | .
*        CLEAR LS_MAIN_TEXT.
**      LS_MAIN_TEXT =  | 'VENDOR NAME'  : { WA_POHEADER-AD_NAME } | .
**      LS_MAIN_TEXT =  | { 'VENDOR NAME : ' } | && | { WA_POHEADER-AD_NAME } | .
**        LS_MAIN_TEXT =   'VENDOR NAME : ' .
*        LS_MAIN_TEXT =   LS_TEXT .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  '<BR>' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        LS_TEXT1 =  | PURCHASE ORDER NO  : { LV_EBELN  } | .
*        CLEAR LS_MAIN_TEXT.
**      LS_MAIN_TEXT =  | 'PURCHASE ORDER NO'  : { LV_EBELN }| .
*        LS_MAIN_TEXT =   LS_TEXT1 .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  '<BR>' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        LS_TEXT2 =  | PO. APPROVED DATE  : { P_AEDAT  } | .
*        CLEAR LS_MAIN_TEXT.
**      LS_MAIN_TEXT =  | 'PO. APPROVED DATE'  : { WA_POHEADER-AEDAT }| .
*        LS_MAIN_TEXT =   LS_TEXT2 .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  '<BR>' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
**      LS_MAIN_TEXT =  | 'REMARKS'  : { WA_POITEM-REMARKS }| .
*        LS_MAIN_TEXT =  'REMARKS : PO Created'   .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  '<BR>' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  '<BR>' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  'From.' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  '<BR>' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  'PurchaseDept.' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  '<BR>' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  'Note: 1. This is auto generated e-mailfrom SAP system.' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  '<BR>' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  'clarifications contact TSG/MKTG.dept.' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  '<BR>' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*        CLEAR LS_MAIN_TEXT.
*        LS_MAIN_TEXT =  '2. Please do not reply to this email.For any queries or clarifications:Email to:sdp.asher@gmail.com' .
*        APPEND LS_MAIN_TEXT TO MAIN_TEXT.
*
*      CATCH CX_BCS INTO BCS_EXCEPTION.
*        MESSAGE I865(SO) WITH BCS_EXCEPTION->ERROR_TYPE.
*
*    ENDTRY.
*
*    CONCATENATE 'Purchase Order' LV_EBELN '.pdf' INTO LV_DOC_SUBJECT.
*
*    TRY .
*        DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
*            I_TYPE    = 'HTM'
*            I_TEXT    = MAIN_TEXT
*            I_SUBJECT = LV_DOC_SUBJECT ).
*      CATCH CX_DOCUMENT_BCS .
*
*    ENDTRY.
*
*    TRY.
*        DOCUMENT->ADD_ATTACHMENT( I_ATTACHMENT_TYPE = 'BIN'
*                                    I_ATTACHMENT_SUBJECT = LV_DOC_SUBJECT
*                                    I_ATT_CONTENT_HEX = LT_PDF_DATA ).
*
*      CATCH CX_DOCUMENT_BCS.
*    ENDTRY.
**    BREAK BREDDY.
*    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*      EXPORTING
*        FORMNAME           = 'ZPACKING_FORM'
**       VARIANT            = ' '
**       DIRECT_CALL        = ' '
*      IMPORTING
*        FM_NAME            = FM_NAME
*      EXCEPTIONS
*        NO_FORM            = 1
*        NO_FUNCTION_MODULE = 2
*        OTHERS             = 3.
*    IF SY-SUBRC <> 0.
** Implement suitable error handling here
*    ENDIF.
*
*    CLEAR :
*    LS_DOCUMENT_OUTPUT_INFO,
*    LS_JOB_OUTPUT_INFO,
*    LS_JOB_OUTPUT_OPTIONS.
*
*
*    CALL FUNCTION FM_NAME
*      EXPORTING
*        CONTROL_PARAMETERS   = LS_CTRLOP
*        OUTPUT_OPTIONS       = LS_OUTPUTOP
*        WA_POHEADER          = WA_POHEADER
*        LV_EBELN             = LV_EBELN
*        LV_ADRC              = LV_ADRC
*        LV_ADRC1             = LV_ADRC1
*        LV_ADRC2             = LV_ADRC2
*        LV_WORDS             = LV_WORDS
*        LV_GSTIN_V           = LV_GSTIN_V
*        LV_GSTIN_C           = LV_GSTIN_C
*      IMPORTING
*        DOCUMENT_OUTPUT_INFO = LS_DOCUMENT_OUTPUT_INFO
*        JOB_OUTPUT_INFO      = LS_JOB_OUTPUT_INFO
*        JOB_OUTPUT_OPTIONS   = LS_JOB_OUTPUT_OPTIONS
*      TABLES
*        IT_POITEM            = IT_POITEM
*      EXCEPTIONS
*        FORMATTING_ERROR     = 1
*        INTERNAL_ERROR       = 2
*        SEND_ERROR           = 3
*        USER_CANCELED        = 4
*        OTHERS               = 5.
*    IF SY-SUBRC <> 0.
**           Implement suitable error handling here
**        ENDIF.
**      ENDIF.
*
*
*    ELSE.
**      CLEAR :LS_BIN_FILESIZE,
**             LV_OTF,
**             LT_OTF,
**             LT_LINES.
*      LT_OTF1 = LS_JOB_OUTPUT_INFO-OTFDATA.
*
*      CALL FUNCTION 'CONVERT_OTF'
*        EXPORTING
*          FORMAT                = 'PDF'
*          MAX_LINEWIDTH         = 132
*        IMPORTING
*          BIN_FILESIZE          = LS_BIN_FILESIZE1
*          BIN_FILE              = LV_OTF1
*        TABLES
*          OTF                   = LT_OTF1
*          LINES                 = LT_LINES1
*        EXCEPTIONS
*          ERR_MAX_LINEWIDTH     = 1
*          ERR_FORMAT            = 2
*          ERR_CONV_NOT_POSSIBLE = 3
*          ERR_BAD_OTF           = 4.
*
*    ENDIF.
*
*    CALL METHOD CL_DOCUMENT_BCS=>XSTRING_TO_SOLIX
*      EXPORTING
*        IP_XSTRING = LV_OTF1
*      RECEIVING
*        RT_SOLIX   = LT_PDF_DATA1.
*
*
*    CLEAR LV_DOC_SUBJECT1.
*    CONCATENATE 'Packing List' LV_EBELN '.pdf' INTO LV_DOC_SUBJECT1.
*
*    TRY.
*        DOCUMENT->ADD_ATTACHMENT( I_ATTACHMENT_TYPE = 'BIN'
*                                    I_ATTACHMENT_SUBJECT = LV_DOC_SUBJECT1
*                                    I_ATT_CONTENT_HEX = LT_PDF_DATA1 ).
*
*      CATCH CX_DOCUMENT_BCS.
*    ENDTRY.
*
*    TRY.
*
**     add document object to send request
*        SEND_REQUEST->SET_DOCUMENT( DOCUMENT ).
*
*
*        V_SEND_REQUEST = CL_SAPUSER_BCS=>CREATE( SY-UNAME ).
*
*        CALL METHOD SEND_REQUEST->SET_SENDER
*          EXPORTING
*            I_SENDER = V_SEND_REQUEST.
*
**break breddy.
**          LOOP AT LT_RECLIST INTO LS_RECLIST.
**            I_ADDRESS_STRING = LS_RECLIST.
*        RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'bhabani.reddy@zietatech.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*        SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*        CLEAR I_ADDRESS_STRING.
**          ENDLOOP.
*        RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'dummyposap@gmail.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*        SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*        CLEAR I_ADDRESS_STRING.
*
**     ---------- send document ---------------------------------------
*        SENT_TO_ALL = SEND_REQUEST->SEND( I_WITH_ERROR_SCREEN = 'X' ).
*
*        COMMIT WORK.
*
*        IF SENT_TO_ALL IS INITIAL.
*          MESSAGE I500(SBCOMS).
*        ELSE.
**        MESSAGE s022(so).
*          ES_MSG = 'Email triggered successfully' ."TYPE 'S'.
*        ENDIF.
*
**   ------------ exception handling ----------------------------------
**   replace this rudimentary exception handling with your own one !!!
*      CATCH CX_BCS INTO BCS_EXCEPTION.
*        MESSAGE I865(SO) WITH BCS_EXCEPTION->ERROR_TYPE.
*    ENDTRY.
*
**    ELSE.
*
*
*  ENDIF.
*
**endif.

ENDFUNCTION.
