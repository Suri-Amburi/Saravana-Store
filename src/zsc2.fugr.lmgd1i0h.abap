*--------------------------------------------------------------------
*  Module BERECHTIGUNG_MATNR
*  Die Pflegeberechtigung für das Material wird geprüft
*--------------------------------------------------------------------
MODULE BERECHTIGUNG_MATNR.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

*----Material-Berechtigung generell------------------------------------
  IF NOT MARA-BEGRU IS INITIAL.        "in FB MARA_BEGRU
*   CALL FUNCTION 'BEGRU_MAT_AUTHORITY_CHECK'      "verlagert     ch/4.0
*        EXPORTING
*             AKTYP        = T130M-AKTYP
*             BEGRU        = MARA-BEGRU
*        EXCEPTIONS
*             NO_AUTHORITY = 1.
*   IF SY-SUBRC NE 0.
*     MESSAGE E849 WITH MARA-MATNR.
*   ENDIF.
*   Ab 4.0: Abhängig vom Customizing Wertetabelle prüfen     /ch
    CALL FUNCTION 'MARA_BEGRU'
         EXPORTING
              MARA_BEGRU     = MARA-BEGRU
              MARA_MATNR     = MARA-MATNR  "ch zu 4.0
              P_MESSAGE      = ' '
              AKTYP          = T130M-AKTYP  "ch zu 4.0
         EXCEPTIONS
              ERR_MARA_BEGRU = 1
              NO_AUTHORITY   = 2       "ch zu 4.0
              OTHERS         = 3.
    IF SY-SUBRC EQ 1.
*     MESSAGE E...(MM) WITH MARA-MATNR.   "noch nicht implementiert
    ENDIF.
    IF SY-SUBRC NE 0.                  "ch zu 4.0
      MESSAGE E849 WITH MARA-MATNR.    "ch zu 4.0
    ENDIF.                             "ch zu 4.0
  ENDIF.

ENDMODULE.
