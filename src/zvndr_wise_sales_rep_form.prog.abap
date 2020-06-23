*&---------------------------------------------------------------------*
*& Include          ZVNDR_WISE_SALES_REP_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*

FORM SELECT_DATA .
*  BREAK mumair.

  SELECT     CLINT
             KLART
             CLASS
             VONDT
             BISDT
             WWSKZ FROM KLAH INTO TABLE IT_KLAH
             WHERE WWSKZ = '0' AND CLASS IN S_CLASS
             AND   KLART = '026' .

*****           MSEG~MBLNR,
*****           MSEG~MJAHR,
*****           MSEG~ZEILE,
*****           MSEG~BUDAT_MKPF,
*****           MSEG~MATNR,
*****           MSEG~BWART,
*****           MSEG~WERKS,
*****           MSEG~MENGE,
*****           MSEG~DMBTR,
*****           MARA~MATKL
******           a502~matnr
******           a502~lifnr
******           a502~kschl
******           a502~knumh
*****
*****            FROM MSEG INNER JOIN MARA as mara ON mara~MATNR = Mseg~MATNR
*****
*****    WHERE BUDAT_MKPF IN @S_BUDAT
*****    AND WERKS IN ('SSTN', 'SSPU', 'SSCP', 'SSPO' )"@S_PLANT
*****  AND BWART IN ('251','252') INTO TABLE @DATA(IT_MSEG).
     SELECT
           MSEG~MBLNR,
           MSEG~MJAHR,
           MSEG~ZEILE,
           MSEG~BUDAT_MKPF,
           MSEG~MATNR,
           MSEG~BWART,
           MSEG~WERKS,
           MSEG~MENGE,
           MSEG~DMBTR,
           MSEG~CHARG,
           MARA~MATKL

          FROM MSEG INNER JOIN MARA AS MARA ON MARA~MATNR = MSEG~MATNR
    WHERE MSEG~BUDAT_MKPF IN @S_BUDAT
    AND MSEG~WERKS IN ('SSTN', 'SSPU', 'SSCP', 'SSPO' )"@S_PLANT
  AND MSEG~BWART IN ('251','252') INTO TABLE @DATA(IT_MSEG).


    SELECT
    VBELN,
    POSNR,
    NETWR,
    PRSDT,
    WERKS,
    FKIMG,
    MATNR,
    CHARG
    FROM VBRP INTO TABLE @DATA(IT_VBRP)
    FOR ALL ENTRIES IN @IT_MSEG
    WHERE WERKS = @IT_MSEG-WERKS AND PRSDT = @IT_MSEG-BUDAT_MKPF AND MATNR = @IT_MSEG-MATNR AND CHARG = @IT_MSEG-CHARG.

IF IT_MSEG IS NOT INITIAL.
  SELECT   MATNR
           CHARG
           LIFNR
           FROM MCH1 INTO TABLE IT_MCH1 FOR ALL ENTRIES IN IT_MSEG WHERE MATNR = IT_MSEG-MATNR AND CHARG = IT_MSEG-CHARG.
*  SELECT   MATNR
*           LIFNR
*           KSCHL
*           KNUMH
*           FROM A502 INTO TABLE IT_A502 FOR ALL ENTRIES IN IT_MSEG WHERE MATNR = IT_MSEG-MATNR.
 ENDIF.
  SELECT  KLAH~CLASS,
          KLAH~CLINT,
          KSSK~OBJEK,
          KLAH1~CLASS AS MATKL INTO TABLE @DATA(LT_DATA)
          FROM KLAH AS KLAH INNER JOIN KSSK AS KSSK ON KSSK~CLINT = KLAH~CLINT
          INNER JOIN KLAH AS KLAH1 ON KSSK~OBJEK = KLAH1~CLINT
            WHERE KLAH~KLART = '026' AND KLAH~CLASS IN @S_CLASS AND KLAH~WWSKZ = '0'.


