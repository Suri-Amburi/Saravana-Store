REPORT ZRV56TD00.

SET EXTENDED CHECK OFF.
TABLES: VBPLA, THEAD, TTXERN, TTXIT, T005, VBDDL, STXH, SADR.   "SADR40A
INCLUDE VTTKDATA.                      "Shipment Header
INCLUDE VTTSDATA.                      "Shipment Segment
INCLUDE VTTPDATA.                      "Shipment Items
INCLUDE VBPADATA.                      "Partner
INCLUDE VTFADATA.                      "Flow
INCLUDE SADRDATA.                      "Address
INCLUDE VTLFDATA.                      "Delivery Selection
INCLUDE RVADTABL.                      "Messages
INCLUDE VSEDATA.                       "shipping units
INCLUDE RV56ACOM.                      "I/O-Structure
SET EXTENDED CHECK ON.

DATA:
  XSCREEN(1)              TYPE C,
  RETCODE                 LIKE SY-SUBRC VALUE 0,
  THERE_WAS_OUTPUT(1)     TYPE C        VALUE SPACE,
  NEW_PAGE_WAS_ORDERED(1) TYPE C        VALUE SPACE.

CONSTANTS:
  NO(1)  VALUE SPACE,
  YES(1) VALUE 'X'.

TABLES : TPAR .                                             "n_742056.

***********************************************************************
*       FORM ENTRY                                                    *
***********************************************************************
*       Called from the Output Controll program                       *
***********************************************************************
*  -->  RETURN_CODE Status                                            *
*  -->  US_SCREEN                                                     *
***********************************************************************
FORM ENTRY USING RETURN_CODE LIKE SY-SUBRC                  "#EC CALLED
                 US_SCREEN   TYPE C.                        "#EC CALLED

* BREAK BREDDY .
  RETURN_CODE = 1.
*
  PERFORM DATA_INIT USING US_SCREEN.
*
  PERFORM GET_DATA.
  CHECK RETCODE EQ 0.

*  PERFORM OPEN_FORM USING US_SCREEN.
*  CHECK RETCODE EQ 0.

