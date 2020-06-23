*------------------------------------------------------------------
*  Module MARC-VRBMT
*
* Prüfungen zum Verbrauchs-Bezugsmaterial
* - Prüfung, ob die Daten vollständig eingegeben wurden
* - Prüfung, ob das Verbrauchsmaterial vorhanden ist
* - Prüfung, ob das Bezugsmaterial das gleiche Periodenkennzeichen/
*   Geschäftsjahresvariante hat wie das aktuelle Material
* - Warnung, falls das Verbrauchsmaterial eine andere Basis-ME hat
* Bem: Das Modul wird auch prozessiert, wenn sich das Periodenkennzei-
*      chen (MARC-PERKZ) oder die Geschäftsjahresvariante (MARC-PERIV)
*      geändert haben.
*------------------------------------------------------------------
MODULE MARC-VRBMT.
  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_VRBMT'
       EXPORTING
            P_MARA_MATNR   =  MARA-MATNR
            P_MARC_WERKS   =  MARC-WERKS
            MARC_VRBMT     =  MARC-VRBMT
            MARC_VRBWK     =  MARC-VRBWK
            MARC_VRBDT     =  MARC-VRBDT
            P_MARC_PERKZ   =  MARC-PERKZ
            MARC_PERIV     =  MARC-PERIV
            P_MARA_MEINS   =  MARA-MEINS
            P_KZ_NO_WARN   =  ' '
       CHANGING
            RET_VRBMT    =  LMARC-VRBMT
            RET_VRBWK    =  LMARC-VRBWK
            RET_VRBDT    =  LMARC-VRBDT
            RET_VRBFK    =  LMARC-VRBFK
            MARC_VRBFK   =  MARC-VRBFK
            ALTPERKZ     =  LMARC-PERKZ
            ALTPERIV     =  LMARC-PERIV
            P_KZ_WMESS   =  FLAG1
       EXCEPTIONS
*          error_vrbmt
            ERROR_VRBMT_EMESS.

  IF NOT FLAG1 IS INITIAL.             " Warnung muß außerhalb des
    SET CURSOR FIELD 'MARC-VRBFK'.     " FB erfolgen, da
    MESSAGE  W772.                     " 'MARC-VRBFK' gleichzeitig
  ENDIF.                               " aktualisiert wird

  IF NOT SY-SUBRC IS INITIAL.
    SET CURSOR FIELD 'MARC-PERKZ'.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO     "Message  e575
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDMODULE.
