*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZSAPMP_MM_PO_CREATE_F01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
 FORM USER_OK_TC USING    P_TC_NAME TYPE DYNFNAM
                          P_TABLE_NAME
                          P_MARK_NAME
                 CHANGING P_OK      LIKE SY-UCOMM.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA: L_OK     TYPE SY-UCOMM,
         L_OFFSET TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
   SEARCH P_OK FOR P_TC_NAME.
   IF SY-SUBRC <> 0.
     EXIT.
   ENDIF.
   L_OFFSET = STRLEN( P_TC_NAME ) + 1.
   L_OK = P_OK+L_OFFSET.
*&SPWIZARD: execute general and TC specific operations                 *
   CASE L_OK.
     WHEN 'INSR'.                      "insert row
       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
                                         P_TABLE_NAME.
       CLEAR P_OK.

     WHEN 'DELE'.                      "delete row
       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
                                         P_TABLE_NAME
                                         P_MARK_NAME.
       CLEAR P_OK.

     WHEN 'P--' OR                     "top of list
          'P-'  OR                     "previous page
          'P+'  OR                     "next page
          'P++'.                       "bottom of list
       PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                             L_OK.
       CLEAR P_OK.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
     WHEN 'MARK'.                      "mark all filled lines
       PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                         P_TABLE_NAME
                                         P_MARK_NAME   .
       CLEAR P_OK.

     WHEN 'DMRK'.                      "demark all filled lines
       PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                           P_TABLE_NAME
                                           P_MARK_NAME .
       CLEAR P_OK.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

   ENDCASE.

 ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
 FORM FCODE_INSERT_ROW
               USING    P_TC_NAME           TYPE DYNFNAM
                        P_TABLE_NAME             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA L_LINES_NAME       LIKE FELD-NAME.
   DATA L_SELLINE          LIKE SY-STEPL.
   DATA L_LASTLINE         TYPE I.
   DATA L_LINE             TYPE I.
   DATA L_TABLE_NAME       LIKE FELD-NAME.
   FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
   FIELD-SYMBOLS <LINES>              TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
   ASSIGN (L_LINES_NAME) TO <LINES>.

*&SPWIZARD: get current line                                           *
   GET CURSOR LINE L_SELLINE.
   IF SY-SUBRC <> 0.                   " append line to table
     L_SELLINE = <TC>-LINES + 1.
*&SPWIZARD: set top line                                               *
     IF L_SELLINE > <LINES>.
       <TC>-TOP_LINE = L_SELLINE - <LINES> + 1 .
     ELSE.
       <TC>-TOP_LINE = 1.
     ENDIF.
   ELSE.                               " insert line into table
     L_SELLINE = <TC>-TOP_LINE + L_SELLINE - 1.
     L_LASTLINE = <TC>-TOP_LINE + <LINES> - 1.
   ENDIF.
*&SPWIZARD: set new cursor line                                        *
   L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.

*&SPWIZARD: insert initial line                                        *
   INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
   <TC>-LINES = <TC>-LINES + 1.
*&SPWIZARD: set cursor                                                 *
   SET CURSOR LINE L_LINE.

 ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
 FORM FCODE_DELETE_ROW
               USING    P_TC_NAME           TYPE DYNFNAM
                        P_TABLE_NAME
                        P_MARK_NAME   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA L_TABLE_NAME       LIKE FELD-NAME.

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <WA>.
   FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
   DESCRIBE TABLE <TABLE> LINES <TC>-LINES.

   LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

     IF <MARK_FIELD> = 'X'.
       DELETE <TABLE> INDEX SYST-TABIX.
       IF SY-SUBRC = 0.
         <TC>-LINES = <TC>-LINES - 1.
       ENDIF.
     ENDIF.
   ENDLOOP.

 ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
 FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
                                       P_OK.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA L_TC_NEW_TOP_LINE     TYPE I.
   DATA L_TC_NAME             LIKE FELD-NAME.
   DATA L_TC_LINES_NAME       LIKE FELD-NAME.
   DATA L_TC_FIELD_NAME       LIKE FELD-NAME.

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <LINES>      TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.
*&SPWIZARD: get looplines of TableControl                              *
   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
   ASSIGN (L_TC_LINES_NAME) TO <LINES>.


*&SPWIZARD: is no line filled?                                         *
   IF <TC>-LINES = 0.
*&SPWIZARD: yes, ...                                                   *
     L_TC_NEW_TOP_LINE = 1.
   ELSE.
