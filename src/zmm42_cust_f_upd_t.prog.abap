*&---------------------------------------------------------------------*
*& Report ZMM42_CUST_F_UPD_T
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zmm42_cust_f_upd_t.


types:begin of ta_flatfile,
****Additional fields
        material(40),
        zzarticle(60),
        zzlabel_desc(40),
        zzivend_desc(40),
        zzemp_code(8),
        zzemp_per(6),
        zzpo_order_txt(80),
        zzdisc_allow(1),
        zzisexchange(1),
        zzisnonstock(1),
        zzisrefund(1),
        zzissaleable(1),
        zzisweighed(1),
        zzisvalid(1),
        zzistaxexempt(1),
        zzisopenprice(1),
        zzisopendesc(1),
        zzisinctax(1),
        zzret_days(3),
        zzprice_frm(8),
        zzprice_to(8),
      end of ta_flatfile,
      ta_t_flatfile type standard table of ta_flatfile.

types:begin of ty_display,
        material   type matnr,
        prctr      type prctr,
        plant      type werks_d,
        type       type bapi_mtype,
        id         type symsgid,
        number     type symsgno,
        message_v1 type mara-matnr,
        message	   type bapi_msg,
      end of ty_display,
      ty_t_display type table of ty_display.

data:it_display  type ty_t_display.
data:ta_flatfile type ta_t_flatfile.
data:wa_display  type ty_display.
field-symbols:<fs_flatfile>  type ta_flatfile,
              <fs_flatfile1> type ta_flatfile,
              <fs_flatfile2> type ta_flatfile,
              <fs_flatfile3> type ta_flatfile,
              <fs_steuertab> type mg03steuer.

data:fname type localfile,
     ename type char4.


selection-screen begin of block b1 with frame title text-001.
parameters : p_file type string."rlgrap-filename.
selection-screen end of block b1.


at selection-screen on value-request for p_file.
  perform get_filename changing p_file.

start-of-selection.
  perform get_data changing ta_flatfile.
  perform upload_material.

end-of-selection.
  perform display_data.

*&---------------------------------------------------------------------*
*&      Form  GET_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_FILE  text
*----------------------------------------------------------------------*
form get_filename  changing fp_p_file type string.

  data: li_filetable    type filetable,
        lx_filetable    type file_table,
        lv_return_code  type i,
        lv_window_title type string.

  call method cl_gui_frontend_services=>file_open_dialog
    exporting
      window_title            = lv_window_title
    changing
      file_table              = li_filetable
      rc                      = lv_return_code
    exceptions
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      others                  = 5.

  read table  li_filetable into lx_filetable index 1.
  fp_p_file = lx_filetable-filename.


  split fp_p_file at '.' into fname ename.
  set locale language sy-langu.
  translate ename to upper case.

endform.                    " GET_FILENAME

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_EXCELTAB  text
*----------------------------------------------------------------------*
form get_data  changing ta_flatfile type ta_t_flatfile.

  data : i_type    type truxs_t_text_data.

  data:lv_file type rlgrap-filename.


*  PROCEED ONLY IF ITS A VALID FILETYPE
  if ename eq 'XLSX' or ename eq 'XLS'.

    refresh ta_flatfile[].

    break ksanthosh.
    lv_file = p_file.

*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    call function 'TEXT_CONVERT_XLS_TO_SAP'
      exporting
        i_tab_raw_data       = i_type
        i_filename           = lv_file
      tables
        i_tab_converted_data = ta_flatfile[]
      exceptions
        conversion_failed    = 1
        others               = 2.


    delete ta_flatfile from 1 to 2.

  else.
    message e398(00) with 'Invalid File Type'  .
  endif.

  if ta_flatfile is initial.
    message 'No records to upload' type 'E'.
  endif.

endform.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  UPLOAD_MATERIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form upload_material .
  data:im_matnr type zmm41_c.
  data:ex_mara  type char100.
  data t type string.
  field-symbols:<fs_flatfile>  type ta_flatfile,
                <fs_steuertab> type mg03steuer.

  break breddy.
  loop at ta_flatfile assigning <fs_flatfile>.
    if <fs_flatfile> is assigned.

      im_matnr-matnr          =  <fs_flatfile>-material.

*******************************  ADDED BY KRITHIKA 28-11-2019  11.03 AM **********************************************
********************* FOR CONVERTINH MATNR IN TO UPPERCASE **************************************

       TRANSLATE im_matnr-matnr TO UPPER CASE.

