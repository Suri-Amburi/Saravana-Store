*&---------------------------------------------------------------------*
*& Include          ZFI_SALES_REG_SUB
*&---------------------------------------------------------------------*

FORM SELECT_QUERRY.

  SELECT VBELN
         FKART
         FKDAT
         REGIO
         KUNRG
         KUNAG
         KNUMV
         KURRF
         XBLNR
         SPART
         BELNR
         GJAHR
*         RFBSK
         FROM VBRK INTO TABLE IT_VBRK
         WHERE FKDAT IN S_FKDAT
         AND BELNR <> ' '
         AND FKSTO <> 'X'
         AND FKART IN S_FKART .
         SORT IT_VBRK BY VBELN FKDAT.

  IF IT_VBRK IS NOT INITIAL.
    SELECT *
           FROM TSPAT INTO TABLE IT_TSPAT
           FOR ALL ENTRIES IN IT_VBRK
           WHERE SPART = IT_VBRK-SPART
           AND SPRAS = SY-LANGU.

    SELECT VBELN
           PARVW
           KUNNR
           ADRNR
           FROM VBPA INTO TABLE IT_VBPA
           FOR ALL ENTRIES IN IT_VBRK
           WHERE VBELN = IT_VBRK-VBELN.

    IF IT_VBPA IS NOT INITIAL.
      SELECT SPRAS
             KUNNR
             NAME1
             NAME2
             STCD3
             ADRNR
             REGIO
             J_1IPANREF
             LAND1
             ORT01
             PSTLZ
             FROM KNA1 INTO TABLE IT_KNA1
             FOR ALL ENTRIES IN IT_VBPA
             WHERE KUNNR = IT_VBPA-KUNNR.
    ENDIF.

    IF IT_KNA1 IS NOT INITIAL.
      SELECT SPRAS
             LAND1
             BLAND
             BEZEI
             FROM T005U INTO TABLE PF_T005U
             FOR ALL ENTRIES IN IT_KNA1
             WHERE SPRAS = IT_KNA1-SPRAS
             AND LAND1 = IT_KNA1-LAND1
             AND BLAND = IT_KNA1-REGIO.

    ENDIF.

    SELECT VBELN
           NETWR
           POSNR
           MATNR
           ARKTX
           WERKS
           FKIMG
           VRKME
           SPART
           VTWEG_AUFT
           WAERK
           AUBEL
           VGBEL
           CHARG
           KURSK
