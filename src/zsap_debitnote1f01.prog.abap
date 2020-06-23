*&---------------------------------------------------------------------*
*& Include          ZSAP_DEBITNOTEF01
*&---------------------------------------------------------------------*

FORM GETDATA.
  SELECT   MBLNR
           MJAHR
           ZEILE
           CHARG
           MATNR
           BWART
           EBELN
           FROM MSEG INTO TABLE IT_MSEG
           WHERE CHARG = LV_BATCH.

  IF IT_MSEG IS NOT INITIAL.

    SELECT  EBELN
            KNUMV
            LIFNR
            AEDAT
            FROM EKKO INTO TABLE IT_EKKO
            FOR ALL ENTRIES IN IT_MSEG
            WHERE EBELN = IT_MSEG-EBELN.


    SELECT EBELN
           EBELP
           MATNR
           MEINS
           MENGE
           NETPR
           BUKRS
           WERKS
           FROM EKPO INTO TABLE IT_EKPO
           FOR ALL ENTRIES IN IT_MSEG
           WHERE EBELN = IT_MSEG-EBELN.

    SELECT QR_CODE
           EBELN
           EBELP
*           SNO
           MATNR
           FROM ZINW_T_ITEM INTO TABLE IT_ZINW_T_ITEM
           FOR ALL ENTRIES IN IT_MSEG
           WHERE EBELN = IT_MSEG-EBELN OR MATNR = IT_MSEG-MATNR.
  ENDIF.

  IF IT_EKPO IS NOT INITIAL.
    SELECT WERKS
           EKORG
           FROM T001W INTO TABLE IT_T001W
           FOR ALL ENTRIES IN IT_EKPO
           WHERE WERKS = IT_EKPO-WERKS.

    SELECT MATNR
           WERKS
           EKGRP
           FROM MARC INTO TABLE IT_MARC
           FOR ALL ENTRIES IN IT_EKPO
           WHERE MATNR = IT_EKPO-MATNR AND WERKS = IT_EKPO-WERKS.

    SELECT MATNR
           MATKL
           FROM MARA INTO TABLE IT_MARA
           FOR ALL ENTRIES IN IT_EKPO
           WHERE MATNR = IT_EKPO-MATNR.

    SELECT MATNR
           WERKS
           LGORT
           FROM MARD INTO TABLE IT_MARD
           FOR ALL ENTRIES IN IT_EKPO
           WHERE MATNR = IT_EKPO-MATNR
           AND WERKS = IT_EKPO-WERKS.

  ENDIF.

  IF IT_EKKO IS NOT INITIAL.

    SELECT KNUMV
           KPOSN
           STUNR
           ZAEHK
           KBETR
           KWERT
           FROM PRCD_ELEMENTS INTO TABLE IT_PRCD_ELEMENTS FOR ALL ENTRIES IN IT_EKKO
           WHERE KNUMV = IT_EKKO-KNUMV.
  ENDIF.

  IF CUSTOM_CONTAINER IS INITIAL.
    CREATE OBJECT CUSTOM_CONTAINER
      EXPORTING
*       PARENT         =     " Parent container
        CONTAINER_NAME = MYCONTAINER. " Name of the Screen CustCtrl Name to Link Container To

    CREATE OBJECT GRID
      EXPORTING
        I_PARENT = CUSTOM_CONTAINER. " Parent Container

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form CHECK_VALID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_VALID .

  IF LV_BATCH IS NOT INITIAL.
*    BREAK-POINT .

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LV_BATCH
      IMPORTING
        OUTPUT = LV_BATCH.

    CLEAR : WA_EKKO , WA_EKPO , WA_MSEG , WA_PRCD_ELEMENTS , WA_ZINW_T_ITEM .
    READ TABLE IT_MSEG INTO WA_MSEG
    WITH KEY CHARG = LV_BATCH.
    IF SY-SUBRC = 0.
      LV_MBLNR = WA_MSEG-MBLNR.

    ENDIF.

    READ TABLE IT_EKKO INTO WA_EKKO
    WITH KEY EBELN = WA_MSEG-EBELN.

    READ TABLE IT_EKPO INTO WA_EKPO
    WITH KEY MATNR = WA_MSEG-MATNR.

    READ TABLE IT_ZINW_T_ITEM INTO WA_ZINW_T_ITEM
    WITH KEY EBELN = WA_MSEG-EBELN.
