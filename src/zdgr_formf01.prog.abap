*&---------------------------------------------------------------------*
*& Include          ZDGR_FORMF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
  SELECT      CLINT
              KLART
              CLASS
              VONDT
              BISDT
              WWSKZ FROM KLAH INTO TABLE IT_KLAH
              WHERE WWSKZ = '0'
              AND   KLART = '026' .
  IF IT_KLAH IS NOT INITIAL.
      SELECT  OBJEK
              MAFID
              KLART
              CLINT
              ADZHL
              DATUB FROM KSSK INTO TABLE IT_KSSK
              FOR ALL ENTRIES IN IT_KLAH
              WHERE CLINT = IT_KLAH-CLINT.
  ENDIF.

  LOOP AT IT_KSSK INTO WA_KSSK .
    WA_KSSK1-OBJEK1 = WA_KSSK-OBJEK .
    SHIFT WA_KSSK-OBJEK LEFT DELETING LEADING '0'.
    WA_KSSK1-OBJEK = WA_KSSK-OBJEK .
    APPEND WA_KSSK1 TO IT_KSSK1 .
    CLEAR WA_KSSK1 .
  ENDLOOP.

  IF IT_KSSK1 IS NOT INITIAL .
       SELECT CLINT
              KLART
              CLASS
              VONDT
              BISDT
              WWSKZ FROM KLAH INTO TABLE IT_KLAH1
              FOR ALL ENTRIES IN IT_KSSK1
              WHERE CLINT = IT_KSSK1-OBJEK
              AND WWSKZ = '1'.
  ENDIF.
  IF IT_KLAH1 IS NOT INITIAL .
       SELECT MATNR
              MATKL FROM MARA INTO TABLE IT_MARA
              FOR ALL ENTRIES IN IT_KLAH1
              WHERE MATKL = IT_KLAH1-CLASS.
  ENDIF.
  IF IT_MARA IS NOT  INITIAL .
******************     COMMENTED ON (4-1-20)        **********************************
***********    SELECT zinw_t_item~qr_code  ,
***********           zinw_t_item~ebeln ,
***********           zinw_t_item~ebelp ,
***********           zinw_t_item~matnr ,
***********           zinw_t_item~werks ,
***********           zinw_t_item~menge ,
***********           zinw_t_item~netwr_p,      " ADDED (11-2-20)
***********           zinw_t_item~netpr_gp,      " ADDED (11-2-20)
***********           zinw_t_hdr~inwd_doc  ,
***********           zinw_t_hdr~mblnr  ,
***********           zinw_t_hdr~lifnr     ,
***********           zinw_t_hdr~bill_date ,
***********           zinw_t_hdr~pur_total ,
***********           zinw_t_hdr~pur_tax ,
***********           zinw_t_hdr~net_amt ,
***********           zinw_t_hdr~erdate    ,
***********           zinw_t_hdr~act_no_bud ,
***********           lfa1~name1 ,
***********           mkpf~bldat
***********           FROM zinw_t_item AS zinw_t_item
***********           LEFT OUTER JOIN zinw_t_hdr AS zinw_t_hdr ON zinw_t_hdr~qr_code =  zinw_t_item~qr_code
***********           LEFT OUTER JOIN lfa1 AS lfa1 ON lfa1~lifnr = zinw_t_hdr~lifnr
***********           LEFT OUTER JOIN mkpf AS mkpf ON mkpf~mblnr  = zinw_t_hdr~mblnr
***********
***********           INTO TABLE @DATA(it_zinw)
***********           FOR ALL ENTRIES IN @it_mara
***********           WHERE  zinw_t_item~matnr = @it_mara-matnr
***********           AND  zinw_t_item~werks IN @s_plant
***********           AND  zinw_t_hdr~erdate  IN @s_date
***********           AND  zinw_t_hdr~status GE '04' .
*************************           END (4-1-20)     ****************************
*******************    added on (4-1-20)  ********************
    SELECT "ZINW_T_STATUS~QR_CODE,
          ZINW_T_STATUS~QR_CODE,          " added on (4-1-20)
           ZINW_T_STATUS~STATUS_VALUE,      " added on (4-1-20)
           ZINW_T_STATUS~CREATED_DATE,      " added on (4-1-20)
           ZINW_T_ITEM~EBELN ,
           ZINW_T_ITEM~EBELP ,
           ZINW_T_ITEM~MATNR ,
           ZINW_T_ITEM~WERKS ,
           ZINW_T_ITEM~MENGE_P ,
           ZINW_T_ITEM~NETWR_P,      " ADDED (11-2-20)
           ZINW_T_ITEM~NETPR_GP,      " ADDED (11-2-20)
           ZINW_T_HDR~INWD_DOC  ,
           ZINW_T_HDR~MBLNR  ,
           ZINW_T_HDR~LIFNR     ,
           ZINW_T_HDR~BILL_DATE ,
           ZINW_T_HDR~PUR_TOTAL ,
           ZINW_T_HDR~PUR_TAX ,
           ZINW_T_HDR~NET_AMT ,
           ZINW_T_HDR~ERDATE    ,
           ZINW_T_HDR~ACT_NO_BUD ,
           LFA1~NAME1 ,
           MKPF~BLDAT
          FROM ZINW_T_STATUS AS ZINW_T_STATUS
           LEFT OUTER JOIN ZINW_T_ITEM AS ZINW_T_ITEM ON ZINW_T_ITEM~QR_CODE =  ZINW_T_STATUS~QR_CODE
           LEFT OUTER JOIN ZINW_T_HDR AS ZINW_T_HDR ON ZINW_T_HDR~QR_CODE =  ZINW_T_STATUS~QR_CODE
           LEFT OUTER JOIN LFA1 AS LFA1 ON LFA1~LIFNR = ZINW_T_HDR~LIFNR
           LEFT OUTER JOIN MKPF AS MKPF ON MKPF~MBLNR  = ZINW_T_HDR~MBLNR
           INTO TABLE @DATA(IT_ZINW)
           FOR ALL ENTRIES IN @IT_MARA
           WHERE  ZINW_T_STATUS~STATUS_VALUE = 'QR04'
           AND ZINW_T_ITEM~MATNR = @IT_MARA-MATNR
           AND  ZINW_T_ITEM~WERKS IN @S_PLANT
           AND  ZINW_T_STATUS~CREATED_DATE  IN @S_DATE.
