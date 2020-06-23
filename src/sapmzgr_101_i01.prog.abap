*&---------------------------------------------------------------------*
*& Include          SAPMZGR_101_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  UPDATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update INPUT.
BREAK PPADHY.
  SELECT SINGLE mblnr bwart FROM mseg INTO ( gv_mblnr , gv_bwart ) WHERE mblnr = lv_gr AND bwart IN ( c_101 , c_303 , c_109 ).

**  IF gv_bwart = '101' OR gv_bwart ='109'.
**    DATA(lv_plant) = lv_to.
**  ELSEIF gv_bwart = '303'.
**    lv_to = lv_plant.
**  ENDIF.

  IF lv_gr <> gv_mblnr.
    MESSAGE 'Enter a Valid GR' TYPE 'E'.
  ELSEIF gv_bwart = c_101 OR gv_bwart = c_109.
    IF it_item IS INITIAL.
      PERFORM get_101.
    ENDIF.
  ELSEIF  gv_bwart = c_303.
    IF it_item IS INITIAL.
      PERFORM get_303.
    ENDIF.

  ENDIF.

ENDMODULE.
