*&---------------------------------------------------------------------*
*& Include          ZN_GSTR1_CREDIT_NOTE_SUB
*&---------------------------------------------------------------------*


FORM select_querry .

  SELECT  bukrs
          belnr
          gjahr
          blart
          budat
          tcode
          awkey
          xreversed
          xreversing
          xblnr
            FROM bkpf INTO TABLE it_bkpf
          WHERE budat IN s_budat AND gjahr IN pyear AND bukrs IN s_bukrs AND blart IN ( 'RV' , 'DG'  )
          AND  xreversed NE 'X'
          AND  xreversing NE 'X' .

  SELECT SINGLE butxt FROM t001 INTO lv_name1
WHERE bukrs = s_bukrs-low.

  IF it_bkpf IS NOT INITIAL.
    SELECT     bukrs
               belnr
               gjahr
               bschl
               buzei
               kunnr
               vbeln
               vbel2
               posn2
               lifnr
               matnr
               hsn_sac
               ktosl
               txgrp
               koart
               umskz
               dmbtr
               gsber
               pswsl
               rebzg
            FROM bseg INTO TABLE it_bseg
            FOR ALL ENTRIES IN it_bkpf
            WHERE bukrs = it_bkpf-bukrs
            AND belnr = it_bkpf-belnr
            AND gjahr = it_bkpf-gjahr
            AND bschl = '11'
            AND koart = 'D'
            AND gsber IN s_gsber.

    IF it_bseg IS NOT INITIAL.
      SELECT bukrs
             belnr
             gjahr
             buzei
             txgrp
             shkzg
             hwbas
             hwste
             ktosl
             kschl
             kbetr
             FROM bset INTO TABLE it_bset
             FOR ALL ENTRIES IN it_bseg
             WHERE belnr = it_bseg-belnr AND bukrs  = it_bseg-bukrs
             AND gjahr = it_bseg-gjahr.

      SELECT vbeln
             posnr
             matnr
             werks
             FROM vbap INTO TABLE it_vbap
             FOR ALL ENTRIES IN it_bseg
             WHERE vbeln  = it_bseg-vbel2.

      SELECT vbeln
             fkart
             fktyp
             xblnr
             fkdat
             kunag
             waerk
             zuonr
                   FROM vbrk INTO TABLE it_vbrk
                   FOR ALL ENTRIES IN it_bseg
                   WHERE vbeln = it_bseg-vbeln.

      SELECT vbeln
             fkart
             fktyp
             xblnr
             fkdat
             kunag
             waerk
             zuonr
                   FROM vbrk INTO TABLE it_vbrk1
                   FOR ALL ENTRIES IN it_vbrk
                   WHERE vbeln = it_vbrk-zuonr.






      SELECT    vbeln
                posnr
                werks
                matnr FROM vbrp INTO TABLE it_vbrp
                      FOR ALL ENTRIES IN it_vbrk
                      WHERE vbeln = it_vbrk-vbeln .




      SELECT kunnr
             name1
             name2
             stcd3
             adrnr
             regio
             j_1ipanref
             land1
             FROM kna1 INTO TABLE it_kna1
             FOR ALL ENTRIES IN it_bseg
             WHERE kunnr = it_bseg-kunnr.

**      DELETE IT_KNA1  WHERE STCD3 IS INITIAL.    "registered Vendor only
**      SORT IT_KNA1 BY KUNNR.

      SELECT new_code
             existing_code FROM zregion_codes INTO TABLE it_zregion
                           FOR ALL ENTRIES IN it_kna1
                           WHERE existing_code = it_kna1-regio.

*      IF IT_VBAP IS NOT INITIAL.
*        SELECT MATNR
*               MTART FROM MARA INTO TABLE IT_MARA
*               FOR ALL ENTRIES IN IT_VBAP
*               WHERE MATNR = IT_VBAP-MATNR .
*        SORT IT_MARA BY MATNR.
*
      SELECT matnr
             steuc
             werks FROM marc INTO TABLE it_marc
             FOR ALL ENTRIES IN it_vbrp
             WHERE matnr = it_vbrp-matnr AND werks = it_vbrp-werks.

