* AHE: 12.05.98 - A (4.0c)
*&---------------------------------------------------------------------*
*&      Module  MLGT-LGPLA  INPUT
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE MLGT-LGPLA INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CLEAR TMESSAGE. REFRESH TMESSAGE.

  CALL FUNCTION 'L_MAT_CHECK_FIXED_BIN'
       EXPORTING
            I_MATNR     = MLGT-MATNR
            I_LGNUM     = MLGT-LGNUM
            I_LGTYP     = MLGT-LGTYP
            I_OLD_LGPLA = LMLGT-LGPLA
            I_NEW_LGPLA = MLGT-LGPLA
       TABLES
            E_MATMESS   = TMESSAGE.

  LOOP AT TMESSAGE.
    IF TMESSAGE-MSGTY = MESSAGE_ERROR.
      BILDFLAG = X.
      TMESSAGE-MSGTY = MESSAGE_WARN.
    ENDIF.
    MESSAGE ID TMESSAGE-MSGID TYPE TMESSAGE-MSGTY
             NUMBER TMESSAGE-MSGNO
             WITH TMESSAGE-MSGV1 TMESSAGE-MSGV2
                  TMESSAGE-MSGV3 TMESSAGE-MSGV4.
  ENDLOOP.

ENDMODULE.                 " MLGT-LGPLA  INPUT
