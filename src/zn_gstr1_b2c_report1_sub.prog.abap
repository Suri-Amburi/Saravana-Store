*&---------------------------------------------------------------------*
*& Include          ZN_GSTR1_B2C_REPORT1_SUB
*&---------------------------------------------------------------------*


FORM select_querry .

  SELECT vbeln
         fkart
         fktyp
         fkdat
         knumv
         fksto
         kunag
         xblnr
         belnr
         bukrs
         stwae
         waerk
         FROM vbrk INTO TABLE it_vbrk
         WHERE fkdat IN s_date
         AND  bukrs IN s_bukrs
         AND FKART = 'FP'              " ADDED ON (16-03-2020)
*         AND fkart IN ('ZDOM', 'ZDMC', 'ZDCW', 'ZTRO', 'ZTRC', 'ZDEP', 'ZJWO', 'ZSAM', 'ZF8', 'ZL2', 'ZSRI') "*---->>>  ADDED BY  mumair <<< 07.11.2019 11:43:22
         AND fksto NE 'X'.
*         AND FKART NOT IN ('ZF2' ,'ZF8' , 'S1' , 'ZRET' , 'ZSN' , 'ZSN1' , 'ZSN2' , 'ZSN3' , 'ZSN4' , 'ZSN5', 'ZSP', 'ZSP1' , 'ZSP2' ,
*                           'ZSP3' , 'ZSP4' , 'ZSP5' , 'ZEXI' , 'ZEXP' ).
*         AND FKART NOT IN ('ZF2' , 'S1' , 'ZRET' , 'ZSN' , 'ZSN1' , 'ZSN2' , 'ZSN3' , 'ZSN4' , 'ZSN5', 'ZSP', 'ZSP1' , 'ZSP2' ,
*                           'ZSP3' , 'ZSP4' , 'ZSP5'  , 'S2' , 'ZEPF' , 'ZPFC' , 'ZPFI' , 'ZG2' , 'ZRE' , 'ZEXI' , 'ZEXP' , 'ZEPD' , 'ZFMS' ).

  DELETE it_vbrk WHERE belnr IS INITIAL.
  DELETE it_vbrk WHERE stwae <> 'INR'  .

  IF NOT it_vbrk IS INITIAL.

    SELECT vbeln
           posnr
           gsber
           werks
           netwr
           mwsbp
           aubel
           matnr
           FROM vbrp INTO TABLE it_vbrp
           FOR ALL ENTRIES IN it_vbrk
           WHERE vbeln  = it_vbrk-vbeln
           AND   werks  IN s_werks.

    SELECT SINGLE name1 FROM t001w INTO lv_name1
      WHERE werks = s_werks-low.

    SELECT knumv
           kposn
           kschl
           kawrt
           mwsk1
           kwert
           kbetr
           FROM prcd_elements INTO TABLE it_prcd
           FOR ALL ENTRIES IN it_vbrk
           WHERE knumv = it_vbrk-knumv.

    SELECT kunnr
           name1
           name2
           stcd3
           adrnr
           regio
           j_1ipanref
           land1
           FROM kna1 INTO TABLE it_kna1
           FOR ALL ENTRIES IN it_vbrk
           WHERE kunnr = it_vbrk-kunag.

    DELETE it_kna1  WHERE stcd3 IS NOT INITIAL.    "registered Vendor only
    SORT it_kna1 BY kunnr.

    SELECT new_code
           existing_code FROM zregion_codes INTO TABLE it_zregion
                         FOR ALL ENTRIES IN it_kna1
                         WHERE existing_code = it_kna1-regio.
    IF it_kna1 IS NOT INITIAL.
      SELECT        spras
                    land1
                    bland
                    bezei FROM t005u INTO TABLE it_t005u FOR ALL ENTRIES IN it_kna1
                    WHERE spras = sy-langu
                    AND land1 = it_kna1-land1
                    AND bland = it_kna1-regio.
    ENDIF.
    SELECT matnr
           steuc
           werks FROM marc INTO TABLE it_marc
           FOR ALL ENTRIES IN it_vbrp
           WHERE matnr = it_vbrp-matnr AND werks = it_vbrp-werks.


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
FORM get_data .

  DATA : lv_sc TYPE regio,
         lv_sd TYPE bezei20.


  LOOP AT it_vbrp INTO wa_vbrp.

    CLEAR wa_vbrk. READ TABLE it_vbrk INTO wa_vbrk WITH KEY vbeln = wa_vbrp-vbeln.
    CLEAR wa_kna1.READ TABLE it_kna1 INTO wa_kna1 WITH KEY kunnr = wa_vbrk-kunag.
    IF sy-subrc = 0.
