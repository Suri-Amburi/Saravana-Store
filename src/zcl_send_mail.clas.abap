class ZCL_SEND_MAIL definition
  public
  final
  create public .

public section.

  class-methods SERVICE_PO
    importing
      !I_EBELN type EBELN
      !PRINT type CHAR1 optional .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SEND_MAIL IMPLEMENTATION.


  METHOD service_po.
*** Mail For Service PO
*** SERVICE ORDER EMAIL .
*    DATA: T_CONTROL       TYPE SSFCTRLOP,
*          T_CONTROL1      TYPE SSFCTRLOP,
*          T_SSFCOMPOP     TYPE SSFCOMPOP,
*          T_SSFCOMPOP1    TYPE SSFCOMPOP,
*          FNAM            TYPE TDSFNAME, "RS38L_FNAM.
*          JOB_OUTPUT_INFO TYPE SSFCRESCL,
*          I_OTF           TYPE TABLE OF ITCOO,
*          I_TLINE         TYPE TABLE OF TLINE,
*          I_RECEIVERS     TYPE TABLE OF SOMLRECI1,
*          I_RECORD        TYPE TABLE OF SOLISTI1,
** Objects to send mail.
*          I_OBJPACK       TYPE TABLE OF SOPCKLSTI1,
*          I_OBJTXT        TYPE TABLE OF SOLISTI1,
*          IS_OBJTXT       TYPE SOLISTI1,
*          I_OBJBIN        TYPE TABLE OF SOLISTI1,
*          I_RECLIST       TYPE TABLE OF SOMLRECI1,
** Work Area declarations
*          WA_OBJHEAD      TYPE SOLI_TAB,
*          W_CTRLOP        TYPE SSFCTRLOP,
*          W_COMPOP        TYPE SSFCOMPOP,
*          W_RETURN        TYPE SSFCRESCL,
*          WA_DOC_CHNG     TYPE SODOCCHGI1,
*          W_DATA          TYPE SODOCCHGI1,
*          WA_BUFFER       TYPE STRING, "To convert from 132 to 255
*
**** Variables declarations
*          V_FORM_NAME     TYPE RS38L_FNAM,
*          V_LEN_IN        TYPE SOOD-OBJLEN,
*          V_LEN_OUT       TYPE SOOD-OBJLEN,
*          V_LEN_OUTN      TYPE I,
*          V_LINES_TXT     TYPE I,
*          V_LINES_BIN     TYPE I.
*
*    DATA : LV_VBELN     TYPE  LIKP-VBELN,
*           E_EMAIL      TYPE  AD_SMTPADR,
*           RECEIVER     TYPE  SO_RECNAME,
*           IS_USER_DATA TYPE  QISRSUSER_DATA,
*           LV_TEXT      TYPE SO_TEXT255.
*
*    DATA: FIELDCATALOG TYPE TABLE OF SLIS_T_FIELDCAT_ALV,
*          GD_LAYOUT    TYPE SLIS_LAYOUT_ALV,
*          GD_REPID     LIKE SY-REPID.
*
**** Attachment
*    REFRESH: I_RECLIST,I_OBJTXT,I_OBJBIN,I_OBJPACK.
*    CLEAR WA_OBJHEAD.
    BREAK breddy.
