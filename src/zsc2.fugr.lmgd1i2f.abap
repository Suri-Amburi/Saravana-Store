*------------------------------------------------------------------
*  Module MARC-MABST.
*  Beim Verfahren 'Höchstbestand' muß das Feld gefüllt sein.
*------------------------------------------------------------------
MODULE MARC-MABST.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_MABST'
       EXPORTING
            P_DISLS      = MARC-DISLS
            P_MABST      = MARC-MABST
            P_MINBE      = MARC-MINBE
            P_LMABST     = LMARC-MABST "AHE: 14.01.98(4.0c) HW 92663
            P_LMINBE     = LMARC-MINBE "AHE: 14.01.98(4.0c) HW 92663
            P_DISPR      = MARC-DISPR
            P_KZ_NO_WARN = ' '
            P_EISBE      = MARC-EISBE  " AHE: 06.11.97 (4.0a)
            P_LDISLS     = LMARC-DISLS
       IMPORTING
            P_MABST      = MARC-MABST.
*      EXCEPTIONS
*           P_ERR_MARC_MABST = 01
*           ERR_T439A        = 02.

ENDMODULE.