*&SPWIZARD: no, ...                                                    *
     CALL FUNCTION 'SCROLLING_IN_TABLE'
       EXPORTING
         ENTRY_ACT      = <TC>-TOP_LINE
         ENTRY_FROM     = 1
         ENTRY_TO       = <TC>-LINES
         LAST_PAGE_FULL = 'X'
         LOOPS          = <LINES>
         OK_CODE        = P_OK
         OVERLAPPING    = 'X'
       IMPORTING
         ENTRY_NEW      = L_TC_NEW_TOP_LINE
       EXCEPTIONS
*        NO_ENTRY_OR_PAGE_ACT  = 01
*        NO_ENTRY_TO    = 02
*        NO_OK_CODE_OR_PAGE_GO = 03
         OTHERS         = 0.
   ENDIF.

*&SPWIZARD: get actual tc and column                                   *
   GET CURSOR FIELD L_TC_FIELD_NAME
              AREA  L_TC_NAME.

   IF SYST-SUBRC = 0.
     IF L_TC_NAME = P_TC_NAME.
*&SPWIZARD: et actual column                                           *
       SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
     ENDIF.
   ENDIF.

*&SPWIZARD: set the new top line                                       *
   <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.


 ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 FORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                P_TABLE_NAME
                                P_MARK_NAME.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
   DATA L_TABLE_NAME       LIKE FELD-NAME.

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <WA>.
   FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
   LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

     <MARK_FIELD> = 'X'.
   ENDLOOP.
 ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                  P_TABLE_NAME
                                  P_MARK_NAME .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA L_TABLE_NAME       LIKE FELD-NAME.

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <WA>.
   FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
   LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

     <MARK_FIELD> = SPACE.
   ENDLOOP.
 ENDFORM.                                          "fcode_tc_mark_lines
*&----------------------------------------------------------------*
*& Form CLEAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
 FORM CLEAR .
*
*  IF wa_header-site is not INITIAL .
*    CLEAR : wa_header-site.
*  ENDIF.

 ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  VALID_MATKL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE VALID_MATKL INPUT.
*BREAK-POINT.
   IF WA_ITEM-MATKL IS NOT INITIAL . " AND WA_ITEM-MATNR IS INITIAL .

     IF WA_ITEM-SL_NO IS  INITIAL .
       IT_ITEM1[] = IT_ITEM .
       SORT IT_ITEM1 DESCENDING BY SL_NO .
       READ TABLE IT_ITEM1 INTO WA_ITEM1 INDEX 1.
       WA_ITEM-SL_NO = WA_ITEM1-SL_NO + 10 .
*       APPEND wa_item to it_item.
     ENDIF.
*  MODIFY wa_item INDEX tc1-current_line.
     READ TABLE IT_MARA INTO WA_MARA WITH KEY MATKL = WA_ITEM-MATKL.
     IF SY-SUBRC = 0.
*         WA_ITEM-MATKL = WA_MARA-MATKL .
       WA_ITEM-MEINS = WA_MARA-MEINS.
*         MODIFY IT_ITEM FROM WA_ITEM TRANSPORTING SL_NO
*                                                  MATKL
*                                                  MEINS  WHERE SL_NO = WA_ITEM-SL_NO .
     ENDIF.

*     CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
*       EXPORTING
*         MATKL             = wa_item-matkl
*        SPRAS             = SY-LANGU
*       TABLES
*         O_WGH01           = it_whg01
*      EXCEPTIONS
*        NO_BASIS_MG       = 1
*        NO_MG_HIER        = 2
*        OTHERS            = 3
*               .
*     IF SY-SUBRC <> 0.
** Implement suitable error handling here
*     ENDIF.



   ENDIF.

*   CLEAR WA_ITEM .

 ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALID_MATNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE VALID_MATNR INPUT.
*   BREAK-POINT.
   CLEAR WA_ITEM-MAKTX .
   IF WA_ITEM-MATNR IS NOT INITIAL .
*     IF WA_ITEM-MATKL IS INITIAL .
     IF WA_ITEM-SL_NO IS  INITIAL .
       IT_ITEM1[] = IT_ITEM .
       SORT IT_ITEM1 DESCENDING BY SL_NO .
       READ TABLE IT_ITEM1 INTO WA_ITEM1 INDEX 1.
       WA_ITEM-SL_NO = WA_ITEM1-SL_NO + 10 .
