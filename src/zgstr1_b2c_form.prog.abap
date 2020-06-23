*&---------------------------------------------------------------------*
*& Include          ZGSTR1_B2C_FORM
*&---------------------------------------------------------------------*

FORM sel.

  """"""""""""""""""""" FOR DATE RANGE """"""""""""""""""""""""""""""
  DATA : first_date TYPE sy-datum,
         last_date  TYPE  sy-datum,
         input_date TYPE sy-datum,
         r_date     TYPE RANGE OF rbkp-budat.

  """""""""""""""""""""""" FOR DATE RANGE """""""""""""""""""""""""""""""
  input_date =  p_fyear && p_month && '01' .
  CALL FUNCTION 'HR_JP_MONTH_BEGIN_END_DATE'
    EXPORTING
      iv_date             = input_date
    IMPORTING
      ev_month_begin_date = first_date     "start date
      ev_month_end_date   = last_date. " end date
  APPEND VALUE #( sign = 'I' option = 'BT' low = first_date high = last_date  ) TO r_date .

  """"""""""""""""""""""""""' SELECT """""""""""""""""""""""""""""""""""""""


***********************Fetching data
BREAK PPADHY.
  DATA(s_cond) = |h_blart IN ( 'RV', 'AB', 'DR', 'DG' , 'DA' )| .
SELECT
  BUKRS,
  BELNR,
  GJAHR,
  BUZEI,
  BSCHL,
  H_BLART,
  DMBTR,
  WRBTR,
  VBELN,
  H_BUDAT
  FROM BSEG INTO TABLE @DATA(IT_BSEG)
  WHERE H_BUDAT IN @R_DATE AND (s_cond).

  SELECT
    vbeln
    erdat
    knumv
    fkart
    fksto
   FROM vbrk INTO TABLE it_vbrk
   FOR ALL ENTRIES IN it_bseg
   WHERE   vbeln = it_bseg-vbeln."FKDAT IN r_date AND fkart = 'FP' AND  fksto = '' AND
  IF it_vbrk IS NOT INITIAL.

    SELECT
      vbeln
      posnr
      matnr
      netwr
      mwsbp
      fkimg
      mwsk1
*    NRAB_KNUMH
    FROM vbrp INTO TABLE it_vbrp
    FOR ALL ENTRIES IN it_vbrk WHERE vbeln = it_vbrk-vbeln.
  ENDIF.

  IF it_vbrp IS NOT INITIAL.

    SELECT
      spras
      kalsm
      mwskz
      text1
      FROM t007s INTO TABLE it_t007s
      FOR ALL ENTRIES IN it_vbrp WHERE mwskz = it_vbrp-mwsk1 AND spras = 'EN'.

    SELECT
         matnr
         werks
         steuc
      FROM marc INTO TABLE it_marc
      FOR ALL ENTRIES IN it_vbrp WHERE matnr = it_vbrp-matnr.
  ENDIF.

  IF it_marc IS NOT INITIAL.

    SELECT
      kappl
      kschl
      aland
      wkreg
      regio
      steuc
      waerk
      kfrst
      datbi
      datab
      knumh
    FROM a519 INTO TABLE it_a519
    FOR ALL ENTRIES IN it_marc WHERE steuc = it_marc-steuc AND datab LE sy-datum
                                                           AND datbi GE sy-datum.
  ENDIF.

  IF it_a519 IS NOT INITIAL.
    SELECT
       knumh
       kopos
       kschl
       kbetr
       pkwrt
       mwsk1
       loevm_ko
      FROM konp INTO TABLE it_konp
      FOR ALL ENTRIES IN it_a519 WHERE knumh = it_a519-knumh AND loevm_ko = space .
  ENDIF.

  IF it_vbrk IS NOT INITIAL.

    SELECT
      knumv,
      kposn,
      kschl,
      kbetr,
      kwert
      FROM prcd_elements INTO TABLE @DATA(it_prcd)
      FOR ALL ENTRIES IN @it_vbrk
      WHERE knumv = @it_vbrk-knumv AND kschl IN ( 'JOSG' , 'JOCG' , 'JOIG' ).

  ENDIF.
  BREAK ppadhy.
  """"""""""""""""""""""""""""""""""""for hsn
  IF hsn EQ 'X'.

    LOOP AT it_vbrp INTO wa_vbrp .""WHERE ERDAT IN R_DATE .


      wa_finalt-posnr = wa_vbrp-posnr.
      wa_finalt-matnr = wa_vbrp-matnr.
      wa_finalt-netwr = wa_vbrp-netwr.
      wa_finalt-mwsbp = wa_vbrp-mwsbp.
      wa_finalt-fkimg = wa_vbrp-fkimg.



      READ TABLE it_vbrk INTO wa_vbrk WITH KEY vbeln = wa_vbrp-vbeln.
      IF sy-subrc = 0.
        wa_finalt-vbeln = wa_vbrk-vbeln.
        wa_finalt-erdat = wa_vbrk-erdat.
        wa_finalt-knumv = wa_vbrk-knumv.
      ENDIF.

      READ TABLE it_t007s INTO wa_t007s WITH KEY mwskz = wa_vbrp-mwsk1.
      IF sy-subrc = 0.
        wa_finalt-spras = wa_t007s-spras.
        wa_finalt-kalsm = wa_t007s-kalsm.
        wa_finalt-mwskz = wa_t007s-mwskz.
        wa_finalt-text1  = wa_t007s-text1.
      ENDIF.

      READ TABLE it_marc INTO wa_marc WITH KEY matnr = wa_vbrp-matnr.
      IF sy-subrc = 0.
        wa_finalt-steuc = wa_marc-steuc.

      ENDIF.

      READ TABLE it_a519 INTO wa_a519 WITH KEY steuc = wa_marc-steuc.
      IF sy-subrc = 0.
        wa_finalt-knumh = wa_a519-knumh.

      ENDIF.

      LOOP AT it_prcd INTO DATA(wa_prcd) WHERE knumv = wa_vbrk-knumv.
        wa_finalt-kschl = wa_prcd-kschl.
        CASE  : wa_prcd-kschl.
          WHEN 'JOIG' .
            wa_finalt-igst = wa_prcd-kwert .
