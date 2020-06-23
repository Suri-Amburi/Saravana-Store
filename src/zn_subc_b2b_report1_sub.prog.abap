*&---------------------------------------------------------------------*
*& Include          ZN_SUBC_B2B_REPORT1_SUB
*&---------------------------------------------------------------------*

FORM SELECT_QUERRY .

  SELECT VBELN
         FKART
         FKTYP
         FKDAT
         KNUMV
         FKSTO
         KUNAG
         XBLNR
         BELNR
         BUKRS
         WAERK
         FROM VBRK INTO TABLE IT_VBRK
         WHERE FKDAT IN S_DATE
         AND  BUKRS IN S_BUKRS
         AND FKSTO NE 'X' AND
         FKART = 'FP'.               " ADDED ON (16-03-20)
*    FKART = 'ZSP'.          " COMMENTED ON (16-03-20)
*         AND FKART  NOT IN ('ZF2' ,'ZF8' , 'S1' , 'ZRET' , 'ZSN' , 'ZSN1' , 'ZSN2' , 'ZSN3' , 'ZSN4' , 'ZSN5', 'ZSP', 'ZSP1' , 'ZSP2' ,
*                           'ZSP3' , 'ZSP4' , 'ZSP5' , 'ZSBC' ).
*             AND FKART  IN ('ZSN' , 'ZSN1' , 'ZSN2' , 'ZSN3' , 'ZSN4' , 'ZSN5', 'ZSP', 'ZSP1' , 'ZSP2' ,
*                           'ZSP3' , 'ZSP4' , 'ZSP5' ).
DELETE IT_VBRK WHERE BELNR IS INITIAL.


  IF NOT IT_VBRK IS INITIAL.

    SELECT VBELN
           POSNR
           GSBER
           WERKS
           NETWR
           MWSBP
           AUBEL
           MATNR
           FROM VBRP INTO TABLE IT_VBRP
           FOR ALL ENTRIES IN IT_VBRK
           WHERE VBELN  = IT_VBRK-VBELN
           AND   WERKS  IN S_WERKS.

    SELECT SINGLE NAME1 FROM T001W INTO LV_NAME1
      WHERE WERKS = S_WERKS-LOW.

    SELECT KNUMV
           KPOSN
           KSCHL
           KAWRT
           MWSK1
           KWERT
           KBETR
           FROM PRCD_ELEMENTS INTO TABLE IT_PRCD
           FOR ALL ENTRIES IN IT_VBRK
           WHERE KNUMV = IT_VBRK-KNUMV.

    SELECT KUNNR
           NAME1
           NAME2
           STCD3
           ADRNR
           REGIO
           J_1IPANREF
           LAND1
           FROM KNA1 INTO TABLE IT_KNA1
           FOR ALL ENTRIES IN IT_VBRK
           WHERE KUNNR = IT_VBRK-KUNAG.

    DELETE IT_KNA1  WHERE STCD3 IS INITIAL.    "registered Vendor only
    SORT IT_KNA1 BY KUNNR.

    SELECT NEW_CODE
           EXISTING_CODE FROM ZREGION_CODES INTO TABLE IT_ZREGION
                         FOR ALL ENTRIES IN IT_KNA1
                         WHERE EXISTING_CODE = IT_KNA1-REGIO.
    IF IT_KNA1 IS NOT INITIAL.
      SELECT        SPRAS
                    LAND1
                    BLAND
                    BEZEI FROM T005U INTO TABLE IT_T005U FOR ALL ENTRIES IN IT_KNA1
                    WHERE SPRAS = SY-LANGU
                    AND LAND1 = IT_KNA1-LAND1
                    AND BLAND = IT_KNA1-REGIO.
    ENDIF.

    SELECT MATNR
           STEUC
           WERKS
            FROM MARC INTO TABLE IT_MARC
           FOR ALL ENTRIES IN IT_VBRP
           WHERE MATNR = IT_VBRP-MATNR AND WERKS = IT_VBRP-WERKS.

