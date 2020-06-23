*&---------------------------------------------------------------------*
*& Report ZFI_BNK_PAYMENT_VOUCHER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_BNK_PAYMENT_VOUCHER.


TABLES: PAYR, BSEG.

DATA: IT     TYPE TABLE OF ZVBLNR,
      WA     TYPE ZVBLNR,
*      it_1   type table of zbelnr,
*      wa_1   type zbelnr,
      GV_IND TYPE CHAR1.


TYPES : BEGIN OF TY_BSAK,
         lifnr TYPE BSAK-LIFNR,
         BELNR TYPE BSAK-BELNR,
         BLART TYPE BSAK-BLART,
  END OF TY_BSAK,

      BEGIN OF TY_BSEG ,
           BELNR TYPE BSEG-BELNR,
           LIFNR TYPE BSEG-LIFNR,
        END OF TY_BSEG.


  DATA : IT_BSAK TYPE TABLE OF TY_BSAK,
         IT_LIFNR1 TYPE TABLE OF TY_BSEG.




DATA : LS_FIS_YR TYPE BKPF-GJAHR.
DATA : R_VBLNR TYPE RANGE OF PAYR-VBLNR WITH HEADER LINE.
DATA :  R_BELNR TYPE RANGE OF BSEG-BELNR WITH HEADER LINE.
DATA: F_NAME TYPE RS38L_FNAM.
*data:lv_vblnr type vblnr.
SELECTION-SCREEN: BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
SKIP 1.

PARAMETERS: P_ZBUKR TYPE   PAYR-ZBUKR. "DEFAULT '4000'.
PARAMETERS : P_GJAHR TYPE  PAYR-GJAHR. "DEFAULT '2017'.
*SELECT-OPTIONS : S_LIFNR FOR PAYR-LIFNR ."MATCHCODE OBJECT ZLIFNR.
SELECT-OPTIONS : S_VBLNR FOR PAYR-VBLNR MATCHCODE OBJECT ZVBLNR.

SKIP 1.
SELECTION-SCREEN: END OF BLOCK B1.


