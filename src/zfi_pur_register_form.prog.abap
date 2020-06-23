*&---------------------------------------------------------------------*
*& Include          ZFI_PUR_REGISTER_FORM
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form FI_POSTING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Include          ZFI_PUR_REGISTER_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form FETCH_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*

FORM FETCH_DATA.

  SELECT EBELN
        BELNR
        BEWTP
        BUDAT
        WERKS
        GJAHR
        FROM EKBE INTO TABLE IT_EKBE
        WHERE BELNR IN S_BELNR
*        AND BUDAT IN S_BUDAT
        AND GJAHR = P_GJAHR
        AND WERKS IN S_WERKS.
*        AND BEWTP IN ('Q','N') .

  SORT IT_EKBE BY BELNR.

  IF NOT IT_EKBE IS INITIAL.

***    SELECT BUKRS
***           BELNR
***           GJAHR
***           CPUDT
***           CPUTM
***           BLART
***           BLDAT
***           USNAM
***           WAERS
***           MONAT
***           KURSF
***           AWKEY
***           XBLNR FROM BKPF INTO TABLE IT_BKPF
***                 WHERE GJAHR = P_GJAHR
****                 AND BELNR = IT_EKBE-BELNR AND
***                and BLART IN ( 'KG', 'KR', 'KA' )
***                 AND BLDAT IN S_BLDAT.
**ENDIF.

**IF IT_BKPF IS NOT INITIAL.

    SELECT BELNR
           GJAHR
           BLDAT
           BUDAT
           XBLNR
           LIFNR
           WAERS
           KURSF
           BEZNK
           WMWST1
           XRECH
           SGTXT
           BUKRS
           BKTXT
           GSBER
*           SGTXT
           FROM RBKP INTO TABLE IT_RBKP
           FOR ALL ENTRIES IN IT_EKBE
           WHERE BELNR = IT_EKBE-BELNR "IN S_belnr
           AND   BLDAT IN S_BLDAT
           AND   GJAHR IN S_GJAHR.
*           AND   GSBER IN S_GSBER." AND BLART IN ( 'KR', 'KG', 'KA' ).
ENDIF.

  IF NOT IT_RBKP IS INITIAL.

    SELECT BELNR
           BUKRS
           GJAHR
           BUZEI
           EBELN
           EBELP
           MATNR
           WERKS
           WRBTR
           MWSKZ
           MENGE
           MEINS
           LFBNR
           HSN_SAC  "hsn code
           XBLNR
           KSCHL
           SHKZG
           FROM RSEG
           INTO TABLE IT_RSEG
           FOR ALL ENTRIES IN IT_RBKP
           WHERE  BELNR = IT_RBKP-BELNR
           AND   BUKRS = P_BUKRS
           AND   GJAHR IN S_GJAHR.
*           AND   MATNR IN S_MATNR.
*       and    BUZEI = it_rseg-BUZEI.
*SORT IT_RSEG BY EBELN EBELP.
*DELETE ADJACENT DUPLICATES FROM IT_RSEG COMPARING EBELN EBELP.

    SELECT LIFNR
           REGIO
           ADRNR
           STCD1
           J_1ILSTNO
           LAND1
           STCD3
           FROM LFA1
           INTO TABLE IT_LFA1
    FOR ALL ENTRIES IN IT_RBKP
    WHERE LIFNR = IT_RBKP-LIFNR.

    SELECT BELNR
           BUKRS
           GJAHR
           BUZEI
           EBELN
           EBELP
           MATNR
           WERKS
           WRBTR
           MWSKZ
           MENGE
           MEINS
           LFBNR
           HSN_SAC  "hsn code
           XBLNR
           KSCHL
           SHKZG
           FROM RSEG
           INTO TABLE IT_RSEG1
           FOR ALL ENTRIES IN IT_EKBE
           WHERE  EBELN = IT_EKBE-EBELN
           AND   BUKRS = P_BUKRS
           AND   GJAHR IN S_GJAHR.

  ENDIF.

  IF IT_LFA1 IS NOT INITIAL.

    SELECT LIFNR
           LICHA FROM MCH1 INTO TABLE IT_MCH1
                 FOR ALL ENTRIES IN IT_LFA1
                 WHERE LIFNR = IT_LFA1-LIFNR.

    SELECT
      SPRAS
      LAND1
      LANDX50 FROM T005T INTO TABLE IT_T005T
      FOR ALL ENTRIES IN IT_LFA1
      WHERE SPRAS = SY-LANGU AND LAND1 = IT_LFA1-LAND1.

    SELECT ADDRNUMBER
           NAME1
           CITY1 FROM ADRC
           INTO TABLE IT_ADRC
    FOR ALL ENTRIES IN IT_LFA1
    WHERE ADDRNUMBER = IT_LFA1-ADRNR.

  ENDIF.
  IF NOT IT_RSEG IS INITIAL.
****************************************************************
    SELECT
       EBELN
       EBELP
       MENGE
       NETWR FROM EKPO INTO TABLE IT_EKPO
             FOR ALL ENTRIES IN IT_RSEG
             WHERE EBELN = IT_RSEG-EBELN AND EBELP = IT_RSEG-EBELP.

    IF IT_EKPO IS NOT INITIAL.
      SELECT
        EBELN
        EBELP
        EINDT FROM EKET INTO TABLE IT_EKET
              FOR ALL ENTRIES IN IT_EKPO
              WHERE EBELN = IT_EKPO-EBELN.
    ENDIF.

**********************************************************
*BREAK KKUMAR.
    SELECT MBLNR
           MJAHR
           ZEILE
           EBELN
           EBELP
           BUDAT_MKPF
           VBELN_IM
           BWART
           LGORT
           MENGE
           DMBTR
           SHKZG
           FROM MSEG INTO TABLE IT_MSEG
           FOR ALL ENTRIES IN IT_RSEG
           WHERE EBELN = IT_RSEG-EBELN
           AND   EBELP = IT_RSEG-EBELP.
*           AND   BWART IN S_BWART.
*           AND   LGORT IN S_LGORT.

    DELETE IT_MSEG WHERE BWART BETWEEN '103' AND '104'.

IF IT_MSEG IS NOT INITIAL.
  SELECT MBLNR
         MJAHR
         FRBNR FROM MKPF INTO TABLE IT_MKPF
               FOR ALL ENTRIES IN  IT_MSEG
               WHERE MBLNR = IT_MSEG-MBLNR AND MJAHR = IT_MSEG-MJAHR.
ENDIF.
    TYPES: BEGIN OF TT,
             BELNR       TYPE RSEG-BELNR,
             V_AWKEY(20) TYPE C,
           END OF TT.

    DATA: IT TYPE STANDARD TABLE OF TT,
          WA TYPE TT.
    DATA: AWKEY TYPE STRING.

    LOOP AT IT_RSEG INTO WA_RSEG.
      CONCATENATE WA_RSEG-BELNR WA_RSEG-GJAHR INTO AWKEY.
      MOVE AWKEY TO WA-V_AWKEY.
      MOVE WA_RSEG-BELNR TO WA-BELNR.
      APPEND WA TO IT.
      SORT IT BY V_AWKEY.
      DELETE ADJACENT DUPLICATES FROM IT COMPARING BELNR.
    ENDLOOP.


    IF NOT IT IS INITIAL.
      SELECT BUKRS
             BELNR
             GJAHR
             BUZEI
             BSCHL
             KOART
             MWSKZ
             HKONT
             BUPLA
             SHKZG
             DMBTR
             WRBTR
             MENGE
             EBELN
             EBELP
             MATNR
             TAXPS
             TXGRP
             AWKEY
             VBELN
             ZUONR
             FROM BSEG INTO TABLE IT_BSEG
             FOR ALL ENTRIES IN IT
             WHERE  AWKEY = IT-V_AWKEY
*    AND    GJAHR = IT_RSEG-GJAHR
            AND   BSCHL IN ( '86','96','31', '21', '89', '99', '70', '75' )
            AND   BUKRS = P_BUKRS.
*      SORT IT_BSEG BY BELNR.
*      DELETE ADJACENT DUPLICATES FROM IT_BSEG COMPARING BELNR.

*      SELECT BUKRS
*              BELNR
*              GJAHR
*              BUZEI
*              BSCHL
*              MWSKZ
*              HKONT
*              BUPLA
*              SHKZG
*              WRBTR
*              MENGE
*              EBELN
*              EBELP
*              MATNR
*              TAXPS
*              AWKEY
*              FROM BSEG
*              INTO TABLE IT_DEBIT
*              FOR ALL ENTRIES IN IT
*              WHERE  AWKEY = IT-V_AWKEY
*              AND BSCHL = '50'
*              AND   HKONT = '0000238910'.
**              AND   GJAHR = P_GJAHR.

    ENDIF.
    IF IT_BSEG IS NOT INITIAL.
      SELECT BUKRS
             BELNR
             GJAHR
             CPUDT
             CPUTM
             BLART
             BLDAT
             USNAM
             WAERS
             MONAT
             KURSF
             AWKEY
             XBLNR FROM BKPF INTO TABLE IT_BKPF FOR ALL ENTRIES IN IT_BSEG
                   WHERE BELNR = IT_BSEG-BELNR
                   AND   BUKRS = IT_BSEG-BUKRS
                   AND   GJAHR = IT_BSEG-GJAHR.
    ENDIF.
    SELECT MATNR
           MAKTX
           FROM MAKT INTO TABLE IT_MAKT
           FOR ALL ENTRIES IN IT_RSEG
           WHERE MATNR = IT_RSEG-MATNR.

    SELECT MATNR
           MATKL
           MFRPN FROM MARA INTO TABLE IT_MARA
                 FOR ALL ENTRIES IN IT_RSEG
                 WHERE MATNR = IT_RSEG-MATNR.