*           ZZLIN
*           ZZDT
           FROM VBRP INTO TABLE IT_VBRP
           FOR ALL ENTRIES IN IT_VBRK
           WHERE VBELN = IT_VBRK-VBELN .
           SORT IT_VBRK BY VBELN.

    SELECT KNUMV
           KPOSN
           KSCHL
           KNUMH
           KOPOS
           KWERT
           KBETR
           KKURS
           WAERS
           FROM PRCD_ELEMENTS INTO TABLE IT_PRCD
           FOR ALL ENTRIES IN IT_VBRK
           WHERE KNUMV  = IT_VBRK-KNUMV.
  ENDIF .

  IF IT_VBRP IS NOT INITIAL.
    SELECT *
           FROM VTTP INTO TABLE IT_VTTP
           FOR ALL ENTRIES IN IT_VBRP
           WHERE VBELN = IT_VBRP-VGBEL.
  ENDIF.

  IF IT_VTTP IS NOT INITIAL.
    SELECT *
           FROM VTTK INTO TABLE IT_VTTK
           FOR ALL ENTRIES IN IT_VTTP
           WHERE TKNUM = IT_VTTP-TKNUM.
  ENDIF.

  IF IT_VBRP IS NOT INITIAL.
    SELECT VBELN
           AUART
           FROM VBAK INTO TABLE IT_VBAK
           FOR ALL ENTRIES IN IT_VBRP
           WHERE VBELN = IT_VBRP-AUBEL.

    SELECT WERKS
           NAME1
           FROM T001W INTO TABLE IT_T001W
           FOR ALL ENTRIES IN IT_VBRP
           WHERE WERKS = IT_VBRP-WERKS.

    SELECT MATNR
           MTART
           FROM MARA INTO TABLE IT_MARA
           FOR ALL ENTRIES IN IT_VBRP
           WHERE MATNR = IT_VBRP-MATNR.
           SORT IT_MARA BY MATNR.

    SELECT
           MATNR
           STEUC
           FROM MARC INTO TABLE IT_MARC
           FOR ALL ENTRIES IN IT_VBRP
           WHERE MATNR = IT_VBRP-MATNR
           AND WERKS IN ('P001','P002','P003').

  ENDIF.

  IF IT_MARC IS NOT INITIAL .
    SELECT STEUC
           TEXT1
           FROM T604N INTO TABLE IT_T604N
           FOR ALL ENTRIES IN IT_MARC
           WHERE STEUC = IT_MARC-STEUC
           AND SPRAS = 'EN'
           AND LAND1 = 'IN'.
  ENDIF .

  IF IT_VBRP IS NOT INITIAL .
    SELECT MATNR
           MAKTX
           FROM MAKT INTO TABLE IT_MAKT
           FOR ALL ENTRIES IN IT_VBRP
           WHERE MATNR = IT_VBRP-MATNR.            "#EC CI_NO_TRANSFORM
  ENDIF.

  IF IT_VBRK IS NOT INITIAL .
    SELECT VBELV
           VBELN
           VBTYP_V
           FROM VBFA INTO TABLE IT_VBFA
           FOR ALL ENTRIES IN IT_VBRK
           WHERE VBELN = IT_VBRK-VBELN.

    SELECT BELNR
           GJAHR
           BUZID
           KOART
           DMBTR
           TXGRP
           FROM BSEG INTO TABLE LT_BSEG
           FOR ALL ENTRIES IN IT_VBRK
           WHERE BELNR = IT_VBRK-BELNR
           AND GJAHR = IT_VBRK-GJAHR
           AND BUZID <> 'T'
           AND KOART <> 'D'.

    IF LT_BSEG IS NOT INITIAL.
      SELECT BELNR
             GJAHR
             HWSTE
             KSCHL
             FROM BSET INTO TABLE LT_BSET
             FOR ALL ENTRIES IN LT_BSEG
             WHERE BELNR = LT_BSEG-BELNR
             AND GJAHR = LT_BSEG-GJAHR.
    ENDIF.
  ENDIF.


  IF IT_VBFA IS NOT INITIAL.
    SELECT MBLNR
           LIFNR
           MATNR
           FROM MSEG INTO TABLE IT_MSEG
           FOR ALL ENTRIES IN IT_VBFA
           WHERE MBLNR = IT_VBFA-VBELV AND SHKZG = 'H'.
  ENDIF.

  IF IT_MSEG IS NOT INITIAL .
    SELECT LIFNR
           LAND1
           NAME1
           NAME2
           STCD3
           J_1IPANREF
           REGIO
           FROM LFA1 INTO TABLE IT_LFA1
           FOR ALL ENTRIES IN IT_MSEG
           WHERE LIFNR = IT_MSEG-LIFNR.

  ENDIF.

  IF IT_VBRP IS NOT INITIAL.
    SELECT J_1IMATNR
           J_1IVALASS
           J_1IWAERS
           FROM J_1IASSVAL INTO TABLE IT_J_1IASSVAL
           FOR ALL ENTRIES IN IT_VBRP
           WHERE J_1IMATNR = IT_VBRP-MATNR.

    SELECT MATNR
           BWKEY
           VERPR
           ZPLP1
           ZPLP2
           ZPLP3
           VPRSV
           STPRS
           FROM MBEW INTO TABLE IT_MBEW
           FOR ALL ENTRIES IN IT_VBRP
           WHERE MATNR = IT_VBRP-MATNR.
  ENDIF.

  IF IT_VBAK IS NOT INITIAL .
    SELECT *
           FROM TVAKT INTO TABLE IT_TVAKT
           FOR ALL ENTRIES IN IT_VBAK
           WHERE AUART = IT_VBAK-AUART
           AND SPRAS = SY-LANGU.
  ENDIF.

  SELECT BUKRS
         BELNR
         GJAHR
         H_BUDAT
         BSCHL
         BUZEI
         KUNNR
         VBEL2
         LIFNR
         MATNR
         HSN_SAC
         KTOSL
         TXGRP
         H_BLART
         KOART
         FROM BSEG INTO TABLE IT_BSEG
         WHERE ( ( BSCHL IN  ( '19','01' ) AND KOART = 'D' )
         OR    ( BSCHL = '96' AND BUZID = 'W' AND SHKZG = 'H' AND KTOSL = 'WRX' )
         OR    ( BSCHL = '50' AND SHKZG = 'H' AND KTOSL = ' ' ) ).


  SELECT BUKRS
         BELNR
         GJAHR
         H_BUDAT
         BSCHL
         BUZEI
         KUNNR
         VBEL2
         LIFNR
         MATNR
         HSN_SAC
         KTOSL
         TXGRP
         H_BLART
         KOART
         MWSKZ
         FROM BSEG INTO TABLE IT_BSEG1
         WHERE BSCHL = '21'
         OR BSCHL = '22'
         AND SHKZG = 'H'
         AND KTOSL = ' '.

  IF IT_BSEG IS NOT INITIAL.
    SELECT BUKRS
           BELNR
           GJAHR
           BLART
           BUDAT
           FROM BKPF INTO TABLE IT_BKPF
           FOR ALL ENTRIES IN IT_BSEG
           WHERE BELNR = IT_BSEG-BELNR AND BUKRS  = '1000'
           AND GJAHR = IT_BSEG-GJAHR .

    SELECT BUKRS
           BELNR
           GJAHR
           HWBAS
           HWSTE
           KSCHL
           KBETR
           BUZEI
           KTOSL
           TXGRP
           SHKZG
           FROM BSET INTO TABLE IT_BSET
           FOR ALL ENTRIES IN IT_BSEG
           WHERE BELNR = IT_BSEG-BELNR AND BUKRS  = '1000'
           AND GJAHR = IT_BSEG-GJAHR.

    SELECT VBELN
           MATNR
           FROM VBAP INTO TABLE IT_VBAP
           FOR ALL ENTRIES IN IT_BSEG
           WHERE VBELN  = IT_BSEG-VBEL2.

    SELECT KUNNR
           NAME1
           NAME2
           STCD3
           ADRNR
           REGIO
           J_1IPANREF
           FROM KNA1 INTO TABLE IT_KNA12
           FOR ALL ENTRIES IN IT_BSEG
           WHERE KUNNR = IT_BSEG-KUNNR.
           SORT IT_KNA12 BY NAME1.
  ENDIF.

  IF IT_VBAP IS NOT INITIAL.
    SELECT MATNR
           MTART
           FROM MARA INTO TABLE IT_MARA
           FOR ALL ENTRIES IN IT_VBAP
           WHERE MATNR = IT_VBAP-MATNR .
           SORT IT_MARA BY MATNR.

    SELECT MATNR
           MAKTX
           FROM MAKT INTO TABLE IT_MAKT
           FOR ALL ENTRIES IN IT_VBAP
           WHERE MATNR = IT_VBAP-MATNR.
  ENDIF.

  IF IT_KNA12 IS NOT INITIAL.
    SELECT SPRAS
           LAND1
           BLAND
           BEZEI
           FROM T005U INTO TABLE IT_T005U
           FOR ALL ENTRIES IN IT_KNA12
           WHERE BLAND = IT_KNA12-REGIO
           AND SPRAS = 'EN' AND LAND1 = 'IN'.
  ENDIF .

  IF IT_BSEG1 IS NOT INITIAL.
    SELECT  LIFNR
            LAND1
            NAME1
            NAME2
            STCD3
            J_1IPANREF
            REGIO
            FROM LFA1 INTO TABLE IT_LFA1
            FOR ALL ENTRIES IN IT_BSEG1
            WHERE LIFNR = IT_BSEG1-LIFNR.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
  CLEAR:WA_VBRP.

  LOOP AT IT_VBRP INTO WA_VBRP.
    CLEAR:WA_MARC,WA_MARA,WA_MAKT,WA_PRCD,WA_VBPA,WA_VBFA.

    READ TABLE IT_VBPA INTO DATA(SP_VBPA) WITH KEY VBELN = WA_VBRP-VBELN PARVW = 'AG'.
    IF SY-SUBRC = 0.
      READ TABLE IT_KNA1 INTO DATA(SP_KNA1) WITH KEY KUNNR = SP_VBPA-KUNNR.
      IF SY-SUBRC = 0.
        WA_FIN-SPNAME = SP_KNA1-NAME1.

        READ TABLE PF_T005U INTO DATA(SP_T005U) WITH KEY SPRAS = SP_KNA1-SPRAS LAND1 = SP_KNA1-LAND1 BLAND = SP_KNA1-REGIO.
        IF SY-SUBRC = 0.
          WA_FIN-SPREGION  = SP_T005U-BEZEI.
          WA_FIN-SPCOUNTRY = SP_T005U-LAND1.
        ENDIF.
      ENDIF.
    ENDIF.

    READ TABLE IT_VBPA INTO DATA(SH_VBPA) WITH KEY VBELN = WA_VBRP-VBELN PARVW = 'WE'.
    IF SY-SUBRC = 0.
      READ TABLE IT_KNA1 INTO DATA(SH_KNA1) WITH KEY KUNNR = SH_VBPA-KUNNR.
      IF SY-SUBRC = 0.
        WA_FIN-SHNAME = SH_KNA1-NAME1.
        WA_FIN-SHGST  = SH_KNA1-STCD3.

        READ TABLE PF_T005U INTO DATA(SH_T005U) WITH KEY SPRAS = SH_KNA1-SPRAS LAND1 = SH_KNA1-LAND1 BLAND = SH_KNA1-REGIO.
        IF SY-SUBRC = 0.
