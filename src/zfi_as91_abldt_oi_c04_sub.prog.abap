*&---------------------------------------------------------------------*
*& Include          ZFI_AS91_ABLDT_OI_C04_SUB
*&---------------------------------------------------------------------*

PERFORM get_data     CHANGING i_exceltab.
PERFORM process_data USING    i_exceltab.
PERFORM errmsg       USING    i_errmsg.
