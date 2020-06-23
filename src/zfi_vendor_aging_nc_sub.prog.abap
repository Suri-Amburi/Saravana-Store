*&---------------------------------------------------------------------*
*& Include          ZFI_VENDOR_AGING_NC_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZFI_VENDOR_AGING_NC_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form VALIDATE_VENDOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VALIDATE_VENDOR .

  SELECT SINGLE LIFNR FROM LFA1 INTO  GV_LIFNR WHERE LIFNR IN S_LIFNR.

  IF SY-SUBRC <> 0.
    MESSAGE E006(ZVENDOR).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_GJAHR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VALIDATE_GJAHR .

  DATA : LV_GJAHR TYPE GJAHR.

  LV_GJAHR = SY-DATUM+0(4).
  LOOP AT S_GJAHR.
    IF S_GJAHR-LOW > LV_GJAHR .
      MESSAGE E007(ZVENDOR).
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SUB_VALIDATE_SLAB1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SUB_VALIDATE_SLAB1 .

* Validate Slab1
  IF P_SLAB1 IS INITIAL AND P_SLAB2 IS INITIAL AND P_SLAB3 IS INITIAL
  AND P_SLAB4 IS INITIAL AND P_SLAB5 IS INITIAL .
    MESSAGE E000(ZVENDOR).                                      " Provide atleast one slab details.
  ELSEIF P_SLAB1 IS INITIAL AND P_SLAB5 IS INITIAL.
    MESSAGE E001(ZVENDOR).                                   " Please fill first slab
  ENDIF.
  IF P_SLAB1 IS NOT INITIAL AND  P_SLAB2 IS NOT INITIAL.
    IF P_SLAB1 = P_SLAB2.
      MESSAGE E002(ZVENDOR).
    ENDIF.
  ENDIF.
  IF P_SLAB2 IS NOT INITIAL AND  P_SLAB3 IS NOT INITIAL.
    IF P_SLAB2 = P_SLAB3.
      MESSAGE E002(ZVENDOR).
    ENDIF.
  ENDIF.
  IF P_SLAB3 IS NOT INITIAL AND  P_SLAB4 IS NOT INITIAL.
    IF P_SLAB3 = P_SLAB4.
      MESSAGE E002(ZVENDOR).
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SUB_VALIDATE_SLAB2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SUB_VALIDATE_SLAB2 .
* Validate Aging Slabs
  IF P_SLAB1 IS INITIAL AND P_SLAB2 IS NOT INITIAL AND P_SLAB3 IS
  INITIAL AND P_SLAB4 IS INITIAL .
    MESSAGE E001(ZVENDOR).                             " Please fill first slab
  ELSEIF P_SLAB1 IS INITIAL AND P_SLAB2 IS NOT INITIAL AND P_SLAB3 IS
  NOT INITIAL AND P_SLAB4 IS NOT INITIAL .
    MESSAGE E001(ZVENDOR).                             " Please fill first slab
  ELSEIF P_SLAB1 IS INITIAL AND P_SLAB2 IS NOT INITIAL AND P_SLAB3 IS
    NOT INITIAL AND P_SLAB4 IS INITIAL .
    MESSAGE E001(ZVENDOR).                              " Please fill first slab
  ENDIF.
  IF P_SLAB2 IS NOT INITIAL .
    IF P_SLAB1 > P_SLAB2.
      MESSAGE E003(ZVENDOR).             " Slabs should be in ascending order
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SUB_VALIDATE_SLAB3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SUB_VALIDATE_SLAB3 .
  IF P_SLAB1 IS INITIAL AND P_SLAB2 IS INITIAL AND P_SLAB3 IS NOT
    INITIAL AND P_SLAB4 IS INITIAL.
    MESSAGE E001(ZVENDOR).                                  " Please fill first slab
  ELSEIF P_SLAB1 IS INITIAL AND P_SLAB2 IS INITIAL AND P_SLAB3 IS NOT
  INITIAL AND P_SLAB4 IS NOT INITIAL .
    MESSAGE E001(ZVENDOR).                                   " Please fill first slab
  ELSEIF P_SLAB1 IS NOT INITIAL AND P_SLAB2 IS INITIAL AND P_SLAB3 IS
  NOT INITIAL AND P_SLAB4 IS NOT INITIAL .
    MESSAGE E004(ZVENDOR).                                  " Mid Slab Cannot be left Blank
  ENDIF.

  IF P_SLAB3 IS NOT INITIAL.
    IF P_SLAB2 > P_SLAB3.
      MESSAGE  E003(ZVENDOR).                      " Slabs should be in ascending order
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SUB_VALIDATE_SLAB4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SUB_VALIDATE_SLAB4 .
* Validate Slab4
  IF P_SLAB1 IS INITIAL AND P_SLAB2 IS INITIAL AND P_SLAB3 IS INITIAL
  AND P_SLAB4 IS NOT INITIAL .
    MESSAGE E001(ZVENDOR).                                " Please fill first slab
  ELSEIF P_SLAB1 IS NOT INITIAL AND P_SLAB2 IS  INITIAL AND P_SLAB3
  IS NOT INITIAL AND P_SLAB4 IS NOT INITIAL .
    MESSAGE E004(ZVENDOR).                                   " Mid Slab Cannot be left Blank
  ELSEIF P_SLAB1 IS NOT INITIAL AND P_SLAB2 IS  NOT INITIAL AND P_SLAB3
 IS  INITIAL AND P_SLAB4 IS NOT INITIAL .
    MESSAGE E004(ZVENDOR).                                   " Mid Slab Cannot be left Blank
    " Mid Slab Cannot be left Blank
  ENDIF.
  IF P_SLAB4 IS NOT INITIAL.
    IF P_SLAB4 < P_SLAB3.
      MESSAGE  E003(ZVENDOR).                                 " Slabs should be in ascending order
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FETCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FETCH .

  DATA: LV_ZFBDT TYPE DZFBDT,
        LV_ZBD1T TYPE DZBD1T,
        LV_ZBD2T TYPE DZBD2T,
        LV_ZBD3T TYPE DZBD3T,
        LV_E_FY  TYPE C,
        LV_TABIX TYPE I,
        LV_AGE   TYPE I.


  DATA: CALC_DATE TYPE P0001-BEGDA,
        MONTHS    TYPE T5A4A-DLYMO,
        YEARS     TYPE T5A4A-DLYYR,
        P_DAYS    TYPE T5A4A-DLYDY.

  SELECT  BUKRS
        LIFNR
        UMSKS
        UMSKZ
        AUGDT
        AUGBL
        ZUONR
        GJAHR
        BELNR
        BUZEI
        BUDAT
        BLDAT
        BLART
        SHKZG
        DMBTR
*          EBELN
        HKONT
        ZFBDT
        ZBD1T
        ZBD2T
        ZBD3T
*          NETDT
        XBLNR
        ZTERM
        GSBER
        SGTXT
        FROM BSIK INTO TABLE I_BSIK WHERE  GJAHR IN S_GJAHR AND
                                           BUDAT <= S_BUDAT AND
                                           LIFNR IN S_LIFNR AND
*                                            BLART <> 'AB'    and
                                           BUKRS = S_BUKRS.

  SELECT  BUKRS
          LIFNR
          UMSKS
          UMSKZ
          AUGDT
          AUGBL
          ZUONR
          GJAHR
          BELNR
          BUZEI
          BUDAT
          BLDAT
          BLART
          SHKZG
          DMBTR
