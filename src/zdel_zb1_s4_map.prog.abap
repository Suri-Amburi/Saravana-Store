*&---------------------------------------------------------------------*
*& Report ZDEL_ZB1_S4_MAP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdel_zb1_s4_map.
DATA : sdel TYPE c.
BREAK-POINT .
CHECK SDEL IS NOT INITIAL.
DELETE FROM zb1_s4_map WHERE plant = space.

IF sy-subrc IS INITIAL.
  MESSAGE 'Records Deleted' TYPE 'S'.
ELSE.
  MESSAGE 'No Record found for deletion' TYPE 'E'.
ENDIF.
