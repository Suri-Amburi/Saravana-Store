*&---------------------------------------------------------------------*
*& Include          ZMM_SOURCE_LIST_C06_TOP
*&---------------------------------------------------------------------*
types:begin of gty_file,
        matnr(40) type c,         "Material Number
        werks(4)  type c,         "Plant
        vdatu(10) type c,         "Source List Record Valid From
        bdatu(10) type c,         "Source List Record Valid To
        lifnr(10) type c,         "Vendor's account number
        ekorg(4)  type c,         "Purchasing Organization
*        reswk(4)  type c,         "Plant from Which Material is Procured
        meins(3)  type c,
        feskz(1)  type c,         "Indicator: Fixed Supplier
        notkz(1)  type c,         "Blocked Source of Supply
        autet(1)  type c,         "Source List Usage in Materials Planning
      end of gty_file,
      gty_t_file type standard table of gty_file,


      begin of ty_log,
        matnr    type matnr,
        msgid    type bdc_mid,
        msgnr    type bdc_mnr,
        msgv1    type bdc_vtext1,
        msgv2    type bdc_vtext1,
        msgv3    type bdc_vtext1,
        msgv4    type bdc_vtext1,
        env      type bdc_akt,
        fldname  type fnam_____4,
*        TYPE    TYPE BDC_MART,
        msg_text type string,
      end of ty_log.

data lv_lifnr(10) type c.
data lv_sortl(10) type c.

data:gwa_file    type gty_file,
     git_file    type gty_t_file,

     gwa_file_i  type gty_file,
     gwa_file_d  type gty_file,
     git_file_i  type gty_t_file,
     git_file_d  type gty_t_file,

     it_bdcdata  type standard table of bdcdata,
     wa_bdcdata  type bdcdata,

     it_msgcoll  type standard table of bdcmsgcoll,
     wa_msgcoll  type bdcmsgcoll,

     it_log      type standard table of ty_log,
     wa_log      type ty_log,

     it_fieldcat type slis_t_fieldcat_alv,
     wa_layout   type slis_layout_alv.

data: ctumode like ctu_params-dismode value 'N',
      cupdate like ctu_params-updmode value 'A'.

data:fname type localfile,
     ename type char4.
data message type string.
data TYPE type CHAR1.
*DATA BAPI_RETURN TYPE BAPIRET2.
