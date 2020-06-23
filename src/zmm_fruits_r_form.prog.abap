*&---------------------------------------------------------------------*
*& Include          ZMM_FRUITS_R_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GETDATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GETDATA .
  BREAK CLIKHITHA.
*IF s_plant IS NOT INITIAL.
  SELECT
      CLINT
      KLART
      CLASS
      VONDT
      BISDT
      WWSKZ
      FROM KLAH INTO TABLE IT_KLAH
      WHERE CLASS = 'FRUITSANDVEGETABLES'.
*  ENDIF.

  IF IT_KLAH IS NOT INITIAL.
    SELECT OBJEK
           MAFID
           KLART
           CLINT
           ADZHL
           DATUB FROM KSSK INTO TABLE IT_KSSK
           FOR ALL ENTRIES IN IT_KLAH
            WHERE CLINT = IT_KLAH-CLINT.
  ENDIF.

*  IF IT_KLAH IS NOT INITIAL.
*    SELECT OBJEK
*           OBJEK1
*      FROM KSSK INTO TABLE IT_KSSK1
*           FOR ALL ENTRIES IN IT_KLAH
*            WHERE OBJEK = IT_kssk-OBJEK.
*  ENDIF.
  LOOP AT IT_KSSK INTO WA_KSSK .
    WA_KSSK1-OBJEK1 = WA_KSSK-OBJEK .
    SHIFT WA_KSSK-OBJEK LEFT DELETING LEADING '0'.
    WA_KSSK1-OBJEK = WA_KSSK-OBJEK .
    APPEND WA_KSSK1 TO IT_KSSK1 .
    CLEAR WA_KSSK1 .
  ENDLOOP.

  IF IT_KSSK1 IS NOT INITIAL .
    SELECT CLINT
           KLART
           CLASS
           VONDT
           BISDT
           WWSKZ FROM KLAH INTO TABLE IT_KLAH1
           FOR ALL ENTRIES IN IT_KSSK1
           WHERE CLINT = IT_KSSK1-OBJEK.
*           AND WWSKZ = '1'.
  ENDIF.

  IF IT_KLAH1 IS NOT INITIAL .
    SELECT SPRAS
           MATKL
           WGBEZ
           WGBEZ60
           FROM T023T INTO TABLE IT_T023T
           FOR ALL ENTRIES IN IT_KLAH1
            WHERE MATKL = IT_KLAH1-CLASS.
  ENDIF.
  IF IT_T023T IS NOT INITIAL.
    SELECT MATNR
           MATKL
          MEINS FROM MARA INTO TABLE IT_MARA
           FOR ALL ENTRIES IN IT_T023T
           WHERE MATKL = IT_T023T-MATKL.
  ENDIF.

*    IF IT_MARA IS NOT INITIAL.
*      SELECT MATNR
*             BWKEY
*             BWTAR
*             VERPR FROM MBEW INTO TABLE IT_MBEW
*             FOR ALL ENTRIES IN IT_MARA
*             WHERE MATNR = IT_MARA-MATNR AND BWKEY = S_PLANT.
*        ENDIF.
*   SELECT a~matnr a~matkl
*          b~spras b~matkl b~WGBEZ b~WGBEZ60
*           FROM mara as a INNER JOIN t023t as b
*           on b~matkl = a~matkl
*         INTO TABLE @data(it_mara1).
**         FOR ALL ENTRIES IN @it_klah1



  SELECT MBLNR
       MJAHR
       ZEILE
       LINE_ID
       BUDAT_MKPF
       MATNR
       BWART
       WERKS
       MENGE
       DMBTR FROM MSEG INTO TABLE IT_MSEG01
      FOR ALL ENTRIES IN IT_MARA
      WHERE MATNR = IT_MARA-MATNR
     AND WERKS IN S_PLANT
     AND  BUDAT_MKPF IN S_DATE
     AND BWART IN ('101').",'102') .



  SELECT MBLNR
       MJAHR
       ZEILE
       LINE_ID
       BUDAT_MKPF
       MATNR
       BWART
       WERKS
       MENGE
       DMBTR FROM MSEG INTO TABLE IT_MSEG02
      FOR ALL ENTRIES IN IT_MARA
      WHERE MATNR = IT_MARA-MATNR
     AND WERKS IN S_PLANT
     AND  BUDAT_MKPF IN S_DATE
     AND BWART IN ('102').",'102') .

  DATA(IT_MSEGD1) = IT_MSEG[] .
  DATA(IT_MSEGA1) = IT_MSEG01[].
  DATA(IT_MSEGB1) = IT_MSEG02[].
*  DELETE ADJACENT DUPLICATES FROM IT_MSEG01 COMPARING MBLNR  .
*  DELETE ADJACENT DUPLICATES FROM IT_MSEG02 COMPARING MBLNR  .
  SORT IT_MSEG01  BY MATNR.
  SORT IT_MSEG02  BY MATNR.
