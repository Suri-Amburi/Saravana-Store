*------------------------------------------------------------------
*    Module MARA-VOLEH.
*Prüfen ob eine ( richtige ) Volumeneinheit angegeben wurde.
*------------------------------------------------------------------
MODULE MARA-VOLEH.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARA_VOLEH'
       EXPORTING
            VOLUM          = MARA-VOLUM
            VOLEH          = MARA-VOLEH
       EXCEPTIONS
            MISSING_VOLUME = 01
            WRONG_VOLUME   = 02.

  CASE SY-SUBRC.
    WHEN '01'.
      SET CURSOR FIELD 'MARA-VOLEH'.
      MESSAGE E092.
    WHEN '02'.
      SET CURSOR FIELD 'MARA-VOLEH'.
      MESSAGE E093 WITH MARA-VOLEH.
  ENDCASE.

ENDMODULE.