*******************    end(4-1-20)   *********************
  ENDIF.
  SORT IT_ZINW  ASCENDING BY  MBLNR .
  IT_KLAHA[] = IT_KLAH[] .
  DATA(IT_ZINW1) = IT_ZINW[] .
  DATA(IT_ZINW2) = IT_ZINW[] .  " added on (4-1-20)
  SORT IT_ZINW1 BY MBLNR .
  DELETE ADJACENT DUPLICATES FROM IT_ZINW1 COMPARING MBLNR .
  DELETE ADJACENT DUPLICATES FROM IT_ZINW COMPARING MBLNR .
******************  ADDDED ON  (29-3-20)  **********
*  *****************  ADDED ON (28-3-20)  ****
  IF S_PLANT IS NOT INITIAL.
*  READ TABLE IT_ZINW ASSIGNING FIELD-SYMBOL(<lv_inw>) with KEY  werks = <lv_inw>-werks.
    SELECT WERKS
           ADRNR
           NAME1
    FROM  T001W
    INTO TABLE IT_T001W
    WHERE WERKS IN S_PLANT."('SSCP' ,'SSPO','SSPU','SSTN','SSWH' ,'SSVG').
  ENDIF.

  IF S_PLANT  IS INITIAL.
    SELECT WERKS
          ADRNR
          NAME1
   FROM  T001W
   INTO TABLE IT_T001W
   WHERE WERKS IN ('SSCP' ,'SSPO','SSPU','SSTN','SSWH' ,'SSVG').
  ELSE.
    SELECT WERKS
          ADRNR
          NAME1
   FROM  T001W
   INTO TABLE IT_T001W
   WHERE WERKS IN S_PLANT .
  ENDIF.
  SELECT A~ADDRNUMBER
           A~NAME1
           A~NAME2
           A~STREET
           A~STR_SUPPL1
           A~CITY1
           A~POST_CODE1
           B~BEZEI
    FROM   ADRC AS A
    INNER JOIN T005U AS B ON ( A~REGION = B~BLAND AND B~SPRAS = SY-LANGU AND A~COUNTRY = B~LAND1 )
    INTO TABLE IT_ADRC
    FOR ALL ENTRIES IN IT_T001W
    WHERE ADDRNUMBER = IT_T001W-ADRNR .
