*&---------------------------------------------------------------------*
*& Report ZHRC_PLANNED_WRK_TIM_UPLOAD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhrc_planned_wrk_tim_upload.

TYPE-POOLS truxs.
DATA:  it_type  TYPE truxs_t_text_data.

INCLUDE zhrc_planned_wrk_tim_top.
INCLUDE zhrc_planned_wrk_tim_sel.
INCLUDE zhrc_planned_wrk_tim_form.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = 'P_FILE'
    IMPORTING
      file_name     = p_file.


START-OF-SELECTION.

 PERFORM get_data.
  PERFORM bdc_data.
  PERFORM fieldcatlog_design.
  PERFORM display.