*  PERFORM PRINT_DOCUMENT.
*  CHECK RETCODE EQ 0.
*
*  PERFORM CLOSE_FORM.
*  CHECK RETCODE EQ 0.

  RETURN_CODE = 0.
  """Added By BReddy""""""""22/11/2018
  PERFORM SHP_DEL_FORM.
ENDFORM.

***********************************************************************
*       FORM data_init                                               *
***********************************************************************
FORM DATA_INIT USING VALUE(US_SCREEN) TYPE C.
  XSCREEN = US_SCREEN.
  CLEAR:
    RETCODE,
    THERE_WAS_OUTPUT,
    NEW_PAGE_WAS_ORDERED.
ENDFORM.

***********************************************************************
*       FORM GET_DATA                                                 *
***********************************************************************
FORM GET_DATA.
  DATA LANGUAGE LIKE NAST-SPRAS.
  DATA SHIPMENT_NUMBER LIKE VTTK-TKNUM.

  LANGUAGE = NAST-SPRAS.
  SHIPMENT_NUMBER = NAST-OBJKY.
  CALL FUNCTION 'RV_SHIPMENT_PRINT_VIEW'
    EXPORTING
      SHIPMENT_NUMBER     = SHIPMENT_NUMBER
      OPTION_TVTK         = 'X'  "Shipmenttype J/N
      OPTION_TTDS         = 'X'  "Disposition J/N
      LANGUAGE            = LANGUAGE
      OPTION_ITEMS        = 'X'  "Transport Items J/N
      OPTION_SEGMENTS     = 'X'  "Transport Segments J/N
      OPTION_PARTNERS     = 'X'  "Partners J/N
      OPTION_SALES_ORDERS = 'X'  "Sales orders J/N
      OPTION_EXPORT_DATA  = 'X'  "Export data J/N
      OPTION_PACKAGES     = 'X'  "Packages J/N
      OPTION_FLOW         = ' '  "Flow J/N
      OPTION_NO_REFRESH   = ' '  "Refresh Tables J/N
    IMPORTING
      F_VTTKVB            = VTTKVB  "Shipment Header
      F_TVTK              = TVTK "Shipmenttype
      F_TVTKT             = TVTKT "Description Shipmenttype
      F_TTDS              = TTDS "Disposition
      F_TTDST             = TTDST "Description Disposition
      F_VBPLA             = VBPLA "Packages
    TABLES
      F_VTTP              = XVTTP "Shipment Items
      F_TRLK              = SLK  "Delivery
      F_TRLP              = SLP  "Delivery Item
      F_VTTS              = XVTTS "Shipment Segments
      F_VTSP              = XVTSP "Segments/Items
      F_VBPA              = XVBPA "Partner
      F_VBADR             = XVBADR  "Address
      F_VTFA              = XVTFA "Flow
      F_VBPLK             = XVBPLK  "Shipment Unit Header
      F_VBPLP             = XVBPLP  "Shipment Unit
      F_VBPLS             = XVBPLS  "Shipment Unit Sum
    EXCEPTIONS
      NOT_FOUND           = 1.

  IF SY-SUBRC NE 0.
    SYST-MSGID = 'VW'.
    SYST-MSGNO = '010'.
    SYST-MSGTY = 'E'.
    SYST-MSGV1 = DBVTTK-TKNUM.
    SYST-MSGV2 = SY-SUBRC.
    RETCODE    = 1.
    PERFORM PROTOCOL_UPDATE.
  ENDIF.

  CHECK RETCODE EQ 0.

* Sort shipment items by itenary (i.e. TPRFO)                 "n_902657
  SORT XVTTP BY TPRFO.                                      "n_902657
* SORT SEGMENTS BY CORRECT ORDER (I.E. TSRFO)
  SORT XVTTS BY TSRFO.

* CONVERT UNITS IN DELIVERIES AND DELIVERY-ITEMS
* TO BE CONFORM TO VTTK-UNITS:

  LOOP AT SLK.
* start of insertion HP_364727
    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        INPUT    = SLK-BRGEW
        UNIT_IN  = SLK-GEWEI
        UNIT_OUT = VTTKVB-DTMEG
      IMPORTING
        OUTPUT   = SLK-BRGEW.

* end of insertion HP_364727
    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        INPUT    = SLK-BTGEW
        UNIT_IN  = SLK-GEWEI
        UNIT_OUT = VTTKVB-DTMEG
      IMPORTING
        OUTPUT   = SLK-BTGEW.

    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        INPUT    = SLK-NTGEW
        UNIT_IN  = SLK-GEWEI
        UNIT_OUT = VTTKVB-DTMEG
      IMPORTING
        OUTPUT   = SLK-NTGEW.

    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        INPUT    = SLK-VOLUM
        UNIT_IN  = SLK-VOLEH
        UNIT_OUT = VTTKVB-DTMEV
      IMPORTING
        OUTPUT   = SLK-VOLUM.

    SLK-GEWEI = VTTKVB-DTMEG.
    SLK-VOLEH = VTTKVB-DTMEV.
    MODIFY SLK.
  ENDLOOP.

  LOOP AT SLP.
    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        INPUT    = SLP-BRGEW
        UNIT_IN  = SLP-GEWEI
        UNIT_OUT = VTTKVB-DTMEG
      IMPORTING
        OUTPUT   = SLP-BRGEW.

    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        INPUT    = SLP-NTGEW
        UNIT_IN  = SLP-GEWEI
        UNIT_OUT = VTTKVB-DTMEG
      IMPORTING
        OUTPUT   = SLP-NTGEW.

    SLP-GEWEI = VTTKVB-DTMEG.
    MODIFY SLP.
  ENDLOOP.
* Transfer address number for mail
  IF NAST-NACHA = '5'.                "e-mail                "v_n_742056.
* Determine the type of the partner number
    SELECT SINGLE * FROM TPAR
                  WHERE PARVW = NAST-PARVW.
    IF SY-SUBRC NE 0.
      EXIT.
    ENDIF.
* Search the address number
    LOOP AT XVBPA
     WHERE PARVW = NAST-PARVW.
      CASE TPAR-NRART.             "type of the partner number
        WHEN 'KU'.                 "- customer
          CHECK XVBPA-KUNNR = NAST-PARNR.
        WHEN 'LI'.                 "- vendor
          CHECK XVBPA-LIFNR = NAST-PARNR.
        WHEN 'AP'.                 "- contact person
          CHECK XVBPA-PARNR = NAST-PARNR.
        WHEN 'PE'.                 "- personell number
          CHECK XVBPA-PERNR = NAST-PARNR.
      ENDCASE.
      "^_n_742056.
* deleted line of n_656692
      ADDR_KEY-ADDRNUMBER = XVBPA-ADRNR.
      ADDR_KEY-PERSNUMBER = XVBPA-ADRNP.
      EXIT.
    ENDLOOP.
  ENDIF.                                                    "n_742056.
ENDFORM.

***********************************************************************
*       FORM PRINT_DOCUMENT                                           *
***********************************************************************
FORM PRINT_DOCUMENT.

  PERFORM PRINT_GENERAL_HEADER_DATA.
  PERFORM NEW_PAGE_IF_NECESSARY.

  PERFORM PRINT_DELIVERIES_IN_SHIPMENT.
  PERFORM NEW_PAGE_IF_NECESSARY.

  PERFORM PRINT_DELIVERY_DETAILS.
  PERFORM NEW_PAGE_IF_NECESSARY.

  PERFORM PRINT_SEGMENT_OVERVIEW.
  PERFORM NEW_PAGE_IF_NECESSARY.

  PERFORM PRINT_SEGMENT_DETAILS.
  PERFORM NEW_PAGE_IF_NECESSARY.

  PERFORM PRINT_TEXTS.
  PERFORM NEW_PAGE_IF_NECESSARY.

  PERFORM PRINT_SHIPPING_UNITS.
  PERFORM NEW_PAGE_IF_NECESSARY.

  PERFORM PRINT_DEADLINES.
  PERFORM NEW_PAGE_IF_NECESSARY.

ENDFORM.

***********************************************************************
*      Form  PRINT_GENAERAL_HEADER_DATA
***********************************************************************
FORM PRINT_GENERAL_HEADER_DATA.
  PERFORM DOMAIN_VALUE_TEXT(SAPMV56A)
          USING 'ABFER' VTTKVB-ABFER RV56A-TXT_ABFER.
  PERFORM DOMAIN_VALUE_TEXT(SAPMV56A)
          USING 'ABWST' VTTKVB-ABWST RV56A-TXT_ABWST.
  PERFORM DOMAIN_VALUE_TEXT(SAPMV56A)
          USING 'LAUFK' VTTKVB-LAUFK RV56A-TXT_LAUFK.
  PERFORM DOMAIN_VALUE_TEXT(SAPMV56A)
          USING 'BFART' VTTKVB-BFART RV56A-TXT_BFART.
  PERFORM DOMAIN_VALUE_TEXT(SAPMV56A)
          USING 'STTRG' VTTKVB-STTRG RV56A-TXT_STTRG.


  PERFORM TVSBT_READ(SAPFV56H) USING VTTKVB-VSBED
                               CHANGING RV56A-TXT_VSBED.
  PERFORM T173T_READ(SAPFV56H)
          USING    VTTKVB-VSART
          CHANGING RV56A-TXT_VSART.
  PERFORM T173T_READ(SAPFV56H)
          USING    VTTKVB-VSAVL
          CHANGING RV56A-TXT_VSAVL.
  PERFORM T173T_READ(SAPFV56H)
          USING    VTTKVB-VSANL
          CHANGING RV56A-TXT_VSANL.

  PERFORM PRINT USING 'GENERAL_HEADER_DATA_TITLE'.
  PERFORM PRINT USING 'GENERAL_HEADER_DATA_TYPES'.
  PERFORM PRINT USING 'GENERAL_HEADER_DATA_PROCESSING'.
  PERFORM PRINT USING 'GENERAL_HEADER_DATA_STATUS'.
  IF   ( NOT VTTKVB-SIGNI IS INITIAL )
    OR ( NOT VTTKVB-TPBEZ IS INITIAL )
    OR ( NOT VTTKVB-EXTI1 IS INITIAL )
    OR ( NOT VTTKVB-EXTI2 IS INITIAL ).
    PERFORM PRINT USING 'GENERAL_HEADER_DATA_IDENTIFICATION'.
  ENDIF.
ENDFORM.

***********************************************************************
*      Form  PRINT_DELIVERIES_IN_SHIPMENT
***********************************************************************
FORM PRINT_DELIVERIES_IN_SHIPMENT.
  DATA SUM_WEIGHT LIKE VTRLK-BTGEW.
  DATA SUM_VOLUME LIKE VTRLK-VOLUM.

  CHECK NOT SLK[] IS INITIAL.

  CLEAR: SUM_WEIGHT, SUM_VOLUME, VTRLK.
  PERFORM PRINT USING 'DELIVERIES_IN_SHIPMENT_TITLE'.
* CALCULATE SUM OVER ALL DELIVERIES AND PRINT IT
  LOOP AT SLK.                         "DELIVERY HEADER
    SUM_WEIGHT = SUM_WEIGHT + SLK-BTGEW.
    SUM_VOLUME = SUM_VOLUME + SLK-VOLUM.
  ENDLOOP.
  VTRLK-BTGEW = SUM_WEIGHT.
  VTRLK-VOLUM = SUM_VOLUME.
  PERFORM PRINT USING 'TRANSPORT_SUM'.
  CLEAR VTRLK.
* PRINT ALL DELIVERIES
  PERFORM PRINT USING 'DELIVERY_HEADING'.
* v_n_902657
  LOOP AT XVTTP.
    READ TABLE SLK
         WITH KEY VBELN = XVTTP-VBELN
         INTO  VTRLK
         BINARY SEARCH.
    CHECK SY-SUBRC = 0.
* ^_n_902657
    PERFORM PRINT USING 'DELIVERY'.
  ENDLOOP.
ENDFORM.

***********************************************************************
*      Form  PRINT_DELIVERY_DETAILS
***********************************************************************
FORM PRINT_DELIVERY_DETAILS.
  CHECK NOT SLK[] IS INITIAL.

* v_n_902657
  LOOP AT XVTTP.
    READ TABLE SLK
         WITH KEY VBELN = XVTTP-VBELN
         INTO  VTRLK
         BINARY SEARCH.
    CHECK SY-SUBRC = 0.
* ^_n_902657
    SLK-VBELN = VTRLK-VBELN.                                "n_998327
    PERFORM PRINT USING 'DELIVERY_TITLE'.
    PERFORM PRINT USING 'DELIVERY_ITEM_HEADING'.
    LOOP AT SLP WHERE VBELN EQ SLK-VBELN.             "DELIVERY-ITEMS
      MOVE SLP TO VTRLP.
      PERFORM PRINT USING 'DELIVERY_ITEM'.
    ENDLOOP.
*   PERFORM PRINT USING 'DELIVERY_SUM'.
  ENDLOOP.
ENDFORM.

***********************************************************************
*      Form  PRINT_SEGMENT_OVERVIEW
***********************************************************************
FORM PRINT_SEGMENT_OVERVIEW.
  CHECK NOT XVTTS[] IS INITIAL.

  PERFORM PRINT USING 'SEGMENT_OVERVIEW_TITLE'.
  PERFORM PRINT USING 'SEGMENT_OVERVIEW_HEADING'.
  LOOP AT XVTTS.                       "Segments
    MOVE XVTTS TO VTTSVB.
    PERFORM DOMAIN_VALUE_TEXT(SAPMV56A)
            USING 'TSTYP' VTTSVB-TSTYP RV56A-TXT_TSTYP.
    PERFORM PRINT USING 'SEGMENT_OVERVIEW'.
  ENDLOOP.
ENDFORM.

***********************************************************************
*      Form  PRINT_SEGMENT_DETAILS
***********************************************************************
FORM PRINT_SEGMENT_DETAILS.
  CHECK NOT XVTTS[] IS INITIAL.

  LOOP AT XVTTS.                       "Segments
    MOVE XVTTS TO VTTSVB.
    PERFORM DOMAIN_VALUE_TEXT(SAPMV56A)
            USING 'LAUFK' VTTSVB-LAUFK RV56A-TXT_LAUFK.
    PERFORM PRINT USING 'SEGMENT_DETAIL_TITLE'.
    PERFORM PRINT USING 'SEGMENT_DETAIL_KNODES'.
    PERFORM PRINT USING 'SEGMENT_DETAIL_PROCESSING'.
    PERFORM PRINT USING 'SEGMENT_DETAIL_DEADLINES'.
    PERFORM PRINT_DEPARTURE_ADDRESS.
    PERFORM PRINT_DEPARTURE_DETAILS.
    PERFORM PRINT_DESTINATION_ADDRESS.
    PERFORM PRINT_DESTINATION_DETAILS.
    PERFORM PRINT_DELIVERIES_IN_SEGMENT.
    PERFORM NEW_PAGE_IF_NECESSARY.
  ENDLOOP.
ENDFORM.

***********************************************************************
*      Form  PRINT_DEPARTURE_DETAILS
***********************************************************************
FORM PRINT_DEPARTURE_DETAILS.

  DATA: BEZ_WERKA  LIKE T001W-NAME1,
        BEZ_LGORTA LIKE T001L-LGOBE.

  CHECK ( VTTSVB-VSTEL  NE SPACE )
     OR ( VTTSVB-LSTEL  NE SPACE )
     OR ( VTTSVB-WERKA  NE SPACE )
     OR ( VTTSVB-LGORTA NE SPACE )
     OR ( VTTSVB-KUNNA  NE SPACE )
     OR ( VTTSVB-LIFNA  NE SPACE )
     OR ( VTTSVB-BELAD  NE SPACE ).

  PERFORM VTTS-VSTEL_DISPLAY(SAPFV56S) USING    VTTSVB-VSTEL
                                       CHANGING RV56A-TXT_VSTEL.
  PERFORM VTTS-LSTEL_DISPLAY(SAPFV56S) USING    VTTSVB-VSTEL
                                                VTTSVB-LSTEL
                                       CHANGING RV56A-TXT_LSTEL.
  PERFORM VTTS-KUNNA_DISPLAY(SAPFV56S) USING    VTTSVB-KUNNA
                                       CHANGING RV56A-TXT_KUNNR.
  PERFORM LFA1_READ(SAPFV56H)          USING    VTTSVB-LIFNA
                                       CHANGING RV56A-TXT_DLNAM.
  PERFORM VTTS-WERK_DISPLAY(SAPFV56S) USING    VTTSVB-WERKA
                                      CHANGING BEZ_WERKA.
  PERFORM VTTS-LGORT_DISPLAY(SAPFV56S) USING    VTTSVB-WERKA
                                                VTTSVB-LGORTA
                                       CHANGING BEZ_LGORTA.
  PERFORM VTTS-BEZ_CONDENSE(SAPFV56S) USING    BEZ_WERKA
                                               BEZ_LGORTA
                                      CHANGING RV56A-TXT_WRKLGO.

  PERFORM PRINT USING 'DEPARTURE_DETAILS'.
ENDFORM.

***********************************************************************
*      Form  PRINT_DESTINATION_DETAILS
***********************************************************************
FORM PRINT_DESTINATION_DETAILS.

  DATA: BEZ_WERKZ  LIKE T001W-NAME1,
        BEZ_LGORTZ LIKE T001L-LGOBE.

  CHECK ( VTTSVB-VSTEZ  NE SPACE )
     OR ( VTTSVB-LSTEZ  NE SPACE )
     OR ( VTTSVB-WERKZ  NE SPACE )
     OR ( VTTSVB-LGORTZ NE SPACE )
     OR ( VTTSVB-KUNNZ  NE SPACE )
     OR ( VTTSVB-LIFNZ  NE SPACE )
     OR ( VTTSVB-ABLAD  NE SPACE ).

  PERFORM VTTS-VSTEL_DISPLAY(SAPFV56S) USING    VTTSVB-VSTEZ
                                       CHANGING RV56A-TXT_VSTEL.
  PERFORM VTTS-LSTEL_DISPLAY(SAPFV56S) USING    VTTSVB-VSTEZ
                                                VTTSVB-LSTEZ
                                       CHANGING RV56A-TXT_LSTEL.
  PERFORM VTTS-KUNNA_DISPLAY(SAPFV56S) USING    VTTSVB-KUNNZ
                                       CHANGING RV56A-TXT_KUNNR.
  PERFORM LFA1_READ(SAPFV56H)          USING    VTTSVB-LIFNZ
                                       CHANGING RV56A-TXT_DLNAM.
  PERFORM VTTS-WERK_DISPLAY(SAPFV56S) USING    VTTSVB-WERKZ
                                      CHANGING BEZ_WERKZ.
  PERFORM VTTS-LGORT_DISPLAY(SAPFV56S) USING    VTTSVB-WERKZ
                                                VTTSVB-LGORTZ
                                       CHANGING BEZ_LGORTZ.
  PERFORM VTTS-BEZ_CONDENSE(SAPFV56S) USING    BEZ_WERKZ
                                               BEZ_LGORTZ
                                      CHANGING RV56A-TXT_WRKLGO.

  PERFORM PRINT USING 'DESTINATION_DETAILS'.
ENDFORM.

***********************************************************************
*      Form  PRINT_DEPARTURE_ADDRESS
***********************************************************************
FORM PRINT_DEPARTURE_ADDRESS.
  DATA:
    L_DEPT LIKE LOC_DEPT.

  MOVE-CORRESPONDING XVTTS TO L_DEPT.
  CALL FUNCTION 'ST_LOCATION_ADDR_READ'
    EXPORTING
      I_LOCATION        = L_DEPT
    IMPORTING
      E_SADR            = SADR   "SADR40A
    EXCEPTIONS
      ADDRESS_NOT_FOUND = 1
      OTHERS            = 2.
  IF SY-SUBRC NE 0.
    CLEAR SADR.                        "SADR40A
    EXIT.
  ENDIF.

  PERFORM PRINT USING 'DEPARTURE_ADDRESS_TITLE'.
  PERFORM PRINT USING 'ADDRESS'.
ENDFORM.

***********************************************************************
*      Form  PRINT_DESTINATION_ADDRESS
***********************************************************************
FORM PRINT_DESTINATION_ADDRESS.
  DATA:
    L_DEST LIKE LOC_DEST.

  MOVE-CORRESPONDING XVTTS TO L_DEST.
  CALL FUNCTION 'ST_LOCATION_ADDR_READ'
    EXPORTING
      I_LOCATION        = L_DEST
    IMPORTING
      E_SADR            = SADR   "SADR40A
    EXCEPTIONS
      ADDRESS_NOT_FOUND = 1
      OTHERS            = 2.
  IF SY-SUBRC NE 0.
    CLEAR SADR.                        "SADR40A
    EXIT.
  ENDIF.

  PERFORM PRINT USING 'DESTINATION_ADDRESS_TITLE'.
  PERFORM PRINT USING 'ADDRESS'.
ENDFORM.

***********************************************************************
*      Form  PRINT_DELIVERIES_IN_SEGMENT
***********************************************************************
FORM PRINT_DELIVERIES_IN_SEGMENT.
  DATA SUM_WEIGHT LIKE VTRLK-BTGEW.
  DATA SUM_VOLUME LIKE VTRLK-VOLUM.
  DATA THERE_ARE_DELIVERIES(1).

  CLEAR: SUM_WEIGHT, SUM_VOLUME.
  THERE_ARE_DELIVERIES = NO.
* Find all items in this segment (= XVTTS-TSNUM)
* of this transport (= XVTTS-TKNUM) in table XVTTSP:
  LOOP AT XVTSP WHERE TKNUM EQ XVTTS-TKNUM
                AND   TSNUM EQ XVTTS-TSNUM.
* Find the corresponding delivery-number in table XVTTP:
    READ TABLE XVTTP WITH KEY TKNUM = XVTTS-TKNUM
                              TPNUM = XVTSP-TPNUM.
    IF SY-SUBRC EQ 0.
* Read the delivery
      LOOP AT SLK WHERE VBELN EQ XVTTP-VBELN.  "Deliveries
        MOVE SLK TO VTRLK.
        IF THERE_ARE_DELIVERIES EQ NO.
          PERFORM PRINT USING 'DELIVERIES_IN_SEGMENT_HEADING'.
          PERFORM PRINT USING 'DELIVERY_HEADING'.
          THERE_ARE_DELIVERIES = YES.
        ENDIF.
        PERFORM PRINT USING 'DELIVERY'.
        SUM_WEIGHT = SUM_WEIGHT + VTRLK-BTGEW.
        SUM_VOLUME = SUM_VOLUME + VTRLK-VOLUM.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
  IF THERE_ARE_DELIVERIES EQ YES.
    VTRLK-BTGEW = SUM_WEIGHT.
    VTRLK-VOLUM = SUM_VOLUME.
    PERFORM PRINT USING 'DELIVERY_OVERVIEW_SUM'.
    CLEAR VTRLK.
  ENDIF.
ENDFORM.

***********************************************************************
*      Form  PRINT_TEXTS
***********************************************************************
FORM PRINT_TEXTS.
  DATA THERE_ARE_TEXTS(1).
  DATA: L_TTXER LIKE TTXERN OCCURS 0 WITH HEADER LINE.

  THERE_ARE_TEXTS = NO.
  SELECT * FROM TTXERN
           INTO TABLE L_TTXER
           WHERE TDOBJECT EQ 'VTTK'
             AND TXTGR    EQ TVTK-TXTGR.

  LOOP AT L_TTXER INTO TTXERN.
    MOVE: VTTKVB-TKNUM   TO THEAD-TDNAME,
          TTXERN-TDOBJECT TO THEAD-TDOBJECT,
          TTXERN-TDID     TO THEAD-TDID,
          NAST-SPRAS     TO THEAD-TDSPRAS.
    SELECT SINGLE * FROM TTXIT
           WHERE TDOBJECT EQ TTXERN-TDOBJECT
           AND   TDID     EQ TTXERN-TDID
           AND   TDSPRAS  EQ NAST-SPRAS.
    IF SY-SUBRC EQ 0.
      MOVE TTXIT-TDTEXT TO THEAD-TDTITLE.
    ELSE.
      THEAD-TDTITLE = TEXT-TXT.
      THEAD-TDTITLE+6(4) = TTXERN-TDID.
    ENDIF.
    SELECT SINGLE * FROM STXH WHERE TDNAME    = THEAD-TDNAME
                                AND TDID      = THEAD-TDID
                                AND TDOBJECT  = THEAD-TDOBJECT
                                AND TDSPRAS   = THEAD-TDSPRAS.
    IF ( SY-SUBRC EQ 0 ).
      IF THERE_ARE_TEXTS EQ NO.
        PERFORM PRINT USING 'TEXT_TITLE'.
        THERE_ARE_TEXTS = YES.
      ENDIF.
      PERFORM PRINT USING 'TEXT'.
    ENDIF.

  ENDLOOP.
ENDFORM.

***********************************************************************
*      Form  PRINT_SHIPPING_UNITS                                     *
***********************************************************************
FORM PRINT_SHIPPING_UNITS.
  CHECK NOT XVBPLK[] IS INITIAL.

  PERFORM PRINT USING 'SHIPPING_UNIT_TITLE'.
  PERFORM PRINT USING 'SHIPPING_UNIT_HEADING'.
  LOOP AT XVBPLK WHERE KZOBE = 'X'.
    PERFORM PACKING_TREE USING XVBPLK-VENUM.
  ENDLOOP.
ENDFORM.


***********************************************************************
*      Form  PACKING_TREE                                             *
***********************************************************************
FORM PACKING_TREE USING VALUE(SHENR) LIKE VEKP-VENUM.
  MOVE SPACE TO XVBPLK.
  XVBPLK-VENUM = SHENR.
  READ TABLE XVBPLK.
  VBPLK = XVBPLK.
  PERFORM PRINT USING 'SHIPPING_UNIT'.

  LOOP AT XVBPLP WHERE VENUM = SHENR.
    IF XVBPLP-POSNR IS INITIAL.
      PERFORM PACKING_TREE USING XVBPLP-UNVEL.
    ELSE.
      VBPLP = XVBPLP.
      PERFORM PRINT USING 'SHIPPING_UNIT_DELIVERY_ITEM'.
    ENDIF.
  ENDLOOP.
ENDFORM.

***********************************************************************
*      Form  PRINT_DEADLINES                                        *
***********************************************************************
FORM PRINT_DEADLINES.
  DATA:
    XVBDDL LIKE VBDDL OCCURS 0 WITH HEADER LINE.

  VTTK = VTTKVB.
  CALL FUNCTION 'SD_DEADLINE_PRINT_VIEW'
    EXPORTING
      DEADLINE_NO  = VTTKVB-TERNR
      LANGUAGE     = SY-LANGU
      HANDLE_NO    = VTTKVB-HANDLE
      IF_OBJECT    = 'WSHDRVTTK'
      IS_OBJECT_WA = VTTK
    TABLES
      DEADLINE_TAB = XVBDDL
    EXCEPTIONS
      NO_DEADLINES = 01.
  CHECK SY-SUBRC EQ 0.

  CHECK NOT XVBDDL[] IS INITIAL.

  PERFORM PRINT USING 'DEADLINES_TITLE'.
  PERFORM PRINT USING 'DEADLINE_HEADING'.
  LOOP AT XVBDDL.
    MOVE XVBDDL TO VBDDL.
    PERFORM PRINT USING 'DEADLINE_PLAN_DATA'.
    IF NOT ( ( VBDDL-ISDD IS INITIAL ) AND
             ( VBDDL-ISDZ IS INITIAL ) AND
             ( VBDDL-IEDD IS INITIAL ) AND
             ( VBDDL-IEDZ IS INITIAL ) ).
      PERFORM PRINT USING 'DEADLINE_ACTUAL_DATA'.
    ENDIF.
    IF VBDDL-VSTGA NE SPACE.
      PERFORM PRINT USING 'DEADLINE_DEVIATION'.
    ENDIF.
    IF VBDDL-KNOTE NE SPACE.
      PERFORM PRINT USING 'DEADLINE_KNODE'.
    ENDIF.
    IF VBDDL-TDNAME NE SPACE.
      THEAD-TDNAME   = VBDDL-TDNAME.
      THEAD-TDOBJECT = 'AUFK'.
      THEAD-TDID     = 'AVOT'.
      THEAD-TDSPRAS  = NAST-SPRAS.
      SELECT SINGLE * FROM STXH WHERE TDNAME    = THEAD-TDNAME
                                  AND TDID      = THEAD-TDID
                                  AND TDOBJECT  = THEAD-TDOBJECT
                                  AND TDSPRAS   = THEAD-TDSPRAS.
      IF ( SY-SUBRC EQ 0 ).
        PERFORM PRINT USING 'DEADLINE_TEXT'.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.



***********************************************************************
********                                                      *********
********                 T E C H N I C A L                    *********
********                                                      *********
***********************************************************************

***********************************************************************
*      Form  PRINT                                                    *
***********************************************************************
FORM PRINT USING TEXTELEMENT TYPE C.
  IF NEW_PAGE_WAS_ORDERED EQ YES.
    CALL FUNCTION 'CONTROL_FORM'
      EXPORTING
        COMMAND = 'ENDPROTECT'.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'NEW_PAGE'
      EXCEPTIONS
        OTHERS  = 1.
    IF SY-SUBRC NE 0.
      PERFORM PROTOCOL_UPDATE.
    ENDIF.
    NEW_PAGE_WAS_ORDERED = NO.
  ENDIF.
  IF THERE_WAS_OUTPUT EQ NO.
    CALL FUNCTION 'CONTROL_FORM'
      EXPORTING
        COMMAND = 'PROTECT'.
    THERE_WAS_OUTPUT = YES.
  ENDIF.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = TEXTELEMENT
    EXCEPTIONS
      OTHERS  = 1.
  IF SY-SUBRC NE 0.
    PERFORM PROTOCOL_UPDATE.
  ENDIF.
ENDFORM.

***********************************************************************
*      Form  NEW_PAGE_IF_NECESSARY
***********************************************************************
FORM NEW_PAGE_IF_NECESSARY.
  IF THERE_WAS_OUTPUT EQ YES.
    NEW_PAGE_WAS_ORDERED = YES.
  ENDIF.
  THERE_WAS_OUTPUT = NO.
ENDFORM.                               " NEW_PAGE

***********************************************************************
*       FORM OPEN_FORM                                                *
***********************************************************************
*  -->  VALUE(US_SCREEN)  Output on screen                            *
*                         ' ' = printer                               *
*                         'X' = screen                                *
***********************************************************************
FORM OPEN_FORM USING VALUE(US_SCREEN) TYPE C.
  DATA US_COUNTRY LIKE T005-LAND1.

  PERFORM GET_SENDER_COUNTRY USING US_COUNTRY.
  CHECK RETCODE EQ 0.
  INCLUDE RVADOPFO.
ENDFORM.

***********************************************************************
*       FORM Get_Sender_Country
*                                                                     *
***********************************************************************
*       Determines the country of the transport-disposition-unit      *
***********************************************************************
FORM GET_SENDER_COUNTRY USING SENDER_COUNTRY LIKE T005-LAND1.
* data:
*   l_addr1_sel like addr1_sel.

* l_addr1_sel-addrnumber = ttds-adrnr.                    "SADR40A
* call function 'ADDR_GET'
*      exporting
*        address_selection = l_addr1_sel
*        address_group     = 'CA01'        "it's a Customizing-Address
*      importing
*        sadr              = sadr                            "SADR40A
*      exceptions
*           others  = 1.
* if sy-subrc eq 0.
*   sender_country = sadr-land1.                             "SADR40A
* else.
*   syst-msgid = 'VW'.
*   syst-msgno = '087'.
*   syst-msgty = 'E'.
*   syst-msgv1 = dbvttk-tknum.
*   syst-msgv2 = sy-subrc.
*   perform protocol_update.
* endif.
  DATA: L_VBADR LIKE VBADR.
  DATA: L_VBPA  LIKE VBPA.

  LOOP AT XVBPA WHERE VBELN = NAST-OBJKY AND
                      PARVW = NAST-PARVW.
    SENDER_COUNTRY = XVBPA-LAND1.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC IS INITIAL  AND  SENDER_COUNTRY IS INITIAL.
    L_VBPA = XVBPA.
    CALL FUNCTION 'VIEW_VBADR'
      EXPORTING
        INPUT         = L_VBPA
        PARTNERNUMMER = NAST-PARNR
      IMPORTING
        ADRESSE       = L_VBADR.
    SENDER_COUNTRY = L_VBADR-LAND1.
  ENDIF.

ENDFORM.

***********************************************************************
*       FORM CLOSE_FORM                                               *
***********************************************************************
FORM CLOSE_FORM.
  CALL FUNCTION 'CLOSE_FORM'
    EXCEPTIONS
      OTHERS = 1.
  IF SY-SUBRC NE 0.
    RETCODE = SY-SUBRC.
    PERFORM PROTOCOL_UPDATE.
  ENDIF.
  SET COUNTRY SPACE.
ENDFORM.

***********************************************************************
*       FORM PROTOCOL_UPDATE                                          *
***********************************************************************
*       The messages are collected for the processing protocol.       *
***********************************************************************
FORM PROTOCOL_UPDATE.

  IF XSCREEN = SPACE.
    CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
      EXPORTING
        MSG_ARBGB = SYST-MSGID
        MSG_NR    = SYST-MSGNO
        MSG_TY    = SYST-MSGTY
        MSG_V1    = SYST-MSGV1
        MSG_V2    = SYST-MSGV2
        MSG_V3    = SYST-MSGV3
        MSG_V4    = SYST-MSGV4.
  ELSE.
    MESSAGE ID SYST-MSGID TYPE 'I' NUMBER SYST-MSGNO
            WITH SYST-MSGV1 SYST-MSGV2 SYST-MSGV3 SYST-MSGV4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SHP_DEL_FORM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SHP_DEL_FORM .
  TYPES: BEGIN OF TY_LIKP,
           VBELN TYPE VBELN_VL,    """Delivery
           VSTEL TYPE VSTEL,
           WERKS TYPE EMPFW,       """Receiving Plant for Deliveries

         END OF TY_LIKP.

  TYPES: BEGIN OF TY_LIPS,
           VBELN TYPE VBELN_VL,    """Delivery
           POSNR TYPE POSNR_VL,    """Delivery Item
           MATNR TYPE MATNR,       """Material Number
           MATKL TYPE MATKL,       """Material Group
           WERKS TYPE WERKS_D,     """Plant
           LFIMG TYPE LFIMG,       """Actual quantity delivered
           ARKTX TYPE ARKTX,       ""Short Text for Sales Order Item
*           VSTEL TYPE VSTEL,  ""shipment
         END OF TY_LIPS.

  TYPES: BEGIN OF TY_MAKT,
           MATNR TYPE MATNR,       """Material Number
           SPRAS TYPE SPRAS,       """Language Key
           MAKTX TYPE MAKTX,       """Material description
         END OF TY_MAKT.

  TYPES: BEGIN OF TY_ADRC,
           ADDRNUMBER TYPE AD_ADDRNUM,  """Address number
           NAME1      TYPE AD_NAME1,    """Name
           CITY1      TYPE AD_CITY1,    """City
           CITY2      TYPE AD_CITY2,    ""CITY2
           POST_CODE1 TYPE AD_PSTCD1,   """City postal code
           STREET     TYPE AD_STREET,   """Street
           HOUSE_NUM1 TYPE AD_HSNM1,    ""House Number
           STR_SUPPL1 TYPE AD_STRSPP1,  """Street 2
           STR_SUPPL2 TYPE AD_STRSPP2,  """Street 3
           STR_SUPPL3 TYPE AD_STRSPP3,  """Street 4
         END OF TY_ADRC.

  TYPES: BEGIN OF TY_T001W,
           WERKS      TYPE WERKS_D,    """Plant
           NAME1      TYPE NAME1,      """"Name
           LAND1      TYPE LAND1,      """Country Key
           REGIO      TYPE REGIO,      """Region
           ADRNR      TYPE ADRNR,      ""Address
           J_1BBRANCH TYPE J_1BBRANC_,   ""Business Place
         END OF TY_T001W.