*          WA_FIN-SHREGION  = SH_T005U-BEZEI.
*          WA_FIN-SHCOUNTRY = SH_T005U-LAND1.
        ENDIF.
      ENDIF.
    ENDIF.

    IF WA_VBRP-FKIMG = 0.
      CONTINUE.
    ENDIF.
    WA_FIN-MATNR      = WA_VBRP-MATNR.
    WA_FIN-POSNR      = WA_VBRP-POSNR."""line itm
    WA_FIN-MATNR      = WA_VBRP-MATNR.
    WA_FIN-ARKTX      = WA_VBRP-ARKTX.
    WA_FIN-FKIMG      = WA_VBRP-FKIMG.
    WA_FIN-VRKME      = WA_VBRP-VRKME.
    WA_FIN-SPART      = WA_VBRP-SPART.
    WA_FIN-WERKS      = WA_VBRP-WERKS.
    WA_FIN-VTWEG_AUFT = WA_VBRP-VTWEG_AUFT.
*    WA_FIN-LICNO      = WA_VBRP-ZZLIN.
*    WA_FIN-LICDATE    = WA_VBRP-ZZDT.
*    WA_FIN-BASE_AMT1 = WA_VBRP-NETWR * WA_VBRP-KURSK.

    READ TABLE IT_VBRK INTO WA_VBRK WITH KEY VBELN = WA_VBRP-VBELN.
    IF SY-SUBRC = 0.
      WA_FIN-EXCH_RATE = WA_VBRK-KURRF .

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = WA_VBRK-VBELN
        IMPORTING
          OUTPUT = WA_FIN-VBELN.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = WA_VBRK-XBLNR
        IMPORTING
          OUTPUT = WA_FIN-XBLNR.

      WA_FIN-REGIO    =  WA_VBRK-REGIO.
      WA_FIN-FKDAT    =  WA_VBRK-FKDAT.
      WA_FIN-FKART    =  WA_VBRK-FKART.

      READ TABLE IT_TSPAT INTO WA_TSPAT WITH KEY SPART = WA_VBRK-SPART.
      IF SY-SUBRC IS INITIAL.
        WA_FIN-VTEXT  = WA_TSPAT-VTEXT.
      ENDIF.

      READ TABLE IT_VBAK INTO WA_VBAK WITH KEY VBELN = WA_VBRP-AUBEL.
      IF SY-SUBRC IS INITIAL.
        WA_FIN-AUART  = WA_VBAK-AUART.
      ENDIF.

      READ TABLE IT_T001W INTO WA_T001W WITH KEY WERKS = WA_VBRP-WERKS.
      IF SY-SUBRC IS INITIAL.
        WA_FIN-BNAME  = WA_T001W-NAME1.
      ENDIF.

      READ TABLE IT_TVAKT INTO WA_TVAKT WITH KEY AUART = WA_VBAK-AUART.
      IF SY-SUBRC IS INITIAL.
        WA_FIN-BEZEI1  = WA_TVAKT-BEZEI.
      ENDIF.

      REFRESH IT_CHAR.
      CALL FUNCTION 'VB_BATCH_GET_DETAIL'
        EXPORTING
          MATNR              = WA_VBRP-MATNR
          CHARG              = WA_VBRP-CHARG
          GET_CLASSIFICATION = 'X'
        TABLES
          CHAR_OF_BATCH      = IT_CHAR
        EXCEPTIONS
          NO_MATERIAL        = 1
          NO_BATCH           = 2
          NO_PLANT           = 3
          MATERIAL_NOT_FOUND = 4
          PLANT_NOT_FOUND    = 5
          NO_AUTHORITY       = 6
          BATCH_NOT_EXIST    = 7
          LOCK_ON_BATCH      = 8
          OTHERS             = 9.

      CLEAR WA_CHAR.
      READ TABLE IT_CHAR INTO WA_CHAR WITH KEY ATNAM = 'GRADE'.
      IF SY-SUBRC IS INITIAL.
        WA_FIN-GRADE = WA_CHAR-ATWTB.
      ENDIF.

      CLEAR WA_CHAR.
      READ TABLE IT_CHAR INTO WA_CHAR WITH KEY ATNAM = 'GENERIC_MERGE'.
      IF SY-SUBRC IS INITIAL.
        WA_FIN-MERGE = WA_CHAR-ATWTB.
      ENDIF.

      READ TABLE IT_VTTP INTO WA_VTTP WITH KEY VBELN = WA_VBRP-VGBEL.
      IF SY-SUBRC IS INITIAL.
        READ TABLE IT_VTTK INTO WA_VTTK WITH KEY TKNUM = WA_VTTP-TKNUM.
        IF SY-SUBRC IS INITIAL.
          WA_FIN-TDLNR        = WA_VTTK-TDLNR.
          WA_FIN-SIGNI        = WA_VTTK-SIGNI.
          WA_FIN-SHBILLNO     = WA_VTTK-EXTI1.
          WA_FIN-SFBILLDAT    = WA_VTTK-EXTI2.
          WA_FIN-TNDR_TRKID   = WA_VTTK-TNDR_TRKID.
          WA_FIN-AWBILLNO     = WA_VTTK-TEXT1.
          WA_FIN-AWBILLDAT    = WA_VTTK-TEXT2.

          READ TABLE IT_LFA1 INTO WA_LFA1 WITH KEY LIFNR = WA_VTTK-TDLNR.
          IF SY-SUBRC IS INITIAL.
            WA_FIN-TRNAME1   =  WA_LFA1-NAME1.
          ENDIF.
        ENDIF.
      ENDIF.

      SELECT * FROM LQUA INTO TABLE TLQUA WHERE MATNR = WA_VBRP-MATNR AND CHARG = WA_VBRP-CHARG AND WERKS = WA_VBRP-WERKS .
      DESCRIBE TABLE TLQUA LINES TINDEX.
      WA_FIN-CRTONS = TINDEX.

      CLEAR:WA_VBPA,WA_KNA1,WA_T005U.
      READ TABLE IT_VBPA INTO WA_VBPA WITH KEY VBELN = WA_VBRP-VBELN PARVW = 'WE'.
      IF SY-SUBRC IS INITIAL.

        READ TABLE IT_KNA1 INTO WA_KNA1 WITH KEY KUNNR = WA_VBPA-KUNNR.
        IF SY-SUBRC IS INITIAL.
          WA_FIN-SHDP     = WA_VBRK-KUNAG.
*          WA_FIN-SHNAME   = WA_KNA1-NAME1.
          WA_FIN-SHRT0    = WA_KNA1-ORT01.
          WA_FIN-SHPSTLZ  = WA_KNA1-PSTLZ.                                      ""GSTIN/UIN
          WA_FIN-SHSTCD3  = WA_KNA1-STCD3.
          READ TABLE IT_T005U INTO WA_T005U WITH KEY BLAND = WA_KNA1-REGIO.
          WA_FIN-SHREGIO  = WA_T005U-BEZEI.                                       ""GSTIN/UIN
        ENDIF.
      ENDIF.


      IF WA_VBRK-FKART = 'F2' OR WA_VBRK-FKART = 'F5' "OR  wa_vbrk-fkart = 'F8' " wa_vbrk-fkart = 'ZF8'
           OR  WA_VBRK-FKART = 'G2'
           OR  WA_VBRK-FKART = 'L2' OR  WA_VBRK-FKART = 'RE' OR  WA_VBRK-FKART = 'S1' OR  WA_VBRK-FKART = 'S2'
           OR  WA_VBRK-FKART = 'ZATH' OR   WA_VBRK-FKART = 'ZSCP' OR  WA_VBRK-FKART = 'ZSGM'
           OR  WA_VBRK-FKART = 'ZSTO' OR  WA_VBRK-FKART = 'ZSYL' .
        GDSVR1 = 'GOODS'.
      ELSEIF WA_VBRK-FKART = 'ZJBW'.
        GDSVR1 = 'SERVICE'.
      ENDIF.
    ENDIF.

    IF WA_VBRP-VBELN IS NOT INITIAL.

      CLEAR:V_TDNAME.
      REFRESH:IT_LINE.
      V_TDNAME = WA_VBRP-VBELN.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          CLIENT                  = SY-MANDT
          ID                      = 'A005'
          LANGUAGE                = 'E'
          NAME                    = V_TDNAME
          OBJECT                  = 'VBBK'
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

      IF SY-SUBRC EQ 0.
        LOOP AT IT_LINE .
          CONCATENATE IT_LINE-TDLINE WA_FIN-LRNO INTO WA_FIN-LRNO SEPARATED BY SPACE.
        ENDLOOP.
      ENDIF.

    ELSEIF WA_VBRP-VBELN IS INITIAL.

      CLEAR:V_TDNAME.
      REFRESH:IT_LINE.
      V_TDNAME = WA_VBRP-VGBEL.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          CLIENT                  = SY-MANDT
          ID                      = 'A005'
          LANGUAGE                = 'E'
          NAME                    = V_TDNAME
          OBJECT                  = 'VBBK'
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

      IF SY-SUBRC EQ 0.
        LOOP AT IT_LINE.
          CONCATENATE IT_LINE-TDLINE WA_FIN-LRNO INTO WA_FIN-LRNO SEPARATED BY SPACE.
        ENDLOOP.
      ENDIF.
    ENDIF.

    CLEAR:V_TDNAME.
    REFRESH:IT_LINE.
    V_TDNAME = WA_VBRP-VBELN.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        CLIENT                  = SY-MANDT
        ID                      = 'A004'
        LANGUAGE                = 'E'
        NAME                    = V_TDNAME
        OBJECT                  = 'VBBK'
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

    IF SY-SUBRC EQ 0.
      LOOP AT IT_LINE.
        CONCATENATE IT_LINE-TDLINE WA_FIN-EWAYB INTO WA_FIN-EWAYB SEPARATED BY SPACE.
      ENDLOOP.
    ENDIF.


    WA_FIN-GDSVR  = GDSVR1.
    CLEAR: GDSVR1,WA_VBPA,WA_VBFA.
    READ TABLE IT_VBFA INTO WA_VBFA WITH KEY VBELN = WA_VBRP-VBELN.

    IF SY-SUBRC = 0.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = WA_VBFA-VBELV
        IMPORTING
          OUTPUT = WA_FIN-VBELN1.
      READ TABLE IT_VBPA INTO WA_VBPA WITH KEY VBELN = WA_VBFA-VBELN "vbeln = wa_vbfa-vbelv
                                               PARVW = 'WE'.
      IF SY-SUBRC = 0.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = WA_VBPA-KUNNR
          IMPORTING
            OUTPUT = WA_FIN-KUNNR.

        READ TABLE IT_KNA1 INTO WA_KNA1 WITH KEY KUNNR = WA_VBPA-KUNNR.
        IF SY-SUBRC = 0.
          WA_FIN-STCD31  = WA_KNA1-STCD3.

          IF WA_KNA1-STCD3 IS INITIAL.
            WA_FIN-STCD3 = WA_KNA1-J_1IPANREF.
          ENDIF.
*          WA_FIN-SOPREGIO = WA_KNA1-REGIO .
          WA_FIN-SOPCNTRY = WA_KNA1-LAND1 .
          CONCATENATE WA_KNA1-NAME1 WA_KNA1-NAME2 INTO  WA_FIN-BKUNNR SEPARATED BY ' '.
        ENDIF.

        READ TABLE IT_T005U_SP INTO WA_T005U_SP WITH KEY SPRAS = WA_KNA1-SPRAS LAND1 = WA_KNA1-LAND1 BLAND = WA_KNA1-REGIO.
        WA_FIN-SOPREGIO = WA_T005U_SP-BEZEI .
      ENDIF.

      CLEAR:WA_VBPA,WA_KNA1 .
      READ TABLE IT_VBPA INTO WA_VBPA WITH KEY VBELN = WA_VBFA-VBELN " vbeln = wa_vbfa-vbelv
                                                        PARVW = 'RE'.
      IF SY-SUBRC IS INITIAL.
        READ TABLE IT_KNA1 INTO WA_KNA1 WITH KEY KUNNR = WA_VBPA-KUNNR.
        IF SY-SUBRC IS INITIAL.
          WA_FIN-BP     = WA_VBPA-KUNNR.
          WA_FIN-BPNAME   = WA_KNA1-NAME1.
          WA_FIN-BPSTCD3  = WA_KNA1-STCD3.
          WA_FIN-BPREGIO  = WA_KNA1-REGIO.
          WA_FIN-BPCNTRY = WA_KNA1-LAND1 .
        ENDIF.
      ENDIF.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = WA_FIN-VBELN
      IMPORTING
        OUTPUT = LV_VBELN.

    LV_VBELN1 = LV_VBELN.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        CLIENT                  = SY-MANDT
        ID                      = 'A002'
        LANGUAGE                = 'E'
        NAME                    = LV_VBELN1
        OBJECT                  = 'VBBK'
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

    IF SY-SUBRC EQ 0.
      LOOP AT IT_LINE .
        CONCATENATE IT_LINE-TDLINE WA_FIN-TBILLENT INTO WA_FIN-TBILLENT SEPARATED BY ' '.
      ENDLOOP.
      REFRESH IT_LINE.
    ENDIF.

*************shipment bill *******************
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        CLIENT                  = SY-MANDT
        ID                      = 'A003'
        LANGUAGE                = 'E'
        NAME                    = LV_VBELN1
        OBJECT                  = 'VBBK'
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

    IF SY-SUBRC EQ 0.
      LOOP AT IT_LINE .
        CONCATENATE IT_LINE-TDLINE WA_FIN-TSHP INTO WA_FIN-TSHP SEPARATED BY ' '.
      ENDLOOP.
      REFRESH IT_LINE.
    ENDIF.

    LV_VBELN1 = LV_VBELN .
****************** Exchange Rate Text *******************

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        CLIENT                  = SY-MANDT
        ID                      = 'A001'
        LANGUAGE                = 'E'
        NAME                    = LV_VBELN1
        OBJECT                  = 'VBBK'
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

    IF SY-SUBRC EQ 0.
      READ TABLE IT_LINE INDEX 1.
      IF SY-SUBRC = 0.
        WA_FIN-EXCH_RTEXT = IT_LINE-TDLINE.
      ENDIF.

      REFRESH IT_LINE.
    ENDIF.


    READ TABLE IT_PRCD INTO WA_PRCD WITH KEY KNUMV = WA_VBRK-KNUMV KPOSN = WA_VBRP-POSNR.
    IF SY-SUBRC = 0.
      LOOP AT IT_PRCD INTO WA_PRCD WHERE KNUMV = WA_VBRK-KNUMV
                                   AND KPOSN = WA_VBRP-POSNR
                                   AND KBETR IS NOT INITIAL
                                   AND KPOSN = WA_VBRP-POSNR.

        CASE WA_PRCD-KSCHL.
          WHEN 'ZCO1' OR 'ZCO2'.
            WA_FIN-CVALUE = WA_FIN-CVALUE + ( WA_PRCD-KWERT * WA_VBRK-KURRF ).
            CLEAR WA_PRCD-KWERT.

          WHEN 'ZEDD' OR 'ZEDV'.
            WA_FIN-DVALUE = WA_FIN-DVALUE + ( WA_PRCD-KWERT * WA_VBRK-KURRF ).
            CLEAR WA_PRCD-KWERT.

          WHEN 'ZEIN'.
            WA_FIN-IVALUE = WA_FIN-IVALUE + ( WA_PRCD-KWERT * WA_VBRK-KURRF ).
            CLEAR WA_PRCD-KWERT.

          WHEN 'ZEFR'.
            WA_FIN-FVALUE = WA_FIN-FVALUE + ( WA_PRCD-KWERT * WA_VBRK-KURRF ).
            CLEAR WA_PRCD-KWERT.

          WHEN 'JOIG'.
            WA_FIN-IGSTVAL = ( WA_PRCD-KWERT * WA_VBRK-KURRF ).
            CLEAR WA_PRCD-KWERT.

          WHEN 'JOSG'.
            WA_FIN-SGSTVAL = ( WA_PRCD-KWERT * WA_VBRK-KURRF ).
            CLEAR WA_PRCD-KWERT.

          WHEN 'JOCG'.
            WA_FIN-CGSTVAL = ( WA_PRCD-KWERT * WA_VBRK-KURRF ).
            CLEAR WA_PRCD-KWERT.

          WHEN 'JOUG'.
            WA_FIN-UGSTVAL = ( WA_PRCD-KWERT * WA_VBRK-KURRF ).
            CLEAR WA_PRCD-KWERT.
        ENDCASE.

        IF WA_VBRK-FKART = 'ZSTO' ."OR wa_vbrk-fkart = 'ZF8' .
        ELSE.
          CASE WA_PRCD-KSCHL.
            WHEN 'ZPR0' OR 'ZPR1' .
              WA_FIN-MAT_VALUE   = WA_PRCD-KWERT . "kwert.
              WA_FIN-WAERS = WA_PRCD-WAERS .
          ENDCASE.
        ENDIF .
        CLEAR:WA_PRCD.

      ENDLOOP.
      WA_FIN-TVALUE       = WA_VBRP-NETWR * WA_VBRK-KURRF.
      WA_FIN-TVALUE       = WA_FIN-TVALUE - ( WA_FIN-FVALUE + WA_FIN-DVALUE + WA_FIN-IVALUE ). "+ WA_FIN-CVALUE ).
      WA_FIN-TOTALINVOICE = WA_FIN-TVALUE  +
                            WA_FIN-FVALUE  +
                            WA_FIN-DVALUE  +
                            WA_FIN-IGSTVAL +
                            WA_FIN-SGSTVAL +
                            WA_FIN-CGSTVAL +
                            WA_FIN-UGSTVAL.

      WA_FIN-U_RATE       = WA_FIN-MAT_VALUE / WA_FIN-FKIMG .       " material value
      WA_FIN-BASE_AMT     = WA_FIN-MAT_VALUE + WA_FIN-SPC_DISC + WA_FIN-TDS_AMT + WA_FIN-CMS_AMT + WA_FIN-FREIGHT + WA_FIN-INS_COST + WA_FIN-CONVCHG.

      IF WA_VBRK-FKART = 'S1' .

        WA_FIN-MAT_VALUE  = WA_FIN-MAT_VALUE     * -1    .
        WA_FIN-FREIGHT    = WA_FIN-FREIGHT       * -1    .
        WA_FIN-CMS_AMT    = WA_FIN-CMS_AMT       * -1    .
        WA_FIN-CONVCHG    = WA_FIN-CONVCHG       * -1    .
        WA_FIN-SPC_DISC   = WA_FIN-SPC_DISC      * -1    .
        WA_FIN-TDS_AMT    = WA_FIN-TDS_AMT       * -1    .
        WA_FIN-RATE_DIF   = WA_FIN-RATE_DIF      * -1    .
        WA_FIN-INS_COST   = WA_FIN-INS_COST      * -1    .
        WA_FIN-TAX_SOURCE = WA_FIN-TAX_SOURCE    * -1    .
        WA_FIN-SGST       = WA_FIN-SGST          * -1    .
        WA_FIN-CGST       = WA_FIN-CGST          * -1    .
        WA_FIN-IGST       = WA_FIN-IGST          * -1    .
        WA_FIN-UTGST      = WA_FIN-UTGST         * -1    .
        WA_FIN-U_RATE     = WA_FIN-U_RATE        * -1    .
        WA_FIN-BASE_AMT   = WA_FIN-BASE_AMT      * -1    .
      ENDIF.
    ENDIF .

    IF WA_VBRK-FKART = 'ZSN'.
      CLEAR:T_PRCDT1[], W_PRCDT1,GTOTL,GZCPO,GZPAC,GZPA,GZINC,GZIN,GZFCH,GZFC,GZCPO,GTOTL.
      SELECT  * FROM PRCD_ELEMENTS INTO TABLE T_PRCDT1
                WHERE KNUMV = WA_VBRK-KNUMV
                AND KPOSN = WA_VBRP-POSNR
                AND KSCHL IN ( 'VPRS','EK02' ).

      READ TABLE T_PRCDT1 INTO W_PRCDT1 WITH KEY KSCHL =  'EK02'.
      IF W_PRCDT1-KWERT IS NOT INITIAL.

        IF SY-SUBRC = 0.
          GTOTL =  W_PRCDT1-KWERT.

          IF SGST = 0.
            SGSTP =  WA_FIN-SGSTP / 100.
            WA_FIN-SGST = ( SGSTP  * GTOTL ) .
            IF WA_LFA1-REGIO = 10.""""""""""if in invoice level there is no tax % maintained,,, calculating manually
              IF SGSTP = 0 OR SGSTP IS INITIAL.
                WA_FIN-SGSTP = '9.00'.
                SGSTPT = '0.09'.
                WA_FIN-SGST = ( SGSTPT  * GTOTL ) .
              ENDIF.
            ENDIF.
          ENDIF.

          IF CGST = 0.
            CGSTP =  WA_FIN-CGSTP / 100.
            WA_FIN-CGST = ( CGSTP * GTOTL ) .
            IF WA_LFA1-REGIO = 10.
              IF CGSTP = 0 OR CGSTP IS INITIAL.
                WA_FIN-CGSTP = '9.00'.
                CGSTPT = '0.09'.
                WA_FIN-CGST = ( CGSTPT  * GTOTL ) .
              ENDIF.
            ENDIF.
          ENDIF.

          IF IGST = 0.
            IGSTP =  WA_FIN-IGSTP / 100.
            WA_FIN-IGST = ( IGSTP  * GTOTL ) .
            IF WA_LFA1-REGIO <> 10.
              IF IGSTP = 0 OR IGSTP IS INITIAL.
                WA_FIN-IGSTP = '18.00'.
                IGSTPT = '0.18'.
                WA_FIN-IGST = ( IGSTPT  * GTOTL ) .
              ENDIF.
            ENDIF.
          ENDIF.

          IF UTGST = 0.
            UTGSTP =  WA_FIN-UTGSTP / 100.
            WA_FIN-UTGST = ( UTGSTP * GTOTL ) .
            IF WA_LFA1-REGIO = 10.
              IF UTGSTP = 0 OR UTGSTP IS INITIAL.
                WA_FIN-UTGSTP = '9.00'.
                UTGSTPT = '0.09'.
                WA_FIN-UTGST = ( UTGSTPT  * GTOTL ) .
              ENDIF.
            ENDIF.
          ENDIF.

        ENDIF.
      ENDIF.

      IF GTOTL IS INITIAL.
        CLEAR:T_PRCDT1[], W_PRCDT1,SGST,SGSTP,CGST,IGST,CGSTP,IGSTP,GTOTL.
        SELECT  * FROM PRCD_ELEMENTS INTO TABLE T_PRCDT1
                  WHERE KNUMV = WA_VBRK-KNUMV
                  AND KPOSN = WA_VBRP-POSNR
                  AND KSCHL = 'VPRS'.

        READ TABLE T_PRCDT1 INTO W_PRCDT1 WITH KEY KSCHL =  'VPRS'.
        IF W_PRCDT1-KWERT IS NOT INITIAL.
          IF SY-SUBRC = 0.
            GTOTL =  W_PRCDT1-KWERT.

            IF SGST = 0.
              SGSTP =  WA_FIN-SGSTP / 100.
              WA_FIN-SGST = ( SGSTP  * GTOTL ) .
              IF WA_LFA1-REGIO = 10.""""""""""if in invoice level there is no tax % maintained,,, calculating manually
                IF SGSTP = 0 OR SGSTP IS INITIAL.
                  WA_FIN-SGSTP = '9.00'.
                  SGSTPT = '0.09'.
                  WA_FIN-SGST = ( SGSTPT  * GTOTL ) .
                ENDIF.
              ENDIF.
            ENDIF.

            IF CGST = 0.
              CGSTP =  WA_FIN-CGSTP / 100.
              WA_FIN-CGST = ( CGSTP * GTOTL ) .
              IF WA_LFA1-REGIO = 10.
                IF CGSTP = 0 OR CGSTP IS INITIAL.
                  WA_FIN-CGSTP = '9.00'.
                  CGSTPT = '0.09'.
                  WA_FIN-CGST = ( CGSTPT  * GTOTL ) .
                ENDIF.
              ENDIF.
            ENDIF.

            IF IGST = 0.
              IGSTP =  WA_FIN-IGSTP / 100.
              WA_FIN-IGST = ( IGSTP  * GTOTL ) .
              IF WA_LFA1-REGIO <> 10.
                IF IGSTP = 0 OR SGSTP IS INITIAL.
                  WA_FIN-IGSTP = '18.00'.
                  IGSTPT = '0.18'.
                  WA_FIN-IGST = ( IGSTPT  * GTOTL ) .
                ENDIF.
              ENDIF.
            ENDIF.

            IF UTGST = 0.
              UTGSTP =  WA_FIN-UTGSTP / 100.
              WA_FIN-UTGST = ( UTGSTP * GTOTL ) .
              IF WA_LFA1-REGIO = 10.
                IF UTGSTP = 0 OR UTGSTP IS INITIAL.
                  WA_FIN-UTGSTP = '9.00'.
                  UTGSTPT = '0.09'.
                  WA_FIN-UTGST = ( UTGSTPT  * GTOTL ) .
                ENDIF.
              ENDIF.
            ENDIF.

          ENDIF.
        ENDIF.
      ENDIF.

      IF GTOTL IS INITIAL.   """fatch from matrial master value
        READ TABLE IT_MBEW INTO WA_MBEW WITH KEY MATNR = WA_VBRP-MATNR.
        IF SY-SUBRC = 0.

          IF WA_MBEW-VPRSV = 'V'.
            GTOTL =  ( WA_VBRP-FKIMG *  WA_MBEW-VERPR )."""Material Valuation for Total Value
          ELSEIF WA_MBEW-VPRSV = 'S'.
            GTOTL =  ( WA_VBRP-FKIMG *   WA_MBEW-STPRS )."""Material Valuation for Total Value
          ELSEIF WA_MBEW-ZPLP1 IS NOT INITIAL.
            GTOTL =  WA_MBEW-ZPLP1.
          ELSEIF WA_MBEW-ZPLP1 IS INITIAL.
            GTOTL =  WA_MBEW-ZPLP2.
          ELSEIF WA_MBEW-ZPLP1 IS INITIAL AND WA_MBEW-ZPLP2 IS INITIAL.
            GTOTL =  WA_MBEW-ZPLP3.
          ENDIF.
        ENDIF.

        IF GTOTL IS INITIAL.
          READ TABLE IT_J_1IASSVAL INTO WA_J_1IASSVAL WITH KEY J_1IMATNR = WA_VBRP-MATNR.
          IF SY-SUBRC = 0.
            GTOTL = ( WA_VBRP-FKIMG *  WA_J_1IASSVAL-J_1IVALASS ) .
          ENDIF.
        ENDIF.

        IF SGST = 0.
          SGSTP =  WA_FIN-SGSTP / 100.
          WA_FIN-SGST = ( SGSTP  * GTOTL ) .
          IF WA_LFA1-REGIO = 10.""""""""""if in invoice level there is no tax % maintained,,, calculating manually
            IF SGSTP = 0 OR SGSTP IS INITIAL.
              WA_FIN-SGSTP = '9.00'.
              SGSTPT = '0.09'.
              WA_FIN-SGST = ( SGSTPT  * GTOTL ) .
            ENDIF.
          ENDIF.
        ENDIF.

        IF CGST = 0.
          CGSTP =  WA_FIN-CGSTP / 100.
          WA_FIN-CGST = ( CGSTP * GTOTL ) .
          IF WA_LFA1-REGIO = 10.""""""""""if in invoice level there is no tax % maintained,,, calculating manually
            IF CGSTP = 0 OR CGSTP IS INITIAL.
              WA_FIN-CGSTP = '9.00'.
              CGSTPT = '0.09'.
              WA_FIN-CGST = ( CGSTPT  * GTOTL ) .
            ENDIF.
          ENDIF.
        ENDIF.

        IF IGST = 0.
          IF WA_LFA1-REGIO <> 10.""""""""""if in invoice level there is no tax % maintained,,, calculating manually
            IGSTP =  WA_FIN-IGSTP / 100.
            WA_FIN-IGST = ( IGSTP  * GTOTL ) .
            IF IGSTP = 0 OR IGSTP IS INITIAL.
              WA_FIN-IGSTP = '18.00'.
              IGSTPT = '0.18'.
              WA_FIN-IGST = ( IGSTPT  * GTOTL ) .
            ENDIF.
          ENDIF.
        ENDIF.

        IF UTGST = 0.
          IF WA_LFA1-REGIO <> 10.""""""""""if in invoice level there is no tax % maintained,,, calculating manually
            UTGSTP =  WA_FIN-UTGSTP / 100.
            WA_FIN-UTGST = ( UTGSTP  * GTOTL ) .
            IF UTGSTP = 0 OR UTGSTP IS INITIAL.
              WA_FIN-UTGSTP = '18.00'.
              UTGSTPT = '0.18'.
              WA_FIN-UTGST = ( UTGSTPT  * GTOTL ) .
            ENDIF.
          ENDIF.
        ENDIF.

      ENDIF.
    ENDIF.
    WA_FIN-TAXBL  =  GTOTL .
