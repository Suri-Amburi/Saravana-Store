*------------------------------------------------------------------
*  Module MVKE-SCHME
*
* Die eingegebene Mengeneinheit muss gueltig sein (Tabelle 006). Wird
* keine eingegeben wird die Basismengeneinheit gesetzt.
* Es wird geprueft, ob die Mengeneinheit fuer dieses Material bereits
* definiert ist. Ist dies nicht der Fall wird ein Bild aufgeblendet,
* auf dem der Benutzer den Unrechnungsfaktor eingeben kann.
*------------------------------------------------------------------
MODULE MVKE-SCHME.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MVKE_SCHME'
       EXPORTING
            WMARA_MEINS      = MARA-MEINS
            WMVKE_SCHME      = MVKE-SCHME
* AHE: 21.02.99 - A (4.6a)
            WMARA_MATNR      = MARA-MATNR
* AHE: 21.02.99 - E
            WMARA_ATTYP      = MARA-ATTYP                    "BE/050696
            WMARA_SATNR      = MARA-SATNR                    "BE/050696
            WMVKE_VKORG      = MVKE-VKORG                    "BE/050696
            WMVKE_VTWEG      = MVKE-VTWEG                    "BE/050696
            WRMMG1_REF_MATNR = RMMG1_REF-MATNR
            WRMMZU           = RMMZU
            LMVKE_SCHME      = LMVKE-SCHME
            AKTYP            = T130M-AKTYP
            OK_CODE          = RMMZU-OKCODE
       IMPORTING
            WMVKE_SCHME      = MVKE-SCHME
            WRMMZU           = RMMZU
            FLAG_BILDFOLGE   = RMMZU-BILDFOLGE
            HOKCODE          = RMMZU-HOKCODE
            OK_CODE          = RMMZU-OKCODE
       TABLES
            MEINH            = MEINH
            Z_MEINH          = RMEINH
            DMEINH           = DMEINH.

  IF NOT RMMZU-BILDFOLGE IS INITIAL.
    BILDFLAG = X.                      "Popup 510: Umrechnungsfaktoren
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Aufruf der speziellen Eingabehilfe für MVKE-RDPRF
*&---------------------------------------------------------------------*
MODULE MVKE-RDPRF_HELP INPUT.

  PERFORM SET_DISPLAY.

  CALL FUNCTION 'MARC_RDPRF_HELP'
       EXPORTING WERK     = MVKE-DWERK
                 DISPLAY  = DISPLAY
                 NO_REFWK = X
       IMPORTING RDPRF   = MVKE-RDPRF.

ENDMODULE.                 " MVKE-RDPRF_HELP  INPUT

*&---------------------------------------------------------------------*
*&      Module  MVKE-RDPRF  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MVKE-RDPRF INPUT.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* Mißbrauch des EINE-Bausteins für MVKE, da selbe Funktionalität
  CALL FUNCTION 'EINE_RDPRF'
       EXPORTING
            WEINE_RDPRF = MVKE-RDPRF
            WEINE_WERKS = MVKE-DWERK.

ENDMODULE.                 " MVKE-RDPRF  INPUT