*****  SELECT mblnr
*****         mjahr
*****         bwart
*****         matnr
*****         budat_mkpf
*****         werks
*****         FROM mseg INTO TABLE it_mseg WHERE  budat_mkpf IN s_budat AND bwart IN ('251', '252')
*****         AND werks IN ('SSTN', 'SSPU', 'SSCP', 'SSPO' ).
*****  IF it_mseg IS NOT INITIAL.
*****    SELECT matnr
*****           erdat
*****           matkl
*****           werks
*****           fkimg
*****           netwr
*****           prsdt
*****           FROM vbrp INTO TABLE it_vbrp FOR ALL ENTRIES IN it_mseg WHERE matnr = it_mseg-matnr AND PRSDT = IT_MSEG-BUDAT_MKPF. "erdat = it_mseg-budat_mkpf.
*****
*****    SELECT matnr
*****           lifnr
*****           kschl
*****           knumh
*****           FROM a502 INTO TABLE it_a502 FOR ALL ENTRIES IN it_mseg WHERE matnr = it_mseg-matnr.
*****
*****SELECT     matnr
*****           matkl
*****           FROM mara INTO TABLE it_mara FOR ALL ENTRIES IN it_mseg WHERE matnr = it_mseg-matnr .
*****
*****    SELECT werks
*****           name1
*****           bwkey
*****           kunnr
*****           lifnr
*****           FROM t001w INTO TABLE it_t001w FOR ALL ENTRIES IN it_mseg WHERE werks = it_mseg-werks.
*****
******    SELECT matnr
******           matkl
******           FROM mara INTO TABLE it_mara FOR ALL ENTRIES IN it_mseg WHERE matnr = it_mseg-matnr .
*****  ENDIF.
*****
*****  IF it_a502 IS NOT INITIAL.
*****    SELECT kschl
*****           loevm_ko
*****           lifnr
*****           knumh
*****           FROM konp INTO TABLE it_konp FOR ALL ENTRIES IN it_a502 WHERE knumh = it_a502-knumh
*****           AND loevm_ko = ' '. "Deletion Indicator
*****  ENDIF.
*****
******---->>> ( Get Group Hierarchy ) mumair <<< 24.09.2019 16:26:26
*****  SELECT klah~class,
*****         klah~clint,
*****         kssk~objek,
*****         klah1~class AS matkl INTO TABLE @DATA(gt_data)
*****         FROM klah AS klah INNER JOIN kssk AS kssk ON kssk~clint = klah~clint
*****         INNER JOIN klah AS klah1 ON kssk~objek = klah1~clint
*****         WHERE klah~klart = '026' AND klah~wwskz = '0'  AND klah~class IN @s_class.

*data: ls_data like LINE OF gt_data.
*  LOOP AT gt_data INTO ls_data. "*---->>> ( For class Hierarchy ) mumair <<< 24.09.2019 17:28:41
*    READ TABLE it_mara INTO wa_mara WITH KEY matkl = ls_data-matkl.
*    IF sy-subrc = 0.
*      ls_data-class = wa_mara-matkl.
*    ENDIF.
*  ENDLOOP.
*BREAK MPATIL.
***** LOOP AT IT_MSEG INTO DATA(WA_MSEG).
*****
*****    WA_ITEM-MATKL      = WA_MSEG-MATKL.
*****    WA_ITEM-MATNR      = WA_MSEG-MATNR.

*****READ TABLE IT_MCH1 INTO WA_MCH1 WITH KEY MATNR = WA_MSEG-MATNR             "ADDED BY MPATIL 23/12/2019
*****                                         CHARG = WA_MSEG-CHARG.
*****IF SY-SUBRC = 0.
*****WA_ITEM-LIFNR = WA_MCH1-LIFNR .
*****ENDIF.

*READ TABLE IT_A502 INTO WA_A502 WITH KEY MATNR = WA_MSEG-MATNR.           " COMMENTED BY MPATIL 23/12/2019
*    IF SY-SUBRC = 0.
*    WA_ITEM-LIFNR = WA_A502-LIFNR.
*    ENDIF.


