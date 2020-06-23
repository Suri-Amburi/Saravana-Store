*&---------------------------------------------------------------------*
*& Report ZMM_MARA_MARC_BATCH
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_mara_marc_batch.


DATA: lv_matnr TYPE mara-matnr.
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS : s_matnr FOR lv_matnr.

SELECTION-SCREEN: END OF BLOCK b1.

SELECT
  marc~matnr,
  marc~xchar,
  mara~xchpf
  FROM mara AS mara
  INNER JOIN marc AS marc ON mara~matnr = marc~matnr
  WHERE mara~matnr IN @s_matnr INTO TABLE @DATA(it_mara).

LOOP AT it_mara INTO DATA(wa_mara).

  UPDATE marc SET xchar = ' ' WHERE matnr = wa_mara-matnr.
  UPDATE mara SET xchpf = ' ' WHERE matnr = wa_mara-matnr.

ENDLOOP.
