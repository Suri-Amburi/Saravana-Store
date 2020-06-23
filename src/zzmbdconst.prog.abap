***INCLUDE MBDCONST .

***********************************************************************
* constants, which are used for 3.0
***********************************************************************

TYPE-POOLS: slis,
            icon.

* True/False
DATA: c_true  VALUE 'X',
      c_false VALUE ' '.

* Numbers
DATA: c_zero(1) TYPE c VALUE '0'.

* Remote/Integrated
DATA: c_remote     VALUE '0',
      c_integrated VALUE '1'.

* IDOC-direction (EDIMAP, EDIDC, etc.)
DATA: c_direct_out                   VALUE '1'.
DATA: c_direct_in                    VALUE '2'.

* Partner types
DATA: c_prt_logical_system LIKE edidc-rcvprt VALUE 'LS',
      c_prt_customer       LIKE edidc-rcvprt VALUE 'KU',
      c_prt_vendor         LIKE edidc-rcvprt VALUE 'LI'.

* Message-ID
DATA: c_message_id     LIKE t100-arbgb   VALUE 'B1',
      c_message_id_edi LIKE t100-arbgb VALUE 'E0'.

* Special messages
DATA: c_message_link LIKE sy-msgno   VALUE '100'.

* Object types (used in EDIDS for links to other objects)
DATA: c_obj_type_tid(10)             VALUE 'TRANS_ID'.
DATA: c_obj_type_sent_commidoc(10)   VALUE 'SENT_CIDOC'.

* constants for IDOC-status
DATA:
  c_status_out_ale_error         LIKE edidc-status VALUE '29',
  c_status_in_ale_error          LIKE edidc-status VALUE '65',
  c_status_out_arfc_called       LIKE edidc-status VALUE '03',
  c_status_out_error_arfc        LIKE edidc-status VALUE '02',
  c_status_out_edi_triggered     LIKE edidc-status VALUE '18',
  c_status_out_idoc_created      LIKE edidc-status VALUE '01',
  c_status_out_syntax_error      LIKE edidc-status VALUE '26',
  c_status_in_syntax_error       LIKE edidc-status VALUE '60',
  c_status_in_application_error  LIKE edidc-status VALUE '51',
  c_status_out_ready_send        LIKE edidc-status VALUE '30',
  c_status_in_ready_post         LIKE edidc-status VALUE '64',
  c_status_out_idoc_processed    LIKE edidc-status VALUE '31',
  c_status_in_idoc_to_appl       LIKE edidc-status VALUE '62',
  c_status_in_err_idoc_to_appl   LIKE edidc-status VALUE '63',
  c_idoc_status_postponed        LIKE edidc-status VALUE '66',
  c_status_in_idoc_processed     LIKE edidc-status VALUE '68',
  c_status_out_sent              LIKE edidc-status VALUE '12',
  c_status_out_error_sending     LIKE edidc-status VALUE '27',
  c_status_out_syn_err_ignore    LIKE edidc-status VALUE '25',
  c_status_in_syn_err_ignore     LIKE edidc-status VALUE '61',
  c_status_out_edi_subsys_err    LIKE edidc-status VALUE '04',
  c_status_out_error_convert     LIKE edidc-status VALUE '05',
  c_status_in_err_idoc_created   LIKE edidc-status VALUE '56',
  c_status_in_idoc_created       LIKE edidc-status VALUE '50',
  c_status_out_idoc_edited       LIKE edidc-status VALUE '32',
  c_status_in_idoc_edited        LIKE edidc-status VALUE '69',
  c_status_out_err_contr_record  LIKE edidc-status VALUE '34',
  c_status_in_idoc_posted        LIKE edidc-status VALUE '53',
  c_status_in_posted_on_receiver LIKE edidc-status VALUE '41'.

* internal status
DATA: c_idoc_not_complete LIKE edidc-status VALUE 'X',
      c_idoc_appl_called  TYPE edi_stapa1 VALUE 'APPL_CALLED'.

* IDOC direction
DATA: c_idoc_direction_outbound LIKE edidc-direct   VALUE 1,
      c_idoc_direction_inbound  LIKE edidc-direct   VALUE 2.