*          WA_FINALT-IGST = WA_FINALT-MWSBP * ( WA_FINALT-IGST% /  100 ) .
          WHEN 'JOCG'.
            wa_finalt-cgst = wa_prcd-kwert .
*          WA_FINALT-CGST = WA_FINALT-MWSBP * ( WA_FINALT-CGST% /  100 ).
          WHEN 'JOSG'.
            wa_finalt-sgst = wa_prcd-kwert .
*          WA_FINALT-SGST = WA_FINALT-MWSBP * ( WA_FINALT-SGST% /  100 ).
        ENDCASE.
      ENDLOOP.
      APPEND wa_finalt TO it_finalt .
      CLEAR wa_finalt .
    ENDLOOP.

    it_finalt1 = it_finalt.
    SORT it_finalt1 BY steuc.
    DELETE ADJACENT DUPLICATES FROM it_finalt1 COMPARING steuc.
*    BREAK ppadhy.
    LOOP AT it_finalt1 INTO wa_finalt1.

      CLEAR:wa_finalt1-fkimg,wa_finalt1-netwr,wa_finalt1-mwsbp,wa_finalt1-igst,
            wa_finalt1-cgst,wa_finalt1-sgst,wa_finalt1-cess.
      wa_final2 = wa_finalt1.

      LOOP AT it_finalt INTO wa_finalt WHERE steuc = wa_finalt1-steuc.

        wa_final2-steuc    = wa_final2-steuc .
        wa_final2-fkimg    = wa_final2-fkimg   + wa_finalt-fkimg.
        wa_final2-netwr    = wa_final2-netwr   + wa_finalt-netwr.
        wa_final2-mwsbp    = wa_final2-mwsbp   + wa_finalt-mwsbp.
        wa_final2-igst     = wa_final2-igst    + wa_finalt-igst.
        wa_final2-cgst     = wa_final2-cgst    + wa_finalt-cgst.
        wa_final2-sgst     = wa_final2-sgst    + wa_finalt-sgst.
        wa_final2-cess     = wa_final2-cess    + wa_finalt-cess.

* APPEND WA_FINALT TO IT_FINALT.
*  CLEAR WA_FINALT.
      ENDLOOP.

      APPEND wa_final2 TO it_final2.
      CLEAR : wa_final2 ,wa_finalt.

    ENDLOOP.
