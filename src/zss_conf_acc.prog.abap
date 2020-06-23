*&---------------------------------------------------------------------*
*& Report ZSS_CONF_ACC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSS_CONF_ACC.


 TYPES : BEGIN OF  TY_BSEG,
          BUKRS   TYPE BUKRS,
          BELNR   TYPE BELNR_D,
          GJAHR   TYPE GJAHR,
*          BUZEI   TYPE BUZEI,
          LIFNR   TYPE LIFNR,
          DMBTR   TYPE DMBTR,
          SGTXT   TYPE SGTXT,
          KOART   TYPE KOART,
          SHKZG   TYPE SHKZG,
          H_BUDAT TYPE BUDAT,
        END OF TY_BSEG.

DATA : IT_BSEG TYPE TABLE OF TY_BSEG,
       WA_BSEG TYPE TY_BSEG.

TYPES : BEGIN OF  TY_LFA1,
          LIFNR TYPE LIFNR,
          NAME1 TYPE NAME1_GP,
        END OF TY_LFA1.

DATA : IT_LFA1 TYPE TABLE OF TY_LFA1,
       WA_LFA1 TYPE TY_LFA1.

TYPES : BEGIN OF  TY_BKPF,
         BUKRS   TYPE BUKRS,
         BELNR   TYPE BELNR_D,
         GJAHR   TYPE GJAHR,
         LIFNR   TYPE LIFNR,
         H_BUDAT TYPE BUDAT,
         BLART   TYPE BLART,
        END OF TY_BKPF.

DATA : IT_BKPF TYPE TABLE OF TY_BKPF,
       WA_BKPF TYPE TY_BKPF.

DATA : LV_DEBIT_TOT TYPE I,
*          DMBTR   TYPE DMBTR,
*          SGTXT   TYPE SGTXT,
*          KOART   TYPE KOART,
*          SHKZG   TYPE SHKZG,
       LV_CREDIT_TOT TYPE I.

*TYPES : BEGIN OF  TY_HEADER,
*         DATE    TYPE SY-DATUM,
*         TIME    TYPE SY-UZEIT,
*         H_BUDAT TYPE BUDAT,
*         LIFNR   TYPE LIFNR,
*         NAME1   TYPE NAME1_GP,
*         DMBTR   TYPE DMBTR,
*        END OF TY_HEADER.

*         DATA :IT_HEADER TYPE TABLE OF ZSS_HEADER,
DATA : WA_HEADER TYPE ZSS_HEADER.


DATA : IT_ITEM TYPE TABLE OF ZSS_ITEM,
       WA_ITEM TYPE ZSS_ITEM.

DATA :DATE TYPE SY-DATUM,
      TIME TYPE SY-UZEIT.

 DATA : LV_H_BUDAT TYPE BUDAT,
        TOT_DEBIT  TYPE I ,
        TOT_CREDIT TYPE I.



SELECTION-SCREEN : BEGIN OF BLOCK N1 WITH FRAME TITLE TEXT-001 .
  PARAMETERS : P_CMP_CD TYPE BUKRS,
               P_VNDR   TYPE LIFNR,
               P_FIS_YR TYPE GJAHR.
  SELECT-OPTIONS : S_POSDAT FOR LV_H_BUDAT .
SELECTION-SCREEN: END OF BLOCK N1 .


SELECT
  BUKRS
  BELNR
  GJAHR
*  BUZEI
  LIFNR
  DMBTR
  SGTXT
  KOART
  SHKZG
  H_BUDAT
   FROM BSEG INTO TABLE IT_BSEG
   WHERE  BUKRS   =  P_CMP_CD AND
          LIFNR   =  P_VNDR   AND
          H_BUDAT IN S_POSDAT AND
          GJAHR   =  P_FIS_YR.
*                                       BLART  = IT_BKPF-BLART.

 IF IT_BSEG IS NOT INITIAL.
   SELECT
     BUKRS
*     BELNR
*     GJAHR
*     LIFNR
*     H_BUDAT
     BLART
      FROM BKPF INTO TABLE IT_BKPF FOR ALL ENTRIES IN IT_BSEG WHERE BUKRS   = IT_BSEG-BUKRS .

  ENDIF.

  SELECT
  LIFNR
  NAME1
     FROM LFA1 INTO TABLE IT_LFA1 FOR ALL ENTRIES IN IT_BSEG WHERE LIFNR = IT_BSEG-LIFNR.
