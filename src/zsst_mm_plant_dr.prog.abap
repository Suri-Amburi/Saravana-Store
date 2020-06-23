*&---------------------------------------------------------------------*
*& Report ZSST_MM_PLANT_DR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSST_MM_PLANT_DR.

DATA  : FM_NAME  TYPE RS38l_FNAM .

TYPES : BEGIN OF TY_EKKO,
          EBELN TYPE EKKO-EBELN,
          AEDAT TYPE EKKO-AEDAT,
          EKGRP TYPE EKKO-EKGRP,
*          LIFNR TYPE EKKO-LIFNR,
          BSART TYPE EKKO-BSART,
          EBELP TYPE EKPO-EBELP,
          RETPO TYPE EKPO-RETPO,
          NETWR TYPE EKPO-NETWR,
          MENGE TYPE EKPO-MENGE,
          WERKS TYPE EKPO-WERKS,
        END OF TY_EKKO,

        BEGIN OF TY_EK,
          EBELN TYPE EKKO-EBELN,
          AEDAT TYPE EKKO-AEDAT,
          EKGRP TYPE EKKO-EKGRP,
          LIFNR TYPE EKKO-LIFNR,
          BSART TYPE EKKO-BSART,
        END OF TY_EK,

        BEGIN OF TY_EKGRP,
          EKGRP TYPE EKKO-EKGRP,
        END OF TY_EKGRP,

        BEGIN OF TY_EKPO,
          EBELN TYPE EKPO-EBELN,
          NETWR TYPE EKPO-NETWR,
          MENGE TYPE EKPO-MENGE,
        END OF TY_EKPO,

        BEGIN OF TY_T024,
          EKGRP TYPE T024-EKGRP,
          EKNAM TYPE T024-EKNAM,
        END OF TY_T024,

        BEGIN OF TY_T001W,
          WERKS TYPE T001W-WERKS,
          ADRNR TYPE T001W-ADRNR,
          NAME1 TYPE T001W-NAME1,
        END OF TY_T001W,

        BEGIN OF TY_ADRC,
          ADDRNUMBER  TYPE ADRC-ADDRNUMBER   ,
          NAME1       TYPE ADRC-NAME1        ,
          NAME2       TYPE ADRC-NAME2        ,
          STREET      TYPE ADRC-STREET       ,
          HOUSE_NUM1  TYPE adrc-HOUSE_NUM1,
          STR_SUPPL1  TYPE ADRC-STR_SUPPL1   ,
          CITY1       TYPE ADRC-CITY1        ,
          POST_CODE1  TYPE ADRC-POST_CODE1   ,
          BEZEI       TYPE T005U-BEZEI       ,
        END OF TY_ADRC,

        BEGIN OF TY_EMAIL,
          MAIL TYPE ADR6-SMTP_ADDR,
        END OF TY_EMAIL,
*
*        BEGIN OF TY_LFA1,
*          LIFNR TYPE LFA1-LIFNR,
*          NAME1 TYPE LFA1-NAME1,
*          ORT01 TYPE LFA1-ORT01,
*        END OF TY_LFA1,
*
*        BEGIN OF TY_SLT,
*          SR_NO   TYPE INT4      ,
*          VEN_NO  TYPE LFA1-LIFNR,
*          DESC    TYPE LFA1-NAME1,
*          LOC     TYPE LFA1-ORT01,
*          EBELN   TYPE EKKO-EBELN,
*          MENGE   TYPE EKPO-MENGE,
*          NETWR   TYPE EKPO-NETWR,
*        END OF TY_SLT,

        BEGIN OF TY_FINAL,
          GROUP  TYPE T024-EKNAM,
          NO_PO  TYPE INT4      ,
          OR_QTY TYPE EKPO-MENGE,
          NTWR   TYPE EKPO-NETWR,
        END OF TY_FINAL.

DATA  : SR_NO       TYPE INT4,
        TOT_QTY     TYPE EKPO-MENGE,
        TOT_PO      TYPE INT4,
        TOT_NTWR    TYPE EKPO-NETWR,
        LV_LIFNR    TYPE EKKO-LIFNR,
        PLANT       TYPE T001W-NAME1,

        LV_FIELD    TYPE CHAR20.