*TYPES: BEGIN OF TY_T005U,
*       SPRAS TYPE SPRAS,      """Language Key
*       LAND1 TYPE LAND1,      """Country Key
*       BLAND TYPE REGIO,      """Region
*       BEZEI TYPE BEZEI20,    """Description
*  END OF TY_T005U."

  TYPES: BEGIN OF TY_J_1BBRANCH,
           BUKRS  TYPE BUKRS,
           BRANCH TYPE J_1BBRANC_,
           GSTIN  TYPE J_1IGSTCD3,
         END OF TY_J_1BBRANCH.

  TYPES: BEGIN OF TY_T023,
           MATKL TYPE MATKL,
         END OF TY_T023.

  TYPES: BEGIN OF TY_T023T,
           SPRAS TYPE SPRAS,
           MATKL TYPE MATKL,
           WGBEZ TYPE WGBEZ,
         END OF TY_T023T,

        BEGIN OF ty_t023t_1 ,
          matkl TYPE klasse_d,
          END OF ty_t023t_1,

         BEGIN OF ty_klah,
           clint TYPE KLAH-clint,
           klart TYPE klassenart,
           class TYPE klasse_d,
*           class TYPE matkl,
           END OF ty_klah,


         BEGIN OF ty_klah2,
           CLINT TYPE CLINT,
           klart TYPE klassenart,
           class TYPE klasse_d,
