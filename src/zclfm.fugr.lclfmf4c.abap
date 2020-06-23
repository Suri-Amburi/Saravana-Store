*&---------------------------------------------------------------------*
*&      Form  OK_CODE_VALUES
*&---------------------------------------------------------------------*
*       Process ok codes for characteristics subscreen.
*----------------------------------------------------------------------*
form ok_code_values using    i_fcode
                    changing e_fcode.


* ok-codes for characteristic subscreen are not
* in a DB table !

  e_fcode = space.
  check i_fcode <> okstat.        "processed in allocation part

  call function 'CTMS_DDB_EXECUTE_FUNCTION'
    exporting
      okcode = i_fcode
*      IMPORTING
*           RAISE_INVALID_OKCODE =
*           RAISE_INCONSISTENCY  =
*           RAISE_INCOMPLETE     =
*           RAISE_VERIFICATION   =
*           RAISE_NOT_ASSIGNED   =
*           RAISE_ANOTHER_OBJECT =
*           RAISE_OTHER_OBJECTS  =
*           RAISE_OTHERS         =
    exceptions
      others = 1.
  if sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

endform.                               " OK_CODE_VALUES