*    MATNR = WA_MSEG-MATNR.

    IF SY-SUBRC = 0.
      LV_MATNR = WA_ZINW_T_ITEM-MATNR .
      LV_QR_CODE = WA_ZINW_T_ITEM-QR_CODE.
*      LV_BATCH = WA_MSEG-CHARG.
    ENDIF.

    READ TABLE IT_T001W INTO WA_T001W
    WITH KEY WERKS = WA_EKPO-WERKS.

    READ TABLE IT_MARC INTO WA_MARC
    WITH KEY MATNR = WA_EKPO-MATNR
             WERKS = WA_EKPO-WERKS.

    READ TABLE IT_PRCD_ELEMENTS INTO WA_PRCD_ELEMENTS
    WITH KEY KNUMV = WA_EKKO-KNUMV.

    LOOP AT SCREEN.
      IF WA_MSEG-BWART <> '101'.
        SCREEN-INPUT = '0'.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form TABLE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM TABLE_DATA .

  SLNO = SLNO + 1.
  WA_ITEM1-SLNO = SLNO.

  LOOP AT IT_MSEG INTO WA_MSEG WHERE CHARG = LV_BATCH AND BWART = '101'.
    WA_ITEM1-MATNR = WA_MSEG-MATNR.
    WA_ITEM1-CHARG = WA_MSEG-CHARG.

    READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_MSEG-MATNR .
    IF SY-SUBRC = 0.
      WA_ITEM1-MATKL = WA_MARA-MATKL .
    ENDIF.

    READ TABLE IT_MARD INTO WA_MARD WITH KEY MATNR = WA_MSEG-MATNR .
    IF SY-SUBRC = 0.
      WA_ITEM1-LGORT = WA_MARD-LGORT.
    ENDIF.

    READ TABLE IT_EKPO INTO WA_EKPO WITH KEY MATNR = WA_MSEG-MATNR. "EBELN = WA_EKPO-EBELN .
    IF SY-SUBRC = 0.
      WA_ITEM1-MEINS = WA_EKPO-MEINS.
      WA_ITEM1-MENGE  = WA_EKPO-MENGE.
      WA_ITEM1-NETPR = WA_EKPO-NETPR.
    ENDIF.

    READ TABLE IT_PRCD_ELEMENTS INTO WA_PRCD_ELEMENTS WITH KEY KNUMV = WA_EKKO-KNUMV.
    IF SY-SUBRC = 0.
      WA_ITEM1-KBETR = WA_PRCD_ELEMENTS-KBETR / 10.
    ENDIF.
  ENDLOOP.

  APPEND WA_ITEM1 TO IT_ITEM1.
  CLEAR WA_ITEM1.
  SORT IT_ITEM1 BY SLNO DESCENDING.

  LOOP AT IT_ITEM1 INTO WA_ITEM1 WHERE CHARG = LV_BATCH.

    LV_MENGE = LV_MENGE + WA_ITEM1-MENGE.
    WA_ITEM1-MENGE = LV_MENGE.
    WA_ITEM1-KWERT = ( WA_ITEM1-NETPR * WA_ITEM1-MENGE ) * WA_ITEM1-KBETR / 100.
    WA_ITEM1-AMOUNT = ( WA_ITEM1-NETPR * WA_ITEM1-MENGE ) + WA_ITEM1-KWERT.

    MODIFY IT_ITEM1 INDEX 1 FROM WA_ITEM1 TRANSPORTING MENGE.
    MODIFY IT_ITEM1 INDEX 1 FROM WA_ITEM1 TRANSPORTING KWERT.
    MODIFY IT_ITEM1 INDEX 1 FROM WA_ITEM1 TRANSPORTING AMOUNT.
    CLEAR WA_ITEM1.

  ENDLOOP.

  CLEAR: LV_MENGE.
  SORT IT_ITEM1 BY CHARG.
  DELETE ADJACENT DUPLICATES FROM IT_ITEM1 COMPARING CHARG.

  LOOP AT IT_ITEM1 INTO WA_ITEM1 WHERE CHARG = LV_BATCH.
    WA_ITEM1-SLNO = SY-TABIX.
    MODIFY IT_ITEM1 INDEX SY-TABIX FROM WA_ITEM1 TRANSPORTING SLNO.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form EXCLUDE_ICONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_ICONS .
  IF GT_TLBR_EXCL IS NOT INITIAL.
    RETURN.
  ENDIF.

  GS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND GS_EXCLUDE TO GT_TLBR_EXCL.
  CLEAR : GS_EXCLUDE.

  GS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND GS_EXCLUDE TO GT_TLBR_EXCL.
  CLEAR : GS_EXCLUDE.

  GS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND GS_EXCLUDE TO GT_TLBR_EXCL.
  CLEAR : GS_EXCLUDE.

  GS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND GS_EXCLUDE TO GT_TLBR_EXCL.
  CLEAR : GS_EXCLUDE.

  GS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND GS_EXCLUDE TO GT_TLBR_EXCL.
  CLEAR : GS_EXCLUDE.

  GS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND GS_EXCLUDE TO GT_TLBR_EXCL.
  CLEAR : GS_EXCLUDE.

  GS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND GS_EXCLUDE TO GT_TLBR_EXCL.
  CLEAR : GS_EXCLUDE.

  GS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND GS_EXCLUDE TO GT_TLBR_EXCL.
  CLEAR : GS_EXCLUDE.

