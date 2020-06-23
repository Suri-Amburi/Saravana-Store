*&---------------------------------------------------------------------*
*& Include SAPMZMM_WHSTO_TOP                        - Module Pool      SAPMZMM_WHSTO
*&---------------------------------------------------------------------*
PROGRAM sapmzmm_whsto.

DATA  : ok_9001 TYPE sy-ucomm.  "User Command

DATA : sdisp TYPE c . "Display Indic.

TYPES : BEGIN OF ty_hdr,
          swerks   TYPE zsubcon_wrk,
          rwerks   TYPE zsubcon_wrk,
          b1_charg TYPE zb1_btch,
          s4_charg TYPE charg_d,
          menge    TYPE menge_d,
          ebeln    TYPE ebeln, "PUrchase Order
          vbeln    TYPE vbeln_vl, "Delivery
        END OF ty_hdr.

DATA : xsto_hdr TYPE ty_hdr.    "Header Details

DATA : xsto_itm TYPE TABLE OF zsto_itm WITH HEADER LINE. "Item Details

DATA: excl   TYPE TABLE OF fcode WITH HEADER LINE,
      excl01 TYPE TABLE OF fcode WITH HEADER LINE.


CONSTANTS : back(4)      TYPE c VALUE 'BACK',
            canc(4)      TYPE c VALUE 'CANC',
            exit(4)      TYPE c VALUE 'EXIT',
            genr(4)      TYPE c VALUE 'GENR',
            refr(4)      TYPE c VALUE 'REFR',
            rwrk(4)      TYPE c VALUE 'RWRK',
            swrk(4)      TYPE c VALUE 'SWRK',
            new(4)       TYPE c VALUE 'NEW',
            post(4)      TYPE c VALUE 'POST',
            find(4)      TYPE c VALUE 'FIND',
            issue(5)     TYPE c VALUE 'ISSUE',
            ssub1(5)     TYPE c VALUE 'SSUB1',
            plant(5)     TYPE c VALUE 'PLANT',
            move(4)      TYPE c VALUE 'MOVE',
            dclick(6)    TYPE c VALUE 'DCLICK',
            clg(6)       TYPE c VALUE 'CLG',
            slg(6)       TYPE c VALUE 'SLG',
            scont1(6)    TYPE c VALUE 'CC2',
            exec(4)      TYPE c VALUE 'EXEC',
            sg1(2)       TYPE c VALUE 'G1',
            sg2(2)       TYPE c VALUE 'G2',
            sg3(2)       TYPE c VALUE 'G3',
            si(2)        TYPE c VALUE 'I',
            se(2)        TYPE c VALUE 'E',
            ss(2)        TYPE c VALUE 'S',
            sw(2)        TYPE c VALUE 'W',
            sdlr_sym(11) TYPE c VALUE '$$$$$$$$$$',
            sgreen(4)    TYPE c VALUE '@08@',
            sred(4)      TYPE c VALUE '@0A@'.



DATA: scont              TYPE REF TO cl_gui_custom_container,
      sgrid              TYPE REF TO cl_gui_alv_grid,
      spcont             TYPE REF TO cl_gui_custom_container,
      spgrid             TYPE REF TO cl_gui_alv_grid,
      gt_selected_rows   TYPE lvc_t_row WITH HEADER LINE,
      gw_selected_rows   TYPE lvc_s_row,
      xfcat              TYPE TABLE OF lvc_s_fcat WITH HEADER LINE,
      xsort              TYPE TABLE OF lvc_s_sort WITH HEADER LINE,
      sgrid_data_changed TYPE REF TO cl_alv_changed_data_protocol.

DATA: fieldcat     TYPE TABLE OF lvc_s_fcat WITH HEADER LINE, "for field catalog
      lt_fcat      TYPE lvc_t_fcat,
      ls_fcat      TYPE lvc_s_fcat,
      lt_dropdown  TYPE lvc_t_drop,
      ls_dropdown  TYPE lvc_s_drop,
      user_command TYPE slis_formname VALUE 'USER_COMMAND', "navigating to the tcode
      it_sort      TYPE slis_t_sortinfo_alv,  "for sorting
      lt_header    TYPE slis_t_listheader,
      lw_header    LIKE LINE OF lt_header.


CONSTANTS : cont(7)     VALUE 'CC_ITEM',
            sel_mode(1) VALUE 'A'.


DATA : x  TYPE disvariant .

DATA: lo_cols      TYPE REF TO cl_salv_columns,
      gr_display   TYPE REF TO cl_salv_display_settings,
      lr_functions TYPE REF TO cl_salv_functions.

DATA: lv_message TYPE REF TO cx_salv_msg, "Exception Class
      s_cont     TYPE REF TO cl_gui_custom_container. "Custom Container

DATA : ls_layo TYPE lvc_s_layo .
****       lt_fcat TYPE TABLE OF lvc_s_fcat WITH HEADER LINE.
CONSTANTS : title TYPE string VALUE 'Stock Transfer Items'.

DATA : scl_error TYPE REF TO cx_amdp_error.

DATA: w_lines      TYPE i,
      pgi_indic(1) TYPE c.
TYPES pict_line(256) TYPE c.
DATA :
  scont01  TYPE REF TO cl_gui_custom_container,
  editor   TYPE REF TO cl_gui_textedit,
  picture  TYPE REF TO cl_gui_picture,
  pict_tab TYPE TABLE OF pict_line,
  url(255) TYPE c.
DATA: graphic_url(255).

DATA : mark TYPE c.

DATA: BEGIN OF graphic_table OCCURS 0,
        line(255) TYPE x,
      END OF graphic_table.
DATA: l_graphic_conv TYPE i.
DATA: l_graphic_offs TYPE i.
DATA: graphic_size TYPE i.
DATA: l_graphic_xstr TYPE xstring.

DATA: lt_toolbar_excluding TYPE ui_functions,
      ls_toolbar_excluding TYPE ui_func.

DATA: lt_f4 TYPE lvc_t_f4 WITH HEADER LINE.

DATA : sebeln TYPE ebeln,   "PO No.
       ssubrc TYPE sy-subrc.

DATA : scharg TYPE charg.
