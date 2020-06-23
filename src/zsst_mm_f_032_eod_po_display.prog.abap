*&---------------------------------------------------------------------*
*& Include          ZSST_MM_F_032_EOD_PO_DISPLAY
*&---------------------------------------------------------------------*



IF IT_FINAL IS NOT INITIAL.

*  PERFORM CL_SALV USING IT_FINAL CHANGING IT_TABL.

  TRY.
      CALL METHOD CL_SALV_TABLE=>FACTORY "get SALV factory instance
        EXPORTING
          LIST_DISPLAY = IF_SALV_C_BOOL_SAP=>FALSE
*         R_CONTAINER  =
*         CONTAINER_NAME =
        IMPORTING
          R_SALV_TABLE = IT_TABLE
        CHANGING
          T_TABLE      = IT_FINAL.


* D


* Header object
    CREATE OBJECT LO_HEADER.
*----------------------------------------------------------------------*
* To create a Label or Flow we have to specify the target
* row and column number where we need to set up the output
* text.
*----------------------------------------------------------------------*
* Information in Bold
    IF S_DATE-HIGH IS INITIAL.
    LO_H_LABEL = LO_HEADER->CREATE_LABEL( ROW = 1 COLUMN = 1 ).
    LO_H_LABEL->SET_TEXT('E O D REPORT PURCHASE ORDER CREATED FOR        DATE:').

    LO_H_LABEL = LO_HEADER->CREATE_LABEL( ROW = 1 COLUMN = 2 ).
    LO_H_LABEL->SET_TEXT( S_DATE-LOW ).
    ELSE.
      LO_H_LABEL = LO_HEADER->CREATE_LABEL( ROW = 1 COLUMN = 1 ).
    LO_H_LABEL->SET_TEXT('E O D REPORT PURCHASE ORDER CREATED FOR        FROM :').

    LO_H_LABEL = LO_HEADER->CREATE_LABEL( ROW = 1 COLUMN = 2 ).
    LO_H_LABEL->SET_TEXT( S_DATE-LOW ).

    LO_H_LABEL = LO_HEADER->CREATE_LABEL( ROW = 1 COLUMN = 3 ).
    LO_H_LABEL->SET_TEXT('TO :').

    LO_H_LABEL = LO_HEADER->CREATE_LABEL( ROW = 1 COLUMN = 4 ).
    LO_H_LABEL->SET_TEXT( S_DATE-HIGH ).

    ENDIF.

    IT_TABLE->SET_TOP_OF_LIST( LO_HEADER ).

LR_columns = IT_table->get_columns( ).
*
LR_cOL ?= LR_columns->get_column( 'GROUP' ).
LR_COL->set_key( IF_SALV_C_BOOL_SAP=>TRUE ).
LR_COL->SET_CELL_TYPE( IF_SALV_C_CELL_TYPE=>HOTSPOT ).
LR_COL->set_long_text( 'GROUP' ).
CLEAR: LR_COL.
LR_COLUMNS->set_key_fixation( ).

LR_columns->set_column_position(
    columnname = 'SR_NO'
    position   = 1
  ).

LR_COL ?= LR_COLUMNS->GET_COLUMN( 'SR_NO' ).
LR_COL->set_long_text( 'SR_NO' ).
CLEAR: LR_COL.

LR_COL ?= LR_COLUMNS->GET_COLUMN( 'OR_QTY' ).
LR_COL->set_long_text( 'TOTAL PCS' ).
CLEAR: LR_COL.

LR_COL ?= LR_COLUMNS->GET_COLUMN( 'NO_PO' ).
LR_COL->set_long_text( 'NO.PO' ).
CLEAR: LR_COL.

LR_COL ?= LR_COLUMNS->GET_COLUMN( 'NTWR' ).
LR_COL->set_long_text( 'TOTAL VALUE' ).
CLEAR: LR_COL.

LR_COL ?= LR_COLUMNS->GET_COLUMN( 'EKGRP' ).
lr_COL->set_visible( value  = if_salv_c_bool_sap=>false ).
*go_alv->get_columns( )->set_column_position( columnname = 'PERNR'
*position = 4 ).

 CATCH CX_SALV_MSG .
  ENDTRY.
 " efault functions
    LO_FUNCTIONS = IT_TABLE->GET_FUNCTIONS( ).
    LO_FUNCTIONS->SET_DEFAULT( ABAP_TRUE ).

CLEAR: LR_COL.
 IT_EVENTS = IT_TABLE->GET_EVENT( ).
 CREATE OBJECT EVENT_HANDLER.
 SET HANDLER EVENT_HANDLER->ON_LINK_CLICK FOR IT_EVENTS.


    lo_aggrs = IT_TABLE->get_aggregations( ).

    PERFORM FLD_TOT USING 'OR_QTY' ."LV_FIELD.
    PERFORM FLD_TOT USING 'NTWR' .
    PERFORM FLD_TOT USING 'NO_PO'.


  IT_TABLE->display( ).

  CLEAR LR_COLUMNS.

 ENDIF.

