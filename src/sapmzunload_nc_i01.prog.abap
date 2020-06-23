*&---------------------------------------------------------------------*
*& Include          ZUNLOAD_SJ_I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Include          SAPMZSHIPMENT_PICKING_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.

  CASE SY-UCOMM.
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'PG+'.
      PERFORM PROCESS_PG_DN.
    WHEN 'PG-'.
      PERFORM PROCESS_PG_UP.
    WHEN OTHERS.
      IF GV_SEL IS NOT INITIAL.
        PERFORM READ_SHIPMENT.
      ENDIF.
  ENDCASE.    "   CASE ok-code.

ENDMODULE.                 " USER_COMMAND_3000  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9001 INPUT.

  CASE SY-UCOMM.
    WHEN 'BACK'.
      SET SCREEN 0 .
      LEAVE TO SCREEN 0.
    WHEN 'ENTER'.
      PERFORM READ_PALLET.
  ENDCASE .
ENDMODULE .

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9999  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9999 INPUT.

  CASE SY-UCOMM.
    WHEN 'BACK'.
      CLEAR SY-UCOMM .
*      unpack = 'X' .
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9991  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9991 INPUT.

  CASE AUCOMM.
    WHEN BACK.
      LEAVE PROGRAM.
    WHEN EXEC.
      PERFORM READ_SHIPMENT.
    WHEN NPAGE.
      IF ( CURRP + 1 ) LE LASTP.
        CURRP = CURRP + 1.
      ENDIF.
    WHEN PPAGE.
      IF ( CURRP - 1 ) GE 1.
        CURRP = CURRP - 1.
      ENDIF.
    WHEN FPAGE.
      CURRP = 1.
    WHEN LPAGE.
      CURRP = LASTP.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9992  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9992 INPUT.

  CASE AUCOMM.
    WHEN BACK.
      PERFORM LOCK_UNLOCK_SHIPMENT USING ATKNUM SPACE
                                CHANGING ASUBRC.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9993  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9993 INPUT.
  MARK = 'X' .
  CASE AUCOMM.
    WHEN AAOK.
      CALL FUNCTION 'DEQUEUE_ALL'
*       EXPORTING
*         _SYNCHRON       = ' '
        .
*      PERFORM unload_hu_update.
      PERFORM UNLOADING .
*      SET SCREEN 0 .
*      LEAVE TO SCREEN 0.
    WHEN AANO.
      CLEAR : GV_EXIDV , GV_VBELN .
*      unpack = 'X' .
      SET SCREEN 0 .
      LEAVE TO SCREEN 0.
  ENDCASE.

  CLEAR AUCOMM.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXDIV_VALI_LOAD_UNLOAD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXDIV_VALI_LOAD_UNLOAD INPUT.

  IF AEXIDV  IS NOT INITIAL.    "added by sjena on 26.12.2018 15:01:01 #FOR_JD_HUNO
    DATA(LEN) = STRLEN( AEXIDV ) .
    IF LEN > 12.
      AEXIDV = AEXIDV+0(11) .       " added by sjena .
    ELSE .
      AEXIDV = AEXIDV+0(12) .       " added by sjena .
    ENDIF.
  ENDIF.
  AEXIDV = |{ AEXIDV ALPHA = IN }| .  "added by sjena on 26.12.2018 15:09:40