**      LV_SLN = LV_SLN + 1.
***      WA_FIN-SLNO = LV_SLN.
      wa_fin-vbeln = wa_vbrp-vbeln.
**      wa_fin-posnr = wa_vbrp-posnr.
      wa_fin-fkdat = wa_vbrk-fkdat.
      wa_fin-belnr = wa_vbrk-belnr.
**      if wa_vbrk-FKART = 'ZRET'.
**      wa_fin-NETWR = wa_vbrp-NETWR * ( -1 ).
**      else.
      wa_fin-netwr = wa_vbrp-netwr .
      wa_fin-xblnr = wa_vbrk-xblnr.

      READ TABLE it_marc INTO wa_marc WITH KEY matnr = wa_vbrp-matnr werks = wa_vbrp-werks.
      IF sy-subrc = 0.
        wa_fin-steuc  = wa_marc-steuc.                                         ""HSN/SAC
      ENDIF.


      READ TABLE it_vbrk INTO wa_vbrk WITH KEY vbeln = wa_vbrp-vbeln.
      IF sy-subrc EQ 0 .
        wa_fin-fkart =  wa_vbrk-fkart.
        wa_fin-stwae =  wa_vbrk-waerk.
      ENDIF .
***        endif.

***      WA_FIN-LTEXT    = 'Customer Advance'.   "
***      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
***        EXPORTING
***          INPUT  = WA_BSEG-BELNR
***        IMPORTING
***          OUTPUT = WA_FIN-VBELN. """"Document no
***
***      WA_FIN-ZOOR = 'Original'.

      DATA: v_kunnr    TYPE vbpa-kunnr, "KNVP-KUNN2,
            v_regio    TYPE kna1-regio,
            v_new_code TYPE zregion_codes-new_code.

      IF wa_vbrk-kunag IS NOT INITIAL.
        READ TABLE it_kna1 INTO wa_kna1 WITH KEY kunnr = wa_vbrk-kunag.
        IF sy-subrc = 0.
          wa_fin-name1   = wa_kna1-name1. "Name
          wa_fin-stcd3   = wa_kna1-stcd3. "GSTIN / UIN No
*        WA_FIN-REGIO   = WA_KNA1-REGIO.
          READ TABLE it_t005u INTO wa_t005u WITH KEY land1 = wa_kna1-land1 bland = wa_kna1-regio .
          lv_sd = wa_t005u-bezei .
          lv_sc = wa_t005u-bland .

          CONCATENATE lv_sc lv_sd INTO wa_fin-stt SEPARATED BY '-' .

          READ TABLE it_zregion INTO wa_zregion WITH KEY existing_code = wa_kna1-regio.
          wa_fin-regio   = wa_zregion-new_code.
*        WA_FIN-ZPOFS = WA_ZREGION-NEW_CODE.    "Place of Supply

          CLEAR v_kunnr. SELECT SINGLE kunnr FROM vbpa INTO v_kunnr WHERE vbeln = wa_vbrp-aubel AND parvw = 'WE'.
          CLEAR v_regio.  SELECT SINGLE regio FROM kna1 INTO v_regio WHERE kunnr = v_kunnr.
          CLEAR v_new_code.  SELECT SINGLE new_code FROM zregion_codes INTO v_new_code WHERE existing_code = v_regio.
          wa_fin-zpofs  = v_new_code.

          IF wa_fin-regio = '29'.          "changes by naveen 22.12.2017
            wa_fin-zsuty = 'Intra'.
          ELSE.
            wa_fin-zsuty = 'Inter'.
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
      CLEAR wa_prcd. READ TABLE it_prcd INTO wa_prcd WITH KEY knumv = wa_vbrk-knumv
                                                              kposn = wa_vbrp-posnr.
      IF sy-subrc = 0.

        LOOP AT it_prcd INTO wa_prcd  WHERE knumv = wa_vbrk-knumv
                                      AND   kposn = wa_vbrp-posnr.
*                                      AND  HWBAS = WA_BSEG-DMBTR.
          IF  wa_prcd-kschl    = 'JOSG'.
            wa_fin-sgst  = wa_prcd-kwert + wa_fin-sgst.
            wa_fin-sgstp = wa_prcd-kbetr .""/ 10.
**            TAXBL2       = WA_BSET-HWBAS.
            wa_fin-mwsk1 = wa_prcd-mwsk1.
          ELSEIF wa_prcd-kschl = 'JOCG'.
            wa_fin-cgst   = wa_prcd-kwert + wa_fin-cgst.
            wa_fin-cgstp  = wa_prcd-kbetr .""/ 10.
*              TAXBL3 =  WA_BSET-HWBAS.
            wa_fin-mwsk1 = wa_prcd-mwsk1.
          ELSEIF wa_prcd-kschl = 'JOIG'.
            wa_fin-igst  =  wa_prcd-kwert + wa_fin-igst.
            wa_fin-igstp =  wa_prcd-kbetr .""/ 10.
**            TAXBL4       =  WA_BSET-HWBAS.
            wa_fin-mwsk1 = wa_prcd-mwsk1.
          ELSEIF wa_prcd-kschl = 'JOUG'.
            wa_fin-ugst  =  wa_prcd-kwert + wa_fin-ugst.
            wa_fin-ugstp =  wa_prcd-kbetr .""/ 10.
**            TAXBL4       =  WA_BSET-HWBAS.
            wa_fin-mwsk1 = wa_prcd-mwsk1.
*          ELSEIF WA_PRCD-KSCHL = 'JICS'.
*            WA_FIN-CESS  =  WA_PRCD-KWERT + WA_FIN-CESS.
*            WA_FIN-CESSP =  WA_PRCD-KBETR .""/ 10.
***            TAXBL5       =  WA_BSET-HWBAS.
*            WA_FIN-MWSK1 = WA_PRCD-MWSK1.


          ELSEIF wa_prcd-kschl = 'ZCES'.
            wa_fin-cess  =  wa_prcd-kwert + wa_fin-cess.
            wa_fin-cessp =  wa_prcd-kbetr .""/ 10.
            wa_fin-mwsk1 = wa_prcd-mwsk1.


            "*---->>> ( start of added ) mumair <<< 18.11.2019 14:32:20
          ELSEIF wa_prcd-kschl = 'ZTCS'.
            wa_fin-tcs  =  wa_prcd-kwert + wa_fin-tcs.
            wa_fin-tcsp  =  wa_prcd-kbetr .""/ 10.
            wa_fin-mwsk1 = wa_prcd-mwsk1.
          ELSEIF wa_prcd-kschl = 'ZINO' OR wa_prcd-kschl = 'ZINS'.
            wa_fin-ino  =  wa_prcd-kwert + wa_fin-ino.
            wa_fin-inop  =  wa_prcd-kbetr .""/ 10.
            wa_fin-mwsk1 = wa_prcd-mwsk1.
          ELSEIF wa_prcd-kschl = 'ZFRT' OR wa_prcd-kschl = 'ZFRM'.
            wa_fin-frt  =  wa_prcd-kwert + wa_fin-frt.
            wa_fin-frtp  =  wa_prcd-kbetr .""/ 10.
            wa_fin-mwsk1 = wa_prcd-mwsk1.

          ELSEIF wa_prcd-kschl = 'ZOPS' OR wa_prcd-kschl = 'ZOPM'.
            wa_fin-ops  =  wa_prcd-kwert + wa_fin-ops.
            wa_fin-opsp  =  wa_prcd-kbetr .""/ 10.
            wa_fin-mwsk1 = wa_prcd-mwsk1.

          ELSEIF wa_prcd-kschl = 'DIFF' .
            wa_fin-diff  =  wa_prcd-kwert + wa_fin-diff.
            wa_fin-mwsk1 = wa_prcd-mwsk1.
          ELSEIF wa_prcd-kschl = 'ZDIS' .
            wa_fin-dis  =  wa_prcd-kwert + wa_fin-dis.
            wa_fin-mwsk1 = wa_prcd-mwsk1.
          ENDIF.
*          ENDIF.
*          ENDIF.
*          ENDIF.
        ENDLOOP.
      ENDIF.

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

      wa_fin-netwr  =   wa_fin-netwr - ( wa_fin-tcs + wa_fin-ino + wa_fin-frt + wa_fin-ops + wa_fin-cess + wa_fin-diff ).

      wa_fin-others =   wa_fin-tcs + wa_fin-ino + wa_fin-frt + wa_fin-ops +  wa_fin-diff .

      wa_fin-totval =   wa_fin-netwr  + wa_fin-sgst + wa_fin-cgst + wa_fin-igst  + wa_fin-ugst + wa_fin-cess +  wa_fin-tcs + wa_fin-ino + wa_fin-frt + wa_fin-ops + wa_fin-diff  . " + WA_FIN-TAXBL.+ WA_FIN-UGST

*    WA_FIN-TOTGST =  WA_FIN-SGST + WA_FIN-CGST + WA_FIN-IGST.
***    endif.

      APPEND wa_fin TO it_fin.
      CLEAR:wa_prcd,wa_vbrp,wa_kna1,wa_vbrk,wa_fin.
    ENDIF.
  ENDLOOP.


  it_fin1[] = it_fin[].

  SORT it_fin1 BY  vbeln mwsk1.
  DELETE ADJACENT DUPLICATES FROM it_fin1 COMPARING vbeln mwsk1.

  LOOP AT it_fin1 INTO wa_fin1.
    lv_sln = lv_sln + 1.
    wa_fin2-slno = lv_sln.
    wa_fin2-vbeln = wa_fin1-vbeln.
    wa_fin2-fkdat = wa_fin1-fkdat.
    wa_fin2-xblnr = wa_fin1-xblnr.
    wa_fin2-belnr = wa_fin1-belnr.
    wa_fin2-name1   = wa_fin1-name1. "Name
    wa_fin2-stcd3   = wa_fin1-stcd3. "GSTIN / UIN No
    wa_fin2-regio   = wa_fin1-regio.
    wa_fin2-cgstp   = wa_fin1-cgstp.
    wa_fin2-sgstp   = wa_fin1-sgstp.
    wa_fin2-igstp   = wa_fin1-igstp.
    wa_fin2-ugstp   = wa_fin1-ugstp.
    wa_fin2-stt = wa_fin1-stt .
    wa_fin2-stwae = wa_fin1-stwae .
    wa_fin2-fkart = wa_fin1-fkart .
    wa_fin2-steuc = wa_fin1-steuc .

    LOOP AT it_fin INTO wa_fin WHERE vbeln = wa_fin1-vbeln AND mwsk1 = wa_fin1-mwsk1.
      wa_fin2-netwr  = wa_fin2-netwr + wa_fin-netwr.
      wa_fin2-sgst   = wa_fin2-sgst + wa_fin-sgst.
      wa_fin2-cgst   = wa_fin2-cgst + wa_fin-cgst.
      wa_fin2-igst   = wa_fin2-igst + wa_fin-igst.
      wa_fin2-ugst   = wa_fin2-ugst + wa_fin-ugst.
      wa_fin2-cess   = wa_fin2-cess + wa_fin-cess.
      wa_fin2-totval   = wa_fin2-totval + wa_fin-totval.
      wa_fin2-others   = wa_fin2-others + wa_fin-others.
    ENDLOOP.

    APPEND wa_fin2 TO it_fin2.
    CLEAR wa_fin2.
  ENDLOOP.

  DELETE it_fin2 WHERE STWAE <> 'INR'.
*   DELETE it_fin2 WHERE waerk <> 'INR'.

  endform.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM field_catalog .

  wa_fcat-fieldname            = 'SLNO'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_l            = 'Sl No'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'NAME1'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_l            = 'Name'.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'STT'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = 'State with Code'.
  wa_fcat-outputlen            = 15.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'STCD3'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = 'GSTIN / UIN No'.
  wa_fcat-outputlen            = 21.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.



  wa_fcat-fieldname            = 'XBLNR'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = 'Reference'.
  wa_fcat-outputlen            = 21.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'VBELN'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = 'Bill Doc No'.
  wa_fcat-outputlen            = 21.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'FKDAT'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = 'Bill Doc Date'.
  wa_fcat-outputlen            = 20.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'BELNR'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = 'Acc Doc No'.
  wa_fcat-outputlen            = 20.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.



  wa_fcat-fieldname            = 'STEUC'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = 'HSN Code'.
  wa_fcat-outputlen            = 16.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.



*  WA_FCAT-FIELDNAME            = 'REGIO'.
*  WA_FCAT-TABNAME              = 'IT_FIN2'.
*  WA_FCAT-SELTEXT_M            = 'Place of Supply'.
*  WA_FCAT-OUTPUTLEN            = 13.
*  WA_FCAT-JUST                 = 'L'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.
  wa_fcat-fieldname            = 'STWAE'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = 'Currency'.
  wa_fcat-outputlen            = 4 .
  wa_fcat-just                 = 'R'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'NETWR'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = 'Taxable Value'.
  wa_fcat-outputlen            = 30.
  wa_fcat-just                 = 'R'.
  wa_fcat-do_sum               = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'IGSTP'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = '%'.
  wa_fcat-outputlen            = 13.
  wa_fcat-just                 = 'R'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-do_sum               = 'X'.
  wa_fcat-fieldname            = 'IGST'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = 'IGST'.
  wa_fcat-outputlen            = 13.
  wa_fcat-just                 = 'R'.
  wa_fcat-do_sum               = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'CGSTP'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = '%'.
  wa_fcat-outputlen            = 13.
  wa_fcat-just                 = 'R'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-do_sum               = 'X'.
  wa_fcat-fieldname            = 'CGST'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = 'CGST'.
  wa_fcat-outputlen            = 13.
  wa_fcat-just                 = 'R'.
  wa_fcat-do_sum               = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'SGSTP'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = '%'.
  wa_fcat-outputlen            = 13.
  wa_fcat-just                 = 'R'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-do_sum               = 'X'.
  wa_fcat-fieldname            = 'SGST'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = 'SGST'.
  wa_fcat-outputlen            = 13.
  wa_fcat-just                 = 'R'.
  wa_fcat-do_sum               = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

*  wa_fcat-fieldname            = 'UGSTP'.
*  wa_fcat-tabname              = 'IT_FIN2'.
*  wa_fcat-seltext_m            = 'UGST Rate'.
*  wa_fcat-outputlen            = 13.
*  wa_fcat-just                 = 'R'.
*  APPEND wa_fcat TO it_fcat.
*  CLEAR wa_fcat.
*
*  wa_fcat-do_sum               = 'X'.
*  wa_fcat-fieldname            = 'UGST'.
*  wa_fcat-tabname              = 'IT_FIN2'.
*  wa_fcat-seltext_m            = 'UGST Amount'.
*  wa_fcat-outputlen            = 13.
*  wa_fcat-just                 = 'R'.
*  wa_fcat-do_sum               = 'X'.
*  APPEND wa_fcat TO it_fcat.
*  CLEAR wa_fcat.

*  wa_fcat-do_sum               = 'X'.
*  wa_fcat-fieldname            = 'CESSP'.
*  wa_fcat-tabname              = 'IT_FIN2'.
*  wa_fcat-seltext_m            = '%'.
*  wa_fcat-outputlen            = 13.
*  wa_fcat-just                 = 'R'.
*  APPEND wa_fcat TO it_fcat.
*  CLEAR wa_fcat.

  wa_fcat-do_sum               = 'X'.
  wa_fcat-fieldname            = 'CESS'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = 'Cess'.
  wa_fcat-outputlen            = 13.
  wa_fcat-just                 = 'R'.
  wa_fcat-do_sum               = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.


  wa_fcat-fieldname            = 'OTHERS'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = 'Other'.
  wa_fcat-outputlen            = 30.
  wa_fcat-just                 = 'R'.
  wa_fcat-do_sum               = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.



  wa_fcat-fieldname            = 'TOTVAL'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = 'Total Value'.
  wa_fcat-outputlen            = 30.
  wa_fcat-just                 = 'R'.
  wa_fcat-do_sum               = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

*  WA_FCAT-DO_SUM               = 'X'.
  wa_fcat-fieldname            = 'FKART'.
  wa_fcat-tabname              = 'IT_FIN2'.
  wa_fcat-seltext_m            = 'Billing Type'.
  wa_fcat-outputlen            = 6.
  wa_fcat-just                 = 'R'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_layout-colwidth_optimize = 'X'.

ENDFORM.                    " FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_data .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program          = sy-repid
      i_callback_html_top_of_page = 'TOP-OF-PAGE'
      is_layout                   = wa_layout
      it_fieldcat                 = it_fcat[]
      it_sort                     = it_sort
      i_default                   = 'X'
      i_save                      = 'A'
    TABLES
      t_outtab                    = it_fin2
    EXCEPTIONS
      program_error               = 1
      OTHERS                      = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    " DISPLAY_DATA

FORM top-of-page USING top TYPE REF TO cl_dd_document.

*ALV Header declarations
  DATA: t_header      TYPE slis_t_listheader,
        wa_header     TYPE slis_listheader,
        t_line        LIKE wa_header-info,
        ld_lines      TYPE i,
        ld_linesc(10) TYPE c.

  DATA: lv_top   TYPE sdydo_text_element,
        lv_date  TYPE sdydo_text_element,
        sep      TYPE c VALUE ' ',
        dot      TYPE c VALUE '.',
        yyyy1    TYPE char4,
        mm1      TYPE char2,
        dd1      TYPE char2,
        date1    TYPE char10,
        yyyy2    TYPE char4,
        mm2      TYPE char2,
        dd2      TYPE char2,
        date2    TYPE char10,
*        lv_name1 TYPE ad_name1,
        lv_name2 TYPE ad_name2,
        lv_adrnr TYPE adrnr.



  lv_top = 'GSTR1-B2C'.

  CALL METHOD top->add_text
    EXPORTING
      text      = lv_top
      sap_style = 'HEADING'.

  CALL METHOD top->new_line.
*
  lv_top = 'Date-'.

  CALL METHOD top->add_text
    EXPORTING
      text      = lv_top
      sap_style = 'SUBHEADING'.

  CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum+0(4) INTO lv_date SEPARATED BY '.'.
  lv_top = lv_date.

  CALL METHOD top->add_text
    EXPORTING
      text      = lv_top
      sap_style = 'SUBHEADING'.

  CALL METHOD top->new_line.
*
  lv_top = 'Plant-'.

  CALL METHOD top->add_text
    EXPORTING
      text      = lv_top
      sap_style = 'SUBHEADING'.

  lv_top = lv_name1.

  CALL METHOD top->add_text
    EXPORTING
      text      = lv_top
      sap_style = 'SUBHEADING'.
*


  IF LV_TOP IS NOT INITIAL .
    CALL FUNCTION 'FI_CONVERT_FIRSTCHARS_TOUPPER'
      EXPORTING
        INPUT_STRING        = LV_TOP
       SEPARATORS          = ' '
     IMPORTING
       OUTPUT_STRING       = LV_TOP
              .


*  CALL FUNCTION 'ISP_CONVERT_FIRSTCHARS_TOUPPER'
*    EXPORTING
*      input_string  = lv_top
*      separators    = ' '
*    IMPORTING
*      output_string = lv_top.
ENDIF.
ENDFORM.