***
***      IF IT_MARC IS NOT INITIAL.
*********HSN DODE Description
***        SELECT STEUC
***               TEXT1 FROM T604N INTO TABLE IT_T604N
***               FOR ALL ENTRIES IN IT_MARC
***               WHERE STEUC = IT_MARC-STEUC AND SPRAS = 'EN'
***                                           AND LAND1 = 'IN'.
***
***      ENDIF.
  ENDIF.


ENDFORM.                    " SELECT_QUERRY
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .

  DATA : LV_SC TYPE REGIO,
         LV_SD TYPE BEZEI20.


  LOOP AT IT_VBRP INTO WA_VBRP.

    CLEAR WA_VBRK. READ TABLE IT_VBRK INTO WA_VBRK WITH KEY VBELN = WA_VBRP-VBELN.
    CLEAR WA_KNA1.READ TABLE IT_KNA1 INTO WA_KNA1 WITH KEY KUNNR = WA_VBRK-KUNAG.
    IF SY-SUBRC = 0.
**      LV_SLN = LV_SLN + 1.
***      WA_FIN-SLNO = LV_SLN.
      WA_FIN-VBELN = WA_VBRP-VBELN.
**      wa_fin-posnr = wa_vbrp-posnr.
      WA_FIN-FKDAT = WA_VBRK-FKDAT.
      WA_FIN-BELNR = WA_VBRK-BELNR.
**      if wa_vbrk-FKART = 'ZRET'.
**      wa_fin-NETWR = wa_vbrp-NETWR * ( -1 ).
**      else.
      WA_FIN-NETWR = WA_VBRP-NETWR .
      WA_FIN-XBLNR = WA_VBRK-XBLNR.
***        endif.


      READ TABLE IT_MARC INTO WA_MARC WITH KEY MATNR = WA_VBRP-MATNR WERKS = WA_VBRP-WERKS.
      IF SY-SUBRC = 0.
        WA_FIN-STEUC  = WA_MARC-STEUC.                                         ""HSN/SAC
      ENDIF.