*    SELECT MATNR
*           MAKTX FROM MAKT INTO TABLE IT_MAKT
*           FOR ALL ENTRIES IN IT_VBAP
*           WHERE MATNR = IT_VBAP-MATNR.
*    ENDIF.
*      ENDIF.
      IF it_kna1 IS NOT INITIAL.
        SELECT        spras
                      land1
                      bland
                      bezei FROM t005u INTO TABLE it_t005u FOR ALL ENTRIES IN it_kna1
                      WHERE spras = sy-langu
                      AND land1 = it_kna1-land1
                      AND bland = it_kna1-regio.
      ENDIF.
      IF it_marc IS NOT INITIAL.
******HSN DODE Description
        SELECT steuc
               text1 FROM t604n INTO TABLE it_t604n
               FOR ALL ENTRIES IN it_marc
               WHERE steuc = it_marc-steuc AND spras = 'EN'
                                           AND land1 = 'IN'.

      ENDIF.
    ENDIF.
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
  DATA :lv_sln TYPE i VALUE 0.

  DATA : lv_sc TYPE regio,
         lv_sd TYPE bezei20.

  DATA : sl TYPE char5.
  LOOP AT it_bseg INTO wa_bseg.
    CLEAR:wa_fin,wa_bset,wa_vbap,wa_kna1,wa_mara.

    sl = sl + 1.
    wa_fin-slno = sl.

    READ TABLE it_vbrk INTO wa_vbrk WITH KEY vbeln = wa_bseg-vbeln .
    IF sy-subrc EQ 0 .
      wa_fin-xblnr = wa_vbrk-xblnr .
      wa_fin-fkart = wa_vbrk-fkart .
      READ TABLE it_vbrp INTO wa_vbrp WITH KEY vbeln = wa_vbrk-vbeln .
      IF sy-subrc EQ 0 .
        READ TABLE it_marc INTO wa_marc WITH KEY matnr = wa_vbrp-matnr werks = wa_vbrp-werks  .
        IF sy-subrc EQ 0 .
          wa_fin-steuc = wa_marc-steuc .
        ENDIF .
      ENDIF .
      READ TABLE it_vbrk1 INTO wa_vbrk1 WITH KEY vbeln = wa_vbrk-zuonr .
      IF sy-subrc EQ 0 .
        wa_fin-oinv = wa_vbrk1-xblnr .
        wa_fin-zuonr = wa_vbrk1-vbeln .
        wa_fin-fkdat = wa_vbrk1-fkdat .
      ENDIF .
    ENDIF .

    wa_fin-waerk = wa_bseg-pswsl .
    wa_fin-belnr1 = wa_bseg-belnr .
*    wa_fin-zuonr    =   wa_bseg-rebzg.

    READ TABLE it_kna1 INTO wa_kna1 WITH KEY kunnr = wa_bseg-kunnr.
    IF sy-subrc = 0.


      DATA: v_kunnr    TYPE vbpa-kunnr, "KNVP-KUNN2,
            v_regio    TYPE kna1-regio,
            v_new_code TYPE zregion_codes-new_code.
      " changed by naveen 04-01-18
      IF wa_bseg-kunnr IS NOT INITIAL.
        READ TABLE it_kna1 INTO wa_kna1 WITH KEY kunnr = wa_bseg-kunnr.
        IF sy-subrc = 0.
          wa_fin-name1   = wa_kna1-name1. "Name
          wa_fin-stcd3   = wa_kna1-stcd3. "GSTIN / UIN No
*        WA_FIN-REGIO   = WA_KNA1-REGIO.
          READ TABLE it_zregion INTO wa_zregion WITH KEY existing_code = wa_kna1-regio.
          wa_fin-regio   = wa_zregion-new_code.
*        WA_FIN-ZPOFS = WA_ZREGION-NEW_CODE.    "Place of Supply

          READ TABLE it_t005u INTO wa_t005u WITH KEY land1 = wa_kna1-land1 bland = wa_kna1-regio .
          IF sy-subrc EQ 0 .
            lv_sd = wa_t005u-bezei .
            lv_sc = wa_t005u-bland .
            CONCATENATE lv_sc lv_sd INTO wa_fin-stt SEPARATED BY '-' .
          ENDIF .
          CLEAR v_kunnr. SELECT SINGLE kunnr FROM vbpa INTO v_kunnr WHERE vbeln = wa_bseg-vbel2 AND parvw = 'WE'.
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

