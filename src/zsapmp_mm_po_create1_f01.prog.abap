*&---------------------------------------------------------------------*
*& Include          ZSAPMP_MM_PO_CREATE1_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
*BREAK-POINT.
  SELECT MATNR
        SPRAS
        MAKTX
        FROM MAKT INTO TABLE IT_MAKT .
  IF IT_MAKT IS NOT INITIAL .
    SELECT MATNR
            MATKL
            MEINS
            TAKLV FROM MARA INTO TABLE IT_MARA
            FOR ALL ENTRIES IN IT_MAKT
            WHERE MATNR = IT_MAKT-MATNR .
    SELECT MATNR
           WERKS
           STEUC FROM MARC INTO TABLE IT_MARC
           FOR ALL ENTRIES IN IT_MAKT
           WHERE MATNR = IT_MAKT-MATNR .

  ENDIF.

*  IF IT_MARC IS NOT INITIAL .
*    SELECT KAPPL
*           KSCHL
*           WKREG
*           REGIO
*           TAXK1
*           TAXM1
*           STEUC
*           KFRST
*           DATBI
*           DATAB
*           KBSTAT
*           KNUMH FROM A900 INTO TABLE IT_A900
*         FOR ALL ENTRIES IN IT_MARC
*         WHERE STEUC = IT_MARC-STEUC
*         AND DATBI GE SY-DATUM .
*
*
*  ENDIF.
*
*  IF IT_A792 IS NOT INITIAL.
*    SELECT KNUMH
*           KOPOS
*           KAPPL
*           KSCHL
*           KBETR
*           LOEVM_KO FROM KONP INTO TABLE IT_KONP
*          FOR ALL ENTRIES IN IT_A792
*      WHERE KNUMH = IT_A792-KNUMH.
*  ENDIF.

  SELECT * FROM T023T INTO TABLE IT_T023T .
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

*  GS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
*  APPEND GS_EXCLUDE TO GT_TLBR_EXCL.
*  CLEAR : GS_EXCLUDE.

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

  GS_EXCLUDE = CL_GUI_ALV_GRID=>mc_lystyle_no_delete_rows .
  APPEND GS_EXCLUDE TO GT_TLBR_EXCL.
  CLEAR : GS_EXCLUDE.


  GS_EXCLUDE = CL_GUI_ALV_GRID=>mc_lystyle_no_insert_rows .
  APPEND GS_EXCLUDE TO GT_TLBR_EXCL.
  CLEAR : GS_EXCLUDE.

    GS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW .
  APPEND GS_EXCLUDE TO GT_TLBR_EXCL.
  CLEAR : GS_EXCLUDE.



ENDFORM.



*&---------------------------------------------------------------------*
*& Form FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FIELD_CATALOG .
*** Test
PERFORM EXCLUDE_ICONS  .
*  DATA: LS_SORT TYPE LVC_S_SORT.
*  DATA: LT_SORT TYPE TABLE OF LVC_S_SORT.
**  REFRESH : LT_SORT.
*  LS_SORT-FIELDNAME = 'SL_NO'.
*  LS_SORT-up = 'X'.
*  LS_SORT-SPOS = 00.
*  APPEND LS_SORT TO LT_SORT.
*
*  CALL METHOD GRID->SET_SORT_CRITERIA
*    EXPORTING
*      IT_SORT                   =   lt_sort  " Sort Criteria
*    EXCEPTIONS
*      NO_FIELDCATALOG_AVAILABLE = 1
*      OTHERS                    = 2
*    .

  IF GRID IS BOUND.
*      SORT IT_ITEM DESCENDING BY SL_NO .
    IF GI_FIELDCAT IS NOT INITIAL.
      REFRESH : GI_FIELDCAT[].
      GS_LAYOUT-FRONTEND = 'X'.
*      GS_LAYOUT-COL_OPT = 'X'.
      GS_LAYOUT-ZEBRA = 'X'.
*      GS_LAYOUT-GRID_TITLE = 'PO Item Details'.
    ENDIF.


***ITEM NUMBER*****
    GS_FIELDCAT-FIELDNAME   = 'SL_NO'.
    GS_FIELDCAT-REPTEXT     = 'PO ITEM'.
    GS_FIELDCAT-COL_OPT     = 'X'.
    GS_FIELDCAT-TXT_FIELD   = 'X'.
*    GS_FIELDCAT-EDIT        = 'X'.
*    GS_FIELDCAT-OUTPUTLEN = 10.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.
***Parent code*****
    GS_FIELDCAT-FIELDNAME   = 'PARENT_CODE'.
    GS_FIELDCAT-REPTEXT     = 'Parent Code'.