*       APPEND wa_item to it_item.
     ENDIF.
*     BREAK-POINT.
     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
       EXPORTING
         INPUT  = WA_ITEM-MATNR
       IMPORTING
         OUTPUT = WA_ITEM-MATNR.


     READ TABLE IT_MAKT INTO WA_MAKT WITH KEY MATNR = WA_ITEM-MATNR SPRAS = SY-LANGU.
     IF SY-SUBRC = 0 .
       WA_ITEM-MAKTX = WA_MAKT-MAKTX .
     ELSE .
       CLEAR : WA_ITEM-MAKTX .
     ENDIF.

     CLEAR WA_ITEM-GST% .
     READ TABLE  IT_MARC INTO WA_MARC WITH KEY MATNR = WA_ITEM-MATNR WERKS = WA_HEADER-SITE .
     IF SY-SUBRC = 0 .
       WA_ITEM-STEUC = WA_MARC-STEUC .
       LOOP AT IT_A900 INTO WA_A900 WHERE STEUC = WA_ITEM-STEUC.
         READ TABLE IT_KONP INTO WA_KONP WITH KEY KNUMH = WA_A900-KNUMH.
         IF SY-SUBRC = 0.
           LV_% = WA_KONP-KBETR / 10 .
           WA_ITEM-GST% = WA_ITEM-GST% + LV_% .
         ENDIF.
       ENDLOOP.
     ELSE .
       CLEAR : WA_ITEM-STEUC , WA_ITEM-GST% .
     ENDIF.
*     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*       EXPORTING
*         INPUT         = wa_item-matnr
*      IMPORTING
*        OUTPUT        = wa_item-matnr
*               .
*       IF WA_ITEM-MATKL IS INITIAL .
     READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_ITEM-MATNR .
     IF SY-SUBRC = 0.
       WA_ITEM-MATKL = WA_MARA-MATKL .
       WA_ITEM-MEINS = WA_MARA-MEINS.
*         MODIFY IT_ITEM FROM WA_ITEM TRANSPORTING SL_NO
*                                                  MATNR
*                                                  MAKTX
*                                                  MATKL
*                                                  MEINS  WHERE SL_NO = WA_ITEM-SL_NO .
     ELSE .
       CLEAR : WA_ITEM-MATKL , WA_ITEM-MEINS .
     ENDIF.
*BREAK-POINT.
     CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
       EXPORTING
         MATKL       = WA_ITEM-MATKL
         SPRAS       = SY-LANGU
       TABLES
         O_WGH01     = IT_WHG01
       EXCEPTIONS
         NO_BASIS_MG = 1
         NO_MG_HIER  = 2
         OTHERS      = 3.
     IF SY-SUBRC <> 0.
* Implement suitable error handling here
     ENDIF.
     READ TABLE IT_WHG01 INDEX 1 .
     WA_ITEM-PARENT_CODE = IT_WHG01-WWGHA .
* Implement suitable error handling here
   ELSE.
     CLEAR WA_ITEM-MAKTX.
   ENDIF.

*     ENDIF.

*ELSE .
*  CLEAR WA_ITEM-MAKTX .
*   ENDIF.

*ENDIF.


*       ENDIF.
*     ELSE.
*       READ TABLE IT_MAKT INTO WA_MAKT WITH KEY MATNR = WA_ITEM-MATNR SPRAS = 'EN'.
*       IF SY-SUBRC = 0 .
*         WA_ITEM-MAKTX = WA_MAKT-MAKTX .
*       ENDIF.
*          READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_ITEM-MATNR .
*         IF SY-SUBRC = 0.
**           WA_ITEM-MATKL = WA_MARA-MATKL .
*           WA_ITEM-MEINS = WA_MARA-MEINS.
*        endIF.
*     ENDIF.





* MODIFY it_item from wa_item index tc1-current_line.
*   ENDIF.
*   CLEAR  WA_ITEM.
 ENDMODULE.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
 FORM GET_DATA .
