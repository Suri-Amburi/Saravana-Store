*------------------------------------------------------------------
*    Module MARA-MEABM.
*Prüfen ob eine Mengeneinheit angegeben wurde
*------------------------------------------------------------------
MODULE MARA-MEABM.

  CHECK BILDFLAG IS INITIAL.           "mk/21.04.95
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  IF ( ( NOT MARA-LAENG IS INITIAL ) OR ( NOT MARA-BREIT IS INITIAL )
    OR ( NOT MARA-HOEHE IS INITIAL ) )
      AND MARA-MEABM IS INITIAL.
    SET CURSOR FIELD 'MARA-MEABM'.
    MESSAGE E395.
  ENDIF.

  IF NOT MARA-MEABM IS INITIAL.
    CALL FUNCTION 'DIMENSIONCHECK_LENGTH'
         EXPORTING
              MEABM                = MARA-MEABM
         EXCEPTIONS
              DIMENSION_NOT_LENGTH = 01
              T006D_ENTRY_MISSING  = 02
              T006_ENTRY_MISSING   = 03.
    IF SY-SUBRC NE 0.
      SET CURSOR FIELD 'MARA-MEABM'.
      MESSAGE E396 WITH MARA-MEABM.
    ENDIF.
  ENDIF.

ENDMODULE.