* Message types
DATA: c_error   LIKE sy-msgty VALUE 'E',
      c_abend   LIKE sy-msgty VALUE 'A',
      c_warning LIKE sy-msgty VALUE 'W',
      c_info    LIKE sy-msgty VALUE 'I'.
* Message numbers
DATA: c_info_ale_actions_out        LIKE bdidocstat-msgno VALUE '006',
      c_info_ale_actions_in         LIKE bdidocstat-msgno VALUE '005',
      c_error_no_recipients         LIKE bdidocstat-msgno VALUE '003',
      c_error_no_data_for_recipient LIKE bdidocstat-msgno VALUE '005',
      c_error_no_link_to_idoc       LIKE bdidocstat-msgno VALUE '002',
      c_error_idoc_segment          LIKE bdidocstat-msgno VALUE '007',
      c_error_mustsegment_filtered  LIKE bdidocstat-msgno VALUE '008',
      c_error_partner_info_out      LIKE bdidocstat-msgno VALUE '009',
      c_error_partner_info_in       LIKE bdidocstat-msgno VALUE '031',
      c_error_partner_info_in_edi   LIKE bdidocstat-msgno VALUE '337',
      c_error_event_code_in         LIKE bdidocstat-msgno VALUE '032',
      c_error_no_input_function     LIKE bdidocstat-msgno VALUE '033',
      c_error_no_function_params    LIKE bdidocstat-msgno VALUE '034',
      c_error_idocs_incompatible    LIKE bdidocstat-msgno VALUE '036',
      c_info_direct_call            LIKE bdidocstat-msgno VALUE '042',
      c_info_task_started           LIKE bdidocstat-msgno VALUE '043',
      c_error_task_not_started      LIKE bdidocstat-msgno VALUE '046',
      c_error_process_not_started   LIKE bdidocstat-msgno VALUE '047',
      c_info_process_started        LIKE bdidocstat-msgno VALUE '048',
      c_info_new_idocs_created      LIKE bdidocstat-msgno VALUE '315',
      c_info_idoc_terminated        LIKE bdidocstat-msgno VALUE '314',
      c_info_status_written_on_err  LIKE bdidocstat-msgno VALUE '306',
      c_info_status_back_after_edit LIKE bdidocstat-msgno VALUE '307',
      c_error_no_classtype          LIKE bdidocstat-msgno VALUE '029',
      c_error_no_classobject        LIKE bdidocstat-msgno VALUE '027',
      c_error_no_list               LIKE bdidocstat-msgno VALUE '023',
      c_error_glob_bukrs            LIKE bdidocstat-msgno VALUE '123',
      c_error_glob_gsber            LIKE bdidocstat-msgno VALUE '124',
      c_abend_idoc_error            LIKE bdidocstat-msgno VALUE '351',
      c_error_no_logical_system     LIKE bdidocstat-msgno VALUE '004',
      c_error_no_cl_object_type     LIKE bdidocstat-msgno VALUE '076',
      c_error_version_change        LIKE bdidocstat-msgno VALUE '351',
      c_error_no_contr_param        LIKE bdidocstat-msgno VALUE '353',
      c_error_wrong_in_cod_ver      LIKE bdidocstat-msgno VALUE '354',
      c_info_idoc_forwarded         LIKE bdidocstat-msgno VALUE '077',
      c_error_no_message_type       LIKE bdidocstat-msgno VALUE '116',
      c_error_loop_problem          LIKE bdidocstat-msgno VALUE '91',
      c_info_status_reset           LIKE bdidocstat-msgno VALUE '317'.
*     c_warning_>1_idoc like bdidocstat-msgno value '273'.

* internal exceptions
DATA: c_exception_some_error        LIKE sy-subrc VALUE '1',
      c_exception_idoc_incomplete   LIKE sy-subrc VALUE '31',
      c_exception_no_segs           LIKE sy-subrc VALUE '3',
      c_exception_no_logical_system LIKE sy-subrc VALUE '4'.

* constants for handling ranges
DATA: c_ran_sig_i(1)                 VALUE 'I'.
DATA: c_ran_opt_eq(2)                VALUE 'EQ'.
DATA: c_ran_opt_cp(2)                VALUE 'CP'.

