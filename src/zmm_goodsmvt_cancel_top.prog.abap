*&---------------------------------------------------------------------*
*& Include          ZMM_GOODSMVT_CANCEL_TOP
*&---------------------------------------------------------------------*

TABLES : MKPF.

TYPES: BEGIN OF TY_LOG,
         MBLNR TYPE MBLNR,
         MJAHR TYPE MJAHR,
         TEXT  TYPE CHAR200,
       END OF TY_LOG.

DATA : IT_LOG    TYPE STANDARD TABLE OF TY_LOG,
       WA_LAYOUT TYPE SLIS_LAYOUT_ALV,
       WA_FCAT   TYPE SLIS_FIELDCAT_ALV,
       IT_FCAT   TYPE SLIS_T_FIELDCAT_ALV.
