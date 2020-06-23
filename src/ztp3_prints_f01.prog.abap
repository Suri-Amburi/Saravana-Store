*&---------------------------------------------------------------------*
*& Include          ZTP3_PRINTS_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form PRINT_GRPO_S
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRINT_GRPO_S .
  IF LS_HDR-GRPO_S IS INITIAL.
    DATA : FORM_NAME TYPE RS38L_FNAM.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        FORMNAME           = 'ZMM_GRPO_FORM'
      IMPORTING
        FM_NAME            = FORM_NAME
      EXCEPTIONS
        NO_FORM            = 1
        NO_FUNCTION_MODULE = 2
        OTHERS             = 3.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
    CALL FUNCTION FORM_NAME
      EXPORTING
        LV_QR_CODE       = P_QR
      EXCEPTIONS
        FORMATTING_ERROR = 1
        INTERNAL_ERROR   = 2
        SEND_ERROR       = 3
        USER_CANCELED    = 4
        OTHERS           = 5.
    IF SY-SUBRC = 0 AND SY-UCOMM = 'PRNT'.
*** Updating Printing status
      LS_HDR-GRPO_S = C_X.
      LS_HDR-GRPO_S_PRINTED_BY = SY-UNAME.
      MODIFY ZINW_T_HDR FROM LS_HDR.
    ENDIF.
  ELSE.
    MESSAGE S026(ZMSG_CLS) WITH LS_HDR-L_PRINTED_BY DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRINT_LABELS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRINT_LABELS .
  IF LS_HDR-LABLE_PRINT IS INITIAL.
    IF  LS_HDR-MBLNR IS NOT INITIAL .
      SELECT SINGLE MJAHR FROM MSEG INTO @DATA(LV_MJAHR) WHERE MBLNR = @LS_HDR-MBLNR.
      DATA(LV_MBLNR) = LS_HDR-MBLNR.
    ELSE.
      SELECT SINGLE MJAHR FROM MSEG INTO LV_MJAHR WHERE MBLNR = LS_HDR-MBLNR_103.
      LV_MBLNR = LS_HDR-MBLNR_103.
    ENDIF.
*** Printing Lables
    IF LV_MBLNR IS NOT INITIAL AND LV_MJAHR IS NOT INITIAL.
*      PERFORM TP3_PRINT_STCKER IN PROGRAM ZTP3_LABLE USING LV_MBLNR C_X LV_MJAHR.
      SUBMIT ZTP3_LABLE AND RETURN WITH P_MBLNR = LV_MBLNR WITH P_TP3 = C_X WITH P_MJAHR = LV_MJAHR WITH p_charg = p_charg WITH p_prints = p_prints .
*      CALL FUNCTION 'ZLABLE_PRINT'
*        EXPORTING
*          I_MBLNR       = LV_MBLNR                " Material Document Number
*          I_TP3_STICKER = 'X'                       " X for Print
*          I_MJAHR       = LV_MJAHR.              " Material Document Year
      IF SY-SUBRC = 0 AND SY-UCOMM = 'PRNT'.
***   Updating Printing status
        LS_HDR-LABLE_PRINT = C_X.
        LS_HDR-L_PRINTED_BY = SY-UNAME.
        MODIFY ZINW_T_HDR FROM LS_HDR.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE S026(ZMSG_CLS) WITH LS_HDR-L_PRINTED_BY DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRINT_GRPO_P
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRINT_GRPO_P .
  IF LS_HDR-GRPO_P IS INITIAL.
    PERFORM GRPO_PRICE_FORM IN PROGRAM ZMM_GRPO_PRICE_REP USING P_QR.
    IF SY-SUBRC = 0 AND SY-UCOMM = 'PRNT'.
***    Updating Printing status
      LS_HDR-GRPO_P = 'X'.
      LS_HDR-GRPO_P_PRINTED_BY = SY-UNAME.
      MODIFY ZINW_T_HDR FROM LS_HDR.
    ENDIF.
  ELSE.
    MESSAGE S026(ZMSG_CLS) WITH LS_HDR-L_PRINTED_BY DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