ENDFORM.

FORM DISPLAYDATA.

  IF GI_FIELDCAT IS NOT INITIAL.
    REFRESH : GI_FIELDCAT[].
    GS_LAYOUT-FRONTEND = 'X'.
  ENDIF.

  GS_FIELDCAT-FIELDNAME   = 'SLNO'.
  GS_FIELDCAT-REPTEXT     = 'SLNO'.
  GS_FIELDCAT-COL_OPT     = 'X'.
  GS_FIELDCAT-TXT_FIELD   = 'X'.
  GS_FIELDCAT-OUTPUTLEN = 15.
  APPEND GS_FIELDCAT TO GI_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME   = 'MATNR'.
  GS_FIELDCAT-REPTEXT     = 'SST Code'.
  GS_FIELDCAT-COL_OPT     = 'X'.
  GS_FIELDCAT-TXT_FIELD   = 'X'.
*  GS_FIELDCAT-EDIT        = 'X'.
  GS_FIELDCAT-OUTPUTLEN = 15.
  APPEND GS_FIELDCAT TO GI_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME   = 'CHARG'.
  GS_FIELDCAT-REPTEXT     = 'Batch'.
  GS_FIELDCAT-COL_OPT     = 'X'.
  GS_FIELDCAT-TXT_FIELD   = 'X'.
*  GS_FIELDCAT-EDIT        = 'X'.
  GS_FIELDCAT-OUTPUTLEN = 15.
  APPEND GS_FIELDCAT TO GI_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME   = 'MENGE'.
  GS_FIELDCAT-REPTEXT     = 'QTY'.
  GS_FIELDCAT-COL_OPT     = 'X'.
  GS_FIELDCAT-TXT_FIELD   = 'X'.
*  GS_FIELDCAT-EDIT        = 'X'.
  GS_FIELDCAT-OUTPUTLEN = 15.
  APPEND GS_FIELDCAT TO GI_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME   = 'NETPR'.
  GS_FIELDCAT-REPTEXT     = 'Rate'.
  GS_FIELDCAT-COL_OPT     = 'X'.
  GS_FIELDCAT-TXT_FIELD   = 'X'.