*    GS_FIELDCAT-COL_OPT     = 'X'.
    GS_FIELDCAT-TXT_FIELD   = 'X'.
    GS_FIELDCAT-EDIT        = 'X'.
    GS_FIELDCAT-OUTPUTLEN = 10.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.

**********MATERIAL GROUP**********
    GS_FIELDCAT-FIELDNAME   = 'MATKL'.
    GS_FIELDCAT-REPTEXT     = 'Material Group'.
    GS_FIELDCAT-F4AVAILABL = 'X'.

    GS_FIELDCAT-COL_OPT     = 'X'.
    GS_FIELDCAT-TXT_FIELD   = 'X'.
    GS_FIELDCAT-EDIT        = 'X'.
    GS_FIELDCAT-OUTPUTLEN = 10.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.

***Material*****
    GS_FIELDCAT-FIELDNAME   = 'MATNR'.
    GS_FIELDCAT-REPTEXT     = 'Material Code'.
    GS_FIELDCAT-F4AVAILABL = 'X'.
*    GS_FIELDCAT-COL_OPT     = 'X'.
    GS_FIELDCAT-TXT_FIELD   = 'X'.
    GS_FIELDCAT-EDIT        = 'X'.
    GS_FIELDCAT-REF_TABLE = 'MAKT' .
    GS_FIELDCAT-OUTPUTLEN = 10.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.
***hsn*****
    GS_FIELDCAT-FIELDNAME   = 'STEUC'.
    GS_FIELDCAT-REPTEXT     = 'HSN Code'.
    GS_FIELDCAT-COL_OPT     = 'X'.
*    GS_FIELDCAT-TXT_FIELD   = 'X'.
*    GS_FIELDCAT-EDIT        = 'X'.
    GS_FIELDCAT-OUTPUTLEN = 10.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.
***Material description*****
    GS_FIELDCAT-FIELDNAME   = 'MAKTX'.
    GS_FIELDCAT-REPTEXT     = 'Category Description'.
*    GS_FIELDCAT-COL_OPT     = 'X'.
    GS_FIELDCAT-TXT_FIELD   = 'X'.
*    GS_FIELDCAT-EDIT        = 'X'.
    GS_FIELDCAT-OUTPUTLEN = 40.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.
***qty*****
    GS_FIELDCAT-FIELDNAME   = 'MENGE'.
*    GS_FIELDCAT-DATATYPE = 'QUAN'.
    GS_FIELDCAT-REPTEXT     = 'Qty'.
    GS_FIELDCAT-COL_OPT     = 'X'.
*    GS_FIELDCAT-QFIELDNAME = 'MEINS'.
*    GS_FIELDCAT-DECIMALS_O    = '2'.
*    GS_FIELDCAT-REF_TABLE = 'EKPO'.
*    GS_FIELDCAT-TXT_FIELD   = 'X'.
    GS_FIELDCAT-EDIT        = 'X'.
    GS_FIELDCAT-OUTPUTLEN = 10.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.
***unit*****
    GS_FIELDCAT-FIELDNAME   = 'MEINS'.
    GS_FIELDCAT-REPTEXT     = 'UOM'.
    GS_FIELDCAT-COL_OPT     = 'X'.
    GS_FIELDCAT-TXT_FIELD   = 'X'.
*    GS_FIELDCAT-EDIT        = 'X'.
    GS_FIELDCAT-OUTPUTLEN = 10.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.
***MRP*****
    GS_FIELDCAT-FIELDNAME   = 'MRP'.
    GS_FIELDCAT-DATATYPE = 'KBETR_KOND'.
    GS_FIELDCAT-REPTEXT     = 'MRP'.
*    GS_FIELDCAT-COL_OPT     = 'X'.
    GS_FIELDCAT-DECIMALS_O    = '2'.
*    GS_FIELDCAT-DECMLFIELD = 'X'.
*    GS_FIELDCAT-TXT_FIELD   = 'X'.
*   GS_FIELDCAT-REF_TABLE = 'KONP'.
    GS_FIELDCAT-EDIT        = 'X'.
    GS_FIELDCAT-OUTPUTLEN = 7.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.
***DISCOUNT 1*****
    GS_FIELDCAT-FIELDNAME   = 'DISC1'.
    GS_FIELDCAT-DATATYPE = 'KBETR_KOND'.
    GS_FIELDCAT-REPTEXT     = 'DISC1'.
