*&---------------------------------------------------------------------*
*& Include          ZFI_IAP_OPENITEM_C07_SUB
*&---------------------------------------------------------------------*
PERFORM get_data     CHANGING i_exceltab.
PERFORM process_data1 USING    i_exceltab.
PERFORM errmsg       USING    i_errmsg.