*          EBELN
          HKONT
          ZFBDT
          ZBD1T
          ZBD2T
          ZBD3T
*          NETDT
          XBLNR
          ZTERM
          GSBER
          SGTXT
          FROM BSAK INTO TABLE I_BSAK WHERE  GJAHR IN S_GJAHR AND
                                             BUDAT <= S_BUDAT AND
                                             LIFNR IN S_LIFNR AND
*                                            BLART <> 'AB'    and
                                             BUKRS = S_BUKRS.

  DELETE I_BSAK WHERE AUGDT <= S_BUDAT .

  APPEND LINES OF I_BSAK TO I_BSIK.


  LOOP AT I_BSIK INTO W_BSIK.
    IF W_BSIK-SHKZG = C_CIND.
      W_BSIK-DMBTR = - ( W_BSIK-DMBTR ) .
    ELSE.
    ENDIF.

    MODIFY I_BSIK FROM W_BSIK INDEX SY-TABIX TRANSPORTING DMBTR.
  ENDLOOP.

  IF I_BSIK IS NOT INITIAL.
    SELECT BUKRS
          BELNR
          GJAHR
          AWKEY FROM BKPF INTO TABLE I_BKPF FOR ALL ENTRIES IN I_BSIK
                WHERE BUKRS = I_BSIK-BUKRS AND
                      BELNR = I_BSIK-BELNR AND
                      GJAHR = I_BSIK-GJAHR AND
                      BLART = I_BSIK-BLART.

    SELECT BUKRS
           BELNR
           GJAHR
           SHKZG
           NETDT
           ZFBDT
           KOART FROM BSEG INTO TABLE I_BSEG FOR ALL ENTRIES IN I_BSIK
                 WHERE BUKRS = I_BSIK-BUKRS
                 AND   BELNR = I_BSIK-BELNR
                 AND   KOART = 'K'."'K'.

    IF I_BKPF IS NOT INITIAL.

      SELECT BELNR
             GJAHR
             BLDAT
             BUKRS
             RMWWR
             FROM RBKP INTO TABLE I_RBKP FOR ALL ENTRIES IN I_BKPF
               WHERE   BELNR = I_BKPF-AWKEY+0(10) AND
                       GJAHR = I_BKPF-GJAHR AND
                       BUKRS = I_BKPF-BUKRS.
    ENDIF.


    SELECT LIFNR
           NAME1
           ORT01
           REGIO
           LAND1
                 FROM LFA1 INTO TABLE I_LFA1 FOR ALL ENTRIES IN I_BSIK  WHERE LIFNR = I_BSIK-LIFNR.

    SELECT  LIFNR
            BUKRS
            AKONT
            FROM LFB1 INTO TABLE I_LFB1 FOR ALL ENTRIES IN I_BSIK  WHERE LIFNR = I_BSIK-LIFNR.

    IF NOT I_LFA1 IS INITIAL.
      SELECT * FROM T005U INTO TABLE I_T005U FOR ALL ENTRIES IN I_LFA1
             WHERE BLAND = I_LFA1-REGIO AND SPRAS = 'EN' AND LAND1 = 'IN'.

      SELECT
        LAND1
        SPRAS
        LANDX50
        FROM T005T INTO TABLE I_T005T FOR ALL ENTRIES IN I_LFA1
        WHERE SPRAS = SY-LANGU AND LAND1 = I_LFA1-LAND1.
    ENDIF.

  ENDIF.

  LOOP AT I_BSIK INTO W_BSIK ."where kunnr ne '0000004001' or kunnr ne '0000004002'.
    IF W_BSIK-LIFNR = 'STOD001' OR W_BSIK-LIFNR = 'STOD002' OR W_BSIK-LIFNR = 'STOD003' OR W_BSIK-LIFNR = 'STOD004'
    OR W_BSIK-LIFNR = 'STOD005' OR W_BSIK-LIFNR = 'STOH001' OR W_BSIK-LIFNR = 'STOP001' OR W_BSIK-LIFNR = 'STOP002'
    OR W_BSIK-LIFNR = 'STOP003' OR W_BSIK-LIFNR = 'STOP004' OR W_BSIK-LIFNR = 'STOP005' OR W_BSIK-LIFNR = 'STOP006'
    OR W_BSIK-LIFNR = 'STORG001' OR W_BSIK-LIFNR = 'STOW001' OR W_BSIK-LIFNR = 'STOD006' OR W_BSIK-LIFNR = 'STOD007'
    OR W_BSIK-LIFNR = 'STOD008'  OR W_BSIK-LIFNR = 'STOD009'.


    ELSE.
      W_FINAL-LIFNR = W_BSIK-LIFNR.
      W_FINAL-BUDAT = W_BSIK-BUDAT.
      W_FINAL-BLDAT = W_BSIK-BLDAT.
      W_FINAL-DMBTR = W_BSIK-DMBTR.
      W_FINAL-XBLNR = W_BSIK-XBLNR.
      W_FINAL-ZTERM = W_BSIK-ZTERM.
      W_FINAL-GSBER = W_BSIK-GSBER.
      W_FINAL-SGTXT = W_BSIK-SGTXT.

      MOVE  W_BSIK-ZBD1T TO P_DAYS.

      CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
        EXPORTING
          DATE      = W_BSIK-ZFBDT
          DAYS      = P_DAYS
          MONTHS    = 0
          SIGNUM    = '+'
          YEARS     = 0
        IMPORTING
          CALC_DATE = CALC_DATE.

      W_FINAL-ZBD1T = W_BSIK-ZBD1T.
      MOVE CALC_DATE TO W_FINAL-NETDT.

      READ TABLE I_LFA1 INTO W_LFA1 WITH KEY LIFNR = W_BSIK-LIFNR.
      IF SY-SUBRC = 0.
        W_FINAL-NAME1 = W_LFA1-NAME1.
        W_FINAL-ORT01 = W_LFA1-ORT01.
      ENDIF.

      READ TABLE I_T005U INTO W_T005U WITH KEY BLAND = W_LFA1-REGIO.
      IF SY-SUBRC = 0.
        W_FINAL-BEZEI = W_T005U-BEZEI.
      ENDIF.

      READ TABLE I_T005T INTO W_T005T WITH KEY LAND1 = W_LFA1-LAND1.
      IF SY-SUBRC  = 0.
        W_FINAL-LANDX50 = W_T005T-LANDX50.
      ENDIF.

      READ TABLE I_LFB1 INTO W_LFB1 WITH KEY LIFNR = W_BSIK-LIFNR.
      IF SY-SUBRC = 0.
        W_FINAL-AKONT = W_LFB1-AKONT.
      ENDIF.

      READ TABLE I_BKPF INTO W_BKPF WITH KEY  BUKRS = W_BSIK-BUKRS  BELNR = W_BSIK-BELNR GJAHR = W_BSIK-GJAHR.
      IF SY-SUBRC = 0.
        W_FINAL-BELNR1 = W_BKPF-BELNR.

        IF W_BSIK-SHKZG = C_DIND.
          W_FINAL-D_DMBTR = W_BSIK-DMBTR.
        ENDIF.

        W_FINAL-C_DMBTR =  W_FINAL-D_DMBTR - W_FINAL-RMWWR.


        LV_AGE = S_BUDAT -  CALC_DATE .

        IF LV_AGE < 0.
          W_FINAL-LV_NYD = W_FINAL-DMBTR.
        ELSE.

          IF LV_AGE <= P_SLAB1.
            W_FINAL-DEBIT1 =  W_FINAL-DMBTR .
          ELSEIF LV_AGE > P_SLAB1 AND LV_AGE <= P_SLAB2.
            W_FINAL-DEBIT2 =  W_FINAL-DMBTR.
          ELSEIF LV_AGE > P_SLAB2 AND LV_AGE <= P_SLAB3.
            W_FINAL-DEBIT3 = W_FINAL-DMBTR.
          ELSEIF LV_AGE > P_SLAB3 AND LV_AGE <= P_SLAB4.
            W_FINAL-DEBIT4 = W_FINAL-DMBTR.
          ELSEIF LV_AGE > P_SLAB4 AND LV_AGE <= P_SLAB5.
            W_FINAL-DEBIT5 = W_FINAL-DMBTR.
          ELSEIF LV_AGE > P_SLAB5 AND LV_AGE <= P_SLAB6.
            W_FINAL-DEBIT6 = W_FINAL-DMBTR.
          ELSEIF LV_AGE > P_SLAB6 ."OR ( lv_age > p_slab6 AND lv_age <= p_slab7 ).
            W_FINAL-DEBIT7 = W_FINAL-DMBTR.

          ENDIF.
        ENDIF.

        W_FINAL-OVERDUE = W_FINAL-DMBTR - W_FINAL-LV_NYD.


        IF P_SLAB2 IS INITIAL.
          W_FINAL-DEBITBAL =  W_FINAL-DEBIT2 + W_FINAL-DEBIT3 + W_FINAL-DEBIT4 + W_FINAL-DEBIT5 + W_FINAL-DEBIT6 + W_FINAL-DEBIT7.
        ELSEIF P_SLAB3 IS INITIAL.
          W_FINAL-DEBITBAL =  W_FINAL-DEBIT3 + W_FINAL-DEBIT4 + W_FINAL-DEBIT5 + W_FINAL-DEBIT6 + W_FINAL-DEBIT7.
        ELSEIF P_SLAB4 IS INITIAL.
          W_FINAL-DEBITBAL =  W_FINAL-DEBIT4 + W_FINAL-DEBIT5 + W_FINAL-DEBIT6 + W_FINAL-DEBIT7.
        ELSEIF P_SLAB5 IS INITIAL.
          W_FINAL-DEBITBAL =  W_FINAL-DEBIT5 + W_FINAL-DEBIT6 + W_FINAL-DEBIT7.
        ELSEIF P_SLAB6 IS INITIAL.
          W_FINAL-DEBITBAL =  W_FINAL-DEBIT6 + W_FINAL-DEBIT7.
        ELSEIF P_SLAB6 IS NOT INITIAL.
          W_FINAL-DEBITBAL =  W_FINAL-DEBIT7.
        ENDIF.


      ENDIF.

    ENDIF.
    APPEND W_FINAL TO I_FINAL.
    CLEAR : W_BSIK,W_EKKO,W_LFA1,W_FINAL,W_RBKP,W_BKPF,W_T005U,W_VBRK.
    DELETE I_FINAL WHERE LIFNR EQ SPACE.
  ENDLOOP.

  SORT I_FINAL BY BLDAT.

  I_FINAL4[] = I_FINAL[].

  SORT I_FINAL4 BY LIFNR.
  DELETE ADJACENT DUPLICATES FROM I_FINAL4 COMPARING LIFNR.

  LOOP AT I_FINAL4 INTO W_FINAL4.