*  BREAK CLIKHITHA.
  LOOP AT IT_MSEG01 INTO WA_MSEG01." WHERE
    WA_MENGE01-MATNR = WA_MSEG01-MATNR.
    WA_MENGE01-DATE = WA_MSEG01-BUDAT_MKPF.
    WA_MENGE01-MENGE_M = WA_MSEG01-MENGE.
    WA_MENGE01-WERKS   = WA_MSEG01-WERKS.
    APPEND : WA_MENGE01 TO IT_MENGE01.
    CLEAR : WA_MENGE01.
  ENDLOOP.

  DATA(IT_MENGE011) = IT_MENGE01[].
*  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
***  DELETE ADJACENT DUPLICATES FROM IT_MENGE01 COMPARING MATNR  .
***  LOOP AT IT_MENGE01 ASSIGNING FIELD-SYMBOL(<WA_MENG>).
***    IF SY-SUBRC = 0.
***      WA_MENGE03-MATNR = <WA_MENG>-MATNR.
***      WA_MENGE03-DATE = <WA_MENG>-DATE.
****    wa_menge01-menge_m = <wa_meng>-menge_m.
***      WA_MENGE03-WERKS   = <WA_MENG>-WERKS.
***      LOOP AT IT_MENGE011 ASSIGNING FIELD-SYMBOL(<WA_MENG1>) WHERE MATNR = <WA_MENG>-MATNR.
***        IF SY-SUBRC = 0.
***          WA_MENGE03-MENGE_M = <WA_MENG1>-MENGE_M + WA_MENGE03-MENGE_M.
***        ENDIF.
***
***      ENDLOOP.
***    ENDIF.
***    APPEND : WA_MENGE03 TO IT_MENGE03.
***    CLEAR : WA_MENGE03.
***  ENDLOOP.

*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

  LOOP AT IT_MSEG02 INTO WA_MSEG02." WHERE
    WA_MENGE02-MATNR = WA_MSEG02-MATNR.
    WA_MENGE02-DATE = WA_MSEG02-BUDAT_MKPF.
    WA_MENGE02-MENGE_M = WA_MSEG02-MENGE.
    WA_MENGE02-WERKS   = WA_MSEG02-WERKS.
*    WA_MENGE02-MBLNR = WA_MSEG02-MBLNR.

*    LOOP AT it_msegb1 ASSIGNING FIELD-SYMBOL(<WA_MSEGB1>) WHERE mblnr = WA_MSEG02-Mblnr.
*      IF SY-SUBRC = 0.
*     wa_menge02-menge_m = wa_menge02-menge_m + <WA_MSEGB1>-menge.
*     ENDIF.
*     ENDLOOP.
    APPEND : WA_MENGE02 TO IT_MENGE02.
    CLEAR : WA_MENGE02.
  ENDLOOP.
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
***  DATA(IT_MENGE012) = IT_MENGE02[].
***  DELETE ADJACENT DUPLICATES FROM IT_MENGE02 COMPARING MATNR  .
***  LOOP AT IT_MENGE02 ASSIGNING FIELD-SYMBOL(<WA_MENG02>).
***    IF SY-SUBRC = 0.
***      WA_MENGE04-MATNR = <WA_MENG>-MATNR.
***      WA_MENGE04-DATE = <WA_MENG>-DATE.
****    wa_menge01-menge_m = <wa_meng>-menge_m.
***      WA_MENGE04-WERKS   = <WA_MENG>-WERKS.
***      LOOP AT IT_MENGE012 ASSIGNING FIELD-SYMBOL(<WA_MENG12>) WHERE MATNR = <WA_MENG>-MATNR.
***        IF SY-SUBRC = 0.
***          WA_MENGE04-MENGE_M = <WA_MENG12>-MENGE_M + WA_MENGE04-MENGE_M.
***        ENDIF.
***
***      ENDLOOP.
***    ENDIF.
***    APPEND : WA_MENGE04 TO IT_MENGE04.
***    CLEAR : WA_MENGE04.
***  ENDLOOP.

*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&



  DELETE ADJACENT DUPLICATES FROM IT_MSEG COMPARING MBLNR .
  SORT IT_MSEG BY MBLNR.

  IF IT_mara IS NOT INITIAL.
  SELECT MATNR
         WERKS
         LGORT
         LABST
          FROM MARD INTO TABLE IT_MARD
          FOR ALL ENTRIES IN IT_Mara
           WHERE MATNR = IT_Mara-MATNR AND WERKS IN S_PLANT..
   ENDIF.