*   BREAK-POINT.
*   wa_header-AEDAT = sy-datum .
   SELECT MATNR
         SPRAS
         MAKTX
         FROM MAKT INTO TABLE IT_MAKT .
   IF IT_MAKT IS NOT INITIAL .
     SELECT MATNR
             MATKL
             MEINS FROM MARA INTO TABLE IT_MARA
             FOR ALL ENTRIES IN IT_MAKT
             WHERE MATNR = IT_MAKT-MATNR .
     SELECT MATNR
            WERKS
            STEUC FROM MARC INTO TABLE IT_MARC
            FOR ALL ENTRIES IN IT_MAKT
            WHERE MATNR = IT_MAKT-MATNR .

   ENDIF.

   IF IT_MARC IS NOT INITIAL .
     SELECT KAPPL
            KSCHL
            WKREG
            REGIO
            TAXK1
            TAXM1
            STEUC
            KFRST
            DATBI
            DATAB
            KBSTAT
            KNUMH FROM A900 INTO TABLE IT_A900
          FOR ALL ENTRIES IN IT_MARC
          WHERE STEUC = IT_MARC-STEUC
          AND DATBI GE SY-DATUM .
   ENDIF.

   IF IT_A900 IS NOT INITIAL.
     SELECT KNUMH
            KOPOS
            KBETR FROM KONP INTO TABLE IT_KONP
           FOR ALL ENTRIES IN IT_A900
       WHERE KNUMH = IT_A900-KNUMH.
   ENDIF.


*   LOOP AT  IT_MAKT INTO WA_MAKT .
*     SHIFT WA_MAKT-MATNR LEFT DELETING LEADING '0'.
*     MODIFY IT_MAKT FROM WA_MAKT .
*   ENDLOOP.

*   LOOP AT  IT_MARA  INTO WA_MARA .
*     SHIFT WA_MARA-MATNR LEFT DELETING LEADING '0'.
*     MODIFY IT_MARA FROM WA_MARA .
*   ENDLOOP.

 ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_FST  INPU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE UPDATE_FST INPUT.
*  BREAK-POINT .
**   IF WA_ITEM-MATKL IS NOT INITIAL AND WA_ITEM-MATNR IS INITIAL .
**
**
**     IF WA_ITEM-SL_NO IS  INITIAL .
**       it_item1[] = it_item .
**       SORT IT_ITEM1 DESCENDING BY SL_NO .
**       READ TABLE IT_ITEM1 INTO WA_ITEM1 INDEX 1.
**       WA_ITEM-SL_NO =  WA_ITEM1-SL_NO + 10 .
**       APPEND wa_item to it_item.
**     ENDIF.
**  MODIFY wa_item INDEX tc1-current_line.
**     READ TABLE IT_MARA INTO WA_MARA WITH KEY MATKL = WA_ITEM-MATKL.
**     IF SY-SUBRC = 0.
**         WA_ITEM-MATKL = WA_MARA-MATKL .
**       WA_ITEM-MEINS = WA_MARA-MEINS.
**         MODIFY IT_ITEM FROM WA_ITEM TRANSPORTING SL_NO
**                                                  MATKL
**                                                  MEINS  WHERE SL_NO = WA_ITEM-SL_NO .
**     ENDIF.
   IF IT_ITEM IS INITIAL.
     APPEND WA_ITEM TO IT_ITEM.
   ENDIF.



*
*   ENDIF.
*   MODIFY IT_ITEM
*     FROM WA_ITEM
*     INDEX TC1-CURRENT_LINE.


 ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALID_STEUC  INPUT
*&---------------------------------------------------------------------*
*       text

*&---------------------------------------------------------------------*
*&      Module  VALID_MENGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE VALID_MENGE INPUT.
   IF WA_ITEM-MENGE IS NOT INITIAL .


   ENDIF.

 ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALID_NETPR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE VALID_NETPR INPUT.

   IF WA_ITEM-NETPR IS NOT INITIAL AND WA_ITEM-MENGE IS NOT INITIAL .
     WA_ITEM-GST = ( WA_ITEM-NETPR * WA_ITEM-MENGE ) * WA_ITEM-GST% / 100 .

     WA_ITEM-AMOUNT = ( WA_ITEM-NETPR * WA_ITEM-MENGE ) + WA_ITEM-GST .
   ENDIF.
   SORT IT_ITEM BY SL_NO .
 ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SEARCH_HELP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE SEARCH_HELP INPUT.


   READ TABLE IT_ITEM INTO WA_ITEM INDEX TC1-CURRENT_LINE .
   CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
     EXPORTING
       MATKL       = WA_ITEM-MATKL
       SPRAS       = SY-LANGU
     TABLES
       O_WGH01     = IT_WHG01
     EXCEPTIONS
       NO_BASIS_MG = 1
       NO_MG_HIER  = 2
       OTHERS      = 3.
   IF SY-SUBRC <> 0.
