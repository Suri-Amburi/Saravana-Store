*&---------------------------------------------------------------------*
*& Include          ZFI_PURCH_REG_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-003.
PARAMETERS: r1 RADIOBUTTON GROUP rb1 USER-COMMAND flg,
            r2 RADIOBUTTON GROUP rb1 DEFAULT 'X',
            r3 RADIOBUTTON GROUP rb1 .

SELECT-OPTIONS: s_werks FOR lv_werks OBLIGATORY,
                s_gsber FOR lv_gsber ."NO-EXTENSION NO INTERVALS.

SELECT-OPTIONS: s_bukrs FOR lv_bukrs   NO-EXTENSION NO INTERVALS,
                s_gjahr FOR lv_gjahr   NO-EXTENSION NO INTERVALS,
                s_budat FOR lv_budat   OBLIGATORY,
                s_lifnr FOR ekko-lifnr." NO-DISPLAY,   "No direct_input_available_for_vendor


SELECTION-SCREEN: END OF BLOCK b1.

AT SELECTION-SCREEN OUTPUT.
* Check what radiobutton is selected
* With PO
  IF r1 = 'X' or r3 = 'X'.
    LOOP AT SCREEN.
      IF screen-name = 'S_WERKS' OR

             screen-name = '%_S_WERKS_%_APP_%-TEXT' OR
             screen-name = '%_S_WERKS_%_APP_%-OPTI_PUSH' OR
             screen-name = 'S_WERKS-LOW' OR
             screen-name = '%_S_WERKS_%_APP_%-TO_TEXT' OR
             screen-name = 'S_WERKS-HIGH' OR
             screen-name = '%_S_WERKS_%_APP_%-VALU_PUSH'.
        screen-invisible = '0'.
        screen-input     = '1'.
        MODIFY SCREEN.
      ELSEIF screen-name = 'S_GSBER' OR
              screen-name = '%_S_GSBER_%_APP_%-TEXT' OR
             screen-name = '%_S_GSBER_%_APP_%-OPTI_PUSH' OR
             screen-name = 'S_GSBER-LOW' OR
             screen-name = '%_S_GSBER_%_APP_%-TO_TEXT' OR
             screen-name = 'S_GSBER-HIGH' OR
             screen-name = '%_S_GSBER_%_APP_%-VALU_PUSH'.
        screen-invisible = '1'.
        screen-input     = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
* Without PO
  ELSE.
    LOOP AT SCREEN.
      IF screen-name     = 'S_GSBER' OR
        screen-name      = '%_S_GSBER_%_APP_%-TEXT' OR
        screen-name      = '%_S_GSBER_%_APP_%-OPTI_PUSH' OR
        screen-name      = 'S_GSBER-LOW' OR
        screen-name      = '%_S_GSBER_%_APP_%-TO_TEXT' OR
        screen-name      = 'S_GSBER-HIGH' OR
        screen-name      = '%_S_GSBER_%_APP_%-VALU_PUSH'.
        screen-invisible = '0'.
        screen-input     = '1'.
        MODIFY SCREEN.
      ELSEIF screen-name = 'S_WERKS' OR
        screen-name      = '%_S_WERKS_%_APP_%-TEXT' OR
        screen-name      = '%_S_WERKS_%_APP_%-OPTI_PUSH' OR
        screen-name      = 'S_WERKS-LOW' OR
        screen-name      = '%_S_WERKS_%_APP_%-TO_TEXT' OR
        screen-name      = 'S_WERKS-HIGH' OR
        screen-name      = '%_S_WERKS_%_APP_%-VALU_PUSH'.
        screen-invisible = '1'.
        screen-input     = '0'.
        MODIFY SCREEN.
        ENDIF.
    ENDLOOP.
  ENDIF.