*  IF IT_MSEG01 IS NOT INITIAL.
*  SELECT MATNR
*         WERKS
*         LGORT
*         LABST
*          FROM MARD INTO TABLE IT_MARD
*          FOR ALL ENTRIES IN IT_MSEG01
*           WHERE MATNR = IT_MSEG01-MATNR AND WERKS IN S_PLANT..
*   ENDIF.
*          FOR ALL ENTRIES IN IT_MENGE01
*           WHERE MATNR = IT_MENGE01-MATNR AND WERKS = IT_MENGE01-WERKS..
IF IT_MARA IS NOT INITIAL.
      SELECT MATNR
             BWKEY
             BWTAR
             VERPR FROM MBEW INTO TABLE IT_MBEW
             FOR ALL ENTRIES IN IT_MARD
             WHERE MATNR = IT_MARD-MATNR AND BWKEY = IT_MARD-WERKS.
        ENDIF.

  SELECT MBLNR
       MJAHR
       ZEILE
       LINE_ID
       BUDAT_MKPF
       MATNR
       BWART
       WERKS
       MENGE
       DMBTR FROM MSEG INTO TABLE IT_MSEG2
      FOR ALL ENTRIES IN IT_MARA
      WHERE MATNR = IT_MARA-MATNR
     AND WERKS IN S_PLANT
     AND  BUDAT_MKPF IN S_DATE
     AND BWART IN ('303') .

    SELECT MBLNR
       MJAHR
       ZEILE
       LINE_ID
       BUDAT_MKPF
       MATNR
       BWART
       WERKS
       MENGE
       DMBTR FROM MSEG INTO TABLE IT_MSEG3
      FOR ALL ENTRIES IN IT_MARA
      WHERE MATNR = IT_MARA-MATNR
     AND WERKS IN S_PLANT
     AND  BUDAT_MKPF IN S_DATE
     AND BWART IN ('304') .



  DATA(IT_MSEGD3) = IT_MSEG2[] .
  DATA(IT_MSEGD4) = IT_MSEG3[] .

*  DELETE ADJACENT DUPLICATES FROM IT_MSEG2 COMPARING MBLNR .
*break clikhitha.
 LOOP AT IT_MSEG2 INTO WA_MSEG2." WHERE
    WA_MENGEc1-MATNR = WA_MSEG2-MATNR.
    WA_MENGEc1-DATE = WA_MSEG2-BUDAT_MKPF.
    WA_MENGEc1-MENGE_M = WA_MSEG2-MENGE.
    WA_MENGEc1-WERKS   = WA_MSEG2-WERKS.
    APPEND : WA_MENGEc1 TO IT_MENGEc1.
    CLEAR : WA_MENGEc1.
  ENDLOOP.
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
***  DATA(IT_MENGEc11) = IT_MENGEc1[].
***  DELETE ADJACENT DUPLICATES FROM IT_MENGEc1 COMPARING MATNR  .
***  DATA(IT_MEgc11) = IT_MENGEc1[].
***  LOOP AT IT_MEGc11 ASSIGNING FIELD-SYMBOL(<WA_MENGc1>).
***    IF SY-SUBRC = 0.
***      WA_MENGEc2-MATNR = <WA_MENGc1>-MATNR.
***      WA_MENGEc2-DATE = <WA_MENGc1>-DATE.
****    wa_menge01-menge_m = <wa_meng>-menge_m.
***      WA_MENGEc2-WERKS   = <WA_MENGc1>-WERKS.
***      LOOP AT IT_MENGEc11 ASSIGNING FIELD-SYMBOL(<WA_MENGc11>) WHERE MATNR = <WA_MENGc1>-MATNR.
***        IF SY-SUBRC = 0.
***          WA_MENGEc2-MENGE_M = <WA_MENGc11>-MENGE_M + WA_MENGEc2-MENGE_M.
***        ENDIF.
***      ENDLOOP.
***    ENDIF.
***    APPEND : WA_MENGEc2 TO IT_MENGEc2.
***    CLEAR : WA_MENGEc2.
***  ENDLOOP.
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
*  DELETE ADJACENT DUPLICATES FROM IT_MSEG3 COMPARING MBLNR .

 LOOP AT IT_MSEG3 INTO WA_MSEG3." WHERE
    WA_MENGEc3-MATNR = WA_MSEG3-MATNR.
    WA_MENGEc3-DATE = WA_MSEG3-BUDAT_MKPF.
    WA_MENGEc3-MENGE_M = WA_MSEG3-MENGE.
    WA_MENGEc3-WERKS   = WA_MSEG3-WERKS.
    APPEND : WA_MENGEc3 TO IT_MENGEc3.
    CLEAR : WA_MENGEc3.
  ENDLOOP.
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
***  DATA(IT_MENGEc13) = IT_MENGEc3[].
***  DELETE ADJACENT DUPLICATES FROM IT_MENGEc3 COMPARING MATNR  .
***  LOOP AT IT_MENGEc3 ASSIGNING FIELD-SYMBOL(<WA_MENGc3>).
***    IF SY-SUBRC = 0.
***      WA_MENGEc4-MATNR = <WA_MENGc3>-MATNR.
***      WA_MENGEc4-DATE = <WA_MENGc3>-DATE.
****    wa_menge01-menge_m = <wa_meng>-menge_m.
***      WA_MENGEc4-WERKS   = <WA_MENGc3>-WERKS.
***      LOOP AT IT_MENGEc13 ASSIGNING FIELD-SYMBOL(<WA_MENGc13>) WHERE MATNR = <WA_MENGc3>-MATNR.
***        IF SY-SUBRC = 0.
***          WA_MENGEc4-MENGE_M = <WA_MENGc13>-MENGE_M + WA_MENGEc4-MENGE_M.
***        ENDIF.
***      ENDLOOP.
***    ENDIF.
***    APPEND : WA_MENGEc4 TO IT_MENGEc4.
***    CLEAR : WA_MENGEc4.
***  ENDLOOP.