*  ENDIF.

LOOP AT IT_BSEG INTO WA_BSEG.
      WA_HEADER-BUKRS   = WA_BSEG-BUKRS  .          "" HEADER part
       WA_HEADER-GJAHR   = WA_BSEG-GJAHR  .
*      WA_HEADER-BUZEI   = WA_BSEG-BUZEI  .
      WA_HEADER-LIFNR   = WA_BSEG-LIFNR  .
      WA_HEADER-DMBTR   = WA_BSEG-DMBTR  .

*      WA_HEADER-KOART   = WA_BSEG-KOART  .
*      WA_HEADER-SHKZG   = WA_BSEG-SHKZG  .
      WA_HEADER-H_BUDAT = WA_BSEG-H_BUDAT.
                                                         ""item part
       WA_ITEM-BELNR   = WA_BSEG-BELNR  .
       WA_ITEM-H_BUDAT = WA_BSEG-H_BUDAT.
       WA_ITEM-SGTXT   = WA_BSEG-SGTXT  .

       IF WA_BSEG-KOART EQ 'K' .                           "" Condition For Debit And Credit.
         ELSEIF WA_BSEG-SHKZG EQ 'H'.
       WA_ITEM-DEBIT = WA_BSEG-DMBTR.
       ELSEIF WA_BSEG-SHKZG EQ 'S' .
       WA_ITEM-CREDIT = WA_BSEG-DMBTR * ( -1 ) .
       ENDIF.
*                                                                       ""tot debit and tot credit logic.
       WA_HEADER-TOTDEBIT  = WA_HEADER-TOTDEBIT  + WA_BSEG-DMBTR.
       WA_HEADER-TOTCREDIT = WA_HEADER-TOTCREDIT + WA_BSEG-DMBTR .
                                                                          ""Opening Balance Logic.
       WA_HEADER-OPBALANCE = WA_HEADER-TOTDEBIT  - WA_ITEM-CREDIT .
                                                                         "" balance Logic.
       WA_ITEM-BALANCE    = WA_HEADER-OPBALANCE - WA_BSEG-DMBTR .

    READ TABLE IT_BKPF INTO WA_BKPF WITH KEY H_BUDAT = WA_BSEG-H_BUDAT.
    IF SY-SUBRC = 0.
*      WA_HEADER-BUKRS    =  WA_BKPF-BUKRS   .
*      WA_HEADER-BELNR    =  WA_BKPF-BELNR   .
*      WA_HEADER-GJAHR    =  WA_BKPF-GJAHR   .
*      WA_HEADER-LIFNR    =  WA_BKPF-LIFNR   .
*      WA_HEADER-H_BUDAT  =  WA_BKPF-H_BUDAT .
      WA_HEADER-BLART    =  WA_BKPF-BLART   .
    ENDIF.

    READ TABLE IT_LFA1 INTO WA_LFA1 WITH KEY LIFNR = WA_BSEG-LIFNR.
    IF SY-SUBRC = 0.
*      WA_HEADER-LIFNR  = WA_LFA1-LIFNR.
      WA_HEADER-NAME1  = WA_LFA1-NAME1.
    ENDIF.


     APPEND WA_ITEM TO IT_ITEM.
     CLEAR WA_ITEM .
*     APPEND WA_HEADER TO IT_HEADER.
*     CLEAR WA_HEADER.


*LOOP AT IT_BSEG INTO WA_BSEG.
**      WA_HEADER-BUKRS   = WA_BSEG-BUKRS  .
**      WA_HEADER-BELNR   = WA_BSEG-BELNR  .
**      WA_HEADER-GJAHR   = WA_BSEG-GJAHR  .
**      WA_HEADER-BUZEI   = WA_BSEG-BUZEI  .
*      WA_HEADER-LIFNR   = WA_BSEG-LIFNR  .
*      WA_HEADER-DMBTR   = WA_BSEG-DMBTR  .
**      WA_HEADER-SGTXT   = WA_BSEG-SGTXT  .
**      WA_HEADER-KOART   = WA_BSEG-KOART  .
**      WA_HEADER-SHKZG   = WA_BSEG-SHKZG  .
*      WA_HEADER-H_BUDAT = WA_BSEG-H_BUDAT.
*
*    READ TABLE IT_BKPF INTO WA_BKPF WITH KEY H_BUDAT = WA_BSEG-H_BUDAT.
*    IF SY-SUBRC = 0.
**      WA_HEADER-BUKRS    =  WA_BKPF-BUKRS   .
**      WA_HEADER-BELNR    =  WA_BKPF-BELNR   .
**      WA_HEADER-GJAHR    =  WA_BKPF-GJAHR   .
*      WA_HEADER-LIFNR    =  WA_BKPF-LIFNR   .
*      WA_HEADER-H_BUDAT  =  WA_BKPF-H_BUDAT .
**      WA_HEADER-BLART    =  WA_BKPF-BLART   .
*    ENDIF.
*
*    READ TABLE IT_LFA1 INTO WA_LFA1 WITH KEY LIFNR = WA_BSEG-LIFNR.
*    IF SY-SUBRC = 0.
*      WA_HEADER-LIFNR    = WA_LFA1-LIFNR.
*      WA_HEADER-NAME1    = WA_LFA1-NAME1.
*    ENDIF.
*
*     APPEND WA_HEADER TO IT_HEADER.
*     CLEAR  WA_HEADER.