*****Validate EXIDV.
  IF AEXIDV IS NOT INITIAL.
    READ TABLE XVEKP WITH KEY EXIDV = AEXIDV.     " check for SAP Carton_no
    IF SY-SUBRC IS NOT INITIAL.
      READ TABLE XVEKP  WITH KEY EXIDV2 = AEXIDV .  " check for JD Carton_no
      IF SY-SUBRC IS NOT INITIAL.
        READ TABLE XVEKP WITH KEY PALLET = AEXIDV . " check for Pallet_no
        IF SY-SUBRC IS NOT INITIAL.
          CLEAR: AICON, MESAG1, MESAG2, MESAG3, MESAG4, MESAG5, MESAG6, MESAG7.
          AICON = ICON_RED_LIGHT.
          MESAG1 = TEXT-006.
          MESAG2 = AEXIDV.
          CALL SCREEN 9999.
          EXIT.
        ELSE .
          CLEAR AEXIDV .
          AEXIDV = XVEKP-EXIDV .
        ENDIF.
      ELSE .
        CLEAR AEXIDV .
        AEXIDV = XVEKP-EXIDV .
      ENDIF.
    ENDIF.
    PERFORM READ_PALLET .
    IF MARK <> 'X'.
      READ TABLE XVEPO WITH KEY VENUM = XVEKP-VENUM.

*****CHECK_IF_ALREADY_LOADED.
      READ TABLE XLHUS WITH KEY OBJNR = XVEPO-OBJNR.
      IF SY-SUBRC IS INITIAL.
*      CALL SCREEN '9993'. "Unload yes or no "Commented on 09.04.2018
*    EXIT.
      ENDIF.
*****LOAD_EXIDV.
      CALL FUNCTION 'LE_MOB_LOAD_HU'
        EXPORTING
          I_HU_EXIDV           = AEXIDV
        EXCEPTIONS
          NOT_POSSIBLE         = 1
          UNLOAD_STATUS_ACTIVE = 2
          LOAD_STATUS_ACTIVE   = 3
          NO_HU_FOUND          = 4
          HUS_LOCKED           = 5
          FATAL_ERROR          = 6
          OTHERS               = 7.


*      PERFORM HU_STATUS_SET_LOAD USING AEXIDV.
      IF SY-SUBRC IS NOT INITIAL.
        CLEAR: AICON, MESAG1, MESAG2, MESAG3, MESAG4, MESAG5, MESAG6, MESAG7.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO AMESAG.
        MESAG1 = AMESAG+0(25).
        MESAG2 = AMESAG+25(25).
        MESAG3 = AMESAG+50(25).
        MESAG4 = AMESAG+75(25).
        MESAG5 = AMESAG+100(25).
        AICON = ICON_RED_LIGHT.
        CALL SCREEN 9999.
        EXIT.
      ENDIF.

      LOADED_HUS = LOADED_HUS + 1.
      XLHUS-OBJNR = XVEPO-OBJNR.
      APPEND XLHUS.

      CALL FUNCTION 'DEQUEUE_ALL'
*     EXPORTING
*       _SYNCHRON       = ' '
        .

      IF LOADED_HUS EQ 1.
*    IF DALBG, DALEN IS NOT INITIAL.
        IF ADALBG IS NOT INITIAL.
********Delete existing load start
          PERFORM START_END_LOADING USING ATKNUM
                                          AX    "Start/End Indicator
                                          AD.   "Change/Delete
        ENDIF.
********Create load start
        PERFORM START_END_LOADING USING ATKNUM
                                        AX    "Start/End Indicator
                                        AC.   "Change/Delete
      ENDIF.

      IF LOADED_HUS EQ TOTALL_HUS.

        IF ADALEN IS NOT INITIAL.
********Delete existing load end
          PERFORM START_END_LOADING USING ATKNUM
                                          SPACE "Start/End Indicator
                                          AD.   "Change/Delete
        ENDIF.

********Create load end
        PERFORM START_END_LOADING USING ATKNUM
                                        SPACE "Start/End Indicator
                                        AC.   "Change/Delete

*******Update higher level HU's with loaded status
*    PERFORM HIGHER_HU_AS_LOADED USING SPACE.

        DELETE XVTTK WHERE TKNUM EQ ATKNUM.
        PERFORM LOCK_UNLOCK_SHIPMENT USING ATKNUM SPACE
                                CHANGING ASUBRC.
        LEAVE TO SCREEN 0.

      ENDIF.
    ENDIF.
  ENDIF.
  CLEAR AEXIDV.
ENDMODULE.