*           class TYPE matkl,
           END OF ty_klah2,


           BEGIN OF ty_kssk,
             objek TYPE cuobn,
             mafid TYPE klmaf,
             klart TYPE klassenart,
             clint TYPE clint,
             END OF ty_kssk,

             BEGIN OF TY_KSSK1 ,
*          OBJEK  TYPE CLINT,
               OBJEK TYPE CUOBN,
*          OBJEK1 TYPE KSSK-OBJEK,
        END OF TY_KSSK1 .



  TYPES: BEGIN OF TY_VTTP,
           TKNUM TYPE TKNUM,
           TPNUM TYPE TPNUM,
           VBELN TYPE VBELN_VL,
           ERNAM TYPE ERNAM,
         END OF TY_VTTP.

  TYPES: BEGIN OF TY_VTTK,
           TKNUM TYPE TKNUM,
           SIGNI TYPE SIGNI,
           EXTI1 TYPE EXTI1,
           EXTI2 TYPE EXTI2,
           TPBEZ TYPE TPBEZ,
           DTABF TYPE DTABF,
           TEXT1 TYPE VTTK_TEXT1,
           TEXT2 TYPE VTTK_TEXT2,
           TEXT3 TYPE VTTK_TEXT3,
           TPLST TYPE TPLST,
           TNDR_TRKID TYPE VTTK-TNDR_TRKID,
         END OF TY_VTTK.

  TYPES: BEGIN OF TY_VEPO,
           VENUM TYPE VENUM,
           VEPOS TYPE VEPOS,
           VBELN TYPE VBELN_VL,
           POSNR TYPE POSNR_VL,
           MATNR TYPE MATNR,
           VEMNG TYPE VEMNG,
           CHARG TYPE  CHARG_D,
           WERKS TYPE WERKS_D,
         END OF TY_VEPO.

  TYPES: BEGIN OF TY_VEKP,
           VENUM TYPE VENUM,
           EXIDV TYPE EXIDV,
           VHART TYPE VHIART,
           VHILM TYPE VHILM,
         END OF TY_VEKP.

  TYPES: BEGIN OF TY_TVTYT,
           SPRAS TYPE SPRAS,
           TRATY TYPE VHIART,
           VTEXT TYPE BEZEI20,
         END OF TY_TVTYT.

  TYPES: BEGIN OF TY_MARA,
           MATNR TYPE MATNR,
           MATKL TYPE MATKL,
         END OF TY_MARA.
         TYPES: BEGIN OF TY_VTTP1,
                TKNUM TYPE VTTP-TKNUM,
                TPNUM TYPE VTTP-TPNUM,
                VBELN TYPE VTTP-VBELN,
             END OF TY_VTTP1.

             TYPES : BEGIN OF ty_mbew,
                     matnr TYPE matnr,
                     BWKEY TYPE BWKEY,
                     BWTAR TYPE BWTAR_D,
                     VERPR TYPE VERPR,
               END OF ty_mbew.

