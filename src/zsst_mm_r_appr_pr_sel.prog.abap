*&---------------------------------------------------------------------*
*& Include          ZSST_MM_R_APPR_PR_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN : BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.

  PARAMETERS : P_RAD1 RADIOBUTTON GROUP RB1 USER-COMMAND UPD.
  PARAMETERS : P_RAD2 RADIOBUTTON GROUP RB1 .
  SELECT-OPTIONS: S_GRP FOR LV_GROUP_ID .
  PARAMETERS P_INWD TYPE ZINW_T_HDR-INWD_DOC.

SELECTION-SCREEN : END OF BLOCK B1.


INITIALIZATION.
  P_RAD1 = 'X'.
  FLAG = ' '.
  LOOP AT SCREEN.
    IF SCREEN-NAME CS 'P_INWD' ."= 'ID1'.
      SCREEN-ACTIVE = '0'.

      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN.
  GD_UCOMM = SY-UCOMM.
  CASE GD_UCOMM.
    WHEN 'UPD'.
      IF P_RAD1 = 'X'.
        FLAG = 'X'.
      ENDIF.
      IF P_RAD2 = 'X'.
        FLAG = 'D'.
      ENDIF.
  ENDCASE.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF SCREEN-NAME CS 'P_INWD'." = 'IDI'.
      IF FLAG ='D'.
        SCREEN-ACTIVE = '1'.
      ELSEIF FLAG = 'X'.
        SCREEN-ACTIVE = '0'.
      ENDIF.
      MODIFY SCREEN.

    ENDIF.
    IF SCREEN-NAME CS 'S_GRP'.
      IF FLAG = 'D'.
        SCREEN-ACTIVE = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