DATA  : IT_EKKO   TYPE TABLE OF TY_EKKO             ,
        IT_EKPO   TYPE TABLE OF TY_EKPO             ,
        IT_EK     TYPE TABLE OF TY_EK               ,
        IT_EKGRP  TYPE TABLE OF TY_EKGRP            ,
        IT_T024   TYPE TABLE OF TY_T024             ,
        IT_T001W  TYPE TABLE OF TY_T001W            ,
        IT_ADRC   TYPE TABLE OF TY_ADRC             ,
        IT_EMAIL  TYPE TABLE OF TY_EMAIL            ,
*        IT_SLT    TYPE TABLE OF TY_SLT              ,
*        IT_LFA1   TYPE TABLE OF TY_LFA1              ,
*        IT_TABLE  TYPE REF   TO CL_SALV_TABLE       ,
*        IT_TAB    TYPE REF   TO CL_SALV_TABLE       ,
*        IT_EVENTS TYPE REF   TO CL_SALV_EVENTS_TABLE,
        IT_FINAL  TYPE TABLE OF ZSST_MM_F_032_STCT  .

DATA  : WA_EKKO   TYPE TY_EKKO           ,
        WA_EKPO   TYPE TY_EKPO           ,
        WA_EK     TYPE TY_EK             ,
        WA_EKGRP  TYPE TY_EKGRP          ,
        WA_T024   TYPE TY_T024           ,
        WA_T001W  TYPE TY_T001W          ,
        WA_ADRC   TYPE TY_ADRC           ,
        WA_ADR    TYPE  ZARC_STR         ,
        WA_EMAIL  TYPE  TY_EMAIL         ,
*        WA_SLT    TYPE TY_SLT            ,
*        WA_LFA1   TYPE TY_LFA1           ,
        WA_FINAL  TYPE ZSST_MM_F_032_STCT.

*DATA :  LV_DATE TYPE ERDAT .
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
      LV_DOC_SUBJECT          TYPE SOOD-OBJDES,
      v_len_in    LIKE sood-objlen.

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
DATA :  LV_DATE TYPE ERDAT ,
         L_DATE TYPE ERDAT.
SELECTION-SCREEN : BEGIN OF  BLOCK B1 WITH FRAME TITLE TEXT-001.
*PARAMETERS        : P_DATE TYPE EKKO-AEDAT,                        " commented on (4-2-20)
  SELECT-OPTIONS :  p_DATE FOR LV_DATE OBLIGATORY no INTERVALS no-EXTENSION DEFAULT sy-datum.
   PARAMETERS :               P_PLANT TYPE EKPO-WERKS.
SELECTION-SCREEN : END   OF  BLOCK B1.


*&---------------------------------------------------------------------*
*& Include          ZSST_MM_F_032_GETDATA
*&---------------------------------------------------------------------*
START-OF-SELECTION.
break clikhitha.
*** Start of Changes by Suri  : 23.09.2019 22:46:00
*  IF  P_DATE IS INITIAL.
*    P_DATE = SY-DATUM.
*  ENDIF.
*** End of Changes by Suri    : 23.09.2019 22:46:00

  SELECT EBELN
         AEDAT
         EKGRP
         lifnr
         BSART
  FROM EKKO
  INTO TABLE IT_EK
  WHERE AEDAT IN P_DATE AND BSART IN ('ZLOP','ZOSP','ZTAT','ZVLO','ZOSP').
if it_ek is NOT INITIAL.    " added on (4-2-20)
  SELECT A~EBELN
         A~AEDAT
         A~EKGRP
         A~BSART
         B~EBELP
         B~RETPO
         B~NETWR
         B~MENGE
         B~WERKS
  FROM   EKKO AS A INNER JOIN EKPO AS B ON ( A~EBELN EQ B~EBELN AND B~RETPO NE 'X' AND WERKS IN ( 'SSCP' ,'SSPO','SSPU','SSTN','SSWH','SSVG' ) )
  INTO TABLE IT_EKKO
  FOR ALL ENTRIES IN IT_EK
  WHERE A~EBELN = IT_EK-EBELN AND A~AEDAT IN P_DATE.


endif.       " added on (4-2-20)
  IF IT_EKKO IS NOT INITIAL.

    SELECT EBELN
           NETWR
           MENGE
    FROM   EKPO
    INTO TABLE IT_EKPO
    FOR ALL ENTRIES IN IT_EKKO
    WHERE EBELN = IT_EKKO-EBELN.

  ENDIF.