* TYPES: BEGIN OF ty_makt,
*        MATNR TYPE MATNR,
*        SPRAS TYPE SPRAS,
*        MAKTX TYPE MAKTX,
*        MAKTG TYPE MAKTG,
*   END OF TY_MAKT.

*   TYPES : BEGIN OF ty_final2,
*           QUANTITY2 TYPE
*           VALUE2 T
*          MATKL2
*          PRODUCT


  DATA : IT_LIKP         TYPE TABLE OF TY_LIKP,
         WA_LIKP         TYPE TY_LIKP,
         IT_LIPS         TYPE TABLE OF TY_LIPS,
         WA_LIPS         TYPE TY_LIPS,
         IT_MAKT         TYPE TABLE OF TY_MAKT,
         WA_MAKT         TYPE TY_MAKT,
         IT_ADRC         TYPE TABLE OF TY_ADRC,
         IT_ADRC_T       TYPE TABLE OF TY_ADRC,
         WA_ADRC         TYPE TY_ADRC,
         WA_ADRC_T       TYPE TY_ADRC,
         IT_T001W        TYPE TABLE OF TY_T001W,
         IT_T001W_T      TYPE TABLE OF TY_T001W,
         WA_T001W        TYPE TY_T001W,
         WA_T001W_T      TYPE TY_T001W,
         IT_J_1BBRANCH   TYPE TABLE OF TY_J_1BBRANCH,
         IT_J_1BBRANCH_T TYPE TABLE OF TY_J_1BBRANCH,
         WA_J_1BBRANCH   TYPE TY_J_1BBRANCH,
         WA_J_1BBRANCH_T TYPE TY_J_1BBRANCH,
         IT_T023         TYPE TABLE OF TY_T023,
         WA_T023         TYPE TY_T023,
         IT_T023T        TYPE TABLE OF TY_T023T,
         WA_T023T        TYPE TY_T023T,
         it_t023t_1      TYPE  TABLE OF ty_t023t_1,
         wa_t023t_1      TYPE ty_t023t_1,
         it_t023t_2      TYPE  TABLE OF ty_t023t_1,
         wa_t023t_2      TYPE ty_t023t_1,
         it_klah     TYPE TABLE OF ty_klah,
         wa_klah TYPE ty_klah,
         IT_KLAH2 TYPE TABLE OF TY_KLAH,
         WA_KLAH2 TYPE TY_KLAH,
         it_kssk TYPE TABLE OF ty_kssk,
         wa_kssk TYPE ty_kssk,
         IT_KSSK1 TYPE TABLE OF TY_KSSK1,
         WA_KSSK1 TYPE  TY_KSSK1,
*         IT_KSSK_2 TYPE TY_KSSK,
          it_mbew TYPE TABLE OF ty_mbew,
          wa_mbew TYPE ty_mbew,


*         IT_makt        TYPE TABLE OF TY_makt,
*         WA_makt        TYPE  TY_makt,
         IT_VEPO         TYPE TABLE OF TY_VEPO,
         WA_VEPO         TYPE TY_VEPO,
         IT_VTTP         TYPE TABLE OF TY_VTTP,
         WA_VTTP         TYPE TY_VTTP,
         IT_VTTK         TYPE TABLE OF TY_VTTK,
         WA_VTTK         TYPE TY_VTTK,
         IT_VEKP         TYPE TABLE OF TY_VEKP,
         WA_VEKP         TYPE TY_VEKP,
         IT_MARA         TYPE TABLE OF TY_MARA,
         WA_MARA         TYPE TY_MARA,
         IT_FINAL        TYPE TABLE OF ZFINAL_DEL1,
         WA_HEADER       TYPE  ZHEADER_DEL,
         WA_FINAL        TYPE ZFINAL_DEL1,
         FM_NAME         TYPE  RS38L_FNAM,
         LV_TRAYS        TYPE I,
         LV_BUNDLES      TYPE I,
         LV_TOTAL        TYPE I,
         LV_VBELN        TYPE VBELN_VL,
         IT_TVTYT        TYPE TABLE OF TY_TVTYT,
         IT_WGH01        TYPE TABLE OF WGH01,
         WA_WGH01        TYPE WGH01,
         WA_TVTYT        TYPE TY_TVTYT,
         XVTTP           TYPE VTTP OCCURS 0 WITH HEADER LINE.
  DATA :IT_LIPS1 TYPE TABLE OF TY_LIPS,
        WA_LIPS1 TYPE  TY_LIPS.
  DATA: LV1(10) TYPE C,
        LV2(10) TYPE C,
        LV3(10) TYPE C,
        LV4(10) TYPE C,
        LV5(10) TYPE C,
        LV6(10) TYPE C.

  BREAK CLIKHITHA.
  LV_VBELN = NAST-OBJKY.
  SELECT * FROM VTTP
           INTO TABLE XVTTP
           WHERE TKNUM = LV_VBELN.

  SELECT VBELN
         VSTEL
         WERKS FROM LIKP INTO TABLE IT_LIKP
         FOR ALL ENTRIES IN XVTTP
         WHERE VBELN = XVTTP-VBELN.

  IF IT_LIKP IS NOT INITIAL.
    SELECT
      VBELN
      POSNR
      MATNR
      MATKL
      WERKS
      LFIMG
      ARKTX FROM LIPS INTO TABLE IT_LIPS
      FOR ALL ENTRIES IN IT_LIKP
      WHERE VBELN = IT_LIKP-VBELN AND PSTYV IN ('YNLN','NLN').
  ENDIF.

  IF IT_LIPS IS NOT INITIAL.

