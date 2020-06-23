*&---------------------------------------------------------------------*
*& Report ZSST_MM_F_032_GRP_PO_DR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSST_MM_F_032_GRP_PO_DR.

TYPES : BEGIN OF TY_T024,
          EKGRP TYPE T024-EKGRP,
          EKNAM TYPE T024-EKNAM,
        END OF TY_T024,

        BEGIN OF TY_EK,
          EBELN TYPE EKKO-EBELN,
          AEDAT TYPE EKKO-AEDAT,
          EKGRP TYPE EKKO-EKGRP,
          LIFNR TYPE EKKO-LIFNR,
          BSART TYPE EKKO-BSART,
        END OF TY_EK,

         BEGIN OF TY_EKKO,
          EBELN TYPE EKKO-EBELN,
          AEDAT TYPE EKKO-AEDAT,
          EKGRP TYPE EKKO-EKGRP,
          LIFNR TYPE EKKO-LIFNR,
          BSART TYPE EKKO-BSART,
          EBELP TYPE EKPO-EBELP,
          RETPO TYPE EKPO-RETPO,
          NETWR TYPE EKPO-NETWR,
          MENGE TYPE EKPO-MENGE,
        END OF TY_EKKO,

         BEGIN OF TY_LFA1,
          LIFNR TYPE LFA1-LIFNR,
          NAME1 TYPE LFA1-NAME1,
          ORT01 TYPE LFA1-ORT01,
        END OF TY_LFA1,

        BEGIN OF TY_EMAIL,
          MAIL TYPE ADR6-SMTP_ADDR,
          GROUP TYPE T024-EKNAM,
        END OF TY_EMAIL,

          BEGIN OF TY_EMAIL1,
          MAIL TYPE ADR6-SMTP_ADDR,
*          GROUP TYPE T024-EKNAM,
        END OF TY_EMAIL1,

        BEGIN OF TY_SEL,
          SIGN   TYPE CHAR1,
          OPTION TYPE CHAR2,
          LOW    TYPE ERDAT,
          HIGH   TYPE ERDAT,
        END OF TY_SEL,


        BEGIN OF TY_SLT,
          SR_NO   TYPE INT4      ,
          VEN_NO  TYPE LFA1-LIFNR,
          DESC    TYPE LFA1-NAME1,
          LOC     TYPE LFA1-ORT01,
          EBELN   TYPE EKKO-EBELN,
          MENGE   TYPE EKPO-MENGE,
          NETWR   TYPE EKPO-NETWR,
        END OF TY_SLT.

DATA  : IT_T024 TYPE TABLE OF TY_T024,
        IT_F4HP TYPE TABLE OF TY_T024,
        IT_EKKO TYPE TABLE OF TY_EKKO,
        IT_LFA1 TYPE TABLE OF TY_LFA1,
        IT_EK   TYPE TABLE OF TY_EK,
        IT_SLT    TYPE TABLE OF ZGRP_PO_STR         ,
        IT_EMAIL TYPE TABLE OF TY_EMAIL,
        IT_EMAIL1 TYPE TABLE OF TY_EMAIL1,
        IT_FINAL  TYPE TABLE OF ZSST_MM_F_032_STCT  .

DATA  : WA_T024 TYPE TY_T024,
        WA_EKKO TYPE TY_EKKO,
        WA_LFA1 TYPE TY_LFA1,
        WA_EK   TYPE TY_EK,
        WA_SLT    TYPE ZGRP_PO_STR      ,
        WA_EMAIL TYPE TY_EMAIL,
        WA_EMAIL1 TYPE TY_EMAIL1,
        WA_DATE TYPE TY_SEL,
         w_cn2 TYPE i,
         w_cn TYPE i,
         DATE TYPE EKKO-AEDAT,
        WA_FINAL  TYPE ZSST_MM_F_032_STCT.


DATA  : SR_NO       TYPE INT4,
        COUNT       TYPE INT4,
        TOT_QTY     TYPE EKPO-MENGE,
        TOT_PO      TYPE INT4,
        TOT_NTWR    TYPE EKPO-NETWR,
        LV_LIFNR    TYPE EKKO-LIFNR,
        LV_FIELD    TYPE CHAR20.

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

data: lv_timestamp type timestamp.

GET TIME STAMP FIELD lv_timestamp.

DATA  : GV_DATE TYPE EKKO-AEDAT.

DATA  : FM_NAME1  TYPE RS38l_FNAM .

PARAMETERS : P_GRP  TYPE T024-EKNAM.