**************  END (28-3-20)  ************
*****************added on (30-3-20)cc*********************
  BREAK CLIKHITHA.
  LOOP AT IT_T001W INTO W_T001W.
    REFRESH : IT_FINAL,IT_FINAL1.
******************* end(30-3-20)  **************
    LOOP AT IT_ZINW ASSIGNING FIELD-SYMBOL(<WA_ZINW>) WHERE WERKS = W_T001W-WERKS.
      WA_FINAL-NAME   =        W_T001W-NAME1.
      WA_FINAL-GRPO_V   =  <WA_ZINW>-PUR_TOTAL .
      WA_FINAL-GRPO_WT  =  <WA_ZINW>-NET_AMT .         " COMMENTED ON (14-2-20)
      WA_FINAL-BUNDLE   =  <WA_ZINW>-ACT_NO_BUD .
*      wa_final-qty      =  <wa_zinw>-menge .
      WA_FINAL1-GRPO_V   =  <WA_ZINW>-NETWR_P.
      WA_FINAL1-QR_CODE  =  <WA_ZINW>-QR_CODE .
      WA_FINAL1-GRPO_WT =  <WA_ZINW>-NET_AMT .
      WA_FINAL1-BUNDLE  =  <WA_ZINW>-ACT_NO_BUD .
*      wa_final1-qty     =  <wa_zinw>-menge .
      WA_FINAL1-LIFNR   =  <WA_ZINW>-LIFNR .
      WA_FINAL1-GRPO    =  <WA_ZINW>-MBLNR .
      WA_FINAL1-NAME1   =  <WA_ZINW>-NAME1 .
      WA_FINAL1-WERKS   =  <WA_ZINW>-WERKS .
      WA_FINAL1-BLDAT   =  <WA_ZINW>-BLDAT.
      WA_FINAL1-MATNR   =  <WA_ZINW>-MATNR.

      CLEAR : WA_MARA , WA_KLAH1 , WA_KLAH , WA_KSSK1 , WA_KSSK .
      READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR   = <WA_ZINW>-MATNR .
      READ TABLE IT_KLAH1 INTO WA_KLAH1 WITH KEY CLASS = WA_MARA-MATKL .
      READ TABLE IT_KSSK1 INTO WA_KSSK1 WITH KEY OBJEK = WA_KLAH1-CLINT .
      READ TABLE IT_KSSK INTO WA_KSSK WITH KEY OBJEK   = WA_KSSK1-OBJEK1 .
      READ TABLE IT_KLAH INTO WA_KLAH WITH KEY CLINT   = WA_KSSK-CLINT .
*      **************    ADDED ON (31-3-20)
      LOOP AT IT_ZINW2 ASSIGNING FIELD-SYMBOL(<WA_ZINW3>) WHERE MBLNR = <WA_ZINW>-MBLNR .
        IF SY-SUBRC = 0.

          WA_FINAL-QTY = WA_FINAL-QTY + <WA_ZINW3>-MENGE_P.
          WA_FINAL1-QTY = WA_FINAL1-QTY + <WA_ZINW3>-MENGE_P.
        ENDIF.
      ENDLOOP.
*******************        END (31-3-20)

      IF SY-SUBRC = 0.
        DELETE IT_KLAHA WHERE CLINT = WA_KLAH-CLINT .
        WA_FINAL-CATEGORY  = WA_KLAH-CLASS .
        WA_FINAL1-CATEGORY = WA_KLAH-CLASS .
      ENDIF.
      READ TABLE IT_FINAL1 ASSIGNING FIELD-SYMBOL(<WA_FINAL>) WITH KEY  GRPO =   <WA_ZINW>-MBLNR .
      IF SY-SUBRC <> 0 .
        WA_FINAL-GRPO_N = 1 .
