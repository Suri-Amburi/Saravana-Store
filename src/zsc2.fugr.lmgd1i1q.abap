*------------------------------------------------------------------
* Module MARD-LSOBS                 neu zu 3.0     ch/02.10.95
*
* Prüfung des Sonderbeschaffungsschlüssels auf Lagerortebene
* - Bei Prozeßmaterialart ist die Eingabe nicht sinnvoll
* - Prf. ob BeschaffungsKz und SonderbeschaffungsKz zusammenpassen
* - Prf. ob Liefer- bzw. Produktionswerk vorhanden ist
* Korr zu 2.2E: Rekusivitätsprf. zum Umlagerungs-/Produktionswerk
*                                             " ch/25.04.95
*------------------------------------------------------------------
MODULE MARD-LSOBS.
  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
*      call function 'MARD_LSOBS'            einfügen

  CALL FUNCTION 'MARD_LSOBS'
       EXPORTING
            P_MARA_MATNR   = MARA-MATNR
            P_MARC_WERKS   = MARC-WERKS
            P_MARC_BESKZ   = MARC-BESKZ
            P_T134_KZPRC   = T134-KZPRC
            NEUFLAG        = NEUFLAG
            P_KZ_NO_WARN   = ' '
       CHANGING
            P_MARD_LSOBS   = MARD-LSOBS
       EXCEPTIONS
            ERR_MARD_LSOBS = 1
            OTHERS         = 2.



  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDMODULE.
