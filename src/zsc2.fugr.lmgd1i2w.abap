*------------------------------------------------------------------
*  Module MARC-DISLS.
*  Pruefung der Dispositionslosgröße.
*------------------------------------------------------------------
MODULE MARC-DISLS.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  check not rmmg1-werks is initial.                     "cfo/4.6B

  CALL FUNCTION 'MARC_DISLS'
       EXPORTING
            P_DISLS        = MARC-DISLS
            P_MTART        = RMMG1-MTART
            P_WERKS        = RMMG1-WERKS
            P_DISMM        = MARC-DISMM
            P_LDISLS       = LMARC-DISLS
            P_KZ_NO_WARN   = ' '
            P_MARC_PSTAT   = MARC-PSTAT
       IMPORTING
            WT439A         = T439A
            WV134W         = V134W
       TABLES
            P_PTAB         = PTAB
       EXCEPTIONS
            ERR_MARC_DISLS = 01
            ERR_T439A      = 02
            ERR_T134       = 03
            ERR_T438A      = 04.

  IF SY-SUBRC NE 0.
    BILDFLAG = X.
    RMMZU-CURS_FELD = 'MARC-DISLS'.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDMODULE.