***      WA_FIN-LTEXT    = 'Customer Advance'.   "
***      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
***        EXPORTING
***          INPUT  = WA_BSEG-BELNR
***        IMPORTING
***          OUTPUT = WA_FIN-VBELN. """"Document no
***
***      WA_FIN-ZOOR = 'Original'.
      READ TABLE IT_VBRK INTO WA_VBRK WITH KEY VBELN = WA_VBRP-VBELN.
      IF SY-SUBRC EQ 0 .
        WA_FIN-WAERK = WA_VBRK-WAERK .
        WA_FIN-FKART = WA_VBRK-FKART .
      ENDIF .

      DATA: V_KUNNR    TYPE VBPA-KUNNR, "KNVP-KUNN2,
            V_REGIO    TYPE KNA1-REGIO,
            V_NEW_CODE TYPE ZREGION_CODES-NEW_CODE.

      IF WA_VBRK-KUNAG IS NOT INITIAL.
        READ TABLE IT_KNA1 INTO WA_KNA1 WITH KEY KUNNR = WA_VBRK-KUNAG.
        IF SY-SUBRC = 0.
          WA_FIN-NAME1   = WA_KNA1-NAME1. "Name
          WA_FIN-STCD3   = WA_KNA1-STCD3. "GSTIN / UIN No
*        WA_FIN-REGIO   = WA_KNA1-REGIO.
          READ TABLE IT_T005U INTO WA_T005U WITH KEY LAND1 = WA_KNA1-LAND1 BLAND = WA_KNA1-REGIO .
          LV_SD = WA_T005U-BEZEI .
          LV_SC = WA_T005U-BLAND .

          CONCATENATE LV_SC LV_SD INTO WA_FIN-STT SEPARATED BY '-' .

          READ TABLE IT_ZREGION INTO WA_ZREGION WITH KEY EXISTING_CODE = WA_KNA1-REGIO.
          WA_FIN-REGIO   = WA_ZREGION-NEW_CODE.
*        WA_FIN-ZPOFS = WA_ZREGION-NEW_CODE.    "Place of Supply

          CLEAR V_KUNNR. SELECT SINGLE KUNNR FROM VBPA INTO V_KUNNR WHERE VBELN = WA_VBRP-AUBEL AND PARVW = 'WE'.
          CLEAR V_REGIO.  SELECT SINGLE REGIO FROM KNA1 INTO V_REGIO WHERE KUNNR = V_KUNNR.
          CLEAR V_NEW_CODE.  SELECT SINGLE NEW_CODE FROM ZREGION_CODES INTO V_NEW_CODE WHERE EXISTING_CODE = V_REGIO.
          WA_FIN-ZPOFS  = V_NEW_CODE.

          IF WA_FIN-REGIO = '29'.          "changes by naveen 22.12.2017
            WA_FIN-ZSUTY = 'Intra'.
          ELSE.
            WA_FIN-ZSUTY = 'Inter'.
          ENDIF.
*        CONCATENATE WA_KNA1-NAME1 WA_KNA1-NAME2 INTO  WA_FIN-BKUNNR SEPARATED BY ' '.""name
        ENDIF.
      ENDIF.
*      IF WA_BSEG-VBEL2 IS NOT INITIAL.
*        READ TABLE IT_VBAP INTO WA_VBAP WITH KEY VBELN = WA_BSEG-VBEL2 POSNR = WA_BSEG-POSN2 .
*        IF SY-SUBRC = 0.
*          READ TABLE IT_MARC INTO WA_MARC WITH KEY MATNR = WA_VBAP-MATNR WERKS = WA_VBAP-WERKS.
*          IF SY-SUBRC = 0.
*            WA_FIN-STEUC  = WA_MARC-STEUC."""HSN / SAC
*            CONDENSE WA_FIN-STEUC.
*          ENDIF.
*          READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_VBAP-MATNR.
*          IF SY-SUBRC = 0.
*            IF WA_MARA-MTART = 'DIEN'.
*              WA_FIN-ZGSER = 'S'.
**            WA_FIN-ZSUTY = 'Service'.       "changes by naveen 22.12.2017
*
*            ELSE.
*              WA_FIN-ZGSER = 'G'.
**            WA_FIN-ZSUTY = 'Goods'.
*            ENDIF.
*          ENDIF.
*
*
**        READ TABLE IT_T604N INTO WA_T604N WITH KEY STEUC = WA_MARC-STEUC."""description
**        IF SY-SUBRC = 0.
**          WA_FIN-TEXT1 = WA_T604N-TEXT1.
**        ENDIF.
*        ENDIF.
*      ENDIF.

**      READ TABLE IT_BKPF INTO WA_BKPF WITH KEY BELNR = WA_BSEG-BELNR.
**      IF SY-SUBRC = 0.
***      WA_FIN-LTEXT    =   WA_BKPF-BLART."Type   "
**        WA_FIN-BUDAT    =   WA_BKPF-BUDAT."DOcument date
**      ENDIF.
** break nkumar.
      CLEAR WA_PRCD. READ TABLE IT_PRCD INTO WA_PRCD WITH KEY KNUMV = WA_VBRK-KNUMV
                                                              KPOSN = WA_VBRP-POSNR.
      IF SY-SUBRC = 0.

        LOOP AT IT_PRCD INTO WA_PRCD  WHERE KNUMV = WA_VBRK-KNUMV
                                      AND   KPOSN = WA_VBRP-POSNR.
*                                      AND  HWBAS = WA_BSEG-DMBTR.
          IF  WA_PRCD-KSCHL    = 'JOSG'.
            WA_FIN-SGST  = WA_PRCD-KWERT + WA_FIN-SGST.
            WA_FIN-SGSTP = WA_PRCD-KBETR .""/ 10.
**            TAXBL2       = WA_BSET-HWBAS.
            WA_FIN-MWSK1 = WA_PRCD-MWSK1.
          ELSEIF WA_PRCD-KSCHL = 'JOCG'.
            WA_FIN-CGST   = WA_PRCD-KWERT + WA_FIN-CGST.
            WA_FIN-CGSTP  = WA_PRCD-KBETR .""/ 10.
*              TAXBL3 =  WA_BSET-HWBAS.
            WA_FIN-MWSK1 = WA_PRCD-MWSK1.
          ELSEIF WA_PRCD-KSCHL = 'JOIG'.
            WA_FIN-IGST  =  WA_PRCD-KWERT + WA_FIN-IGST.
            WA_FIN-IGSTP =  WA_PRCD-KBETR .""/ 10.
**            TAXBL4       =  WA_BSET-HWBAS.
            WA_FIN-MWSK1 = WA_PRCD-MWSK1.
          ELSEIF WA_PRCD-KSCHL = 'JOUG'.
            WA_FIN-UGST  =  WA_PRCD-KWERT + WA_FIN-UGST.
            WA_FIN-UGSTP =  WA_PRCD-KBETR .""/ 10.
**            TAXBL4       =  WA_BSET-HWBAS.
            WA_FIN-MWSK1 = WA_PRCD-MWSK1.
          ELSEIF WA_PRCD-KSCHL = 'JICS'.
            WA_FIN-CESS  =  WA_PRCD-KWERT + WA_FIN-CESS.
            WA_FIN-CESSP =  WA_PRCD-KBETR .""/ 10.
**            TAXBL5       =  WA_BSET-HWBAS.
            WA_FIN-MWSK1 = WA_PRCD-MWSK1.
*---->>> ( start of added ) mumair <<< 18.11.2019 16:09:50
             ELSEIF WA_PRCD-KSCHL = 'ZCES'.
               WA_FIN-CESS  =  WA_PRCD-KWERT + WA_FIN-CESS.
               WA_FIN-CESSP =  WA_PRCD-KBETR .""/ 10.
               WA_FIN-MWSK1 = WA_PRCD-MWSK1.

              ELSEIF WA_PRCD-KSCHL = 'ZTCS'.
                WA_FIN-TCS  =  WA_PRCD-KWERT + WA_FIN-TCS.
                WA_FIN-TCSP  =  WA_PRCD-KBETR .""/ 10.
                WA_FIN-MWSK1 = WA_PRCD-MWSK1.
              ELSEIF WA_PRCD-KSCHL = 'ZINO' OR WA_PRCD-KSCHL = 'ZINS'.
                WA_FIN-INO  =  WA_PRCD-KWERT + WA_FIN-INO.
                WA_FIN-INOP  =  WA_PRCD-KBETR .""/ 10.
                WA_FIN-MWSK1 = WA_PRCD-MWSK1.
              ELSEIF WA_PRCD-KSCHL = 'ZFRT' OR WA_PRCD-KSCHL = 'ZFRM'.
                WA_FIN-FRT  =  WA_PRCD-KWERT + WA_FIN-FRT.
                WA_FIN-FRTP  =  WA_PRCD-KBETR .""/ 10.
                WA_FIN-MWSK1 = WA_PRCD-MWSK1.

              ELSEIF WA_PRCD-KSCHL = 'ZOPS' OR WA_PRCD-KSCHL = 'ZOPM'.
                WA_FIN-OPS  =  WA_PRCD-KWERT + WA_FIN-OPS.
                WA_FIN-OPSP  =  WA_PRCD-KBETR .""/ 10.
                WA_FIN-MWSK1 = WA_PRCD-MWSK1.

              ELSEIF WA_PRCD-KSCHL = 'DIFF' .
                WA_FIN-DIFF  =  WA_PRCD-KWERT + WA_FIN-DIFF.
                WA_FIN-MWSK1 = WA_PRCD-MWSK1.
              ELSEIF WA_PRCD-KSCHL = 'ZDIS' .
                WA_FIN-DIS  =  WA_PRCD-KWERT + WA_FIN-DIS.
                WA_FIN-MWSK1 = WA_PRCD-MWSK1.
          ENDIF.
        ENDLOOP.
      ENDIF.

  wa_fin-netwr  =   wa_fin-netwr - ( wa_fin-tcs + wa_fin-ino + wa_fin-frt + wa_fin-ops + wa_fin-cess + wa_fin-diff ).
  WA_FIN-OTHERS =   WA_FIN-TCS + WA_FIN-INO + WA_FIN-FRT + WA_FIN-OPS +  WA_FIN-DIFF .

  WA_FIN-TOTVAL =   WA_FIN-NETWR  + WA_FIN-SGST + WA_FIN-CGST + WA_FIN-IGST  + WA_FIN-UGST + WA_FIN-CESS +   WA_FIN-TCS + WA_FIN-INO + WA_FIN-FRT + WA_FIN-OPS + WA_FIN-DIFF .

*---->>> ( end of added ) mumair <<< 18.11.2019 16:09:50
      " changed by naveen 26-12-17


*    WA_FIN-TAXBL  =  TAXBL2 + TAXBL3 + TAXBL4 + TAXBL5.
***       if wa_vbrk-FKART = 'ZRET'.
***         WA_FIN-SGST =  WA_FIN-SGST * ( -1 ).
***        WA_FIN-CGST =  WA_FIN-CGST * ( -1 ).
***        WA_FIN-IGST =  WA_FIN-IGST * ( -1 ).
***        WA_FIN-CESS =  WA_FIN-CESS * ( -1 ).
***
***    WA_FIN-TOTVAL =   wa_fin-netwr  + WA_FIN-SGST + WA_FIN-CGST + WA_FIN-IGST + WA_FIN-CESS  . " + WA_FIN-TAXBL.+ WA_FIN-UGST
***
***    else.
*      WA_FIN-TOTVAL =   WA_FIN-NETWR  + WA_FIN-SGST + WA_FIN-CGST + WA_FIN-IGST  + WA_FIN-UGST + WA_FIN-CESS . " + WA_FIN-TAXBL.+ WA_FIN-UGST
*    WA_FIN-TOTGST =  WA_FIN-SGST + WA_FIN-CGST + WA_FIN-IGST.
***    endif.

      APPEND WA_FIN TO IT_FIN.
      CLEAR:WA_PRCD,WA_VBRP,WA_KNA1,WA_VBRK,WA_FIN.
    ENDIF.
  ENDLOOP.


  IT_FIN1[] = IT_FIN[].

  SORT IT_FIN1 BY  VBELN MWSK1.
  DELETE ADJACENT DUPLICATES FROM IT_FIN1 COMPARING VBELN MWSK1.

  LOOP AT IT_FIN1 INTO WA_FIN1.
    LV_SLN = LV_SLN + 1.
    WA_FIN2-SLNO = LV_SLN.
    WA_FIN2-VBELN = WA_FIN1-VBELN.
    WA_FIN2-FKDAT = WA_FIN1-FKDAT.
    WA_FIN2-XBLNR = WA_FIN1-XBLNR.
    WA_FIN2-BELNR = WA_FIN1-BELNR.
    WA_FIN2-NAME1   = WA_FIN1-NAME1. "Name
    WA_FIN2-STCD3   = WA_FIN1-STCD3. "GSTIN / UIN No
    WA_FIN2-REGIO   = WA_FIN1-REGIO.
    WA_FIN2-CGSTP   = WA_FIN1-CGSTP.
    WA_FIN2-SGSTP   = WA_FIN1-SGSTP.
    WA_FIN2-IGSTP   = WA_FIN1-IGSTP.
    WA_FIN2-UGSTP   = WA_FIN1-UGSTP.
    WA_FIN2-STT = WA_FIN1-STT .
    WA_FIN2-WAERK = WA_FIN1-WAERK .
    WA_FIN2-FKART = WA_FIN1-FKART .
     WA_FIN2-STEUC = WA_FIN1-STEUC .
    LOOP AT IT_FIN INTO WA_FIN WHERE VBELN = WA_FIN1-VBELN AND MWSK1 = WA_FIN1-MWSK1.
      WA_FIN2-NETWR  = WA_FIN2-NETWR + WA_FIN-NETWR.
      WA_FIN2-SGST   = WA_FIN2-SGST + WA_FIN-SGST.
      WA_FIN2-CGST   = WA_FIN2-CGST + WA_FIN-CGST.
      WA_FIN2-IGST   = WA_FIN2-IGST + WA_FIN-IGST.
      WA_FIN2-UGST   = WA_FIN2-UGST + WA_FIN-UGST.
      WA_FIN2-CESS   = WA_FIN2-CESS + WA_FIN-CESS.
      WA_FIN2-TOTVAL   = WA_FIN2-TOTVAL + WA_FIN-TOTVAL.
      WA_FIN2-OTHERS   = WA_FIN2-OTHERS + WA_FIN-OTHERS.
    ENDLOOP.

    APPEND WA_FIN2 TO IT_FIN2.
    CLEAR WA_FIN2.
  ENDLOOP.
ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELD_CATALOG .

  WA_FCAT-FIELDNAME            = 'SLNO'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_L            = 'Sl No'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'NAME1'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_L            = 'Name'.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'STT'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = 'State with Code'.
  WA_FCAT-OUTPUTLEN            = 15.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.


  WA_FCAT-FIELDNAME            = 'STCD3'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = 'GSTIN / UIN No'.
  WA_FCAT-OUTPUTLEN            = 21.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.



  WA_FCAT-FIELDNAME            = 'XBLNR'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = 'Reference'.
  WA_FCAT-OUTPUTLEN            = 21.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'VBELN'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = 'Bill Doc No'.
  WA_FCAT-OUTPUTLEN            = 21.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'FKDAT'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = 'Bill Doc Date'.
  WA_FCAT-OUTPUTLEN            = 20.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'BELNR'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = 'Acc Doc No'.
  WA_FCAT-OUTPUTLEN            = 20.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.



  WA_FCAT-FIELDNAME            = 'STEUC'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = 'HSN Code'.
  WA_FCAT-OUTPUTLEN            = 16.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

*  WA_FCAT-FIELDNAME            = 'REGIO'.
*  WA_FCAT-TABNAME              = 'IT_FIN2'.
*  WA_FCAT-SELTEXT_M            = 'Place of Supply'.
*  WA_FCAT-OUTPUTLEN            = 13.
*  WA_FCAT-JUST                 = 'L'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'WAERK'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = 'Currency'.
  WA_FCAT-OUTPUTLEN            = 4.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.



  WA_FCAT-FIELDNAME            = 'NETWR'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = 'Taxable Value'.
  WA_FCAT-OUTPUTLEN            = 30.
  WA_FCAT-JUST                 = 'R'.
  WA_FCAT-DO_SUM               = 'X'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'IGSTP'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = '%'.
  WA_FCAT-OUTPUTLEN            = 13.
  WA_FCAT-JUST                 = 'R'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-DO_SUM               = 'X'.
  WA_FCAT-FIELDNAME            = 'IGST'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = 'IGST'.
  WA_FCAT-OUTPUTLEN            = 13.
  WA_FCAT-JUST                 = 'R'.
  WA_FCAT-DO_SUM               = 'X'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'CGSTP'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = '%'.
  WA_FCAT-OUTPUTLEN            = 13.
  WA_FCAT-JUST                 = 'R'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-DO_SUM               = 'X'.
  WA_FCAT-FIELDNAME            = 'CGST'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = 'CGST'.
  WA_FCAT-OUTPUTLEN            = 13.
  WA_FCAT-JUST                 = 'R'.
  WA_FCAT-DO_SUM               = 'X'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'SGSTP'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = '%'.
  WA_FCAT-OUTPUTLEN            = 13.
  WA_FCAT-JUST                 = 'R'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-DO_SUM               = 'X'.
  WA_FCAT-FIELDNAME            = 'SGST'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = 'SGST'.
  WA_FCAT-OUTPUTLEN            = 13.
  WA_FCAT-JUST                 = 'R'.
  WA_FCAT-DO_SUM               = 'X'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.
*
*  WA_FCAT-FIELDNAME            = 'UGSTP'.
*  WA_FCAT-TABNAME              = 'IT_FIN2'.
*  WA_FCAT-SELTEXT_M            = 'UGST Rate'.
*  WA_FCAT-OUTPUTLEN            = 13.
*  WA_FCAT-JUST                 = 'R'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.
*
*  WA_FCAT-DO_SUM               = 'X'.
*  WA_FCAT-FIELDNAME            = 'UGST'.
*  WA_FCAT-TABNAME              = 'IT_FIN2'.
*  WA_FCAT-SELTEXT_M            = 'UGST Amount'.
*  WA_FCAT-OUTPUTLEN            = 13.
*  WA_FCAT-JUST                 = 'R'.
*  WA_FCAT-DO_SUM               = 'X'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.
*
*  WA_FCAT-DO_SUM               = 'X'.
*  WA_FCAT-FIELDNAME            = 'CESSP'.
*  WA_FCAT-TABNAME              = 'IT_FIN2'.
*  WA_FCAT-SELTEXT_M            = 'Cess Rate'.
*  WA_FCAT-OUTPUTLEN            = 13.
*  WA_FCAT-JUST                 = 'R'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.

  WA_FCAT-DO_SUM               = 'X'.
  WA_FCAT-FIELDNAME            = 'CESS'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = 'Cess'.
  WA_FCAT-OUTPUTLEN            = 13.
  WA_FCAT-JUST                 = 'R'.
  WA_FCAT-DO_SUM               = 'X'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'OTHERS'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = 'Other'.
  WA_FCAT-OUTPUTLEN            = 30.
  WA_FCAT-JUST                 = 'R'.
  WA_FCAT-DO_SUM               = 'X'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.


  WA_FCAT-FIELDNAME            = 'TOTVAL'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = 'Total Value'.
  WA_FCAT-OUTPUTLEN            = 30.
  WA_FCAT-JUST                 = 'R'.
  WA_FCAT-DO_SUM               = 'X'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'FKART'.
  WA_FCAT-TABNAME              = 'IT_FIN2'.
  WA_FCAT-SELTEXT_M            = 'Billing Type'.
  WA_FCAT-OUTPUTLEN            = 6.
  WA_FCAT-JUST                 = 'L'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

ENDFORM.                    " FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM          = SY-REPID
      I_CALLBACK_HTML_TOP_OF_PAGE = 'TOP-OF-PAGE'
      IS_LAYOUT                   = WA_LAYOUT
      IT_FIELDCAT                 = IT_FCAT[]
      IT_SORT                     = IT_SORT
      I_DEFAULT                   = 'X'
      I_SAVE                      = 'A'
    TABLES
      T_OUTTAB                    = IT_FIN2
    EXCEPTIONS
      PROGRAM_ERROR               = 1
      OTHERS                      = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    " DISPLAY_DATA

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



  LV_TOP = 'SUBCONTRACTING'.

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

  CONCATENATE SY-DATUM+6(2) SY-DATUM+4(2) SY-DATUM+0(4) INTO LV_DATE SEPARATED BY '.'.
  LV_TOP = LV_DATE.

  CALL METHOD TOP->ADD_TEXT
    EXPORTING
      TEXT      = LV_TOP
      SAP_STYLE = 'SUBHEADING'.

  CALL METHOD TOP->NEW_LINE.
*
  LV_TOP = 'Plant-'.

  CALL METHOD TOP->ADD_TEXT
    EXPORTING
      TEXT      = LV_TOP
      SAP_STYLE = 'SUBHEADING'.

  LV_TOP = LV_NAME1.

  CALL METHOD TOP->ADD_TEXT
    EXPORTING
      TEXT      = LV_TOP
      SAP_STYLE = 'SUBHEADING'.
*


 IF LV_TOP IS NOT INITIAL.
   CALL FUNCTION 'FI_CONVERT_FIRSTCHARS_TOUPPER'
     EXPORTING
       INPUT_STRING        = LV_TOP
      SEPARATORS          = ' '
    IMPORTING
      OUTPUT_STRING       = LV_TOP
             .


*  CALL FUNCTION 'ISP_CONVERT_FIRSTCHARS_TOUPPER'
*    EXPORTING
*      INPUT_STRING  = LV_TOP
*      SEPARATORS    = ' '
*    IMPORTING
*      OUTPUT_STRING = LV_TOP.
ENDIF.
ENDFORM.