*    GS_FIELDCAT-COL_OPT     = 'X'.
*    GS_FIELDCAT-TXT_FIELD   = 'X'.
*    GS_FIELDCAT-EDIT        = 'X'.
    GS_FIELDCAT-OUTPUTLEN = 5.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.
***DISCOUNT 2*****
    GS_FIELDCAT-FIELDNAME   = 'DISC2'.
    GS_FIELDCAT-DATATYPE = 'KBETR_KOND'.
    GS_FIELDCAT-REPTEXT     = 'DISC2'.
*    GS_FIELDCAT-COL_OPT     = 'X'.
*    GS_FIELDCAT-TXT_FIELD   = 'X'.
*    GS_FIELDCAT-EDIT        = 'X'.
    GS_FIELDCAT-OUTPUTLEN = 5.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.
***DISCOUNT 3*****
    GS_FIELDCAT-FIELDNAME   = 'DISC3'.
    GS_FIELDCAT-DATATYPE = 'KBETR_KOND'.
    GS_FIELDCAT-REPTEXT     = 'DISC3'.
*    GS_FIELDCAT-COL_OPT     = 'X'.
*    GS_FIELDCAT-TXT_FIELD   = 'X'.
*    GS_FIELDCAT-EDIT        = 'X'.
    GS_FIELDCAT-OUTPUTLEN = 5.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.
***DISCOUNT 4*****
    GS_FIELDCAT-FIELDNAME   = 'DISC4'.
    GS_FIELDCAT-DATATYPE = 'KBETR_KOND'.
    GS_FIELDCAT-REPTEXT     = 'DISC4'.
*    GS_FIELDCAT-COL_OPT     = 'X'.
    GS_FIELDCAT-DATATYPE = 'CURR'.
*        gs_fieldcat-REF_TABLE = 'EKkO'.
*    GS_FIELDCAT-TXT_FIELD   = 'X'.
    GS_FIELDCAT-EDIT        = 'X'.
    GS_FIELDCAT-OUTPUTLEN = 5.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.
***net price*****
    GS_FIELDCAT-FIELDNAME   = 'NETPR'.
    GS_FIELDCAT-DATATYPE = 'NETPR'.
    GS_FIELDCAT-REPTEXT     = 'Net Price'.
*    GS_FIELDCAT-COL_OPT     = 'X'.
*    GS_FIELDCAT-TXT_FIELD   = 'X'.
*    GS_FIELDCAT-EDIT        = 'X'.
    GS_FIELDCAT-OUTPUTLEN = 10.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.
***Amount*****
    GS_FIELDCAT-FIELDNAME   = 'AMOUNT'.
    GS_FIELDCAT-REPTEXT     = 'AMOUNT'.
*    GS_FIELDCAT-COL_OPT     = 'X'.
*    GS_FIELDCAT-TXT_FIELD   = 'X'.
*    GS_FIELDCAT-EDIT        = 'X'.
    GS_FIELDCAT-OUTPUTLEN = 10.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.
*****GST*****
    GS_FIELDCAT-FIELDNAME   = 'GST%'.
    GS_FIELDCAT-REPTEXT     = 'GST%'.
*    GS_FIELDCAT-COL_OPT     = 'X'.
*    GS_FIELDCAT-TXT_FIELD   = 'X'.
*    GS_FIELDCAT-EDIT        = 'X'.
    GS_FIELDCAT-OUTPUTLEN = 7.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.
***GST VALUE****
    GS_FIELDCAT-FIELDNAME   = 'GST'.
    GS_FIELDCAT-REPTEXT     = 'GST Value'.
*    GS_FIELDCAT-COL_OPT     = 'X'.
*    GS_FIELDCAT-TXT_FIELD   = 'X'.
*    GS_FIELDCAT-EDIT        = 'X'.
    GS_FIELDCAT-OUTPUTLEN = 10.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.
***TOTAL ****
    GS_FIELDCAT-FIELDNAME   = 'TOTAL'.
    GS_FIELDCAT-REPTEXT     = 'Total'.
*    GS_FIELDCAT-COL_OPT     = 'X'.
*    GS_FIELDCAT-TXT_FIELD   = 'X'.
*    GS_FIELDCAT-EDIT        = 'X'.
    GS_FIELDCAT-OUTPUTLEN = 10.
    APPEND GS_FIELDCAT TO GI_FIELDCAT.
    CLEAR GS_FIELDCAT.