*    SELECT
*      MATNR
*      MATKL FROM MARA INTO TABLE IT_MARA
*      FOR ALL ENTRIES IN IT_LIPS
*      WHERE MATNR = IT_LIPS-MATNR.
*          AND VENUM IN ('23' , '24').
    SELECT
     VENUM
     VEPOS
     VBELN
     POSNR
     MATNR
     VEMNG
      CHARG
      WERKS FROM VEPO INTO TABLE IT_VEPO
     FOR ALL ENTRIES IN IT_LIPS
     WHERE VBELN = IT_LIPS-VBELN.

  ENDIF.
 if it_vepo is NOT INITIAL.
    SELECT matnr
           BWKEY
           BWTAR
           VERPR FROM mbew INTO TABLE it_mbew
           FOR ALL ENTRIES IN it_vepo
           WHERE matnr = it_vepo-matnr AND bwkey = it_vepo-werks AND bwtar = it_vepo-charg.
endif.





  IF IT_VEPO IS NOT INITIAL.
    SELECT
      VENUM
      EXIDV
      VHART
      VHILM FROM VEKP INTO TABLE IT_VEKP
      FOR ALL ENTRIES IN IT_VEPO
      WHERE VENUM = IT_VEPO-VENUM.
*        AND VENUM IN ('23' , '24').
    SELECT
    MATNR
    MATKL FROM MARA INTO TABLE IT_MARA
    FOR ALL ENTRIES IN IT_VEPO
    WHERE MATNR = IT_VEPO-MATNR.

    SELECT
    MATNR
    SPRAS
    MAKTX FROM MAKT INTO TABLE IT_MAKT
    FOR ALL ENTRIES IN IT_VEPO
    WHERE MATNR = IT_VEPO-MATNR.
  ENDIF.

  IF IT_VEKP IS NOT INITIAL.
    SELECT
      SPRAS
      TRATY
      VTEXT FROM TVTYT INTO TABLE IT_TVTYT
      FOR ALL ENTRIES IN IT_VEKP
      WHERE TRATY = IT_VEKP-VHART
      AND SPRAS = SY-LANGU.
  ENDIF.

  IF IT_MARA IS NOT INITIAL.
    SELECT
     MATKL FROM T023 INTO TABLE IT_T023
     FOR ALL ENTRIES IN IT_MARA
     WHERE MATKL = IT_MARA-MATKL.
  ENDIF.

  IF IT_T023 IS NOT INITIAL.
    SELECT
      SPRAS
      MATKL
      WGBEZ FROM T023T INTO TABLE IT_T023T
      FOR ALL ENTRIES IN IT_T023
      WHERE MATKL = IT_T023-MATKL.
  ENDIF.

  data(t023t_3) = it_t023t[].
  LOOP AT t023t_3 ASSIGNING FIELD-SYMBOL(<wa_t023t_3>).
    wa_t023t_1-matkl = <wa_t023t_3>-matkl.
    append wa_t023t_1 TO it_t023t_1.
    CLEAR : wa_t023t_1.
    ENDLOOP.
  if it_t023t_1 is NOT INITIAL.
    SELECT clint
           klart
           class
           FROM klah INTO TABLE it_klah
          FOR ALL ENTRIES IN it_t023t_1
         WHERE class = it_t023t_1-matkl AND klart = '026'.
    ENDIF.

   LOOP AT IT_KLAH ASSIGNING FIELD-SYMBOL(<WA_KLAHH>).
     WA_KSSK1-OBJEK = <WA_KLAHH>-CLINT.
     APPEND WA_KSSK1 TO IT_KSSK1.
     CLEAR : WA_KSSK1.
     ENDLOOP.

    SELECT OBJEK
           MAFID
           KLART
           CLINT
           FROM KSSK
           INTO TABLE IT_KSSK
           FOR ALL ENTRIES IN IT_KSSK1
           WHERE OBJEK = IT_KSSK1-OBJEK.

           SELECT CLINT
                  KLART
                  CLASS
                  FROM KLAH
                 INTO TABLE IT_KLAH2
                 FOR ALL ENTRIES IN IT_KSSK
                 WHERE CLINT = IT_KSSK-CLINT.






*  SORT IT_T023T BY MATKL.
  READ TABLE IT_LIKP INTO WA_LIKP INDEX 1.
  READ TABLE IT_LIPS INTO WA_LIPS INDEX 1.

  IF WA_LIKP IS NOT INITIAL.
    SELECT SINGLE
      WERKS
      NAME1
      LAND1
      REGIO
      ADRNR
      J_1BBRANCH
      FROM T001W INTO WA_T001W
      WHERE WERKS = WA_LIKP-WERKS.                         "'SSWH'.
**
**
**        SELECT SINGLE
**          VENUM
**          VEPOS
**          VBELN FROM VEPO INTO WA_VEPO
**          FOR ALL ENTRIES IN IT_LIPS
**          WHERE VBELN = WA_LIPS-VBELN
**          AND   VENUM = '22'.

    SELECT SINGLE
      TKNUM
      TPNUM
      VBELN
      ERNAM
      FROM VTTP INTO WA_VTTP
*          FOR ALL ENTRIES IN IT_LIPS
      WHERE VBELN = WA_LIPS-VBELN.
********************ADDED N (30-3-20)
   SELECT TKNUM
          TPNUM
          VBELN
           ERNAM    FROM VTTP INTO TABLE IT_VTTP
          FOR ALL ENTRIES IN XVTTP
          WHERE VBELN = XVTTP-VBELN.

*******************     END (30-3-20)
  ENDIF.
  IF WA_VTTP IS NOT INITIAL.
    SELECT SINGLE
      TKNUM
      SIGNI
      EXTI1
      EXTI2
      TPBEZ
      DTABF
      TEXT1
      TEXT2
      TEXT3
      TPLST
      TNDR_TRKID FROM VTTK INTO WA_VTTK
*          FOR ALL ENTRIES IN IT_VTTP
      WHERE TKNUM = WA_VTTP-TKNUM.
  ENDIF.
  IF WA_T001W IS NOT INITIAL.
    SELECT SINGLE
      BUKRS
      BRANCH
      GSTIN FROM J_1BBRANCH INTO WA_J_1BBRANCH
      WHERE BRANCH = WA_T001W-J_1BBRANCH  .                ""AND BUKRS = WA_VTTK-TPLST.

    SELECT SINGLE
      ADDRNUMBER
      NAME1
      CITY1
      CITY2
      POST_CODE1
      STREET
      HOUSE_NUM1
      STR_SUPPL1
      STR_SUPPL2
      STR_SUPPL3 FROM ADRC INTO WA_ADRC
      WHERE ADDRNUMBER = WA_T001W-ADRNR.
  ENDIF.




*    IF WA_VEPO IS NOT INITIAL.
*      SELECT SINGLE
*        VENUM
*        VHART FROM VEKP INTO WA_VEKP
*        FOR ALL ENTRIES IN IT_VEPO
*        WHERE VENUM = WA_VEPO-VENUM.
*    ENDIF.

*     IF WA_VEKP IS NOT INITIAL.
*      SELECT SINGLE
*        SPRAS
*        TRATY
*        VTEXT FROM TVTYT INTO WA_TVTYT
**        FOR ALL ENTRIES IN IT_VEKP
*        WHERE TRATY = WA_VEKP-VHART
*        AND SPRAS = SY-LANGU.
*     ENDIF.


  IF WA_LIKP IS NOT INITIAL.
    SELECT SINGLE
      WERKS
      NAME1
      LAND1
      REGIO
      ADRNR
      J_1BBRANCH FROM T001W INTO WA_T001W_T
      WHERE WERKS = WA_LIKP-VSTEL.                      ""'SFCP'.
  ENDIF.

  IF WA_T001W_T IS NOT INITIAL.
    SELECT SINGLE
      BUKRS
      BRANCH
      GSTIN  FROM J_1BBRANCH INTO WA_J_1BBRANCH_T
      WHERE BRANCH = WA_T001W_T-J_1BBRANCH .                          ""AND BUKRS = WA_VTTK-TPLST.

    SELECT SINGLE
       ADDRNUMBER
       NAME1
       CITY1
       CITY2
       POST_CODE1
       STREET
       HOUSE_NUM1
       STR_SUPPL1
       STR_SUPPL2
       STR_SUPPL3 FROM ADRC INTO WA_ADRC_T
      WHERE ADDRNUMBER = WA_T001W_T-ADRNR.
  ENDIF.

  IF IT_LIPS IS NOT INITIAL.

    SELECT  VBFA~VBELV , VBFA~POSNV , VBFA~VBTYP_N , VBFA~RFWRT , VBFA~VBTYP_V FROM VBFA INTO TABLE @DATA(IT_VBFA) FOR ALL ENTRIES IN @IT_LIPS
                                                                 WHERE VBELV = @IT_LIPS-VBELN AND POSNV =  @IT_LIPS-POSNR  AND VBTYP_N = 'R' AND VBTYP_V = 'J'.



  ENDIF.
