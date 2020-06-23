*-----------------------------------------------------------------------
* Module MVKE-DWERK
* Vorschlagswerk für Kundenaufträge: das Werk muß in der T001W sein
* und die VKORG/WERKS-Kombin. in der TVKWZ (über Dictionary).
* Zusätzlich kommt eine Warnung, wenn das Material noch nicht in dem
* Werk angelegt ist.
*-----------------------------------------------------------------------
MODULE MVKE-DWERK.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MVKE_DWERK'
       EXPORTING
            WRMMG1_MATNR = RMMG1-MATNR
            WRMMG1_WERKS = RMMG1-WERKS
            WMVKE_DWERK  = MVKE-DWERK
            NEUFLAG      = NEUFLAG
* note 335437
            ATTYP        = MARA-ATTYP
            FLG_RETAIL   = RMMG2-FLG_RETAIL.

ENDMODULE.