*  GS_FIELDCAT-EDIT        = 'X'.
  GS_FIELDCAT-OUTPUTLEN = 15.
  APPEND GS_FIELDCAT TO GI_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME   = 'KBETR'.
  GS_FIELDCAT-REPTEXT     = 'GST %'.
  GS_FIELDCAT-COL_OPT     = 'X'.
  GS_FIELDCAT-TXT_FIELD   = 'X'.
*  GS_FIELDCAT-EDIT        = 'X'.
  GS_FIELDCAT-OUTPUTLEN = 15.
  APPEND GS_FIELDCAT TO GI_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME   = 'KWERT'.
  GS_FIELDCAT-REPTEXT     = 'GST Value'.
  GS_FIELDCAT-COL_OPT     = 'X'.
  GS_FIELDCAT-TXT_FIELD   = 'X'.
*  GS_FIELDCAT-EDIT        = 'X'.
  GS_FIELDCAT-OUTPUTLEN = 15.
  APPEND GS_FIELDCAT TO GI_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME   = 'AMOUNT'.
  GS_FIELDCAT-REPTEXT     = 'Total Amount'.
  GS_FIELDCAT-COL_OPT     = 'X'.
  GS_FIELDCAT-TXT_FIELD   = 'X'.
*  GS_FIELDCAT-EDIT        = 'X'.
  GS_FIELDCAT-OUTPUTLEN = 15.
  APPEND GS_FIELDCAT TO GI_FIELDCAT.
  CLEAR GS_FIELDCAT.

  CREATE OBJECT LR_EVENT.
  SET HANDLER LR_EVENT->HANDLE_TOOLBAR_SET   FOR GRID.
  SET HANDLER LR_EVENT->HANDLE_USER_COMMAND  FOR GRID.


  CALL METHOD GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*     I_BUFFER_ACTIVE               =     " Buffering Active
*     I_BYPASSING_BUFFER            =     " Switch Off Buffer
*     I_CONSISTENCY_CHECK           =     " Starting Consistency Check for Interface Error Recognition
*     I_STRUCTURE_NAME              =     " Internal Output Table Structure Name
*     IS_VARIANT                    =     " Layout
*     I_SAVE                        =     " Save Layout
*     I_DEFAULT                     = 'X'    " Default Display Variant
      IS_LAYOUT                     = GS_LAYOUT " Layout
*     IS_PRINT                      =     " Print Control
*     IT_SPECIAL_GROUPS             =     " Field Groups
      IT_TOOLBAR_EXCLUDING          = GT_TLBR_EXCL   " Excluded Toolbar Standard Functions
*     IT_HYPERLINK                  =     " Hyperlinks
*     IT_ALV_GRAPHICS               =     " Table of Structure DTC_S_TC
*     IT_EXCEPT_QINFO               =     " Table for Exception Quickinfo
*     IR_SALV_ADAPTER               =     " Interface ALV Adapter
    CHANGING
      IT_OUTTAB                     = IT_ITEM1 " Output Table
      IT_FIELDCATALOG               = GI_FIELDCAT  " Field Catalog
*     IT_SORT                       =     " Sort Criteria
*     IT_FILTER                     =     " Filter Criteria
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

  CALL METHOD GRID->SET_READY_FOR_INPUT
    EXPORTING
      I_READY_FOR_INPUT = 1.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

FORM BACK_FUN.
  CASE SY-UCOMM.
    WHEN 'SAVE'.
      PERFORM CREATE_DEBIT.

    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form CREATE_DEBIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*

FORM CREATE_DEBIT .
*  BREAK DDASH.

  IT_ITEM2 = IT_ITEM1.
  WA_ITEM2 = WA_ITEM1.

  IF LV_EBELN IS INITIAL .

    HEADER-COMP_CODE = WA_EKPO-BUKRS . "'1000'.
    HEADER-CREAT_DATE = WA_EKKO-AEDAT .
    HEADER-VENDOR = WA_EKKO-LIFNR .
    HEADER-DOC_TYPE = 'ZDOM' .
    HEADER-LANGU = SY-LANGU .
    HEADER-PURCH_ORG = WA_T001W-EKORG  .
    HEADER-PUR_GROUP =  WA_MARC-EKGRP . "'001' .

    HEADERX-COMP_CODE =  'X'.
    HEADERX-CREAT_DATE = 'X'.
    HEADERX-VENDOR = 'X'.
    HEADERX-DOC_TYPE = 'X' .
    HEADERX-LANGU = 'X' .
    HEADERX-PURCH_ORG = 'X' .
    HEADERX-PUR_GROUP = 'X'.

    REFRESH ITEM .
    REFRESH ITEMX .

