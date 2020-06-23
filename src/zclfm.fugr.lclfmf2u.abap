*------------------------------------------------------------------*
*        FORM HELP_F1_OBJEK                                        *
*------------------------------------------------------------------*
*        F1 auf den Feldern OBJEK und OBTXT in Dynpro 511          *
*------------------------------------------------------------------*
*
FORM HELP_F1_OBJEK.
*
  DATA: EXITFLAG.
  DATA: I            LIKE SYST-TABIX.
  DATA: S_TABLE      LIKE TCLA-OBTAB.
  DATA: OFFSFELDL    LIKE OFFSET.
  DATA: OFFSFELDH    LIKE OFFSET.
  DATA: TCLOFELD     LIKE HELP_INFO-FIELDNAME VALUE 'TCLO-KEYF '.
*

  GET CURSOR FIELD FNAME LINE ZEILE OFFSET OFFSET.
  CHECK SYST-SUBRC = 0.
  ZEILE = ZEILE + INDEX_NEU - 1.
  READ TABLE G_OBJ_INDX_TAB INDEX ZEILE.
  CHECK SYST-SUBRC = 0.
  READ TABLE KLASTAB INDEX G_OBJ_INDX_TAB-INDEX.
  CHECK SYST-SUBRC = 0.
  CASE FNAME.
    WHEN 'RMCLF-OBJEK'.
      IF KLASTAB-MAFID = MAFIDK.
        CALL FUNCTION 'HELP_DOCU_SHOW_FOR_FIELD'
             EXPORTING
                  FIELDNAME = 'CLASS'
                  TABNAME   = 'RMCLF'.
      ELSE.
        IF NOT MULTI_OBJ IS INITIAL.
          REFRESH LAENGTAB.
          S_TABLE     = KLASTAB-OBTAB.
        ELSE.
          S_TABLE     = SOBTAB.
        ENDIF.
        DESCRIBE TABLE LAENGTAB LINES SYST-TFILL.
        IF SYST-TFILL = 0.
          RMCLF-OBJEK = KLASTAB-OBJEK.
          CALL FUNCTION 'CLCV_CONVERT_OBJECT_TO_FIELDS'
               EXPORTING
                    TABLE      = S_TABLE
                    RMCLFSTRU  = RMCLF
                    LENGTHFLAG = KREUZ
               IMPORTING
                    ITCLO      = TCLO
               TABLES
                    LENGTHTAB  = LAENGTAB.
        ENDIF.
        LOOP AT LAENGTAB.
          OFFSFELDL = OFFSFELDH.
          OFFSFELDH = OFFSFELDH +  LAENGTAB-L.
          IF OFFSET GE OFFSFELDL AND OFFSET LT OFFSFELDH.
            EXITFLAG = KREUZ.
            I = SYST-TABIX - 1.
            EXIT.
          ENDIF.
          OFFSFELDH = OFFSFELDH + 1.
        ENDLOOP.
        IF EXITFLAG NE KREUZ.
          MESSAGE S730(SH).
          EXIT.
        ENDIF.
        CASE I.
          WHEN 0.
            TCLOFELD = TCLO-KEYF0.
          WHEN 1.
            TCLOFELD = TCLO-KEYF1.
          WHEN 2.
            TCLOFELD = TCLO-KEYF2.
          WHEN 3.
            TCLOFELD = TCLO-KEYF3.
          WHEN 4.
            TCLOFELD = TCLO-KEYF4.
          WHEN 5.
            TCLOFELD = TCLO-KEYF5.
          WHEN 6.
            TCLOFELD = TCLO-KEYF6.
          WHEN 7.
            TCLOFELD = TCLO-KEYF7.
          WHEN 8.
            TCLOFELD = TCLO-KEYF8.
          WHEN 9.
            TCLOFELD = TCLO-KEYF9.
        ENDCASE.
        CALL FUNCTION 'HELP_DOCU_SHOW_FOR_FIELD'
             EXPORTING
                  FIELDNAME = TCLOFELD
                  TABNAME   = 'RMCLF'.
      ENDIF.
    WHEN 'RMCLF-OBTXT'.
      IF KLASTAB-MAFID = MAFIDK.
        CALL FUNCTION 'HELP_DOCU_SHOW_FOR_FIELD'
             EXPORTING
                  FIELDNAME = 'KLTXT'
                  TABNAME   = 'RMCLF'.
      ENDIF.
  ENDCASE.
ENDFORM.