*    AT END OF lifnr.
*      SUM.
    W_FINAL2 = W_FINAL4.
    W_FINAL1-NAME1 = W_FINAL2-NAME1.
    W_FINAL1-NAME2 = W_FINAL2-NAME2.
    W_FINAL1-NAME3 = W_FINAL2-NAME3.
    W_FINAL1-BUDAT = W_FINAL2-BUDAT.
*      W_FINAL1-VKBUR = W_FINAL2-VKBUR.
*      W_FINAL1-VKGRP = W_FINAL2-VKGRP.
    W_FINAL1-BEZEI  = W_FINAL2-BEZEI.
    W_FINAL1-ORT01  = W_FINAL2-ORT01.
    W_FINAL1-LANDX50  = W_FINAL2-LANDX50.
*    W_FINAL1-KDGRP  = W_FINAL2-KDGRP.
*    W_FINAL1-SPART  = W_FINAL2-SPART.
*    W_FINAL1-SGTXT  = W_FINAL2-SGTXT.
    W_FINAL1-BELNR1 = W_FINAL2-BELNR1.
    W_FINAL1-BLDAT = W_FINAL2-BLDAT.
    W_FINAL1-LIFNR = W_FINAL2-LIFNR.
    W_FINAL1-XBLNR = W_FINAL2-XBLNR.
    W_FINAL1-ZTERM = W_FINAL2-ZTERM.
    W_FINAL1-AKONT = W_FINAL2-AKONT.
    W_FINAL1-GSBER = W_FINAL2-GSBER.
    W_FINAL1-ZBD1T  =  W_FINAL2-ZBD1T.
    W_FINAL1-NETDT  =  W_FINAL2-NETDT.
    W_FINAL1-BELNR1 =  W_FINAL2-BELNR1.
    W_FINAL1-BLDAT1 =  W_FINAL2-BLDAT1.
    W_FINAL1-RMWWR  =  W_FINAL2-RMWWR.

    LOOP AT I_FINAL INTO W_FINAL WHERE LIFNR = W_FINAL4-LIFNR.
      W_FINAL2 = W_FINAL.
      W_FINAL1-DMBTR   = W_FINAL1-DMBTR + W_FINAL-DMBTR.
      W_FINAL1-C_DMBTR = W_FINAL1-C_DMBTR + W_FINAL-C_DMBTR.
      W_FINAL1-D_DMBTR = W_FINAL1-D_DMBTR + W_FINAL-D_DMBTR.
      W_FINAL1-LV_NYD = W_FINAL1-LV_NYD + W_FINAL2-LV_NYD.
      W_FINAL1-DEBIT1 = W_FINAL1-DEBIT1 + W_FINAL2-DEBIT1.
      W_FINAL1-DEBIT2 = W_FINAL1-DEBIT2 + W_FINAL2-DEBIT2.
      W_FINAL1-DEBIT3 = W_FINAL1-DEBIT3 + W_FINAL2-DEBIT3.
      W_FINAL1-DEBIT4 = W_FINAL1-DEBIT4 + W_FINAL2-DEBIT4.
      W_FINAL1-DEBIT5 = W_FINAL1-DEBIT5 + W_FINAL2-DEBIT5.
      W_FINAL1-DEBIT6 = W_FINAL1-DEBIT6 + W_FINAL2-DEBIT6.
      W_FINAL1-DEBIT7 = W_FINAL1-DEBIT7 + W_FINAL2-DEBIT7.
      W_FINAL1-DEBITBAL = W_FINAL1-DEBITBAL + W_FINAL2-DEBITBAL. """added by naveen
      W_FINAL1-OVERDUE = W_FINAL1-OVERDUE + W_FINAL2-OVERDUE.
    ENDLOOP.

    APPEND W_FINAL1 TO I_FINAL1.
    CLEAR : W_FINAL1.
*    ENDAT.
    CLEAR :W_FINAL,W_FINAL2,W_FINAL4.
  ENDLOOP.

  SORT I_FINAL1 BY LIFNR." SPART.
  "***************MATERIAL RECONCILATION ACCOUNT************************

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DETAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_DETAIL .

  PERFORM LAYOUT.
  REFRESH I_FIELDCAT.
  PERFORM PREPARE_CATLOG1.

  PERFORM GRID_DISPLAY USING I_FINAL1  I_FIELDCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY .

  PERFORM LAYOUT.

  PERFORM PREPARE_CATLOG.

  PERFORM GRID_DISPLAY2 USING I_FINAL  I_FIELDCAT.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM LAYOUT .

  CLEAR  GS_ALV_LAYOUT.
  GS_ALV_LAYOUT-NO_AUTHOR = 'X'.
  GS_ALV_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  GS_ALV_LAYOUT-ZEBRA = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PREPARE_CATLOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PREPARE_CATLOG .

  DATA: T_SLAB1  TYPE CHAR40,
        N_SLAB1  TYPE CHAR10,
        N_SLAB2  TYPE CHAR10,
        T_SLAB2  TYPE CHAR40,
        N_SLAB3  TYPE CHAR10,
        N_SLAB4  TYPE CHAR10,
        T_SLAB3  TYPE CHAR40,
        N_SLAB5  TYPE CHAR10,
        N_SLAB6  TYPE CHAR10,
        T_SLAB4  TYPE CHAR40,
        N_SLAB7  TYPE CHAR10,
        N_SLAB8  TYPE CHAR10,
        N_SLAB9  TYPE CHAR10,
        N_SLAB10 TYPE CHAR10,
        T_SLAB5  TYPE CHAR40,
        N_SLAB11 TYPE CHAR10,
        N_SLAB12 TYPE CHAR10,
        N_SLAB13 TYPE CHAR10,
        N_SLAB14 TYPE CHAR10,
        T_SLAB6  TYPE CHAR40,
        T_SLAB7  TYPE CHAR40.

  PERFORM FIELDCAT USING '1'  'LIFNR' 'Vendor Acc. No.' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '3'  'GSBER' 'Business Area' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '4'  'BEZEI' 'State' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '5'  'ORT01' 'City' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '5'  'LANDX50' 'Country' 'I_FINAL' ' ' ' ' ' '
                CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '2'  'NAME1'  'Vendor Name' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '6'  'BELNR1' 'Document No' 'I_FINAL' ' ' ' ' 'X'
                   CHANGING I_FIELDCAT.

*  PERFORM fieldcat USING '5'  'BLDAT1' 'Document Date' 'I_FINAL' ' ' ' ' ' '
*                   CHANGING i_fieldcat.

  PERFORM FIELDCAT USING '7'  'BLDAT' 'Invoice Date' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.


  PERFORM FIELDCAT USING '8'  'XBLNR' 'Reference' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.

**  PERFORM FIELDCAT USING '8'  'KDGRP' 'Customer Grp' 'I_FINAL' ' ' ' ' ' '
**                   CHANGING I_FIELDCAT.
**
***  PERFORM FIELDCAT USING '9'  'VKBUR' 'Sales Office' 'I_FINAL' ' ' ' ' ' '
***                   CHANGING I_FIELDCAT.
***
***  PERFORM FIELDCAT USING '10'  'VKGRP' 'Sales Group' 'I_FINAL' ' ' ' ' ' '
***                   CHANGING I_FIELDCAT.
**
**  PERFORM FIELDCAT USING '9'  'NAME2' 'Regional manager' 'I_FINAL' ' ' ' ' ' '
**                   CHANGING I_FIELDCAT.
**
**  PERFORM FIELDCAT USING '10'  'NAME3' 'Sales employee' 'I_FINAL' ' ' ' ' ' '
**                   CHANGING I_FIELDCAT.
**
**  PERFORM FIELDCAT USING '11'  'SPART' 'Division' 'I_FINAL' ' ' ' ' ' '
**                   CHANGING I_FIELDCAT.
**
**  PERFORM FIELDCAT USING '12'  'SGTXT' 'Reference' 'I_FINAL' ' ' ' ' ' '
**                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '9'  'DMBTR' 'AMOUNT' 'I_FINAL' ' ' 'X' ' '
                 CHANGING I_FIELDCAT.

*  PERFORM fieldcat USING '8'  'BELNR1' 'Document No' 'I_FINAL' ' ' ' ' 'X'
*                   CHANGING i_fieldcat.
*  PERFORM fieldcat USING '7'  'RMWWR' 'Invoice Amount' 'I_FINAL' 'X' 'X' ' '
*                   CHANGING i_fieldcat.
*
*
*  PERFORM fieldcat USING '8'  'D_DMBTR' 'Paid Amount' 'I_FINAL' 'X' 'X' ' '
*                   CHANGING i_fieldcat.
*  PERFORM fieldcat USING '9'  'C_DMBTR' 'Outstanding Amount' 'I_FINAL' 'X' 'X' ' '
*                   CHANGING i_fieldcat.

*  PERFORM fieldcat USING '16' 'ZBD1T' 'Payment Due Days' 'I_FINAL' ' ' 'X' ' '
*                                CHANGING i_fieldcat.

  PERFORM FIELDCAT USING '10' 'LV_NYD' 'Not Yet Due' 'I_FINAL' ' ' 'X' ' '
                                CHANGING I_FIELDCAT.

*
*  PERFORM fieldcat USING '17' 'NETDT' 'Payment Due Date' 'I_FINAL' ' ' ' ' ' '
*                                CHANGING i_fieldcat.

  IF P_SLAB1 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB1
      IMPORTING
        OUTPUT = N_SLAB1.

    CONCATENATE  '0-' N_SLAB1  INTO N_SLAB2.
    CONCATENATE   N_SLAB2 'Days' INTO  T_SLAB1 SEPARATED BY SPACE..

    PERFORM FIELDCAT USING '11' 'DEBIT1' T_SLAB1 'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.

  IF P_SLAB2 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB2
      IMPORTING
        OUTPUT = N_SLAB3.

    N_SLAB1 = N_SLAB1 + 1.
    CONDENSE N_SLAB1.
    CONCATENATE  N_SLAB1 '-' N_SLAB3  INTO N_SLAB4.
    CONCATENATE   N_SLAB4 'Days' INTO  T_SLAB2 SEPARATED BY SPACE.


    PERFORM FIELDCAT USING '12'  'DEBIT2' T_SLAB2  'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.
  IF P_SLAB3 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB3
      IMPORTING
        OUTPUT = N_SLAB5.

    N_SLAB3 = N_SLAB3 + 1.
    CONDENSE N_SLAB3.
    CONCATENATE  N_SLAB3 '-' N_SLAB5  INTO N_SLAB6.
    CONCATENATE   N_SLAB6 'Days' INTO  T_SLAB3 SEPARATED BY SPACE.

    PERFORM FIELDCAT USING '13'  'DEBIT3' T_SLAB3 'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.
  IF P_SLAB4 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB4
      IMPORTING
        OUTPUT = N_SLAB7.

    N_SLAB5 = N_SLAB5 + 1.
    CONDENSE N_SLAB5.
*    CONCATENATE  '>' N_SLAB7  INTO N_SLAB8.
    CONCATENATE  N_SLAB5 '-' N_SLAB7  INTO N_SLAB8.
    CONCATENATE   N_SLAB8 'Days' INTO  T_SLAB4 SEPARATED BY SPACE.


    PERFORM FIELDCAT USING '14'  'DEBIT4'  T_SLAB4 'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.


  IF P_SLAB5 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB5
      IMPORTING
        OUTPUT = N_SLAB9.

    N_SLAB7 = N_SLAB7 + 1.
    CONDENSE N_SLAB7.
*    CONCATENATE '=>'  N_SLAB9  INTO N_SLAB10.
    CONCATENATE  N_SLAB7 '-' N_SLAB9  INTO N_SLAB10.
    CONCATENATE   N_SLAB10 'Days' INTO  T_SLAB5 SEPARATED BY SPACE.


    PERFORM FIELDCAT USING '15'  'DEBIT5' T_SLAB5 'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.

  """""""""""begin of changes by naveen 0n 4-Dec-2016

  IF P_SLAB6 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB6
      IMPORTING
        OUTPUT = N_SLAB11.
    N_SLAB9 = N_SLAB9 + 1.
    CONDENSE N_SLAB9.
