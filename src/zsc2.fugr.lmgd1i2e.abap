*------------------------------------------------------------------
*  Module MARC-MINBE.
*  Pruefung des Meldebestandes.
*------------------------------------------------------------------
MODULE MARC-MINBE.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_MINBE'
       EXPORTING
            P_MINBE          = MARC-MINBE
            P_EISBE          = MARC-EISBE
            P_KZ_NO_WARN     = ' '
            P_MABST          = MARC-MABST  " AHE: 06.11.97 (4.0a)
       EXCEPTIONS
            P_ERR_MARC_MINBE = 01.
  IF SY-SUBRC NE 0.
    BILDFLAG = X.
    RMMZU-CURS_FELD = 'MARC-EISBE'.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.
