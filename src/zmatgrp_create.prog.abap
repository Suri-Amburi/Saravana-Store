REPORT ZMATGRP_CREATE
       NO STANDARD PAGE HEADING LINE-SIZE 255.


INCLUDE ZMATGRP_CREATE_TOP.
INCLUDE ZMATGRP_CREATE_SCREEN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM GET_FILENAME CHANGING P_FILE.

AT SELECTION-SCREEN ON P_FILE.
  PERFORM CHECK_FILE_PATH.

*AT SELECTION-SCREEN.
*  PERFORM SET_BACKGROUND_JOB.

START-OF-SELECTION.
*  IF PV_BG = 'X'.
*    LEAVE LIST-PROCESSING.
*  ENDIF.

  INCLUDE ZMATGRP_CREATE_ROUTINE.
  INCLUDE ZMATGRP_CREATE_SUBFORMS.
