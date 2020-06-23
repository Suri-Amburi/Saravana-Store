*&---------------------------------------------------------------------*
*& Include          ZSST_MM_R_APPR_PR_BDC
*&---------------------------------------------------------------------*


*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  IF FVAL IS NOT INITIAL.
    CLEAR BDCDATA.
    BDCDATA-FNAM = FNAM.
    BDCDATA-FVAL = FVAL.
    SHIFT BDCDATA-FVAL LEFT DELETING LEADING SPACE. " Added by Suri : 22.10.2019
    APPEND BDCDATA.
  ENDIF.
ENDFORM.


FORM VK12_PA2 USING WORD TYPE CHAR4.
  " VEN_NO TYPE A502-LIFNR
  "MAT_NO TYPE MARA-MATNR
  "NEW_SP TYPE KONP-KBETR.
  BREAK KKRITI .
  CONCATENATE SY-DATUM+6(2) '.' SY-DATUM+4(2) '.' SY-DATUM(4) INTO DATE.
  LOOP AT IT_FIN INTO WA_FIN.
    READ TABLE IT_VENDOR INTO WA_VENDOR WITH KEY MATNR = WA_FIN-MATNR.
    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '0100'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RV13A-KSCHL'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'RV13A-KSCHL'
                                    WORD .  " record-KSCHL_001.
    PERFORM BDC_DYNPRO      USING 'SAPLV14A' '0100'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RV130-SELKZ(05)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=WEIT'.
    PERFORM BDC_FIELD       USING 'RV130-SELKZ(01)'
                                    ' ' ." record-SELKZ_01_002.
    PERFORM BDC_FIELD       USING 'RV130-SELKZ(05)'
                                   'X' . "record-SELKZ_05_003.
    PERFORM BDC_DYNPRO      USING 'RV13A502' '1000'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'F002-LOW'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'F001'
                                    WA_VENDOR-LIFNR ."record-F001_004.
    PERFORM BDC_FIELD       USING 'F002-LOW'
                                   WA_FIN-MATNR . "record-LOW_005.
    PERFORM BDC_FIELD       USING 'SEL_DATE'
                                    DATE.  " record-SEL_DATE_006.
    PERFORM BDC_DYNPRO      USING 'RV13A502' '1000'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'F002-LOW'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=ONLI'.
    PERFORM BDC_FIELD       USING 'F001'
                                     WA_VENDOR-LIFNR ." record-F001_007.
    PERFORM BDC_FIELD       USING 'F002-LOW'
                                    WA_FIN-MATNR . "record-LOW_008.
    PERFORM BDC_FIELD       USING 'SEL_DATE'
                                     DATE. "record-SEL_DATE_009.
    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1502'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RV13A-DATAB(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'KONP-KBETR(01)'
                                    WA_FIN-NEW_SP .  "record-KBETR_01_010.
    PERFORM BDC_FIELD       USING 'RV13A-DATAB(01)'
                                   DATE . "record-DATAB_01_011.
    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1502'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RV13A-DATAB(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=SICH'.
    PERFORM BDC_TRANSACTION USING 'VK12'.
    CLEAR : WA_FIN.
  ENDLOOP.



ENDFORM.

FORM VK12_PA3 USING WORD TYPE CHAR4.
  CLEAR DATE.
  CONCATENATE SY-DATUM+6(2) '.' SY-DATUM+4(2) '.' SY-DATUM(4) INTO DATE.

  LOOP AT IT_FIN INTO WA_FIN.
    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '0100'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
    PERFORM BDC_FIELD       USING 'RV13A-KSCHL'
                                WORD.
    PERFORM BDC_DYNPRO      USING 'RV13A515' '1000'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'F001-LOW'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
    PERFORM BDC_FIELD       USING 'F001-LOW'
                                WA_FIN-MATNR.
    PERFORM BDC_FIELD       USING 'SEL_DATE'
                                DATE.
    PERFORM BDC_DYNPRO      USING 'RV13A515' '1000'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'F001-LOW'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=ONLI'.
    PERFORM BDC_FIELD       USING 'F001-LOW'
                                WA_FIN-MATNR.
    PERFORM BDC_FIELD       USING 'SEL_DATE'
                                DATE.
    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1515'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RV13A-DATAB(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
    PERFORM BDC_FIELD       USING 'KONP-KBETR(01)'
                                WA_FIN-NEW_MRP.
    PERFORM BDC_FIELD       USING 'RV13A-DATAB(01)'
                                DATE.
    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1515'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RV13A-DATAB(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=SICH'.
    PERFORM BDC_TRANSACTION USING 'VK12'.

    CLEAR : WA_FIN.
  ENDLOOP.

ENDFORM.

