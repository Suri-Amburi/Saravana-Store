*&---------------------------------------------------------------------*
*& Include          SAPMZMM_WHSTO_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
  CLEAR : ok_9001.

  REFRESH : excl.
  IF xsto_itm[] IS INITIAL .
    excl = move. APPEND excl.
****  ELSE.
  ELSE.
  ENDIF.
  SET PF-STATUS 'STATUS_9001' EXCLUDING excl.
  SET TITLEBAR 'TITLE_9001'.

  LOOP AT SCREEN .
    IF ( xsto_hdr-swerks IS INITIAL
      OR xsto_hdr-rwerks IS INITIAL )
      AND screen-group1 = sg1.
      screen-input = 0 .
    ELSEIF xsto_hdr-swerks IS NOT INITIAL
      AND xsto_hdr-rwerks IS NOT INITIAL AND screen-group1 = sg2.
      screen-input = 0 .
    ELSEIF xsto_hdr-b1_charg IS INITIAL AND screen-name = 'XSTO_HDR-MENGE'.
      screen-input = 0.
    ELSEIF xsto_hdr-vbeln IS NOT INITIAL AND screen-group2 = sg2.
      screen-invisible = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

  IF xsto_hdr-swerks IS INITIAL.
    SET CURSOR FIELD 'XSTO_HDR-SWERKS'.
  ELSEIF xsto_hdr-rwerks IS INITIAL.
    SET CURSOR FIELD 'XSTO_HDR-RWERKS'.
  ELSEIF xsto_hdr-b1_charg IS INITIAL.
    SET CURSOR FIELD 'XSTO_HDR-B1_CHARG'.
  ELSE.
    SET CURSOR FIELD 'XSTO_HDR-MENGE'.
  ENDIF.

  PERFORM disp_logo(sapmzmm_subcon_sales).  "Display Logo
  PERFORM scontainer.
ENDMODULE.
