*&---------------------------------------------------------------------*
*& Report ZZZ_TEST_BM_UPLOAD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZZZ_TEST_BM_UPLOAD.

DATA : GV_MATNR TYPE MATNR.
SELECT-OPTIONS : S_MATNR FOR GV_MATNR NO INTERVALS.

LOOP AT S_MATNR.

  UPDATE MARC SET xchar = 'X'
                  xchpf = 'X'
              WHERE matnr = S_MATNR-LOW.
  CLEAR S_MATNR-LOW.
ENDLOOP.
