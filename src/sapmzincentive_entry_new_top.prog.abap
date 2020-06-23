*&---------------------------------------------------------------------*
*& Report SAPMZINCENTIVE_ENTRY_NEW
*&---------------------------------------------------------------------*
*&

*&---------------------------------------------------------------------*
PROGRAM sapmzincentive_entry_new.

TYPES: BEGIN OF ty_item,
        ccode    TYPE matkl,    "Category Code
        sstcode  TYPE char10,    "SST Code
        sstdesc  TYPE char20,    "SST Description
        batch    TYPE char10,    "Batch
        brand    TYPE char5,     "Brand
        group    TYPE char10,    "Group
        lifnr    TYPE lifnr,     "Vendor Code
        pernr    TYPE persno,    "Employee Code
        name     TYPE char20,    "Employee Name
        datef    TYPE budat,     "Date From
        datet    TYPE budat,     "Date To
        mon      TYPE c,         "Day
        tue      TYPE c,         "Day
        wed      TYPE c,         "Day
        thu      TYPE c,         "Day
        fri      TYPE c,         "Day
        sat      TYPE c,         "Day
        sun      TYPE c,         "Day
        tarpc    TYPE menge_d,   "Target Piece
        tarval   TYPE menge_d,   "Target Value
        incepc   TYPE menge_d,   "Incentive Piece
        inceval  TYPE menge_d,   "Incenntive Value
        docno    TYPE zdoc,      "Document Number
        style    TYPE lvc_t_styl,
       END OF ty_item.


DATA: lv_werks TYPE werks_d,
      it_item  TYPE TABLE OF ty_item,
      it_item1 TYPE TABLE OF ty_item,
      wa_item  TYPE ty_item,
      wa_item1 TYPE ty_item,
      ok_code  TYPE sy-ucomm.
DATA : x  TYPE disvariant .
 DATA:container     TYPE REF TO cl_gui_custom_container,
      grid          TYPE REF TO cl_gui_alv_grid,
      it_exclude    TYPE ui_functions,
      lw_layo       TYPE lvc_s_layo,
      lt_fieldcat   TYPE lvc_t_fcat,
      gt_f4         TYPE lvc_t_f4 ,
      gs_f4         TYPE lvc_s_f4,
      row_ind       TYPE  lvc_t_row,
      wa_addf       TYPE zincentive.

TYPES pict_line(256) TYPE c.
DATA :  logo  TYPE REF TO cl_gui_custom_container,
        editor   TYPE REF TO cl_gui_textedit,
        picture  TYPE REF TO cl_gui_picture,
        pict_tab TYPE TABLE OF pict_line,
        url(255) TYPE c.

DATA: BEGIN OF graphic_table OCCURS 0,
        line(255) TYPE x,
      END OF graphic_table.
DATA: l_graphic_conv TYPE i.
DATA: l_graphic_offs TYPE i.
DATA: graphic_size TYPE i.
DATA: l_graphic_xstr TYPE xstring.