*********************     ADDED ON (22-4-20)     ********************
**AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VBLNR-LOW.
**  DATA : return TYPE TABLE OF ddshretval.
**  CHECK s_LIFNR[] IS NOT INITIAL.
**  s_LIFNR = s_LIFNR[ 1 ].
***BREAK CLIKHITHA.
***  SELECT vblnr
***     FROM payr INTO TABLE @data(it_LIFNR) WHERE lifnr = @s_lifnr-low .
**    SELECT PAYR~VBLNR,
**           BSAK~BELNR,
**           BSAK~lifnr,
**           BSAK~blart
**           FROM PAYR INNER JOIN BSAK AS BSAK ON BSAK~BELNR = PAYR~VBLNR
**           WHERE  PAYR~VBLNR = BSAK~BELNR AND blart = 'KZ' AND
**      BSAK~lifnr IN @s_lifnr  INTO TABLE @DATA(it_LIFNR).
**
***    SELECT augbl
***           lifnr
***           BLART FROM bsak INTO CORRESPONDING FIELDS OF TABLE it_LIFNR
***           FOR ALL ENTRIES IN it_pay
***           WHERE augbl = it_pay-vblnr AND
***           lifnr = it_pay-lifnr AND
***           blart IN ('KR','RE','ZH').
***           AND shkzg = 'H'.
**
**
**  SORT it_lifnr AS TEXT BY vblnr.
**  DELETE ADJACENT DUPLICATES FROM it_lifnr COMPARING vblnr.
**CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
**  EXPORTING
***   DDIC_STRUCTURE         = ' '
**    RETFIELD               = 'vblnr'
***   PVALKEY                = ' '
**   DYNPPROG               = sy-repid
**   DYNPNR                 = sy-dynnr
**   DYNPROFIELD            = 's_vblnr'
***   STEPL                  = 0
***   WINDOW_TITLE           =
***   VALUE                  = ' '
***   VALUE_ORG              = 'S'
**   MULTIPLE_CHOICE        = 'X'
**   VALUE_ORG              = 'S'
***   DISPLAY                = ' '
***   CALLBACK_PROGRAM       = ' '
***   CALLBACK_FORM          = ' '
***   CALLBACK_METHOD        =
***   MARK_TAB               =
*** IMPORTING
***   USER_RESET             =
**  TABLES
**    VALUE_TAB              = IT_LIFNR
***   FIELD_TAB              =
**   RETURN_TAB             = return.
***   DYNPFLD_MAPPING        =
*** EXCEPTIONS
***   PARAMETER_ERROR        = 1
***   NO_VALUES_FOUND        = 2
***   OTHERS                 = 3
**          .
** CLEAR s_VBLNR. REFRESH : s_VBLNR[] .
**  LOOP AT return ASSIGNING FIELD-SYMBOL(<ls_return>).
**    s_VBLNR-sign = 'I'.
**    s_VBLNR-option = 'EQ'.
**    s_VBLNR-low = <ls_return>-fieldval.
**    append s_VBLNR to s_VBLNR[].
**    APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_return>-fieldval ) TO r_VBLNR[].
**  ENDLOOP.
***  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
** IF IT_LIFNR IS INITIAL .
**
**
***   SELECT BELNR
***     FROM BSEG INTO TABLE @data(it_lifnr1) WHERE lifnr = @s_lifnr-low .
***      SELECT BSEG~BELNR,
***           BSAK~augbl,
***           BSAK~lifnr,
***           BSAK~blart
***           FROM BSEG INNER JOIN BSAK AS BSAK ON BSAK~augbl = BSEG~BELNR
***           WHERE  BSEG~BELNR = BSAK~augbl AND blart IN  ('KZ') AND
***      BSAK~lifnr IN @s_lifnr  INTO TABLE @DATA(it_LIFNR1).
**  SELECT lifnr
**         BELNR
**         BLART FROM BSAK INTO TABLE IT_BSAK WHERE LIFNR IN S_LIFNR AND BLART = 'KZ'.
**    IF IT_BSAK IS NOT INITIAL.
**      SELECT BELNR
**             LIFNR
**             FROM BSEG INTO TABLE IT_LIFNR1 FOR ALL ENTRIES IN IT_BSAK WHERE BELNR = IT_BSAK-BELNR AND LIFNR = IT_BSAK-LIFNR.
**      ENDIF.
**
**
**
**  SORT it_lifnr1 AS TEXT BY BELNR.
**  DELETE ADJACENT DUPLICATES FROM it_lifnr1 COMPARING BELNR.
**CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
**  EXPORTING
***   DDIC_STRUCTURE         = ' '
**    RETFIELD               = 'BELNR'
***   PVALKEY                = ' '
**   DYNPPROG               = sy-repid
**   DYNPNR                 = sy-dynnr
**   DYNPROFIELD            = 's_vblnr'
***   STEPL                  = 0
***   WINDOW_TITLE           =
***   VALUE                  = ' '
***   VALUE_ORG              = 'S'
**   MULTIPLE_CHOICE        = 'X'
**   VALUE_ORG              = 'S'
***   DISPLAY                = ' '
***   CALLBACK_PROGRAM       = ' '
***   CALLBACK_FORM          = ' '
***   CALLBACK_METHOD        =
***   MARK_TAB               =
*** IMPORTING
***   USER_RESET             =
**  TABLES
**    VALUE_TAB              = IT_LIFNR1
***   FIELD_TAB              =
**   RETURN_TAB             = return.
***   DYNPFLD_MAPPING        =
*** EXCEPTIONS
***   PARAMETER_ERROR        = 1
***   NO_VALUES_FOUND        = 2
***   OTHERS                 = 3
**          .
** CLEAR s_VBLNR. REFRESH : s_VBLNR[] .
**  LOOP AT return ASSIGNING FIELD-SYMBOL(<ls_return1>).
**    s_VBLNR-sign = 'I'.
**    s_VBLNR-option = 'EQ'.
**    s_VBLNR-low = <ls_return1>-fieldval.
**    append s_VBLNR to s_VBLNR[].
**    APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_return1>-fieldval ) TO r_BELNR[].
**  ENDLOOP.
**
**   ENDIF.
**
***   ********************************************************************************************
**
**  AT SELECTION-SCREEN OUTPUT.
**  LOOP AT SCREEN.
**    IF screen-name = '%_S_SIZE_%_APP_%-VALU_PUSH' OR screen-name = '%_S_FROM_%_APP_%-VALU_PUSH'.
**      screen-invisible = '1'.
**      MODIFY SCREEN.
**    ENDIF.
**  ENDLOOP.
***IF SY-SUBRC <> 0.
**** Implement suitable error handling here
***ENDIF.
**

