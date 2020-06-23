*&---------------------------------------------------------------------*
*& Include          ZMM_VK12_CHANGE_MARGIN_TOP
*&---------------------------------------------------------------------*


TYPES:BEGIN OF gty_file,
        kschl(04),
        matnr(18),
        EAN11(15),
        KBETR(13),
        KONWA(03),
      END OF gty_file,
      gty_t_file TYPE STANDARD TABLE OF gty_file.


DATA:gwa_file    TYPE gty_file,
     git_file    TYPE gty_t_file,
     git_file_i  TYPE gty_t_file,
     git_file_it TYPE gty_t_file.

DATA:fname TYPE localfile,
     ename TYPE char4,
     cnt   TYPE i.

TYPES:BEGIN OF gty_display,
        sno      TYPE i,
        LIFNR    TYPE LIFNR,
        matnr    TYPE matnr,
*         datuv TYPE datuv,
*         datub TYPE DATUB,
*         bmeng TYPE bmeng,
*         posnr TYPE SPOSN,
*         POSTP type postp,
*         idnrk TYPE IDNRK,
*         menge TYPE KMPMG,
*         meins TYPE KMPME,
        message1 TYPE message,
        message2 TYPE message,
      END OF gty_display,
      gty_t_display TYPE STANDARD TABLE OF gty_display.

DATA: gwa_display TYPE gty_display,
      git_display TYPE gty_t_display,
      lv_date     TYPE dats,
      lv_time     TYPE tims,
      lv_sqno(6)  TYPE n,

      it_fieldcat TYPE slis_t_fieldcat_alv,
      wa_layout   TYPE slis_layout_alv.

DATA: it_bdcdata TYPE TABLE OF bdcdata,
      wa_bdcdata TYPE bdcdata.
DATA: it_messtab TYPE TABLE OF bdcmsgcoll,
      wa_messtab TYPE bdcmsgcoll,
*        wa_log TYPE zint_log,
      messtab1   LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
DATA: ctumode LIKE ctu_params-dismode VALUE 'N',
      cupdate LIKE ctu_params-updmode VALUE 'A'.

DATA: lv_matnr TYPE csap_mbom-matnr,          " Material BOM Initial Screen Data
      lv_werks TYPE csap_mbom-werks,
      lv_stlan TYPE csap_mbom-stlan,
*      lv_stlal type csap_mbom-stlal,
      lv_datuv TYPE csap_mbom-datuv.
