*&---------------------------------------------------------------------*
*& Include          ZMM_STOCK_REPORT_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN : BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001 .

*PARAMETERS : CAT RADIOBUTTON GROUP R1 USER-COMMAND GR1 DEFAULT 'X',
*             VEN RADIOBUTTON GROUP R1.
PARAMETERS : CATEGORY TYPE KLASSE_D OBLIGATORY.                ""MODIF ID GR2 ."OBLIGATORY.
SELECTION-SCREEN : END OF BLOCK B1 .
*
*SELECTION-SCREEN : BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002 .
*
*
*SELECTION-SCREEN : END OF BLOCK B2.

*AT SELECTION-SCREEN OUTPUT .
*BREAK-POINT.
*  IF cat = 'X'.
*    LOOP AT SCREEN .
*      IF SCREEN-GROUP1 = 'GR2'.
*        SCREEN-ACTIVE = 0.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

*  at SELECTION-SCREEN .
*      IF CATEGORY is INITIAL and ven = 'X'.
*    MESSAGE 'Enter Category' type 'E' .
*  ENDIF.