***  PO Deatils
*    SELECT SINGLE EKKO~EBELN,
*                  EKKO~AEDAT,
*                  EKKO~ERNAM,
*                  EKKO~LIFNR,
*                  LFA1~NAME1
*                  INTO @DATA(LS_EKKO)
*                  FROM EKKO AS EKKO
*                  INNER JOIN LFA1 AS LFA1 ON LFA1~LIFNR = EKKO~LIFNR
*                  WHERE EKKO~EBELN = @I_EBELN.
*    CHECK LS_EKKO IS NOT INITIAL.
**** Subject email
**** Body email
*    REFRESH I_OBJTXT.
*    APPEND VALUE #( LINE = 'Dear Sir / Madam,' ) TO I_OBJTXT.
*    APPEND VALUE #( LINE = 'Kindly find Service Order Details' ) TO I_OBJTXT.
*    APPEND VALUE #( LINE = '' ) TO I_OBJTXT.
*    APPEND VALUE #( LINE = '1. Service Order : ' && LS_EKKO-EBELN && CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB ) TO I_OBJTXT.
*    APPEND VALUE #( LINE = '2. Transporter Code : ' && LS_EKKO-LIFNR && CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB  ) TO I_OBJTXT.
*    APPEND VALUE #( LINE = '3. Transporter Name: ' && LS_EKKO-NAME1 && CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB  ) TO I_OBJTXT.
*    APPEND VALUE #( LINE = '4. Created By : ' && LS_EKKO-ERNAM && CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB  ) TO I_OBJTXT.
*    APPEND VALUE #( LINE = '5. Created On : ' && LS_EKKO-AEDAT+6(2) && '.' && LS_EKKO-AEDAT+4(2) && '.' &&  LS_EKKO-AEDAT+0(4) && CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB  ) TO I_OBJTXT.
*    APPEND VALUE #( LINE = '' ) TO I_OBJTXT.
*    APPEND VALUE #( LINE = 'Thanks,' ) TO I_OBJTXT.
*    APPEND VALUE #( LINE = 'Team - Saravana. ' ) TO I_OBJTXT.
*    APPEND VALUE #( LINE = '' ) TO I_OBJTXT.
*
*    APPEND VALUE #( LINE = 'This is an automatically generated email – please do not reply to it.' ) TO I_OBJTXT.
*    DESCRIBE TABLE I_OBJTXT LINES V_LINES_TXT.
**** Mail ID
*    APPEND VALUE #( RECEIVER = 'SURI.AMBURI@ZIETATECH.COM' REC_TYPE = 'U' ) TO I_RECLIST.
*    APPEND VALUE #( RECEIVER = 'SDP.ASHER@GMAIL.COM' REC_TYPE = 'U' ) TO I_RECLIST.
*    APPEND VALUE #( RECEIVER = 'ANUANILMETHA@YAHOO.COM' REC_TYPE = 'U' ) TO I_RECLIST.
*    APPEND VALUE #( RECEIVER = 'DUMMYPOSAP@GMAIL.COM' REC_TYPE = 'U' ) TO I_RECLIST.
**** Main Text
*    APPEND VALUE #( HEAD_START = 1 HEAD_NUM = 0 BODY_START = 1 BODY_NUM = V_LINES_TXT DOC_TYPE = 'RAW') TO I_OBJPACK.
**** Email Ids
*
*    WA_DOC_CHNG-OBJ_NAME = 'Service PO'.
*    WA_DOC_CHNG-OBJ_DESCR = 'Service PO Created : ' && I_EBELN.
*    WA_DOC_CHNG-SENSITIVTY = 'F'.
*    WA_DOC_CHNG-DOC_SIZE = V_LINES_TXT * 255.
*
*    IF I_RECLIST IS NOT INITIAL.
**** Sending Mail
*      CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
*        EXPORTING
*          DOCUMENT_DATA              = WA_DOC_CHNG
*          PUT_IN_OUTBOX              = 'X'
*          COMMIT_WORK                = 'X'
*        TABLES
*          PACKING_LIST               = I_OBJPACK
*          CONTENTS_TXT               = I_OBJTXT
*          RECEIVERS                  = I_RECLIST
*        EXCEPTIONS
*          TOO_MANY_RECEIVERS         = 1
*          DOCUMENT_NOT_SENT          = 2
*          DOCUMENT_TYPE_NOT_EXIST    = 3
*          OPERATION_NO_AUTHORIZATION = 4
*          PARAMETER_ERROR            = 5
*          X_ERROR                    = 6
*          ENQUEUE_ERROR              = 7
*          OTHERS                     = 8.
*      IF SY-SUBRC = 0.
*      ENDIF.
*    ENDIF.



**************changes done by bhavani******************

    IF print IS NOT INITIAL .
      CALL FUNCTION 'ZFM_PURCHASE_FORM1'
        EXPORTING
          lv_ebeln       = i_ebeln           " Purchasing Document Number
          print_prieview = 'X'                " Single-Character Flag
          service_po     = 'X'.                " Single-Character Flag
    ELSE.
      CALL FUNCTION 'ZFM_PURCHASE_FORM1'
        EXPORTING
          lv_ebeln   = i_ebeln           " Purchasing Document Number
          service_po = 'X'.                " Single-Character Flag
    ENDIF.





*************end of changes***************************
  ENDMETHOD.
ENDCLASS.
