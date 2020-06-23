FORM BATCH_DELETE_OBJECT TABLES INOBJ STRUCTURE KLARTINOB
                         USING  ECHTLAUF LIKE RMCLF-KREUZ
                                ANZAUSP  LIKE SYST-DBCNT.
*
DATA: SKLART   LIKE KSSK-KLART.
DATA: OBJEKID  LIKE CDHDR-OBJECTID.
*
DATA: BEGIN OF OBJID,
        OBJEK LIKE INOB-CUOBJ,
        MAFID LIKE RMCLDEL-MAFID.
DATA: END   OF OBJID.
*
DATA: BEGIN OF LKSSK OCCURS 0.
        INCLUDE STRUCTURE KSSK.
DATA: END   OF LKSSK.
*
DATA: BEGIN OF LAUSP OCCURS 0.
        INCLUDE STRUCTURE AUSP.
DATA: END   OF LAUSP.

*
* Löschen Zuordung
* 1. KSSK - Satz
  REFRESH LAUSP.
  LOOP AT IKSSK.
    APPEND IKSSK TO LKSSK.
* 2. alle AUSP - Sätze
    IF SKLART NE IKSSK-KLART.
      SKLART = IKSSK-KLART.
      CALL FUNCTION 'CLFM_SELECT_AUSP'
           EXPORTING
                MAFID        = IKSSK-MAFID
                CLASSTYPE    = IKSSK-KLART
                OBJECT       = IKSSK-OBJEK
                I_AENNR      = RMCLF-AENNR1
           TABLES
                EXP_AUSP     = LAUSP
           EXCEPTIONS
                NO_VALUES    = 01.
      DESCRIBE TABLE LAUSP LINES ANZAUSP.
      IF ANZAUSP NE 0.
        IF ECHTLAUF = KREUZ.
          DELETE AUSP FROM TABLE LAUSP.
          IF SYST-SUBRC NE 0.
            RAISE NOT_DELETED.
          ENDIF.
        ENDIF.
      ENDIF.
* Änderungsbelege löschen
      READ TABLE INOBJ WITH KEY IKSSK-KLART BINARY SEARCH.
      IF SYST-SUBRC = 0.
        IF INOBJ-AEBLG = KREUZ.
          OBJID-OBJEK = IKSSK-OBJEK.
          OBJID-MAFID = MAFIDO.
          OBJEKID = OBJID.
          CALL FUNCTION 'CHANGEDOCUMENT_DELETE'
               EXPORTING
                    OBJECTCLASS                 = 'CLASSIFY'
                    OBJECTID                    = OBJEKID
               EXCEPTIONS
                    NO_AUTHORITY                = 1
                    NO_CHANGES_FOUND            = 2
                    OTHERS                      = 3.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
* Massenlöschen
  DESCRIBE TABLE LKSSK LINES SYST-TFILL.
  IF SYST-TFILL NE 0.
    IF ECHTLAUF = KREUZ.
      DELETE KSSK FROM TABLE LKSSK.
      IF SYST-SUBRC NE 0.
        RAISE NOT_DELETED.
      ENDIF.
    ENDIF.
  ENDIF.
  DESCRIBE TABLE INOBJ LINES SYST-TFILL.
  IF SYST-TFILL NE 0.
    IF ECHTLAUF = KREUZ.
      LOOP AT INOBJ.
        DELETE FROM INOB
          WHERE CUOBJ = INOBJ-CUOBJ.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.