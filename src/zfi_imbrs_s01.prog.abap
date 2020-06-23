*&---------------------------------------------------------------------*
*& Include          ZFI_IMBRS_S01
*&---------------------------------------------------------------------*

DATA: lv_date TYPE zmbrs-posdat.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_bukrs  TYPE bukrs OBLIGATORY,
            p_hbkid  TYPE hbkid OBLIGATORY,
            p_hktid  TYPE hktid OBLIGATORY,
            p_monat  TYPE monat NO-DISPLAY,"OBLIGATORY,
            p_gjahr  TYPE gjahr OBLIGATORY,
            p_date   TYPE budat OBLIGATORY,
            p_amount TYPE char18.

*SELECT-OPTIONS: s_date FOR lv_date OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_hbkid.
  PERFORM f4_housebank.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_hktid.
  PERFORM f4_acctid.
