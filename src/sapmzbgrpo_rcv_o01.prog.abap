*&---------------------------------------------------------------------*
*& Include          SAPMZBGRPO_RCV_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
 SET PF-STATUS 'ZPF'.
 SET TITLEBAR 'ZTITLE'.

IF container1 IS INITIAL.
  PERFORM alv_grid1.
ELSE.
  CALL METHOD grid1->refresh_table_display.
ENDIF.

IF it_item IS NOT INITIAL.
  LOOP AT SCREEN.
    IF screen-name   = 'WA_HDR-EBELN' OR screen-name = 'WA_HDR-BUDAT'.
       screen-input  = 0.
       screen-active = 1.
       MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDIF.




ENDMODULE.
*&---------------------------------------------------------------------*
*& Module LOGO_DISP OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE logo_disp OUTPUT.
IF picture IS NOT BOUND.
    CALL METHOD cl_gui_cfw=>flush.
    CREATE OBJECT:
   logo EXPORTING container_name = 'LOGO',
   picture EXPORTING parent = logo.

    CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
      EXPORTING
        p_object       = 'GRAPHICS'
        p_name         = 'ZSARVANA_LOGO'
        p_id           = 'BMAP'
        p_btype        = 'BCOL'
      RECEIVING
        p_bmp          = l_graphic_xstr
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    graphic_size = xstrlen( l_graphic_xstr ).
    l_graphic_conv = graphic_size.
    l_graphic_offs = 0.
    WHILE l_graphic_conv > 255.
      graphic_table-line = l_graphic_xstr+l_graphic_offs(255).
      APPEND graphic_table.
      l_graphic_offs = l_graphic_offs + 255.
      l_graphic_conv = l_graphic_conv - 255.
    ENDWHILE.
    graphic_table-line = l_graphic_xstr+l_graphic_offs(l_graphic_conv).
    APPEND graphic_table.
    CALL FUNCTION 'DP_CREATE_URL'
      EXPORTING
        type     = 'IMAGE'
        subtype  = 'X-UNKNOWN'
        size     = graphic_size
        lifetime = 'T'
      TABLES
        data     = graphic_table
      CHANGING
        url      = url.
    CALL METHOD picture->load_picture_from_url
      EXPORTING
        url = url.
    CALL METHOD picture->set_display_mode
      EXPORTING
        display_mode = picture->display_mode_fit_center.
  ENDIF.
ENDMODULE.
