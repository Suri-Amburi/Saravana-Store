*----------------------------------------------------------------------*
*   INCLUDE LMGD1F2J                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  HELP_SMEINH_MESUB
*&---------------------------------------------------------------------*
*       jw/4.6A: F4-Hilfe für die untergeordnete Mengeneinheit
*----------------------------------------------------------------------*
*  -->  meinh
*----------------------------------------------------------------------*
FORM SMEINH_MESUB_HELP.

  DATA: BEGIN OF H_MEINH OCCURS 30,
           MEINH LIKE SMEINH-MEINH,
           TEXT  LIKE T006A-MSEHT.
  DATA  END   OF H_MEINH.

  DATA: WT006A LIKE T006A.

* H_MEINH aufbauen mit Texten
* Refresh nicht notwendig wegen Definition oben.
  LOOP AT MEINH.
    CALL FUNCTION 'ZUS_EAN_READ_DESCRIPTION'
         EXPORTING
              P_MEAN_MEINH = MEINH-MEINH
         IMPORTING
              WT006A       = WT006A    " T006A-MSEHT belegt
         EXCEPTIONS
              OTHERS       = 1.

    H_MEINH-MEINH = MEINH-MEINH.
    H_MEINH-TEXT  = WT006A-MSEHT.
    APPEND H_MEINH.
  ENDLOOP.

  SORT H_MEINH.

* Aufruf der F4-Hilfe

  HELP_TAB   = 'SMEINH'.
  HELP_FIELD = 'MESUB'.

  REFRESH H_FIELDS.
  H_FIELDS-TABNAME    = 'SMEINH'.
  H_FIELDS-FIELDNAME  = 'MESUB'.
  H_FIELDS-SELECTFLAG = X.
  APPEND H_FIELDS.
  H_FIELDS-TABNAME    = 'T006A'.
  H_FIELDS-FIELDNAME  = 'MSEHT'.
  H_FIELDS-SELECTFLAG = SPACE.
  APPEND H_FIELDS.

  REFRESH H_VALUES.
  LOOP AT H_MEINH.
    H_VALUES-VALUE = H_MEINH-MEINH.
    APPEND H_VALUES.
    H_VALUES-VALUE = H_MEINH-TEXT.
    APPEND H_VALUES.
  ENDLOOP.

  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
       EXPORTING
            CUCOL                     = 0
            CUROW                     = 0
            DISPLAY                   = SPACE
            FIELDNAME                 = HELP_FIELD
            TABNAME                   = HELP_TAB
       IMPORTING
            SELECT_VALUE              = SMEINH-MESUB
       TABLES
            FIELDS                    = H_FIELDS
            VALUETAB                  = H_VALUES
       EXCEPTIONS
            FIELD_NOT_IN_DDIC         = 01
            MORE_THEN_ONE_SELECTFIELD = 02
            NO_SELECTFIELD            = 03.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
       EXPORTING
            INPUT    = SMEINH-MESUB
            LANGUAGE = SY-LANGU
       IMPORTING
            OUTPUT   = SMEINH-MESUB.

ENDFORM.                               " SMEINH_MESUB_HELP






























