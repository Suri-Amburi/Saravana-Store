*&---------------------------------------------------------------------*
*& Include          SAPMZUNLOAD_NC_O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9001 OUTPUT.

  SET PF-STATUS 'PF_9001'.
  SET TITLEBAR 'TITLE_9001'.

  SHIFT aexidv LEFT DELETING LEADING '0' .

ENDMODULE .
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.

  SET PF-STATUS 'PF_9001'.
  SET TITLEBAR 'TITLE_9001'.

  SHIFT aexidv LEFT DELETING LEADING '0' .

  IF gs_ship IS INITIAL.
*    BREAK sjena.
*    PERFORM get_tdp_parameter.
*    IF asubrc IS NOT INITIAL.
*      aicon  = icon_red_light.
*      mesag1 = TEXT-007.
*      mesag2 = TEXT-008.
*      mesag3 = TEXT-009.
*      PERFORM call_message_screen.
*      LEAVE TO SCREEN 0.
*    ELSEIF ssubrc IS NOT INITIAL  .
*      aicon  = icon_red_light.
*      mesag1 = TEXT-010.
*      mesag2 = TEXT-008.
*      mesag3 = TEXT-009.
*      PERFORM call_message_screen.
*      LEAVE TO SCREEN 0.
*    ENDIF.
    PERFORM fetch_open_shipments.
    DESCRIBE TABLE xvttk LINES gv_line.
    gv_from = 1.
    gv_to = 7.

    LOOP AT xvttk FROM gv_from TO gv_to.
      IF sy-tabix EQ 1.
        gs_ship-1slnum = sy-tabix.
        gs_ship-1tknum = xvttk-tknum.
        gs_ship-1signi = xvttk-signi.
        gs_ship-2slnum = sy-tabix.
      ELSEIF sy-tabix EQ 2 .
        gs_ship-2slnum = sy-tabix.
        gs_ship-2tknum = xvttk-tknum.
        gs_ship-2signi = xvttk-signi.
      ELSEIF sy-tabix EQ 3.
        gs_ship-3slnum = sy-tabix.
        gs_ship-3tknum = xvttk-tknum.
        gs_ship-3signi = xvttk-signi.   " IF sy-tabix EQ 3.
      ELSEIF sy-tabix EQ 4.
        gs_ship-4slnum = sy-tabix.
        gs_ship-4tknum = xvttk-tknum.
        gs_ship-4signi = xvttk-signi.      " IF sy-tabix EQ 4.
      ELSEIF sy-tabix EQ 5.
        gs_ship-5slnum = sy-tabix.
        gs_ship-5tknum = xvttk-tknum.
        gs_ship-5signi = xvttk-signi.    " IF sy-tabix EQ 4.
      ELSEIF sy-tabix EQ 6.
        gs_ship-6slnum = sy-tabix.
        gs_ship-6tknum = xvttk-tknum.
        gs_ship-6signi = xvttk-signi.  " IF sy-tabix EQ 4.
      ELSEIF sy-tabix EQ 7.
        gs_ship-7slnum = sy-tabix.
        gs_ship-7tknum = xvttk-tknum.
        gs_ship-7signi = xvttk-signi.    " IF sy-tabix EQ 4.
      ENDIF .
      CLEAR : xvttk.
    ENDLOOP.

  ENDIF .
  SET CURSOR FIELD gv_sel.
ENDMODULE .
*&---------------------------------------------------------------------*
*& Include          ZLOADUNO01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9991 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9991 OUTPUT.

* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  IF xvttk IS INITIAL.

    PERFORM get_tdp_parameter.
    IF asubrc IS NOT INITIAL.
      aicon  = icon_red_light.
      mesag1 = TEXT-007.
      mesag2 = TEXT-008.
      mesag3 = TEXT-009.
      PERFORM call_message_screen.
      LEAVE TO SCREEN 0.
    ENDIF.

    PERFORM fetch_open_shipments.
    DESCRIBE TABLE xvttk LINES total.
    currp = 1.
    lastp = ceil( total DIV screen_no_shipments ).

    IF ( total MOD screen_no_shipments ) NE 0.
      lastp = lastp + 1.
    ENDIF.

    SORT xvttk BY tknum.

  ENDIF.

  IF xvttk[] IS INITIAL.
    aicon  = icon_red_light.
    mesag1 = TEXT-001.
    mesag2 = TEXT-002.
    PERFORM call_message_screen.
    LEAVE TO SCREEN 0.
  ENDIF.

  CLEAR tempa.
  DO screen_no_shipments TIMES.
    tempa = tempa + 1.
    CONCATENATE 'SPR' tempa INTO afield. CONDENSE afield NO-GAPS.
    UNASSIGN <afs>. ASSIGN (afield) TO <afs>. CLEAR <afs>.
    CONCATENATE 'SPN' tempa INTO afield. CONDENSE afield NO-GAPS.
    UNASSIGN <afs>. ASSIGN (afield) TO <afs>. CLEAR <afs>.
  ENDDO.

  CLEAR tempa.
  LOOP AT xvttk FROM ( ( ( currp - 1 ) * screen_no_shipments ) + 1 ) TO ( currp * screen_no_shipments ).
    tempa = tempa + 1.
    CONCATENATE 'SPN' tempa INTO afield. CONDENSE afield NO-GAPS.
    UNASSIGN <afs>. ASSIGN (afield) TO <afs>.
*    <AFS>+0(10)  = XVTTK-TKNUM.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = xvttk-tknum
      IMPORTING
        output = <afs>+0(10).
    <afs>+10(1)  = '-'.
    <afs>+11(20) = xvttk-signi.
  ENDLOOP.

  CLEAR tempa.
  DO screen_no_shipments TIMES.
    tempa = tempa + 1.
    CONCATENATE 'SPN' tempa INTO afield. CONDENSE afield NO-GAPS.
    UNASSIGN <afs>. ASSIGN (afield) TO <afs>.
    CHECK <afs> IS INITIAL.
    LOOP AT SCREEN.
      CONCATENATE 'SPR' tempa INTO afield. CONDENSE afield NO-GAPS.
      CHECK screen-name EQ afield.
      screen-active = 0.
      MODIFY SCREEN.
      EXIT.
    ENDLOOP.
  ENDDO.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_9992 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9992 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  CLEAR: aexidv, aucomm,mark.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  GET_OPEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_open_ship OUTPUT.


ENDMODULE .

*&---------------------------------------------------------------------*
*& Module NOTIFY_BELL_SIGNAL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE notify_bell_signal OUTPUT.
*  IF sy-ucomm <> 'OK_P'.
  notify_bell_signal = '9'.
*  ENDIF.
ENDMODULE.