*      WA_MAIN-GRPO_N = WA_FINAL-GRPO_N.
      ENDIF.

      COLLECT WA_FINAL INTO IT_FINAL .
      CLEAR WA_FINAL .
      APPEND WA_FINAL1 TO IT_FINAL1 .
      CLEAR WA_FINAL1 .
    ENDLOOP.

    LOOP AT  IT_KLAHA ASSIGNING FIELD-SYMBOL(<WA_KLAHA>) .
      WA_FINAL-CATEGORY = <WA_KLAHA>-CLASS .
      APPEND WA_FINAL TO IT_FINAL .
      CLEAR WA_FINAL .
*      PERFORM DISPLAY.
    ENDLOOP.
    SORT IT_FINAL BY CATEGORY.
*  PERFORM DISPLAY.

*  ENDLOOP.
*  PERFORM DISPLAY.
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM DISPLAY .

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        FORMNAME           = 'ZGRPO_REPORT'
*       VARIANT            = ' '
*       DIRECT_CALL        = ' '
      IMPORTING
        FM_NAME            = F_NAME
      EXCEPTIONS
        NO_FORM            = 1
        NO_FUNCTION_MODULE = 2
        OTHERS             = 3.
    .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

******************ADDED ON (28-3-20) FOR MAIL   **********

*loop at IT_T001W INTO WA_T001W." WHERE werks in ( 'SSCP' ,'SSPO','SSPU','SSTN','SSWH' ,'SSVG' )..
*loop at it_final INTO wa_final
    PLANT = W_T001W-NAME1.
    READ TABLE IT_ADRC INTO WA_ADRC WITH KEY ADDRNUMBER = WA_T001W-ADRNR  .
    IF SY-SUBRC = 0.
      MOVE WA_ADRC-ADDRNUMBER    TO WA_ADR-ADDRNUMBER.
      MOVE WA_ADRC-NAME1         TO WA_ADR-NAME1     .
      MOVE WA_T001W-WERKS        TO WA_ADR-WERKS     .
    ENDIF.
    W_CTRLOP-GETOTF = 'X'.
*w_ctrlop-PREVIEW = 'X'.
    W_CTRLOP-NO_DIALOG = 'X'.
*w_compop-tdnoprev = 'X'.
    W_COMPOP-TDDEST = 'LP01'.
****************END (28-3-20)  ***********
    L_DATE = S_DATE-LOW.
****
    CALL FUNCTION F_NAME "'/1BCDWB/SF00000066'
*******************ADDED ON (28-3-20)
      EXPORTING
        CONTROL_PARAMETERS = W_CTRLOP
        OUTPUT_OPTIONS     = W_COMPOP
        USER_SETTINGS      = 'X'
        LV_PLANT           = PLANT
        LV_DATE            = L_DATE
      IMPORTING
        JOB_OUTPUT_INFO    = W_RETURN
********************END(28-3-20)
      TABLES
        IT_ITEM            = IT_FINAL
      EXCEPTIONS
        FORMATTING_ERROR   = 1
        INTERNAL_ERROR     = 2
        SEND_ERROR         = 3
        USER_CANCELED      = 4
        OTHERS             = 5.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
*ENDLOOP.
*ENDFORM..


*ENDFORM.

*BREAK CLIKHITHA.
*********************ADDED ON (28-3-20)  ****************
    CLEAR : L_DATE , PLANT .
    REFRESH : I_OTF[],
             I_OBJBIN[].
    I_OTF[] = W_RETURN-OTFDATA[].
    CALL FUNCTION 'CONVERT_OTF'
      EXPORTING
        FORMAT                = 'PDF'
        MAX_LINEWIDTH         = 132
*       ARCHIVE_INDEX         = ' '
*       COPYNUMBER            = 0
*       ASCII_BIDI_VIS2LOG    = ' '
*       PDF_DELETE_OTFTAB     = ' '
*       PDF_USERNAME          = ' '
*       PDF_PREVIEW           = ' '
*       USE_CASCADING         = ' '
*       MODIFIED_PARAM_TABLE  =
      IMPORTING
        BIN_FILESIZE          = V_LEN_IN
        BIN_FILE              = I_XSTRING   " This is NOT Binary. This is Hexa
      TABLES
        OTF                   = I_OTF
        LINES                 = I_TLINE
      EXCEPTIONS
        ERR_MAX_LINEWIDTH     = 1
        ERR_FORMAT            = 2
        ERR_CONV_NOT_POSSIBLE = 3
        ERR_BAD_OTF           = 4
        OTHERS                = 5.