* constants for workflow-assignments
*data: c_wf_asgn_type_idoc like wfasd-asgtp value 'IDOC',
*      c_wf_asgn_role_idoc_outbound like wfasd-asgrl value 'OUT',
*      c_wf_asgn_role_idoc_inbound like wfasd-asgrl value 'IN'.

* Workflow: ACTION for ASSIGNMENTS
DATA: c_wf_assgn_action_insert     LIKE wfas1-action    VALUE 'I'.

* Workflow: constants for object type
DATA: c_object_type_idoc LIKE wfas1-asgtp   VALUE 'IDOC'.

* Constants for return code
DATA: c_subrc_ok     LIKE sy-subrc     VALUE '0'.
DATA: c_subrc_not_ok LIKE sy-subrc     VALUE '1'.
DATA: c_subrc_exit   LIKE sy-subrc     VALUE '4'.
DATA: c_subrc_continue    LIKE sy-subrc     VALUE '8'.

DATA: c_dequeue_no LIKE edi_help-unlock VALUE 'X'.
DATA: c_dequeue_yes LIKE edi_help-unlock VALUE ' '.



DATA: c_no(1) VALUE 'N'.
DATA: c_yes(1) VALUE 'J'.
DATA: c_cancel(1) VALUE 'A'.
DATA: c_db_read(1) VALUE 'Y'.

* Message type
DATA: c_msg_type_i(1) VALUE 'I'.

* Program SAPLBD11
DATA: c_saplbd11 LIKE edids-repid VALUE 'SAPLBD11'.

* Constants for action mode (popup)
DATA: c_action_delete(4)            VALUE 'DELE'.
DATA: c_action_cancel(4)            VALUE 'CANC'.
DATA: c_action_task_cancel(4)       VALUE 'TASK'.
DATA: c_action_process(4)           VALUE 'PROC'.
DATA: c_action_syntax_error_ignore(4)  VALUE 'IGNR'.

DATA: c_event_object_type_idocappl LIKE
                   swetypecou-objtype VALUE 'IDOCAPPL'.
DATA: c_event_err_process_completed
              LIKE swetypecou-event VALUE 'ERRORPROCESSCOMPLETD'.

* IDOC-display function codes
DATA: c_action_foreground LIKE sy-ucomm VALUE 'FORE',
      c_action_errorforeg LIKE sy-ucomm VALUE 'FERR',
      c_action_deletemark LIKE sy-ucomm VALUE 'DELM',
      c_action_background LIKE sy-ucomm VALUE 'BAGR',
      c_action_closeproce LIKE sy-ucomm VALUE 'CLPR',
      c_action_syn_ignore LIKE sy-ucomm VALUE 'SYNC'.

* OK-code
DATA: c_okcode_proc(4) VALUE 'PROC'.
DATA: c_okcode_dele(4) VALUE 'DELE'.

* Constants for action mode
DATA: c_action_read              VALUE 'R',
      c_action_write             VALUE 'W',
      c_action_clear_and_refresh VALUE 'C'.

* constants for ALE error handling
DATA: c_ale_error_process LIKE wfprc1-prctp VALUE 'ERR_ALE2'.

* Constants for starting Workflow 3.0
* Names of IDOC-Method input parameters.
DATA: c_wf_par_idoc_packet LIKE bdwfretvar-wf_param
                           VALUE 'IDOC_PACKET'.             "#EC NOTEXT
DATA: c_wf_par_task_obj_id LIKE bdwfretvar-wf_param
                           VALUE '_WI_OBJECT_ID'.           "#EC NOTEXT
DATA: c_wf_unprocessed_idocs LIKE bdwfretvar-wf_param
                             VALUE 'Unprocessed_IDOCs'.     "#EC NOTEXT
DATA: c_wf_par_no_of_retries LIKE bdwfretvar-wf_param
                             VALUE 'No_of_retries'.         "#EC NOTEXT
* IDOC Object type
DATA: c_wf_object_idoc      LIKE swotobjid-objtype
                             VALUE 'IDOC',
      c_objtype_idoc_packet LIKE swotobjid-objtype VALUE 'IDOCPACKET'.

