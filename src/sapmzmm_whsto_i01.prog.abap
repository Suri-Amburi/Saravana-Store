*&---------------------------------------------------------------------*
*& Include          SAPMZMM_WHSTO_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.
  CASE ok_9001.
    WHEN back OR canc OR exit.
      LEAVE TO SCREEN 0.
    WHEN move.
      CHECK xsto_itm[] IS NOT INITIAL AND xsto_hdr-ebeln IS INITIAL.
      CLEAR : xsto_hdr-vbeln.
      PERFORM sto_create CHANGING ssubrc
                         xsto_hdr-ebeln
                         xsto_hdr-vbeln.
      CLEAR : xsto_itm. "xsto_hdr,
      CLEAR : xsto_hdr-b1_charg,xsto_hdr-s4_charg,xsto_hdr-menge,xsto_hdr-vbeln.
      REFRESH : xsto_itm.
    WHEN swrk.
      IF xsto_hdr-swerks = xsto_hdr-rwerks.
        CLEAR : xsto_hdr-swerks.
        MESSAGE 'Soruce & Dest. cant be the same ' TYPE sw.
      ENDIF.
    WHEN rwrk.
      IF xsto_hdr-swerks = xsto_hdr-rwerks.
        CLEAR : xsto_hdr-rwerks.
        MESSAGE 'Soruce & Dest. cant be the same ' TYPE sw.
      ENDIF.
    WHEN dclick.
      CHECK xsto_hdr-vbeln IS NOT INITIAL.
      SET PARAMETER ID 'VL' FIELD xsto_hdr-vbeln.
      CALL TRANSACTION 'VL33N' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
    WHEN refr.
      CLEAR : xsto_itm. "xsto_hdr,
      CLEAR : xsto_hdr-b1_charg,xsto_hdr-s4_charg,xsto_hdr-menge.
      REFRESH : xsto_itm.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_BATCH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_batch INPUT.
  CHECK xsto_hdr-b1_charg IS NOT INITIAL .
  CLEAR : xsto_hdr-s4_charg.
  SELECT SINGLE s4_batch  FROM zb1_s4_map
    INTO xsto_hdr-s4_charg
    WHERE b1_batch  = xsto_hdr-b1_charg.
  IF xsto_hdr-s4_charg IS INITIAL.
    scharg = xsto_hdr-b1_charg(10). "SAP Batch
    SELECT SINGLE charg FROM mchb
      INTO xsto_hdr-s4_charg
      WHERE werks = xsto_hdr-swerks AND lgort = 'FG01' AND charg = scharg.
  ENDIF.
  IF xsto_hdr-s4_charg IS NOT INITIAL.

    IF xsto_itm[] IS NOT INITIAL.
      READ TABLE xsto_itm WITH KEY s4_charg = xsto_hdr-s4_charg TRANSPORTING NO FIELDS.
      IF sy-subrc IS INITIAL.
        CLEAR : xsto_hdr-b1_charg,xsto_hdr-s4_charg.
        MESSAGE 'Entry Already Exists in line ' && sy-tabix TYPE si.
      ELSE.
      ENDIF.
    ENDIF.
    IF xsto_hdr-menge IS NOT INITIAL AND xsto_hdr-s4_charg IS NOT INITIAL .
      CLEAR : xsto_itm.
      MOVE-CORRESPONDING xsto_hdr TO xsto_itm .
      SELECT SINGLE a~matnr,c~maktx,a~clabs,b~matkl,b~meins,d~verpr
         FROM mchb AS a INNER JOIN mara AS b ON ( b~matnr = a~matnr )
        INNER JOIN makt AS c ON ( c~matnr = a~matnr AND c~spras = @sy-langu )
        INNER JOIN mbew AS d ON ( d~matnr = a~matnr AND d~bwkey = a~werks AND d~bwtar = a~charg  )
        WHERE charg = @xsto_hdr-s4_charg
        AND werks = @xsto_hdr-swerks
        AND lgort = 'FG01'
        INTO ( @xsto_itm-matnr , @xsto_itm-maktx , @DATA(sclabs), @xsto_itm-matkl,@xsto_itm-meins,@xsto_itm-verpr ).
      IF xsto_hdr-menge <= sclabs.
        APPEND xsto_itm.
        CLEAR : xsto_hdr-b1_charg,xsto_hdr-s4_charg,xsto_hdr-menge,xsto_itm.
      ELSE.
        DATA : smsg TYPE char10.
        smsg = xsto_hdr-menge - sclabs.
        MESSAGE 'Qty Exceeded by ' && smsg && space && xsto_itm-meins TYPE sw.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE 'Invalid Batch !!!' && xsto_hdr-b1_charg TYPE sw.
    CLEAR  :xsto_hdr-b1_charg.
  ENDIF.

ENDMODULE.
