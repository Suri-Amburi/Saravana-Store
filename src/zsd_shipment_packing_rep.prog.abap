*&---------------------------------------------------------------------*
*& Report ZSD_SHIPMENT_PACKING_REP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT ZSD_SHIPMENT_PACKING_REP.
INCLUDE ZSD_SHIPMENT_PACKING_REP_TOP.
INCLUDE ZSD_SHIPMENT_PACKING_REP_sel.
INCLUDE ZSD_SHIPMENT_PACKING_REP_FORM.

START-OF-SELECTION.
PERFORM GET_DATA.
PERFORM LOOP_DATA.
PERFORM CAL_FUNC.