****<<<<<<<<<<<<<<<round off >>>>>>>>>>>>>>>>>>>>>>>>>>>>>

*    ROUNDOF =   WA_FIN-SGST .
*    IF  ROUNDOF IS NOT INITIAL.
*      CALL FUNCTION 'HR_IN_ROUND_AMT'
*        EXPORTING
*          AMOUNT = ROUNDOF
*          RNDOFF = '100'
*          RNDLMT = 'N'
*        IMPORTING
*          RETAMT = ROUNDOF1.
**              DLTAMT = ROUND.
*    ENDIF.
*    WA_FIN-SGST  = ROUNDOF1.
*    CLEAR:ROUNDOF,ROUNDOF1.
*
*    ROUNDOF =   WA_FIN-CGST .
*    IF  ROUNDOF IS NOT INITIAL.
*      CALL FUNCTION 'HR_IN_ROUND_AMT'
*        EXPORTING
*          AMOUNT = ROUNDOF
*          RNDOFF = '100'
*          RNDLMT = 'N'
*        IMPORTING
*          RETAMT = ROUNDOF1.
**              DLTAMT = ROUND.
*    ENDIF.
*    WA_FIN-CGST  = ROUNDOF1.
*    CLEAR:ROUNDOF,ROUNDOF1.
*
*    ROUNDOF =   WA_FIN-IGST .
*    IF  ROUNDOF IS NOT INITIAL.
*      CALL FUNCTION 'HR_IN_ROUND_AMT'
*        EXPORTING
*          AMOUNT = ROUNDOF
*          RNDOFF = '100'
*          RNDLMT = 'N'
*        IMPORTING
*          RETAMT = ROUNDOF1.
**              DLTAMT = ROUND.
*    ENDIF.
*    WA_FIN-IGST  = ROUNDOF1.
*    CLEAR:ROUNDOF,ROUNDOF1.
*
*    ROUNDOF =   WA_FIN-UTGST .
*    IF  ROUNDOF IS NOT INITIAL.
*      CALL FUNCTION 'HR_IN_ROUND_AMT'
*        EXPORTING
*          AMOUNT = ROUNDOF
*          RNDOFF = '100'
*          RNDLMT = 'N'
*        IMPORTING
*          RETAMT = ROUNDOF1.
**              DLTAMT = ROUND.
*    ENDIF.
*    WA_FIN-UTGST  = ROUNDOF1.
*    CLEAR:ROUNDOF,ROUNDOF1.

