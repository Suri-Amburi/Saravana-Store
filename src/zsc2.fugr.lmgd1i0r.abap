*-----------------------------------------------------------------------
*  Module MARA-SPART
* Verprobung gegen die Entitätentabelle TSPA übers Dictionary.
* Ein Ändern der Sparte wird nur zugelassen, wenn dadurch keine
* ungültigen VKORG/VTWEG/SPARTE-Kombinationen entstehen (Tab. TVTA).
* Der Text zur Sparte wird im PBO-Modul MARA-SPART gelesen, in diesem
* Modul wird auch das Feld RET_SPART gesetzt.
* Achtung: das Modul wurde zu 3.0 deaktiviert (-> Int.Pr. 157223)
*          ch/14.11.94
*-----------------------------------------------------------------------
MODULE MARA-SPART.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARA_SPART'
       EXPORTING
            WMARA        = MARA
            VKORG        = RMMG1-VKORG
            VTWEG        = RMMG1-VTWEG
            LMARA        = LMARA
            AKTYP        = T130M-AKTYP
            P_KZ_NO_WARN = ' '             "JB/4.6B
       IMPORTING
            WMARA = MARA.

ENDMODULE.