CLASS LCL_HANDLE_EVENTS IMPLEMENTATION.

  METHOD ON_LINK_CLICK.
    READ TABLE IT_FINAL INTO WA_FINAL INDEX ROW.
    REFRESH IT_SLT.
    SR_NO = 0.
    LOOP AT IT_EK INTO WA_EK WHERE EKGRP = WA_FINAL-EKGRP.
      SR_NO        = SR_NO + 1 .
      WA_SLT-SR_NO = SR_NO .
      MOVE WA_EK-EBELN TO WA_SLT-EBELN.
      MOVE WA_EK-LIFNR TO WA_SLT-VEN_NO.
      READ TABLE IT_LFA1 INTO WA_LFA1 WITH KEY LIFNR = WA_EK-LIFNR.
      IF SY-SUBRC = 0.
         MOVE WA_LFA1-NAME1 TO WA_SLT-DESC.
         MOVE WA_LFA1-ORT01 TO WA_SLT-LOC.
      ENDIF.
      LOOP AT IT_EKKO INTO WA_EKKO WHERE EBELN = WA_EK-EBELN AND EKGRP = WA_EK-EKGRP.
        WA_SLT-MENGE = WA_SLT-MENGE + WA_EKKO-MENGE .
        WA_SLT-NETWR = WA_SLT-NETWR + WA_EKKO-NETWR.
      ENDLOOP.
      APPEND WA_SLT TO IT_SLT.
      CLEAR : WA_SLT.
    ENDLOOP.

     cl_salv_table=>factory( IMPORTING r_salv_table = IT_TAB CHANGING t_table = IT_SLT ).

      LO_FUNCTIONS = IT_TAB->GET_FUNCTIONS( ).
    LO_FUNCTIONS->SET_DEFAULT( ABAP_TRUE ).


    CREATE OBJECT LO_HEADER.
*----------------------------------------------------------------------*
* To create a Label or Flow we have to specify the target
* row and column number where we need to set up the output
* text.
*----------------------------------------------------------------------*
* Information in Bold
    LO_H_LABEL = LO_HEADER->CREATE_LABEL( ROW = 1 COLUMN = 1 ).
    LO_H_LABEL->SET_TEXT('E O D REPORT PURCHASE ORDER CREATED FOR').

    LO_H_LABEL = LO_HEADER->CREATE_LABEL( ROW = 1 COLUMN = 2 ).
    LO_H_LABEL->SET_TEXT( WA_FINAL-GROUP ).
    IF S_DATE-HIGH IS INITIAL.
     LO_H_LABEL = LO_HEADER->CREATE_LABEL( ROW = 1 COLUMN = 3 ).
    LO_H_LABEL->SET_TEXT( 'GROUP (OPEN CATEGORY)                     DATE:').


    LO_H_LABEL = LO_HEADER->CREATE_LABEL( ROW = 1 COLUMN = 4 ).
    LO_H_LABEL->SET_TEXT( S_DATE-LOW ).
    ELSE.
      LO_H_LABEL = LO_HEADER->CREATE_LABEL( ROW = 1 COLUMN = 3 ).
    LO_H_LABEL->SET_TEXT( 'GROUP (OPEN CATEGORY)                     FROM :').


    LO_H_LABEL = LO_HEADER->CREATE_LABEL( ROW = 1 COLUMN = 4 ).
    LO_H_LABEL->SET_TEXT( S_DATE-LOW ).

    LO_H_LABEL = LO_HEADER->CREATE_LABEL( ROW = 1 COLUMN = 5 ).
    LO_H_LABEL->SET_TEXT( 'TO :').

    LO_H_LABEL = LO_HEADER->CREATE_LABEL( ROW = 1 COLUMN = 6 ).
    LO_H_LABEL->SET_TEXT( S_DATE-HIGH ).

    ENDIF.


    IT_TAB->SET_TOP_OF_LIST( LO_HEADER ).


     LR_columns = IT_tab->get_columns( ).
     LR_COL ?= LR_COLUMNS->GET_COLUMN( 'SR_NO' ).
     LR_COL->set_long_text( 'SL. NO' ).
     CLEAR: LR_COL.

     LR_COL ?= LR_COLUMNS->GET_COLUMN( 'VEN_NO' ).
     LR_COL->set_long_text( 'VENDOR CODE' ).
     CLEAR: LR_COL.

     LR_COL ?= LR_COLUMNS->GET_COLUMN( 'DESC' ).
     LR_COL->set_long_text( 'VENDOR NAME' ).
     CLEAR: LR_COL.

     LR_COL ?= LR_COLUMNS->GET_COLUMN( 'LOC' ).
     LR_COL->set_long_text( 'LOCATION' ).
     CLEAR: LR_COL.

     LR_COL ?= LR_COLUMNS->GET_COLUMN( 'EBELN' ).
     LR_COL->set_long_text( 'SAP PO NO.' ).
     CLEAR: LR_COL.

    LR_COL ?= LR_COLUMNS->GET_COLUMN( 'MENGE' ).
    LR_COL->set_long_text( 'TOTAL PCS' ).
    CLEAR: LR_COL.

    LR_COL ?= LR_COLUMNS->GET_COLUMN( 'NETWR' ).
    LR_COL->set_long_text( 'TOTAL VALUE' ).
    CLEAR: LR_COL.

    lo_aggrs = IT_TAB->get_aggregations( ).
    PERFORM FLD_TOT USING 'MENGE' .
    PERFORM FLD_TOT USING 'NETWR' .

    IT_TAB->DISPLAY( ).
    CLEAR LR_COLUMNS.

  ENDMETHOD.
 ENDCLASS.

 FORM FLD_TOT USING FIELD TYPE LVC_FNAME.

    TRY.
        CALL METHOD lo_aggrs->add_aggregation
          EXPORTING
            columnname  = FIELD
            aggregation = if_salv_c_aggregation=>total.
      CATCH cx_salv_data_error .                        "#EC NO_HANDLER
      CATCH cx_salv_not_found .                         "#EC NO_HANDLER
      CATCH cx_salv_existing .                          "#EC NO_HANDLER
    ENDTRY.

 ENDFORM.
