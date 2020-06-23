*&---------------------------------------------------------------------*
*& Include          ZFI_IGL_BALANCES_C01_SUB
*&---------------------------------------------------------------------*
PERFORM get_data     CHANGING i_exceltab.
PERFORM process_data USING    i_exceltab.
PERFORM errmsg       USING    i_errmsg.
