*&---------------------------------------------------------------------*
*& Include          ZSAP_DEBITNOTEO01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
 SET PF-STATUS 'ZSTATUS'.
 SET TITLEBAR 'T9000'.

 IF grid is BOUND.
   CALL METHOD GRID->REGISTER_EDIT_EVENT
     EXPORTING
       I_EVENT_ID =   CL_GUI_ALV_GRID=>MC_EVT_MODIFIED .  " Event ID
*     EXCEPTIONS
*       ERROR      = 1
*       OTHERS     = 2
     .
   IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.
  ENDIF.
ENDMODULE.
