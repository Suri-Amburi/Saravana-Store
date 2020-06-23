*&---------------------------------------------------------------------*
*& Include          ZSST_MM_F_032_FORM
*&---------------------------------------------------------------------*

CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    FORMNAME                 = 'ZSST_MM_F_032_SF'
*   VARIANT                  = ' '
*   DIRECT_CALL              = ' '
 IMPORTING
   FM_NAME                   = FM_NAME
 EXCEPTIONS
   NO_FORM                   = 1
   NO_FUNCTION_MODULE        = 2
   OTHERS                    = 3
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.


w_ctrlop-getotf = 'X'.     " By Suri : 23.09.2019 22:44:00
*w_ctrlop-PREVIEW = 'X'.
w_ctrlop-no_dialog = 'X'.   " By Suri : 23.09.2019 22:44:00
*w_compop-tdnoprev = 'X'.
w_compop-tddest = 'LP01'.

 CALL FUNCTION FM_NAME
    EXPORTING
    control_parameters = w_ctrlop
    output_options     = w_compop
    user_settings      = 'X'
    LV_QTY             = TOT_QTY
    LV_NTR             = TOT_NTWR
    LV_PO              = TOT_PO
    LV_DATE            = P_DATE
    WA_ADRC            = WA_ADR
    IMPORTING
    job_output_info    = w_return
    TABLES
    IT_EOD             = IT_FINAL
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



* Get Output Text Format (OTF)
  i_otf[] = w_return-otfdata[].

* Import Binary file and filesize
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
* Sy-subrc check not required.
*
***************    commented by likhitha     ********************
*WA_EMAIL-MAIL = 'SABA@SARAVANASTORES.NET'.
*APPEND WA_EMAIL TO IT_EMAIL.
*
*WA_EMAIL-MAIL = 'SDP.ASHER@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.

*****WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.                    "BY KRITHIKA 09.10.2019 12.05
*****APPEND WA_EMAIL TO IT_EMAIL.                                     "BY KRITHIKA 09.10.2019 12.05
*****************      end  *****************************************
WA_EMAIL-MAIL = 'SURI.AMBURI@ZIETATECH.COM'.
APPEND WA_EMAIL TO IT_EMAIL.


LOOP AT IT_EMAIL INTO WA_EMAIL.
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

  "create send request
  lo_send_request = cl_bcs=>create_persistent( ).
FREE : lt_message_body.
  "create message body and subject
  salutation ='Dear Sir/Madam,'.
  APPEND salutation TO lt_message_body.
  APPEND INITIAL LINE TO lt_message_body.

  body = 'Please find the attached the EOD PO in PDF format.'.
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
  i_subject = 'EOD PO in PDF' ).

  TRY.
      lo_document->add_attachment(
      EXPORTING
      i_attachment_type = 'PDF'
      i_attachment_subject = 'EOD PO'
      i_att_content_hex = i_objbin[] ).
    CATCH cx_document_bcs INTO lx_document_bcs.
  ENDTRY.

* Add attachment
* Pass the document to send request
IF I_OTF IS NOT INITIAL .

*REFRESH LT_MESSAGE_BODY.

  lo_send_request->set_document( lo_document ).

  "Create sender
  lo_sender = cl_sapuser_bcs=>create( sy-uname ).
 lo_send_request->set_sender( lo_sender ).

  "Set sender

  IN_MAILID = WA_EMAIL-MAIL.
  "Create recipient
  lo_recipient = cl_cam_address_bcs=>create_internet_address( IN_MAILID ).

*Set recipient
  lo_send_request->add_recipient(
  EXPORTING
  i_recipient = lo_recipient
  i_express = abap_true
  ).

    lo_send_request->add_recipient( lo_recipient ).

******************** SETTING TIME ***************************
lv_timestamp = CL_ABAP_TSTMP=>ADD( tstmp = lv_timestamp  secs = 30 ).

lo_send_request->SEND_REQUEST->set_send_at( lv_timestamp ).

* Send email
  lo_send_request->send(
  EXPORTING
  i_with_error_screen = abap_true
  RECEIVING
  result = lv_sent_to_all ).

CLEAR IN_MAILID.

CONCATENATE 'Email sent to' 'KRITHIKA' INTO data(lv_msg) SEPARATED BY space.
 WRITE:/ lv_msg COLOR COL_POSITIVE.
  SKIP.
* Commit Work to send the email
  COMMIT WORK.
ENDIF.
*REFRESH lt_message_body.
ENDLOOP.