*                 AND   MATKL IN S_MATKL.

    SELECT
      MATNR
      WERKS
      STEUC
      FROM MARC INTO TABLE IT_MARC
      FOR ALL ENTRIES IN IT_MARA
      WHERE MATNR = IT_MARA-MATNR.


  ENDIF.

  IF NOT IT_BSEG IS INITIAL.

    SELECT BUKRS
           BELNR
           GJAHR
           BUZEI
           MWSKZ
           HWBAS
           HWSTE
           HKONT
           TAXPS
           TXGRP
           KSCHL
           SHKZG
           FROM BSET
           INTO TABLE IT_BSET
           FOR ALL ENTRIES IN IT_BSEG
    WHERE BELNR = IT_BSEG-BELNR
    AND   GJAHR = IT_BSEG-GJAHR
    AND   BUKRS = P_BUKRS.
  ENDIF.
**SORT IT_BSET BY BELNR TXGRP.
**DELETE ADJACENT DUPLICATES FROM IT_BSET COMPARING BELNR TXGRP.

  SELECT SINGLE NAME1 FROM T001W INTO LV_NAME1
      WHERE WERKS = S_WERKS-LOW.

  SELECT EBELN
         KNUMV
         RLWRT
         BSART FROM EKKO INTO TABLE IT_EKKO
               FOR ALL ENTRIES IN IT_RSEG
               WHERE EBELN = IT_RSEG-EBELN.
  IF IT_EKKO IS NOT INITIAL.
    SELECT KNUMV
           KPOSN
           KSCHL
           KNUMH
           KOPOS
           KWERT
           KBETR
           MWSK1 FROM PRCD_ELEMENTS INTO TABLE IT_PRCD
                 FOR ALL ENTRIES IN IT_EKKO
                 WHERE KNUMV = IT_EKKO-KNUMV.
    DELETE IT_PRCD WHERE KWERT IS INITIAL.
  ENDIF.
***********************************************************************************
  IF IT_MSEG IS NOT INITIAL.
*    SELECT MBLNR
*           MJAHR
*           ZLR_NO
*           ZLR_DATE
*           ZVEHICLE
*           ZTRNPRT  FROM ZGEMIGO INTO TABLE IT_ZGEMIGO
*                    FOR ALL ENTRIES IN IT_MSEG
*                    WHERE MBLNR = IT_MSEG-MBLNR
*                    AND   MJAHR = IT_MSEG-MJAHR.
  ENDIF.

***********************************************************************************
*  BREAK PPADHY.
  SORT IT_MSEG BY EBELN .                     "MBLNR.              "ADDED MBLNR BY N
*************************************************************************************
*  BREAK BBARAL.
*  LOOP AT IT_RSEG INTO WA_RSEG.
*    READ TABLE IT_MSEG INTO WA_MSEG WITH KEY EBELN = WA_RSEG-EBELN EBELP = WA_RSEG-EBELP.
LOOP AT IT_RSEG INTO WA_RSEG.
  READ TABLE IT_MSEG INTO WA_MSEG WITH  KEY EBELN = WA_RSEG-EBELN  EBELP = WA_RSEG-EBELP ZEILE = wa_rseg-BUZEI .
  IF sy-subrc = 0 .

    WA_FINAL-MBLNR    = WA_MSEG-MBLNR.
    WA_FINAL-BUDAT1   = WA_MSEG-BUDAT_MKPF.
    WA_FINAL-VBELN_IM = WA_MSEG-VBELN_IM.
    WA_FINAL-BWART    = WA_MSEG-BWART.
    WA_FINAL-LGORT    = WA_MSEG-LGORT.
    WA_FINAL-MENGE1   = WA_MSEG-MENGE.
    WA_FINAL-DMBTR    = WA_MSEG-DMBTR.

  ENDIF.
    READ TABLE IT_MKPF INTO WA_MKPF WITH KEY MBLNR = WA_MSEG-MBLNR.
    IF SY-SUBRC = 0.
      WA_FINAL-FRBNR = WA_MKPF-FRBNR.
    ENDIF.

    READ TABLE IT_EKPO INTO WA_EKPO WITH KEY EBELN = WA_RSEG-EBELN EBELP = WA_RSEG-EBELP .

    IF SY-SUBRC = 0.
      WA_FINAL-MENGE_P = WA_FINAL-MENGE_P + WA_EKPO-MENGE.
    ENDIF.

    READ TABLE IT_EKET INTO WA_EKET WITH KEY EBELN = WA_EKPO-EBELN.
    IF SY-SUBRC = 0.
      WA_FINAL-EINDT = WA_EKET-EINDT.
    ENDIF.
**************************************************************************************
    READ TABLE IT_RBKP INTO WA_RBKP WITH KEY BELNR = WA_RSEG-BELNR.
    IF SY-SUBRC = 0.
*      WA_FINAL-BELNR = WA_RBKP-BELNR.
      WA_FINAL-BLDAT = WA_RBKP-BLDAT. "DOCUMENT DATE
      WA_FINAL-BUDAT = WA_RBKP-BUDAT. " POSTING DATE
      WA_FINAL-XBLNR = WA_RBKP-XBLNR. " REFERENCE NUMBER
      WA_FINAL-LIFNR = WA_RBKP-LIFNR. "Invoicing Party
      WA_FINAL-WAERS = WA_RBKP-WAERS . "Currency
      WA_FINAL-BUKRS = WA_RBKP-BUKRS.
      WA_FINAL-BKTXT = WA_RBKP-BKTXT.
      WA_FINAL-SGTXT = WA_RBKP-SGTXT.
*        WA_FINAL-WMWST1 = WA_RBKP-WMWST1. " TAX AMAOUNT
    ENDIF.

*    READ TABLE IT_RSEG INTO WA_RSEG WITH KEY EBELN = WA_MSEG-EBELN EBELP = WA_MSEG-EBELP.

*    IF SY-SUBRC = 0.

      WA_FINAL-BELNR = WA_RSEG-BELNR.
      WA_FINAL-GJAHR = WA_RSEG-GJAHR.
      WA_FINAL-BUKRS = WA_RSEG-BUKRS.
      WA_FINAL-BUZEI = WA_RSEG-BUZEI. "Document Item in Invoice Document
      WA_FINAL-EBELN = WA_RSEG-EBELN. "PURCHASE ORDER
      WA_FINAL-EBELP = WA_RSEG-EBELP. "Item Number of Purchasing Document
      WA_FINAL-MATNR = WA_RSEG-MATNR. " Material number
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = WA_FINAL-MATNR
        IMPORTING
          OUTPUT = WA_FINAL-MATNR.

      WA_FINAL-WERKS = WA_RSEG-WERKS. "PLANT
      WA_FINAL-MEINS = WA_RSEG-MEINS. "UOM
*      WA_FINAL-XEKBZ = WA_RSEG-XEKBZ. "unplanned delivery cost
      WA_FINAL-WRBTR = WA_RSEG-WRBTR. " Gross amount
      WA_FINAL-MWSKZ = WA_RSEG-MWSKZ. " Tax Code

  IF WA_RSEG-SHKZG = 'S'.                                          "  ADDED BY N

      WA_FINAL-MENGE = WA_RSEG-MENGE. "QUANTITY
 ELSEIF WA_RSEG-SHKZG  = 'H'.
   WA_FINAL-MENGE = WA_RSEG-MENGE * ( -1 ).
   ENDIF.


*      WA_FINAL-G_AMT = WA_RSEG-WRBTR * WA_RSEG-MENGE.

*    ENDIF.


    READ TABLE IT_EKKO INTO WA_EKKO WITH KEY EBELN = WA_RSEG-EBELN.
    IF SY-SUBRC = 0.
      WA_FINAL-NETWR = WA_EKKO-RLWRT.
      WA_FINAL-BSART = WA_EKKO-BSART.
    ENDIF.

    READ TABLE IT_PRCD INTO WA_PRCD
               WITH KEY KNUMV = WA_EKKO-KNUMV
                        KPOSN = WA_RSEG-EBELP
                        KSCHL = 'FRB2'.
    IF SY-SUBRC = 0.
      IF WA_RSEG-SHKZG = 'H'.
        WA_FINAL-FREIGHT = WA_PRCD-KWERT * -1.
      ELSE.
        WA_FINAL-FREIGHT = WA_PRCD-KWERT.
      ENDIF.
