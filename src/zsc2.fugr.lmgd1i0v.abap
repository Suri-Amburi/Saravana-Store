*  Module MARA-MATKL
*
* Änderungen der Warengruppe sind nur erlaubt, wenn keine Bestellungen,
* Lieferpläne oder Bestellanforderungen vorhanden sind (Warengruppe
* wird in diese Objekt unverändert übernommen)
* Modul läuft nur 'on request' ab
*------------------------------------------------------------------
MODULE MARA-MATKL.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARA_MATKL'
       EXPORTING
            P_NEUFLAG      = NEUFLAG
            P_MARA_MATKL   = MARA-MATKL
            P_Z_MARA_MATKL = *MARA-MATKL
            P_MESSAGE      = ' '
            P_AKTYP        = T130M-AKTYP  "ch zu 4.0
            WMARA          = MARA
       EXCEPTIONS                      "ch zu 4.0
            NO_AUTHORITY   = 01.       "ch zu 4.0
  IF SY-SUBRC NE 0.                    "ch zu 4.0
    MESSAGE E852 WITH MARA-MATKL.      "ch zu 4.0
  ENDIF.                               "ch zu 4.0
*----Warengruppen-Berechtigung-----------------------------------------
* IF NOT MARA-MATKL IS INITIAL.                "in FB MARA_MATKL
*   CALL FUNCTION 'T023_SINGLE_READ'           "verlagert      ch/4.0
*        EXPORTING
*             T023_MATKL = MARA-MATKL
*        IMPORTING
*             WT023      = T023
*        EXCEPTIONS
*             NOT_FOUND  = 01.
*   IF SY-SUBRC NE 0.
*     MESSAGE E852 WITH MARA-MATKL.
*   ENDIF.
*
*   IF NOT T023-BEGRU IS INITIAL.
*     CALL FUNCTION 'BEGRU_WGR_AUTHORITY_CHECK'
*          EXPORTING
*               AKTYP        = T130M-AKTYP
*               BEGRU        = T023-BEGRU
*          EXCEPTIONS
*               NO_AUTHORITY = 1.
*     IF SY-SUBRC NE 0.
*       MESSAGE E852 WITH MARA-MATKL.
*     ENDIF.
*   ENDIF.
* ENDIF.

ENDMODULE.
