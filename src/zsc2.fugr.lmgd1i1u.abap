*------------------------------------------------------------------
*  Module MARC-XCHAR.
*
*  Setzen des Kz. Chargenführung, falls Chargenpflicht eingegeben wurde.
*  Weiterhin setzen des Kz.'Chargenführung prüfen/aktualisieren'
*   - falls beim Anlegen Chargenpflicht nicht gesetzt ist
*   - falls beim Ändern die Chargenpflicht zurückgenommen wurde
*   (im Verbucher wird in Abhängigkeit, ob getrennte Bewertung
*   vereinbart ist oder nicht, das Kz. Chargenführung gesetzt bzw.
*   zurückgenommen).
*------------------------------------------------------------------
MODULE MARC-XCHAR.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.           "mk/21.04.95

  CALL FUNCTION 'MARC_XCHAR'
       EXPORTING
            P_NEUFLAG          = NEUFLAG
            P_MARC_XCHPF       = MARC-XCHPF
            P_MARA_XCHPF       = MARA-XCHPF
            P_MARC_XCHAR       = MARC-XCHAR
            P_STERN_MARC_XCHPF = *MARC-XCHPF
            P_STERN_MARA_XCHPF = *MARA-XCHPF
            CHARGEN_EBENE      = RMMG2-CHARGEBENE
*           FLGXCHAR_CHPF      = FLGXCHAR_CHPF
* (del)     FLGXCHAR_CHPF      = RMMG2-XCHAR_CHPF  "ch 3.0D  "BE/071196
* (del)     KZMARA_XCHPF       = RMMG2-KZ_XCHPF_A            "BE/081196
       IMPORTING
*           FLGXCHAR_CHPF      = FLGXCHAR_CHPF
* (del)     FLGXCHAR_CHPF      = RMMG2-XCHAR_CHPF  "ch 3.0D  "BE/071196
* (del)     KZMARA_XCHPF       = RMMG2-KZ_XCHPF_A            "BE/081196
            P_MARC_XCHAR       = MARC-XCHAR.
* (del)     P_MARA_XCHPF       = MARA-XCHPF.                 "BE/130296

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  marc-uchkz  INPUT
*&---------------------------------------------------------------------*
*  TF 4.7 Ursprungscharge
*----------------------------------------------------------------------*
MODULE marc-uchkz INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'VBOB_MARC_OB_CHECK'
    EXPORTING
      i_aktyp                              = t130m-aktyp
      i_xchpf                              = marc-xchpf
      i_matnr                              = rmmg1-matnr
      i_werks                              = rmmg1-werks
      i_bwkey                              = rmmg1-bwkey
      i_uchkz                              = marc-uchkz
      i_ucmat                              = marc-ucmat.

ENDMODULE.                 " marc-uchkz  INPUT
