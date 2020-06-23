*&---------------------------------------------------------------------*
*& Include          SAPMZUNLOAD_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9001 OUTPUT.

  SET PF-STATUS 'PF_9001'.
  SET TITLEBAR 'TITLE_9001'.

  SHIFT AEXIDV LEFT DELETING LEADING '0' .

ENDMODULE .
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.

  SET PF-STATUS 'PF_9001'.
  SET TITLEBAR 'TITLE_9001'.

  SHIFT AEXIDV LEFT DELETING LEADING '0' .

  IF GS_SHIP IS INITIAL.
*******user parameters for shipping point*********************
*    BREAK sjena
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
    PERFORM FETCH_OPEN_SHIPMENTS.
    DESCRIBE TABLE XVTTK LINES GV_LINE.
    GV_FROM = 1.
    GV_TO = 7.

    LOOP AT XVTTK FROM GV_FROM TO GV_TO.
      IF SY-TABIX EQ 1.
        GS_SHIP-1SLNUM = SY-TABIX.
        GS_SHIP-1TKNUM = XVTTK-TKNUM.
        GS_SHIP-1SIGNI = XVTTK-SIGNI.
        GS_SHIP-2SLNUM = SY-TABIX.
      ELSEIF SY-TABIX EQ 2 .
        GS_SHIP-2SLNUM = SY-TABIX.
        GS_SHIP-2TKNUM = XVTTK-TKNUM.
        GS_SHIP-2SIGNI = XVTTK-SIGNI.
      ELSEIF SY-TABIX EQ 3.
        GS_SHIP-3SLNUM = SY-TABIX.
        GS_SHIP-3TKNUM = XVTTK-TKNUM.
        GS_SHIP-3SIGNI = XVTTK-SIGNI.   " IF sy-tabix EQ 3.
      ELSEIF SY-TABIX EQ 4.
        GS_SHIP-4SLNUM = SY-TABIX.
        GS_SHIP-4TKNUM = XVTTK-TKNUM.
        GS_SHIP-4SIGNI = XVTTK-SIGNI.      " IF sy-tabix EQ 4.
      ELSEIF SY-TABIX EQ 5.
        GS_SHIP-5SLNUM = SY-TABIX.
        GS_SHIP-5TKNUM = XVTTK-TKNUM.
        GS_SHIP-5SIGNI = XVTTK-SIGNI.    " IF sy-tabix EQ 4.
      ELSEIF SY-TABIX EQ 6.
        GS_SHIP-6SLNUM = SY-TABIX.
        GS_SHIP-6TKNUM = XVTTK-TKNUM.
        GS_SHIP-6SIGNI = XVTTK-SIGNI.  " IF sy-tabix EQ 4.
      ELSEIF SY-TABIX EQ 7.
        GS_SHIP-7SLNUM = SY-TABIX.
        GS_SHIP-7TKNUM = XVTTK-TKNUM.
        GS_SHIP-7SIGNI = XVTTK-SIGNI.    " IF sy-tabix EQ 4.
      ENDIF .
      CLEAR : XVTTK.
    ENDLOOP.

  ENDIF .
  SET CURSOR FIELD GV_SEL.
ENDMODULE .
*&---------------------------------------------------------------------*
*& Include          ZLOADUNO01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9991 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9991 OUTPUT.

* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  IF XVTTK IS INITIAL.

    PERFORM GET_TDP_PARAMETER.
    IF ASUBRC IS NOT INITIAL.
      AICON  = ICON_RED_LIGHT.
      MESAG1 = TEXT-007.
      MESAG2 = TEXT-008.
      MESAG3 = TEXT-009.
      PERFORM CALL_MESSAGE_SCREEN.
      LEAVE TO SCREEN 0.
    ENDIF.

    PERFORM FETCH_OPEN_SHIPMENTS.
    DESCRIBE TABLE XVTTK LINES TOTAL.
    CURRP = 1.
    LASTP = CEIL( TOTAL DIV SCREEN_NO_SHIPMENTS ).

    IF ( TOTAL MOD SCREEN_NO_SHIPMENTS ) NE 0.
      LASTP = LASTP + 1.
    ENDIF.

    SORT XVTTK BY TKNUM.

  ENDIF.

  IF XVTTK[] IS INITIAL.
    AICON  = ICON_RED_LIGHT.
    MESAG1 = TEXT-001.
    MESAG2 = TEXT-002.
    PERFORM CALL_MESSAGE_SCREEN.
    LEAVE TO SCREEN 0.
  ENDIF.

  CLEAR TEMPA.
  DO SCREEN_NO_SHIPMENTS TIMES.
    TEMPA = TEMPA + 1.
    CONCATENATE 'SPR' TEMPA INTO AFIELD. CONDENSE AFIELD NO-GAPS.
    UNASSIGN <AFS>. ASSIGN (AFIELD) TO <AFS>. CLEAR <AFS>.
    CONCATENATE 'SPN' TEMPA INTO AFIELD. CONDENSE AFIELD NO-GAPS.
    UNASSIGN <AFS>. ASSIGN (AFIELD) TO <AFS>. CLEAR <AFS>.
  ENDDO.

  CLEAR TEMPA.
  LOOP AT XVTTK FROM ( ( ( CURRP - 1 ) * SCREEN_NO_SHIPMENTS ) + 1 ) TO ( CURRP * SCREEN_NO_SHIPMENTS ).
    TEMPA = TEMPA + 1.
    CONCATENATE 'SPN' TEMPA INTO AFIELD. CONDENSE AFIELD NO-GAPS.
    UNASSIGN <AFS>. ASSIGN (AFIELD) TO <AFS>.
*    <AFS>+0(10)  = XVTTK-TKNUM.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = XVTTK-TKNUM
      IMPORTING
        OUTPUT = <AFS>+0(10).
    <AFS>+10(1)  = '-'.
    <AFS>+11(20) = XVTTK-SIGNI.
  ENDLOOP.

  CLEAR TEMPA.
  DO SCREEN_NO_SHIPMENTS TIMES.
    TEMPA = TEMPA + 1.
    CONCATENATE 'SPN' TEMPA INTO AFIELD. CONDENSE AFIELD NO-GAPS.
    UNASSIGN <AFS>. ASSIGN (AFIELD) TO <AFS>.
    CHECK <AFS> IS INITIAL.
    LOOP AT SCREEN.
      CONCATENATE 'SPR' TEMPA INTO AFIELD. CONDENSE AFIELD NO-GAPS.
      CHECK SCREEN-NAME EQ AFIELD.
      SCREEN-ACTIVE = 0.
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
MODULE STATUS_9992 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  CLEAR: AEXIDV, AUCOMM,MARK.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  GET_OPEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_OPEN_SHIP OUTPUT.


ENDMODULE .

*&---------------------------------------------------------------------*
*& Module NOTIFY_BELL_SIGNAL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE NOTIFY_BELL_SIGNAL OUTPUT.
*  IF sy-ucomm <> 'OK_P'.
  NOTIFY_BELL_SIGNAL = '9'.
*  ENDIF.
ENDMODULE.
