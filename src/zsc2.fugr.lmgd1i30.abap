
*------------------------------------------------------------------
*  Module Marc-Ausme
*
* Die eingegebene Mengeneinheit muss gueltig sein (Tabelle 006). Sie
* muss ungleich der Basismengeneinheit sein.
* Es wird geprueft, ob die Mengeneinheit fuer dieses Material bereits
* definiert ist. Ist dies nicht der Fall wird ein Bild aufgeblendet,
* auf dem der Benutzer den Unrechnungsfaktor eingeben kann.
*
* ab 2.1B Prüfung, ob eine kaufmännische Einheit eingegeben wurde
*------------------------------------------------------------------
MODULE MARC-AUSME.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_AUSME'
       EXPORTING
            P_AKTYP           = T130M-AKTYP
            MARC_IN_AUSME     = MARC-AUSME
            RET_AUSME         = LMARC-AUSME
            MARA_IN_MEINS     = MARA-MEINS
            P_RM03M_REF_MATNR = RMMG1_REF-MATNR
            P_MESSAGE         = ' '
            Z_MARC_IN_PSTAT   = *MARC-PSTAT
            Z_MARC_IN_AUSME   = *MARC-AUSME
            MARA_IN_MATNR     = RMMG1-MATNR
            MARC_IN_WERKS     = RMMG1-WERKS
            OK_CODE           = RMMZU-OKCODE
            MARA_IN_KZWSM     = MARA-KZWSM
            MARA_ATTYP        = MARA-ATTYP                "note 2309145
       IMPORTING
            FLAG_BILDFOLGE    = RMMZU-BILDFOLGE
            P_RM03M_MEINH     = RMMZU-MEINH
            P_RM03M_UMREZ     = RMMZU-UMREZ
            P_RM03M_UMREN     = RMMZU-UMREN
            OK_CODE           = RMMZU-OKCODE
            HOKCODE           = RMMZU-HOKCODE
       TABLES
            MEINH             = MEINH
            Z_MEINH           = RMEINH
            DMEINH            = DMEINH.

  IF NOT RMMZU-BILDFOLGE IS INITIAL.
    BILDFLAG = X.
  ENDIF.

ENDMODULE.
