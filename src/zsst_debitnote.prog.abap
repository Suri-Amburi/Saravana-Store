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
   IF WA_ITEM-MATNR IS NOT INITIAL .
     IF WA_ITEM-MATKL IS INITIAL .

       READ TABLE IT_MAKT INTO WA_MAKT WITH KEY MATNR = WA_ITEM-MATNR SPRAS = 'EN'.
       IF SY-SUBRC = 0 .
         WA_ITEM-MAKTX = WA_MAKT-MAKTX .
       ENDIF.

       IF WA_ITEM-MATKL IS INITIAL .
         READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_ITEM-MATNR .
         IF SY-SUBRC = 0.
           WA_ITEM-MATKL = WA_MARA-MATKL .
           WA_ITEM-MEINS = WA_MARA-MEINS.
*         MODIFY IT_ITEM FROM WA_ITEM TRANSPORTING SL_NO
*                                                  MATNR
*                                                  MAKTX
*                                                  MATKL
*                                                  MEINS  WHERE SL_NO = WA_ITEM-SL_NO .
         ENDIF.


       ENDIF.
     ELSE.
       READ TABLE IT_MAKT INTO WA_MAKT WITH KEY MATNR = WA_ITEM-MATNR SPRAS = 'EN'.
       IF SY-SUBRC = 0 .
         WA_ITEM-MAKTX = WA_MAKT-MAKTX .
       ENDIF.
          READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_ITEM-MATNR .
         IF SY-SUBRC = 0.
*           WA_ITEM-MATKL = WA_MARA-MATKL .
           WA_ITEM-MEINS = WA_MARA-MEINS.
        endIF.
     ENDIF.





* MODIFY it_item from wa_item index tc1-current_line.
   ENDIF.
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
          WHERE STEUC = IT_MARC-STEUC .
   ENDIF.

   IF IT_A900 IS NOT INITIAL.
     SELECT KNUMH
            KOPOS
            KBETR FROM KONP INTO TABLE IT_KONP
           FOR ALL ENTRIES IN IT_A900
       WHERE KNUMH = IT_A900-KNUMH.
   ENDIF.


   LOOP AT  IT_MAKT INTO WA_MAKT .
     SHIFT WA_MAKT-MATNR LEFT DELETING LEADING '0'.
     MODIFY IT_MAKT FROM WA_MAKT .
   ENDLOOP.

   LOOP AT  IT_MARA  INTO WA_MARA .
     SHIFT WA_MARA-MATNR LEFT DELETING LEADING '0'.
     MODIFY IT_MARA FROM WA_MARA .
   ENDLOOP.

 ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_FST  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE UPDATE_FST INPUT.
*  BREAK-POINT .
   IF WA_ITEM-MATKL IS NOT INITIAL AND WA_ITEM-MATNR IS INITIAL .


     IF WA_ITEM-SL_NO IS  INITIAL .
*       it_item1[] = it_item .
*       SORT IT_ITEM1 DESCENDING BY SL_NO .
*       READ TABLE IT_ITEM1 INTO WA_ITEM1 INDEX 1.
       WA_ITEM-SL_NO =  10 .
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




   ENDIF.
   MODIFY IT_ITEM
     FROM WA_ITEM
     INDEX TC1-CURRENT_LINE.


 ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALID_STEUC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE VALID_STEUC INPUT.
*BREAK-POINT.
   clear wa_item-gst% .
   IF WA_ITEM-STEUC IS NOT INITIAL AND WA_ITEM-MATNR IS NOT INITIAL .

     READ TABLE  IT_MARC INTO WA_MARC WITH KEY STEUC = WA_ITEM-STEUC .
     IF SY-SUBRC = 0 .
       LOOP AT IT_A900 INTO WA_A900 WHERE STEUC = WA_ITEM-STEUC.
         READ TABLE IT_KONP INTO WA_KONP WITH KEY KNUMH = WA_A900-KNUMH.
         IF SY-SUBRC = 0.
           LV_% = WA_KONP-KBETR / 10 .
           WA_ITEM-GST% = WA_ITEM-GST% + LV_% .
         ENDIF.

       ENDLOOP.

     ENDIF.
   ENDIF.

 ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALID_MENGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALID_MENGE INPUT.
  IF wa_item-menge is not INITIAL .


  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALID_NETPR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALID_NETPR INPUT.

  IF wa_item-netpr is not INITIAL and wa_item-menge is not INITIAL .
    wa_item-gst = ( wa_item-netpr * wa_item-menge ) * wa_item-gst% / 100 .

    wa_item-AMOUNT = ( wa_item-netpr * wa_item-menge ) + wa_item-gst .
  ENDIF.

ENDMODULE.