SELECTION-SCREEN : BEGIN OF  BLOCK B1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : S_DATE FOR GV_DATE.
SELECTION-SCREEN : END   OF  BLOCK B1.
*             P_DATE TYPE EKKO-AEDAT.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_GRP.
SELECT EKGRP
       EKNAM
FROM   T024
INTO TABLE IT_F4HP.

CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
  EXPORTING
*   DDIC_STRUCTURE         = ' '
    RETFIELD               = 'EKNAM'
*   PVALKEY                = ' '
    DYNPPROG               = SY-REPID
    DYNPNR                 = SY-DYNNR
    DYNPROFIELD            = 'P_DATE'
*   STEPL                  = 0
*   WINDOW_TITLE           =
*   VALUE                  = ' '
    VALUE_ORG              = 'S'
*   MULTIPLE_CHOICE        = ' '
*   DISPLAY                = ' '
*   CALLBACK_PROGRAM       = ' '
*   CALLBACK_FORM          = ' '
*   CALLBACK_METHOD        =
*   MARK_TAB               =
* IMPORTING
*   USER_RESET             =
  TABLES
    VALUE_TAB              = IT_F4HP
*   FIELD_TAB              =
*   RETURN_TAB             =
*   DYNPFLD_MAPPING        =
 EXCEPTIONS
   PARAMETER_ERROR        = 1
   NO_VALUES_FOUND        = 2
   OTHERS                 = 3
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.



START-OF-SELECTION.

 IF  S_DATE[] IS INITIAL.
     APPEND VALUE #( LOW = SY-DATUM OPTION = 'EQ' SIGN = 'I' ) to S_DATE[].
  ENDIF.
  READ TABLE S_DATE INTO WA_DATE .
DATE = WA_DATE-LOW.
SELECT EBELN
       AEDAT
       EKGRP
       LIFNR
       BSART
FROM EKKO
INTO TABLE IT_EK
WHERE AEDAT IN S_DATE AND BSART IN ('ZLOP','ZOSP','ZTAT','ZVLO','ZOSP').

  IF IT_EK IS NOT INITIAL.

SELECT A~EBELN
       A~AEDAT
       A~EKGRP
       A~LIFNR
       A~BSART
       B~EBELP
       B~RETPO
       B~NETWR
       B~MENGE
FROM   EKKO AS A INNER JOIN EKPO AS B ON ( A~EBELN EQ B~EBELN AND B~RETPO NE 'X' )
INTO TABLE IT_EKKO
FOR ALL ENTRIES IN IT_EK
WHERE A~EBELN EQ IT_EK-EBELN.
 ENDIF.

SELECT LIFNR
       NAME1
       ORT01
FROM   LFA1
INTO TABLE IT_LFA1
FOR ALL ENTRIES IN IT_EKKO
WHERE LIFNR EQ IT_EKKO-LIFNR.

SELECT EKGRP
       EKNAM
FROM   T024
INTO TABLE IT_T024
  WHERE EKGRP NE '001' AND
      EKGRP NE '002' AND
      EKGRP NE '003'.

LOOP AT IT_T024 INTO WA_T024.
  SR_NO          = SR_NO + 1 .
  WA_FINAL-SR_NO = SR_NO .

 LOOP AT IT_EKKO INTO WA_EKKO WHERE EKGRP = WA_T024-EKGRP.

   WA_FINAL-OR_QTY = WA_FINAL-OR_QTY + WA_EKKO-MENGE.
   WA_FINAL-NTWR   = WA_FINAL-NTWR + WA_EKKO-NETWR.

 ENDLOOP.

 LOOP AT IT_EK INTO WA_EK WHERE EKGRP = WA_T024-EKGRP.
    WA_FINAL-NO_PO  = WA_FINAL-NO_PO + 1.
 ENDLOOP.

   MOVE WA_T024-EKNAM TO WA_FINAL-GROUP.

* TOT_QTY  = TOT_QTY  + WA_FINAL-OR_QTY.
* TOT_NTWR = TOT_NTWR + WA_FINAL-NTWR.
* TOT_PO   = TOT_PO   + WA_FINAL-NO_PO.

 MOVE WA_T024-EKGRP TO WA_FINAL-EKGRP.
 APPEND WA_FINAL TO IT_FINAL.
 CLEAR : WA_FINAL.

ENDLOOP.
CLEAR SR_NO.
*READ TABLE IT_T024 INTO WA_T024 WITH KEY EKNAM = P_GRP.
*IF SY-SUBRC = 0.

