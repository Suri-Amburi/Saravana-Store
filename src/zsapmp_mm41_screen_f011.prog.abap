*&---------------------------------------------------------------------*
*& Include          ZSAPMP_MM41_SCREEN_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form DISABLE_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISABLE_FIELDS .

  IF sy-tcode = 'MM03'.

    LOOP AT SCREEN.

      SCREEN-INPUT = '0'.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

ENDFORM.
