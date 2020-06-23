*------------------------------------------------------------------
* RM03M-VPMAT
*
* -Ein Vorplanungsmaterial darf nicht angegeben werden, wenn das
*  aktuelle Material bereits als Vorplanungsmaterial fungiert
* -Bei Änderung der Kombination Vorplanungsmatnr/-Werk wird folgendes
*  durchgeführt, wenn das Vorplanungsmaterial nicht initial ist:
*  - Zum neuen Vorplanungsmaterial/-Werk muß ein MARC-Satz vorhanden
*    sein, in diesem darf kein Vorplanungsmaterial/Werk eingetragen
*    sein (nur einstufige Verrechnung)
*  - das neue Vorplanungsmaterial/-Werk wird shared gesperrt, damit
*    diesem parallel kein weiteres Vorplanungsmaterial zugeordnet
*    werden kann
*  - war das bisherige Vorplanungsmaterial/-Werk bereits gesperrt,
*    wird die Sperre freigegeben
* -Bei Rücknahme der Vorplanungsdaten wird das bisherige Vorplanungs-
*  material/Werk freigegeben, falls es bereits gesperrt war
* -Wird zum Vorplanungsmaterial kein Werk eingegeben, so wird das
*  aktuelle Werk vorgeschlagen
* -Wird zum Vorplanungsmaterial kein Umrechnungsfaktor eingegeben, so
*  wird die Standard-Umrechnung zur BasisMe des Vorplanungsmaterials
*  vorgeschlagen, soweit ermittelbar, ansonsten der Wert 1
*------------------------------------------------------------------
MODULE RM03M-VPMAT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'RM03M_VPMAT'
       EXPORTING
            WMPGD                = MPGD
            P_AKTYP              = T130M-AKTYP
            P_NEUFLAG            = NEUFLAG
            P_MATNR              = RMMG1-MATNR
            P_WERKS              = RMMG1-WERKS
            P_MEINS              = MARA-MEINS
            P_LVPMAT             = LMPGD-PRGRP
            P_LVPWRK             = LMPGD-PRWRK
            P_LVPREF             = LMPGD-UMREF
            P_FLG_VP_SPERR       = RMMG2-VP_SPERR
            P_FLG_VP_EINSTUFIG_1 = RMMG2-VP_EINST
            P_KZ_NO_WARN         = ' '
       IMPORTING
            WMPGD                = MPGD
            P_VB_FLAG_PGDATA     = RMMG2-VB_PGDATA
            P_VPBME              = RMMZU-VPBME
            P_KZ_WMESS           = FLAG1
*           P_VPBME nur hier im Dialogfall zu benutzen ! (AHE)
            P_FLG_VP_SPERR       = RMMG2-VP_SPERR
            P_FLG_VP_EINSTUFIG_1 = RMMG2-VP_EINST.
*      EXCEPTIONS
*           P_ERR_RM03M_VPMAT = 01.

* Warnung muß außerhalb des FB erfolgen, da rmmzu-vpbme gleichzeitig
* aktualisiert wird                       mk/26.05.95
  IF NOT FLAG1 IS INITIAL.
    SET CURSOR FIELD 'MPGD-UMREF'.
    MESSAGE W580.
  ENDIF.

ENDMODULE.