***      IF WA_BSEG-VBEL2 IS NOT INITIAL.
***        READ TABLE IT_VBAP INTO WA_VBAP WITH KEY VBELN = WA_BSEG-VBEL2 POSNR = WA_BSEG-POSN2 .
***        IF SY-SUBRC = 0.
***          READ TABLE IT_MARC INTO WA_MARC WITH KEY MATNR = WA_VBAP-MATNR WERKS = WA_VBAP-WERKS.
***          IF SY-SUBRC = 0.
***            WA_FIN-STEUC  = WA_MARC-STEUC."""HSN / SAC
***            CONDENSE WA_FIN-STEUC.
***          ENDIF.
***          READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_VBAP-MATNR.
***          IF SY-SUBRC = 0.
***            IF WA_MARA-MTART = 'DIEN'.
***              WA_FIN-ZGSER = 'S'.
****            WA_FIN-ZSUTY = 'Service'.       "changes by naveen 22.12.2017
***
***            ELSE.
***              WA_FIN-ZGSER = 'G'.
****            WA_FIN-ZSUTY = 'Goods'.
***            ENDIF.
***          ENDIF.
***
***
****        READ TABLE IT_T604N INTO WA_T604N WITH KEY STEUC = WA_MARC-STEUC."""description
****        IF SY-SUBRC = 0.
****          WA_FIN-TEXT1 = WA_T604N-TEXT1.
****        ENDIF.
***        ENDIF.
***      ENDIF.

      READ TABLE it_bkpf INTO wa_bkpf WITH KEY belnr = wa_bseg-belnr.
      IF sy-subrc = 0.
        wa_fin-awkey    =   wa_bkpf-awkey."Type   "
        wa_fin-budat    =   wa_bkpf-budat."DOcument date
        wa_fin-xblnrc   =   wa_bkpf-xblnr .
      ENDIF.
      " changed by naveen 26-12-17
      IF wa_bkpf-tcode = 'FB08'.
        wa_fin-dmbtr = wa_bseg-dmbtr * ( -1 ). "Amount of Advance Received
      ELSE.
        wa_fin-dmbtr = wa_bseg-dmbtr.
      ENDIF.
      " changed by naveen 26-12-17

      " changed by naveen 26-12-17
      IF wa_bkpf-tcode = 'FB08'..
        LOOP AT it_bset INTO wa_bset WHERE belnr = wa_bseg-belnr
                                      AND  gjahr = wa_bseg-gjahr.
*                                      AND  HWBAS = WA_BSEG-DMBTR.
          IF  wa_bset-kschl    = 'JOSG'.
            wa_fin-sgst  = wa_bset-hwste * ( -1 ).
            wa_fin-sgstp = ( wa_bset-kbetr / 10 ) * ( -1 ) .
            taxbl2       = wa_bset-hwbas.
          ELSEIF wa_bset-kschl = 'JOCG'.
            wa_fin-cgst   = wa_bset-hwste * ( -1 ).
            wa_fin-cgstp  = ( wa_bset-kbetr / 10 ) * ( -1 ).
*              TAXBL3 =  WA_BSET-HWBAS.
          ELSEIF wa_bset-kschl = 'JOIG'.
            wa_fin-igst  =  wa_bset-hwste * ( -1 ).
            wa_fin-igstp =  ( wa_bset-kbetr / 10 ) * ( -1 ).
            taxbl4       =  wa_bset-hwbas.

          ELSEIF wa_bset-kschl = 'JOUG'.            "'JOIG'.
            wa_fin-ugst  =  wa_bset-hwste * ( -1 ).
            wa_fin-ugstp =  ( wa_bset-kbetr / 10 ) * ( -1 ).
            taxbl4       =  wa_bset-hwbas.
          ELSEIF wa_bset-kschl = 'JICS'.
            wa_fin-cess  =  wa_bset-hwste * ( -1 ).
            wa_fin-cessp =  ( wa_bset-kbetr / 10 ) * ( -1 ).
            taxbl5       =  wa_bset-hwbas.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT it_bset INTO wa_bset WHERE belnr = wa_bseg-belnr
                                      AND  gjahr = wa_bseg-gjahr.
*                                      AND  HWBAS = WA_BSEG-DMBTR.
          IF  wa_bset-kschl    = 'JOSG' OR wa_bset-kschl = 'JISG'.
            wa_fin-sgst  = wa_bset-hwste + wa_fin-sgst.
            wa_fin-sgstp = wa_bset-kbetr / 10.
            taxbl2       = wa_bset-hwbas.
          ELSEIF wa_bset-kschl = 'JOCG' OR wa_bset-kschl = 'JICG'.
            wa_fin-cgst   = wa_bset-hwste + wa_fin-cgst.
            wa_fin-cgstp  = wa_bset-kbetr / 10.
