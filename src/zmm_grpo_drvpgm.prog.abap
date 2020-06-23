*&---------------------------------------------------------------------*
*& Report ZMM_GRPO_DRVPGM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_GRPO_DRVPGM.
*data : lv_qr type ZQR_CODE .
*include ZMM_GRPO_DRVPGM_TOP.
include ZMM_GRPO_DRVPGM_SEL.
*include ZMM_GRPO_DRVPGM_PERFORM.
*include ZMM_GRPO_DRVPGM_FORM.


  DATA FMNAME TYPE RS38L_FNAM.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZMM_GRPO_FORM'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      FM_NAME            = FMNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

                CALL FUNCTION '/1BCDWB/SF00000002'
                  EXPORTING
*                   ARCHIVE_INDEX              =
*                   ARCHIVE_INDEX_TAB          =
*                   ARCHIVE_PARAMETERS         =
*                   CONTROL_PARAMETERS         =
*                   MAIL_APPL_OBJ              =
*                   MAIL_RECIPIENT             =
*                   MAIL_SENDER                =
*                   OUTPUT_OPTIONS             =
*                   USER_SETTINGS              = 'X'
                    LV_QR_CODE                 = s_qr
*                 IMPORTING
*                   DOCUMENT_OUTPUT_INFO       =
*                   JOB_OUTPUT_INFO            =
*                   JOB_OUTPUT_OPTIONS         =
*                  TABLES
*                    IT_FINAL                   =
*                 EXCEPTIONS
*                   FORMATTING_ERROR           = 1
*                   INTERNAL_ERROR             = 2
*                   SEND_ERROR                 = 3
*                   USER_CANCELED              = 4
*                   OTHERS                     = 5
                          .
                IF SY-SUBRC <> 0.
* Implement suitable error handling here
                ENDIF.
*  call function