**************************************************************************************************

      if <fs_flatfile>-zzarticle is not initial.
        im_matnr-zzarticle      =  <fs_flatfile>-zzarticle.
      endif.
      if <fs_flatfile>-zzlabel_desc is not initial.
        im_matnr-zzlabel_desc   =  <fs_flatfile>-zzlabel_desc.
      endif.
      if <fs_flatfile>-zzivend_desc is not initial.
        im_matnr-zzivend_desc   =  <fs_flatfile>-zzivend_desc.
      endif.
      if <fs_flatfile>-zzemp_code is not initial.
        im_matnr-zzemp_code     =  <fs_flatfile>-zzemp_code.
      endif.
      if <fs_flatfile>-zzemp_per is not initial.
        im_matnr-zzemp_per      =  <fs_flatfile>-zzemp_per.
      endif.
      if <fs_flatfile>-zzpo_order_txt is not initial.
        im_matnr-zzpo_order_txt =  <fs_flatfile>-zzpo_order_txt.
      endif.
      if <fs_flatfile>-zzdisc_allow is not initial.
        im_matnr-zzdisc_allow   =  <fs_flatfile>-zzdisc_allow.
      endif.
      if <fs_flatfile>-zzisexchange is not initial.
        im_matnr-zzisexchange   = <fs_flatfile>-zzisexchange.
      endif.
      if <fs_flatfile>-zzisnonstock is not initial.
        im_matnr-zzisnonstock   = <fs_flatfile>-zzisnonstock.
      endif.
      if <fs_flatfile>-zzisrefund is not initial.
        im_matnr-zzisrefund     = <fs_flatfile>-zzisrefund.
      endif.
      if <fs_flatfile>-zzissaleable is not initial.
        im_matnr-zzissaleable   = <fs_flatfile>-zzissaleable.
      endif.
      if <fs_flatfile>-zzisweighed is not initial.
        im_matnr-zzisweighed    = <fs_flatfile>-zzisweighed.
      endif.
      if <fs_flatfile>-zzisvalid is not initial.
        im_matnr-zzisvalid      = <fs_flatfile>-zzisvalid.
      endif.
      if <fs_flatfile>-zzistaxexempt is not initial.
        im_matnr-zzistaxexempt  = <fs_flatfile>-zzistaxexempt.
      endif.
      if <fs_flatfile>-zzisopenprice is not initial.
        im_matnr-zzisopenprice  = <fs_flatfile>-zzisopenprice.
      endif.
      if <fs_flatfile>-zzisopendesc is not initial.
        im_matnr-zzisopendesc   = <fs_flatfile>-zzisopendesc.
      endif.
      if <fs_flatfile>-zzisinctax is not initial.
        im_matnr-zzisinctax     = <fs_flatfile>-zzisinctax.
      endif.
      if <fs_flatfile>-zzret_days is not initial.
        im_matnr-zzret_days     = <fs_flatfile>-zzret_days.
      endif.
      if <fs_flatfile>-zzprice_frm is not initial.
        im_matnr-zzprice_frm    = <fs_flatfile>-zzprice_frm.
      endif.
      if <fs_flatfile>-zzprice_to is not initial.
        im_matnr-zzprice_to     = <fs_flatfile>-zzprice_to.
      endif.

      call method zmm42_udp_t=>get_mat_updt(
        exporting
          im_matnr = im_matnr
        importing
          ex_mara  = ex_mara ).

      if sy-subrc  is initial.
        wa_display-material    = im_matnr-matnr.                             "CHANGED BY KRITHIKA MATERIAL IN UPPERCASE 28-11-2019 11.03AM
        wa_display-type        = 'S'.
        wa_display-message_v1 = ex_mara.
        append wa_display to it_display.
        clear wa_display.
      else.
        wa_display-material    = <fs_flatfile>-material.
        wa_display-type        = 'E'.
        wa_display-message_v1 = ex_mara.
        append wa_display to it_display.
        clear wa_display.
      endif.

    endif.
  endloop.

endform.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form display_data .

  data:lt_fieldcat type slis_t_fieldcat_alv,
       ls_fieldcat type slis_fieldcat_alv,
       lwa_layout  type slis_layout_alv.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'MATERIAL'.
  ls_fieldcat-seltext_l = 'MATERIAL'.
  ls_fieldcat-seltext_m = 'MATERIAL'.
  ls_fieldcat-seltext_s = 'MATERIAL'.
  append ls_fieldcat to lt_fieldcat.

**  CLEAR LS_FIELDCAT.
**  LS_FIELDCAT-FIELDNAME = 'PRCTR'.
**  LS_FIELDCAT-SELTEXT_L = 'Profit Cneter'.
**  LS_FIELDCAT-SELTEXT_M = 'Profit Cneter'.
**  LS_FIELDCAT-SELTEXT_S = 'Profit Cneter'.
**  APPEND LS_FIELDCAT TO LT_FIELDCAT.
**  CLEAR LS_FIELDCAT.
**
**  LS_FIELDCAT-FIELDNAME = 'PLANT'.
**  LS_FIELDCAT-SELTEXT_L = 'Plant'.
**  LS_FIELDCAT-SELTEXT_M = 'Plant'.
**  LS_FIELDCAT-SELTEXT_S = 'Plant'.
**  APPEND LS_FIELDCAT TO LT_FIELDCAT.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'TYPE'.
  ls_fieldcat-seltext_l = 'Message Type'.
  ls_fieldcat-seltext_m = 'Message Type'.
  ls_fieldcat-seltext_s = 'Message Type'.
  append ls_fieldcat to lt_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'MESSAGE_V1'.
  ls_fieldcat-seltext_l = 'Material'.
  ls_fieldcat-seltext_m = 'Material'.
  ls_fieldcat-seltext_s = 'Material'.
  append ls_fieldcat to lt_fieldcat.


  lwa_layout-zebra = 'X'.
  lwa_layout-colwidth_optimize = 'X'.

  call function 'REUSE_ALV_GRID_DISPLAY'
    exporting
      i_callback_program = sy-repid
      is_layout          = lwa_layout
      it_fieldcat        = lt_fieldcat
      i_save             = 'X'
    tables
      t_outtab           = it_display
    exceptions
      program_error      = 1
      others             = 2.



endform.