*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&



**  SORT IT_MSEG BY MBLNR.
**
  DATA(IT_T023TD) = IT_T023T[] .
***   DELETE ADJACENT DUPLICATES FROM IT_t023t COMPARING matkl .
break clikhitha.
loop at it_mara INTO wa_mara.
*LOOP AT it_t023t INTO wa_t023t.

  LOOP at it_MARD INTO wa_MARD WHERE matnr = WA_MARA-matnr .
*      if sy-subrc = 0.
       wa_final-menge05 = wa_MARD-LABST + wa_final-menge05.
*       ENDIF.
       endloop.
  READ TABLE it_t023t INTO wa_t023t with key matkl = wa_mara-matkl.
*  if sy-subrc = 0.
      wa_final-CATEGORY = wa_t023t-matkl.
      wa_final-WGBEZ60 = wa_t023t-WGBEZ60.
*      ENDIF .

*      LOOP at it_MARD INTO wa_MARD WHERE matnr = WA_MARA-matnr .
*      if sy-subrc = 0.
*       wa_final-menge05 = wa_MARD-LABST + wa_final-menge05.
*       ENDIF.
*       endloop.

       LOOP at it_MBEW INTO wa_MBEW WHERE matnr = WA_MARD-matnr .
      if sy-subrc = 0.
       wa_final-VERPR = wa_MBEW-VERPR + wa_final-VERPR.
       ENDIF.
       endloop.

*      READ TABLE it_mara INTO wa_mara with key matkl = wa_t023t-matkl.
*      READ TABLE IT_MENGE01 INTO wa_MENGE01 with key matnr = wa_mara-matnr.
      LOOP at it_MENGE01 INTO wa_MENGE01 WHERE matnr = wa_mara-matnr.
*      if sy-subrc = 0.
       wa_final-menge01 = wa_menge01-menge_m + wa_final-menge01.
*      ENDIF.
      endloop.
*      READ TABLE IT_MENGE02 INTO wa_MENGE02 with key matnr = wa_mara-matnr.
      LOOP at it_MENGE02 INTO wa_MENGE02 WHERE matnr = wa_mara-matnr.
*      if sy-subrc = 0.
       wa_final-menge02 = wa_menge02-menge_m + wa_final-menge02.
*       wa_final-GRPO_QTY = wa_menge01-menge_m - wa_menge01-menge_m.
*       ENDIF.
       endloop.
      LOOP at it_MENGEC1 INTO wa_MENGEC1 WHERE matnr = wa_mara-matnr.
*      if sy-subrc = 0.
       wa_final-menge03 = wa_mengeC1-menge_m + wa_final-menge03.
*       ENDIF.
       endloop.
        LOOP at it_MENGEC2 INTO wa_MENGEC2 WHERE matnr = wa_mara-matnr.
*      if sy-subrc = 0.
       wa_final-menge04 = wa_mengeC2-menge_m + wa_final-menge04.
*       ENDIF.
       endloop.
*    READ TABLE IT_MARD INTO wa_MARD WITH KEY matnr = WA_MSEG01-matnr .
*    wa_final-menge05 = wa_MARD-LABST.
*       LOOP at it_MARD INTO wa_MARD WHERE matnr = WA_MSEG01-matnr .
*      if sy-subrc = 0.
*       wa_final-menge05 = wa_MARD-LABST + wa_final-menge05.
*       ENDIF.
*       endloop.


       WA_FINAL-DC_QTY = wa_final-menge03 - wa_final-menge04.
       wa_final-GRPO_QTY = wa_final-menge01 - wa_final-menge02.
       wa_final-OPEN_QTY = wa_final-menge05 - wa_final-GRPO_QTY.
       wa_final-AVAL_QTY = ( wa_final-GRPO_QTY + wa_final-OPEN_QTY ) ."- WA_FINAL-DC_QTY.
       wa_final-TOT_COST = wa_final-VERPR * wa_final-AVAL_QTY.
*       WA_FINAL-CHECK = 'X'.
*       wa_final-radio = icon_wd_radio_button_empty.
      APPEND wa_final TO it_final.
      CLEAR : wa_final, wa_t023t,wa_mara,wa_MENGE01,wa_MENGE02 .
  ENDLOOP.
  break clikhitha.
