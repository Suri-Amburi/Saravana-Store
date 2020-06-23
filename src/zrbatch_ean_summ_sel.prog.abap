*&---------------------------------------------------------------------*
*& Include          ZRBATCH_EAN_SUMM_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
*  SELECT-OPTIONS : s_plant FOR gv_plant NO INTERVALS." OBLIGATORY.
  PARAMETERS : s_plant TYPE WERKS_D ."AS LISTBOX VISIBLE LENGTH 20.
  SELECT-OPTIONS :  S_DATE FOR LV_DATE DEFAULT sy-datum.."OBLIGATORY DEFAULT sy-datum..
  SELECTION-SCREEN : END OF BLOCK b1 .
* BREAK CLIKHITHA.
*  AT SELECTION-SCREEN OUTPUT.
**    BREAK CLIKHITHA.
*    SELECT WERKS FROM T001W INTO TABLE IT_PLANT.
*      LOOP AT IT_PLANT INTO WA_PLANT.
*        WA_VALUES-KEY = WA_PLANT-WERKS.
*        WA_VALUES-TEXT = WA_PLANT-WERKS.
*        APPEND WA_VALUES TO IT_VALUES.
*        CLEAR : WA_VALUES.
*        ENDLOOP.
*        G_ID = 'S_PLANT'.
*
*        CALL FUNCTION 'VRM_SET_VALUES'
*          EXPORTING
*            ID                    = G_ID
*            VALUES                = IT_VALUES
*         EXCEPTIONS
*           ID_ILLEGAL_NAME       = 1
*           OTHERS                = 2
*                  .
*        IF SY-SUBRC <> 0.
** Implement suitable error handling here
*        ENDIF.