* Implement suitable error handling here
   ENDIF.



   CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
     EXPORTING
*      DDIC_STRUCTURE  = ' '
       RETFIELD        = 'WWGHA'
*      PVALKEY         = ' '
       DYNPPROG        = SY-CPROG
       DYNPNR          = SY-DYNNR
       DYNPROFIELD     = 'WA_ITEM-PARENT_CODE'
*      STEPL           = 0
*      WINDOW_TITLE    =
*      VALUE           = ' '
       VALUE_ORG       = 'S'
*      MULTIPLE_CHOICE = ' '
*      DISPLAY         = ' '
*      CALLBACK_PROGRAM       = ' '
*      CALLBACK_FORM   = ' '
*      CALLBACK_METHOD =
*      MARK_TAB        =
*     IMPORTING
*      USER_RESET      =
     TABLES
       VALUE_TAB       = IT_WHG01
*      FIELD_TAB       =
*      RETURN_TAB      =
*      DYNPFLD_MAPPING =
     EXCEPTIONS
       PARAMETER_ERROR = 1
       NO_VALUES_FOUND = 2
       OTHERS          = 3.
   IF  SY-SUBRC <> 0.
* Implement suitable error handling here
   ENDIF.

 ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SEARCH_HELP1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE SEARCH_HELP1 INPUT.
   CLEAR WA_ITEM-MATKL.
   READ TABLE IT_ITEM INTO WA_ITEM INDEX TC1-CURRENT_LINE .

   SELECT MARA~MATNR MARA~MATKL MAKT~MAKTX INTO TABLE IT_ITAB FROM
       MARA AS MARA INNER JOIN
       MAKT AS MAKT ON
       MARA~MATNR = MAKT~MATNR
       FOR ALL ENTRIES IN IT_MAKT
       WHERE MAKT~MATNR = IT_MAKT-MATNR.

   IF WA_ITEM-MATKL IS INITIAL .

     CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
*        DDIC_STRUCTURE  = ' '
         RETFIELD        = 'MATNR'
*        PVALKEY         = ' '
         DYNPPROG        = SY-CPROG
         DYNPNR          = SY-DYNNR
         DYNPROFIELD     = 'WA_ITEM-MATNR'
*        STEPL           = 0
*        WINDOW_TITLE    =
*        VALUE           = ' '
         VALUE_ORG       = 'S'
*        MULTIPLE_CHOICE = ' '
*        DISPLAY         = ' '
*        CALLBACK_PROGRAM       = ' '
*        CALLBACK_FORM   = ' '
*        CALLBACK_METHOD =
*        MARK_TAB        =
*     IMPORTING
*        USER_RESET      =
       TABLES
         VALUE_TAB       = IT_ITAB
*        FIELD_TAB       =
*        RETURN_TAB      =
*        DYNPFLD_MAPPING =
       EXCEPTIONS
         PARAMETER_ERROR = 1
         NO_VALUES_FOUND = 2
         OTHERS          = 3.
     IF  SY-SUBRC <> 0.

     ELSE.
       READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_ITEM-MATNR .
       IF SY-SUBRC = 0  .
         WA_ITEM-MATKL = WA_MARA-MATKL .
         CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
           EXPORTING
             MATKL       = WA_ITEM-MATKL
             SPRAS       = SY-LANGU
           TABLES
             O_WGH01     = IT_WHG01
           EXCEPTIONS
             NO_BASIS_MG = 1
             NO_MG_HIER  = 2
             OTHERS      = 3.
         IF SY-SUBRC <> 0.
* Implement suitable error handling here
         ENDIF.
         READ TABLE IT_WHG01 INDEX 1 .
         WA_ITEM-PARENT_CODE = IT_WHG01-WWGHA .
* Implement suitable error handling here


       ELSE .
         CLEAR : WA_ITEM-MATKL , WA_ITEM-PARENT_CODE .
       ENDIF.
     ENDIF.
*READ TABLE IT_ITEM INTO WA_ITEM INDEX TC1-CURRENT_LINE .

   ELSE.

*     SELECT MATNR
*          MATKL
*          MEINS FROM MARA INTO TABLE IT_MARA1
*          WHERE MATKL = WA_ITEM-MATKL .
     IT_ITAB1 = IT_ITAB .
     DELETE IT_ITAB1 WHERE MATKL <> WA_ITEM-MATKL .

     CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