*BREAK-POINT.
*PERFORM EXCLUDE_ICONS .
*REFRESH it_item .
    IF IT_ITEM IS INITIAL .
      DO 500 TIMES.
        WA_ITEM-SL_NO = 10 + WA_ITEM-SL_NO .
        APPEND  wa_item TO IT_ITEM  .

      ENDDO.
*      WA_ITEM-SL_NO = 10 .
      clear wa_item .
    ENDIF.

*    IF IT_ITEM IS not INITIAL .
*      REFRESH it_item1 .
*      it_item1[] = it_item .
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

*      WA_ITEM-SL_NO = 10 .
*      clear wa_item .
*    ENDIF.

    CALL METHOD GRID->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
*       I_BUFFER_ACTIVE               =     " Buffering Active
*       I_BYPASSING_BUFFER            =     " Switch Off Buffer
*       I_CONSISTENCY_CHECK           =     " Starting Consistency Check for Interface Error Recognition
*       I_STRUCTURE_NAME              =     " Internal Output Table Structure Name
*       IS_VARIANT                    =     " Layout
*       I_SAVE                        =     " Save Layout
*       I_DEFAULT                     = 'X'    " Default Display Variant
        IS_LAYOUT                     = GS_LAYOUT " Layout
*       IS_PRINT                      =     " Print Control
*       IT_SPECIAL_GROUPS             =     " Field Groups
       IT_TOOLBAR_EXCLUDING          = GT_TLBR_EXCL   " Excluded Toolbar Standard Functions
*       IT_HYPERLINK                  =     " Hyperlinks
*       IT_ALV_GRAPHICS               =     " Table of Structure DTC_S_TC
*       IT_EXCEPT_QINFO               =     " Table for Exception Quickinfo
*       IR_SALV_ADAPTER               =     " Interface ALV Adapter
      CHANGING
        IT_OUTTAB                     = IT_ITEM " Output Table
        IT_FIELDCATALOG               = GI_FIELDCAT  " Field Catalog
*       IT_SORT                       = LT_SORT   " Sort Criteria
*       IT_FILTER                     =     " Filter Criteria
      EXCEPTIONS
        INVALID_PARAMETER_COMBINATION = 1
        PROGRAM_ERROR                 = 2
        TOO_MANY_LINES                = 3
        OTHERS                        = 4.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.


*BREAK-POINT.
    CALL METHOD GRID->SET_READY_FOR_INPUT
      EXPORTING
        I_READY_FOR_INPUT = 1.

    CALL METHOD GRID->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED
      EXCEPTIONS
        ERROR      = 1
        OTHERS     = 2.
    IF G_VERIFIER1 IS NOT BOUND.
      CREATE OBJECT G_VERIFIER1.
    ENDIF.
    SET HANDLER G_VERIFIER1->HANDLE_DATA_CHANGED FOR GRID.

*    BREAK-POINT.

      DATA: LS_SORT TYPE LVC_S_SORT.
    DATA: LT_SORT TYPE TABLE OF LVC_S_SORT.
*  REFRESH : LT_SORT.
    LS_SORT-FIELDNAME = 'SL_NO'.
    LS_SORT-UP = 'X'.
    LS_SORT-SPOS = 00.
    APPEND LS_SORT TO LT_SORT.

    CALL METHOD GRID->SET_SORT_CRITERIA
      EXPORTING
        IT_SORT                   = LT_SORT  " Sort Criteria
      EXCEPTIONS
        NO_FIELDCATALOG_AVAILABLE = 1
        OTHERS                    = 2.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI .

  IF LV_EBELN IS INITIAL AND WA_HEADER-AEDAT1 IS NOT INITIAL AND WA_HEADER-EKGRP IS NOT INITIAL AND WA_HEADER-SITE IS NOT INITIAL AND WA_HEADER-LGORT IS NOT INITIAL . .


*    BREAK-POINT.
    DELETE IT_ITEM WHERE SL_NO IS INITIAL AND MATNR IS NOT INITIAL .
*    SORT IT_ITEM ASCENDING BY SL_NO .
    HEADER-COMP_CODE = WA_T001K-BUKRS . "'1000'.
    HEADER-CREAT_DATE = WA_HEADER-AEDAT .
    HEADER-VENDOR = WA_HEADER-LIFNR .
    HEADER-DOC_TYPE = 'ZDOM' .
    HEADER-LANGU = SY-LANGU .
    HEADER-PURCH_ORG = WA_T001W-EKORG  .
    HEADER-PUR_GROUP =  WA_HEADER-EKGRP . "'001' .

    HEADERX-COMP_CODE =  'X'.
    HEADERX-CREAT_DATE = 'X'.
    HEADERX-VENDOR = 'X'.
    HEADERX-DOC_TYPE = 'X' .
    HEADERX-LANGU = 'X' .
    HEADERX-PURCH_ORG = 'X' .
    HEADERX-PUR_GROUP = 'X'.