FORM VK12_MEK2 USING WORD TYPE CHAR4.
  CLEAR DATE.
  CONCATENATE SY-DATUM+6(2) '.' SY-DATUM+4(2) '.' SY-DATUM(4) INTO DATE.

  LOOP AT IT_FIN INTO WA_FIN.
    READ TABLE IT_VENDOR INTO WA_VENDOR WITH KEY MATNR = WA_FIN-MATNR.
    IF WA_VENDOR-LIFNR IS NOT INITIAL.
      PERFORM BDC_DYNPRO      USING 'SAPMV13A' '0100'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RV13A-KSCHL'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
      PERFORM BDC_FIELD       USING 'RV13A-KSCHL'
                              WORD."record-KSCHL_001.
      PERFORM BDC_DYNPRO      USING 'SAPLV14A' '0100'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RV130-SELKZ(05)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=WEIT'.
      PERFORM BDC_FIELD       USING 'RV130-SELKZ(01)'
                              ' ' . "record-SELKZ_01_002.
      PERFORM BDC_FIELD       USING 'RV130-SELKZ(05)'
                              'X'."record-SELKZ_05_003.
      PERFORM BDC_DYNPRO      USING 'RV13A502' '1000'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'F002-LOW'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=ONLI'.
      PERFORM BDC_FIELD       USING 'F001'
                              WA_VENDOR-LIFNR.
      PERFORM BDC_FIELD       USING 'F002-LOW'
                              WA_FIN-MATNR."record-LOW_005.
      PERFORM BDC_FIELD       USING 'SEL_DATE'
                             DATE." record-SEL_DATE_006.
      PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1502'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RV13A-DATAB(01)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
      PERFORM BDC_FIELD       USING 'KONP-KBETR(01)'
                              WA_FIN-NEW_TAX."record-KBETR_01_007.
      PERFORM BDC_FIELD       USING 'RV13A-DATAB(01)'
                              DATE."record-DATAB_01_008.
      PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1502'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RV13A-DATAB(01)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=SICH'.
      PERFORM BDC_TRANSACTION USING 'MEK2'.
    ENDIF.
    CLEAR : WA_FIN.
  ENDLOOP.

ENDFORM.

FORM VK12_PA1 USING WORD TYPE CHAR4.
  CLEAR DATE.
  CONCATENATE SY-DATUM+6(2) '.' SY-DATUM+4(2) '.' SY-DATUM(4) INTO DATE.
  LOOP AT IT_FIN INTO WA_FIN.
    READ TABLE IT_PA1 INTO WA_PA1 WITH KEY MATNR = WA_FIN-MATNR.
    IF WA_PA1-EAN11 IS NOT INITIAL.
      PERFORM BDC_DYNPRO      USING 'SAPMV13A' '0100'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RV13A-KSCHL'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
      PERFORM BDC_FIELD       USING 'RV13A-KSCHL'
                              WORD."record-KSCHL_001.
      PERFORM BDC_DYNPRO      USING 'SAPLV14A' '0100'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RV130-SELKZ(04)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=WEIT'.
      PERFORM BDC_FIELD       USING 'RV130-SELKZ(01)'
                              ' ' ."record-SELKZ_01_002.
      PERFORM BDC_FIELD       USING 'RV130-SELKZ(04)'
                              'X'."record-SELKZ_04_003.
      PERFORM BDC_DYNPRO      USING 'RV13A516' '1000'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'F001-LOW'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=ONLI'.
      PERFORM BDC_FIELD       USING 'F001-LOW'
                              WA_FIN-MATNR."record-LOW_004.
      PERFORM BDC_FIELD       USING 'F002-LOW'
                              WA_PA1-EAN11."record-LOW_005.
      PERFORM BDC_FIELD       USING 'SEL_DATE'
                              DATE."record-SEL_DATE_006.
      PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1516'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RV13A-DATAB(01)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
      PERFORM BDC_FIELD       USING 'KONP-KBETR(01)'
                              WA_FIN-NEW_SP."record-KBETR_01_007.
      PERFORM BDC_FIELD       USING 'RV13A-DATAB(01)'
                              DATE."record-DATAB_01_008.
      PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1516'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RV13A-DATAB(01)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=SICH'.
      PERFORM BDC_TRANSACTION USING 'VK12'.
    ENDIF.
    CLEAR : WA_FIN.
  ENDLOOP.

ENDFORM.

FORM BDC_TRANSACTION USING WORD TYPE CHAR4.
  BREAK SAMBURI.
  REFRESH: IT_MESSTAB.
  CALL TRANSACTION WORD USING BDCDATA
                      MODE   CTUMODE
                      UPDATE CUPDATE
                      MESSAGES INTO IT_MESSTAB.

  REFRESH BDCDATA.
  READ TABLE IT_MESSTAB INTO  WA_MESSTAB WITH KEY MSGTYP = 'E'.
  IF SY-SUBRC = 0.
    LOOP AT IT_MESSTAB INTO WA_MESSTAB.

      CALL FUNCTION 'FORMAT_MESSAGE'
        EXPORTING
          ID        = WA_MESSTAB-MSGID
          LANG      = '-D'
          NO        = WA_MESSTAB-MSGNR
          V1        = WA_MESSTAB-MSGV1
          V2        = WA_MESSTAB-MSGV2
          V3        = WA_MESSTAB-MSGV3
          V4        = WA_MESSTAB-MSGV4
        IMPORTING
          MSG       = WA_DISPLAY-MESSAGE
        EXCEPTIONS
          NOT_FOUND = 1
          OTHERS    = 2.

      WA_DISPLAY-TYPE     = WA_MESSTAB-MSGTYP.
      WA_DISPLAY-MESSAGE   = WA_MESSTAB-MSGV1.

      APPEND WA_DISPLAY TO IT_DISPLAY.
      CLEAR WA_DISPLAY.
    ENDLOOP.
  ELSE .
    WA_DISPLAY-TYPE     = 'S'.
    WA_DISPLAY-MESSAGE  = 'SUCCESSFULLY UPDATED' .

  ENDIF.
  APPEND WA_DISPLAY TO IT_DISPLAY.
  CLEAR WA_DISPLAY.
  WAIT UP TO 1 SECONDS.
ENDFORM.
