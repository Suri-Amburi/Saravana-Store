*&---------------------------------------------------------------------*
*& Report ZSST_MM_AGENT_MAIL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSST_MM_AGENT_MAIL.

DATA  : FORM_NAME1  TYPE RS38l_FNAM .
TYPES : BEGIN OF TY_HDR,
          QR_CODE   TYPE ZINW_T_HDR-QR_CODE,
          EBELN     TYPE ZINW_T_HDR-EBELN  ,
          RETURN_PO TYPE ZINW_T_HDR-RETURN_PO,
          TAT_PO    TYPE ZINW_T_HDR-TAT_PO,
        END OF TY_HDR.

DATA: i_otf       TYPE itcoo    OCCURS 0 WITH HEADER LINE,
      i_tline     LIKE tline    OCCURS 0 WITH HEADER LINE,
      i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE,
      i_xstring   TYPE xstring,
* Objects to send mail.
      i_objpack   LIKE sopcklsti1 OCCURS 0 WITH HEADER LINE,
      i_objtxt    LIKE solisti1   OCCURS 0 WITH HEADER LINE,
      i_objbin    LIKE solix      OCCURS 0 WITH HEADER LINE,
      i_reclist   LIKE somlreci1  OCCURS 0 WITH HEADER LINE,
* Work Area declarations
      wa_objhead  TYPE soli_tab,
      w_ctrlop    TYPE ssfctrlop,
      w_compop    TYPE ssfcompop,
      w_return    TYPE ssfcrescl,
      wa_buffer   TYPE string,
* Variables declarations
      v_form_name TYPE rs38l_fnam,
      v_len_in    LIKE sood-objlen.

DATA: in_mailid TYPE ad_smtpadr.

DATA : IT_HDR TYPE TABLE OF TY_HDR.
DATA : WA_HDR TYPE TY_HDR.


*      DATA : GV_QR TYPE ZINW_T_HDR-QR_CODE.
SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

*SELECT-OPTIONS: S_QR   FOR GV_QR .
**                S_MATKL FOR GV_MATKL,
**                S_MATNR FOR GV_MATNR.
PARAMETERS : P_QR TYPE ZINW_T_HDR-QR_CODE.

SELECTION-SCREEN : END OF BLOCK b1.

START-OF-SELECTION.

SELECT QR_CODE
       EBELN
       RETURN_PO
       TAT_PO
FROM ZINW_T_HDR
INTO TABLE IT_HDR
WHERE QR_CODE EQ P_QR.

READ TABLE IT_HDR INTO WA_HDR WITH KEY QR_CODE = P_QR.
*WRITE : 'HELLO'.
IF SY-SUBRC EQ 0.
  IF WA_HDR-RETURN_PO IS NOT INITIAL.
CALL FUNCTION 'ZFM_PURCHASE_FORM'
  EXPORTING
    LV_EBELN             = WA_HDR-EBELN
*   REG_PO               =
   RETURN_PO            = 'X'
*   TATKAL_PO            = WA_HDR-TAT_PO
*   PRINT_PRIEVIEW       =
*   SERVICE_PO           =
          .

ELSEIF WA_HDR-TAT_PO IS NOT INITIAL.
  CALL FUNCTION 'ZFM_PURCHASE_FORM'
    EXPORTING
      LV_EBELN             = WA_HDR-EBELN
*     REG_PO               =
*     RETURN_PO            =
     TATKAL_PO            = 'X'
*     PRINT_PRIEVIEW       =
*     SERVICE_PO           =
            .
  ENDIF.
ENDIF.

CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    FORMNAME                 = 'ZMM_GRPO_FORM'
*   VARIANT                  = ' '
*   DIRECT_CALL              = ' '
 IMPORTING
   FM_NAME                  = FORM_NAME1
 EXCEPTIONS
   NO_FORM                  = 1
   NO_FUNCTION_MODULE       = 2
   OTHERS                   = 3
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

w_ctrlop-getotf = 'X'.
*w_ctrlop-PREVIEW = 'X'.
w_ctrlop-no_dialog = 'X'.
*w_compop-tdnoprev = 'X'.
w_compop-tddest = 'LP01'.

