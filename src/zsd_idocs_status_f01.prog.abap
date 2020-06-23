*&---------------------------------------------------------------------*
*& Include          ZSD_ERROR_IDOCS_F01
*&---------------------------------------------------------------------*

FORM get_data.

  FIELD-SYMBOLS :
    <ls_data>        TYPE ty_final,
    <ls_data_key>    TYPE ty_final,
    <ls_final>       TYPE ty_final,
    <ls_idoc_seg>    TYPE ty_idoc_seg,
    <ls_foldoc>      TYPE wpusa_foldoc,
    <ls_data_foldoc> TYPE ty_data_foldoc,
    <ls_invoice_hdr> TYPE ty_invoice_hdr,
    <p>.

  DATA :
    lt_foldoc   TYPE wpusa_t_foldoc,
    lv_exist(1),
    lg          TYPE i.

  REFRESH : gt_data , gt_idoc_seg.
*** Idoc Error Messages
  SELECT docnum,
         segnum,
         msgnr,
         msgid,
         parameter1,
         parameter2,
         parameter3,
         parameter4
         FROM wplst INTO TABLE @DATA(lt_wplst) WHERE docnum IN @s_docnum AND fehlertyp = @c_e.

  IF lt_wplst IS NOT INITIAL.
**** Errored Idoc
    SELECT edidc~docnum,
           edidc~rcvprn,
           edidc~status,
           edidc~credat,
           edid4~segnam,
           edid4~segnum,
           edid4h~dtint2,
           edid4h~sdata,
           edid4~dtint2,
           edid4~sdata
           FROM edid4 AS edid4
           INNER JOIN edidc ON edid4~docnum = edidc~docnum AND edid4~segnam = 'E1WPU02'
           INNER JOIN edid4 AS edid4h ON edid4h~docnum = edid4~docnum AND edid4h~segnam = 'E1WPU01'
           FOR ALL ENTRIES IN @lt_wplst
           WHERE edidc~status <> '53' AND edidc~status <> '70'
           AND   edid4~docnum = @lt_wplst-docnum AND edid4~segnum = @lt_wplst-segnum
           INTO TABLE @gt_idoc_seg.

*** Message Texts
    SELECT DISTINCT
           arbgb,
           msgnr,
           text
           INTO TABLE @DATA(lt_msgs)
           FROM t100 FOR ALL ENTRIES IN @lt_wplst
           WHERE arbgb = @lt_wplst-msgid AND msgnr = @lt_wplst-msgnr AND sprsl = @sy-langu(1).
  ENDIF.

  FIELD-SYMBOLS : <ls_wplst> LIKE LINE OF lt_wplst,
                  <ls_msgs>  LIKE LINE OF lt_msgs.
  SORT lt_wplst BY docnum segnum.
  SORT gt_idoc_seg BY docnum segnum.
***  Final Table
  LOOP AT lt_wplst ASSIGNING <ls_wplst>.
    READ TABLE gt_idoc_seg ASSIGNING <ls_idoc_seg> WITH KEY docnum = <ls_wplst>-docnum segnum = <ls_wplst>-segnum BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      APPEND INITIAL LINE TO gt_data ASSIGNING <ls_data>.
      <ls_data>-docnum   = <ls_idoc_seg>-docnum.          " Docu Number
      <ls_data>-segnum   = <ls_idoc_seg>-segnum.          " Segment
      <ls_data>-matnr    = <ls_idoc_seg>-sdata+121(40).   " Material
      <ls_data>-werks    = <ls_idoc_seg>-rcvprn.          " Plant
      <ls_data>-charg    = <ls_idoc_seg>-sdata+29(15).    " Batch
      <ls_data>-pos_date = <ls_idoc_seg>-sdatah+6(2) && '.' && <ls_idoc_seg>-sdatah+4(2) && '.' && <ls_idoc_seg>-sdatah+0(4).  " Posting Date

      IF <ls_idoc_seg>-sdata+44(1) = '-'.
        <ls_data>-idoc_qty = <ls_idoc_seg>-sdata+45(35) * -1.    " Idoc Quantity
      ELSE.
        <ls_data>-idoc_qty = <ls_idoc_seg>-sdata+45(35).         " Idoc Quantity
      ENDIF.
