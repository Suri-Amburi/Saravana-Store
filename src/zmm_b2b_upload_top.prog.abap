*&---------------------------------------------------------------------*
*& Include          ZMM_B2B_UPLOAD_TOP
*&---------------------------------------------------------------------*

*** Type Decleration
TYPES :
  BEGIN OF ty_data,
    batch         TYPE charg_d,
    old_price(10),
    menge(15),
    new_price(10),
    batch_n       TYPE charg_d,
    message       TYPE bapiret2-message,
  END OF ty_data.

TYPES :
  BEGIN OF ty_det,
    ebeln       TYPE ebeln,
    mblnr       TYPE mblnr,
    mjahr       TYPE mjahr,
    msg_type(1),
    message     TYPE bapiret2-message,
  END OF ty_det.

DATA:
  ok_100           TYPE sy-ucomm,
  g_repid          TYPE sy-repid,
*  gv_batch         TYPE charg_d,
  gv_batch         TYPE char20, "added on 13.05.2020
  gv_batch1        TYPE charg_d,
  gv_werks         TYPE werks_d,
  gv_mblnr         TYPE mblnr,
  gv_mjahr         TYPE mjahr,
  gv_mod(1),
  custom_container TYPE REF TO cl_gui_custom_container,
  grid             TYPE REF TO cl_gui_alv_grid,
  gs_print         TYPE lvc_s_prnt,
  gs_layout        TYPE lvc_s_layo,
  i_layout         LIKE TABLE OF gs_layout,
  mycontainer      TYPE scrfname VALUE 'MYCONTAINER',
  p_file           TYPE localfile,
  gt_data          TYPE STANDARD TABLE OF ty_data,
  gs_data          TYPE ty_data,
  gs_fieldcat      TYPE lvc_s_fcat,
  gi_fieldcat      TYPE lvc_t_fcat.

CONSTANTS :
  c_101(3)       VALUE '101',
  c_back(4)      VALUE 'BACK',
  c_enter(4)     VALUE 'ENTER',
  c_save(4)      VALUE 'SAVE',
  c_print(5)     VALUE 'PRINT',
  c_exit(4)      VALUE 'EXIT',
  c_cancel(6)    VALUE 'CANCEL',
  c_311(3)       VALUE '311',
  c_mvt_ind_b(1) VALUE 'B',
  c_mvt_04(2)    VALUE '04',
  c_x(1)         VALUE 'X',
  c_d(1)         VALUE 'D'.

*** Declaration for toolbar buttons
DATA : ty_toolbar     TYPE stb_button,
       e_object       TYPE REF TO cl_alv_event_toolbar_set,
       io_alv_toolbar TYPE REF TO cl_alv_event_toolbar_set.
*** Declaration for excluding toolbar buttons
DATA :gs_exclude   TYPE ui_func,
      gt_tlbr_excl TYPE ui_functions.
CLASS event_class DEFINITION DEFERRED.
DATA: lr_event TYPE REF TO event_class.

CLASS event_class DEFINITION.
  PUBLIC SECTION.
***---code addition for ALV pushbuttons
***--for placing buttons
    METHODS : handle_toolbar_set
        FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING
        e_object
        e_interactive,
      handle_user_command
                  FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,

      handle_data_changed
                  FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed.

ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION

*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS event_class IMPLEMENTATION.
*** method for handling toolbar
  METHOD handle_toolbar_set.
*    READ TABLE E_OBJECT->MT_TOOLBAR TRANSPORTING NO FIELDS WITH KEY FUNCTION = 'ADD'.
*    IF SY-SUBRC = 0.
*      RETURN.
*    ENDIF.
*    CLEAR TY_TOOLBAR.
*    TY_TOOLBAR-FUNCTION = 'ADD'. "name of btn to  catch click
*    TY_TOOLBAR-BUTN_TYPE = 0.
*    TY_TOOLBAR-TEXT = 'Add Record'.
*    APPEND TY_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
  ENDMETHOD.                    "handle_toolbar_set

  METHOD handle_user_command.
*    DATA: LT_ROWS TYPE LVC_T_ROW.
*    CASE E_UCOMM.
*      WHEN 'ADD'.
*        APPEND GS_DATA TO GT_DATA.
*        PERFORM DISPLAY_DATA.
*    ENDCASE.
*    CLEAR :E_UCOMM.
  ENDMETHOD.

  METHOD handle_data_changed.
    IF grid IS BOUND.
      CALL METHOD grid->refresh_table_display.
    ENDIF.
  ENDMETHOD.

ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION
