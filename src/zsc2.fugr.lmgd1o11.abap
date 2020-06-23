*&---------------------------------------------------------------------*
*&      Module  TC_SET_INVISIBLE  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_SET_INVISIBLE OUTPUT.

*wk/4.0 f_tc has to be set to the relevant table control before
* this point
  IF FLG_TCFULL IS INITIAL.            " or <f_tc>-lines = 0.
*    <f_tc>-invisible = 'X'.
    LOOP AT <F_TC>-COLS INTO TC_COL.
      TC_COL-INVISIBLE = CX_TRUE.
      MODIFY <F_TC>-COLS FROM TC_COL.
    ENDLOOP.
  ELSE.
*   note 1358288: columns in TC_VIEW are now set already before
*     <F_TC>-INVISIBLE = CX_FALSE.
*     LOOP AT <F_TC>-COLS INTO TC_COL.
*       IF TC_COL-INVISIBLE = CX_TRUE.
*         TC_COL-INVISIBLE = CX_FALSE.
*         MODIFY <F_TC>-COLS FROM TC_COL.
*       ENDIF.
*     ENDLOOP.

  ENDIF.
  ASSIGN TC_DUMMY TO <F_TC>.
  FLG_TCFULL = ' '.

ENDMODULE.                             " TC_SET_INVISIBLE  OUTPUT
