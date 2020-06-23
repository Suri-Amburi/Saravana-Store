*&---------------------------------------------------------------------*
*& Report ZLR_DATE_UPDATE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZLR_DATE_UPDATE.

SELECT * FROM ZINW_T_HDR INTO TABLE @DATA(LT_INW_H).

LOOP AT LT_INW_H ASSIGNING FIELD-SYMBOL(<LS_INW_H>).
  <LS_INW_H>-LR_DATE = <LS_INW_H>-BILL_DATE.
ENDLOOP.

MODIFY ZINW_T_HDR FROM TABLE LT_INW_H .
IF SY-SUBRC = 0.
  MESSAGE 'Success' TYPE 'S'.
ENDIF.
