*&---------------------------------------------------------------------*
*& Include          ZHR_I6789_INFOTYPE_CNV_ROU
*&---------------------------------------------------------------------*

PERFORM get_data.

IF it_0006[] IS NOT INITIAL.
  PERFORM process_it6_data USING it_0006.
ELSEIF it_0007[] IS NOT INITIAL.
  PERFORM process_it7_data USING it_0007.
ELSEIF it_0008[] IS NOT INITIAL.
  PERFORM process_it8_data USING it_0008.
ELSEIF it_0009[] IS NOT INITIAL.
  PERFORM process_it9_data USING it_0009.
ENDIF.
PERFORM display_data.
