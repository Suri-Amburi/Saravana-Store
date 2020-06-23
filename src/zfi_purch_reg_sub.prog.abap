*&---------------------------------------------------------------------*
*& Include          ZFI_PURCH_REG_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZFI_PURCH_REG_SUB
*&---------------------------------------------------------------------*
  CLASS lcl_handle_events DEFINITION.
    PUBLIC SECTION.
      METHODS:
        on_double_click FOR EVENT double_click OF cl_salv_events_table
          IMPORTING row column.
  ENDCLASS.                    "lcl_handle_events DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*----------------------------------------------------------------------*
**   Double click event Handling
*----------------------------------------------------------------------*
  CLASS lcl_handle_events IMPLEMENTATION.
    METHOD on_double_click.

      DATA: row_c(10) TYPE c,
            col_c(16) TYPE c.

      row_c = row.
      col_c = column .
*--> Handle_double_click_based_on_column_selected ->
      READ TABLE gt_final INTO gw_final INDEX row_c  .
      CASE col_c.
        WHEN 'EBELN'.
          CHECK gw_final-ebeln IS NOT INITIAL .
          SET PARAMETER ID 'BES'  FIELD gw_final-ebeln.
          SET PARAMETER ID 'BSP'  FIELD gw_final-ebelp.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
**          WHEN 'MR_BELNR'.
        WHEN 'FI_BELNR' .
          CHECK gw_final-fi_belnr IS NOT INITIAL.
          SET PARAMETER ID 'BLN'  FIELD gw_final-fi_belnr.
          SET PARAMETER ID 'GJR' FIELD gw_final-gjahr.
          SET PARAMETER ID 'BUK' FIELD gw_final-bukrs.
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
***        WHEN 'MATNR' .
***          CHECK gw_final-matnr IS NOT INITIAL.
***          SET PARAMETER ID 'MAT'  FIELD gw_final-matnr.
***          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
        WHEN 'LBLNI' .
          CHECK gw_final-lblni IS NOT INITIAL.
          SET PARAMETER ID 'LBL'  FIELD gw_final-lblni.
          SET PARAMETER ID 'BES'  FIELD gw_final-ebeln.
          SET PARAMETER ID 'BSP'  FIELD gw_final-ebelp.
          CALL TRANSACTION 'ML81N' AND SKIP FIRST SCREEN.
        WHEN OTHERS.
          CHECK gw_final-mr_belnr IS NOT INITIAL .
          SET PARAMETER ID 'RBN' FIELD gw_final-mr_belnr.
          SET PARAMETER ID 'GJR' FIELD gw_final-gjahr.
          CALL TRANSACTION 'MIR4' AND SKIP FIRST SCREEN.
      ENDCASE.

    ENDMETHOD. "on_double_click
  ENDCLASS.

  START-OF-SELECTION .

    IF r1 = 'X'.

      PERFORM get_purch_history .   "Purchase_history_ekbe .
      PERFORM process_data .        "Process_data_for_final_output .
      PERFORM display_output1 .      "Display_output

    ELSEIF  r2 = 'X'.

      DATA: li_selection  TYPE TABLE OF rsparams,
            lwa_selection TYPE rsparams.

IF S_GSBER IS NOT INITIAL.
      CLEAR lwa_selection.
      lwa_selection-selname = 'S_GSBER'.
      lwa_selection-kind    = 'S'.
      lwa_selection-sign    = 'I'.
      lwa_selection-option  = 'BT'.
      lwa_selection-low     = s_gsber-low.
      lwa_selection-high    = s_gsber-high.
      APPEND lwa_selection TO li_selection.
ENDIF.

IF S_GJAHR IS NOT INITIAL.
      CLEAR lwa_selection.
      lwa_selection-selname = 'S_GJAHR'.
      lwa_selection-kind    = 'S'.
      lwa_selection-sign    = 'I'.
      lwa_selection-option  = 'BT'.
      lwa_selection-low     = s_gjahr-low.
      lwa_selection-high    = s_gjahr-high.
      APPEND lwa_selection TO li_selection.
ENDIF.

IF S_BUDAT IS NOT INITIAL.
      CLEAR lwa_selection.
      lwa_selection-selname = 'S_BUDAT'.
      lwa_selection-kind    = 'S'.
      lwa_selection-sign    = 'I'.
      lwa_selection-option  = 'BT'.
      lwa_selection-low     = s_budat-low.
*          APPEND lwa_selection TO li_selection.
      lwa_selection-high    = s_budat-high.
      APPEND lwa_selection TO li_selection.
ENDIF.

IF S_LIFNR IS NOT INITIAL.
      CLEAR lwa_selection.
      lwa_selection-selname = 'S_LIFNR'.
      lwa_selection-kind    = 'S'.
      lwa_selection-sign    = 'I'.
      lwa_selection-option  = 'BT'.
      lwa_selection-low     = s_lifnr-low.
      lwa_selection-high    = s_lifnr-high.
      APPEND lwa_selection TO li_selection.
ENDIF.

      SUBMIT zfi_pur_without_po WITH SELECTION-TABLE li_selection AND RETURN.

**        PERFORM get_data4.
**  PERFORM mov_fin4.
**  PERFORM disply_data4.

    ELSEIF r3 = 'X'.   "Service PO

*      PERFORM get_purch_history .   "Purchase_history_ekbe .
*      PERFORM process_data .        "Process_data_for_final_output .
*      PERFORM display_output1_SER .      "Display_output

      PERFORM get_purch_history_ser .   "Purchase_history_ekbe .
      PERFORM process_data_ser .        "Process_data_for_final_output .
      PERFORM display_output1_ser .      "Display_output

    ENDIF.