*        DDIC_STRUCTURE  = ' '
         RETFIELD        = 'MATNR'
*        PVALKEY         = ' '
         DYNPPROG        = SY-CPROG
         DYNPNR          = SY-DYNNR
         DYNPROFIELD     = 'WA_ITEM-MATNR'
*        STEPL           = 0
*        WINDOW_TITLE    =
*        VALUE           = ' '
         VALUE_ORG       = 'S'
*        MULTIPLE_CHOICE = ' '
*        DISPLAY         = ' '
*        CALLBACK_PROGRAM       = ' '
*        CALLBACK_FORM   = ' '
*        CALLBACK_METHOD =
*        MARK_TAB        =
*     IMPORTING
*        USER_RESET      =
       TABLES
         VALUE_TAB       = IT_ITAB1
*        FIELD_TAB       =
*        RETURN_TAB      =
*        DYNPFLD_MAPPING =
       EXCEPTIONS
         PARAMETER_ERROR = 1
         NO_VALUES_FOUND = 2
         OTHERS          = 3.
     IF  SY-SUBRC <> 0 .

     ENDIF.

   ENDIF.


 ENDMODULE.
*&---------------------------------------------------------------------*
*& Form BAPI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
 FORM BAPI .


   IF LV_EBELN IS INITIAL .



     HEADER-COMP_CODE = WA_T001K-BUKRS . "'1000'.
     HEADER-CREAT_DATE = WA_HEADER-AEDAT .
     HEADER-VENDOR = WA_HEADER-LIFNR .
     HEADER-DOC_TYPE = 'ZDOM' .
     HEADER-LANGU = SY-LANGU .
     HEADER-PURCH_ORG = WA_T001W-EKORG  .
     HEADER-PUR_GROUP =  WA_HEADER-EKGRP . "'001' .

     HEADERX-COMP_CODE =  'X'.
     HEADERX-CREAT_DATE = 'X'.
     HEADERX-VENDOR = 'X'.
     HEADERX-DOC_TYPE = 'X' .
     HEADERX-LANGU = 'X' .
     HEADERX-PURCH_ORG = 'X' .
     HEADERX-PUR_GROUP = 'X'.
*
*     it1_bapi_poheader-agent_name = wa_header-agent_name .
*it1_bapi_poheaderx-agent_name = 'X'.
*
*wa_extensionin-structure = 'BAPI_TE_MEPOHEADER'.
*wa_extensionin-valuepart1 = it1_bapi_poheader.
*append wa_extensionin to it_extensionin.
*Clear  wa_extensionin.
*
*wa_extensionin-structure = 'BAPI_TE_MEPOHEADERX'.
*wa_extensionin-valuepart1 = it1_bapi_poheaderx.
*
*append wa_extensionin to it_extensionin.
*Clear  wa_extensionin.


*BREAK-POINT.
REFRESH item .
REFRESH itemX .
     LOOP AT IT_ITEM INTO WA_ITEM WHERE MATNR IS NOT INITIAL .
       ITEM-PO_ITEM = WA_ITEM-SL_NO .

       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
           INPUT  = WA_ITEM-MATNR
         IMPORTING
           OUTPUT = WA_ITEM-MATNR.



       ITEM-MATERIAL = WA_ITEM-MATNR .
       ITEM-PLANT = WA_HEADER-SITE.
       ITEM-MATL_GROUP = WA_ITEM-MATKL.
       ITEM-QUANTITY = WA_ITEM-MENGE.
       ITEM-PO_UNIT = WA_ITEM-MEINS .
       ITEM-NET_PRICE = WA_ITEM-NETPR.
       ITEM-STGE_LOC = WA_HEADER-LGORT .


       ITEMX-PO_ITEM = WA_ITEM-SL_NO.
       ITEMX-MATERIAL = 'X'.
       ITEMX-PLANT = 'X'.
       ITEMX-MATL_GROUP = 'X'.
       ITEMX-QUANTITY = 'X'.
       ITEMX-PO_UNIT = 'X'.
       ITEMX-NET_PRICE = 'X'.
       ITEMX-STGE_LOC = 'X'.
       APPEND ITEM.
       CLEAR item .
       APPEND ITEMX .
       CLEAR itemx.

