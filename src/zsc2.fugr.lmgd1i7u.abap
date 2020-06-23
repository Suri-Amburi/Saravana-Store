*&---------------------------------------------------------------------*
*&  Include           LMGD1I7U                                         *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  MARA-RMATP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MARA-RMATP INPUT.
  CALL FUNCTION 'VHUPIMAT_CHECK_REFMATPI'
    EXPORTING
      IS_MARA                 = MARA
    EXCEPTIONS
      CHECK_FAILED            = 1
      OTHERS                  = 2
          .
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDMODULE.                 " MARA-RMATP  INPUT