*  WA_EMAIL-MAIL = 'SABA@SARAVANASTORES.NET'.
*APPEND WA_EMAIL TO IT_EMAIL.
*
*WA_EMAIL-MAIL = 'SDP.ASHER@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.

*WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.
*WA_EMAIL-MAIL = 'sankardurai2009@gmail.com'.
*WA_EMAIL-GROUP = 'SAREES'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.
*WA_EMAIL-MAIL = 'Prakash.arikrish@gmail.com'.
*WA_EMAIL-GROUP = 'TOYS'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.
*WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.
*WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.
*WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.
*WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.
*WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.
*WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.
*WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.
*WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.
*WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.
*CLEAR WA_EMAIL.


WA_EMAIL-GROUP = 'SAREES'.
WA_EMAIL-MAIL = 'sankardurai2009@gmail.com'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'INNER WARE'.
WA_EMAIL-MAIL = 'pkannan@saravanastores.net'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'LADYS READYMADE'.
WA_EMAIL-MAIL = 'murugan@saravanastores.net'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'GENTS READYMADE'.
WA_EMAIL-MAIL = 'kmannanmaha@gmail.com'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'GIRLS READYMADE'.
WA_EMAIL-MAIL = 'chermananu1982@gmail.com'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'BOYS READYMADE'.
WA_EMAIL-MAIL = 'thangaduraivo8@gmail.com'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'WATHCES'.
WA_EMAIL-MAIL = 'elect@saravanastores.net'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'ELECTRONICS'.
WA_EMAIL-MAIL = 'elect@saravanastores.net'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'MOBILES'.
WA_EMAIL-MAIL = 'elect@saravanastores.net'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'CONSUMABLES'.
WA_EMAIL-MAIL = 'Augustin@saravanastores.net'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'IMITATION'.
WA_EMAIL-MAIL = 'sudar@saravanastores.net'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'COSMETICS'.
WA_EMAIL-MAIL = 'sudar@saravanastores.net'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'GIFTS&FLOWERS'.
WA_EMAIL-MAIL = 'Prakash.arikrish@gmail.com'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'RIDE ON'.
WA_EMAIL-MAIL = 'pkannan@saravanastores.net'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'JUST BORN'.
WA_EMAIL-MAIL = 'sankardurai2009@gmail.com'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'SMALL APPLIANCES'.
WA_EMAIL-MAIL = 'jaichandran@saravanastores.net'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'TOYS'.
WA_EMAIL-MAIL = 'Prakash.arikrish@gmail.com'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'BIG APPLIANCES'.
WA_EMAIL-MAIL = 'jaichandran@saravanastores.net'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

WA_EMAIL-GROUP = 'FURNITURE'.
WA_EMAIL-MAIL = 'jaichandran@saravanastores.net'.
APPEND WA_EMAIL TO IT_EMAIL.
CLEAR: WA_EMAIL.

*
*WA_EMAIL-MAIL = 'SABA@SARAVANASTORES.NET'.
*APPEND WA_EMAIL TO IT_EMAIL.
*
*WA_EMAIL-MAIL = 'SDP.ASHER@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.*
*WA_EMAIL-MAIL = 'KRITHIKANAVODAYA@GMAIL.COM'.
*APPEND WA_EMAIL TO IT_EMAIL.



CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    FORMNAME                 = 'ZSST_MM_F_032_GRPPO_SF'
*   VARIANT                  = ' '
*   DIRECT_CALL              = ' '
 IMPORTING
    FM_NAME                  = FM_NAME1
* EXCEPTIONS
*   NO_FORM                  = 1
*   NO_FUNCTION_MODULE       = 2
*   OTHERS                   = 3
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

DESCRIBE TABLE IT_T024 lines w_cn.
  LOOP AT IT_T024 INTO WA_T024 .
    REFRESH IT_SLT.
    CLEAR SR_NO.
LOOP AT IT_EK INTO WA_EK WHERE EKGRP = WA_T024-EKGRP.

      SR_NO        = SR_NO + 1 .
      WA_SLT-SR_NO = SR_NO .
      MOVE WA_EK-EBELN TO WA_SLT-EBELN.
      MOVE WA_EK-LIFNR TO WA_SLT-VEN_NO.
      READ TABLE IT_LFA1 INTO WA_LFA1 WITH KEY LIFNR = WA_EK-LIFNR.
      IF SY-SUBRC = 0.
         MOVE WA_LFA1-NAME1 TO WA_SLT-DESC.
         MOVE WA_LFA1-ORT01 TO WA_SLT-LOC.
      ENDIF.
      LOOP AT IT_EKKO INTO WA_EKKO WHERE EBELN = WA_EK-EBELN AND EKGRP = WA_EK-EKGRP.
        WA_SLT-MENGE = WA_SLT-MENGE + WA_EKKO-MENGE .
        WA_SLT-NETWR = WA_SLT-NETWR + WA_EKKO-NETWR.
      ENDLOOP.
      TOT_QTY  = TOT_QTY + WA_SLT-MENGE .
      TOT_NTWR = TOT_NTWR + WA_SLT-NETWR.
      APPEND WA_SLT TO IT_SLT.
      CLEAR : WA_SLT,
              WA_EKKO.
    ENDLOOP.