********** READ TABLE  IT_VBRP INTO DATA(WA_VBRP) WITH KEY WERKS = WA_MSEG-WERKS
**********                                                 MATNR = WA_MSEG-MATNR
**********                                                 PRSDT = WA_MSEG-BUDAT_MKPF
**********                                                 CHARG = WA_MSEG-CHARG.

* IF SY-SUBRC = 0.
*LOOP AT IT_VBRP1 INTO DATA(WA_VBRP1) WHERE VBELN = WA_VBRK-VBELN.
*BREAK MPATIL.
LOOP AT IT_VBRP INTO DATA(WA_VBRP). "WHERE VBELN = WA_VBRK-VBELN AND WERKS = WA_MSEG-WERKS.
    CASE WA_VBRP-WERKS.
      WHEN 'SSTN'.   "T. Nagar
        WA_ITEM-LIFNR =  WA_MCH1-LIFNR .      "Vendor Code. WA_ITEM-LIFNR =  WA_A502-LIFNR .
        WA_ITEM-QTY   =  WA_VBRP-FKIMG .      " Qty
        WA_ITEM-VALUE =  WA_VBRP-NETWR .      "Value

      WHEN 'SSPU'.    "PURUSAIWALAM
        WA_ITEM-LIFNR  =  WA_MCH1-LIFNR .                  "WA_ITEM-LIFNR =  WA_A502-LIFNR .
        WA_ITEM-QTY1   =  WA_VBRP-FKIMG .
        WA_ITEM-VALUE1 =  WA_VBRP-NETWR .

      WHEN 'SSCP'.    "CHROMPET
        WA_ITEM-LIFNR  =  WA_MCH1-LIFNR .                  "WA_ITEM-LIFNR =  WA_A502-LIFNR .
        WA_ITEM-QTY2   =  WA_VBRP-FKIMG .
        WA_ITEM-VALUE2 =  WA_VBRP-NETWR .

      WHEN 'SSPO'.    "PORUR
        WA_ITEM-LIFNR  =  WA_MCH1-LIFNR .                  "WA_ITEM-LIFNR =  WA_A502-LIFNR .
        WA_ITEM-QTY3   =  WA_VBRP-FKIMG .
        WA_ITEM-VALUE3 =  WA_VBRP-NETWR .
    ENDCASE.
*ENDIF.
*ENDLOOP.
READ TABLE IT_MSEG INTO DATA(WA_MSEG) WITH KEY WERKS = WA_VBRP-WERKS
                                               MATNR = WA_VBRP-MATNR
                                               BUDAT_MKPF = WA_VBRP-PRSDT
                                               CHARG = WA_VBRP-CHARG.
    WA_ITEM-MATKL      = WA_MSEG-MATKL.
    WA_ITEM-MATNR      = WA_MSEG-MATNR.

READ TABLE IT_MCH1 INTO WA_MCH1 WITH KEY MATNR = WA_MSEG-MATNR             "ADDED BY MPATIL 23/12/2019
                                         CHARG = WA_MSEG-CHARG.
IF SY-SUBRC = 0.
WA_ITEM-LIFNR = WA_MCH1-LIFNR .
ENDIF.

    READ TABLE LT_DATA INTO LS_DATA WITH KEY MATKL = WA_MSEG-MATKL."               WITH KEY MATNR = WA_MSEG-MATNR .
    IF SY-SUBRC = 0.
      WA_ITEM-CLASS =  LS_DATA-CLASS.
    ENDIF.

*    APPEND WA_FINAL TO IT_FINAL.
*    CLEAR WA_FINAL.
*  ENDLOOP.