*      lv_freight  = ( wa_prcd-kwert / wa_final-netwr ) * 100.
*      wa_final-freight =  ( wa_final-wrbtr * lv_freight ) / 100.
    ELSE.
      READ TABLE IT_PRCD INTO WA_PRCD
             WITH KEY KNUMV = WA_EKKO-KNUMV
                      KPOSN = WA_RSEG-EBELP
                      KSCHL = 'FRB1'.
     IF SY-SUBRC = 0.
      IF WA_RSEG-SHKZG = 'H'.
        WA_FINAL-FREIGHT = WA_PRCD-KWERT * -1.
      ELSE.
        WA_FINAL-FREIGHT = WA_PRCD-KWERT.
      ENDIF.
      ENDIF.
    ENDIF.

    LOOP AT IT_RSEG1 INTO WA_RSEG1 WHERE EBELN = WA_EKKO-EBELN AND SHKZG = WA_RSEG-SHKZG.
      IF WA_RSEG1-KSCHL = 'OTHR' .
      IF WA_RSEG1-SHKZG = 'S'.
      WA_FINAL-OTHR =  WA_RSEG1-WRBTR." * -1.
      ELSEIF WA_RSEG1-SHKZG = 'H'.
      WA_FINAL-OTHR =  WA_RSEG1-WRBTR * -1.
      ENDIF.
    ELSEIF WA_RSEG1-KSCHL = 'JCDB' .
      IF WA_RSEG1-SHKZG = 'S'.
      WA_FINAL-JCDB =  WA_RSEG1-WRBTR." * -1.
      ELSEIF  WA_RSEG1-SHKZG = 'H'.
     WA_FINAL-JCDB =  WA_RSEG1-WRBTR * -1.
    ENDIF.
   ELSEIF WA_RSEG1-KSCHL = 'ZSOC' .
      IF WA_RSEG1-SHKZG = 'S'.
      WA_FINAL-ZSOC =  WA_RSEG1-WRBTR." * -1.
      ELSEIF  WA_RSEG1-SHKZG = 'H'.
      WA_FINAL-ZSOC =  WA_RSEG1-WRBTR * -1.
      ENDIF.
     ENDIF.
   ENDLOOP.

    READ TABLE IT_PRCD INTO WA_PRCD WITH KEY KNUMV = WA_EKKO-KNUMV KPOSN = WA_RSEG-EBELP KSCHL = 'JEDB' .
    IF SY-SUBRC = 0.
      WA_FINAL-JEDB =  WA_PRCD-KWERT.
    ENDIF.
    READ TABLE IT_PRCD INTO WA_PRCD WITH KEY KNUMV = WA_EKKO-KNUMV KPOSN = WA_RSEG-EBELP KSCHL = 'JEDS' .
    IF SY-SUBRC = 0.
      WA_FINAL-JEDS =  WA_PRCD-KWERT.
    ENDIF.
    READ TABLE IT_PRCD INTO WA_PRCD WITH KEY KNUMV = WA_EKKO-KNUMV KPOSN = WA_RSEG-EBELP KSCHL = 'JADD' .
    IF SY-SUBRC = 0.
      WA_FINAL-JADD =  WA_PRCD-KWERT.
    ENDIF.
    READ TABLE IT_PRCD INTO WA_PRCD WITH KEY KNUMV = WA_EKKO-KNUMV KPOSN = WA_RSEG-EBELP KSCHL = 'DADD' .
    IF SY-SUBRC = 0.
      WA_FINAL-DADD =  WA_PRCD-KWERT.
    ENDIF.

    WA_FINAL-CUSTOM = WA_FINAL-JCDB + WA_FINAL-ZSOC + WA_FINAL-JEDB + WA_FINAL-JEDS + WA_FINAL-JADD + WA_FINAL-DADD.
*********************************************************************************************************



*    ENDIF.
***************************************************************************
*    READ TABLE IT_ZGEMIGO INTO WA_ZGEMIGO WITH KEY MBLNR = WA_MSEG-MBLNR
*                                                   MJAHR = WA_MSEG-MJAHR.
*
*    IF SY-SUBRC = 0.
*      WA_FINAL-ZLR_NO = WA_ZGEMIGO-ZLR_NO.
*      WA_FINAL-ZLR_DATE = WA_ZGEMIGO-ZLR_DATE.
*      WA_FINAL-ZVEHICLE = WA_ZGEMIGO-ZVEHICLE.
*      WA_FINAL-ZTRNPRT = WA_ZGEMIGO-ZTRNPRT.
*    ENDIF.

    READ TABLE IT_MAKT INTO WA_MAKT WITH KEY MATNR = WA_RSEG-MATNR.
    IF SY-SUBRC = 0.
      WA_FINAL-MAKTX = WA_MAKT-MAKTX. "Item Description (General Description)
    ENDIF.

    READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_RSEG-MATNR.
    IF SY-SUBRC = 0.
      WA_FINAL-MATKL = WA_MARA-MATKL.                "Material group
      WA_FINAL-MFRPN = WA_MARA-MFRPN.
    ENDIF.

    READ TABLE IT_MARC INTO WA_MARC WITH KEY MATNR = WA_MARA-MATNR.
    IF SY-SUBRC  = 0.
      WA_FINAL-STEUC = WA_MARC-STEUC.
    ENDIF.



    READ TABLE IT INTO WA WITH KEY BELNR = WA_RSEG-BELNR.

    IF SY-SUBRC = 0.

*    LOOP AT IT_BSEG INTO WA_BSEG  WHERE AWKEY = WA-V_AWKEY .

      READ TABLE IT_BSEG INTO WA_BSEG WITH KEY AWKEY = WA-V_AWKEY
                                               EBELN = WA_RSEG-EBELN
                                               EBELP = WA_RSEG-EBELP.

*BREAK kkumar.
*                                              taxps =
      IF SY-SUBRC = 0 AND WA_BSEG-SHKZG = 'S'.
*        WA_FINAL-HKONT = WA_BSEG-HKONT.
        WA_FINAL-WRBTR = WA_BSEG-WRBTR * WA_RBKP-KURSF.            " CHNGED BY N  (WA_FINAL-WRBTR1 = WA_BSEG-WRBTR).
        WA_FINAL-MWSKZ1 = WA_BSEG-MWSKZ.
        WA_FINAL-FI_DOC = WA_BSEG-BELNR.
*        WA_FINAL-ZUONR  = WA_BSEG-ZUONR.             "ucommented by n
        WA_FINAL-TYPE   = 'Debit'.

      ELSEIF WA_BSEG-SHKZG = 'H'. "Credit
*        WA_FINAL-HKONT = WA_BSEG-HKONT.
        WA_FINAL-WRBTR = ( ( WA_BSEG-WRBTR * WA_RBKP-KURSF ) * ( -1 ) ).   "CHANGED BY N (WA_FINAL1-WRBTR = WA_BSEG-WRBTR).
        WA_FINAL-MWSKZ1 = WA_BSEG-MWSKZ.
        WA_FINAL-FI_DOC = WA_BSEG-BELNR.
*        WA_FINAL-ZUONR  = WA_BSEG-ZUONR.             "uncommented by n
        WA_FINAL-TYPE   = 'Credit'.
      ENDIF.

    READ TABLE IT_BKPF INTO WA_BKPF WITH KEY BELNR = WA_BSEG-BELNR
                                             BUKRS = WA_BSEG-BUKRS
                                             GJAHR = WA_BSEG-GJAHR.
    IF SY-SUBRC = 0.
      WA_FINAL-XBLNR = WA_BKPF-XBLNR.
    ENDIF.

    READ TABLE IT_LFA1 INTO WA_LFA1 WITH KEY LIFNR = WA_RBKP-LIFNR.
    IF SY-SUBRC = 0.
      WA_FINAL-STCD3 = WA_LFA1-STCD3.
    ENDIF.
    READ TABLE IT_MCH1 INTO WA_MCH1 WITH KEY LIFNR = WA_LFA1-LIFNR.
    IF SY-SUBRC = 0.
      WA_FINAL-LICHA = WA_MCH1-LICHA.
    ENDIF.
    READ TABLE IT_ADRC INTO WA_ADRC WITH KEY ADDRNUMBER = WA_LFA1-ADRNR.
    IF SY-SUBRC = 0.
      WA_FINAL-NAME1 = WA_ADRC-NAME1.
      WA_FINAL-CITY1 = WA_ADRC-CITY1.
    ENDIF.

    READ TABLE IT_T005T INTO WA_T005T WITH KEY LAND1 = WA_LFA1-LAND1.
    IF SY-SUBRC = 0.
      WA_FINAL-LANDX50 = WA_T005T-LANDX50.
    ENDIF.

 loop at it_bseg INTO wa_bseg where AWKEY = WA-V_AWKEY.
  IF WA_BSEG-BSCHL = '31' or wa_bseg-bschl = '21'.
   WA_FINAL-ZUONR  = WA_BSEG-ZUONR.
 ENDIF.
 endloop.

    READ TABLE IT_BSET INTO WA_BSET WITH KEY BELNR = WA_BSEG-BELNR
                                             GJAHR = WA_BSEG-GJAHR.
*                                             TAXPS = WA_RSEG-BUZEI.
    IF SY-SUBRC = 0 .
      WA_FINAL-BELNR2 = WA_BSET-BELNR.
      WA_FINAL-BUZEI2 = WA_BSET-BUZEI.
*      WA_FINAL-HKONT = WA_BSET-HKONT.
    ENDIF.
