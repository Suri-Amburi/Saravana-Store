*&---------------------------------------------------------------------*
*& Include          SAPMZMM_SUBCON_SALES_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.
  "Handle User Command
  CASE ok_9001.
    WHEN back OR canc OR exit.
      LEAVE TO SCREEN 0 .
    WHEN genr.
      DELETE xsubcon_itm WHERE menge IS INITIAL.
      CHECK xsubcon_hdr-sprice IS NOT INITIAL AND xsubcon_hdr-menge IS NOT INITIAL.
      PERFORM generate_po CHANGING sebeln .
      CHECK sebeln IS NOT INITIAL.
      PERFORM goods_movement_541 CHANGING ssubrc xsubcon_hdr-mblnr_541 xsubcon_hdr-mjahr_541.
      CHECK ssubrc IS INITIAL.
      PERFORM goods_movement_101 CHANGING ssubrc xsubcon_hdr-mblnr_101 xsubcon_hdr-mjahr_101 xsubcon_hdr-charg.
***      IF ssubrc IS NOT INITIAL AND xsubcon_hdr-mblnr_101 IS INITIAL.
***        PERFORM reverse_gm USING xsubcon_hdr-mblnr_541 xsubcon_hdr-mjahr_541.
***      ENDIF.
      IF xsubcon_hdr-mjahr_101 IS INITIAL.
        xsubcon_hdr-mjahr_101 = sy-datum(4).
      ENDIF.
      CHECK ssubrc IS INITIAL AND xsubcon_hdr-mblnr_101 IS NOT INITIAL.
      PERFORM print_label CHANGING ssubrc.
    WHEN refr.
      CLEAR : xsubcon_hdr,xsubcon_itm,sebeln.
      REFRESH : xsubcon_itm.
    WHEN dclick.
      CHECK sebeln IS NOT INITIAL.
      SET PARAMETER ID 'BES' FIELD sebeln.
      DATA : sebelp TYPE ebelp VALUE '00010'.
      SET PARAMETER ID 'BSP' FIELD sebelp.
      "Open Purchase Order Screen.
      CALL TRANSACTION 'ME23N'
      WITH AUTHORITY-CHECK
      AND SKIP FIRST SCREEN .
    WHEN plant.
      "Get Plant Name
      CLEAR : xsubcon_hdr-pdesc.
      IF xsubcon_hdr-werks IS NOT INITIAL.
        SELECT SINGLE name1 FROM t001w
       INTO xsubcon_hdr-pdesc
       WHERE werks = xsubcon_hdr-werks.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_COMP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_comp INPUT.
  CHECK xsubcon_hdr-chargean IS NOT INITIAL.
  CLEAR : xsubcon_itm.
  SELECT SINGLE a~werks a~matnr f~meins e~maktx a~charg a~clabs c~stprs c~verpr b~ersda b~lwedt
         INTO CORRESPONDING FIELDS OF xsubcon_itm
         FROM mchb AS a INNER JOIN mcha AS b
         ON ( b~matnr = a~matnr AND b~werks = a~werks AND b~charg = a~charg )
         INNER JOIN mara AS f ON ( f~matnr = a~matnr )
         INNER JOIN mbew AS c ON ( c~matnr = a~matnr AND c~bwkey = a~werks AND c~bwtar = a~charg  )
         INNER JOIN makt AS e ON ( e~spras = sy-langu AND e~matnr = a~matnr )
         WHERE a~werks = xsubcon_hdr-werks AND a~charg = xsubcon_hdr-chargean.
  IF sy-subrc IS NOT INITIAL.
    SELECT SINGLE b~werks a~matnr e~meins d~maktx a~ean11 b~lgort INTO CORRESPONDING FIELDS OF xsubcon_itm
         FROM marm AS a INNER JOIN mard AS b
         ON ( b~matnr = a~matnr AND b~lgort = 'FG01' )
         INNER JOIN mara AS e ON ( e~matnr = a~matnr )
         INNER JOIN mbew AS c ON ( c~matnr = a~matnr AND c~bwkey = b~werks )
         INNER JOIN makt AS d ON ( d~spras = sy-langu AND d~matnr = a~matnr )
         WHERE b~werks = xsubcon_hdr-werks AND a~ean11 = xsubcon_hdr-chargean.
  ENDIF.
  IF sy-subrc IS INITIAL.
    READ TABLE xsubcon_itm WITH KEY matnr = xsubcon_itm-matnr TRANSPORTING NO FIELDS.
    IF sy-subrc IS NOT INITIAL.
      xsubcon_itm-menge = 1.
      xsubcon_itm-req_qty = xsubcon_hdr-menge * xsubcon_itm-menge.
      IF xsubcon_itm-req_qty > xsubcon_itm-clabs.
        xsubcon_itm-icon = sred.
      ELSE.
        xsubcon_itm-icon = sgreen.
      ENDIF.
      APPEND xsubcon_itm.
      CLEAR :xsubcon_itm.
***  ELSE.
***    CLEAR : xsubcon_hdr-chargean.
***    MESSAGE 'Invalid Component dtls.' && xsubcon_hdr-chargean TYPE si.
***  ENDIF.
    ELSE.
      MESSAGE 'Duplicate Article entry not possible' && xsubcon_itm-matnr TYPE sw.
    ENDIF.
  ELSE.
    CLEAR : xsubcon_hdr-chargean.
    MESSAGE 'Invalid Component dtls.' && xsubcon_hdr-chargean TYPE si.
  ENDIF.
  CLEAR : xsubcon_hdr-chargean,xsubcon_itm..
ENDMODULE.