**********************************************************

    IF  WA_VBRK-FKART <> 'ZSER'.
      CLEAR:GZPRI.
    ENDIF.
    IF  WA_FIN-TAXBL IS INITIAL.
      WA_FIN-TAXBL   =  GZPAC + GZPA + GZINC + GZIN + GZFCH + GZFC + GTOTL + GZCPO + GZPRI.
    ENDIF.

    IF WA_VBRK-FKART = 'ZEES'.
      TAXZESS1       = WA_FIN-TAXBL.
      CALL FUNCTION 'CMS_API_CURR_CONV'
        EXPORTING
          I_ORIGINAL_CURR = WA_VBRP-WAERK
          I_ORIGINAL_AMT  = TAXZESS1
          I_RESULT_CURR   = 'INR'
          I_RATE_TYPE     = 'M'
          I_CONV_DATE     = WA_VBRK-FKDAT
        IMPORTING
          E_CONV_AMT      = TAXZESS.

      WA_FIN-TAXBL = TAXZESS.
      CLEAR:TAXZESS,TAXZESS1.
    ENDIF.

    WA_FIN-TOTGST =  WA_FIN-SGST + WA_FIN-CGST + WA_FIN-IGST + WA_FIN-UTGST.
    ROUNDOF       =  WA_FIN-TOTGST + WA_FIN-BASE_AMT1 + WA_FIN-TAX_SOURCE.

    IF ROUNDOF IS NOT INITIAL.
      CALL FUNCTION 'HR_IN_ROUND_AMT'
        EXPORTING
          AMOUNT  = ROUNDOF
          RNDOFF  = '100'
          RNDLMT  = 'N'
        IMPORTING
          RETAMT  = ROUNDOF1.
    ENDIF.

    WA_FIN-TOTVAL   =  ROUNDOF1.
    IF WA_FIN-WAERS = 'INR'.
      WA_FIN-CONV_AMT =  WA_FIN-TOTVAL .
    ELSE .
      WA_FIN-CONV_AMT = WA_FIN-EXCH_RATE * WA_FIN-TOTVAL .

    ENDIF.

    IF WA_FIN-EXCH_RTEXT IS NOT INITIAL.
      WA_FIN-CONV_AMT1 = WA_FIN-TOTVAL * WA_FIN-EXCH_RTEXT .
    ENDIF.

    CLEAR:ROUNDOF,ROUNDOF1,GTOTL,GTOTL1,GTOTL2,IGSTPT,SGSTPT,CGSTPT.
    CLEAR:SGST,SGSTP,CGST,IGST,UTGST,CGSTP,IGSTP,UTGSTP,GZCPO,GZPAC,GZPA,GZINC,GZIN,GZFCH,GZFC,GZCPO.

    READ TABLE IT_MARA INTO WA_MARA WITH  KEY MATNR = WA_VBRP-MATNR .
    IF SY-SUBRC = 0.
      WA_FIN-MATNR  = WA_MARA-MATNR.
    ENDIF.

    READ TABLE IT_MAKT INTO WA_MAKT WITH KEY  MATNR = WA_VBRP-MATNR.
    IF SY-SUBRC = 0.
      WA_FIN-MAKTX   = WA_MAKT-MAKTX.
    ENDIF.

    READ TABLE IT_MARC INTO WA_MARC WITH KEY MATNR = WA_VBRP-MATNR.
    IF SY-SUBRC = 0.
      WA_FIN-MATNR = WA_MARC-MATNR.
      WA_FIN-STEUC  = WA_MARC-STEUC.
      CONDENSE WA_FIN-STEUC.
    ENDIF.

    READ TABLE IT_T604N INTO WA_T604N WITH KEY STEUC = WA_MARC-STEUC .
    IF SY-SUBRC = 0.
      WA_FIN-TEXT1 = WA_T604N-TEXT1.
    ENDIF.

    CLEAR LV_TDNAME.
    REFRESH IT_TLINE.
    LV_TDNAME = WA_VBRP-VBELN.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        ID                      = 'Z001'
        LANGUAGE                = 'E'
        NAME                    = LV_TDNAME
        OBJECT                  = 'VBBK'
      TABLES
        LINES                   = IT_TLINE
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

    LOOP AT IT_TLINE INTO WA_TLINE WHERE TDLINE IS NOT INITIAL.
      SPLIT WA_TLINE-TDLINE AT ' ' INTO LV_EWBILLNO LV_EWBILLDAT.
      WA_FIN-EWAYBILLNO   = LV_EWBILLNO.
      WA_FIN-EWAYBILLDAT  = LV_EWBILLDAT.

    ENDLOOP .

    APPEND WA_FIN TO IT_FIN.
    CLEAR:WA_VBRK,WA_VBRP,WA_MARC,WA_MARA,WA_MAKT,WA_PRCD,WA_FIN,WA_J_1IASSVAL,WA_MBEW,GTOTL.
  ENDLOOP.

  SORT IT_FIN BY FKART VBELN POSNR .
  LOOP AT IT_FIN INTO WA_FIN.
    WA_FIN-SLNO = SY-TABIX.
    MODIFY IT_FIN FROM WA_FIN TRANSPORTING SLNO.
  ENDLOOP.


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
  REFRESH:IT_FCAT.

  WA_FCAT-FIELDNAME            = 'SLNO'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Sl.No'.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'FKDAT'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Posting Date'.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