*    CONCATENATE '=>'  N_SLAB11  INTO N_SLAB12.
    CONCATENATE  N_SLAB9 '-' N_SLAB11  INTO N_SLAB12.
    CONCATENATE   N_SLAB12 'Days' INTO  T_SLAB6 SEPARATED BY SPACE.


    PERFORM FIELDCAT USING '16'  'DEBIT6' T_SLAB6 'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.

  IF P_SLAB2 IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB1
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ELSEIF P_SLAB3 IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB2
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ELSEIF P_SLAB4 IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB3
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ELSEIF P_SLAB5 IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB4
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ELSEIF P_SLAB6 IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB5
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ELSEIF P_SLAB6 IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB6
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ENDIF.

  PERFORM FIELDCAT USING '17'  'DEBITBAL' T_SLAB7 'I_FINAL' 'X' 'X' ' '
                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '18' 'OVERDUE' 'Over Due' 'I_FINAL' ' ' 'X' ' '
                                CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '19'  'AKONT' 'Recon.G/L Account' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.

  """"""""""""""""""end of changes"""""""""""""

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GRID_DISPLAY2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_FINAL
*&      --> I_FIELDCAT
*&---------------------------------------------------------------------*
FORM GRID_DISPLAY2  USING FP_I_FINAL TYPE TY_T_FINAL  FP_I_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK           = ' '
*     I_BYPASSING_BUFFER          = ' '
*     I_BUFFER_ACTIVE             = ' '
      I_CALLBACK_PROGRAM          = GV_REPID