*** Messages
      READ TABLE lt_msgs ASSIGNING <ls_msgs> WITH KEY arbgb = <ls_wplst>-msgid msgnr = <ls_wplst>-msgnr.
      IF sy-subrc IS INITIAL.
        <ls_data>-message = <ls_msgs>-text.
        IF <ls_data>-message CA '&'.
          lg = strlen( <ls_wplst>-parameter1 ).
          IF lg > 0.
            ASSIGN <ls_wplst>-parameter1(lg) TO <p>.
            IF <ls_data>-message CA '&'.
              REPLACE '&' WITH <p> INTO <ls_data>-message.
            ENDIF.
          ELSE.
            IF <ls_data>-message CA '&'.
              REPLACE '&' WITH ' ' INTO <ls_data>-message.
            ENDIF.
          ENDIF.
          lg = strlen( <ls_wplst>-parameter2 ).
          IF lg > 0.
            ASSIGN <ls_wplst>-parameter2(lg) TO <p>.
            IF <ls_data>-message CA '&'.
              REPLACE '&' WITH <p> INTO <ls_data>-message.
            ENDIF.
          ELSE.
            IF <ls_data>-message CA '&'.
              REPLACE '&' WITH ' ' INTO <ls_data>-message.
            ENDIF.
          ENDIF.
          lg = strlen( <ls_wplst>-parameter3 ).
          IF lg > 0.
            ASSIGN <ls_wplst>-parameter3(lg) TO <p>.
            IF <ls_data>-message CA '&'.
              REPLACE '&' WITH <p> INTO <ls_data>-message.
            ENDIF.
          ELSE.
            IF <ls_data>-message CA '&'.
              REPLACE '&' WITH ' ' INTO <ls_data>-message.
            ENDIF.
          ENDIF.
          lg = strlen( <ls_wplst>-parameter4 ).
          IF lg > 0.
            ASSIGN <ls_wplst>-parameter4(lg) TO <p>.
            IF <ls_data>-message CA '&'.
              REPLACE '&' WITH <p> INTO <ls_data>-message.
            ENDIF.
          ELSE.
            IF <ls_data>-message CA '&'.
              REPLACE '&' WITH ' ' INTO <ls_data>-message.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  REFRESH : gt_idoc_seg , lt_msgs , lt_wplst.

ENDFORM.

FORM display.
*** Display Data
  DATA : lr_alv       TYPE REF TO cl_salv_table,
         lr_cols      TYPE REF TO cl_salv_columns,
         lr_col       TYPE REF TO cl_salv_column,
         lr_functions TYPE REF TO cl_salv_functions,
         lr_display   TYPE REF TO cl_salv_display_settings.

  DATA: lo_table   TYPE REF TO cl_salv_table,
        lo_columns TYPE REF TO cl_salv_columns_table,
        lo_column  TYPE REF TO cl_salv_column_list.

  TRY.
      cl_salv_table=>factory(
      EXPORTING
        list_display   = if_salv_c_bool_sap=>false    " ALV Displayed in List Mode
        IMPORTING
        r_salv_table   = lr_alv                       " Basis Class Simple ALV Tables
        CHANGING
        t_table        = gt_data ).

***   Column optimization
      lr_cols = lr_alv->get_columns( ).
      lr_cols->set_optimize( c_x ).
      lr_display = lr_alv->get_display_settings( ).
      lr_display->set_striped_pattern( cl_salv_display_settings=>true ).

      lr_functions = lr_alv->get_functions( ) .
      lr_functions->set_all( abap_true ).
*** Store
      TRY.
          lr_col = lr_cols->get_column( 'POS_DATE' ).
          lr_col->set_long_text( 'Posting Date' ).
          lr_col->set_medium_text( 'Posting Date' ).

          lr_col = lr_cols->get_column( 'DOCNUM' ).
          lr_col->set_long_text( 'IDOC Num' ).
          lr_col->set_medium_text( 'IDOC Num' ).

          lr_col = lr_cols->get_column( 'SEGNUM' ).
          lr_col->set_technical( 'X' ).

          lr_col = lr_cols->get_column( 'BATCH_MAN' ).
          lr_col->set_long_text( 'Batch Managed' ).
          lr_col->set_medium_text( 'Batch Managed' ).

          lr_col = lr_cols->get_column( 'CHARG' ).
          lr_col->set_long_text( 'Batch ' ).
          lr_col->set_medium_text( 'Batch' ).

          lr_col = lr_cols->get_column( 'MESSAGES' ).
          lr_col->set_long_text( 'Message' ).
          lr_col->set_medium_text( 'Message' ).

        CATCH cx_salv_not_found.
      ENDTRY.
    CATCH cx_salv_msg.
  ENDTRY .

  lr_alv->display( ).
ENDFORM.