* Constants for Workflow container definition
DATA: c_wf_reftype_object LIKE swcontdef-reftype VALUE 'O'.

* Constants for IDOC input mode
DATA: c_inmod_immediate  LIKE edp21-inmod VALUE 1,
      c_inmod_soft_batch LIKE edp21-inmod VALUE 2,
      c_inmod_hard_batch LIKE edp21-inmod VALUE 3.

* Constants for IDOC output mode
DATA:
  c_outmod_ale_immediate LIKE edp13-outmod VALUE 2,
  c_outmod_ale_batch     LIKE edp13-outmod VALUE 4.

* Constants for IDOC inbound processing
DATA: c_common VALUE 'N'. " common process.

* Constants for input type (Workflow <= Rel. 2.2 etc.)
DATA: c_in_workflow_30_flow LIKE tede2-edivr2 VALUE '1',
      c_in_workflow_30_item LIKE tede2-edivr2 VALUE '2',
      c_in_workflow_22      LIKE tede2-edivr2 VALUE '7',
      c_in_no_workflow      LIKE tede2-edivr2 VALUE '6'.

* Constants for Workitem type (Workitem or Workflow)
DATA: c_workitem_item       LIKE swwwihead-wi_type VALUE 'W',
      c_workitem_flow       LIKE swwwihead-wi_type VALUE 'F',
      c_workitem_background LIKE swwwihead-wi_type VALUE 'B'.


* Constants for links
DATA: c_link_type_idoc(10) VALUE 'IDOC'.

* Constants for ALE-Log and Trace ALE Log
*data: c_param_progname like spar-param value 'PROGNAME'.
*data: c_param_idocnumber like spar-param value 'IDOCNUMBER'.
*data: c_object_ale like balobj-object value 'ALE'.
*data: c_subobject_ale_log like balsub-subobject value 'ALE_LOG'.
*data: c_subobject_trace_ale like balsub-subobject value 'TRACE_ALE'.
*data: c_userexitp_saplbd16 like balhdri-userexitp value 'SAPLBD16'.
*data: c_userexitf_msg_dtls_disp like balhdri-userexitf
*                value 'MESSAGE_DETAILS_DISPLAY'.
*data: c_userexitf_hdr_dtls_disp like balhdri-userexitf
*                value 'HEADER_DETAILS_DISPLAY'.
*data: c_message_details_display           value 'M'.
*data: c_header_details_display            value 'H'.

DATA: c_insert VALUE 'I'.


* Constants for RANGES definitions.
DATA: c_ranges_sign_i       TYPE c VALUE 'I',
      c_ranges_option_eq(2) TYPE c VALUE 'EQ'.

* constants for determination of recipients via listings
DATA: c_object_type_listing LIKE tbd10-objtype VALUE 'LISTING',
      c_object_type_list(4) VALUE 'LIST',
      c_distr_list_push     LIKE tbdli-list_attr VALUE '2'.


* constant to activate data selection
*data: c_data_selection_active(14) value 'DATA_SELECTION'.

* constants for ALE/EDI error workflow process types
DATA: c_wf_err_type_input      LIKE tede5-evcods VALUE 'EDII',
      c_wf_err_type_output     LIKE tede5-evcods VALUE 'EDIO',
      c_wf_err_type_syntax_in  LIKE tede5-evcods VALUE 'EDIY',
      c_wf_err_type_syntax_out LIKE tede5-evcods VALUE 'EDIX',
      c_wf_err_type_no_idoc    LIKE tede5-evcods VALUE 'EDIM'.

* Database read option for Function EDI_DOCUMENT_OPEN_FOR_PROCESS
DATA: c_db_read_option_no_read LIKE edi_help-dbr_option VALUE 'N'.

* Constants for *-logic
DATA: c_all(1) TYPE c                VALUE '*',
      c_det(1) TYPE c                VALUE 'D'.

* maximum of range-record when processing performance-optmized SELECT
DATA: c_range_max LIKE sy-tabix      VALUE '20'.

* Workflow: startmode used when creating workflow processes.
DATA:  c_batch  LIKE wfprc1-startmode VALUE 'B'.