*READ TABLE IT_EKPO

  SELECT EKGRP
         EKNAM
  FROM   T024
  INTO TABLE IT_T024
  WHERE EKGRP NE '001' AND
        EKGRP NE '002' AND
        EKGRP NE '003'.

  SELECT WERKS
         ADRNR
         NAME1
  FROM  T001W
  INTO TABLE IT_T001W
  WHERE WERKS IN ('SSCP' ,'SSPO','SSPU','SSTN','SSWH' ,'SSVG').

  SELECT A~ADDRNUMBER
         A~NAME1
         A~NAME2
         A~STREET
         A~HOUSE_NUM1
         A~STR_SUPPL1
         A~CITY1
         A~POST_CODE1
         B~BEZEI
  FROM   ADRC AS A
  INNER JOIN T005U AS B ON ( A~REGION = B~BLAND AND B~SPRAS = SY-LANGU AND A~COUNTRY = B~LAND1 )
  INTO TABLE IT_ADRC
  FOR ALL ENTRIES IN IT_T001W
  WHERE ADDRNUMBER = IT_T001W-ADRNR .

*  LOOP AT IT_T001W INTO WA_T001W.

*  ENDLOOP.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    FORMNAME                 = 'ZSST_MM_PLANT_SF'
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

LOOP AT IT_T001W INTO WA_T001W.
  REFRESH : IT_FINAL.
  CLEAR : SR_NO.
  LOOP AT IT_T024 INTO WA_T024.
    SR_NO          = SR_NO + 1 .
    WA_FINAL-SR_NO = SR_NO .
    SORT IT_EKKO BY EBELN.
    LOOP AT IT_EKKO INTO WA_EKKO WHERE EKGRP = WA_T024-EKGRP AND WERKS = WA_T001W-WERKS.
      AT NEW EBELN.
        WA_FINAL-NO_PO  = WA_FINAL-NO_PO + 1.
      ENDAT.
*      L_DATE = WA_EKKO-AEDAT.
      WA_FINAL-OR_QTY = WA_FINAL-OR_QTY + WA_EKKO-MENGE.
      WA_FINAL-NTWR   = WA_FINAL-NTWR + WA_EKKO-NETWR.
    ENDLOOP.

*    LOOP AT IT_EK INTO WA_EK WHERE EKGRP = WA_T024-EKGRP.
*      WA_FINAL-NO_PO  = WA_FINAL-NO_PO + 1.
*    ENDLOOP.

    MOVE WA_T024-EKNAM TO WA_FINAL-GROUP.
    TOT_QTY  = TOT_QTY  + WA_FINAL-OR_QTY.
    TOT_NTWR = TOT_NTWR + WA_FINAL-NTWR.
    TOT_PO   = TOT_PO   + WA_FINAL-NO_PO.

    APPEND WA_FINAL TO IT_FINAL.
    CLEAR : WA_FINAL.

  ENDLOOP.

  PLANT = WA_T001W-NAME1.
    READ TABLE IT_ADRC INTO WA_ADRC WITH KEY ADDRNUMBER = WA_T001W-ADRNR.
    IF SY-SUBRC = 0.
      MOVE WA_ADRC-ADDRNUMBER    TO WA_ADR-ADDRNUMBER.
      MOVE WA_ADRC-NAME1         TO WA_ADR-NAME1     .
      MOVE WA_ADRC-NAME2         TO WA_ADR-NAME2     .
      MOVE WA_ADRC-STREET        TO WA_ADR-STREET    .
      MOVE WA_ADRC-HOUSE_NUM1    TO WA_ADR-HOUSE_NUM1.
      MOVE WA_ADRC-STR_SUPPL1    TO WA_ADR-STR_SUPPL1.
      MOVE WA_ADRC-CITY1         TO WA_ADR-CITY1     .
      MOVE WA_ADRC-POST_CODE1    TO WA_ADR-POST_CODE1.
      MOVE WA_ADRC-BEZEI         TO WA_ADR-BEZEI     .
      MOVE WA_T001W-WERKS        TO WA_ADR-WERKS     .
    ENDIF.