********************    END (22-4-20)   *******************
*INITIALIZATION.
*  CALL FUNCTION 'GET_CURRENT_YEAR'
*    EXPORTING
*      BUKRS = '4000'
*      DATE  = SY-DATUM
*    IMPORTING
*      CURRY = LS_FIS_YR.
*  P_GJAHR = LS_FIS_YR.
**  P_GJAHR-SIGN = 'I'.
**  P_GJAHR-OPTION = 'EQ'.
**  APPEND P_GJAHR.

START-OF-SELECTION.

  SELECT VBLNR FROM PAYR INTO TABLE IT WHERE VBLNR IN S_VBLNR.
  IF SY-SUBRC <> 0.
    SELECT BELNR   FROM BSEG INTO TABLE IT WHERE BELNR IN S_VBLNR.
    IF SY-SUBRC = 0.
      GV_IND = 'X'.
    ENDIF.

  ENDIF.

  SORT IT BY VBLNR.
  DELETE ADJACENT DUPLICATES FROM IT COMPARING VBLNR BELNR.


  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZFI_PAYMENT_VOUCHER_N'
    IMPORTING
      FM_NAME            = F_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  IF SY-SUBRC <> 0.
* Implement suitable error handling here

  ENDIF.


  DATA:CONTROL TYPE SSFCTRLOP.

  CONTROL-NO_OPEN  = 'X'.
  CONTROL-PREVIEW  = 'X'.
  CONTROL-NO_CLOSE = 'X'.

  CALL FUNCTION 'SSF_OPEN'
    EXPORTING
*     ARCHIVE_PARAMETERS =
      USER_SETTINGS      = 'X'
*     MAIL_SENDER        =
*     MAIL_RECIPIENT     =
*     MAIL_APPL_OBJ      =
*     OUTPUT_OPTIONS     =
      CONTROL_PARAMETERS = CONTROL
*   IMPORTING
*     JOB_OUTPUT_OPTIONS =
    EXCEPTIONS
      FORMATTING_ERROR   = 1
      INTERNAL_ERROR     = 2
      SEND_ERROR         = 3
      USER_CANCELED      = 4
      OTHERS             = 5.


  IF SY-SUBRC <> 0.
* Implement suitable error handling here

  ENDIF.

  LOOP AT IT INTO WA.


    CALL FUNCTION F_NAME
      EXPORTING
*       ARCHIVE_INDEX      =
*       ARCHIVE_INDEX_TAB  =
*       ARCHIVE_PARAMETERS =
        CONTROL_PARAMETERS = CONTROL
*       MAIL_APPL_OBJ      =
*       MAIL_RECIPIENT     =
*       MAIL_SENDER        =
*       OUTPUT_OPTIONS     =
        USER_SETTINGS      = 'X'
        P_ZBUKR            = P_ZBUKR
        P_GJAHR            = P_GJAHR
        S_VBLNR            = WA
        GV_IND             = GV_IND
*   IMPORTING
*       DOCUMENT_OUTPUT_INFO       =
*       JOB_OUTPUT_INFO    =
*       JOB_OUTPUT_OPTIONS =
      EXCEPTIONS
        FORMATTING_ERROR   = 1
        INTERNAL_ERROR     = 2
        SEND_ERROR         = 3
        USER_CANCELED      = 4
        OTHERS             = 5.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    CLEAR WA.
  ENDLOOP.

  CALL FUNCTION 'SSF_CLOSE'.