*     I_CALLBACK_PF_STATUS_SET    = ' '
*     i_callback_user_command     = 'USER_COMMAND1'
*     I_CALLBACK_TOP_OF_PAGE      = 'TOP_OF_PAGE'
      I_CALLBACK_HTML_TOP_OF_PAGE = 'TOP_OF_PAGE'
      IS_LAYOUT                   = GS_ALV_LAYOUT
      IT_FIELDCAT                 = FP_I_FIELDCAT
      I_DEFAULT                   = 'X'
      I_SAVE                      = 'A'
    TABLES
      T_OUTTAB                    = FP_I_FINAL
    EXCEPTIONS
      PROGRAM_ERROR               = 1
      OTHERS                      = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  LEAVE TO TRANSACTION 'ZVENDAG'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> T_SLAB7
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      <-- I_FIELDCAT
*&---------------------------------------------------------------------*
FORM FIELDCAT  USING LF_COL  TYPE SYCUROW
                    LF_FIELDNAME    TYPE SLIS_FIELDNAME
                    LF_NAME TYPE SCRTEXT_L
                    LF_TABNAME        TYPE SLIS_TABNAME
                    LF_LZERO TYPE C
                    LF_DO_SUM TYPE C
                    LF_HOTSPOT TYPE C
              CHANGING   LI_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

  DATA :  LW_FIELDCAT TYPE SLIS_FIELDCAT_ALV.

  LW_FIELDCAT-COL_POS  = LF_COL.
  LW_FIELDCAT-FIELDNAME = LF_FIELDNAME.
  LW_FIELDCAT-SELTEXT_L = LF_NAME.
  LW_FIELDCAT-TABNAME    = LF_TABNAME .
  LW_FIELDCAT-LZERO = LF_LZERO .
  LW_FIELDCAT-DO_SUM = LF_DO_SUM.
  LW_FIELDCAT-HOTSPOT = LF_HOTSPOT .

  APPEND LW_FIELDCAT TO LI_FIELDCAT.
  CLEAR LW_FIELDCAT.

ENDFORM.
FORM TOP_OF_PAGE USING TOP TYPE REF TO CL_DD_DOCUMENT.

  DATA: LV_TOP  TYPE SDYDO_TEXT_ELEMENT,
        LV_DATE TYPE SDYDO_TEXT_ELEMENT,
        SEP     TYPE C VALUE ' ',
        DOT     TYPE C VALUE '.',
        YYYY1   TYPE CHAR4,
        MM1     TYPE CHAR2,
        DD1     TYPE CHAR2,
        DATE1   TYPE CHAR10,
        YYYY2   TYPE CHAR4,
        MM2     TYPE CHAR2,
        DD2     TYPE CHAR2,
        DATE2   TYPE CHAR10.

  LV_TOP = 'Vendor Ageing Report'.

  IF S_BUDAT IS INITIAL AND S_BLDAT IS INITIAL.
*  LV_DATE = SY-DATUM.
    WRITE SY-DATUM TO LV_DATE MM/DD/YYYY.

  ENDIF.

  CALL METHOD TOP->ADD_TEXT
    EXPORTING
      TEXT      = LV_TOP
      SAP_STYLE = 'HEADING'.
*     to move to next line
  CALL METHOD TOP->NEW_LINE.
  CALL METHOD TOP->NEW_LINE.

  CALL METHOD TOP->ADD_TEXT
    EXPORTING
      TEXT = LV_DATE.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form PREPARE_CATLOG1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PREPARE_CATLOG1 .

  DATA: T_SLAB1  TYPE CHAR40,
        N_SLAB1  TYPE CHAR6,
        N_SLAB2  TYPE CHAR6,
        T_SLAB2  TYPE CHAR40,
        N_SLAB3  TYPE CHAR6,
        N_SLAB4  TYPE CHAR6,
        T_SLAB3  TYPE CHAR40,
        N_SLAB5  TYPE CHAR6,
        N_SLAB6  TYPE CHAR6,
        T_SLAB4  TYPE CHAR40,
        N_SLAB7  TYPE CHAR6,
        N_SLAB8  TYPE CHAR6,
        N_SLAB9  TYPE CHAR6,
        N_SLAB10 TYPE CHAR10,
        T_SLAB5  TYPE CHAR40,
        N_SLAB11 TYPE CHAR10,
        N_SLAB12 TYPE CHAR10,
        N_SLAB13 TYPE CHAR10,
        N_SLAB14 TYPE CHAR10,
        T_SLAB6  TYPE CHAR40,
        T_SLAB7  TYPE CHAR40.

  PERFORM FIELDCAT USING '1'  'LIFNR' 'Vendor Acc. No.' 'I_FINAL1' ' ' ' ' 'X'
                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '3'  'GSBER' 'Business Area' 'I_FINAL' ' ' ' ' ' '
                    CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '4'  'BEZEI' 'State' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '5'  'ORT01' 'City' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '2'  'NAME1'  'Vendor Name' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.
*
*  PERFORM FIELDCAT USING '3'  'XBLNR' 'Reference' 'I_FINAL' ' ' ' ' ' '
*                   CHANGING I_FIELDCAT.