*BREAK KKUMAR.
   LOOP AT IT_BSEG INTO WA_BSEG WHERE AWKEY = WA-V_AWKEY
                                AND EBELN = WA_RSEG-EBELN
                                AND EBELP = WA_RSEG-EBELP.

*   READ TABLE IT_BSEG INTO WA_BSEG WITH KEY AWKEY = WA-V_AWKEY .

      IF WA_BSEG-BSCHL = '86' AND  WA_BSET-SHKZG = 'S' .               "ADDED BY NEHA  WA_BSET-SHKZG = 'S'.

        LOOP AT IT_BSET INTO WA_BSET WHERE BELNR = WA_BSEG-BELNR AND TXGRP = WA_BSEG-TXGRP.
                  "  TAXPS = WA_BSEG-TAXPS.
          WA_FINAL-HWBAS = WA_BSET-HWBAS.

          IF WA_BSET-KSCHL = 'JICG'.
            WA_FINAL-CGST = WA_FINAL-CGST + WA_BSET-HWSTE." *  WA_FINAL-MENGE.
          ELSEIF WA_BSET-KSCHL = 'JISG'.
            WA_FINAL-SGST = WA_FINAL-SGST + WA_BSET-HWSTE." *  WA_FINAL-MENGE.
          ELSEIF WA_BSET-KSCHL = 'JIIG'.
            WA_FINAL-IGST = WA_FINAL-IGST + WA_BSET-HWSTE." *  WA_FINAL-MENGE.
**          ELSEIF WA_BSET-KSCHL = 'JIUG'.                          "" COMMENTED BY NEHA
**            WA_FINAL-UGST = WA_BSET-HWSTE." *  WA_FINAL-MENGE.
          ENDIF.
        ENDLOOP.


      ELSEIF WA_BSEG-BSCHL = '96' AND  WA_BSET-SHKZG = 'H'.             "ADDED BY NEHA  WA_BSET-SHKZG = 'H'.
        WA_FINAL-HWBAS = WA_BSET-HWBAS * -1.

        LOOP AT IT_BSET INTO WA_BSET WHERE BELNR = WA_BSEG-BELNR and TXGRP = WA_BSEG-TXGRP.     " AND buzei = wa_rseg-buzei ."TAXPS = WA_BSEG-TAXPS.
          IF WA_BSET-KSCHL = 'JICG'.
            WA_FINAL-CGST =  WA_FINAL-CGST +  WA_BSET-HWSTE * ( -1 )." *  WA_FINAL-MENGE.                 "* ( -1 ) ADDED BY NEHA
          ELSEIF WA_BSET-KSCHL = 'JISG'.
            WA_FINAL-SGST = WA_FINAL-SGST + WA_BSET-HWSTE * ( -1 )." *  WA_FINAL-MENGE.
          ELSEIF WA_BSET-KSCHL = 'JIIG'.
            WA_FINAL-IGST = WA_FINAL-IGST + WA_BSET-HWSTE * ( -1 )." *  WA_FINAL-MENGE.
**          ELSEIF WA_BSET-KSCHL = 'JIUG'.                                 "COMMENTED BY NEHA
**            WA_FINAL-UGST = WA_FINAL-UGST +  WA_BSET-HWSTE." *  WA_FINAL-MENGE.
          ENDIF.
        ENDLOOP.

      ELSEIF WA_BSEG-BSCHL = '89' AND  WA_BSET-SHKZG = 'S' OR WA_BSEG-KOART = 'M'.             "ADDED BY NEHA  WA_BSET-SHKZG = 'H'.
        WA_FINAL-HWBAS = WA_BSET-HWBAS.

        LOOP AT IT_BSET INTO WA_BSET WHERE BELNR = WA_BSEG-BELNR and TXGRP = WA_BSEG-TXGRP.     " AND buzei = wa_rseg-buzei ."TAXPS = WA_BSEG-TAXPS.
          IF WA_BSET-KSCHL = 'JICG'.
            WA_FINAL-CGST =  WA_FINAL-CGST +  WA_BSET-HWSTE." * ( -1 )." *  WA_FINAL-MENGE.                 "* ( -1 ) ADDED BY NEHA
          ELSEIF WA_BSET-KSCHL = 'JISG'.
            WA_FINAL-SGST = WA_FINAL-SGST + WA_BSET-HWSTE ."* ( -1 )." *  WA_FINAL-MENGE.
          ELSEIF WA_BSET-KSCHL = 'JIIG'.
            WA_FINAL-IGST = WA_FINAL-IGST + WA_BSET-HWSTE ."* ( -1 )." *  WA_FINAL-MENGE.
**          ELSEIF WA_BSET-KSCHL = 'JIUG'.                                 "COMMENTED BY NEHA
**            WA_FINAL-UGST = WA_FINAL-UGST +  WA_BSET-HWSTE." *  WA_FINAL-MENGE.
          ENDIF.
        ENDLOOP.

      ELSEIF WA_BSEG-BSCHL = '99' AND  WA_BSET-SHKZG = 'H' OR WA_BSEG-KOART = 'M'.             "ADDED BY NEHA  WA_BSET-SHKZG = 'H'.
        WA_FINAL-HWBAS = WA_BSET-HWBAS * -1.

        LOOP AT IT_BSET INTO WA_BSET WHERE BELNR = WA_BSEG-BELNR and TXGRP = WA_BSEG-TXGRP.     " AND buzei = wa_rseg-buzei ."TAXPS = WA_BSEG-TAXPS.
          IF WA_BSET-KSCHL = 'JICG'.
            WA_FINAL-CGST =  WA_FINAL-CGST +  WA_BSET-HWSTE * ( -1 )." *  WA_FINAL-MENGE.                 "* ( -1 ) ADDED BY NEHA
          ELSEIF WA_BSET-KSCHL = 'JISG'.
            WA_FINAL-SGST = WA_FINAL-SGST + WA_BSET-HWSTE * ( -1 )." *  WA_FINAL-MENGE.
          ELSEIF WA_BSET-KSCHL = 'JIIG'.
            WA_FINAL-IGST = WA_FINAL-IGST + WA_BSET-HWSTE * ( -1 )." *  WA_FINAL-MENGE.
**          ELSEIF WA_BSET-KSCHL = 'JIUG'.                                 "COMMENTED BY NEHA
**            WA_FINAL-UGST = WA_FINAL-UGST +  WA_BSET-HWSTE." *  WA_FINAL-MENGE.
          ENDIF.
        ENDLOOP.

      ELSEIF WA_BSEG-BSCHL = '70' AND  WA_BSET-SHKZG = 'S'.             "ADDED BY NEHA  WA_BSET-SHKZG = 'H'.
        WA_FINAL-HWBAS = WA_BSET-HWBAS.

        LOOP AT IT_BSET INTO WA_BSET WHERE BELNR = WA_BSEG-BELNR and TXGRP = WA_BSEG-TXGRP.     " AND buzei = wa_rseg-buzei ."TAXPS = WA_BSEG-TAXPS.
          IF WA_BSET-KSCHL = 'JICG'.
            WA_FINAL-CGST =  WA_FINAL-CGST +  WA_BSET-HWSTE." * ( -1 )." *  WA_FINAL-MENGE.                 "* ( -1 ) ADDED BY NEHA
          ELSEIF WA_BSET-KSCHL = 'JISG'.
            WA_FINAL-SGST = WA_FINAL-SGST + WA_BSET-HWSTE . "( -1 )." *  WA_FINAL-MENGE.
          ELSEIF WA_BSET-KSCHL = 'JIIG'.
            WA_FINAL-IGST = WA_FINAL-IGST + WA_BSET-HWSTE.  "( -1 )." *  WA_FINAL-MENGE.
**          ELSEIF WA_BSET-KSCHL = 'JIUG'.                                 "COMMENTED BY NEHA
**            WA_FINAL-UGST = WA_FINAL-UGST +  WA_BSET-HWSTE." *  WA_FINAL-MENGE.
          ENDIF.
        ENDLOOP.

      ELSEIF WA_BSEG-BSCHL = '75' AND  WA_BSET-SHKZG = 'H'.             "ADDED BY NEHA  WA_BSET-SHKZG = 'H'.
        WA_FINAL-HWBAS = WA_BSET-HWBAS * -1.

        LOOP AT IT_BSET INTO WA_BSET WHERE BELNR = WA_BSEG-BELNR and TXGRP = WA_BSEG-TXGRP.     " AND buzei = wa_rseg-buzei ."TAXPS = WA_BSEG-TAXPS.
          IF WA_BSET-KSCHL = 'JICG'.
            WA_FINAL-CGST =  WA_FINAL-CGST +  WA_BSET-HWSTE * ( -1 )." *  WA_FINAL-MENGE.                 "* ( -1 ) ADDED BY NEHA
          ELSEIF WA_BSET-KSCHL = 'JISG'.
            WA_FINAL-SGST = WA_FINAL-SGST + WA_BSET-HWSTE * ( -1 )." *  WA_FINAL-MENGE.
          ELSEIF WA_BSET-KSCHL = 'JIIG'.
            WA_FINAL-IGST = WA_FINAL-IGST + WA_BSET-HWSTE * ( -1 )." *  WA_FINAL-MENGE.
