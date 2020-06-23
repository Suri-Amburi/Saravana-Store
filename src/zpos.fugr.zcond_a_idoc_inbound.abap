FUNCTION zcond_a_idoc_inbound.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(INPUT_METHOD) LIKE  BDWFAP_PAR-INPUTMETHD
*"     VALUE(MASS_PROCESSING) LIKE  BDWFAP_PAR-MASS_PROC
*"  EXPORTING
*"     VALUE(WORKFLOW_RESULT) LIKE  BDWF_PARAM-RESULT
*"     VALUE(APPLICATION_VARIABLE) LIKE  BDWF_PARAM-APPL_VAR
*"     VALUE(IN_UPDATE_TASK) LIKE  BDWFAP_PAR-UPDATETASK
*"     VALUE(CALL_TRANSACTION_DONE) LIKE  BDWFAP_PAR-CALLTRANS
*"  TABLES
*"      IDOC_CONTRL STRUCTURE  EDIDC
*"      IDOC_DATA STRUCTURE  EDIDD
*"      IDOC_STATUS STRUCTURE  BDIDOCSTAT
*"      RETURN_VARIABLES STRUCTURE  BDWFRETVAR
*"      SERIALIZATION_INFO STRUCTURE  BDI_SER
*"  EXCEPTIONS
*"      WRONG_FUNCTION_CALLED
*"----------------------------------------------------------------------

  DATA:ls_batch_info        TYPE mch1.
  FIELD-SYMBOLS : <ls_idoc_data> TYPE edidd.
  CONSTANTS : c_zcond_a(7) VALUE 'ZCOND_A',
              c_e1komg(7)  VALUE 'E1KOMG'.

  CLEAR : ls_batch_info.
  READ TABLE idoc_data ASSIGNING <ls_idoc_data> WITH KEY segnam = c_zcond_a.
  IF sy-subrc = 0.
    ls_batch_info-zzbatchsrl_informationkey = <ls_idoc_data>-sdata+0(24).
  ENDIF.

  READ TABLE idoc_data ASSIGNING <ls_idoc_data> WITH KEY segnam = c_e1komg.
  IF sy-subrc = 0.
*    ls_batch_info-u_batch_serial_number = <ls_idoc_data>-sdata+119(10).
    ls_batch_info-charg = <ls_idoc_data>-sdata+119(10).
  ENDIF.

  IF ls_batch_info-zzbatchsrl_informationkey IS NOT INITIAL AND ls_batch_info-charg IS NOT INITIAL.
    SHIFT ls_batch_info-zzbatchsrl_informationkey LEFT DELETING LEADING '0'.
*** Success
*** Update Key in Batch Table
*    MODIFY zbatch_info FROM ls_batch_info.
    UPDATE mch1 SET zzbatchsrl_informationkey = ls_batch_info-zzbatchsrl_informationkey WHERE charg = ls_batch_info-charg.
    workflow_result = '99999'.
    CLEAR idoc_status.
    idoc_status-status = '53'.
    idoc_status-msgid  = 'WP'.
    idoc_status-msgty  = 'S'.
    idoc_status-msgno  = '119'.
    idoc_status-repid  = sy-repid.
    CLEAR return_variables.
    return_variables-wf_param = 'Error_IDOCs'.
    LOOP AT idoc_contrl.
      idoc_status-docnum = idoc_contrl-docnum.
      idoc_status-msgv1 = idoc_contrl-mestyp.
      APPEND idoc_status.
      return_variables-doc_number = idoc_contrl-docnum.
      APPEND return_variables.
    ENDLOOP.
  ELSE.
*** Fail
    workflow_result = '99999'.
    CLEAR idoc_status.
    idoc_status-status = '56'.
    idoc_status-msgid  = 'ZMSG_CLS'.
    idoc_status-msgty  = 'E'.
    idoc_status-msgno  = '094'.
    idoc_status-repid  = sy-repid.
    CLEAR return_variables.
    return_variables-wf_param = 'Error_IDOCs'.
    LOOP AT idoc_contrl.
      idoc_status-docnum = idoc_contrl-docnum.
      idoc_status-msgv1 = idoc_contrl-mestyp.
      APPEND idoc_status.
      return_variables-doc_number = idoc_contrl-docnum.
      APPEND return_variables.
    ENDLOOP.
  ENDIF.
ENDFUNCTION.
