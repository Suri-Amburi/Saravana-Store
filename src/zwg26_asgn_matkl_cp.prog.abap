*&---------------------------------------------------------------------*
*& Report ZWG26_ASGN_MATKL_CP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZWG26_ASGN_MATKL_CP MESSAGE-ID WW.
*--> Material Group Assignment to char.profile -> sjena <- 31.01.2020 13:09:57
*--> Functional_responsible ---> Chetan_Patil -> tech responsible sjena <- 31.01.2020 13:10:00
TYPES : BEGIN OF TY_DATA,
          MATKL  TYPE KLAH-CLASS,
          MCHPRF TYPE KLAH-CLASS,
        END OF TY_DATA,

        BEGIN OF TY_LOG,
          MATKL  TYPE MATKL,
          MCHPRF TYPE KLAH-CLASS,
          MSG    TYPE BAPI_MSG,
        END OF TY_LOG.

*--> gui_status ->
DATA: CURLINE     TYPE INT4, MAXLINE(10),
      PERC        TYPE INT4, TEXT TYPE TEXT100,
      LV_COUNT    TYPE INT4,
      LV_COUNT01  TYPE INT4.


DATA:  IT_TYPE  TYPE TRUXS_T_TEXT_DATA.
DATA : IT_LOG TYPE TABLE OF TY_LOG WITH HEADER LINE.
DATA: GT_DATA TYPE TABLE OF TY_DATA,
      WA_DATA TYPE TY_DATA.
"Selection Screen.
SELECTION-SCREEN : BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS P_FILE TYPE LOCALFILE OBLIGATORY.
SELECTION-SCREEN : END OF BLOCK B1 .

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      PROGRAM_NAME  = SYST-CPROG
      DYNPRO_NUMBER = SYST-DYNNR
      FIELD_NAME    = 'P_FILE'
    IMPORTING
      FILE_NAME     = P_FILE.

START-OF-SELECTION .

  PERFORM GET_DATA.

  CHECK GT_DATA IS NOT INITIAL.

  PERFORM ASGN_MATKL_CLS.

  CHECK IT_LOG[] IS NOT INITIAL.

  PERFORM DISPLAY_DATA.

*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR    =
      I_LINE_HEADER        = 'X'
      I_TAB_RAW_DATA       = IT_TYPE
      I_FILENAME           = P_FILE
    TABLES
      I_TAB_CONVERTED_DATA = GT_DATA
    EXCEPTIONS
      CONVERSION_FAILED    = 1
      OTHERS               = 2.

  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ELSE.
    DELETE GT_DATA INDEX 1.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ASGN_MATKL_CLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ASGN_MATKL_CLS .

  DATA  H_MODUS           VALUE ' '    LIKE WPSTRUC-MODUS.
  DATA  H_ANLEGEN         VALUE '1'    LIKE WPSTRUC-MODUS.
  DATA  H_AENDERN         VALUE '2'    LIKE WPSTRUC-MODUS.
  DATA  H_ANZEIGEN        VALUE '3'    LIKE WPSTRUC-MODUS.
  DATA  H_LOESCHEN        VALUE '4'    LIKE WPSTRUC-MODUS.
  DATA  H_UNDO            VALUE '5'    LIKE WPSTRUC-MODUS.

  DATA  G_CLASS  LIKE KLAH-CLASS.
  DATA  G_CLASS0 LIKE KLAH-CLASS.
  DATA  G_O_CLASS0 LIKE KLAH-CLASS.
  DATA  G_CLASS1 LIKE KLAH-CLASS.
  DATA  G_CLASS2 LIKE KLAH-CLASS.
  DATA  G_O_CLASS2 LIKE KLAH-CLASS.
  DATA  H_OLD_CLASS1 LIKE KLAH-CLASS.

  DATA  G_DESC1 LIKE SWOR-KSCHL.
  DATA  G_DESC2 LIKE SWOR-KSCHL.

  DATA  G_CLINT1 LIKE KLAH-CLINT.
  DATA  G_CLINT2 LIKE KLAH-CLINT.

  DATA  H_LOOPC      LIKE SY-LOOPC.
  DATA  G_LOOPC      LIKE SY-LOOPC.
  DATA  H_MERKMAL    LIKE SY-LOOPC.
  DATA  H_UPDATEFLAG LIKE RMCLK-UPDAT.
  DATA  H_NO_DELETE  LIKE WPSTRUC-MODUS.
  DATA  H_OKCODE     LIKE SY-UCOMM.
  DATA  H_NO_CHANGE  LIKE SY-BATCH.

  DATA  G_ART LIKE KLAH-KLART VALUE '026'.
  DATA  G_WWSKZ LIKE KLAH-WWSKZ VALUE ' '. " Übergabeparameter
  DATA  G_WWSKZW LIKE KLAH-WWSKZ VALUE '1'. " Kennzeichen Basiswarengruppe
  DATA  G_WWSKZB LIKE KLAH-WWSKZ VALUE '2'. " Kennzeichen Merkmalprofil

