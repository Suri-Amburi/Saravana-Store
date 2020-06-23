*&---------------------------------------------------------------------*
*& Include          ZN_GSTR1_CREDIT_SR_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_budat FOR  bkpf-budat,
                s_bukrs FOR bseg-bukrs OBLIGATORY NO INTERVALS NO-EXTENSION DEFAULT '1000',
                pyear FOR bkpf-gjahr no INTERVALS no-EXTENSION OBLIGATORY,
                s_gsber FOR bseg-gsber.
SELECTION-SCREEN : END OF BLOCK b1.