*IF SY-SUBRC <> 0.
** Implement suitable error handling here
*ENDIF.
*ENDFORM.
*********************END (28-3-20)  *************
*
    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        BUFFER     = I_XSTRING
*       APPEND_TO_TABLE       = ' '
* IMPORTING
*       OUTPUT_LENGTH         =
      TABLES
        BINARY_TAB = I_OBJBIN[].

    REFRESH LT_MESSAGE_BODY.
    "create send request
    LO_SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).

    "create message body and subject
    SALUTATION ='Dear Sir/Madam,'.
    APPEND SALUTATION TO LT_MESSAGE_BODY.
    APPEND INITIAL LINE TO LT_MESSAGE_BODY.

    BODY = 'Please find the attachment of plant wise EOD GRPO in PDF format.'.
    APPEND BODY TO LT_MESSAGE_BODY.
    APPEND INITIAL LINE TO LT_MESSAGE_BODY.

    FOOTER = 'With Regards,'.
    APPEND FOOTER TO LT_MESSAGE_BODY.
    FOOTER = 'ZIETA'.
    APPEND FOOTER TO LT_MESSAGE_BODY.
    "put your text into the document

    CONCATENATE W_T001W-NAME1 'EODGRPO' '.pdf' INTO LV_DOC_SUBJECT.
    IF LO_DOCUMENT IS INITIAL.
      LO_DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
       I_TYPE = 'RAW'
       I_TEXT = LT_MESSAGE_BODY
       I_SUBJECT = 'PLANTWISE_EOD_GRPO' ).
    ENDIF.
    TRY.
        LO_DOCUMENT->ADD_ATTACHMENT(
        EXPORTING
        I_ATTACHMENT_TYPE = 'PDF'
        I_ATTACHMENT_SUBJECT = LV_DOC_SUBJECT
        I_ATT_CONTENT_HEX = I_OBJBIN[] ).
      CATCH CX_DOCUMENT_BCS ."INTO lx_document_bcs.
    ENDTRY.


    CLEAR : W_RETURN.
*ENDFORM.
  ENDLOOP.
* endloop.
*
  LO_SEND_REQUEST->SET_DOCUMENT( LO_DOCUMENT ).
  "Create sender
  LO_SENDER = CL_SAPUSER_BCS=>CREATE( SY-UNAME ).

  "Set sender
  LO_SEND_REQUEST->SET_SENDER( LO_SENDER ).
  lo_recipient = cl_cam_address_bcs=>create_internet_address('SABA@SARAVANASTORES.NET')."( 'KRITHIKANAVODAYA@GMAIL.COM' ).

*Set recipient
  LO_SEND_REQUEST->ADD_RECIPIENT(
  EXPORTING
  I_RECIPIENT = LO_RECIPIENT
  I_EXPRESS = ABAP_TRUE
  ).

  LO_RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS('SDP.ASHER@GMAIL.COM').

*Set recipient
  LO_SEND_REQUEST->ADD_RECIPIENT(
*  ***********  ADDED ON (1-4-20)
*EXPORTING
*  i_recipient = lo_recipient
*  i_express = abap_true
*  ).
*
*   lo_recipient = cl_cam_address_bcs=>create_internet_address('Chintapalli.Likhitha@ZIETATECH.COM' ).
*
**Set recipient
*  lo_send_request->add_recipient(
***********END(1-4-20)
  EXPORTING
  I_RECIPIENT = LO_RECIPIENT
  I_EXPRESS = ABAP_TRUE
  ).

  LO_SEND_REQUEST->SEND(
  EXPORTING
  I_WITH_ERROR_SCREEN = ABAP_TRUE
  RECEIVING
  RESULT = LV_SENT_TO_ALL ).

  IF LV_SENT_TO_ALL IS NOT INITIAL.
    CONCATENATE 'Email sent to' WA_T001W-NAME1 'WISE' INTO DATA(LV_MSG) SEPARATED BY SPACE.
    WRITE:/ LV_MSG COLOR COL_POSITIVE.
    SKIP.
  ENDIF.
* Commit Work to send the email
  COMMIT WORK.
  .
ENDFORM.