*  WA_FCAT-COL_POS              = 02.
*  WA_FCAT-FIELDNAME            = 'STCD3'.
*  WA_FCAT-TABNAME              = 'it_fin'.
*  WA_FCAT-SELTEXT_M            = 'Supplier GSTIN/UIN'.
**  WA_FCAT-OUTPUTLEN            = 50.
*  WA_FCAT-JUST                 = 'L'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.

*  WA_FCAT-COL_POS              = 03.
*  WA_FCAT-FIELDNAME            = 'SKUNNR'.
*  WA_FCAT-TABNAME              = 'it_fin'.
*  WA_FCAT-SELTEXT_L            = 'Sup Name'.
**  WA_FCAT-OUTPUTLEN            = 50.
*  WA_FCAT-JUST                 = 'L'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.

*  WA_FCAT-FIELDNAME            = 'BKUNNR'.
  WA_FCAT-FIELDNAME            = 'SPNAME'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_L            = 'Sold To Party Name'.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

*  WA_FCAT-FIELDNAME            = 'SOPREGIO'.
  WA_FCAT-FIELDNAME            = 'SPREGION'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_L            = 'Sold To Party Region'.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

*  WA_FCAT-FIELDNAME            = 'SOPCNTRY'.
  WA_FCAT-FIELDNAME            = 'SPCOUNTRY'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_L            = 'Sold To Party Country'.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'SHNAME'.
  WA_FCAT-TABNAME              = 'IT_FIN'.
  WA_FCAT-SELTEXT_L            = 'Ship to Party Name'.
  WA_FCAT-OUTPUTLEN            =  15.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