*    LOOP AT IT_ITEM1 INTO WA_ITEM1 .
    LOOP AT IT_ITEM2 INTO WA_ITEM2 .
*      ITEM-PO_ITEM = WA_ITEM1-SLNO .
      ITEM-PO_ITEM = WA_ITEM2-SLNO .

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = WA_ITEM2-MATNR
        IMPORTING
          OUTPUT = WA_ITEM2-MATNR.

*      ITEM-MATERIAL = WA_ITEM1-MATNR .
      ITEM-MATERIAL = WA_ITEM2-MATNR .
      ITEM-PLANT = WA_EKPO-WERKS.
      ITEM-MATL_GROUP = WA_MARA-MATKL.
*      ITEM-QUANTITY = WA_ITEM1-MENGE.
      ITEM-QUANTITY = WA_ITEM2-MENGE.
*      ITEM-PO_UNIT = WA_ITEM1-MEINS .
      ITEM-PO_UNIT = WA_ITEM2-MEINS .
*      ITEM-NET_PRICE = WA_ITEM1-NETPR.
      ITEM-NET_PRICE = WA_ITEM2-NETPR.
      ITEM-STGE_LOC = WA_MARD-LGORT.
      ITEM-RET_ITEM = 'X'.


*      ITEMX-PO_ITEM = WA_ITEM1-SLNO.
      ITEMX-PO_ITEM = WA_ITEM2-SLNO.
      ITEMX-MATERIAL = 'X'.
      ITEMX-PLANT = 'X'.
      ITEMX-MATL_GROUP = 'X'.
      ITEMX-QUANTITY = 'X'.
      ITEMX-PO_UNIT = 'X'.
      ITEMX-NET_PRICE = 'X'.
      ITEMX-STGE_LOC = 'X'.
      ITEMX-RET_ITEM = 'X'.
      APPEND ITEM.
      CLEAR ITEM .
      APPEND ITEMX .
      CLEAR ITEMX.

    ENDLOOP.

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
*       NO_PRICE_FROM_PO =
*       PARK_COMPLETE    =
*       PARK_UNCOMPLETE  =
      IMPORTING
        EXPPURCHASEORDER = LV_EBELN
*       EXPHEADER        =
*       EXPPOEXPIMPHEADER            =
      TABLES
        RETURN           = RETURN
        POITEM           = ITEM
        POITEMX          = ITEMX
*       POADDRDELIVERY   =
*       POSCHEDULE       = POSCHEDULE
*       POSCHEDULEX      = POSCHEDULEx
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
*       POSERVICESTEXT   =
*       EXTENSIONIN      = it_extensionin
*       EXTENSIONOUT     =
*       POEXPIMPITEM     =
*       POEXPIMPITEMX    =
*       POTEXTHEADER     =
*       POTEXTITEM       =
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

    DELETE RETURN WHERE TYPE <> 'E'.
    READ TABLE RETURN INTO WA_RETURN INDEX 1.
    IF WA_RETURN-TYPE = 'E'.
      MESSAGE WA_RETURN-MESSAGE  TYPE 'E' DISPLAY LIKE 'E' .
    ENDIF.

    IF LV_EBELN IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ''
*   IMPORTING
*         RETURN        =
        .
      CONCATENATE 'Purchase Order No.' LV_EBELN 'is created' INTO LV_SUC SEPARATED BY ' '.
      MESSAGE LV_SUC  TYPE 'S' DISPLAY LIKE 'I' .
    ENDIF.
  ELSE.
    MESSAGE 'Purchase Order is already Created' TYPE 'E' DISPLAY LIKE 'I' .
  ENDIF.
  EXIT.
ENDFORM.