****************&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
****  LOOP AT IT_MSEG01 INTO WA_MSEG01.
**  LOOP AT IT_Menge03 INTO WA_Menge03.
*******LOOP AT it_t023t INTO wa_t023t.
**    IF SY-SUBRC = 0.
**      WA_FINAL-MENGE01 = WA_menge03-MENGE_m.
**    ENDIF.
**    READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_menge03-MATNR.
**    READ TABLE IT_MENGE04 INTO WA_MENGE02 WITH KEY MATNR = WA_mara-MATNR.
**    IF SY-SUBRC = 0.
**      WA_FINAL-MENGE02 =   WA_menge02-MENGE_m.
**      wa_final-GRPO_QTY = WA_menge03-MENGE_m - WA_menge02-MENGE_m.
**    ENDIF.
******     READ TABLE it_mara INTO wa_mara with key matKL = wa_T023T-matKL.
**    READ TABLE IT_KLAH1 INTO WA_KLAH1 WITH KEY CLASS = WA_MARA-MATKL .
**    READ TABLE IT_KSSK1 INTO WA_KSSK1 WITH KEY OBJEK = WA_KLAH1-CLINT .
**    READ TABLE IT_KSSK INTO WA_KSSK WITH KEY OBJEK   = WA_KSSK1-OBJEK1 .
**    READ TABLE IT_KLAH INTO WA_KLAH WITH KEY CLINT   = WA_KSSK-CLINT .
**    IF SY-SUBRC = 0.
**      WA_FINAL-CATEG  = WA_KLAH-CLASS .
**    ENDIF.
******    READ TABLE IT_MSEG INTO WA_MSEG WITH KEY MATNR   = WA_MARA-MATNR .
******     wa_final-GRPO_QTY =  wa_mseg-menge.
******    wa_final-OPEN_QTY =   wa_mseg-menge.
**    READ TABLE IT_T023T INTO WA_T023T WITH KEY MATKL = WA_MARA-MATKL.
**    IF SY-SUBRC = 0.
**      WA_FINAL-CATEGORY = WA_T023T-MATKL.
**      WA_FINAL-WGBEZ60 = WA_T023T-WGBEZ60.
**    ENDIF .
***BREAK CLIKHITHA.
**    READ TABLE IT_MARD ASSIGNING FIELD-SYMBOL(<WA_MARD1>) WITH KEY MATNR = WA_MARA-MATNR." werks = s_plant.
**    IF SY-SUBRC = 0.
**      WA_FINAL-OPEN_QTY =  <WA_MARD1>-LABST - wa_final-GRPO_QTY." + wa_final-OPEN_ATY.
**    ENDIF.
**    READ TABLE IT_MSEGD3 ASSIGNING FIELD-SYMBOL(<WA_MSEGD3>) WITH KEY MATNR = WA_MARA-MATNR." budat_mkpf =
**    IF SY-SUBRC = 0.
**      WA_FINAL-DC_QTY =  <WA_MSEGD3>-MENGE." + wa_final-DC_QTY.
**    ENDIF.
**    APPEND WA_FINAL TO IT_FINAL.
**    CLEAR : WA_FINAL  , WA_MSEG01 ,WA_MSEG02,WA_MARA,WA_T023T.
**
**  ENDLOOP.
**  BREAK CLIKHITHA.
***  IT_FINAL2[] = IT_FINAL.
***  SORT IT_FINAL2 BY CATEGORY.
***  DELETE ADJACENT DUPLICATES FROM IT_FINAL2 COMPARING CATEGORY.
***
***  LOOP AT IT_FINAL2 ASSIGNING FIELD-SYMBOL(<WA_FINAL2>).
***    IF SY-SUBRC = 0.
***      WA_FIN-CATEGORY = <WA_FINAL2>-CATEGORY.
***      WA_FIN-WGBEZ60 = <WA_FINAL2>-WGBEZ60.
***    ENDIF.
***    LOOP AT IT_FINAL ASSIGNING FIELD-SYMBOL(<WA_FINAL0>) WHERE CATEGORY = <WA_FINAL2>-CATEGORY.
***      IF SY-SUBRC = 0.
***        WA_FIN-GRPO_QTY = <WA_FINAL0>-GRPO_QTY + WA_FIN-GRPO_QTY.
***        WA_FIN-MENGE01 = <WA_FINAL0>-OPEN_QTY + WA_FIN-MENGE01.
***        WA_FIN-MENGE02 = <WA_FINAL0>-OPEN_QTY + WA_FIN-MENGE02.
***        WA_FIN-DC_QTY = <WA_FINAL0>-DC_QTY + WA_FIN-DC_QTY.
***      ENDIF.
***    ENDLOOP.
***    WA_FIN-OPEN_QTY = WA_FIN-GRPO_QTY - WA_FIN-GRPO_QTY.
***    APPEND WA_FIN TO IT_FIN.
***    CLEAR : WA_FIN.
***
***  ENDLOOP.



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
  DATA : WA_LAYOUT   TYPE SLIS_LAYOUT_ALV.
  DATA: IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
        WA_FIELDCAT TYPE SLIS_FIELDCAT_ALV.
