*----------------------------------------------------------------------*
*   INCLUDE LMGD1O08                                                   *
*----------------------------------------------------------------------*

  INCLUDE LMGD1O12 .  " TC_CHECK_INVISIBLE

  INCLUDE LMGD1O11 .  " TC_SET_INVISIBLE
  INCLUDE LMGD1O10 .  " TC_ON_DYNPRO
ENHANCEMENT-POINT LMGD1O08_01 SPOTS ES_MGD2 STATIC INCLUDE BOUND .

*&---------------------------------------------------------------------*
*& Module GET_SGT_VALUE OUTPUT
*&---------------------------------------------------------------------*
*It calls the GET_SEGMENT_VALUE_MM,which is responsible for Hiding     *
*Segmnet field and modifies MEAN_ME_TAB with Segment filter value      *
*&---------------------------------------------------------------------*
MODULE GET_SGT_VALUE_MM OUTPUT.
** Call subroutine to modify the buffers based on the segment value
  PERFORM GET_SEGMENT_VALUE_MM.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form GET_SEGMENT_VALUE
*&---------------------------------------------------------------------*
* Standard table MEAN_ME_TAB is modified to hold the the EANs of the      *
* corresponding segment value entered.                                 *
* If no segment value is entered then all EANs are displayed.          *
* The global buffer table is GT_MEAN are filled for the first time.    *                                                      *
*----------------------------------------------------------------------*
FORM GET_SEGMENT_VALUE_MM .
    DATA : LV_CATV_AVL TYPE FLAG.
    IF MARA-SGT_COVSA IS NOT INITIAL.
      GV_EAN_REL  = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'.
      "Check for EAN-Relevancy
      CALL FUNCTION 'SGTG_ELIMINATE_NON_RELEVANT'
        EXPORTING
          IV_CSGR                     = MARA-SGT_CSGR
          IV_COVS                     = MARA-SGT_COVSA
          IV_APPL                     = 'S'
          IV_CFUN                     = 'EAN'
        CHANGING
          CV_CAT_VALUE                = GV_EAN_REL
        EXCEPTIONS
          NO_CATEGORY_STRUCTURE_FOUND = 1
          NO_RELEVANCE_INFO_FOUND     = 2
          INTERNAL_ERROR              = 3
          OTHERS                      = 4.
      IF SY-SUBRC <> 0.
        "Handle Exception
      ENDIF.
    ENDIF.

    LOOP AT MEAN_ME_TAB WHERE SGT_CATV IS NOT INITIAL .
      LV_CATV_AVL = 'X'.
    ENDLOOP.

    IF MARA-SGT_COVSA IS INITIAL OR MARA-SGT_SCOPE <> 1 OR GV_EAN_REL IS INITIAL .
      LOOP AT SCREEN.
        " Hide Segment field if segmentation strategy is not maitained
        IF SCREEN-GROUP2 = 'SG1'.
          SCREEN-INVISIBLE = 1.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

    ELSEIF LV_CATV_AVL IS INITIAL.
        LOOP AT SCREEN.
* Disable Segmentation Search Field
          IF SCREEN-GROUP2 = 'SG1'.
            SCREEN-INPUT     = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
    ELSE.
      "Stores the Segment filter value in Global variable
      GV_MEAN = *MEAN-SGT_CATV.

      "Global table GT_MEAN[] will be filled for first time
      GT_MEAN[] = MEAN_ME_TAB[].

      "Only Segment filter EAN's will be displayed
      IF *MEAN-SGT_CATV IS NOT INITIAL.
        DELETE MEAN_ME_TAB[] WHERE ( SGT_CATV NE *MEAN-SGT_CATV
                               AND   NUMTP    IS NOT INITIAL ).
      ENDIF.
    ENDIF.
  ENDFORM.
*&---------------------------------------------------------------------*
*& Module TC_MODIFY_SEG_V2 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE TC_MODIFY_SEG_MM OUTPUT.
** Call subroutine to modify the hide / disable segment field
  PERFORM MODIFY_TC_SEG_MM.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form MODIFY_TC_SEG_V2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
* Hide Segment field in the table control if the article is not        *
* segment relevant; Input disable the segment field if segment filter  *
* value is entered                                                     *
*----------------------------------------------------------------------*
FORM MODIFY_TC_SEG_MM .
* If Segment value filter is entered
    IF *MEAN-SGT_CATV IS NOT INITIAL.
      LOOP AT SCREEN.
* Disable Segment field in Table control
        IF SCREEN-GROUP1 = 'SG0'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
* If Material is not segment relevant
    ELSEIF MARA-SGT_COVSA IS INITIAL OR MARA-SGT_SCOPE <> 1 OR GV_EAN_REL IS INITIAL.
      LOOP AT SCREEN.
* Disable Segment field in Table control
        IF SCREEN-GROUP2 = 'SG1'.
          SCREEN-INVISIBLE = 1.
          SCREEN-INPUT     = 0.
          SCREEN-ACTIVE    = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.
ENDFORM.