*              TAXBL3 =  WA_BSET-HWBAS.
          ELSEIF wa_bset-kschl = 'JOIG' OR wa_bset-kschl = 'JIIG'.
            wa_fin-igst  =  wa_bset-hwste + wa_fin-igst.
            wa_fin-igstp =  wa_bset-kbetr / 10.
            taxbl4       =  wa_bset-hwbas.
          ELSEIF wa_bset-kschl = 'JOUG' OR wa_bset-kschl = 'JIUG'.
            wa_fin-ugst  =  wa_bset-hwste + wa_fin-ugst.
            wa_fin-ugstp =  wa_bset-kbetr / 10.
            taxbl5       =  wa_bset-hwbas.
          ELSEIF wa_bset-kschl = 'JICS'.
            wa_fin-cess  =  wa_bset-hwste + wa_fin-cess.
            wa_fin-cessp =  wa_bset-kbetr / 10.
            taxb16       =  wa_bset-hwbas.
          ENDIF.
        ENDLOOP.
      ENDIF.
      " changed by naveen 26-12-17


*    WA_FIN-TAXBL  =  TAXBL2 + TAXBL3 + TAXBL4 + TAXBL5.
      wa_fin-totval =   wa_fin-dmbtr  - ( wa_fin-sgst + wa_fin-cgst + wa_fin-igst + wa_fin-ugst + wa_fin-cess ). " + WA_FIN-TAXBL.+ WA_FIN-UGST
      IF wa_fin-cgst IS INITIAL AND wa_fin-igst IS INITIAL.
        CLEAR wa_fin.
        CONTINUE.
      ENDIF.
      APPEND wa_fin TO it_fin.
      CLEAR:wa_bset,wa_vbap,wa_kna1,wa_mara,wa_bseg,taxbl2,taxbl3,taxbl4,wa_makt,wa_bkpf,wa_fin.
    ENDIF.
  ENDLOOP.


*  DELETE it_fin WHERE cgst  IS INITIAL AND igst IS INITIAL.


ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM field_catalog .

*  wa_fcat-fieldname            = 'SLNO'.
*  wa_fcat-tabname              = 'IT_FIN'.
*  wa_fcat-seltext_l            = 'Sl No'.
*  APPEND wa_fcat TO it_fcat.
*  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'NAME1'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_l            = 'Name'.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'STT'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_l            = 'State with Code'.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'STCD3'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = 'GSTIN / UIN No'.
  wa_fcat-outputlen            = 21.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'BELNR1'.
*  WA_FCAT-FIELDNAME            = 'VBELN'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = 'FI Document No'.
  wa_fcat-outputlen            = 21.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'XBLNRC'.
*  WA_FCAT-FIELDNAME            = 'VBELN'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = 'Reference'.
  wa_fcat-outputlen            = 21.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'BUDAT'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = 'Document Date'.
  wa_fcat-outputlen            = 20.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'AWKEY'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = 'Document No'.
  wa_fcat-outputlen            = 20.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.


  wa_fcat-fieldname            = 'ZUONR'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = 'Original Doc No'.
  wa_fcat-outputlen            = 20.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.


  wa_fcat-fieldname            = 'OINV'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = 'Original Ref No'.
  wa_fcat-outputlen            = 20.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.


  wa_fcat-fieldname            = 'FKDAT'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = 'Original Doc Date'.
  wa_fcat-outputlen            = 20.
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.


  wa_fcat-fieldname            = 'STEUC'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = 'HSN Code'.
  wa_fcat-outputlen            = 16 .
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

*  wa_fcat-fieldname            = 'REGIO'.
*  wa_fcat-tabname              = 'IT_FIN'.
*  wa_fcat-seltext_m            = 'Place of Supply'.
*  wa_fcat-outputlen            = 13.
*  wa_fcat-just                 = 'L'.
*  APPEND wa_fcat TO it_fcat.
*  CLEAR wa_fcat.