*  BREAK CLIKHITHA.
  IF  IT_VTTP IS NOT INITIAL.
    SELECT  VBFA~VBELV , VBFA~POSNV , VBFA~VBTYP_N , VBFA~RFWRT , VBFA~VBTYP_V FROM VBFA INTO TABLE @DATA(IT_VBFA2) FOR ALL ENTRIES IN @IT_VTTP
                                                                 WHERE VBELV = @IT_VTTP-VBELN  AND VBTYP_N = 'R' ."AND VBTYP_V = 'J'.

******LOOP AT IT_VTTP2 ASSIGNING FIELD-SYMBOL(<wa_VTTP2>).
******wa_header-RFWRT_l = <wa_VTTP2>-RFWRT + wa_header-RFWRT_l.
******
******  ENDLOOP.

    ENDIF.
  BREAK BREDDY.
*  IT_LIPS1[] = IT_LIPS[].
*  SORT IT_LIPS1 BY VBELN MATNR.
*  DELETE ADJACENT DUPLICATES FROM IT_LIPS1 COMPARING VBELN MATNR.
*  LOOP AT IT_LIPS1 INTO WA_LIPS1.
*
*
*    WA_FINAL-ZSL_NO    = SY-TABIX.
*    READ TABLE IT_MAKT INTO WA_MAKT WITH KEY MATNR = WA_LIPS-MATNR.
*    IF SY-SUBRC = 0.
*      WA_FINAL-PRODUCT   = WA_MAKT-MAKTX.
*    ENDIF.
*
*
*
*    LOOP AT IT_LIPS INTO WA_LIPS WHERE VBELN = WA_LIPS1-VBELN AND MATNR = WA_LIPS1-MATNR.
*
*
*      READ TABLE IT_VBFA ASSIGNING FIELD-SYMBOL(<WA_VBFA>) WITH KEY VBELV = WA_LIPS-VBELN POSNV = WA_LIPS-POSNR .
*      IF SY-SUBRC = 0.
*
**      WA_FINAL-STOCK_V = WA_FINAL-STOCK_V +  <WA_VBFA>-RFWRT.
*        WA_HEADER-STOCK_V = WA_HEADER-STOCK_V + <WA_VBFA>-RFWRT .
*      ENDIF.
*      WA_FINAL-SAP_DC_NO = WA_LIPS-VBELN.
*      WA_FINAL-QUANTITY  = WA_FINAL-QUANTITY + WA_LIPS-LFIMG.
*
*      CLEAR: LV1, LV2, LV3.
*      LV1 = WA_FINAL-QUANTITY.
*      SPLIT LV1 AT '.' INTO LV2 LV3.
*      WA_FINAL-QUANTITY = LV2.
*
**      READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_LIPS-MATNR.
**
**      CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
**        EXPORTING
**          MATKL       = WA_MARA-MATKL
**          SPRAS       = SY-LANGU
**        TABLES
**          O_WGH01     = IT_WGH01
**        EXCEPTIONS
**          NO_BASIS_MG = 1
**          NO_MG_HIER  = 2
**          OTHERS      = 3.
**      IF SY-SUBRC <> 0.
*** Implement suitable error handling here
**      ENDIF.
**      READ TABLE IT_WGH01 INTO WA_WGH01 INDEX 1.
**      IF SY-SUBRC = 0.
**        WA_FINAL-WWGHB = WA_WGH01-WWGHB.
**      ENDIF.
*
*
*
*
*      CLEAR: WA_T023, WA_T023T.
*      READ TABLE IT_T023 INTO WA_T023 WITH KEY MATKL = WA_LIPS-MATKL.
*
*      READ TABLE IT_T023T INTO WA_T023T WITH KEY MATKL = WA_T023-MATKL.
**
*      IF SY-SUBRC = 0.
*        WA_FINAL-WGBEZ = WA_T023T-WGBEZ.
*      ENDIF.
*
***    CLEAR:WA_VEPO, WA_VEKP,WA_TVTYT.
***    READ TABLE IT_VEPO INTO WA_VEPO WITH KEY VBELN = WA_LIPS-VBELN POSNR = WA_LIPS-POSNR.
***    READ TABLE IT_VEKP INTO WA_VEKP WITH KEY VENUM = WA_VEPO-VENUM.
***
***
***    CASE WA_VEKP-VHART.
***      WHEN '0004'.
***        READ TABLE IT_TVTYT INTO WA_TVTYT WITH KEY TRATY = WA_VEKP-VHART SPRAS = SY-LANGU.
***        WA_FINAL-TRAYS = WA_TVTYT-VTEXT.
***        WA_FINAL-BUNDLES = 'Nill'.
***        LV_TRAYS = LV_TRAYS + 1.
***      WHEN '0005'.
***        READ TABLE IT_TVTYT INTO WA_TVTYT WITH KEY TRATY = WA_VEKP-VHART SPRAS = SY-LANGU.
***        WA_FINAL-BUNDLES = WA_TVTYT-VTEXT."
*      LOOP AT IT_VEPO INTO WA_VEPO WHERE VBELN = WA_LIPS-VBELN AND POSNR = WA_LIPS-POSNR .             "AND MATNR = WA_LIPS-MATNR.
*
*        READ TABLE IT_VEKP INTO WA_VEKP WITH KEY VENUM = WA_VEPO-VENUM.
*        IF WA_VEKP-VHART = 'Z001'.
*          WA_FINAL-TRAYS =   WA_VEKP-EXIDV.                                 ""WA_FINAL-TRAYS + 1.
*          WA_FINAL-BUNDLES = 'Nill'.
*          LV_TRAYS = LV_TRAYS + 1.
*        ELSEIF WA_VEKP-VHART = 'Z002'.
*          WA_FINAL-BUNDLES =  WA_VEKP-EXIDV.                               ""WA_FINAL-BUNDLES + 1.
*          WA_FINAL-TRAYS = 'Nill'.
*          LV_BUNDLES = LV_BUNDLES + 1.
*        ENDIF.
*
*      ENDLOOP.

*  LV_TOTAL = LV_TRAYS +  LV_BUNDLES.
*  WA_HEADER-TOT_QUAN = WA_HEADER-TOT_QUAN + WA_FINAL-QUANTITY.
*  LV4 = WA_HEADER-TOT_QUAN.
*  SPLIT LV4 AT '.' INTO LV5 LV6.
*  WA_HEADER-TOT_QUAN = LV5.
*  APPEND WA_FINAL TO IT_FINAL.
*  CLEAR: WA_FINAL.
*ENDLOOP.
*ENDLOOP.
  DATA(IT_VEPO1) = IT_VEPO.
  SORT IT_VEPO1 BY VENUM MATNR .
*  SORT IT_T023 BY MATKL.
*  SORT IT_T023T BY MATKL.
  DELETE ADJACENT DUPLICATES FROM IT_VEPO1 COMPARING VENUM MATNR.
  REFRESH : IT_FINAL.
  LOOP AT IT_VEPO1 INTO WA_VEPO .

    WA_FINAL-ZSL_NO    = SY-TABIX.
*    SORT IT_VEPO BY MATNR.
    LOOP AT IT_VEPO ASSIGNING FIELD-SYMBOL(<WA_VEPO1>) WHERE VENUM = WA_VEPO-VENUM AND MATNR = WA_VEPO-MATNR.
*      SORT IT_MAKT BY MAKTX.
      READ TABLE IT_MAKT INTO WA_MAKT WITH KEY MATNR = <WA_VEPO1>-MATNR.
      IF SY-SUBRC = 0.
        WA_FINAL-PRODUCT = WA_MAKT-MAKTX.
        WA_FINAL-SAP_DC_NO = <WA_VEPO1>-VBELN.    " commented on (16-5-20)
      ENDIF.

      ADD <WA_VEPO1>-VEMNG TO WA_FINAL-QUANTITY.

      READ TABLE IT_VEKP INTO WA_VEKP WITH KEY VENUM = <WA_VEPO1>-VENUM .
*      LV_TOTAL = WA_VEKP-VENUM + 1.
      IF WA_VEKP-VHART = 'Z001'.
*        WA_HEADER-HED = 'Trays'.
        WA_FINAL-TRAYS =   WA_VEKP-EXIDV.                                 ""WA_FINAL-TRAYS + 1.
        WA_FINAL-BUNDLES = WA_VEKP-VHILM.
*          LV_TRAYS = LV_TRAYS + 1.

      ELSEIF WA_VEKP-VHART = 'Z002'.
        WA_FINAL-BUNDLES =  WA_VEKP-EXIDV.                               ""WA_FINAL-BUNDLES + 1.
*        WA_HEADER-HED = 'Bundles'.
        WA_FINAL-TRAYS =   WA_VEKP-EXIDV.
        WA_FINAL-BUNDLES = WA_VEKP-VHILM.                              ""packeging material
*          WA_FINAL-TRAYS = 'Nill'.
*          LV_BUNDLES = LV_BUNDLES + 1.
      ENDIF.
******************     added on (16-6-20)
*      break clikhitha.
      READ TABLE it_mbew INTO wa_mbew with key
      matnr = <WA_VEPO1>-matnr   bwtar = <WA_VEPO1>-charg bwkey = <wa_vepo1>-werks .
      if sy-subrc = 0.
        WA_FINAL-VAL = wa_mbew-verpr.
        WA_FINAL-VALUE = wa_final-quantity * WA_FINAL-VAL.
*        WA_HEADER-TOTVAL = WA_HEADER-TOTVAL + WA_FINAL-VALUE.

        ENDIF.

