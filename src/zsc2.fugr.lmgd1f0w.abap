*&---------------------------------------------------------------------*
*&      Form  LESEN_TNTPB
*&---------------------------------------------------------------------*
*     Lesen der Tabelle TNTPB für die Texte zum EAN-Nummerierungstyp
*----------------------------------------------------------------------*
FORM LESEN_TNTPB USING SPRACHE type sylangu
                       NUMTP   type numtp.

  IF NOT ( TNTPB-SPRAS = SPRACHE ) OR
     NOT ( TNTPB-NUMTP = NUMTP   ).

* Select später ersetzen durch single_read. cfo/19.05.95
    CALL FUNCTION 'TNTPB_SINGLE_READ'
         EXPORTING
              TNTPB_SPRAS = SPRACHE
              TNTPB_NUMTP = NUMTP
         IMPORTING
              WTNTPB      = TNTPB
         EXCEPTIONS
              NOT_FOUND   = 01.
  ENDIF.

ENDFORM.                               " LESEN_TNTPB