****    LOOP AT it_vbrp INTO wa_vbrp.
****    READ TABLE it_mseg INTO wa_mseg WITH KEY matnr = wa_vbrp-matnr
****                                             budat_mkpf = wa_vbrp-erdat.
****
****READ TABLE it_mara INTO wa_mara WITH KEY matnr = wa_mseg-matnr.                             "added
****
****    READ TABLE it_a502 INTO wa_a502 WITH KEY matnr = wa_mseg-matnr.
****    IF sy-subrc = 0.
****      wa_item-lifnr = wa_a502-lifnr.
****    ENDIF.
****    LOOP AT gt_data INTO gs_data.
****    wa_item-class = gs_data-class.
*    READ TABLE gt_data INTO gs_data INDEX 1.
*    IF sy-subrc = 0.
*      wa_item-class = gs_data-class.
*
*    ENDIF.

*    READ TABLE it_t001w INTO wa_t001w WITH KEY werks = wa_vbrp-werks.
*    IF sy-subrc = 0.
*      wa_item-werks = wa_t001w-werks.
*    ENDIF.
*    ENDLOOP.

****    CASE wa_vbrp-werks.
****      WHEN 'SSTN'.   "T. Nagar
****        wa_item-lifnr =  wa_a502-lifnr .      "Vendor Code.
****        wa_item-qty   =  wa_vbrp-fkimg .      " Qty
****        wa_item-value =  wa_vbrp-netwr .      "Value
****
****      WHEN 'SSPU'.    "PURUSAIWALAM
****        wa_item-lifnr =  wa_a502-lifnr .
****        wa_item-qty1   =  wa_vbrp-fkimg .
****        wa_item-value1 =  wa_vbrp-netwr .
****
****      WHEN 'SSCP'.    "CHROMPET
****        wa_item-lifnr =  wa_a502-lifnr .
****        wa_item-qty2   =  wa_vbrp-fkimg .
****        wa_item-value2 =  wa_vbrp-netwr .
****
****      WHEN 'SSPO'.    "PORUR
****        wa_item-lifnr =  wa_a502-lifnr .
****        wa_item-qty3   =  wa_vbrp-fkimg .
****        wa_item-value3 =  wa_vbrp-netwr .
****    ENDCASE.

    WA_ITEM-QTY4   = WA_ITEM-QTY   + WA_ITEM-QTY1   + WA_ITEM-QTY2   + WA_ITEM-QTY3.   "Total Qty
    WA_ITEM-VALUE4 = WA_ITEM-VALUE + WA_ITEM-VALUE1 + WA_ITEM-VALUE2 + WA_ITEM-VALUE3. "Total Value

    APPEND WA_ITEM TO IT_ITEM.
    CLEAR : WA_ITEM.
  ENDLOOP.
*  BREAK mpatil.
  IT_ITEM1[] = IT_ITEM.                                             "IT_FINAL1[] = LT_DATA.
  SORT IT_ITEM1 BY CLASS ."CLASS
  DELETE ADJACENT DUPLICATES FROM IT_ITEM1 COMPARING CLASS.
  LOOP AT IT_KLAH INTO WA_KLAH.
    WA_ITEM2-CLASS = WA_KLAH-CLASS.
