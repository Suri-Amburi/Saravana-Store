*&---------------------------------------------------------------------*
*& Include          ZSD_SALES_REPORT_F01
*&---------------------------------------------------------------------*

FORM get_data.
*** Get Data
  SELECT
    vbrk~vbeln,
    vbrp~posnr,
    vbrp~matnr,
    vbrp~werks,
    CASE
      WHEN vbrp~shkzg = @c_x THEN vbrp~fkimg * -1
      WHEN vbrp~shkzg = @c_space THEN vbrp~fkimg
    END AS fkimg,
    vbrp~meins,
    vbrp~netwr,
    vbrp~mwsbp,
    vbrp~netwr + vbrp~mwsbp AS tot_amount,
    mara~matkl,
    mara~zzprice_frm,
    mara~zzprice_to,
    mara~size1,
    makt~maktx,
    t023t~wgbez,
    klah1~class AS group
    INTO TABLE @DATA(lt_sales)
    FROM vbrk AS vbrk
    INNER JOIN vbrp AS vbrp ON vbrp~vbeln = vbrk~vbeln
    INNER JOIN mara AS mara ON mara~matnr = vbrp~matnr
    INNER JOIN makt AS makt ON makt~matnr = vbrp~matnr
    LEFT JOIN klah AS klah ON klah~klart = '026' AND  klah~class = mara~matkl
    LEFT JOIN kssk AS kssk  ON kssk~objek = klah~clint
    LEFT JOIN klah AS klah1 ON kssk~clint = klah1~clint
    LEFT JOIN t023t AS t023t ON t023t~matkl = mara~matkl AND t023t~spras = @sy-langu
    WHERE vbrp~werks IN @s_plant AND mara~matkl IN @s_matkl AND mara~size1 IN @r_size AND zzprice_frm IN @r_from
    AND   vbrk~fkdat IN @s_budat AND zzprice_to IN @r_to AND fkart = 'FP' AND fksto = @space AND klah1~class IN @s_class.

  IF lt_sales IS NOT INITIAL.
    FIELD-SYMBOLS : <ls_sales> LIKE LINE OF lt_sales.
    DATA          : ls_final TYPE ty_final.
    SORT lt_sales BY matkl matnr group.
    LOOP AT lt_sales ASSIGNING <ls_sales>.
      IF pr_detl IS NOT INITIAL.
        ls_final-vbeln       = <ls_sales>-vbeln.
        ls_final-werks       = <ls_sales>-werks.
      ENDIF.
      ls_final-group       = <ls_sales>-group.
      ls_final-matkl       = <ls_sales>-matkl.
      ls_final-matnr       = <ls_sales>-matnr.
      ls_final-maktx       = <ls_sales>-maktx.
      ls_final-zzprice_frm = <ls_sales>-zzprice_frm.
      ls_final-zzprice_to  = <ls_sales>-zzprice_to.
      ls_final-netwr       = <ls_sales>-netwr.
      ls_final-menge       = <ls_sales>-fkimg.
      ls_final-meins       = <ls_sales>-meins.
      ls_final-mwsbp       = <ls_sales>-mwsbp.
      ls_final-tot_amount  = <ls_sales>-tot_amount.
      COLLECT ls_final INTO gt_final.
    ENDLOOP.
  ENDIF.
ENDFORM.

FORM display.
*** Display Data

  DATA : lr_alv       TYPE REF TO cl_salv_table,
         lr_cols      TYPE REF TO cl_salv_columns,
         lr_col       TYPE REF TO cl_salv_column,
         lr_functions TYPE REF TO cl_salv_functions,
         lr_display   TYPE REF TO cl_salv_display_settings.

  TRY.
      cl_salv_table=>factory(
      EXPORTING
        list_display   = if_salv_c_bool_sap=>false    " ALV Displayed in List Mode
        IMPORTING
        r_salv_table   = lr_alv                       " Basis Class Simple ALV Tables
        CHANGING
        t_table        = gt_final ).

***   Column optimization
      lr_cols = lr_alv->get_columns( ).
      lr_cols->set_optimize( c_x ).
      lr_display = lr_alv->get_display_settings( ).
      lr_display->set_striped_pattern( cl_salv_display_settings=>true ).

      lr_functions = lr_alv->get_functions( ) .
      lr_functions->set_all( abap_true ).
*** Store
      TRY.
          IF pr_detl IS INITIAL.
            lr_col = lr_cols->get_column( 'WERKS' ).
            lr_col->set_technical( c_x ).

            lr_col = lr_cols->get_column( 'VBELN' ).
            lr_col->set_technical( c_x ).
          ENDIF.

          lr_col = lr_cols->get_column( 'GROUP' ).
          lr_col->set_long_text( 'Group' ).
          lr_col->set_medium_text( 'Group' ).
          lr_col->set_short_text('Group').

          lr_col = lr_cols->get_column( 'MATNR' ).
          lr_col->set_long_text( 'SST No' ).
          lr_col->set_medium_text( 'SST No' ).
          lr_col->set_short_text('SST No').

          lr_col = lr_cols->get_column( 'MATKL' ).
          lr_col->set_long_text( 'Category' ).
          lr_col->set_medium_text( 'Category' ).
          lr_col->set_short_text('Category').

          lr_col = lr_cols->get_column( 'TOT_AMOUNT' ).
          lr_col->set_long_text( 'Total Amount' ).
          lr_col->set_medium_text( 'Total Amount' ).

          lr_col = lr_cols->get_column( 'ZZPRICE_FRM' ).
          lr_col->set_long_text( 'From Price' ).
          lr_col->set_medium_text( 'From Price' ).
          lr_col->set_short_text('From Price').

          lr_col = lr_cols->get_column( 'ZZPRICE_TO' ).
          lr_col->set_long_text( 'To Price' ).
          lr_col->set_medium_text( 'To Price' ).
          lr_col->set_short_text('To Price').

        CATCH cx_salv_not_found.
      ENDTRY.

*** Aggirations
      DATA: lr_aggrs TYPE REF TO cl_salv_aggregations.
      lr_aggrs = lr_alv->get_aggregations( ).               "get aggregations
***   Add TOTAL for COLUMN NETWR
      TRY.
          CALL METHOD lr_aggrs->add_aggregation             "add aggregation
            EXPORTING
              columnname  = 'NETWR'                         "aggregation column name
              aggregation = if_salv_c_aggregation=>total.   "aggregation type

          CALL METHOD lr_aggrs->add_aggregation             "add aggregation
            EXPORTING
              columnname  = 'TOT_AMOUNT'                    "aggregation column name
              aggregation = if_salv_c_aggregation=>total.   "aggregation type

          CALL METHOD lr_aggrs->add_aggregation             "add aggregation
            EXPORTING
              columnname  = 'MENGE'                         "aggregation column name
              aggregation = if_salv_c_aggregation=>total.   "aggregation type

          CALL METHOD lr_aggrs->add_aggregation             "add aggregation
            EXPORTING
              columnname  = 'MWSBP'                         "aggregation column name
              aggregation = if_salv_c_aggregation=>total.   "aggregation type
        CATCH cx_salv_data_error .                      "#EC NO_HANDLER
        CATCH cx_salv_not_found .                       "#EC NO_HANDLER
        CATCH cx_salv_existing .                        "#EC NO_HANDLER
      ENDTRY.
    CATCH cx_salv_msg.
  ENDTRY .

***  register to the events of cl_salv_table
  DATA: lr_events TYPE REF TO cl_salv_events_table.
  lr_events = lr_alv->get_event( ).
  lr_alv->display( ).
ENDFORM.