*        WVARI       TYPE DISVARIANT.

  DATA: IT_SORT TYPE SLIS_T_SORTINFO_ALV,
        WA_SORT TYPE SLIS_SORTINFO_ALV.

*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&


*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&






  data : WA_LAY  TYPE LVC_S_LAYO.
*
   wa_lay-zebra = abap_true .
   wa_lay-cwidth_opt = abap_true .
   wa_lay-stylefname = 'STYLE'.


  WA_FIELDCAT-FIELDNAME = 'CATEGORY'.
  WA_FIELDCAT-SELTEXT_L =  'CATEGORY CODE'.
*  wa_FIELDCAT-outputlen = '100'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR   WA_FIELDCAT  .

  WA_FIELDCAT-FIELDNAME = 'WGBEZ60'.
  WA_FIELDCAT-SELTEXT_L =  'CATEGORY DESCRIPTION'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR   WA_FIELDCAT  .

  WA_FIELDCAT-FIELDNAME = 'OPEN_QTY'.
  WA_FIELDCAT-SELTEXT_L =  'OPENING QUANTITY'.
*  wa_FIELDCAT-outputlen = '100'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR   WA_FIELDCAT  .

  WA_FIELDCAT-FIELDNAME = 'GRPO_QTY'.
  WA_FIELDCAT-SELTEXT_L =  'GRPO QUANTITY'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR   WA_FIELDCAT  .

  WA_FIELDCAT-FIELDNAME = 'DC_QTY'.
  WA_FIELDCAT-SELTEXT_L =  'DC QUANTITY'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR   WA_FIELDCAT  .

  WA_FIELDCAT-FIELDNAME = 'AVAL_QTY'.
  WA_FIELDCAT-SELTEXT_L =  'AVAILABLE QUANTITY'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR   WA_FIELDCAT  .

   WA_FIELDCAT-FIELDNAME = 'TOT_COST'.
  WA_FIELDCAT-SELTEXT_L =  'TOTAL COST'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR   WA_FIELDCAT  .
BREAK CLIKHITHA.
   WA_FIELDCAT-FIELDNAME = 'CHECK'.
*   WA_FIELDCAT-FIELDNAME = 'CHECK2'.
  WA_FIELDCAT-SELTEXT_L =  'WASTAGE'.
*  WA_FIELDCAT-tabname = 'IT_FINAL'.
*  WA_FIELDCAT-input =  'X'.
  WA_FIELDCAT-CHECKBOX = 'X'.
  WA_FIELDCAT-EDIT     = 'X'.


  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR   WA_FIELDCAT  .



  WA_FIELDCAT-FIELDNAME = 'CHECK2'.
  WA_FIELDCAT-SELTEXT_L =  'PHYSICAL AVAILABLE'.
  WA_FIELDCAT-CHECKBOX = 'X'.
  WA_FIELDCAT-EDIT     = 'X'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR   WA_FIELDCAT  .

*  WA_FIELDCAT-FIELDNAME = 'RADIO'.
*  WA_FIELDCAT-SELTEXT_L =  'PHYSICAL'.
*  WA_FIELDCAT-KEY = 'X' .
*  WA_FIELDCAT-HOTSPOT = 'X' .
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*  CLEAR   WA_FIELDCAT .




*  wa_lay-zebra = abap_true .
*  wa_lay-cwidth_opt = abap_true .

  WA_LAYOUT-ZEBRA = abap_true."'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = abap_true."'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'

    EXPORTING
*     I_INTERFACE_CHECK       = ' '
*     I_BYPASSING_BUFFER      = ' '
*      I_BUFFER_ACTIVE         = ' '
      I_CALLBACK_PROGRAM      = SY-REPID
     I_CALLBACK_PF_STATUS_SET          = 'SET_PF_STATUS'
*     I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
*     I_CALLBACK_TOP_OF_PAGE  = ' '
     I_CALLBACK_HTML_TOP_OF_PAGE       = 'TOP_OF_PAGE1'
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME        =
*     I_BACKGROUND_ID         = ' '
*     I_GRID_TITLE            =
*     I_GRID_SETTINGS         =
      IS_LAYOUT               = WA_LAYOUT
      I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
      IT_FIELDCAT             = IT_FIELDCAT
*     IT_EXCLUDING            =
*     IT_SPECIAL_GROUPS       =
      IT_SORT                 = IT_SORT
*     IT_FILTER               =
*     IS_SEL_HIDE             =
      I_DEFAULT               = 'X'
      I_SAVE                  = 'A'
*     IS_VARIANT              =
*     IT_EVENTS               =
*     IT_EVENT_EXIT           =
*     IS_PRINT                =
*     IS_REPREP_ID            =
*     I_SCREEN_START_COLUMN   = 0
*     I_SCREEN_START_LINE     = 0
*     I_SCREEN_END_COLUMN     = 0
*     I_SCREEN_END_LINE       = 0
*     I_HTML_HEIGHT_TOP       = 0
*     I_HTML_HEIGHT_END       = 0
*     IT_ALV_GRAPHICS         =
*     IT_HYPERLINK            =
*     IT_ADD_FIELDCAT         =
*     IT_EXCEPT_QINFO         =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER =
*     ES_EXIT_CAUSED_BY_USER  =
    TABLES
      T_OUTTAB                = IT_FINAL
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_EXCLUDE
*&---------------------------------------------------------------------*
*FORM exclude_tb_functions  CHANGING lt_exclude TYPE ui_functions.