*  PERFORM FIELDCAT USING '6'  'BELNR1' 'Document No' 'I_FINAL' ' ' ' ' 'X'
*                   CHANGING I_FIELDCAT.
*
**  PERFORM fieldcat USING '5'  'BLDAT1' 'Document Date' 'I_FINAL' ' ' ' ' ' '
**                   CHANGING i_fieldcat.
*
*  PERFORM FIELDCAT USING '7'  'BUDAT' 'Posting Date' 'I_FINAL' ' ' ' ' ' '
*                   CHANGING I_FIELDCAT.

*  PERFORM FIELDCAT USING '8'  'KDGRP' 'Customer Grp' 'I_FINAL' ' ' ' ' ' '
*                   CHANGING I_FIELDCAT.
*
**  PERFORM FIELDCAT USING '9'  'VKBUR' 'Sales Office' 'I_FINAL' ' ' ' ' ' '
**                   CHANGING I_FIELDCAT.
**
**  PERFORM FIELDCAT USING '10'  'VKGRP' 'Sales Group' 'I_FINAL' ' ' ' ' ' '
**                   CHANGING I_FIELDCAT.
*
*
*  PERFORM FIELDCAT USING '9'  'NAME2' 'Regional manager' 'I_FINAL' ' ' ' ' ' '
*                   CHANGING I_FIELDCAT.
*
*  PERFORM FIELDCAT USING '10'  'NAME3' 'Sales employee' 'I_FINAL' ' ' ' ' ' '
*                   CHANGING I_FIELDCAT.
*
*  PERFORM FIELDCAT USING '11'  'SPART' 'Division' 'I_FINAL' ' ' ' ' ' '
*                   CHANGING I_FIELDCAT.
*
*  PERFORM FIELDCAT USING '12'  'SGTXT' 'Reference' 'I_FINAL' ' ' ' ' ' '
*                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '8'  'DMBTR' 'AMOUNT' 'I_FINAL1' ' ' 'X' ' '
                   CHANGING I_FIELDCAT.
*  PERFORM fieldcat USING '4'  'RMWWR' 'Invoice Amount' 'I_FINAL1' 'X' 'X' ' '
*                   CHANGING i_fieldcat.
*
*
*  PERFORM fieldcat USING '5'  'D_DMBTR' 'Paid Amount' 'I_FINAL1' 'X' 'X' ' '
*                   CHANGING i_fieldcat.
*  PERFORM fieldcat USING '6'  'C_DMBTR' 'Outstanding Amount' 'I_FINAL1' 'X' 'X' ' '
*                   CHANGING i_fieldcat.

  PERFORM FIELDCAT USING '9' 'LV_NYD' 'Not Yet Due' 'I_FINAL1' ' ' 'X' ' '
                                CHANGING I_FIELDCAT.

*  PERFORM fieldcat USING '8' 'NETDT' 'Payment Due Date' 'I_FINAL1' ' ' ' ' ' '
*                                CHANGING i_fieldcat.


  IF P_SLAB1 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB1
      IMPORTING
        OUTPUT = N_SLAB1.

    CONCATENATE  '0-' N_SLAB1  INTO N_SLAB2.
    CONCATENATE   N_SLAB2 'Days' INTO  T_SLAB1 SEPARATED BY SPACE..

    PERFORM FIELDCAT USING '11' 'DEBIT1' T_SLAB1 'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.

  IF P_SLAB2 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB2
      IMPORTING
        OUTPUT = N_SLAB3.

    N_SLAB1 = N_SLAB1 + 1.
    CONDENSE N_SLAB1.
    CONCATENATE  N_SLAB1 '-' N_SLAB3  INTO N_SLAB4.
    CONCATENATE   N_SLAB4 'Days' INTO  T_SLAB2 SEPARATED BY SPACE.


    PERFORM FIELDCAT USING '12'  'DEBIT2' T_SLAB2  'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.
  IF P_SLAB3 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB3
      IMPORTING
        OUTPUT = N_SLAB5.

    N_SLAB3 = N_SLAB3 + 1.
    CONDENSE N_SLAB3.
    CONCATENATE  N_SLAB3 '-' N_SLAB5  INTO N_SLAB6.
    CONCATENATE   N_SLAB6 'Days' INTO  T_SLAB3 SEPARATED BY SPACE.

    PERFORM FIELDCAT USING '13'  'DEBIT3' T_SLAB3 'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.
  IF P_SLAB4 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB4
      IMPORTING
        OUTPUT = N_SLAB7.

    N_SLAB5 = N_SLAB5 + 1.
    CONDENSE N_SLAB5.
*    CONCATENATE  '>' N_SLAB7  INTO N_SLAB8.
    CONCATENATE  N_SLAB5 '-' N_SLAB7  INTO N_SLAB8.
    CONCATENATE   N_SLAB8 'Days' INTO  T_SLAB4 SEPARATED BY SPACE.


    PERFORM FIELDCAT USING '14'  'DEBIT4'  T_SLAB4 'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.


  IF P_SLAB5 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB5
      IMPORTING
        OUTPUT = N_SLAB9.

    N_SLAB7 = N_SLAB7 + 1.
    CONDENSE N_SLAB7.