*  CLEAR : WA_FINALT.
*ENDLOOP.
ELSE.
"""""""""""""""""""""""""""""for taxwise

    LOOP AT it_vbrp INTO wa_vbrp ."WHERE ERDAT IN R_DATE .


      wa_finalt-posnr = wa_vbrp-posnr.
      wa_finalt-matnr = wa_vbrp-matnr.
      wa_finalt-netwr = wa_vbrp-netwr.
      wa_finalt-mwsbp = wa_vbrp-mwsbp.
      wa_finalt-fkimg = wa_vbrp-fkimg.


      READ TABLE it_vbrk INTO wa_vbrk WITH KEY vbeln = wa_vbrp-vbeln.
      IF sy-subrc = 0.

        wa_finalt-vbeln = wa_vbrk-vbeln.
        wa_finalt-erdat = wa_vbrk-erdat.
        wa_finalt-knumv = wa_vbrk-knumv.

      ENDIF.

      READ TABLE it_t007s INTO wa_t007s WITH KEY mwskz = wa_vbrp-mwsk1.
      IF sy-subrc = 0.
        wa_finalt-spras = wa_t007s-spras.
        wa_finalt-kalsm = wa_t007s-kalsm.
        wa_finalt-mwskz = wa_t007s-mwskz.
        wa_finalt-text1  = wa_t007s-text1.
      ENDIF.

      READ TABLE it_marc INTO wa_marc WITH KEY matnr = wa_vbrp-matnr.
      IF sy-subrc = 0.
        wa_finalt-steuc = wa_marc-steuc.

      ENDIF.

      READ TABLE it_a519 INTO wa_a519 WITH KEY steuc = wa_marc-steuc.
      IF sy-subrc = 0.
        wa_finalt-knumh = wa_a519-knumh.

      ENDIF.
      LOOP AT it_prcd INTO wa_prcd WHERE knumv = wa_vbrk-knumv.
        CASE  : wa_prcd-kschl.
          WHEN 'JOIG' .
            wa_finalt-igst = wa_prcd-kwert .
*          WA_FINALT-IGST = WA_FINALT-MWSBP* ( WA_FINALT-IGST% /  100 ) .
          WHEN 'JOCG'.
            wa_finalt-cgst = wa_prcd-kwert .
*          WA_FINALT-CGST = WA_FINALT-MWSBP * ( WA_FINALT-CGST% /  100 ).
          WHEN 'JOSG'.
            wa_finalt-sgst = wa_prcd-kwert .
*          WA_FINALT-SGST = WA_FINALT-MWSBP * ( WA_FINALT-SGST% /  100 ).
        ENDCASE.
      ENDLOOP.
      APPEND wa_finalt TO it_finalt .
      CLEAR wa_finalt .
    ENDLOOP.
*BREAK dgouda.
    DATA(it_fin4) = it_finalt.
    SORT it_fin4 BY mwskz.
    DELETE ADJACENT DUPLICATES FROM it_fin4 COMPARING mwskz.

    LOOP AT it_fin4 INTO DATA(wa_fin4).

      CLEAR:wa_fin4-fkimg,wa_fin4-netwr,wa_fin4-mwsbp,wa_fin4-igst,
         wa_fin4-cgst,wa_fin4-sgst,wa_fin4-cess.

      wa_final3 = wa_fin4.
*  WA_FINAL3-MWSK1   = WA_FINAL3-MWSK1.

      LOOP AT it_finalt INTO wa_finalt WHERE mwskz = wa_fin4-mwskz.

        wa_final3-mwskz   = wa_final3-mwskz.
        wa_final3-fkimg   = wa_final3-fkimg   + wa_finalt-fkimg.
        wa_final3-netwr   = wa_final3-netwr   + wa_finalt-netwr.
        wa_final3-mwsbp   = wa_final3-mwsbp   + wa_finalt-mwsbp.
        wa_final3-igst    = wa_final3-igst    + wa_finalt-igst.
        wa_final3-cgst    = wa_final3-cgst    + wa_finalt-cgst.
        wa_final3-sgst    = wa_final3-sgst    + wa_finalt-sgst.
        wa_final3-cess    = wa_final3-cess    + wa_finalt-cess.
        wa_final3-text1   = wa_final3-text1.

      ENDLOOP.

      APPEND wa_final3 TO it_final3.
      CLEAR : wa_final3 , wa_finalt.

    ENDLOOP.

*  CLEAR : WA_FINALT.
*ENDLOOP.
  ENDIF.

*  BREAK dgouda.

*********************,Fieldcatlog designing

  IF hsn EQ 'X'.
    wa_fieldcat-col_pos = '1'.
    wa_fieldcat-fieldname = 'STEUC' .
    wa_fieldcat-seltext_m = 'HSN WISE' .
    APPEND wa_fieldcat TO it_fieldcat .
    CLEAR wa_fieldcat .
  ELSE.
    wa_fieldcat-col_pos = '1'.
    wa_fieldcat-fieldname = 'MWSKZ' .
    wa_fieldcat-seltext_m = 'TAX WISE' .
    APPEND wa_fieldcat TO it_fieldcat .
    CLEAR wa_fieldcat .

    wa_fieldcat-col_pos = '9'.
    wa_fieldcat-fieldname = 'TEXT1' .
    wa_fieldcat-seltext_m = 'Taxcode Description' .
    APPEND wa_fieldcat TO it_fieldcat .
    CLEAR wa_fieldcat .
  ENDIF.

  wa_fieldcat-col_pos = '2'.
  wa_fieldcat-fieldname = 'FKIMG' .
  wa_fieldcat-seltext_m = 'Total Qty' .
  wa_fieldcat-do_sum = 'X'.
  APPEND wa_fieldcat TO it_fieldcat .
  CLEAR wa_fieldcat .

  wa_fieldcat-col_pos = '3'.
  wa_fieldcat-fieldname = 'NETWR' .
  wa_fieldcat-seltext_m = 'Total Sales Amount'.
  wa_fieldcat-do_sum = 'X'.
  APPEND wa_fieldcat TO it_fieldcat .
  CLEAR wa_fieldcat .

  wa_fieldcat-col_pos = '4'.
  wa_fieldcat-fieldname = 'MWSBP' .
  wa_fieldcat-seltext_m = 'Taxable Sales Amount'.
  wa_fieldcat-do_sum = 'X'.
  APPEND wa_fieldcat TO it_fieldcat .
  CLEAR wa_fieldcat .

  wa_fieldcat-col_pos = '5'.
  wa_fieldcat-fieldname = 'IGST' .
  wa_fieldcat-seltext_m = 'Integrated Tax Amount' .
  wa_fieldcat-do_sum = 'X'.
  APPEND wa_fieldcat TO it_fieldcat .
  CLEAR wa_fieldcat .

  wa_fieldcat-col_pos = '6'.
  wa_fieldcat-fieldname = 'CGST' .
  wa_fieldcat-seltext_m = 'Central Tax Amount' .
  wa_fieldcat-do_sum = 'X'.
  APPEND wa_fieldcat TO it_fieldcat .
  CLEAR wa_fieldcat .

  wa_fieldcat-col_pos = '7'.
  wa_fieldcat-fieldname = 'SGST' .
  wa_fieldcat-seltext_m = 'State/UT Tax Amount' .
  wa_fieldcat-do_sum = 'X'.
  APPEND wa_fieldcat TO it_fieldcat .
  CLEAR wa_fieldcat .

  wa_fieldcat-col_pos = '8'.
  wa_fieldcat-fieldname = 'CESS' .
  wa_fieldcat-seltext_m = 'CESS Amount' .
  wa_fieldcat-do_sum = 'X'.
  APPEND wa_fieldcat TO it_fieldcat .
  CLEAR wa_fieldcat .

  wa_layout-colwidth_optimize ='X'.
  wa_layout-zebra = 'X'.

  IF hsn EQ 'X'.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
*       I_INTERFACE_CHECK  = ' '
*       I_BYPASSING_BUFFER = ' '
*       I_BUFFER_ACTIVE    = ' '
        i_callback_program = sy-repid
*       I_CALLBACK_PF_STATUS_SET          = ' '
*       I_CALLBACK_USER_COMMAND           = ' '
*       I_CALLBACK_TOP_OF_PAGE            = ' '
        is_layout          = wa_layout
        it_fieldcat        = it_fieldcat
      TABLES
        t_outtab           = it_final2
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF.
  IF taxcode EQ 'X'.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
*       I_INTERFACE_CHECK  = ' '
*       I_BYPASSING_BUFFER = ' '
*       I_BUFFER_ACTIVE    = ' '
        i_callback_program = sy-repid
*       I_CALLBACK_PF_STATUS_SET          = ' '
*       I_CALLBACK_USER_COMMAND           = ' '
*       I_CALLBACK_TOP_OF_PAGE            = ' '
        is_layout          = wa_layout
        it_fieldcat        = it_fieldcat
      TABLES
        t_outtab           = it_final3
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF.

ENDFORM.
