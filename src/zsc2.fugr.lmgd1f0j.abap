*&---------------------------------------------------------------------*
*&      Form  UPDATE_INFORECORD
*&---------------------------------------------------------------------*
*       Änderung der Bestellmengeneinheit im Infosatz                  *
*----------------------------------------------------------------------*
FORM UPDATE_INFORECORD TABLES CHNG_EINE_TAB STRUCTURE EINE    "cfo/1.2B3
                       USING EINA STRUCTURE EINA
                             O_EINA STRUCTURE EINA
                             EINE STRUCTURE EINE              "cfo/1.2B3
                             O_EINE STRUCTURE EINE            "cfo/1.2B3
                       CHANGING HSUBRC type sysubrc.
* cfo/4.0C wieder gelöscht
*                               EINE STRUCTURE EINE.          "cfo/4.0B
DATA: HMT06E LIKE MT06E,
      KZCHANGED LIKE RMMW3-EKAEND.
DATA: LV_EINE  LIKE EINE.
DATA: LV_MGEINE LIKE MGEINE.
DATA: LV_EINA  LIKE EINA.


  MOVE-CORRESPONDING MARA TO HMT06E.
  HMT06E-AUSME = MAW1-WAUSM.
  HMT06E-EKGRP = MAW1-WEKGR.
  HMT06E-BKLAS = MAW1-WBKLA.
  HMT06E-HERKL = MAW1-WHERL.
  HMT06E-HERKR = MAW1-WHERR.
  HMT06E-MAKTX = MAKT-MAKTX.

  CALL FUNCTION 'ME_MAINTAIN_INFORECORD'
       EXPORTING
            ACTIVITY                = 'U'
            I_EINA                  = EINA
            I_EINE                  = EINE                  "cfo/1.2B3
*           I_OKCODE                =
*           I_SCREEN                =
            O_EINA                  = O_EINA
            O_EINE                  = O_EINE                "cfo/1.2B3
            I_NO_SUPPOSE            = X
            I_NO_MATERIAL_READ      = X
            I_MT06E                 = HMT06E
            I_VORGA                 = 'A'  "integrierte Artikelpflege
       IMPORTING
            E_EINA                  = LV_EINA
* cfo/4.0C wieder gelöscht
            E_EINE                  = LV_EINE                  "cfo/4.0B
*           E_F11                   =
*           E_BRUTTO_NOT_NETTO      =
            E_DATA_HAS_BEEN_CHANGED = KZCHANGED
       TABLES                                               "cfo/1.2B3
            ET_EINE                 = CHNG_EINE_TAB         "cfo/1.2B3
       EXCEPTIONS
            ERROR_MESSAGE           = 1
            OTHERS                  = 2.
   HSUBRC = SY-SUBRC.
   IF SY-SUBRC NE 0.
     EXIT.
   ENDIF.
   IF NOT KZCHANGED IS INITIAL.
     RMMW3-EKAEND = KZCHANGED.
* Note 816113
     move-corresponding LV_eine to LV_MGeine.
     CALL FUNCTION 'EINA_E_SET_SUB'
         EXPORTING
              WMGEINE = LV_MGEINE
              WEINA   = LV_EINA
         EXCEPTIONS
              OTHERS  = 1.
            CALL FUNCTION 'EINA_E_SET_BILD'
           EXCEPTIONS
                OTHERS = 1.

   ENDIF.

ENDFORM.                    " UPDATE_INFORECORD