*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

FORM top_of_page1 USING top TYPE REF TO cl_dd_document.
  DATA: lv_top1  TYPE sdydo_text_element,
        lv_date TYPE sdydo_text_element,
        lv_to1   TYPE sdydo_text_element.

 data: l_date type string,
                gd_day(2),   "field to store day 'DD'
                gd_month(2), "field to store month 'MM'
                gd_year(4).  "field to store year 'YYYY'
  lv_top1 = s_plant-low .
  IF S_PLANT IS NOT INITIAL.
    SELECT WERKS
           NAME1
           FROM T001W
           INTO TABLE IT_T001W
           WHERE WERKS IN S_PLANT.
    ENDIF.
    READ TABLE IT_T001W INTO WA_T001W INDEX 1.
    lv_top1 = WA_T001W-NAME1.
  CONCATENATE  'Plant' lv_top1  INTO lv_top1 SEPARATED BY '-' .
  CALL METHOD top->add_text
    EXPORTING
      text      = lv_top1
      sap_style = 'HEADING'.
*     to move to next line
  CALL METHOD top->new_line.
  IF s_date[] IS NOT INITIAL.
    lv_date = s_date-low .
    gd_day(2)   = lv_date+6(2).
      gd_month(2) = lv_date+4(2).
      gd_year(4)  = lv_date(4).
*    SPLIT lv_date
    concatenate gd_day gd_month gd_year into l_date separated by '.'.
  CONCATENATE  'Date' l_date  INTO lv_date SEPARATED BY '-' .
  CALL METHOD top->add_text
    EXPORTING
      text      = lv_date
      sap_style = 'HEADING'.
  ENDIF.

ENDFORM .

FORM SET_PF_STATUS USING RT_EXTAB   TYPE  SLIS_T_EXTAB.

  SET PF-STATUS 'ZSTAT' EXCLUDING RT_EXTAB.

ENDFORM.

*FORM user_command USING r_ucomm LIKE sy-ucomm
*                  rs_selfield TYPE slis_selfield.
FORM user_command USING  sy-ucomm rs_selfield TYPE slis_selfield.
  BREAK CLIKHITHA.

  DATA : REF_GRID TYPE REF TO CL_GUI_ALV_GRID.
  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'   "This FM will get the reference of the changed data in ref_grid
    IMPORTING
      E_GRID = REF_GRID.

  IF REF_GRID IS NOT INITIAL.
    CALL METHOD REF_GRID->CHECK_CHANGED_DATA( ).
  ENDIF.

  CASE sy-ucomm.
*  CASE R_UCOMM.
*    rs_selfield-fieldname = 'X'.
    WHEN 'SAV'.


*      IF IT_FINAL-CHECK = 'X'.
*      head = rs_selfield-fieldname.
      rs_selfield-fieldname = 'x'.
*      READ TABLE it_final INTO  wa_final INDEX RS_SELFIELD-TABINDEX."
*      LOOP AT IT_FINAL INTO WA_FINAL  RS_SELFIELD-TABINDEX.
*      IF sy-subrc = 0.
*        IF rs_selfield-fieldname  = 'X'.
          PERFORM GET_DATA ."USING <ls_final>-date rs_selfield-tabindex.
*          ENDIF.
*          ENDIF.
      ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_FINAL>_DATE
*&      --> RS_SELFIELD_TABINDEX
*&---------------------------------------------------------------------*
FORM GET_DATA ." USING    P_<LS_FINAL>_DATE
                     "   P_RS_SELFIELD_TABINDEX.



  DATA:
    ls_gmvt_header  TYPE bapi2017_gm_head_01,
    ls_gmvt_item    TYPE bapi2017_gm_item_create,
    ls_gmvt_headret TYPE bapi2017_gm_head_ret,
    lt_bapiret      TYPE STANDARD TABLE OF bapiret2,
    lw_return1      TYPE bapiret2,
    lt_gmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    lv_line_id      TYPE mb_line_id,
    lv_diff(1).
  FIELD-SYMBOLS :
    <ls_bapiret> TYPE bapiret2.
BREAK CLIKHITHA.
   CHECK wa_hdr-mblnr_201 IS INITIAL.
    ls_gmvt_header-pstng_date = sy-datum.
  ls_gmvt_header-doc_date   = sy-datum.
  ls_gmvt_header-pr_uname   = sy-uname.
  ls_gmvt_header-ver_gr_gi_slip   = 1.
  lv_line_id = '000001'.

 DATA(IT_FINN) = IT_FINAL[] .