**  DATA: ZWGH LIKE KSSK-CLINT.
**  DATA: OWGH LIKE KLAH-CLINT.


  SELECT A~CLINT,A~CLASS,B~KLPOS, B~KSCHL FROM KLAH AS A
          INNER JOIN SWOR AS B ON ( B~CLINT = A~CLINT AND B~SPRAS = @SY-LANGU )
          INTO TABLE @DATA(GT_SWOR01) FOR ALL ENTRIES IN @GT_DATA
          WHERE A~KLART = '026' AND CLASS = @GT_DATA-MATKL.

  SELECT A~CLINT,A~CLASS,B~KLPOS, B~KSCHL FROM KLAH AS A
           INNER JOIN SWOR AS B ON ( B~CLINT = A~CLINT AND B~SPRAS = @SY-LANGU )
           INTO TABLE @DATA(GT_SWOR02) FOR ALL ENTRIES IN @GT_DATA
           WHERE A~KLART = '026' AND CLASS = @GT_DATA-MCHPRF.
  CHECK GT_SWOR01 IS NOT INITIAL AND GT_SWOR02 IS NOT INITIAL .

  MAXLINE = LINES( GT_DATA[] ) .
  LV_COUNT = MAXLINE / 10 .
  LV_COUNT01  = LV_COUNT .
***  CLEAR LV_COUNT .

  LOOP AT GT_DATA INTO DATA(GW_DATA).

    CURLINE = SY-TABIX.
    IF  CURLINE = LV_COUNT.
      ADD LV_COUNT01 TO LV_COUNT .
      TEXT = TEXT-002 .
      PERC = ( CURLINE * 100 ) / MAXLINE .
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          PERCENTAGE = PERC
          TEXT       = TEXT.
    ENDIF.

    READ TABLE GT_SWOR01 INTO DATA(GW_SWOR01) WITH KEY CLASS = GW_DATA-MATKL.
    IF SY-SUBRC IS INITIAL.
      G_CLASS1 = GW_SWOR01-CLASS.
      G_DESC1 = GW_SWOR01-KSCHL.
      G_CLINT1 = GW_SWOR01-CLINT.
    ENDIF.

    READ TABLE GT_SWOR02 INTO DATA(GW_SWOR02) WITH KEY CLASS = GW_DATA-MCHPRF.
    IF SY-SUBRC IS INITIAL.
      G_CLASS2 = GW_SWOR02-CLASS.
      G_DESC2 = GW_SWOR02-KSCHL.
      G_CLINT2 = GW_SWOR02-CLINT.
    ENDIF.

    SELECT SINGLE * FROM KSSK INTO @DATA(G_T_KSSK)
           WHERE CLINT = @G_CLINT1
           AND   OBJEK = @G_CLINT2.
    IF G_T_KSSK IS NOT INITIAL. "Assignment exists
      CLEAR : G_T_KSSK.
      H_OKCODE = 1.
      CONDENSE H_OKCODE NO-GAPS.
    ELSE.

      CHECK G_CLASS1 IS NOT INITIAL AND G_CLASS2 IS NOT INITIAL .
