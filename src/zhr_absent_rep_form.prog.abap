*&---------------------------------------------------------------------*
*& Include          ZHR_ABSENT_REP_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

* rp_read_infotype pernr-pernr 0001 p0001 pn-begda pn-endda.
*rp_read_infotype pernr-pernr 0001 p0001 PYPERNR.


 ""pn-begda pn-endda.
* break breddy.
SELECT
  PERNR
  SNAME
  ENAME
  BEGDA from pa0001 into table it_pa0001
                    where begda in s_begda
                    and pernr   = pernr-pernr.""PYPERNR-low.

  IF it_pa0001 is not INITIAL.
    SELECT
      PERNR
      SUBTY
      KALTG
      ABWTG from pa2001 into table it_pa2001
                        FOR ALL ENTRIES IN it_pa0001
                        where pernr = it_pa0001-pernr.

  ENDIF.





ENDFORM.
*&---------------------------------------------------------------------*
*& Form LOOP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM LOOP_DATA .

  SORT P2001 BY PERNR ASCENDING PERNR.

  LOOP AT P2001 INTO P2001.

    SL = SL + 1.
    WA_FINAL-SL    = SL.
    WA_FINAL-ABWTG = P2001-ABWTG.
    READ TABLE P0001 INTO P0001 WITH KEY PERNR = P2001-PERNR.

    WA_FINAL-PERNR =  P0001-PERNR.     "Personnel number
    WA_FINAL-ENAME =  P0001-ENAME.     "Formatted Name of Employee or Applicant


    APPEND WA_FINAL TO IT_FINAL.
    CLEAR WA_FINAL.

  ENDLOOP .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELDCATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FIELDCATALOG .



  REFRESH IT_FIELDCAT.

  WA_FIELDCAT-FIELDNAME = 'SL'.
  WA_FIELDCAT-SELTEXT_M = text-001.                       "Personnel number
  wa_fieldcat-just = 'C'.
*  WA_FIELDCAT-EMPHASIZE = 'C1'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  clear WA_FIELDCAT.
*
*  wa_fieldcat-fieldname = 'PERNR'.
*  wa_fieldcat-seltext_m = 'Personnel number'.                       "Personnel number
*  wa_fieldcat-emphasize = 'C2'.
*  append wa_fieldcat to it_fieldcat.


  WA_FIELDCAT-FIELDNAME = 'ENAME'.
  WA_FIELDCAT-SELTEXT_M = text-002.
  wa_fieldcat-just = 'L'.                     "Employee Name
*  WA_FIELDCAT-EMPHASIZE = 'C2'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
 clear WA_FIELDCAT.

  WA_FIELDCAT-FIELDNAME = 'ABWTG'.
  WA_FIELDCAT-SELTEXT_L = text-003.
  wa_fieldcat-just = 'L'.
*  WA_FIELDCAT-EMPHASIZE = 'C5'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
clear WA_FIELDCAT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA .

  wa_layout-colwidth_optimize = 'X'.
  wa_layout-ZEBRA = 'X'.
  wa_layout-EXPAND_ALL = 'X'.

 CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
*    I_INTERFACE_CHECK                 = ' '
*    I_BYPASSING_BUFFER                = ' '
*    I_BUFFER_ACTIVE                   = ' '
*    I_CALLBACK_PROGRAM                = ' '
*    I_CALLBACK_PF_STATUS_SET          = ' '
*    I_CALLBACK_USER_COMMAND           = ' '
*    I_CALLBACK_TOP_OF_PAGE            = ' '
*    I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*    I_CALLBACK_HTML_END_OF_LIST       = ' '
*    I_STRUCTURE_NAME                  =
*    I_BACKGROUND_ID                   = ' '
*    I_GRID_TITLE                      =
*    I_GRID_SETTINGS                   =
    IS_LAYOUT                         = wa_layout
    IT_FIELDCAT                       = IT_FIELDCAT
*    IT_EXCLUDING                      =
*    IT_SPECIAL_GROUPS                 =
*    IT_SORT                           =
*    IT_FILTER                         =
*    IS_SEL_HIDE                       =
*    I_DEFAULT                         = 'X'
*    I_SAVE                            = ' '
*    IS_VARIANT                        =
*    IT_EVENTS                         =
*    IT_EVENT_EXIT                     =
*    IS_PRINT                          =
*    IS_REPREP_ID                      =
*    I_SCREEN_START_COLUMN             = 0
*    I_SCREEN_START_LINE               = 0
*    I_SCREEN_END_COLUMN               = 0
*    I_SCREEN_END_LINE                 = 0
*    I_HTML_HEIGHT_TOP                 = 0
*    I_HTML_HEIGHT_END                 = 0
*    IT_ALV_GRAPHICS                   =
*    IT_HYPERLINK                      =
*    IT_ADD_FIELDCAT                   =
*    IT_EXCEPT_QINFO                   =
*    IR_SALV_FULLSCREEN_ADAPTER        =
*  IMPORTING
*    E_EXIT_CAUSED_BY_CALLER           =
*    ES_EXIT_CAUSED_BY_USER            =
   TABLES
     T_OUTTAB                          = IT_FINAL
  EXCEPTIONS
    PROGRAM_ERROR                     = 1
    OTHERS                            = 2
           .
 IF SY-SUBRC <> 0.
* Implement suitable error handling here
 ENDIF.


**  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
**    EXPORTING
**     i_callback_program          = sy-repid
**     i_callback_html_top_of_page = 'TOP-OF-PAGE'
**      IT_FIELDCAT   = IT_FIELDCAT
**     it_sort       = i_sort
**    TABLES
**      T_OUTTAB      = IT_FINAL
**    EXCEPTIONS
**      PROGRAM_ERROR = 1
**      OTHERS        = 2.
**  IF SY-SUBRC <> 0.
** Implement suitable error handling here
**  ENDIF.

ENDFORM.