*      POSCHEDULE-po_item = wa_item-sl_no.
*      POSCHEDULE-sched_line = '001'.
*      POSCHEDULE-del_datcat_ext = 'X'.
*      POSCHEDULE-delivery_date = wa_header-AEDAT1 .
*      POSCHEDULE-quantity = wa_item-menge.
*      APPEND POSCHEDULE.
*
*     poschedulex-po_item = wa_item-sl_no.
*     poschedulex-sched_line = '001'.
*     poschedulex-po_itemx = 'X'.
*     poschedulex-sched_linex = 'X'.
*     poschedulex-del_datcat_ext = 'X'.
*     poschedulex-delivery_date = 'X'.
*     poschedulex-quantity = 'X'.
*     poschedulex-deliv_time = 'X'.
*     poschedulex-stat_date = 'X'.
*      APPEND poschedulex.


     ENDLOOP.
*
* it1_bapi_poheader-agent_name = wa_header-agent_name.
*it1_bapi_poheaderx-agent_name = 'X'.
*
*
*it_extensionin-structure = 'BAPI_TE_MEPOHEADER'.
*it_extensionin-valuepart1 = it1_bapi_poheader.
*append it_extensionin.
*Clear  it_extensionin.
*
*it_extensionin-structure = 'BAPI_TE_MEPOHEADERX'.
*it_extensionin-valuepart1 = it1_bapi_poheaderx.
*
*append it_extensionin.
*Clear  it_extensionin.

     CALL FUNCTION 'BAPI_PO_CREATE1'
       EXPORTING
         POHEADER         = HEADER
         POHEADERX        = HEADERX
*        POADDRVENDOR     =
*        TESTRUN          =
*        MEMORY_UNCOMPLETE            =
*        MEMORY_COMPLETE  =
*        POEXPIMPHEADER   =
*        POEXPIMPHEADERX  =
*        VERSIONS         =
*        NO_MESSAGING     =
*        NO_MESSAGE_REQ   =
*        NO_AUTHORITY     =
*        NO_PRICE_FROM_PO =
*        PARK_COMPLETE    =
*        PARK_UNCOMPLETE  =
       IMPORTING
         EXPPURCHASEORDER = LV_EBELN
*        EXPHEADER        =
*        EXPPOEXPIMPHEADER            =
       TABLES
         RETURN           = RETURN
         POITEM           = ITEM
         POITEMX          = ITEMX
*        POADDRDELIVERY   =
*        POSCHEDULE       = POSCHEDULE
*        POSCHEDULEX      = POSCHEDULEx
*        POACCOUNT        =
*        POACCOUNTPROFITSEGMENT       =
*        POACCOUNTX       =
*        POCONDHEADER     =
*        POCONDHEADERX    =
*        POCOND           =
*        POCONDX          =
*        POLIMITS         =
*        POCONTRACTLIMITS =
*        POSERVICES       =
*        POSRVACCESSVALUES            =
*        POSERVICESTEXT   =
*        EXTENSIONIN      = it_extensionin
*        EXTENSIONOUT     =
*        POEXPIMPITEM     =
*        POEXPIMPITEMX    =
*        POTEXTHEADER     =
*        POTEXTITEM       =
*        ALLVERSIONS      =
*        POPARTNER        =
*        POCOMPONENTS     =
*        POCOMPONENTSX    =
*        POSHIPPING       =
*        POSHIPPINGX      =
*        POSHIPPINGEXP    =
*        SERIALNUMBER     =
*        SERIALNUMBERX    =
*        INVPLANHEADER    =
*        INVPLANHEADERX   =
*        INVPLANITEM      =
*        INVPLANITEMX     =
*        NFMETALLITMS     =
       .

     DELETE  RETURN WHERE TYPE <> 'E'.
     READ TABLE RETURN INTO WA_RETURN INDEX 1.
     IF WA_RETURN-TYPE = 'E'.
       MESSAGE WA_RETURN-MESSAGE  TYPE 'E' DISPLAY LIKE 'E' .
     ENDIF.

     IF LV_EBELN IS NOT INITIAL.
       CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
         EXPORTING
           WAIT = ''
*   IMPORTING
*          RETURN        =
         .
       CONCATENATE 'Purchase Order No.' LV_EBELN 'is created' INTO LV_SUC SEPARATED BY ' '.
       MESSAGE LV_SUC  TYPE 'S' DISPLAY LIKE 'I' .
     ENDIF.
   ELSE.
     MESSAGE 'Purchase Order is already Created' TYPE 'E' DISPLAY LIKE 'I' .

   ENDIF.

 ENDFORM.