*BREAK-POINT.
**IT1_BAPI_POHEADER-PO_NUMBER = '' .
**IT1_BAPI_POHEADERX-PO_NUMBER = ''.
*it1_bapi_poheader-agent_name = wa_header-agent_name .
*it1_bapi_poheaderx-agent_name = 'X'.
*
*wa_extensionin-structure = 'BAPI_TE_MEPOHEADER'.
*wa_extensionin-valuepart1 = it1_bapi_poheader.
*append wa_extensionin to it_extensionin.
*Clear  wa_extensionin.
*
*wa_extensionin-structure = 'BAPI_TE_MEPOHEADERX'.
*wa_extensionin-valuepart1 = it1_bapi_poheaderx.
*
*append wa_extensionin to it_extensionin.
*Clear  wa_extensionin.


*BREAK-POINT.
    REFRESH ITEM .
    REFRESH ITEMX .
    data it_tax type ztax_t .
    data wa_tax type ZTAX_S .
    DATA I_MATNR TYPE MATNR18  .
    IT_ITEM1[] = IT_ITEM[].
    DELETE IT_ITEM1 WHERE MATNR IS INITIAL .
    LOOP AT IT_ITEM INTO WA_ITEM WHERE MATNR IS NOT INITIAL .
      ITEM-PO_ITEM = WA_ITEM-SL_NO .

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = WA_ITEM-MATNR
        IMPORTING
          OUTPUT = WA_ITEM-MATNR.



      ITEM-MATERIAL = WA_ITEM-MATNR .
      ITEM-PLANT = WA_HEADER-SITE.
      ITEM-MATL_GROUP = WA_ITEM-MATKL_C.
      ITEM-QUANTITY = WA_ITEM-MENGE.
      ITEM-PO_UNIT = WA_ITEM-MEINS .
      ITEM-NET_PRICE = WA_ITEM-NETPR.
      ITEM-STGE_LOC = WA_HEADER-LGORT .
      ITEM-TAX_CODE = WA_ITEM-TAX_CODE .


      ITEMX-PO_ITEM = WA_ITEM-SL_NO.
      ITEMX-MATERIAL = 'X'.
      ITEMX-PLANT = 'X'.
      ITEMX-MATL_GROUP = 'X'.
      ITEMX-QUANTITY = 'X'.
      ITEMX-PO_UNIT = 'X'.
      ITEMX-NET_PRICE = 'X'.
      ITEMX-STGE_LOC = 'X'.
      ITEMX-TAX_CODE = 'X' .
      APPEND ITEM.
      CLEAR ITEM .
      APPEND ITEMX .
      CLEAR ITEMX.
      I_MATNR = WA_ITEM-MATNR .
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT         =  I_MATNR
       IMPORTING
         OUTPUT        =  WA_ITEM-MATNR
                .
        I_MATNR = WA_ITEM-MATNR  .
        BREAK BREDDY .
      call METHOD ZCL_GST=>GET_GST_PER
                EXPORTING
                  I_MATNR =    WA_ITEM-MATNR " Material Number
                  I_LIFNR =   WA_lfa1-LIFNR   " Account Number of Vendor or Creditor
                IMPORTING
                  ET_TAX  =  it_tax  " Tax Table type
                .

      LOOP AT it_tax into wa_tax .
          ibapicond-itm_number   = WA_ITEM-SL_NO.
          ibapicond-cond_type    = WA_TAX-COND_TYPE .
          ibapicond-cond_value   = WA_TAX-TAX .
          ibapicond-currency     = wa_t500w-WAERS .
          ibapicond-CHANGE_ID     = 'U' .

          ibapicondx-itm_number  = WA_ITEM-SL_NO .
          ibapicondx-cond_type   =  WA_TAX-COND_TYPE .
          ibapicondx-cond_value  = 'X'.
          ibapicondx-currency    = 'X'.
            ibapicondX-CHANGE_ID     = 'X' .
          APPEND ibapicond .
          APPEND ibapicondx.
      ENDLOOP.
    ENDLOOP.

    CLEAR RETURN .
    IF IT_ITEM1 IS NOT INITIAL .


      CALL FUNCTION 'BAPI_PO_CREATE1'
        EXPORTING
          POHEADER         = HEADER
          POHEADERX        = HEADERX
