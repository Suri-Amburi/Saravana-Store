*&---------------------------------------------------------------------*
*& Include          ZSAPMP_MM41_SCREEN_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
* SET PF-STATUS 'ZSTATUS'.
* SET TITLEBAR 'xxx'.
*  BREAK BREDDY.
  DATA :Z1 TYPE MARA-ZZLABEL_DESC,
        Z2 TYPE MARA-ZZIVEND_DESC,
        Z3 TYPE MARA-ZZEMP_CODE,
        Z4 TYPE MARA-ZZEMP_PER,
        Z5 TYPE MARA-ZZRET_DAYS,
        Z6 TYPE MARA-ZZSTYLE.
  PERFORM DISABLE_FIELDS.
*  PERFORM GET_DATA.

*  IF SY-UCOMM EQ 'ZU12'.
*    IMPORT MARA-ZZLABEL_DESC  TO Z1 MARA-ZZIVEND_DESC TO Z2 MARA-ZZEMP_CODE TO Z3 MARA-ZZEMP_PER TO Z4 MARA-ZZRET_DAYS TO Z5 FROM MEMORY ID 'ZMARA'.
*
*    IF SY-SUBRC = 0.
*
**      MARA-ZZLABEL_DESC = Z1.
*      MARA-ZZIVEND_DESC = Z2.
*      MARA-ZZEMP_CODE = Z3.
*      MARA-ZZEMP_PER = Z4.
*      MARA-ZZRET_DAYS = Z5.
*
*    ENDIF.
*  ENDIF.
* ASSIGN ('(ZSAPMP_MM41_SCREEN)MARA-ZZLABEL_DESC') TO FIELD-SYMBOL(<LS_MARA>).
* IF <LS_MARA> IS ASSIGNED.

* ENDIF.

*  IF EXIT IS INITIAL.
*    CALL METHOD CL_EXITHANDLER=>GET_INSTANCE
*      CHANGING
*        INSTANCE = EXIT.
*  ENDIF.
*
*  CALL METHOD CL_EXITHANDLER=>SET_INSTANCE_FOR_SUBSCREEN
*    EXPORTING
*      INSTANCE = EXIT.

ENDMODULE.
