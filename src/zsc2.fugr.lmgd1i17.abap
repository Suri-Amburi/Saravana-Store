*----------------------------------------------------------------------*
*   INCLUDE LMGD1I17                                                   *
*----------------------------------------------------------------------*

* Enhancement related to segmentation dependent Weights and Volumes
ENHANCEMENT-POINT LMGD1I17_01 SPOTS ES_LMGD1I17 STATIC INCLUDE BOUND .

*&---------------------------------------------------------------------*
*&      Module  TC_ON_DYNPRO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_ON_DYNPRO INPUT.
  FLG_TC = 'X'.
ENDMODULE.                 " TC_ON_DYNPRO  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_SEGMENT_MM  INPUT
*&---------------------------------------------------------------------*
*It validates the Segment value, set's the change indicator            *
*GV_SGT_CHANGE                                                         *
*----------------------------------------------------------------------*
MODULE VALIDATE_SEGMENT_MM INPUT.
** Call subroutine to perform validations
  PERFORM VALIDATE_SEGMENT_MM.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form VALIDATE_SEGMENT_MM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
* 1. Check if the segment value entered is valid                       *
* 2. Set/Clear segment value change indicator (GV_SGT_CHANGE)          *
*----------------------------------------------------------------------*
FORM VALIDATE_SEGMENT_MM .
* Check user command
* Exclude exit commands
  IF SY-UCOMM NE FCODE_BABA AND SY-UCOMM NE FCODE_MAIN.
    IF *MEAN-SGT_CATV IS NOT INITIAL.
* Validate Segment
      PERFORM VALIDATE_SEGMENT_VALUE_MM USING *MEAN-SGT_CATV.
    ENDIF.
  ENDIF.
* Set change indicator
  IF GV_MEAN NE *MEAN-SGT_CATV .
    GV_SGT_CHANGE = ABAP_TRUE.
  ELSE.
* Clear change indicator
    CLEAR GV_SGT_CHANGE.
  ENDIF.

* Copy the number of current EAN entries into EAN_LINES
    DESCRIBE TABLE MEAN_ME_TAB[] LINES EAN_LINES.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_SEGMENT_VALUE_MM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
* Function module SGTV_VALID_CATS_READ validates the Segment Value     *
* Based on Segmentation Structure & Segmentation Strategy              *
*&---------------------------------------------------------------------*
FORM VALIDATE_SEGMENT_VALUE_MM  USING PV_SEGMENT.
* EAN Relevancy check
CALL FUNCTION 'SGTV_VALID_CATS_READ'
  EXPORTING
   IV_CSGR    = MARA-SGT_CSGR
   IV_APPL    = 'S'
   IV_COVS    = MARA-SGT_COVSA
   IV_VALUE   = PV_SEGMENT
   IV_CFUN    = 'EAN'
 EXCEPTIONS
   NOT_FOUND                     = 2
   OTHERS                        = 3.
IF SY-SUBRC <> 0.
* Invalid stock segment
    MESSAGE E834(SGT_01) WITH PV_SEGMENT MARA-SGT_COVSA DISPLAY LIKE 'S'.
ELSEIF SY-SUBRC = 0 AND MEAN-EANTP IS INITIAL
                    AND *MEAN-SGT_CATV IS INITIAL.
    "Check for EAN-Category
    MESSAGE E118(SGT_01) WITH PV_SEGMENT DISPLAY LIKE 'S'.
ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  MODIFY_MEAN_MM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_MEAN_MM INPUT.
** Call subroutine to modify transfer segment values
 PERFORM MODIFY_MEAN_MM.
ENDMODULE.

MODULE VALIDATE_MEAN_MM INPUT.
* Validate segment value
 IF MEAN-SGT_CATV IS NOT INITIAL.
   PERFORM VALIDATE_SEGMENT_VALUE_MM USING MEAN-SGT_CATV.

 ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form MODIFY_MEAN_MM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
* MEAN_ME_TAB structures are modified to hold the Segment values,      *
* Only if the segment value is changed                                 *
*----------------------------------------------------------------------*
FORM MODIFY_MEAN_MM .
* Copy Segment values, while creation and change of Segment values
  IF GV_SGT_CHANGE IS INITIAL.
    IF *MEAN-SGT_CATV IS INITIAL.
      MEAN_ME_TAB-SGT_CATV    = MEAN-SGT_CATV.
    ELSE.
      MEAN_ME_TAB-SGT_CATV    = *MEAN-SGT_CATV.
    ENDIF.

*    "Update Segment value
*    MODIFY MEAN_ME_TAB[] FROM MEAN_ME_TAB TRANSPORTING SGT_CATV
*                         WHERE EAN11 = MEAN_ME_TAB-EAN11.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_MEAN_MM  INPUT
*&---------------------------------------------------------------------*
* Update tables MEAN_ME_TAB with the changed EANS.                     *
* Update the buffer tables GT_MEAN above tables.                       *
* If segment filter value is changed then load the buffer data into    *
* tables MEAN_TAB_SA and MEAN_TAB                                      *
*----------------------------------------------------------------------*
MODULE UPDATE_MEAN_MM INPUT.
** Call subroutine to update the changed entries
  PERFORM UPDATE_MEAN_TAB_MM.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form UPDATE_MEAN_TAB_MM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
* Update tables MEAN_ME_TAB with the changed EANS.                     *
* Update the buffer tables GT_MEAN above tables.                       *
* If segment filter value is changed then load the buffer data into    *
* tables MEAN_TAB_SA and MEAN_TAB                                      *
*----------------------------------------------------------------------*
FORM UPDATE_MEAN_TAB_MM .
* If Segment value is changed
  IF GV_SGT_CHANGE IS INITIAL.
      IF *MEAN-SGT_CATV IS NOT INITIAL.
        "On filter, EAN's changes will be captured here.
        DELETE GT_MEAN[] WHERE SGT_CATV = *MEAN-SGT_CATV.
        APPEND LINES OF MEAN_ME_TAB TO GT_MEAN.
        MEAN_ME_TAB[] = GT_MEAN[].
      ELSE.
        "New data will be copied to Global table GT_MEAN
        GT_MEAN[] = MEAN_ME_TAB[].
      ENDIF.
  ELSE.
      "Filtering with segment, then Global table container
      "data will be copied, later in PBO Non-filter
      "data will be removed.
      MEAN_ME_TAB[] = GT_MEAN[].
  ENDIF.
ENDFORM.