*         POADDRVENDOR     =
*         TESTRUN          =
*         MEMORY_UNCOMPLETE            =
*         MEMORY_COMPLETE  =
*         POEXPIMPHEADER   =
*         POEXPIMPHEADERX  =
*         VERSIONS         =
*         NO_MESSAGING     =
*         NO_MESSAGE_REQ   =
*         NO_AUTHORITY     =
*         NO_PRICE_FROM_PO =
*         PARK_COMPLETE    =
*         PARK_UNCOMPLETE  =
        IMPORTING
          EXPPURCHASEORDER = LV_EBELN
*         EXPHEADER        =
*         EXPPOEXPIMPHEADER            =
        TABLES
          RETURN           = RETURN
          POITEM           = ITEM
          POITEMX          = ITEMX
*         POADDRDELIVERY   =
*         POSCHEDULE       = POSCHEDULE
*         POSCHEDULEX      = POSCHEDULEx
*         POACCOUNT        =
*         POACCOUNTPROFITSEGMENT       =
*         POACCOUNTX       =
*         POCONDHEADER     =
*         POCONDHEADERX    =
         POCOND           = ibapicond
         POCONDX          = ibapicondX
*         POLIMITS         =
*         POCONTRACTLIMITS =
*         POSERVICES       =
*         POSRVACCESSVALUES            =
*         POSERVICESTEXT   =
*         EXTENSIONIN      = it_extensionin
*         EXTENSIONOUT     =
*         POEXPIMPITEM     =
*         POEXPIMPITEMX    =
*         POTEXTHEADER     =
*         POTEXTITEM       =
*         ALLVERSIONS      =
*         POPARTNER        =
*         POCOMPONENTS     =
*         POCOMPONENTSX    =
*         POSHIPPING       =
*         POSHIPPINGX      =
*         POSHIPPINGEXP    =
*         SERIALNUMBER     =
*         SERIALNUMBERX    =
*         INVPLANHEADER    =
*         INVPLANHEADERX   =
*         INVPLANITEM      =
*         INVPLANITEMX     =
*         NFMETALLITMS     =
        .

      DELETE  RETURN WHERE TYPE <> 'E'.
      READ TABLE RETURN INTO WA_RETURN INDEX 1.
      IF WA_RETURN-TYPE = 'E'.
        MESSAGE WA_RETURN-MESSAGE  TYPE 'E' DISPLAY LIKE 'E' .
      ENDIF.

      IF LV_EBELN IS NOT INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ''
*   IMPORTING
*           RETURN        =
          .
        CONCATENATE 'Purchase Order No.' LV_EBELN 'is created' INTO LV_SUC SEPARATED BY ' '.
        WA_HEADER-EBELN = LV_EBELN .
        MESSAGE LV_SUC  TYPE 'S' DISPLAY LIKE 'I' .
      ELSEIF LV_EBELN IS NOT INITIAL .
        MESSAGE 'Purchase Order is already Created' TYPE 'E' DISPLAY LIKE 'I' .

      ENDIF.

    ELSE.
      MESSAGE 'Enter Items to create purchase order ' TYPE 'I' DISPLAY LIKE 'E' .
    ENDIF.

  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ADDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ADDR .
*  sort it_item .
  CLEAR WA_HEADER-CADDR .
  IF WA_HEADER-SITE IS NOT INITIAL ."and WA_HEADER-CADDR is INITIAL .
    CLEAR WA_HEADER-CADDR .
    SELECT SINGLE WERKS
           ADRNR
           EKORG
           REGIO FROM T001W INTO WA_T001W
           WHERE WERKS = WA_HEADER-SITE.
    IF WA_T001W IS NOT INITIAL .
      SELECT SINGLE ADDRNUMBER
               DATE_FROM
               NATION
               NAME1
               CITY1
               POST_CODE1
               STREET
               COUNTRY
               REGION
               STR_SUPPL1
               STR_SUPPL2 FROM ADRC INTO WA_ADRC
               WHERE ADDRNUMBER  = WA_T001W-ADRNR .

      SELECT SINGLE BWKEY
                    BUKRS FROM T001K INTO WA_T001K
                    WHERE BWKEY = WA_T001W-WERKS .


      SELECT SINGLE * FROM T026Z INTO WA_T026Z WHERE EKORG = WA_T001W-EKORG .
    ENDIF.

    IF WA_ADRC-STREET IS NOT INITIAL.
      WA_HEADER-CADDR = WA_ADRC-STREET.
