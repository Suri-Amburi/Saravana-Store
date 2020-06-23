*&---------------------------------------------------------------------*
*& Report ZMM_EMP_VEND_BANK_UPD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_emp_vend_bank_upd.
*--> Global_declaration -> sjena <- 18.05.2019 20:04:23
INCLUDE zmm_emp_vend_bank_upd_top .
*--> Input_details -> sjena <- 18.05.2019 20:04:31
INCLUDE zmm_emp_vend_bank_upd_sel .

*--> Subroutine_call -> sjena <- 18.05.2019 20:04:39
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.

AT SELECTION-SCREEN ON p_file.
  PERFORM check_file_path.

  PERFORM get_data CHANGING supl_data.

START-OF-SELECTION .
CHECK supl_data[] IS NOT INITIAL.
*--> Update_bank_details_for_vendor -> sjena <- 18.05.2019 20:09:57
  PERFORM update_supl_data .

*--> Generate_result -> sjena <- 18.05.2019 20:34:13
  PERFORM get_result .

*--> Include_for_subroutine -> sjena <- 18.05.2019 20:04:54
  INCLUDE zmm_emp_vend_bank_upd_sub.