*  ENDIF.


*w_ctrlop-getotf = 'X'.
*w_ctrlop-PREVIEW = 'X'.
*w_ctrlop-no_dialog = 'X'.
*w_compop-tdnoprev = 'X'.
*w_compop-tddest = 'LP01'.

  w_cn2 = sy-tabix.
  case w_cn2.
    WHEN 1.
      w_ctrlop-no_open = space.
      w_ctrlop-no_close = 'X'.
    WHEN w_cn.
      w_ctrlop-no_open = 'X'.
      w_ctrlop-no_close = space.
    WHEN others.
      w_ctrlop-no_open = 'X'.
      w_ctrlop-no_close = 'X'.
    ENDCASE.

 CALL FUNCTION FM_NAME1
    EXPORTING
    control_parameters = w_ctrlop
    output_options     = w_compop
    user_settings      = 'X'
    LV_QTY             = TOT_QTY
    LV_NTR             = TOT_NTWR
    LV_GRP             = WA_T024-EKNAM
    LV_DATE            = DATE
*    LV_PO              = TOT_PO
*    LV_DATE            = P_DATE
*    WA_ADRC            = WA_ADR
    IMPORTING
    job_output_info    = w_return
    TABLES
    IT_EOD             = IT_SLT
*    ITAB_SELECT        = S_DATE[]
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
CLEAR : WA_T024,
        TOT_QTY,
        TOT_NTWR.
    "Get Output Text Format (OTF)
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



*LOOP AT IT_EMAIL INTO WA_EMAIL WHERE GROUP EQ WA_T024-EKNAM .



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
  i_subject = 'EOD GROUP in PDF' ).

  TRY.
      lo_document->add_attachment(
      EXPORTING
      i_attachment_type = 'PDF'
      i_attachment_subject = 'EOD GROUP'
      i_att_content_hex = i_objbin[] ).
    CATCH cx_document_bcs INTO lx_document_bcs.
  ENDTRY.

* Add attachment
* Pass the document to send request
IF I_OTF IS NOT INITIAL .
  IF IT_SLT IS NOT INITIAL.

  lo_send_request->set_document( lo_document ).

  "Create sender
  lo_sender = cl_sapuser_bcs=>create( sy-uname ).

  "Set sender
  lo_send_request->set_sender( lo_sender ).
  IF IT_EMAIL IS NOT INITIAL.
  IN_MAILID = WA_EMAIL-MAIL.
  "Create recipient
  lo_recipient = cl_cam_address_bcs=>create_internet_address( IN_MAILID ).

*Set recipient
  lo_send_request->add_recipient(
  EXPORTING
  i_recipient = lo_recipient
  i_express = abap_true
  ).
endif.
*    lo_send_request->add_recipient( lo_recipient ).
*     lo_recipient = cl_cam_address_bcs=>create_internet_address( 'SABA@SARAVANASTORES.NET').
*
**Set recipient
*  lo_send_request->add_recipient(
*  EXPORTING
*  i_recipient = lo_recipient
*  i_express = abap_true
*  ).
**
**    lo_send_request->add_recipient( lo_recipient ).
*     lo_recipient = cl_cam_address_bcs=>create_internet_address( 'SDP.ASHER@GMAIL.COM' ).
*
**  RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'suri.amburi@zietatech.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
**          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
**          CLEAR I_ADDRESS_STRING.
*
**Set recipient
*  lo_send_request->add_recipient(
*  EXPORTING
*  i_recipient = lo_recipient
*  i_express = abap_true
*  ).
**
*    lo_send_request->add_recipient( lo_recipient ).
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

  ENDIF.

CLEAR IN_MAILID.

CONCATENATE 'Email sent to' 'KRITHIKA' INTO data(lv_msg) SEPARATED BY space.
 WRITE:/ lv_msg COLOR COL_POSITIVE.
  SKIP.
* Commit Work to send the email
  COMMIT WORK.
ENDIF.
*endloop.

   ENDLOOP.
