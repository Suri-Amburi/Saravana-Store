function znc_ivend_article_details.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_DATE_LOW) TYPE  ERDAT
*"     VALUE(I_DATE_HIGH) TYPE  ERDAT
*"  TABLES
*"      TT_ART_DET TYPE  ZNCART_DET_TT
*"----------------------------------------------------------------------

  select matnr
         LAEDA
         mtart
         matkl
         meins
         ean11
         xchpf
         zzivend_desc
*    UP TO 50 rows
    from mara
    into table tt_art_det
    where laeda = sy-datum.





endfunction.
