*&---------------------------------------------------------------------*
*& Include          SAPMZMM_SUBCON_SALES_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
  CLEAR  :ok_9001.
  REFRESH : excl.
  IF xsubcon_itm[] IS INITIAL OR ( sebeln IS NOT INITIAL AND xsubcon_itm[] IS NOT INITIAL ) .
    excl = genr. APPEND excl.
****  ELSE.
  ELSE.
  ENDIF.
  SET PF-STATUS 'STATUS_9001' EXCLUDING excl.
  SET TITLEBAR 'TITLE_9001' WITH sy-uname.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module UPDT_SCRN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE updt_scrn OUTPUT.
  PERFORM disp_logo.  "Display Logo
  PERFORM scontainer. "Update Grid.
  IF xsubcon_hdr-werks IS NOT INITIAL AND xsubcon_hdr-pdesc IS INITIAL.
    "Get Plant Name
    SELECT SINGLE name1 FROM t001w
      INTO xsubcon_hdr-pdesc
      WHERE werks = xsubcon_hdr-werks.
  ENDIF.

  IF xsubcon_hdr-matnr IS NOT INITIAL AND xsubcon_hdr-maktx IS INITIAL.
    "Get Plant Name
    SELECT SINGLE b~maktx a~meins INTO ( xsubcon_hdr-maktx , xsubcon_hdr-meins )
      FROM mara AS a INNER JOIN makt AS b ON ( b~matnr = a~matnr )
      INNER JOIN marc AS c ON ( c~werks = xsubcon_hdr-werks AND c~matnr = a~matnr )
      WHERE b~spras = sy-langu AND a~matnr = xsubcon_hdr-matnr.
    IF sy-subrc IS NOT INITIAL.
      CLEAR  : xsubcon_hdr-matnr  .
      MESSAGE 'Material Not found in plant' && xsubcon_hdr-matnr TYPE sw.
    ENDIF.
  ENDIF.

  "Update Screen Attributes.
  LOOP AT SCREEN .
    IF sebeln IS INITIAL.
      IF xsubcon_hdr-mblnr_101 IS INITIAL AND screen-group1 = sg1 .
        screen-invisible = 1 .
      ELSEIF xsubcon_hdr-werks IS INITIAL AND screen-group2 = sg1.
        screen-input = 0 .
      ELSEIF xsubcon_hdr-werks IS NOT INITIAL AND screen-name = 'XSUBCON_HDR-WERKS'.
        screen-input = 0.
      ELSEIF xsubcon_hdr-matnr IS NOT INITIAL AND screen-name = 'XSUBCON_HDR-MATNR'.
        screen-input = 0.
      ELSEIF xsubcon_hdr-matnr IS INITIAL AND screen-name = 'XSUBCON_HDR-CHARGEAN'.
        screen-input = 0.
      ENDIF.
    ELSE.
      screen-input = 0 .
    ENDIF.
    MODIFY SCREEN .
  ENDLOOP.
  "Set Cursor Field.
  IF xsubcon_hdr-werks IS NOT INITIAL AND xsubcon_hdr-menge IS INITIAL
    AND xsubcon_hdr-text IS INITIAL .
    SET CURSOR FIELD 'XSUBCON_HDR-TEXT'.
  ELSEIF xsubcon_hdr-werks IS NOT INITIAL AND xsubcon_hdr-text IS NOT INITIAL
    AND xsubcon_hdr-menge IS INITIAL.
    SET CURSOR FIELD 'XSUBCON_HDR-MENGE'.
  ELSEIF xsubcon_hdr-menge IS NOT INITIAL AND xsubcon_hdr-sprice IS INITIAL.
    SET CURSOR FIELD 'XSUBCON_HDR-SPRICE'.
  ELSEIF xsubcon_hdr-chargean IS INITIAL AND xsubcon_hdr-menge IS NOT INITIAL .
    SET CURSOR FIELD 'XSUBCON_HDR-CHARGEAN' .
  ENDIF.
  IF xsubcon_hdr-waers IS INITIAL.
    xsubcon_hdr-waers = 'INR'.  "Currency
  ENDIF.
ENDMODULE.