* DATA(IT_MARA2) = IT_MARA[].
  LOOP AT IT_FINAL ASSIGNING FIELD-SYMBOL(<LS_FINAL>) WHERE CHECK = 'X'.
    MOVE-CORRESPONDING  <LS_FINAL> TO WA_FINAL2 .

    APPEND : WA_FINAL2 TO IT_FINAL2.
    CLEAR : WA_FINAL2.
   ENDLOOP.
 SELECT MATNR
        MATKL
        MEINS FROM MARA INTO TABLE IT_MARA2 FOR ALL ENTRIES IN IT_FINAL2
        WHERE MATKL = IT_FINAL2-CATEGORY.

*   LOOP AT IT_MARA2 ASSIGNING FIELD-SYMBOL(<LS_ITEM>) .
     LOOP AT  IT_FINAL2 ASSIGNING FIELD-SYMBOL(<WA_FIN>)." WITH KEY CATEGORY = <LS_ITEM>-MATKL.
       READ TABLE IT_MARA2 ASSIGNING FIELD-SYMBOL(<LS_ITEM>) WITH KEY MATKL = <WA_FIN>-CATEGORY.
     ls_gmvt_item-material  = ls_gmvt_item-material_long =   <LS_ITEM>-MATNR.
     ls_gmvt_item-move_type = '201'.
     ls_gmvt_item-plant     = WA_T001W-WERKS.
*     ls_gmvt_item-batch     = ls_gmvt_item-val_type
     ls_gmvt_item-entry_qnt = <WA_FIN>-AVAL_QTY.
     ls_gmvt_item-entry_uom = <LS_ITEM>-MEINS.
     ls_gmvt_item-entry_uom_iso = 'KGM'.
     ls_gmvt_item-stge_loc      = 'FG01'.
     ls_gmvt_item-gl_account    = '0000620100'.
  IF SY-sysid = 'SDS'.
     ls_gmvt_item-costcenter    = '0000010000'.
  ELSE.
    ls_gmvt_item-costcenter    = '0009100000'.
  ENDIF.
  ls_gmvt_item-line_id   = lv_line_id.
    APPEND ls_gmvt_item TO lt_gmvt_item.
    CLEAR ls_gmvt_item.
    lv_line_id = lv_line_id + 1.
   ENDLOOP.
   DATA(c_mvt_03) = '03'.

   CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
     EXPORTING
       GOODSMVT_HEADER               = ls_gmvt_header
       GOODSMVT_CODE                 = c_mvt_03
*      TESTRUN                       = ' '
*      GOODSMVT_REF_EWM              =
*      GOODSMVT_PRINT_CTRL           =
    IMPORTING
      GOODSMVT_HEADRET              = ls_gmvt_headret
*      MATERIALDOCUMENT              =
*      MATDOCUMENTYEAR               =
     TABLES
       GOODSMVT_ITEM                 = lt_gmvt_item
*      GOODSMVT_SERIALNUMBER         =
       RETURN                        = lt_bapiret.
*      GOODSMVT_SERV_PART_DATA       =
*      EXTENSIONIN                   =
*      GOODSMVT_ITEM_CWM             =
             .
 READ TABLE lt_bapiret ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E'.
  IF sy-subrc <> 0 .

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
     EXPORTING
       WAIT          = 'X'.
wa_hdr-mblnr_201 = ls_gmvt_headret-mat_doc.

                    APPEND VALUE #( type  = 'S'
                                   id    = 'MIGO'
                                   txtnr = '012'
                                   msgv1 = wa_hdr-mblnr_201  ) TO it_log.

                    IF IT_LOG IS NOT INITIAL.
*                      MESSAGE  MSGV1 'Material Document is Succesfully Created'
                      CONCATENATE  'Material Document is Succesfully Created' wa_hdr-mblnr_201 INTO  MSGV3 .
                      MESSAGE MSGV3 TYPE 'S'.
                      ENDIF.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
*     IMPORTING
*       RETURN        =
              .
    gv_subrc = 4.
        LOOP AT lt_bapiret INTO lw_return1 WHERE type = 'E'.

            APPEND VALUE #( type  = lw_return1-type
                            id    = lw_return1-id
                            txtnr = lw_return1-number
                            msgv1 = lw_return1-message_v1
                            msgv2 = lw_return1-message_v2 ) TO it_log.
        ENDLOOP.

        REFRESH  lt_bapiret .

        CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
          EXPORTING
            MATERIALDOCUMENT          = wa_hdr-mblnr_542
            MATDOCUMENTYEAR           = SY-DATUM+0(4)
           GOODSMVT_PSTNG_DATE       =  SY-DATUM
*           GOODSMVT_PR_UNAME         =
*           DOCUMENTHEADER_TEXT       =
*         IMPORTING
*           GOODSMVT_HEADRET          =
          TABLES
            RETURN                    = lt_bapiret.
*           GOODSMVT_MATDOCITEM       =
                  .







ENDIF.
ENDFORM.
