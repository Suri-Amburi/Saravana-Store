*&---------------------------------------------------------------------*
*& Include          ZHR_PAY_SLIP_TOP
*&---------------------------------------------------------------------*
*************************************************************************
**************************TABLES*****************************************
 TABLES: PERNR,PA0000,PA0001,PA2001,T512T.
*----------------------------------------------------------------------*
*                    I  N F O T Y P E S                                *
*----------------------------------------------------------------------*
INFOTYPES : 0000,0001,2001.
************************************************************************
*                          T Y P E - P O O L S                         *
************************************************************************
TYPE-POOLS : slis.   "Generic list types
************************************************************************
*                  T Y P E - D E C L A R A T I O N S                   *
************************************************************************
***Structure type for Org. Assignment

DATA : IT_FINAL      TYPE TABLE OF ZFINAL_PAY_SLIP1,
       WA_FINAL      TYPE          ZFINAL_PAY_SLIP1,
       wa_header     type          zps_header,
       git_rgdir     type table of pc261,
       ls_rgdir      type          pc261,
       wa_T512T      type          T512T,
       it_p0000      TYPE TABLE OF p0000,
       wa_p0000      TYPE  p0000,
       WA_T247       TYPE  T247,
       wa_rt        like pc207 occurs 0 with header line,
       pay_results  type table of payin_result with header line,
       LV_SL_NO TYPE I.
*LV_SL_NO = 1.
