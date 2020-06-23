*&---------------------------------------------------------------------*
*& Include          ZFI_VACCOUNT_DP_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
SELECT-OPTIONS   : s_lifnr FOR lfa1-lifnr NO-EXTENSION NO INTERVALS OBLIGATORY,
                   s_bukrs FOR bkpf-bukrs NO-EXTENSION NO INTERVALS OBLIGATORY,
                   s_bldat FOR bkpf-bldat OBLIGATORY,
                   s_belnr FOR bkpf-belnr NO-DISPLAY,
                   s_gjahr FOR bkpf-gjahr no-EXTENSION no INTERVALS,
                   s_gsber FOR bseg-gsber NO-EXTENSION NO INTERVALS OBLIGATORY.
SELECTION-SCREEN : END OF BLOCK b1.