**          ELSEIF WA_BSET-KSCHL = 'JIUG'.                                 "COMMENTED BY NEHA
**            WA_FINAL-UGST = WA_FINAL-UGST +  WA_BSET-HWSTE." *  WA_FINAL-MENGE.
          ENDIF.
        ENDLOOP.
      ENDIF.
*          ENDIF.
 ENDLOOP.

********************
    WA_FINAL-NET_AMOUNT =  WA_FINAL-WRBTR + WA_FINAL-IGST + WA_FINAL-CGST + WA_FINAL-SGST + WA_FINAL-FREIGHT." + WA_FINAL-CUSTOM ." + wa_final-exaed.WA_FINAL-EXBED (WA_FINAL-FREIGHT)
*                                                                                 "  WA_FINAL-UGST REMOVED FROM  WA_FINAL-NET_AMOUNT "commented by n
    ENDIF.

    TDOBNAME = WA_RSEG-EBELN.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT                  = SY-MANDT
        ID                      = 'F07'
        LANGUAGE                = 'E'
        NAME                    = TDOBNAME
        OBJECT                  = 'EKKO'
*       ARCHIVE_HANDLE          = 0
*       LOCAL_CAT               = ' '
*   IMPORTING
*       HEADER                  =
*       OLD_LINE_COUNTER        =
      TABLES
        LINES                   = IT_LINE
      EXCEPTIONS
        ID                      = 1
        LANGUAGE                = 2
        NAME                    = 3
        NOT_FOUND               = 4
        OBJECT                  = 5
        REFERENCE_CHECK         = 6
        WRONG_ACCESS_TO_ARCHIVE = 7
        OTHERS                  = 8.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    LOOP AT IT_LINE INTO WA_LINE WHERE TDLINE IS NOT INITIAL.
      CONCATENATE WA_FINAL-P_TERM WA_LINE-TDLINE INTO WA_FINAL-P_TERM SEPARATED BY ' ' .
    ENDLOOP .

*IF WA_FINAL-MBLNR IS NOT INITIAL.                 "'commented by N
    APPEND WA_FINAL TO IT_FINAL.
*ENDIF.
    CLEAR : IT_LINE,WA_LINE , LV_FREIGHT.
    CLEAR: WA_FINAL,WA_BKPF,WA_BSEG,WA_BSET,WA_LFA1 ,
           WA_ADRC,WA,WA_KONP,WA_MCH1.
          DELETE IT_MSEG WHERE         MBLNR = WA_MSEG-MBLNR AND
                                       EBELN = WA_RSEG-EBELN AND
                                       EBELP = WA_RSEG-EBELP AND
                                       ZEILE = wa_rseg-BUZEI .

*  ENDLOOP.
  ENDLOOP.
*  BREAK kkumar.
  SORT IT_FINAL BY BELNR EBELN MBLNR EBELP.
  IT_FINAL1[] = IT_FINAL[] .
*  DELETE ADJACENT DUPLICATES FROM IT_FINAL2 COMPARING BELNR MBLNR EBELN EBELP.
  LOOP AT IT_FINAL1 INTO WA_FINAL1 .
    WA_FINAL2-EBELN    = WA_FINAL1-EBELN .
    WA_FINAL2-BSART    = WA_FINAL1-BSART.
    WA_FINAL2-EBELP    = WA_FINAL1-EBELP .
    WA_FINAL2-BUKRS    = WA_FINAL1-BUKRS .
    WA_FINAL2-WERKS    = WA_FINAL1-WERKS .
    WA_FINAL2-LGORT    = WA_FINAL1-LGORT .
    WA_FINAL2-BELNR    = WA_FINAL1-BELNR .
    WA_FINAL2-BUZEI    = WA_FINAL1-BUZEI .
    WA_FINAL2-FI_DOC   = WA_FINAL1-FI_DOC .
    WA_FINAL2-MBLNR    = WA_FINAL1-MBLNR .
    WA_FINAL2-BUDAT1   = WA_FINAL1-BUDAT1 .
    WA_FINAL2-VBELN_IM = WA_FINAL1-VBELN_IM .
    WA_FINAL2-EINDT    = WA_FINAL1-EINDT .
    WA_FINAL2-BWART    = WA_FINAL1-BWART .
    WA_FINAL2-LIFNR    = WA_FINAL1-LIFNR .
    WA_FINAL2-NAME1    = WA_FINAL1-NAME1 .
    WA_FINAL2-LANDX50  = WA_FINAL1-LANDX50 .
    WA_FINAL2-STCD3    = WA_FINAL1-STCD3 .
    WA_FINAL2-STEUC    = WA_FINAL1-STEUC .
    WA_FINAL2-LICHA    = WA_FINAL1-LICHA .
    WA_FINAL2-MATNR    = WA_FINAL1-MATNR .
    WA_FINAL2-MAKTX    = WA_FINAL1-MAKTX .
    WA_FINAL2-MFRPN    = WA_FINAL1-MFRPN .
    WA_FINAL2-MATKL    = WA_FINAL1-MATKL .
    WA_FINAL2-MEINS    = WA_FINAL1-MEINS .
    WA_FINAL2-WAERS    = WA_FINAL1-WAERS .
    WA_FINAL2-MWSKZ    = WA_FINAL1-MWSKZ .
    WA_FINAL2-FREIGHT  = WA_FINAL1-FREIGHT .
    WA_FINAL2-CUSTOM   = WA_FINAL1-CUSTOM .
    WA_FINAL2-P_TERM   = WA_FINAL1-P_TERM .
    WA_FINAL2-TYPE     = WA_FINAL1-TYPE .
    WA_FINAL2-BLDAT    = WA_FINAL1-BLDAT .
    WA_FINAL2-BUDAT    = WA_FINAL1-BUDAT.
    WA_FINAL2-XBLNR    = WA_FINAL1-XBLNR.
    WA_FINAL2-ZLR_NO   = WA_FINAL1-ZLR_NO.
    WA_FINAL2-ZLR_DATE = WA_FINAL1-ZLR_DATE.
    WA_FINAL2-ZVEHICLE = WA_FINAL1-ZVEHICLE.
    WA_FINAL2-ZTRNPRT  = WA_FINAL1-ZTRNPRT.
    WA_FINAL2-ZUONR    = WA_FINAL1-ZUONR.
    WA_FINAL2-BKTXT    = WA_FINAL1-BKTXT.
    WA_FINAL2-SGTXT    = WA_FINAL1-SGTXT.
    WA_FINAL2-FRBNR    = WA_FINAL1-FRBNR.
    WA_FINAL2-OTHR    = WA_FINAL1-OTHR.
    WA_FINAL2-ZSOC    = WA_FINAL1-ZSOC.
    WA_FINAL2-JCDB   = WA_FINAL1-JCDB.