*    SLNO = SLNO + 1.
*    WA_item2-SLNO = SLNO .
   LOOP AT IT_ITEM1 INTO WA_ITEM1 WHERE CLASS = WA_KLAH-CLASS.

   LOOP AT IT_ITEM INTO WA_ITEM WHERE CLASS = WA_ITEM1-CLASS.

    WA_ITEM2-MATKL  = WA_ITEM-MATKL.
    WA_ITEM2-LIFNR  = WA_ITEM-LIFNR.
    WA_ITEM2-QTY    = WA_ITEM-QTY +  WA_ITEM2-QTY.                    "T.Nagar (SSTN)
    WA_ITEM2-VALUE  = WA_ITEM-VALUE + WA_ITEM2-VALUE.
    WA_ITEM2-QTY1   = WA_ITEM-QTY1 +  WA_ITEM2-QTY1.                  "PURUSAIWAL (SSPU)
    WA_ITEM2-VALUE1 = WA_ITEM-VALUE1 + WA_ITEM2-VALUE1.
    WA_ITEM2-QTY2   = WA_ITEM-QTY2 +  WA_ITEM2-QTY2.                  "Chrompet (SSCP)
    WA_ITEM2-VALUE2 = WA_ITEM-VALUE2 + WA_ITEM2-VALUE2.
    WA_ITEM2-QTY3   = WA_ITEM-QTY3 +  WA_ITEM2-QTY3.                  "Porur (SSPO)
    WA_ITEM2-VALUE3 = WA_ITEM-VALUE3 + WA_ITEM2-VALUE3.
    WA_ITEM2-QTY4   = WA_ITEM-QTY4 + WA_ITEM2-QTY4 .                  " Total qty
    WA_ITEM2-VALUE4 = WA_ITEM-VALUE4 + WA_ITEM2-VALUE4.               " Total value

   ENDLOOP.
ENDLOOP.
*BREAK mpatil.
*    wa_item2-matkl  = wa_item-matkl.
*    wa_item2-lifnr  = wa_item-lifnr.
*    wa_item2-qty    = wa_item-qty.
*    wa_item2-value  = wa_item-value.
*    wa_item2-qty1   = wa_item-qty1.
*    wa_item2-value1 = wa_item-value1.
*    wa_item2-qty2   = wa_item-qty2.
*    wa_item2-value2 = wa_item-value2.
*    wa_item2-qty3   = wa_item-qty3.
*    wa_item2-value3 = wa_item-value3.
*    wa_item2-qty4   = wa_item-qty4.
*    wa_item2-value4 = wa_item-value4.
*      ENDLOOP.
*      ENDLOOP.
*    WA_item2-MENGE = MENGE.
*    WA_item2-fkimg = fkimg.
*    WA_FINAL2-DMBTR = DMBTR.
*    WA_item2-NETWR = NETWR.
*    WA_item2-NETWR = NETWR.
    APPEND WA_ITEM2 TO IT_ITEM2.
    CLEAR :  WA_ITEM2."wa_item2-qty4 ,wa_item2-value4,
  ENDLOOP.
* BREAK mumair.
*****  LOOP AT it_item INTO wa_item.
******    wa_item2-matkl  = wa_item-matkl.
*****    wa_item2-lifnr  = wa_item-lifnr.
*****    wa_item2-qty    = wa_item-qty.
*****    wa_item2-value  = wa_item-value.
*****    wa_item2-qty1   = wa_item-qty1.
*****    wa_item2-value1 = wa_item-value1.
*****    wa_item2-qty2   = wa_item-qty2.
*****    wa_item2-value2 = wa_item-value2.
*****    wa_item2-qty3   = wa_item-qty3.
*****    wa_item2-value3 = wa_item-value3.
*****    wa_item2-qty4   = wa_item-qty4.
*****    wa_item2-value4 = wa_item-value4.
*****    wa_item2-class = wa_item-class.
*****
*****    COLLECT wa_item2 INTO it_item2.
******APPEND wa_item2 TO it_item2.
*****CLEAR : wa_item2, wa_item.
*****
*****  ENDLOOP.
*****SORT it_item2 BY lifnr.                                 "added matkl
*