CALL FUNCTION FORM_NAME1
    EXPORTING
    control_parameters = w_ctrlop
    output_options     = w_compop
    user_settings      = 'X'
    LV_QR_CODE         = P_QR
    IMPORTING
    job_output_info    = w_return
    EXCEPTIONS
      formatting_error = 1
      internal_error   = 2
      send_error       = 3
      user_canceled    = 4
     OTHERS            = 5.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

    ENDIF.

     i_otf[] = w_return-otfdata[].
   IF I_OTF[] IS NOT INITIAL.

    CALL FUNCTION 'CONVERT_OTF'
    EXPORTING
      format                = 'PDF'
      max_linewidth         = 132
    IMPORTING
      bin_filesize          = v_len_in
      bin_file              = i_xstring   " This is NOT Binary. This is Hexa
    TABLES
      otf                   = i_otf
      lines                 = i_tline
    EXCEPTIONS
      err_max_linewidth     = 1
      err_format            = 2
      err_conv_not_possible = 3
      OTHERS                = 4.
* Sy-subrc check not checked

CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer     = i_xstring
    TABLES
      binary_tab = i_objbin[].

DATA: salutation TYPE string.
  DATA: body TYPE string.
  DATA: footer TYPE string.

  DATA: lo_send_request TYPE REF TO cl_bcs,
        lo_document     TYPE REF TO cl_document_bcs,
        lo_sender       TYPE REF TO if_sender_bcs,
        lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL,
        lt_message_body TYPE bcsy_text,
        lx_document_bcs TYPE REF TO cx_document_bcs,
        lv_sent_to_all  TYPE os_boolean.

  REFRESH lt_message_body.
  "create send request
  lo_send_request = cl_bcs=>create_persistent( ).

  "create message body and subject
  salutation ='Dear Sir/Madam,'.
  APPEND salutation TO lt_message_body.
  APPEND INITIAL LINE TO lt_message_body.

  body = 'GRPO Summary'.
  APPEND body TO lt_message_body.
  APPEND INITIAL LINE TO lt_message_body.

  footer = 'With Regards,'.
  APPEND footer TO lt_message_body.
  footer = 'ZIETA'.
  APPEND footer TO lt_message_body.
  "put your text into the document
  lo_document = cl_document_bcs=>create_document(
  i_type = 'RAW'
  i_text = lt_message_body
  i_subject = 'GRPO SUMMARY' ).

  TRY.
      lo_document->add_attachment(
      EXPORTING
      i_attachment_type = 'PDF'
      i_attachment_subject = 'GRPO'
      i_att_content_hex = i_objbin[] ).
    CATCH cx_document_bcs INTO lx_document_bcs.
  ENDTRY.

* Add attachment
* Pass the document to send request
*IF I_OTF IS NOT INITIAL .
**  IF IT_SLT IS NOT INITIAL.
*
  lo_send_request->set_document( lo_document ).

  "Create sender
  lo_sender = cl_sapuser_bcs=>create( sy-uname ).

  "Set sender
  lo_send_request->set_sender( lo_sender ).
**  IF IT_EMAIL IS NOT INITIAL.
**  IN_MAILID = WA_EMAIL-MAIL.
*  "Create recipient
*  lo_recipient = cl_cam_address_bcs=>create_internet_address( IN_MAILID ).
*
**Set recipient
*  lo_send_request->add_recipient(
*  EXPORTING
*  i_recipient = lo_recipient
*  i_express = abap_true
*  ).
*endif.

lo_recipient = cl_cam_address_bcs=>create_internet_address( 'suri.amburi@zietatech.com' ).

*Set recipient
  lo_send_request->add_recipient(
  EXPORTING
  i_recipient = lo_recipient
  i_express = abap_true
  ).

   lo_recipient = cl_cam_address_bcs=>create_internet_address( 'KRITHIKANAVODAYA@GMAIL.COM' ).

*Set recipient
  lo_send_request->add_recipient(
  EXPORTING
  i_recipient = lo_recipient
  i_express = abap_true
  ).


  lo_send_request->send(
  EXPORTING
  i_with_error_screen = abap_true
  RECEIVING
  result = lv_sent_to_all ).

*  ENDIF.

CLEAR IN_MAILID.

CONCATENATE 'Email sent to' 'KRITHIKA' INTO data(lv_msg) SEPARATED BY space.
 WRITE:/ lv_msg COLOR COL_POSITIVE.
  SKIP.
* Commit Work to send the email
  COMMIT WORK.

ENDIF.