***************
    LOOP AT IT_FINAL INTO WA_FINAL WHERE BELNR = WA_FINAL1-BELNR AND EBELN = WA_FINAL1-EBELN AND EBELP = WA_FINAL1-EBELP AND MBLNR = WA_FINAL1-MBLNR.
      WA_FINAL2-MENGE_P =  WA_FINAL2-MENGE_P + WA_FINAL-MENGE_P ."""""""""
      WA_FINAL2-MENGE   =  WA_FINAL2-MENGE + WA_FINAL-MENGE.
      WA_FINAL2-MENGE1  =  WA_FINAL2-MENGE1 + WA_FINAL-MENGE1.
      WA_FINAL2-WRBTR   =  WA_FINAL2-WRBTR + WA_FINAL-WRBTR .
      WA_FINAL2-DMBTR   =  WA_FINAL2-DMBTR + WA_FINAL-DMBTR .
      WA_FINAL2-SGST    =  WA_FINAL2-SGST + WA_FINAL-SGST .
      WA_FINAL2-CGST    =  WA_FINAL2-CGST + WA_FINAL-CGST .
      WA_FINAL2-HWBAS   = WA_FINAL2-HWBAS + wa_final-hwbas.
**      WA_FINAL2-OTHR    =  WA_FINAL2-OTHR + WA_FINAL-OTHR .
**      WA_FINAL2-ZSOC    =  WA_FINAL2-ZSOC + WA_FINAL-ZSOC .
**      WA_FINAL2-JCDB    =  WA_FINAL2-JCDB + WA_FINAL-JCDB .
*      WA_FINAL2-IGST    = WA_FINAL2-SGST + WA_FINAL-IGST .
      WA_FINAL2-IGST    = WA_FINAL-IGST .

*      wa_final2-ugst = wa_final2-ugst + wa_final-ugst .
*      wa_final2-net_amount = wa_final2-net_amount + wa_final-net_amount .
ENDLOOP .
    WA_FINAL2-NET_AMOUNT =  WA_FINAL2-FREIGHT + WA_FINAL2-WRBTR + WA_FINAL2-SGST + WA_FINAL2-CGST + WA_FINAL2-IGST .

    APPEND WA_FINAL2 TO IT_FINAL2 .
    CLEAR WA_FINAL2 .
  ENDLOOP .
 SORT IT_FINAL2 BY   BELNR EBELP.
 DELETE ADJACENT DUPLICATES FROM IT_FINAL2 COMPARING  BELNR EBELP.
*******************************************************************************
**    IF S_LGORT-LOW IS NOT INITIAL.
**      DELETE IT_FINAL2 WHERE LGORT <> S_LGORT-LOW.
**    ENDIF.
**
**    IF S_BWART-LOW IS NOT INITIAL.
**      DELETE IT_FINAL2 WHERE BWART <> S_BWART-LOW.
**    ENDIF.
**
**    IF S_MATKL-LOW IS NOT INITIAL.
**      DELETE IT_FINAL2 WHERE MATKL <> S_MATKL-LOW.
**    ENDIF.

*    SORT IT_FINAL2 BY BELNR BUZEI.
SORT IT_FINAL2 BY BELNR   EBELP.                                       "EBELN
DELETE ADJACENT DUPLICATES FROM IT_FINAL2 COMPARING BELNR   EBELP.    "EBELN

*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELDCATLOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FIELDCATLOG.

  WA_SORT-FIELDNAME = 'EBELN '.
  WA_SORT-UP = 'X'.
  WA_SORT-SUBTOT = 'X '.

  APPEND WA_SORT TO I_SORT .

  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'BUKRS'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'COMPANY CODE'.
* WA_FCAT-KEY = 'X'.
* WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'LIFNR'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Vendor No'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'NAME1'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Vendor Name'.
* WA_FCAT-KEY = 'X'.
* WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'LANDX50'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Vendor Country'.
* WA_FCAT-KEY = 'X'.
* WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'STCD3'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Vendor GSTIN'.
* WA_FCAT-KEY = 'X'.
* WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

****  WA_FCAT-FIELDNAME = 'BWART'.
****  WA_FCAT-TABNAME   = 'IT_FINAL2'.
****  WA_FCAT-SELTEXT_M = 'Mvt.Typ'.
***** WA_FCAT-KEY = 'X'.
***** WA_FCAT-OUTPUTLEN = 10.
****  APPEND WA_FCAT TO IT_FCAT.
****  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'EBELN'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'PO Number'.
**** WA_FCAT-KEY = 'X'.
**** WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'EBELP'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'PO Item'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'MATNR'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Material No.'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'MAKTX'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Material Des'.
* WA_FCAT-KEY = 'X'.
* WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

**  WA_FCAT-FIELDNAME = 'MENGE_P'.
**  WA_FCAT-TABNAME   = 'IT_FINAL2'.
**  WA_FCAT-SELTEXT_M = 'PO Qty'.
*  WA_FCAT-DO_SUM = 'X'.

* WA_FCAT-KEY = 'X'.
* WA_FCAT-OUTPUTLEN = 10.
**  APPEND WA_FCAT TO IT_FCAT.
**  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'MEINS'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'UOM'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'WAERS'. "'basis amount.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Currency'.
* WA_FCAT-KEY = 'X'.
  WA_FCAT-OUTPUTLEN = 08.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

**  WA_FCAT-FIELDNAME = 'MATKL'.
**  WA_FCAT-TABNAME   = 'IT_FINAL2'.
**  WA_FCAT-SELTEXT_M = 'Material Group'.
*** WA_FCAT-KEY = 'X'.
*** WA_FCAT-OUTPUTLEN = 10.
**  APPEND WA_FCAT TO IT_FCAT.
**  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'WERKS'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'PLANT'.
* WA_FCAT-KEY = 'X'.
* WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'STEUC'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'HSN Code'.
* WA_FCAT-KEY = 'X'.
* WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'FRBNR'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_L = 'Airway Bill No/ Bill of lading No'.
* WA_FCAT-KEY = 'X'.
 WA_FCAT-OUTPUTLEN = 50.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

**  WA_FCAT-FIELDNAME = 'MBLNR'.
**  WA_FCAT-TABNAME   = 'IT_FINAL2'.
**  WA_FCAT-SELTEXT_M = 'GRN NUM'.
*** WA_FCAT-KEY = 'X'.
**  WA_FCAT-OUTPUTLEN = 10.
**  APPEND WA_FCAT TO IT_FCAT.
**  CLEAR WA_FCAT.
**
**  WA_FCAT-FIELDNAME = 'BUDAT1'.
**  WA_FCAT-TABNAME   = 'IT_FINAL2'.
**  WA_FCAT-SELTEXT_M = 'GRN Date'.
*** WA_FCAT-KEY = 'X'.
**  WA_FCAT-OUTPUTLEN = 10.
**  APPEND WA_FCAT TO IT_FCAT.
**  CLEAR WA_FCAT.

**  WA_FCAT-FIELDNAME = 'MENGE1'.
**  WA_FCAT-TABNAME   = 'IT_FINAL2'.
**  WA_FCAT-SELTEXT_M = 'GRN Qty'.
***  WA_FCAT-DO_SUM = 'X'.
*** WA_FCAT-KEY = 'X'.
**  WA_FCAT-OUTPUTLEN = 10.
**  APPEND WA_FCAT TO IT_FCAT.
**  CLEAR WA_FCAT.

***  WA_FCAT-FIELDNAME = 'DMBTR'.
***  WA_FCAT-TABNAME   = 'IT_FINAL2'.
***  WA_FCAT-SELTEXT_M = 'GRN Amt'.
***  WA_FCAT-DO_SUM = 'X'.
**** WA_FCAT-KEY = 'X'.
***  WA_FCAT-OUTPUTLEN = 10.
***  APPEND WA_FCAT TO IT_FCAT.
***  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'BELNR'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'MIRO Doc No'.
* WA_FCAT-KEY = 'X'.
  WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'FI_DOC'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'FI Doc No'.
* WA_FCAT-KEY = 'X'.
  WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'BLDAT'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'MIRO Invoice Date'.
* WA_FCAT-KEY = 'X'.
  WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'BUDAT'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Posting Date'.
* WA_FCAT-KEY = 'X'.
  WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'XBLNR'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Reference'.
* WA_FCAT-KEY = 'X'.
  WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'SGTXT'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Supply Inv. No'.
* WA_FCAT-KEY = 'X'.
  WA_FCAT-OUTPUTLEN = 15.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'ZUONR'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Bill of Entry No/dt.'.
* WA_FCAT-KEY = 'X'.
  WA_FCAT-OUTPUTLEN = 40.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'BKTXT'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Licence Details'.
* WA_FCAT-KEY = 'X'.
  WA_FCAT-OUTPUTLEN = 15.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'MENGE'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'MIRO Qty'.
*  WA_FCAT-DO_SUM = 'X'.
* WA_FCAT-KEY = 'X'.
  WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'WRBTR'. "'basis amount.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'MIRO Amount'.
  WA_FCAT-DO_SUM = 'X'.
* WA_FCAT-KEY = 'X'.
* WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'MWSKZ' . "'TEXT1'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Tax Code'.
* WA_FCAT-KEY = 'X'.
* WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'CGST'.
  WA_FCAT-TABNAME = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'CGST'.
  WA_FCAT-DO_SUM = 'X'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'SGST'.
  WA_FCAT-TABNAME = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'SGST'.
  WA_FCAT-DO_SUM = 'X'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'IGST'.
  WA_FCAT-TABNAME = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'IGST'.
  WA_FCAT-DO_SUM = 'X'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'FREIGHT'.
  WA_FCAT-TABNAME = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Freight'.
  WA_FCAT-DO_SUM = 'X'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'NET_AMOUNT'.
  WA_FCAT-TABNAME = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Total  Amount'.
  WA_FCAT-DO_SUM = 'X'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'JCDB'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Basic Custom Duty'.
* WA_FCAT-KEY = 'X'.
* WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'ZSOC'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Social Welfare'.
* WA_FCAT-KEY = 'X'.
* WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'OTHR'.
  WA_FCAT-TABNAME   = 'IT_FINAL2'.
  WA_FCAT-SELTEXT_M = 'Others'.
* WA_FCAT-KEY = 'X'.
* WA_FCAT-OUTPUTLEN = 10.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  GT_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  GT_LAYOUT-ZEBRA = 'X'.

















**  WA_FCAT-FIELDNAME = 'BUZEI'.
**  WA_FCAT-TABNAME   = 'IT_FINAL2'.
**  WA_FCAT-SELTEXT_M = 'Invoice Doc Item'.
*** WA_FCAT-KEY = 'X'.
**  WA_FCAT-OUTPUTLEN = 10.
**  APPEND WA_FCAT TO IT_FCAT.
**  CLEAR WA_FCAT.
**
**  WA_FCAT-FIELDNAME = 'FI_DOC'.
**  WA_FCAT-TABNAME   = 'IT_FINAL2'.
**  WA_FCAT-SELTEXT_M = 'Accounting Doc No'.
*** WA_FCAT-KEY = 'X'.
**  WA_FCAT-OUTPUTLEN = 10.
**  APPEND WA_FCAT TO IT_FCAT.
**  CLEAR WA_FCAT.



*  WA_FCAT-FIELDNAME = 'VBELN_IM'.
*  WA_FCAT-TABNAME = 'IT_FINAL2'.
*  WA_FCAT-SELTEXT_M = 'Del No'.
** WA_FCAT-KEY = 'X'.
*  WA_FCAT-OUTPUTLEN = 10.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.

*  WA_FCAT-FIELDNAME = 'EINDT'.
*  WA_FCAT-TABNAME = 'IT_FINAL2'.
*  WA_FCAT-SELTEXT_M = 'PO Del Date'.
** WA_FCAT-KEY = 'X'.
*  WA_FCAT-OUTPUTLEN = 10.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.
*




*  WA_FCAT-FIELDNAME = 'LICHA'.
*  WA_FCAT-TABNAME = 'IT_FINAL2'.
*  WA_FCAT-SELTEXT_M = 'Supplier Batch'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.




*  WA_FCAT-FIELDNAME = 'BSART'.
*  WA_FCAT-TABNAME = 'IT_FINAL2'.
*  WA_FCAT-SELTEXT_M = 'PO Type'.
** WA_FCAT-KEY = 'X'.
** WA_FCAT-OUTPUTLEN = 10.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.





*  WA_FCAT-FIELDNAME = 'MFRPN'.
*  WA_FCAT-TABNAME = 'IT_FINAL2'.
*  WA_FCAT-SELTEXT_M = 'MPN No'.
** WA_FCAT-KEY = 'X'.
** WA_FCAT-OUTPUTLEN = 10.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.












  "TAX
*  WA_FCAT-FIELDNAME = 'FREIGHT'.
*  WA_FCAT-TABNAME = 'IT_FINAL2'.
*  WA_FCAT-SELTEXT_M = 'Freight'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.



*  WA_FCAT-FIELDNAME = 'CUSTOM'.
*  WA_FCAT-TABNAME = 'IT_FINAL2'.
*  WA_FCAT-SELTEXT_M = 'CUSTOM DUTY'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.




*  WA_FCAT-FIELDNAME = 'P_TERM'.
*  WA_FCAT-TABNAME = 'IT_FINAL2'.
*  WA_FCAT-SELTEXT_M = 'Payment Terms'.
*  WA_FCAT-OUTPUTLEN = 35.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.

*  WA_FCAT-FIELDNAME = 'TYPE'.
*  WA_FCAT-TABNAME = 'IT_FINAL2'.
*  WA_FCAT-SELTEXT_M = 'Type'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.

*  WA_FCAT-FIELDNAME = 'ZLR_NO'.
*  WA_FCAT-TABNAME = 'IT_FINAL2'.
*  WA_FCAT-SELTEXT_M = 'Lr No'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.

*  WA_FCAT-FIELDNAME = 'ZLR_DATE'.
*  WA_FCAT-TABNAME = 'IT_FINAL2'.
*  WA_FCAT-SELTEXT_M = 'Lr Date'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.

*  WA_FCAT-FIELDNAME = 'ZVEHICLE'.
*  WA_FCAT-TABNAME = 'IT_FINAL2'.
*  WA_FCAT-SELTEXT_M = 'Lorry No'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.
*
*  WA_FCAT-FIELDNAME = 'ZTRNPRT'.
*  WA_FCAT-TABNAME = 'IT_FINAL2'.
*  WA_FCAT-SELTEXT_M = 'Transporter Name'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM OUTPUT.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM          = SY-REPID
*     I_CALLBACK_PF_STATUS_SET    = 'SET_PF_STATUS'
*     I_CALLBACK_USER_COMMAND     = 'USER_COMMAND'
*     I_CALLBACK_TOP_OF_PAGE      = 'TOP-OF-PAGE'
      I_CALLBACK_HTML_TOP_OF_PAGE = 'TOP-OF-PAGE'
      IS_LAYOUT                   = GT_LAYOUT
      IT_FIELDCAT                 = IT_FCAT
      IT_SORT                     = I_SORT
      I_SAVE                      = 'X'
*     IS_PRINT                    = LW_PRINT
    TABLES
      T_OUTTAB                    = IT_FINAL2
    EXCEPTIONS
      PROGRAM_ERROR               = 1
      OTHERS                      = 2.

ENDFORM.
FORM TOP-OF-PAGE USING TOP TYPE REF TO CL_DD_DOCUMENT.

*ALV Header declarations
  DATA: T_HEADER      TYPE SLIS_T_LISTHEADER,
        WA_HEADER     TYPE SLIS_LISTHEADER,
        T_LINE        LIKE WA_HEADER-INFO,
        LD_LINES      TYPE I,
        LD_LINESC(10) TYPE C.

  DATA: LV_TOP   TYPE SDYDO_TEXT_ELEMENT,
        LV_DATE  TYPE SDYDO_TEXT_ELEMENT,
        SEP      TYPE C VALUE ' ',
        DOT      TYPE C VALUE '.',
        YYYY1    TYPE CHAR4,
        MM1      TYPE CHAR2,
        DD1      TYPE CHAR2,
        DATE1    TYPE CHAR10,
        YYYY2    TYPE CHAR4,
        MM2      TYPE CHAR2,
        DD2      TYPE CHAR2,
        DATE2    TYPE CHAR10,
*        lv_name1 TYPE ad_name1,
        LV_NAME2 TYPE AD_NAME2,
        LV_ADRNR TYPE ADRNR.

  LV_TOP = 'Purchase Register'.

  CALL METHOD TOP->ADD_TEXT
    EXPORTING
      TEXT      = LV_TOP
      SAP_STYLE = 'HEADING'.

  CALL METHOD TOP->NEW_LINE.
*
  LV_TOP = 'Date-'.

  CALL METHOD TOP->ADD_TEXT
    EXPORTING
      TEXT      = LV_TOP
      SAP_STYLE = 'SUBHEADING'.

*  CONCATENATE S_BUDAT-LOW+6(2) S_BUDAT-LOW+4(2) S_BUDAT-LOW+0(4) '-' S_BUDAT-HIGH+6(2) S_BUDAT-HIGH+4(2) S_BUDAT-HIGH+0(4) INTO LV_DATE SEPARATED BY '.'.
lv_date = sy-datum.
  LV_TOP = LV_DATE.

  CALL METHOD TOP->ADD_TEXT
    EXPORTING
      TEXT      = LV_TOP
      SAP_STYLE = 'SUBHEADING'.

  CALL METHOD TOP->NEW_LINE.
*
*  LV_TOP = 'Plant-'.
*
*  CALL METHOD TOP->ADD_TEXT
*    EXPORTING
*      TEXT      = LV_TOP
*      SAP_STYLE = 'SUBHEADING'.
*
*  LV_TOP = 'Evolv Clothing Pvt. Ltd.'.

  CALL METHOD TOP->ADD_TEXT
    EXPORTING
      TEXT      = LV_TOP
      SAP_STYLE = 'SUBHEADING'.
*

  CALL FUNCTION 'FI_CONVERT_FIRSTCHARS_TOUPPER'
    EXPORTING
      INPUT_STRING  = LV_TOP
*     SEPARATORS    = ' -.,;:'
    IMPORTING
      OUTPUT_STRING = LV_TOP.


ENDFORM.

FORM FI_POSTING .

TYPES: BEGIN OF TY_BKPF,
       BUKRS TYPE BKPF-BUKRS,
       BELNR TYPE BKPF-BELNR,
       GJAHR TYPE BKPF-GJAHR,
       BLART TYPE BKPF-BLART,
       BLDAT TYPE BKPF-BLDAT,
       BUDAT TYPE BKPF-BUDAT,
       XBLNR TYPE BKPF-XBLNR,
      END OF TY_BKPF.

TYPES: BEGIN OF TY_BSEG,
       BUKRS TYPE BSEG-BUKRS,
       BELNR TYPE BSEG-BELNR,
       GJAHR TYPE BSEG-GJAHR,
       BUZEI TYPE BSEG-BUZEI,
       BSCHL TYPE BSEG-BSCHL,
       GSBER TYPE BSEG-GSBER,
       MWSKZ TYPE BSEG-MWSKZ,
       DMBTR TYPE BSEG-DMBTR,
       TXGRP TYPE BSEG-TXGRP,
       LIFNR TYPE BSEG-LIFNR,
      END OF TY_BSEG.

TYPES: BEGIN OF TY_BSET,
       BUKRS TYPE BSET-BUKRS,
       BELNR TYPE BSET-BELNR,
       GJAHR TYPE BSET-GJAHR,
       BUZEI TYPE BSET-BUZEI,
       MWSKZ TYPE BSET-MWSKZ,
       TXGRP TYPE BSET-TXGRP,
       SHKZG TYPE BSET-SHKZG,
       FWBAS TYPE BSET-FWBAS,
       HWSTE TYPE BSET-HWSTE,
       KSCHL TYPE BSET-KSCHL,
       KBETR TYPE BSET-KBETR,
      END OF TY_BSET.

TYPES: BEGIN OF TY_LFA1,
       LIFNR TYPE LFA1-LIFNR,
       NAME1 TYPE LFA1-NAME1,
      END OF TY_LFA1.

TYPES: BEGIN OF TY_FINAL,
       BELNR TYPE BKPF-BELNR,
       BLDAT TYPE BKPF-BLDAT,
       BUDAT TYPE BKPF-BUDAT,
       XBLNR TYPE BKPF-XBLNR,
       GSBER TYPE BSEG-GSBER,
       DMBTR TYPE BSEG-DMBTR,
       LIFNR TYPE LFA1-LIFNR,
       NAME1 TYPE LFA1-NAME1,
       BLART TYPE BKPF-BLART,
       DMBTR1 TYPE DMBTR,
       CGSTP TYPE KBETR,
       SGSTP TYPE KBETR,
       IGSTP TYPE KBETR,
       CGSTV TYPE HWSTE,
       SGSTV TYPE HWSTE,
       IGSTV TYPE HWSTE,
       SLNO TYPE I,
      END OF TY_FINAL.

DATA: IT_BKPF TYPE TABLE OF TY_BKPF,
      WA_BKPF TYPE TY_BKPF,
      IT_BSEG TYPE TABLE OF TY_BSEG,
      IT_BSEG1 TYPE TABLE OF TY_BSEG,
      WA_BSEG TYPE TY_BSEG,
      WA_BSEG1 TYPE TY_BSEG,
      IT_BSET TYPE TABLE OF TY_BSET,
      WA_BSET TYPE TY_BSET,
      IT_LFA1 TYPE TABLE OF TY_LFA1,
      WA_LFA1 TYPE TY_LFA1,
      IT_FINAL TYPE TABLE OF TY_FINAL,
      WA_FINAL TYPE TY_FINAL.

DATA: IT_FCAT TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE,
      WA_FCAT LIKE IT_FCAT.

DATA: SLNO TYPE I.

SELECT   BUKRS
         BELNR
         GJAHR
         BLART
         BLDAT
         BUDAT
         XBLNR FROM BKPF INTO TABLE IT_BKPF
               WHERE GJAHR IN S_GJAHR
               AND BLDAT IN S_BLDAT1
               AND BLART IN ( 'KG', 'KR', 'KA' ).

*SORT IT_BKPF.

IF IT_BKPF IS NOT INITIAL.
  SELECT BUKRS
         BELNR
         GJAHR
         BUZEI
         BSCHL
         GSBER
         MWSKZ
         DMBTR
         TXGRP
         LIFNR FROM BSEG INTO TABLE IT_BSEG
               FOR ALL ENTRIES IN  IT_BKPF
               WHERE BELNR = IT_BKPF-BELNR
               AND GJAHR = IT_BKPF-GJAHR
               AND BUKRS = IT_BKPF-BUKRS
               AND GSBER IN S_GSBER.
ENDIF.

IF IT_BSEG IS NOT INITIAL.
  SELECT BUKRS
         BELNR
         GJAHR
         BUZEI
         MWSKZ
         TXGRP
         SHKZG
         FWBAS
         HWSTE
         KSCHL
         KBETR FROM BSET INTO TABLE IT_BSET
               FOR ALL ENTRIES IN IT_BSEG
               WHERE BELNR = IT_BSEG-BELNR
               AND GJAHR = IT_BSEG-GJAHR
               AND BUKRS = IT_BSEG-BUKRS.

SELECT LIFNR
       NAME1 FROM LFA1 INTO TABLE IT_LFA1
             FOR ALL ENTRIES IN IT_BSEG
             WHERE LIFNR = IT_BSEG-LIFNR.
ENDIF.

IT_BSEG1 = IT_BSEG[].
DELETE IT_BSEG WHERE TXGRP IS INITIAL.

CLEAR SLNO.
LOOP AT IT_BSEG INTO WA_BSEG.

WA_FINAL-GSBER = WA_BSEG-GSBER.
IF WA_BSEG-BSCHL = '40'.
WA_FINAL-DMBTR = WA_BSEG-DMBTR.
ENDIF.

IF WA_BSEG-BSCHL = '50'.
  WA_FINAL-DMBTR = WA_BSEG-DMBTR * -1.
ENDIF.

READ TABLE IT_BKPF INTO WA_BKPF WITH KEY BELNR = WA_BSEG-BELNR.
IF SY-SUBRC = 0.
  WA_FINAL-BLDAT = WA_BKPF-BLDAT.
  WA_FINAL-BUDAT = WA_BKPF-BUDAT.
  WA_FINAL-XBLNR = WA_BKPF-XBLNR.
  WA_FINAL-BELNR = WA_BKPF-BELNR.
  WA_FINAL-BLART = WA_BKPF-BLART.
ENDIF.
READ TABLE IT_LFA1 INTO WA_LFA1 WITH KEY LIFNR = WA_BSEG-LIFNR.
 IF SY-SUBRC = 0.
   WA_FINAL-LIFNR = WA_LFA1-LIFNR.
   WA_FINAL-NAME1 = WA_LFA1-NAME1.
 ENDIF.
SLNO = SLNO + 1.
WA_FINAL-SLNO = SLNO.
IF WA_BSEG-BSCHL = '40'.
LOOP AT IT_BSET INTO WA_BSET WHERE BELNR = WA_BSEG-BELNR AND TXGRP = WA_BSEG-TXGRP.
* IF SY-SUBRC = 0.
   IF WA_BSET-KSCHL = 'JICG'.
     WA_FINAL-CGSTP = WA_BSET-KBETR / 10.
     WA_FINAL-CGSTV = WA_BSET-HWSTE.
   ELSEIF WA_BSET-KSCHL = 'JISG'.
     WA_FINAL-SGSTP = WA_BSET-KBETR / 10.
     WA_FINAL-SGSTV = WA_BSET-HWSTE.
   ELSEIF WA_BSET-KSCHL = 'JIIG'.
     WA_FINAL-IGSTP = WA_BSET-KBETR / 10.
     WA_FINAL-IGSTV = WA_BSET-HWSTE.
   ENDIF.
ENDLOOP.
ENDIF.

IF WA_BSEG-BSCHL = '50'.
LOOP AT IT_BSET INTO WA_BSET WHERE BELNR = WA_BSEG-BELNR AND TXGRP = WA_BSEG-TXGRP.
* IF SY-SUBRC = 0.
   IF WA_BSET-KSCHL = 'JICG'.
     WA_FINAL-CGSTP = WA_BSET-KBETR / 10.
     WA_FINAL-CGSTV = WA_BSET-HWSTE * -1.
   ELSEIF WA_BSET-KSCHL = 'JISG'.
     WA_FINAL-SGSTP = WA_BSET-KBETR / 10.
     WA_FINAL-SGSTV = WA_BSET-HWSTE * -1.
   ELSEIF WA_BSET-KSCHL = 'JIIG'.
     WA_FINAL-IGSTP = WA_BSET-KBETR / 10.
     WA_FINAL-IGSTV = WA_BSET-HWSTE * -1.
   ENDIF.
ENDLOOP.
ENDIF.

WA_FINAL-DMBTR1 = WA_FINAL-DMBTR + WA_FINAL-CGSTV + WA_FINAL-SGSTV + WA_FINAL-IGSTV.
APPEND WA_FINAL TO IT_FINAL.
 CLEAR WA_FINAL.
ENDLOOP.

DELETE IT_BSEG1 WHERE BSCHL <> '31' AND BSCHL <> '22'.
LOOP AT IT_FINAL INTO WA_FINAL.
  READ TABLE IT_BSEG1 INTO WA_BSEG1 WITH KEY BELNR = WA_FINAL-BELNR.
  IF SY-SUBRC = 0.
    READ TABLE IT_LFA1 INTO WA_LFA1 WITH KEY LIFNR = WA_BSEG1-LIFNR.
     IF SY-SUBRC = 0.
       WA_FINAL-NAME1 = WA_LFA1-NAME1.
       MODIFY IT_FINAL FROM WA_FINAL TRANSPORTING NAME1.
     ENDIF.
  ENDIF.
ENDLOOP.

  WA_SORT-FIELDNAME = 'BELNR'.
  WA_SORT-UP = 'X'.
  WA_SORT-SUBTOT = 'X '.
  APPEND WA_SORT TO I_SORT .

  WA_FCAT-FIELDNAME = 'BLART'.
  WA_FCAT-SELTEXT_M = 'Document Type'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'BELNR'.
  WA_FCAT-SELTEXT_M = 'Document No'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'NAME1'.
  WA_FCAT-SELTEXT_M = 'Vendor Name'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'BLDAT'.
  WA_FCAT-SELTEXT_M = 'Document Date'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'BUDAT'.
  WA_FCAT-SELTEXT_M = 'Posting Date'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'XBLNR'.
  WA_FCAT-SELTEXT_M = 'Reference'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'GSBER'.
  WA_FCAT-SELTEXT_M = 'Businee Area'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'DMBTR'.
  WA_FCAT-SELTEXT_M = 'Taxable Amount'.
  WA_FCAT-DO_SUM = 'X'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'CGSTP'.
  WA_FCAT-SELTEXT_M = 'CGST Per.'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'CGSTV'.
  WA_FCAT-SELTEXT_M = 'CGST Value'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'SGSTP'.
  WA_FCAT-SELTEXT_M = 'SGST Per.'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'SGSTV'.
  WA_FCAT-SELTEXT_M = 'SGST Value'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'IGSTP'.
  WA_FCAT-SELTEXT_M = 'IGST Per.'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'IGSTV'.
  WA_FCAT-SELTEXT_M = 'IGST Value'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'DMBTR1'.
  WA_FCAT-SELTEXT_M = 'Total Amount'.
  WA_FCAT-DO_SUM = 'X'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
   I_CALLBACK_PROGRAM                = SY-REPID
*   IS_LAYOUT                         =
   IT_FIELDCAT                       = IT_FCAT[]
   IT_SORT                           = I_SORT
*   I_DEFAULT                         = 'X'
   I_SAVE                            = 'X'
  TABLES
    T_OUTTAB                          = IT_FINAL.
ENDFORM.