******************      end(16-6-20)
*************      ADDED ON (30-3-20)   *************
      READ TABLE  IT_VBFA2 ASSIGNING FIELD-SYMBOL(<wa_VBFA2>) WITH KEY VBELV = <WA_VEPO1>-VBELN.
      IF SY-SUBRC = 0.
*     WA_FINAL-VALUE = <wa_VBFA2>-RFWRT.
     wa_header-RFWRT_l = <wa_VBFA2>-RFWRT + wa_header-RFWRT_l.
        ENDIF.
***************      END(30-3-20)   ************
    ENDLOOP.
    READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = <WA_VEPO1>-MATNR.

    CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
      EXPORTING
        MATKL       = WA_MARA-MATKL
        SPRAS       = SY-LANGU
      TABLES
        O_WGH01     = IT_WGH01
      EXCEPTIONS
        NO_BASIS_MG = 1
        NO_MG_HIER  = 2
        OTHERS      = 3.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
    READ TABLE IT_WGH01 INTO WA_WGH01 INDEX 1.
    IF SY-SUBRC = 0.
      WA_FINAL-WWGHB = WA_WGH01-WWGHB.
    ENDIF.

    READ TABLE IT_T023 INTO WA_T023 WITH KEY MATKL = WA_MARA-MATKL.
*    SORT IT_T023 BY MATKL.
    READ TABLE IT_T023T INTO WA_T023T WITH KEY MATKL = WA_T023-MATKL.
*    SORT IT_T023T BY MATKL.
    IF SY-SUBRC = 0.
      WA_FINAL-WGBEZ = WA_T023T-WGBEZ.
      wa_final-MATKL = WA_T023T-matkl.
      WA_FINAL-MATKL_1 = WA_T023T-MATKL.
    ENDIF.
**    BREAK CLIKHITHA.
    READ TABLE IT_KLAH INTO WA_KLAH WITH KEY CLASS = WA_FINAL-MATKL_1 KLART = '026'.
     WA_FINAL-OBJ_L = WA_KLAH-CLINT.
     READ TABLE IT_KSSK INTO WA_KSSK WITH KEY OBJEK = WA_FINAL-OBJ_L.
     READ TABLE IT_KLAH2 INTO WA_KLAH2 WITH KEY CLINT = WA_KSSK-CLINT.
     WA_FINAL-CLASS = WA_KLAH2-CLASS.
*    READ TABLE IT_KLAH2 INTO WA_KLAH2 WITH KEY
*  ENDLOOP.
    WA_HEADER-TOT_QUAN =  WA_HEADER-TOT_QUAN + WA_FINAL-QUANTITY.
    WA_HEADER-TOTVAL = WA_HEADER-TOTVAL + WA_FINAL-VALUE.
*    WA_FINAL-ZSL_NO    = SY-TABIX.
    APPEND WA_FINAL TO IT_FINAL.
    CLEAR :WA_FINAL.
    CLEAR : WA_T023, WA_T023T, WA_VEPO , WA_MARA , WA_MAKT.
  ENDLOOP.

******************added on (16-5-20)
*break clikhitha.
*SORT IT_FINAL BY MATKL.
*  data(it_final1) = it_final[].
*  DElete ADJACENT DUPLICATES FROM it_final1 COMPARING matkl.
*  DELETE ADJACENT DUPLICATES FROM IT_final COMPARING matkl wgbez product."sap_dc_no..
******************end(16-5--20)



  BREAK BREDDY.
*  DATA(IT_VEPO2) = IT_VEPO.
*  SORT IT_VEPO BY VENUM.
*  DELETE ADJACENT DUPLICATES FROM IT_VEPO2 COMPARING VENUM.
*  READ TABLE IT_VEPO INTO WA_VEPO INDEX 1.
  LOOP AT IT_VEKP ASSIGNING FIELD-SYMBOL(<WA_VEKP1>).
*    READ TABLE IT_VEKP ASSIGNING FIELD-SYMBOL(<WA_VEKP1>) WITH KEY VENUM = <WA_VEPO2>-VENUM.

    IF <WA_VEKP1>-VHART = 'Z001'.

      LV_TRAYS = LV_TRAYS + 1.

    ELSEIF <WA_VEKP1>-VHART = 'Z002'.

      LV_BUNDLES = LV_BUNDLES + 1.
    ENDIF.

  ENDLOOP.

  LV_TOTAL = LV_TRAYS + LV_BUNDLES.

*CLEAR: WA_T023, WA_T023T.
*READ TABLE IT_T023 INTO WA_T023 WITH KEY MATKL = WA_LIPS-MATKL.
*READ TABLE IT_T023T INTO WA_T023T WITH KEY MATKL = WA_T023T-MATKL.
*
*  IF SY-SUBRC = 0.
*    WA_FINAL-WGBEZ = WA_T023T-WGBEZ.
*  ENDIF.

*  CLEAR:WA_VEPO, WA_VEKP,WA_TVTYT.
*  READ TABLE IT_VEPO INTO WA_VEPO WITH KEY VBELN = WA_LIPS-VBELN POSNR = WA_LIPS-POSNR.
*  READ TABLE IT_VEKP INTO WA_VEKP WITH KEY VENUM = WA_VEPO-VENUM.
*
*
*  CASE WA_VEKP-VHART.
*    WHEN '0004'.
*      READ TABLE IT_TVTYT INTO WA_TVTYT WITH KEY TRATY = WA_VEKP-VHART SPRAS = SY-LANGU.
*      WA_FINAL-TRAYS = WA_TVTYT-VTEXT.
*      WA_FINAL-BUNDLES = 'Nill'.
*      LV_TRAYS = LV_TRAYS + 1.
*    WHEN '0005'.
*      READ TABLE IT_TVTYT INTO WA_TVTYT WITH KEY TRATY = WA_VEKP-VHART SPRAS = SY-LANGU.
*      WA_FINAL-BUNDLES = WA_TVTYT-VTEXT.
*      WA_FINAL-TRAYS = 'Nill'.
*      LV_BUNDLES = LV_BUNDLES + 1.
*  ENDCASE.
*  LV_TOTAL = LV_TRAYS +  LV_BUNDLES.
*
*  APPEND WA_FINAL TO IT_FINAL.
*
*  CLEAR: WA_FINAL.
  WA_HEADER-ERNAM_L           = WA_VTTP-ERNAM.
  WA_HEADER-ADDRESS_TO      = WA_ADRC_T-ADDRNUMBER.
  WA_HEADER-NAME_TO         = WA_ADRC_T-NAME1.
  WA_HEADER-CITY_TO         = WA_ADRC_T-CITY1.
  WA_HEADER-POST_CODE_TO    = WA_ADRC_T-POST_CODE1.
  WA_HEADER-STREET_TO       = WA_ADRC_T-STREET.
  WA_HEADER-HOUSE_NUM_TO    = WA_ADRC_T-HOUSE_NUM1.
  WA_HEADER-GSTIN_TO        = WA_J_1BBRANCH_T-GSTIN.
  WA_HEADER-ADDRESS_FROM    = WA_ADRC-ADDRNUMBER.
  WA_HEADER-STR_SUPPL1_F    = WA_ADRC-STR_SUPPL1.
  WA_HEADER-STR_SUPPL2_F    = WA_ADRC-STR_SUPPL2.
  WA_HEADER-CITY2           = WA_ADRC-CITY2.
  WA_HEADER-NAME_FROM       = WA_ADRC-NAME1.
  WA_HEADER-CITY_FROM       = WA_ADRC-CITY1.
  WA_HEADER-POST_CODE_FROM  = WA_ADRC-POST_CODE1.
  WA_HEADER-STREET_FROM     = WA_ADRC-STREET.
  WA_HEADER-HOUSE_NUM_FROM  = WA_ADRC-HOUSE_NUM1.
  WA_HEADER-GSTIN_FROM      = WA_J_1BBRANCH-GSTIN.
  WA_HEADER-DESP_DAT        = WA_VTTK-DTABF.
  WA_HEADER-GATE_NO         = WA_VTTK-TEXT3.
  WA_HEADER-LOT_NO          = WA_VTTK-TEXT1.
  WA_HEADER-TNDR_TRKID      = WA_VTTK-TNDR_TRKID.
  WA_HEADER-TRANS_NAME      = WA_VTTK-TPBEZ.
  WA_HEADER-DR_NAME         = WA_VTTK-EXTI1.
  WA_HEADER-CON_NO          = WA_VTTK-EXTI2.
  WA_HEADER-VEH_NO          = WA_VTTK-SIGNI.
  WA_HEADER-SEAL_NO         = WA_VTTK-EXTI2.
  WA_HEADER-NO_TRAYS        = LV_TRAYS.
  WA_HEADER-NO_BUND         = LV_BUNDLES.
  WA_HEADER-LV_TOTAL        = LV_TOTAL.
  WA_HEADER-TOT_QTY         = WA_LIPS-LFIMG.
  WA_HEADER-SHP_NO          = LV_VBELN.

*BREAK-POINT.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZSD_SHIPMENT_PACKING_LIST'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      FM_NAME            = FM_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL FUNCTION FM_NAME
    EXPORTING
      WA_HEADER        = WA_HEADER
      LV_TRAYS         = LV_TRAYS
      LV_BUNDLES       = LV_BUNDLES
      LV_VBELN         = LV_VBELN
    TABLES
      IT_FINAL         = IT_FINAL
    EXCEPTIONS
      FORMATTING_ERROR = 1
      INTERNAL_ERROR   = 2
      SEND_ERROR       = 3
      USER_CANCELED    = 4
      OTHERS           = 5.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