*    CONCATENATE  WA_HEADER-vADDR WA_ADRC1-STREET  INTO WA_HEADER-VADDR SEPARATED BY ',' .
    ENDIF.
    IF WA_ADRC-CITY1 IS NOT INITIAL AND WA_HEADER-CADDR IS NOT INITIAL .
      CONCATENATE WA_HEADER-CADDR  WA_ADRC-CITY1 INTO WA_HEADER-CADDR SEPARATED BY ',' .
    ELSE .
      CONCATENATE WA_HEADER-CADDR  WA_ADRC-CITY1 INTO WA_HEADER-CADDR ."SEPARATED BY ',' .
    ENDIF.

    IF WA_ADRC-POST_CODE1 IS NOT INITIAL .
      CONCATENATE WA_HEADER-CADDR  WA_ADRC-POST_CODE1 INTO WA_HEADER-CADDR SEPARATED BY '-' .
    ENDIF.
*BREAK-POINT.

    NUM = STRLEN( WA_HEADER-CADDR ).
    NUM1 = 120 - NUM .
    NUM = NUM1 / 2 .
*    DO NUM TIMES.
*      SHIFT WA_HEADER-CADDR LEFT CIRCULAR.
*    ENDDO.
**    WRITE: / TEXT.

    SHIFT WA_HEADER-CADDR BY NUM PLACES RIGHT .

  ENDIF.
  IF WA_HEADER-LIFNR IS NOT INITIAL .

    IF VENDOR IS INITIAL .
      VENDOR = WA_HEADER-LIFNR .
    ENDIF.
    IF VENDOR <> WA_HEADER-LIFNR .
      VENDOR = WA_HEADER-LIFNR .
      REFRESH IT_ITEM .
      IF GRID IS BOUND.
        CALL METHOD GRID->REFRESH_TABLE_DISPLAY.
      ENDIF.
    ELSE.
*      SORT IT_ITEM ASCENDING BY SL_NO .
      IF GRID IS BOUND.
        CALL METHOD GRID->REFRESH_TABLE_DISPLAY.
      ENDIF.
    ENDIF.
    CLEAR WA_HEADER-VADDR.
    SELECT SINGLE LIFNR
                  LAND1
                  NAME1
                  ADRNR
                  STCD3
                  REGIO
                  VEN_CLASS
       FROM LFA1 INTO WA_LFA1
           WHERE LIFNR = WA_HEADER-LIFNR.

     SELECT single * from t500w into wa_t500w where LAND1 = wa_lfa1-land1 .

    SELECT SINGLE ADDRNUMBER
        DATE_FROM
        NATION
        NAME1
        CITY1
        POST_CODE1
        STREET
        COUNTRY
        REGION
        STR_SUPPL1
        STR_SUPPL2 FROM ADRC INTO WA_ADRC1
        WHERE ADDRNUMBER  = WA_LFA1-ADRNR .


    CLEAR : WA_HEADER-NAME1, WA_HEADER-STCD3 .
    WA_HEADER-NAME1 = WA_ADRC1-NAME1.
    WA_HEADER-STCD3 = WA_LFA1-STCD3.
    IF WA_ADRC1-STREET IS NOT INITIAL.
      WA_HEADER-VADDR = WA_ADRC1-STREET.
*    CONCATENATE  WA_HEADER-vADDR WA_ADRC1-STREET  INTO WA_HEADER-VADDR SEPARATED BY ',' .
    ENDIF.

    IF WA_ADRC1-CITY1 IS NOT INITIAL AND WA_HEADER-VADDR IS NOT INITIAL .
      CONCATENATE WA_HEADER-VADDR  WA_ADRC1-CITY1 INTO WA_HEADER-VADDR SEPARATED BY ',' .
    ELSE .
      CONCATENATE WA_HEADER-VADDR  WA_ADRC1-CITY1 INTO WA_HEADER-VADDR . "SEPARATED BY ',' .
    ENDIF.


    IF WA_ADRC1-POST_CODE1 IS NOT INITIAL .
      CONCATENATE WA_HEADER-VADDR  WA_ADRC1-POST_CODE1 INTO WA_HEADER-VADDR SEPARATED BY '-' .
    ENDIF.
  ENDIF.


  IF WA_HEADER-AEDAT IS NOT INITIAL AND LV_LEAD IS NOT INITIAL.

    CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
      EXPORTING
        DATE      = WA_HEADER-AEDAT
        DAYS      = LV_LEAD
        MONTHS    = '00'
        SIGNUM    = '+'
        YEARS     = '00'
      IMPORTING
        CALC_DATE = WA_HEADER-AEDAT1.
  ENDIF.