"logic for opening balance.

*IF WA_BSEG-H_BUDAT lt s_clear-low.
*IF     WA_BSEG-SHKZG = 'H'.
*       WA_OUT-DMBTR2 = WA_BSEG-DMBTR.
*       lv_open1 = lv_open1 + wa_out-dmbtr2.
*ELSEIF WA_BSEG-SHKZG = 'S'.
*       WA_OUT-DMBTR3 = WA_BSEG-DMBTR.
*       lv_open2 = lv_open2 + wa_out-dmbtr3.
*endif.
*endif.

"endlogic

  ENDLOOP.


  DATA : IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
         WA_FIELDCAT TYPE  SLIS_FIELDCAT_ALV.

  DATA:WA_LAYOUT  TYPE SLIS_LAYOUT_ALV.
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X' .

  WA_FIELDCAT-FIELDNAME ='SY-DATUM' .
  WA_FIELDCAT-SELTEXT_M = 'DATE'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .


  WA_FIELDCAT-FIELDNAME ='SY-UZEIT' .
  WA_FIELDCAT-SELTEXT_M = 'TIME'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .


  WA_FIELDCAT-FIELDNAME = 'H_BUDAT' .
  WA_FIELDCAT-SELTEXT_M = 'POSTING DT'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .

 WA_FIELDCAT-FIELDNAME = 'LIFNR' .
  WA_FIELDCAT-SELTEXT_M = 'ACCOUNT'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .

 WA_FIELDCAT-FIELDNAME = 'NAME1' .
  WA_FIELDCAT-SELTEXT_M = 'SUPPLIER'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .


 WA_FIELDCAT-FIELDNAME = 'DMBTR' .
  WA_FIELDCAT-SELTEXT_M = 'OPENING BALANCE'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .


 WA_FIELDCAT-FIELDNAME = 'BELNR' .
  WA_FIELDCAT-SELTEXT_M = 'DOC NUMBER'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .


 WA_FIELDCAT-FIELDNAME = 'H_BUDAT' .
  WA_FIELDCAT-SELTEXT_M = 'POSTING DATE'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .

WA_FIELDCAT-FIELDNAME = 'SGTXT' .
  WA_FIELDCAT-SELTEXT_M = 'PARTICULERS'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .

  WA_FIELDCAT-FIELDNAME = 'DMBTR' .
  WA_FIELDCAT-SELTEXT_M = 'DEBIT'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .

  WA_FIELDCAT-FIELDNAME = 'DMBTR' .
  WA_FIELDCAT-SELTEXT_M = 'CREDIT'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .

  WA_FIELDCAT-FIELDNAME = 'DMBTR' .
  WA_FIELDCAT-SELTEXT_M = 'BALANCE'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .

     CALL METHOD zcl_conf_acc=>get_posting_deatils
      EXPORTING
        i_company_code      =     WA_BSEG-BUKRS             " Company Code
        i_vendor            =     WA_BSEG-LIFNR             " Account Number of Vendor or Creditor
        i_fiscal_year       =     WA_BSEG-GJAHR             " Fiscal Year
        i_from_posting_date =     WA_BSEG-H_BUDAT           " From Posting Date
        i_to_posting_date   =     WA_BSEG-H_BUDAT           " To Posting Date
      IMPORTING
        es_header           =    ZSS_HEADER           " HEADER
        et_item             =    ZSS_ITEM   .         " Item