*  WA_FCAT-FIELDNAME            = 'SHSTCD3'.
  WA_FCAT-FIELDNAME            = 'SHGST'.
  WA_FCAT-TABNAME              = 'IT_FIN'.
  WA_FCAT-SELTEXT_L            = 'Ship to Party GSTIN'.
  WA_FCAT-OUTPUTLEN            =  15.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'BPNAME'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_L            = 'Bill To Party Name'.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'FKART'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Billing Type'.
  WA_FCAT-OUTPUTLEN            = 10.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'VBELN'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Invoice No'.
  WA_FCAT-OUTPUTLEN            = 10.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'FKDAT'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Billing Date'.
  WA_FCAT-OUTPUTLEN            = 10.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'POSNR'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Invoice Item No'.
  WA_FCAT-OUTPUTLEN            = 10.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'MATNR'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Material'.
  WA_FCAT-OUTPUTLEN            = 40.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'ARKTX'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Material Description'.
  WA_FCAT-OUTPUTLEN            = 40.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-DO_SUM               = 'X'.
  WA_FCAT-FIELDNAME            = 'FKIMG'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Qty'.
  WA_FCAT-JUST                 = 'R'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'VRKME'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'UOM'.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'STEUC'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'HSN/SAC'.
  WA_FCAT-OUTPUTLEN            = 10.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

