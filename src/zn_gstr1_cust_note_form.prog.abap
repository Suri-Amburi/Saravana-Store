*&---------------------------------------------------------------------*
*& Include          ZN_GSTR1_CUST_NOTE_FORM
*&---------------------------------------------------------------------*

CLEAR:WA_KNA1,WA_MARA, WA_MARC,WA_MAKT,WA_VBAP,WA_FIN,WA_T604N.
  REFRESH:IT_KNA1,IT_MARA,IT_MARC,IT_MAKT,IT_FIN,IT_T604N.

  PERFORM SELECT_QUERRY.
  PERFORM GET_DATA.
  PERFORM FIELD_CATALOG.
  PERFORM DISPLAY_DATA.
