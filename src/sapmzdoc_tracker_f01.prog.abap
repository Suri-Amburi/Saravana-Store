*&---------------------------------------------------------------------*
*& Include          SAPMZDOC_TRACKER_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SCAN_QR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_QR
*&---------------------------------------------------------------------*
FORM SCAN_QR CHANGING GV_QR.
  CHECK GV_QR IS NOT INITIAL.
  READ TABLE GT_DATA WITH KEY QR_CODE = GV_QR TRANSPORTING NO FIELDS.
  IF SY-SUBRC <> 0.
    SELECT SINGLE * FROM ZDOC_T_TRACK INTO @DATA(LS_TRACK) WHERE QR_CODE = @GV_QR AND STATUS = @GV_DOC_STATUS.
    IF SY-SUBRC <> 0.
      SELECT SINGLE * FROM ZINW_T_HDR INTO @DATA(LS_HDR) WHERE QR_CODE = @GV_QR AND STATUS = @GV_STATUS.
      IF SY-SUBRC <> 0.
        MESSAGE S003(ZMSG_CLS)  DISPLAY LIKE 'E'.
*    LEAVE LIST-PROCESSING.
        EXIT.
      ELSE.
        DESCRIBE TABLE GT_DATA LINES DATA(LV_LINES).
        APPEND VALUE #( SLNO = LV_LINES + 1 INWARD_DOC = LS_HDR-INWD_DOC QR_CODE = LS_HDR-QR_CODE ) TO GT_DATA.
        MESSAGE S068(ZMSG_CLS).
      ENDIF.
    ELSE.
      MESSAGE 'QR Already Processed to Next Level' TYPE 'S' DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE 'QR Already Scanned' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.
  CLEAR : GV_QR.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_EXCLUDE
*&---------------------------------------------------------------------*

FORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE TYPE UI_FUNCTIONS.
  DATA LS_EXCLUDE TYPE UI_FUNC.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_FIND_MORE.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_SUM.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_AVERAGE.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_DETAIL.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PREPARE_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PREPARE_FCAT.
***  Displaying date in ALV Grid
  CHECK GT_FIELDCAT IS INITIAL.
*** SLNO
  GS_FIELDCAT-FIELDNAME   = 'SLNO'.
  GS_FIELDCAT-REPTEXT     = 'SLNO'.
  GS_FIELDCAT-COL_OPT     = 'X'.
  GS_FIELDCAT-TXT_FIELD   = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.
  CLEAR GS_FIELDCAT.
*** Group Des
  GS_FIELDCAT-FIELDNAME   = 'INWARD_DOC'.
  GS_FIELDCAT-REPTEXT     = 'Inward Document'.
  GS_FIELDCAT-COL_OPT     = 'X'.
  GS_FIELDCAT-TXT_FIELD   = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.
  CLEAR GS_FIELDCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA.

  CALL METHOD GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT                     = GS_LAYO
      IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE  " Excluded Toolbar Standard Functions
    CHANGING
      IT_OUTTAB                     = GT_DATA
      IT_FIELDCATALOG               = GT_FIELDCAT
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_DATA.
  FIELD-SYMBOLS :
    <LS_DATA> TYPE TY_DATA.
  IF GV_SENDOR IS INITIAL OR GV_RECEIVER IS INITIAL.
    MESSAGE 'Fill Sendor and Receivers Name' TYPE 'E'.
    EXIT.
  ENDIF.

  CHECK GT_DATA IS NOT INITIAL.
  LOOP AT GT_DATA ASSIGNING <LS_DATA>.
    APPEND VALUE #( MANDT = SY-MANDT QR_CODE = <LS_DATA>-QR_CODE INWD_DOC = <LS_DATA>-INWARD_DOC STATUS = GV_DOC_STATUS
                    CREATED_BY = SY-UNAME CREATED_DATE = SY-DATUM SENDER = GV_SENDOR RECEIVER = GV_RECEIVER ) TO GT_TRACKER.
  ENDLOOP.
  MODIFY ZDOC_T_TRACK FROM TABLE GT_TRACKER.
  MESSAGE S002(ZMSG_CLS).
  gv_mode = 'D'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INITIALIZATION .
  CASE C_X.
    WHEN R_RB1.
      GV_STATUS     = '01'.
      GV_DOC_STATUS = '01'.
    WHEN R_RB2.
      GV_STATUS     = '05'.
      GV_DOC_STATUS = '02'.
    WHEN R_RB3.
      GV_STATUS     = '07'.
      GV_DOC_STATUS = '03'.
    WHEN R_RB4.
      GV_STATUS     = '08'.
      GV_DOC_STATUS = '04'.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CLEAR_DATA.
  CLEAR : GV_DOC_STATUS, GV_SENDOR, GV_RECEIVER, GV_QR.
  REFRESH : GT_DATA, GT_TRACKER.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_MODE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_MODE.
  IF GV_MODE = 'D'.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'GV_QR' OR SCREEN-NAME = 'GV_SENDOR' OR SCREEN-NAME = 'GV_RECEIVER' .
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.