**  WA_FCAT-FIELDNAME            = 'WAERS'.
**  WA_FCAT-TABNAME              = 'IT_FIN'.
**  WA_FCAT-SELTEXT_L            = 'Currency Key'.
**  WA_FCAT-OUTPUTLEN            =  15.
**  APPEND WA_FCAT TO IT_FCAT.
**  CLEAR WA_FCAT.
**
**  WA_FCAT-FIELDNAME            = 'EXCH_RATE'.
**  WA_FCAT-TABNAME              = 'IT_FIN'.
**  WA_FCAT-SELTEXT_L            = 'Exchange Rate'.
**  WA_FCAT-OUTPUTLEN            =  15.
**  APPEND WA_FCAT TO IT_FCAT.
**  CLEAR WA_FCAT.

  WA_FCAT-DO_SUM               = 'X'.
*  WA_FCAT-FIELDNAME            = 'BASE_AMT1'.
  WA_FCAT-FIELDNAME            = 'TVALUE'.
  WA_FCAT-TABNAME              = 'IT_FIN'.
  WA_FCAT-SELTEXT_L            = 'Taxable Value'.
  WA_FCAT-OUTPUTLEN            =  20.
  WA_FCAT-JUST                 = 'R'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-DO_SUM               = 'X'.
*  WA_FCAT-FIELDNAME            = 'DISC'.
  WA_FCAT-FIELDNAME            = 'DVALUE'.
  WA_FCAT-TABNAME              = 'IT_FIN'.
  WA_FCAT-SELTEXT_L            = 'Discount'.
  WA_FCAT-OUTPUTLEN            =  15.
  WA_FCAT-JUST                 = 'R'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-DO_SUM               = 'X'.
*  WA_FCAT-FIELDNAME            = 'FREIGHT'.
  WA_FCAT-FIELDNAME            = 'FVALUE'.
  WA_FCAT-TABNAME              = 'IT_FIN'.
  WA_FCAT-SELTEXT_L            = 'Freight Cost'.
  WA_FCAT-OUTPUTLEN            =  15.
  WA_FCAT-JUST                 = 'R'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-DO_SUM               = 'X'.
*  WA_FCAT-FIELDNAME            = 'SGST'.
  WA_FCAT-FIELDNAME            = 'SGSTVAL'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'SGST Amount'.
  WA_FCAT-OUTPUTLEN            = 13.
  WA_FCAT-JUST                 = 'R'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-DO_SUM               = 'X'.
*  WA_FCAT-FIELDNAME            = 'CGST'.
  WA_FCAT-FIELDNAME            = 'CGSTVAL'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'CGST Amount'.
  WA_FCAT-OUTPUTLEN            = 13.
  WA_FCAT-JUST                 = 'R'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-DO_SUM               = 'X'.
*  WA_FCAT-FIELDNAME            = 'IGST'.
  WA_FCAT-FIELDNAME            = 'IGSTVAL'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'IGST Amount'.
  WA_FCAT-OUTPUTLEN            = 13.
  WA_FCAT-JUST                 = 'R'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

*  WA_FCAT-DO_SUM               = 'X'.
*  WA_FCAT-FIELDNAME            = 'TAX_SOURCE'.
*  WA_FCAT-TABNAME              = 'it_fin'.
*  WA_FCAT-SELTEXT_M            = 'TCS Value'.
*  WA_FCAT-OUTPUTLEN            = 13.
*  WA_FCAT-JUST                 = 'R'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.

  WA_FCAT-DO_SUM               = 'X'.
*  WA_FCAT-FIELDNAME            = 'TOTVAL'.
  WA_FCAT-FIELDNAME            = 'TOTALINVOICE'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Total Invoice Value'.
  WA_FCAT-OUTPUTLEN            = 13.
  WA_FCAT-JUST                 = 'R'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-DO_SUM               = 'X'.
*  WA_FCAT-FIELDNAME            = 'CMS_AMT'.
  WA_FCAT-FIELDNAME            = 'CVALUE'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Commision'.
  WA_FCAT-OUTPUTLEN            = 13.
  WA_FCAT-JUST                 = 'R'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-DO_SUM               = 'X'.
*  WA_FCAT-FIELDNAME            = 'INS_COST'.
  WA_FCAT-FIELDNAME            = 'IVALUE'.
  WA_FCAT-TABNAME              = 'IT_FIN'.
  WA_FCAT-SELTEXT_L            = 'Insurance Cost'.
  WA_FCAT-OUTPUTLEN            =  15.
  WA_FCAT-JUST                 = 'R'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'SPART'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Division'.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'WERKS'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Plant'.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'SHBILLNO'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Shipping Bill No'.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'SFBILLDAT'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Shipping Bill Date'.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'TNDR_TRKID'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Duty Drawback Amount'.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'AWBILLNO'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Airway Bill No'.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'AWBILLDAT'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Airway Bill Date'.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'LICNO'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'License Number'.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'LICDATE'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'License Date'.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'EWAYBILLNO'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Eway Bill No'.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'EWAYBILLDAT'.
  WA_FCAT-TABNAME              = 'it_fin'.
  WA_FCAT-SELTEXT_M            = 'Eway Bill Date'.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-REPID
      IS_LAYOUT          = WA_LAYOUT
      IT_FIELDCAT        = IT_FCAT[]
      IT_SORT            = IT_SORT
      I_DEFAULT          = 'X'
      I_SAVE             = 'A'
    TABLES
      T_OUTTAB           = IT_FIN
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