w_ctrlop-getotf = 'X'.
*w_ctrlop-PREVIEW = 'X'.
w_ctrlop-no_dialog = 'X'.
*w_compop-tdnoprev = 'X'.
w_compop-tddest = 'LP01'.
break clikhitha.
L_DATE = P_DATE-LOW.
CALL FUNCTION FM_NAME
    EXPORTING
    control_parameters = w_ctrlop
    output_options     = w_compop
    user_settings      = 'X'
    LV_QTY             = TOT_QTY
    LV_NTR             = TOT_NTWR
    LV_PO              = TOT_PO
    LV_DATE            = L_DATE   " COMMENTED P_DATE
    LV_PLANT           = PLANT
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

    CLEAR : WA_ADR,
*            P_DATE,
            PLANT,
            TOT_PO,
            TOT_NTWR,
            TOT_QTY.
    REFRESH :  I_OTF[],
               i_objbin[].
    i_otf[] = w_return-otfdata[].

break clikhitha.
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


  REFRESH lt_message_body.
  "create send request
  lo_send_request = cl_bcs=>create_persistent( ).

  "create message body and subject
  salutation ='Dear Sir/Madam,'.
  APPEND salutation TO lt_message_body.
  APPEND INITIAL LINE TO lt_message_body.

  body = 'Please find the attachment of plant wise EOD PO in PDF format.'.
  APPEND body TO lt_message_body.
  APPEND INITIAL LINE TO lt_message_body.

  footer = 'With Regards,'.
  APPEND footer TO lt_message_body.
  footer = 'ZIETA'.
  APPEND footer TO lt_message_body.
  "put your text into the document

  CONCATENATE WA_T001W-NAME1 'EODPO' '.pdf' INTO LV_DOC_SUBJECT.
IF LO_DOCUMENT IS INITIAL.
 lo_document = cl_document_bcs=>create_document(
  i_type = 'RAW'
  i_text = lt_message_body
  i_subject = 'PLANTWISE_EOD_PO' ).
 ENDIF.
  TRY.
      lo_document->add_attachment(
      EXPORTING
      i_attachment_type = 'PDF'
      i_attachment_subject = LV_DOC_SUBJECT
      i_att_content_hex = i_objbin[] ).
    CATCH cx_document_bcs ."INTO lx_document_bcs.
  ENDTRY.


      CLEAR : w_return.

 ENDLOOP.

 lo_send_request->set_document( lo_document ).
   "Create sender
  lo_sender = cl_sapuser_bcs=>create( sy-uname ).

  "Set sender
  lo_send_request->set_sender( lo_sender ).
  lo_recipient = cl_cam_address_bcs=>create_internet_address('SABA@SARAVANASTORES.NET')."( 'KRITHIKANAVODAYA@GMAIL.COM' ).

*Set recipient
  lo_send_request->add_recipient(
  EXPORTING
  i_recipient = lo_recipient
  i_express = abap_true
  ).

   lo_recipient = cl_cam_address_bcs=>create_internet_address( 'SDP.ASHER@GMAIL.COM' ).

*Set recipient
  lo_send_request->add_recipient(
***********  ADDED ON (31-3-20)
*EXPORTING
*  i_recipient = lo_recipient
*  i_express = abap_true
*  ).
*
*   lo_recipient = cl_cam_address_bcs=>create_internet_address('Chintapalli.Likhitha@ZIETATECH.COM' ).
*
**Set recipient
*  lo_send_request->add_recipient(
***********END(31-3-20)
  EXPORTING
  i_recipient = lo_recipient
  i_express = abap_true
  ).

  lo_send_request->send(
  EXPORTING
  i_with_error_screen = abap_true
  RECEIVING
  result = lv_sent_to_all ).

IF lv_sent_to_all IS NOT INITIAL.
CONCATENATE 'Email sent to' WA_T001W-NAME1 'WISE' INTO data(lv_msg) SEPARATED BY space.
 WRITE:/ lv_msg COLOR COL_POSITIVE.
  SKIP.
ENDIF.
* Commit Work to send the email
  COMMIT WORK.


*w_ctrlop-getotf = 'X'.     " By Suri : 23.09.2019 22:44:00
*w_ctrlop-PREVIEW = 'X'.
*w_ctrlop-no_dialog = 'X'.   " By Suri : 23.09.2019 22:44:00
*w_compop-tdnoprev = 'X'.
*w_compop-tddest = 'LP01'.
