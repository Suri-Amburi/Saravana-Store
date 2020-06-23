*&---------------------------------------------------------------------*
*& Include          ZHR_ABSENT_REP_SEL
*&---------------------------------------------------------------------*


START-OF-SELECTION.
GET pernr.
*  rp-provide-from-last p0001  space pn-begda pn-endda.
*  rp-provide-from-last p0002 space pn-begda pn-endda.
*  rp-provide-from-last p0007 space pn-begda pn-endda.
PERFORM get_data.
PERFORM loop_data.
perform fieldcatalog.
PERFORM display_data.