*    CONCATENATE '=>'  N_SLAB9  INTO N_SLAB10.
    CONCATENATE  N_SLAB7 '-' N_SLAB9  INTO N_SLAB10.
    CONCATENATE   N_SLAB10 'Days' INTO  T_SLAB5 SEPARATED BY SPACE.


    PERFORM FIELDCAT USING '15'  'DEBIT5' T_SLAB5 'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.

  """""""""""begin of changes by naveen 0n 4-Dec-2016

  IF P_SLAB6 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB6
      IMPORTING
        OUTPUT = N_SLAB11.
    N_SLAB9 = N_SLAB9 + 1.
    CONDENSE N_SLAB9.
*    CONCATENATE '=>'  N_SLAB11  INTO N_SLAB12.
    CONCATENATE  N_SLAB9 '-' N_SLAB11  INTO N_SLAB12.
    CONCATENATE   N_SLAB12 'Days' INTO  T_SLAB6 SEPARATED BY SPACE.


    PERFORM FIELDCAT USING '16'  'DEBIT6' T_SLAB6 'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.

  IF P_SLAB2 IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB1
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ELSEIF P_SLAB3 IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB2
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ELSEIF P_SLAB4 IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB3
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ELSEIF P_SLAB5 IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB4
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ELSEIF P_SLAB6 IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB5
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ELSEIF P_SLAB6 IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB6
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ENDIF.

  PERFORM FIELDCAT USING '17'  'DEBITBAL' T_SLAB7 'I_FINAL' 'X' 'X' ' '
                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '18' 'OVERDUE' 'Over Due' 'I_FINAL' ' ' 'X' ' '
                                CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '19'  'AKONT' 'Recon.G/L Account' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.

  """"""""""""""""""end of changes"""""""""""""

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GRID_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_FINAL1
*&      --> I_FIELDCAT
*&---------------------------------------------------------------------*
FORM GRID_DISPLAY  USING FP_I_FINAL TYPE TY_T_FINAL  FP_I_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK           = ' '
*     I_BYPASSING_BUFFER          = ' '
*     I_BUFFER_ACTIVE             = ' '
      I_CALLBACK_PROGRAM          = GV_REPID
*     I_CALLBACK_PF_STATUS_SET    = ' '
      I_CALLBACK_USER_COMMAND     = 'USER_COMMAND2'
*     I_CALLBACK_TOP_OF_PAGE      = 'TOP_OF_PAGE'
      I_CALLBACK_HTML_TOP_OF_PAGE = 'TOP_OF_PAGE'
*     I_CALLBACK_HTML_END_OF_LIST = ' '
*     I_STRUCTURE_NAME            =
*     I_BACKGROUND_ID             = ' '
*     I_GRID_TITLE                =
*     I_GRID_SETTINGS             =
      IS_LAYOUT                   = GS_ALV_LAYOUT
      IT_FIELDCAT                 = FP_I_FIELDCAT
*     IT_EXCLUDING                =
*     IT_SPECIAL_GROUPS           =
*     IT_SORT                     =
*     IT_FILTER                   =
*     IS_SEL_HIDE                 =
      I_DEFAULT                   = 'X'
      I_SAVE                      = 'A'
*     IS_VARIANT                  =
*     IT_EVENTS                   =
*     IT_EVENT_EXIT               =
*     IS_PRINT                    =
*     IS_REPREP_ID                =
*     I_SCREEN_START_COLUMN       = 0
*     I_SCREEN_START_LINE         = 0
*     I_SCREEN_END_COLUMN         = 0
*     I_SCREEN_END_LINE           = 0
*     IT_ALV_GRAPHICS             =
*     IT_HYPERLINK                =
*     IT_ADD_FIELDCAT             =
*     IT_EXCEPT_QINFO             =
*     I_HTML_HEIGHT_TOP           =
*     I_HTML_HEIGHT_END           =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER     =
*     ES_EXIT_CAUSED_BY_USER      =
    TABLES
      T_OUTTAB                    = FP_I_FINAL
    EXCEPTIONS
      PROGRAM_ERROR               = 1
      OTHERS                      = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


  LEAVE TO TRANSACTION 'ZVENDAG'. "changed by naveen on 4-Dec-2016

ENDFORM.
FORM USER_COMMAND1 USING SY-UCOMM
                      RS_SELFIELD TYPE SLIS_SELFIELD.



ENDFORM.
FORM USER_COMMAND2 USING  SY-UCOMM
                      RS_SELFIELD TYPE SLIS_SELFIELD.
  DATA : LV_INDEX TYPE SY-TABIX,
         LV_LIFNR TYPE LIFNR.

  REFRESH I_FINAL3.
  CLEAR W_FINAL3.
  CASE SY-UCOMM.
    WHEN '&IC1'.

      IF RS_SELFIELD-FIELDNAME = 'LIFNR' AND RS_SELFIELD-VALUE <> ' '.
        READ TABLE I_FINAL1 INTO W_FINAL1 INDEX RS_SELFIELD-TABINDEX.
        IF SY-SUBRC = 0.
          SORT I_FINAL BY LIFNR.
          LV_LIFNR = W_FINAL1-LIFNR.
          READ TABLE I_FINAL INTO W_FINAL WITH KEY LIFNR = LV_LIFNR.
          IF SY-SUBRC = 0.
            LV_INDEX = SY-TABIX.

            CLEAR W_FINAL.
            LOOP AT I_FINAL INTO W_FINAL FROM LV_INDEX.
              IF W_FINAL-LIFNR <> LV_LIFNR.
                EXIT.
              ENDIF.
              MOVE-CORRESPONDING W_FINAL TO W_FINAL3.
              APPEND W_FINAL3 TO I_FINAL3.
              CLEAR :W_FINAL, W_FINAL3.

            ENDLOOP.
          ENDIF.
          CLEAR W_FINAL1.
          PERFORM DISPLAY3.
        ENDIF.

      ENDIF.
*
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY3 .
  PERFORM LAYOUT.

  REFRESH I_FIELDCAT.
  PERFORM PREPARE_CATLOG3.

  PERFORM GRID_DISPLAY3 USING I_FINAL3  I_FIELDCAT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PREPARE_CATLOG3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PREPARE_CATLOG3 .

  DATA: T_SLAB1  TYPE CHAR40,
        N_SLAB1  TYPE CHAR4,
        N_SLAB2  TYPE CHAR4,
        T_SLAB2  TYPE CHAR40,
        N_SLAB3  TYPE CHAR4,
        N_SLAB4  TYPE CHAR4,
        T_SLAB3  TYPE CHAR40,
        N_SLAB5  TYPE CHAR4,
        N_SLAB6  TYPE CHAR4,
        T_SLAB4  TYPE CHAR40,
        N_SLAB7  TYPE CHAR4,
        N_SLAB8  TYPE CHAR4,
        N_SLAB9  TYPE CHAR4,
        N_SLAB10 TYPE CHAR10,
        T_SLAB5  TYPE CHAR40,
        T_SLAB6  TYPE CHAR40,
        T_SLAB7  TYPE CHAR40,
        N_SLAB11 TYPE CHAR10,
        N_SLAB12 TYPE CHAR10,
        N_SLAB13 TYPE CHAR10,
        N_SLAB14 TYPE CHAR10.

  PERFORM FIELDCAT USING '1'  'LIFNR' 'Vendor Acc. No.' 'I_FINAL3' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '2'  'GSBER' 'Business Area' 'I_FINAL' ' ' ' ' ' '
                  CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '3'  'BEZEI' 'State' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '4'  'ORT01' 'City' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '5'  'NAME1'  'Vendor Name' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.
*
*  PERFORM FIELDCAT USING '3'  'XBLNR' 'Reference' 'I_FINAL' ' ' ' ' ' '
*                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '6'  'BELNR1' 'Document No' 'I_FINAL' ' ' ' ' 'X'
                   CHANGING I_FIELDCAT.

*  PERFORM fieldcat USING '5'  'BLDAT1' 'Document Date' 'I_FINAL' ' ' ' ' ' '
*                   CHANGING i_fieldcat.

  PERFORM FIELDCAT USING '7'  'BLDAT' 'Document Date' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.


  PERFORM FIELDCAT USING '8'  'XBLNR' 'Reference' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.

*  PERFORM FIELDCAT USING '8'  'KDGRP' 'Customer Grp' 'I_FINAL' ' ' ' ' ' '
*                   CHANGING I_FIELDCAT.

*  PERFORM FIELDCAT USING '9'  'VKBUR' 'Sales Office' 'I_FINAL' ' ' ' ' ' '
*                   CHANGING I_FIELDCAT.
*
*  PERFORM FIELDCAT USING '10'  'VKGRP' 'Sales Group' 'I_FINAL' ' ' ' ' ' '
*                   CHANGING I_FIELDCAT.


*  PERFORM FIELDCAT USING '9'  'NAME2' 'Regional manager' 'I_FINAL' ' ' ' ' ' '
*                   CHANGING I_FIELDCAT.
*
*  PERFORM FIELDCAT USING '10'  'NAME3' 'Sales employee' 'I_FINAL' ' ' ' ' ' '
*                   CHANGING I_FIELDCAT.
*
*  PERFORM FIELDCAT USING '11'  'SPART' 'Division' 'I_FINAL' ' ' ' ' ' '
*                   CHANGING I_FIELDCAT.
*
*  PERFORM FIELDCAT USING '12'  'SGTXT' 'Reference' 'I_FINAL' ' ' ' ' ' '
*                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '9'  'DMBTR' 'AMOUNT' 'I_FINAL3' ' ' 'X' ' '
                   CHANGING I_FIELDCAT.

*
*  PERFORM fieldcat USING '7'  'RMWWR' 'Invoice Amount' 'I_FINAL3' 'X' 'X' ' '
*                   CHANGING i_fieldcat.
*
*
*  PERFORM fieldcat USING '8'  'D_DMBTR' 'Paid Amount' 'I_FINAL3' 'X' 'X' ' '
*                   CHANGING i_fieldcat.
*  PERFORM fieldcat USING '9'  'C_DMBTR' 'Outstanding Amount' 'I_FINAL3' 'X' 'X' ' '
*                   CHANGING i_fieldcat.
  PERFORM FIELDCAT USING '10' 'LV_NYD' 'Not Yet Due' 'I_FINAL3' ' ' 'X' ' '
                                CHANGING I_FIELDCAT.

*  PERFORM fieldcat USING '17' 'NETDT' 'Payment Due Date' 'I_FINAL3' ' ' ' ' ' '
*                                CHANGING i_fieldcat.
  IF P_SLAB1 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB1
      IMPORTING
        OUTPUT = N_SLAB1.

    CONCATENATE  '0-' N_SLAB1  INTO N_SLAB2.
    CONCATENATE   N_SLAB2 'Days' INTO  T_SLAB1 SEPARATED BY SPACE..

    PERFORM FIELDCAT USING '11' 'DEBIT1' T_SLAB1 'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.

  IF P_SLAB2 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB2
      IMPORTING
        OUTPUT = N_SLAB3.

    N_SLAB1 = N_SLAB1 + 1.
    CONDENSE N_SLAB1.
    CONCATENATE  N_SLAB1 '-' N_SLAB3  INTO N_SLAB4.
    CONCATENATE   N_SLAB4 'Days' INTO  T_SLAB2 SEPARATED BY SPACE.


    PERFORM FIELDCAT USING '12'  'DEBIT2' T_SLAB2  'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.
  IF P_SLAB3 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB3
      IMPORTING
        OUTPUT = N_SLAB5.

    N_SLAB3 = N_SLAB3 + 1.
    CONDENSE N_SLAB3.
    CONCATENATE  N_SLAB3 '-' N_SLAB5  INTO N_SLAB6.
    CONCATENATE   N_SLAB6 'Days' INTO  T_SLAB3 SEPARATED BY SPACE.

    PERFORM FIELDCAT USING '13'  'DEBIT3' T_SLAB3 'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.
  IF P_SLAB4 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB4
      IMPORTING
        OUTPUT = N_SLAB7.

    N_SLAB5 = N_SLAB5 + 1.
    CONDENSE N_SLAB5.
*    CONCATENATE  '>' N_SLAB7  INTO N_SLAB8.
    CONCATENATE  N_SLAB5 '-' N_SLAB7  INTO N_SLAB8.
    CONCATENATE   N_SLAB8 'Days' INTO  T_SLAB4 SEPARATED BY SPACE.


    PERFORM FIELDCAT USING '14'  'DEBIT4'  T_SLAB4 'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.


  IF P_SLAB5 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB5
      IMPORTING
        OUTPUT = N_SLAB9.

    N_SLAB7 = N_SLAB7 + 1.
    CONDENSE N_SLAB7.
*    CONCATENATE '=>'  N_SLAB9  INTO N_SLAB10.
    CONCATENATE  N_SLAB7 '-' N_SLAB9  INTO N_SLAB10.
    CONCATENATE   N_SLAB10 'Days' INTO  T_SLAB5 SEPARATED BY SPACE.


    PERFORM FIELDCAT USING '15'  'DEBIT5' T_SLAB5 'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.


  IF P_SLAB6 <> 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB6
      IMPORTING
        OUTPUT = N_SLAB11.
    N_SLAB9 = N_SLAB9 + 1.
    CONDENSE N_SLAB9.
*    CONCATENATE '=>'  N_SLAB11  INTO N_SLAB12.
    CONCATENATE  N_SLAB9 '-' N_SLAB11  INTO N_SLAB12.
    CONCATENATE   N_SLAB12 'Days' INTO  T_SLAB6 SEPARATED BY SPACE.


    PERFORM FIELDCAT USING '16'  'DEBIT6' T_SLAB6 'I_FINAL' 'X' 'X' ' '
                     CHANGING I_FIELDCAT.
  ENDIF.

  IF P_SLAB2 IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB1
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ELSEIF P_SLAB3 IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB2
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ELSEIF P_SLAB4 IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB3
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ELSEIF P_SLAB5 IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB4
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ELSEIF P_SLAB6 IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB5
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ELSEIF P_SLAB6 IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_SLAB6
      IMPORTING
        OUTPUT = N_SLAB13.

    CONCATENATE '>'  N_SLAB13  INTO N_SLAB14.
    CONCATENATE   N_SLAB14 'Days' INTO  T_SLAB7 SEPARATED BY SPACE.
  ENDIF.

  PERFORM FIELDCAT USING '17'  'DEBITBAL' T_SLAB7 'I_FINAL' 'X' 'X' ' '
                   CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '18' 'OVERDUE' 'Over Due' 'I_FINAL' ' ' 'X' ' '
                                CHANGING I_FIELDCAT.

  PERFORM FIELDCAT USING '19'  'AKONT' 'Recon.G/L Account' 'I_FINAL' ' ' ' ' ' '
                   CHANGING I_FIELDCAT.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GRID_DISPLAY3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_FINAL3
*&      --> I_FIELDCAT
*&---------------------------------------------------------------------*
FORM GRID_DISPLAY3  USING FP_I_FINAL TYPE TY_T_FINAL  FP_I_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK           = ' '
*     I_BYPASSING_BUFFER          = ' '
*     I_BUFFER_ACTIVE             = ' '
      I_CALLBACK_PROGRAM          = GV_REPID
*     I_CALLBACK_PF_STATUS_SET    = ' '
      I_CALLBACK_USER_COMMAND     = 'USER_COMMAND1'
*     I_CALLBACK_TOP_OF_PAGE      = 'TOP_OF_PAGE'
      I_CALLBACK_HTML_TOP_OF_PAGE = 'TOP_OF_PAGE'
      IS_LAYOUT                   = GS_ALV_LAYOUT
      IT_FIELDCAT                 = FP_I_FIELDCAT
      I_DEFAULT                   = 'X'
      I_SAVE                      = 'A'
    TABLES
      T_OUTTAB                    = FP_I_FINAL
    EXCEPTIONS
      PROGRAM_ERROR               = 1
      OTHERS                      = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
FORM BDC_DYNPRO  USING  P_DYNBEGIN TYPE BDC_START
                        P_FNAM TYPE FNAM_____4
                        P_FVAL TYPE BDC_FVAL .

  CLEAR GW_BDCDATA.
  GW_BDCDATA-PROGRAM = P_FNAM.
  GW_BDCDATA-DYNBEGIN = P_DYNBEGIN.
  GW_BDCDATA-DYNPRO = P_FVAL.
  APPEND GW_BDCDATA TO GT_BDCDATA.

ENDFORM.                    " bdc_dynpro
*&---------------------------------------------------------------------*
*&      Form  bdc_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1697   text
*      -->P_1698   text
*----------------------------------------------------------------------*
FORM BDC_FIELD USING   P_FNAM TYPE STRING
                        P_FVAL TYPE ANY .

  CLEAR GW_BDCDATA.
  GW_BDCDATA-FNAM = P_FNAM.
  GW_BDCDATA-FVAL = P_FVAL.
  APPEND GW_BDCDATA TO GT_BDCDATA.

ENDFORM.
