*------------------------------------------------------------------
*           MARC-SSQSS
*Wenn Feld SSQSS eingegeben wird ---> FB TQ08_READ wird aufgerufen;
*Voraussetzung ist, daß SSQSS nicht initial ist oder geändert wurde.
*falls KZ ZEUGNIS_ERFORDERLICH sitzt ---> OZGTP ist Mußeingabe;
*
*falls KZ TECHN._LIEFERBEDG_ERFORDERLICH sitzt, wird geprüft, ob
*die entsprechenden Dokumentendaten vorhanden sind (->RM03M-KZTLB)
*------------------------------------------------------------------
MODULE MARC-SSQSS.

 CHECK BILDFLAG IS INITIAL.
 CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

 CALL FUNCTION 'MARC_SSQSS'
      EXPORTING
           P_MARC_SSQSS    = MARC-SSQSS
           P_MARA_QMPUR    = MARA-QMPUR
           P_MARC_WERKS   =  RMMG1-WERKS               "3.1I  BE/090398
           P_RM03M_KZTLB   = RMMG2-KZTLB
           BILDSEQUENZ     = BILDSEQUENZ
           FLAG_UEBERNAHME = ' '
           OK_CODE         = RMMZU-OKCODE
           P_AKTYP         = T130M-AKTYP                  "note 1550293
      IMPORTING
           OK_CODE         = RMMZU-OKCODE
      TABLES
           MPTAB           = PTAB.                        "note 1550293
*     EXCEPTIONS
*          ERROR_NACHRICHT = 01.
ENDMODULE.