* Workflow: object types used when linking objects via ASSIGNMENTS.
DATA: c_wf_obj_idoc LIKE wfas1-asgtp                  VALUE 'IDOC'.

* Workflow: object roles used when linking objects via ASSIGNMENTS.
DATA: c_wf_role_communication_idoc LIKE wfas1-asgrl     VALUE 'CO',
      c_wf_role_inbound_idoc       LIKE wfas1-asgrl     VALUE 'IN',
      c_wf_role_application_idoc   LIKE wfas1-asgrl     VALUE 'AP',
      c_wf_role_master_idoc        LIKE wfas1-asgrl     VALUE 'MA'.

* Exceptions from function IDOC_INPUT
DATA: c_wf_exception_ok LIKE bdwf_param-exception VALUE 0.

* Constants for writing links, used in mbdforms
DATA: c_wf_elem_source       LIKE swcont-element VALUE 'SOURCE_IDOC',
      c_wf_elem_out_idoc     LIKE swcont-element VALUE 'OUTBOUND_IDOC',
      c_wf_elem_master_idoc  LIKE swcont-element VALUE 'MASTER_IDOC',
      c_wf_elem_comm_idoc    LIKE swcont-element
        VALUE 'COMMUNICATION_IDOC',
      c_wf_elem_inbound_idoc LIKE swcont-element VALUE 'INBOUND_IDOC',
      c_wf_elem_appl_idoc    LIKE swcont-element
        VALUE 'APPLICATION_IDOC',
      c_wf_elem_out_object   LIKE swcont-element VALUE 'OUTBOUND_OBJECT',
      c_wf_elem_out_tid      LIKE swcont-element VALUE 'OUTBOUND_TRANS_ID',

      c_wf_elem_in_idoc      LIKE swcont-element VALUE 'INBOUND_IDOC',
      c_wf_elem_in_object    LIKE swcont-element VALUE 'INBOUND_OBJECT',
      c_wf_elem_in_tid       LIKE swcont-element VALUE 'INBOUND_TRANS_ID',

      c_wf_objtype_idoc      LIKE swotobjid-objtype VALUE 'IDOC',
      c_wf_objtype_transid   LIKE swotobjid-objtype VALUE 'TRANSID'.

* constants for the distribution model
DATA: c_model_subsystems LIKE tbd00-custmodel VALUE 'SUBSYSTEMS',
      c_model_contrldata LIKE tbd00-custmodel VALUE 'CONTRLDATA'.

* activities for authorization_check
DATA: c_actvt_create(2) VALUE '01'.
DATA: c_actvt_edit(2) VALUE '02'.
DATA: c_actvt_read(2) VALUE '03'.
CONSTANTS c_display(2) VALUE '03'.
DATA: c_actvt_distribute(2) VALUE '59'.

* Filter objects for SD scenario
DATA: c_objtype_customer LIKE bdi_model-objtype VALUE 'KUNNR',
      c_objtype_vendor   LIKE bdi_model-objtype VALUE 'LIFNR'.

* Checkin/Checkout mode for Upload/Download of OA-model
DATA: c_cico_mode_normal(20)     VALUE ''.
DATA: c_cico_mode_checkin(20)    VALUE 'CHECKIN'.
DATA: c_cico_mode_checkout(20)   VALUE 'CHECKOUT'.

* CCMS Monitoring additional
CONSTANTS: ccms_ale_call LIKE sy-tcode VALUE 'BDMO'.
CONSTANTS: ale_ccms_grp LIKE usr05-parid VALUE 'ALE_CCMS_GRP'.

CONSTANTS: c_aging(10) VALUE '_DATAAGING'.

CONSTANTS: c_mestype_artstm TYPE edimsg-mestyp  VALUE 'WP_PLU', " Msg Type
           c_chg_doc_obj    TYPE bdcp2-cdobjcl VALUE 'MAT_FULL',    " Change Document Object
           c_vkorg          TYPE t001w-vkorg VALUE '1000',
           c_vtweg          TYPE t001w-vtweg VALUE '10',
           c_x(1)           VALUE 'X'.