* AKTIVIERUNG GLOBALER PARAMETER FÜR FBAU C026_MODIFY_STRUCTURE_CLASSES
      CALL FUNCTION 'C026_SET_UPPER_CLASS_FOR_CP'
        EXPORTING
          UPPER_CLASS = G_CLASS1
        EXCEPTIONS
          OTHERS      = 1.
      IF SY-SUBRC = 0.
*
      ENDIF.

* Warengruppenhierarchiezuordnungen pflegen
      CLEAR H_UPDATEFLAG.
      CLEAR H_OKCODE.
      CALL FUNCTION 'ZCLFM_WWS_CLASSIFICATION'
        EXPORTING
          CLASS            = G_CLASS2
          CLASS_TEXT       = G_DESC2
          UPPER_CLASS      = G_CLASS1
          UPPER_CLINT      = G_CLINT1
          UPPER_CLASS_TEXT = G_DESC1
          STATUS           = H_ANLEGEN                 "Anlegen,Aendern,Löschen,Anzeigen
          NO_F11           = ' '
          WWS_CLASS_IND    = G_WWSKZB
        IMPORTING
          UPDATEFLAG       = H_UPDATEFLAG
          OKCODE           = H_OKCODE
        EXCEPTIONS
          OTHERS           = 1.

      IF SY-SUBRC = 0.
*
      ENDIF.
    ENDIF.
    MOVE-CORRESPONDING GW_DATA TO IT_LOG .
    CASE H_OKCODE.
      WHEN ' '.
        MESSAGE S074 WITH GW_DATA-MCHPRF GW_DATA-MATKL INTO IT_LOG-MSG .
        COMMIT WORK.
        CALL FUNCTION 'DEQUEUE_ALL'
          EXPORTING
            _SYNCHRON = 'X'.

***      WHEN .
      WHEN '1'.
        MESSAGE S011 WITH GW_DATA-MCHPRF GW_DATA-MATKL INTO IT_LOG-MSG .
      WHEN OTHERS.

        IT_LOG-MSG = 'Assignment Failed'.
    ENDCASE.
    APPEND IT_LOG.
  ENDLOOP.

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
  DATA: LO_DOCK  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
        LO_CONT  TYPE REF TO CL_GUI_CONTAINER,
        LO_ALV   TYPE REF TO CL_SALV_TABLE,
        LO_ALV01 TYPE REF TO CL_SALV_TABLE.
  CHECK LO_ALV IS INITIAL.
  TRY.
      CALL METHOD CL_SALV_TABLE=>FACTORY
*          EXPORTING
***            list_display   = if_salv_c_bool_sap=>false
***            r_container    = lo_cont
***            container_name = 'DOCK_CONT'
        IMPORTING
          R_SALV_TABLE = LO_ALV
        CHANGING
          T_TABLE      = IT_LOG[].

    CATCH CX_SALV_MSG .
  ENDTRY.

  DATA: LO_COLS TYPE REF TO CL_SALV_COLUMNS.
  LO_COLS = LO_ALV->GET_COLUMNS( ).

*    *   set the Column optimization
  LO_COLS->SET_OPTIMIZE( 'X' ).
*
*   Pf status
  DATA: LO_FUNCTIONS TYPE REF TO CL_SALV_FUNCTIONS_LIST.
  LO_FUNCTIONS = LO_ALV->GET_FUNCTIONS( ).
  LO_FUNCTIONS->SET_ALL( ABAP_TRUE ).

  DATA: LO_LAYOUT TYPE REF TO CL_SALV_LAYOUT,
*            lf_variant TYPE slis_vari,
        LS_KEY    TYPE SALV_S_LAYOUT_KEY.
*      GET layout object
  LO_LAYOUT = LO_ALV->GET_LAYOUT( ).
*   set Layout save restriction
*   1. Set Layout Key .. Unique key identifies the Differenet ALVs
  LS_KEY-REPORT = SY-REPID.
  LO_LAYOUT->SET_KEY( LS_KEY ).
*   2. Remove Save layout the restriction.
  LO_LAYOUT->SET_SAVE_RESTRICTION( CL_SALV_LAYOUT=>RESTRICT_NONE ).
*   OUTPUT DISPLAY
  LO_ALV->DISPLAY( ).

ENDFORM.