*  BREAK-POINT.
  SELECT KAPPL
           KSCHL
           LLAND
           REGIO
           WKREG
           VEN_CLASS
           TAXIM
           STEUC
           KFRST
           DATBI
           DATAB
           KBSTAT
           KNUMH    FROM A792 INTO TABLE IT_A792
         FOR ALL ENTRIES IN IT_MARC
         WHERE LLAND = 'IN'
        and KAPPL = 'TX'
         AND REGIO = WA_LFA1-REGIO
         AND WKREG = WA_T001W-REGIO
       and DATBI  > sy-datum
*         AND VEN_CLASS = WA_LFA1-VEN_CLASS
*         AND TAXIM = WA_MARA-TAKLV
         AND STEUC = IT_MARC-STEUC .



****  MODULE A  EDAT1.
****  MODULE EKGRP.
****  MODULE LGORT.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form VALIDATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VALIDATION .
  IF WA_HEADER-SITE IS INITIAL.
*    SET CURSOR FIELD WA_HEADER-SITE .
    MESSAGE 'Enter Plant' TYPE 'E'." DISPLAY LIKE 'E' .
  ELSE .
    CLEAR LV_WERKS .
    SELECT SINGLE WERKS FROM T001W INTO LV_WERKS WHERE WERKS = WA_HEADER-SITE .
    IF LV_WERKS IS INITIAL.
      MESSAGE 'Incorrect site' TYPE 'E' ."DISPLAY LIKE 'E' .
    ENDIF.
  ENDIF.

  IF WA_HEADER-LIFNR IS INITIAL.
*    SET CURSOR FIELD WA_HEADER-SITE .
    MESSAGE 'Enter Vendor' TYPE 'E'." DISPLAY LIKE 'E' .
  ELSE .
    CLEAR LV_VENDOR1 .
    SELECT SINGLE LIFNR FROM LFA1 INTO LV_VENDOR1 WHERE LIFNR = WA_HEADER-LIFNR .
    IF LV_VENDOR1 IS INITIAL.
      MESSAGE 'Incorrect Vendor' TYPE 'E' ."DISPLAY LIKE 'E' .
    ENDIF.
  ENDIF.

  IF LV_LEAD IS INITIAL.
    SET CURSOR FIELD 'lv_lead' .
    MESSAGE 'Enter lead time' TYPE 'E' ."  DISPLAY LIKE 'E' .
  ENDIF.

  IF WA_HEADER-LGORT IS INITIAL.
    SET CURSOR FIELD 'WA_HEADER-LGORT' .
    MESSAGE 'Storage location should not be blank' TYPE 'E' ." DISPLAY LIKE 'E' .

  ELSE.
    SELECT SINGLE LGORT FROM T001L INTO LV_LGORT WHERE LGORT = WA_HEADER-LGORT .
    IF LV_LGORT IS INITIAL.
      MESSAGE 'Incorrect Storage Location' TYPE 'E' ."DISPLAY LIKE 'E' .
    ENDIF.
  ENDIF.

  IF WA_HEADER-EKGRP IS INITIAL.
*    SET CURSOR FIELD 'WA_HEADER-EKGRP' .
    MESSAGE 'Purchase Order Group should not be blank' TYPE 'E'."  DISPLAY LIKE  'E' .
*    RETURN .
  ELSE.
    SELECT SINGLE EKGRP FROM T024 INTO LV_EKGRP WHERE EKGRP = WA_HEADER-EKGRP .
    IF LV_EKGRP IS INITIAL.
      MESSAGE 'Incorrect Purchasing group' TYPE 'E' ." DISPLAY LIKE 'E' .
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM DELETE  USING    P_ER_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL .
*  BREAK-POINT.
  DATA : LS_MOD_CELLS TYPE LVC_S_MODI.

  LOOP AT P_ER_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    DELETE IT_ITEM INDEX LS_MOD_CELLS-ROW_ID.
  ENDLOOP .
*  BREAK-POINT.
*  lv_sl_no = 10 .
*  delete it_item where matnr is  INITIAL .
*  LOOP AT it_item into wa_item.
*    wa_item-SL_NO = lv_sl_no .
*    lv_sl_no = lv_sl_no + 10 .
*    MODIFY it_item FROM wa_item .
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE INPUT.
  PERFORM VALIDATION .
ENDMODULE.




*****************************************