**  WA_FCAT-DO_SUM               = 'X'.
**  WA_FCAT-FIELDNAME            = 'ZSUTY'.
**  WA_FCAT-TABNAME              = 'IT_FIN'.
**  WA_FCAT-SELTEXT_M            = 'Supply Type'.
**  WA_FCAT-OUTPUTLEN            = 13.
**  WA_FCAT-JUST                 = 'L'.
**  APPEND WA_FCAT TO IT_FCAT.
**  CLEAR WA_FCAT.
  wa_fcat-fieldname            = 'WAERK'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = 'Currency'.
  wa_fcat-outputlen            = 4 .
  wa_fcat-just                 = 'L'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'TOTVAL'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = 'Taxable Value'.
  wa_fcat-outputlen            = 30.
  wa_fcat-just                 = 'R'.
  wa_fcat-do_sum               = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.


  wa_fcat-fieldname            = 'IGSTP'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = '%'.
  wa_fcat-outputlen            = 13.
  wa_fcat-just                 = 'R'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.


  wa_fcat-do_sum               = 'X'.
  wa_fcat-fieldname            = 'IGST'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = 'IGST'.
  wa_fcat-outputlen            = 13.
  wa_fcat-just                 = 'R'.
  wa_fcat-do_sum               = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'CGSTP'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = '%'.
  wa_fcat-outputlen            = 13.
  wa_fcat-just                 = 'R'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-do_sum               = 'X'.
  wa_fcat-fieldname            = 'CGST'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = 'CGST'.
  wa_fcat-outputlen            = 13.
  wa_fcat-just                 = 'R'.
  wa_fcat-do_sum               = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'SGSTP'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = '%'.
  wa_fcat-outputlen            = 13.
  wa_fcat-just                 = 'R'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-do_sum               = 'X'.
  wa_fcat-fieldname            = 'SGST'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = 'SGST'.
  wa_fcat-outputlen            = 13.
  wa_fcat-just                 = 'R'.
  wa_fcat-do_sum               = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

*  wa_fcat-fieldname            = 'UGSTP'.
*  wa_fcat-tabname              = 'IT_FIN'.
*  wa_fcat-seltext_m            = 'UGST Rate'.
*  wa_fcat-outputlen            = 13.
*  wa_fcat-just                 = 'R'.
*  APPEND wa_fcat TO it_fcat.
*  CLEAR wa_fcat.
*
*  wa_fcat-do_sum               = 'X'.
*  wa_fcat-fieldname            = 'UGST'.
*  wa_fcat-tabname              = 'IT_FIN'.
*  wa_fcat-seltext_m            = 'UGST Amount'.
*  wa_fcat-outputlen            = 13.
*  wa_fcat-just                 = 'R'.
*  wa_fcat-do_sum               = 'X'.
*  APPEND wa_fcat TO it_fcat.
*  CLEAR wa_fcat.
*
*  wa_fcat-do_sum               = 'X'.
*  wa_fcat-fieldname            = 'CESSP'.
*  wa_fcat-tabname              = 'IT_FIN'.
*  wa_fcat-seltext_m            = 'Cess Rate'.
*  wa_fcat-outputlen            = 13.
*  wa_fcat-just                 = 'R'.
*  APPEND wa_fcat TO it_fcat.
*  CLEAR wa_fcat.


  wa_fcat-do_sum               = 'X'.
  wa_fcat-fieldname            = 'CESS'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = 'Cess'.
  wa_fcat-outputlen            = 13.
  wa_fcat-just                 = 'R'.
  wa_fcat-do_sum               = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'DMBTR'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = 'Total Value'.
  wa_fcat-outputlen            = 30.
  wa_fcat-just                 = 'R'.
  wa_fcat-do_sum               = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.


  wa_fcat-fieldname            = 'FKART'.
  wa_fcat-tabname              = 'IT_FIN'.
  wa_fcat-seltext_m            = 'Billing Type'.
  wa_fcat-outputlen            = 6.
  wa_fcat-just                 = 'L'.
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
      t_outtab                    = it_fin
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



  lv_top = 'GSTR1-Credit Note'.

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

IF lv_top IS NOT INITIAL.
  CALL FUNCTION 'FI_CONVERT_FIRSTCHARS_TOUPPER'
    EXPORTING
      INPUT_STRING        = LV_TOP
     SEPARATORS          = ' '
   IMPORTING
     OUTPUT_STRING       = lv_top.
            .

*  CALL FUNCTION 'ISP_CONVERT_FIRSTCHARS_TOUPPER'
*
*    EXPORTING
*      input_string  = lv_top
*      separators    = ' '
*    IMPORTING
*      output_string = lv_top.
ENDIF.
ENDFORM.