***************
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
**&---------------------------------------------------------------------*
*FORM process_data .
**  LOOP AT gt_data INTO gs_data. "*---->>> ( For class Hierarchy ) mumair <<< 24.09.2019 17:28:41
**    READ TABLE it_mara INTO wa_mara WITH KEY matkl = gs_data-matkl.
**    IF sy-subrc = 0.
**      gs_data-matkl = wa_mara-matkl.
**    ENDIF.
**  ENDLOOP.
*
*  LOOP AT it_vbrp INTO wa_vbrp.
*    READ TABLE it_mseg INTO wa_mseg WITH KEY matnr = wa_vbrp-matnr.
*
*    READ TABLE it_a502 INTO wa_a502 WITH KEY matnr = wa_mseg-matnr.
*    IF sy-subrc = 0.
*      wa_item-lifnr = wa_a502-lifnr.
*    ENDIF.
*LOOP AT GT_DATA INTO gs_data.
*  wa_item-class = gs_data-class.
*
**    READ TABLE it_t001w INTO wa_t001w WITH KEY werks = wa_vbrp-werks.
**    IF sy-subrc = 0.
**      wa_item-werks = wa_t001w-werks.
**    ENDIF.
*
*
*    CASE wa_vbrp-werks.
*      WHEN 'SSTN'.   "T. Nagar
*        wa_item-lifnr =  wa_a502-lifnr .      "Vendor Code.
*        wa_item-qty   =  wa_vbrp-fkimg .      " Qty
*        wa_item-value =  wa_vbrp-netwr .      "Value
*
*      WHEN 'SSPU'.    "PURUSAIWALAM
*        wa_item-lifnr =  wa_a502-lifnr .
*        wa_item-qty1   =  wa_vbrp-fkimg .
*        wa_item-value1 =  wa_vbrp-netwr .
*
*      WHEN 'SSCP'.    "CHROMPET
*        wa_item-lifnr =  wa_a502-lifnr .
*        wa_item-qty2   =  wa_vbrp-fkimg .
*        wa_item-value2 =  wa_vbrp-netwr .
*
*      WHEN 'SSPO'.    "PORUR
*        wa_item-lifnr =  wa_a502-lifnr .
*        wa_item-qty3   =  wa_vbrp-fkimg .
*        wa_item-value3 =  wa_vbrp-netwr .
*    ENDCASE.
*    wa_item-qty4   = wa_item-qty   + wa_item-qty1   + wa_item-qty2   + wa_item-qty3.   "Total Qty
*    wa_item-value4 = wa_item-value + wa_item-value1 + wa_item-value2 + wa_item-value3. "Total Value
*
*    APPEND wa_item TO it_item.
*    CLEAR wa_item.
*
*  ENDLOOP.
**  ENDLOOP.
** BREAK mumair.
*  LOOP AT it_item INTO wa_item.
*    wa_item2-lifnr  = wa_item-lifnr.
*    wa_item2-qty    = wa_item-qty.
*    wa_item2-value  = wa_item-value.
*    wa_item2-qty1   = wa_item-qty1.
*    wa_item2-value1 = wa_item-value1.
*    wa_item2-qty2   = wa_item-qty2.
*    wa_item2-value2 = wa_item-value2.
*    wa_item2-qty3   = wa_item-qty3.
*    wa_item2-value3 = wa_item-value3.
*    wa_item2-qty4   = wa_item-qty4.
*    wa_item2-value4 = wa_item-value4.
*
*    COLLECT wa_item2 INTO it_item2.
*    CLEAR : wa_item2, wa_item.
*
*  ENDLOOP.
*  ENDLOOP.
*  SORT it_item2 BY lifnr.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_OUTPUT .
  DATA: FM_NAME     TYPE RS38L_FNAM.
  DATA: T_SSFCOMPOP TYPE SSFCOMPOP.
  DATA: T_CONTROL   TYPE SSFCTRLOP.


  T_CONTROL-GETOTF = 'X'.
  T_CONTROL-NO_DIALOG = 'X'.
  T_SSFCOMPOP-TDNOPREV = 'X'.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZVNDR_SALES_FORM'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      FM_NAME            = FM_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
  CALL FUNCTION FM_NAME "'/1BCDWB/SF00000040'
    TABLES
      IT_ITEM          = IT_ITEM2
    EXCEPTIONS
      FORMATTING_ERROR = 1
      INTERNAL_ERROR   = 2
      SEND_ERROR       = 3
      USER_CANCELED    = 4
      OTHERS           = 5.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
