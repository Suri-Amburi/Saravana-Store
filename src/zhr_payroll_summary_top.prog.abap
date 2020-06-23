*&---------------------------------------------------------------------*
*& Include          ZHR_PAYROLL_SUMMARY_TOP
*&---------------------------------------------------------------------*
************************************************************************
*                   T A B L E S                                        *
************************************************************************
TABLES : pernr,PA0000,PA0001,PA0002.
*----------------------------------------------------------------------*
*                    I  N F O T Y P E S                                *
*----------------------------------------------------------------------*
INFOTYPES : 0000,0001,0002.
************************************************************************
*                          T Y P E - P O O L S                         *
************************************************************************
TYPE-POOLS : slis.
***********************************************************************
DATA: IT_FINAL TYPE TABLE OF ZPR_FINAL,
      WA_FINAL TYPE ZPR_FINAL,
       git_rgdir     type table of pc261,
       ls_rgdir      type          pc261,
       wa_rt        like pc207 occurs 0 with header line,
       pay_results  type table of payin_result with header line,
       LV_SL_NO TYPE I.

data: it_fieldcat type slis_t_fieldcat_alv,
      wa_fieldcat type slis_fieldcat_alv.

data: t_header      type slis_t_listheader,
        wa_header     type slis_listheader.
data: wa_layout       type slis_layout_alv.
