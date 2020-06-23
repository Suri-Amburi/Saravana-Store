*&---------------------------------------------------------------------*
*& Include          ZN_GSTR1_EXPORTS_FORM
*&---------------------------------------------------------------------*

START-OF-SELECTION.
 REFRESH:IT_VBRK,IT_VBRP,IT_KONV,IT_KNA1,IT_MARC,IT_MAKT,IT_VBPA,IT_VBFA,IT_LFA1,IT_MSEG,IT_BKPF,IT_BSEG.

  PERFORM SELECT_QUERRY.
  PERFORM GET_DATA.
  PERFORM DISPLAY_DATA.
  PERFORM FIELD_CATALOG.
