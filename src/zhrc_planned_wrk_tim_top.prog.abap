*&---------------------------------------------------------------------*
*& Include          ZHRC_PLANNED_WRK_TIM_TOP
*&---------------------------------------------------------------------*

TYPES:BEGIN OF ty_data,
        pernr TYPE PERNR_D,       " Personnel Number
        begda(10) TYPE c,       " Start Date
        endda(10) TYPE c,       " End Date
        schkz TYPE SCHKN,       " Work Schedule Rule
        zterf TYPE PT_ZTERF,       " Employee Time Management Status
*        empct TYPE EMPCT,
      END OF ty_data.

TYPES:BEGIN OF ty_log,
       pernr TYPE PERNR_D,
       tcode    TYPE bdc_tcode,
       dyname   TYPE bdc_module,
       dynumb   TYPE bdc_dynnr,
       msgtyp   TYPE bdc_mart,
       msgspra  TYPE  bdc_spras,
       msgid    TYPE  bdc_mid,
       msgnr    TYPE  bdc_mnr,
       msgv1    TYPE  bdc_vtext1,
       msgv2    TYPE bdc_vtext1,
       msgv3    TYPE bdc_vtext1,
       msgv4    TYPE bdc_vtext1,
       env      TYPE bdc_akt,
       fldname  TYPE  fnam_____4,
       msg_text TYPE string,
      END OF ty_log.

 DATA: gt_data  TYPE TABLE OF ty_data,
       wa_data  TYPE ty_data.

 DATA: it_bdcdata  TYPE TABLE OF bdcdata,
      wa_bdcdata  TYPE bdcdata,
      it_messtab  TYPE TABLE OF bdcmsgcoll,
      wa_messtab  TYPE bdcmsgcoll,
      it_log      TYPE TABLE OF ty_log,
      wa_log      TYPE ty_log,
      it_fieldcat TYPE slis_t_fieldcat_alv,
      wa_layout   TYPE slis_layout_alv.

DATA: ctumode LIKE ctu_params-dismode VALUE 'N',
      cupdate LIKE ctu_params-updmode VALUE 'A',
      ls_opt  TYPE ctu_params.
