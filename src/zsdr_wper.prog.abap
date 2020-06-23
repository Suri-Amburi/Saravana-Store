*&---------------------------------------------------------------------*
*& Report ZSDR_WPER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSDR_WPER.

TABLES : SRRELROLES, EDIDC.
Type-pools slis.
TYPES : BEGIN OF ty_final,
        Invoice TYPE wpusa_doc_key,
        idoc TYPE EDIDC-DOCNUM,
        Article TYPE wpusa_doc_key,
        upkey TYPE wpusa_uploadkey,
        END OF ty_final.

TYPES : begin of ty_data,
        idoc TYPE EDIDC-DOCNUM,
        segnum     like edidd-segnum,
       segnum_end like edidd-segnum,
*      Upload key
       uploadkey  type wpusa_uploadkey,
*      Index to keep follow-on documents in the order they were written
       index      like sy-tabix,
*      object type of follow-on document
       objtype like objectconn-objecttype,
*      key of follow-on document
       key     type wpusa_doc_key,
*      Flag if the current record is the external document:
       extdoc_flag type wpusa_extdoc_flag,
*      level of follow-on document in case of an hierarchical structure
       level(2) type n,
*      Attributes of follow-on document. Field can be used freely.
       attr(10),
*        data TYPE WPUSA_T_FOLDOC,
        END OF ty_data.
data : data_foldoc TYPE TABLE OF ty_data,
       wa_foldoc TYPE ty_data.

data : li_final TYPE TABLE OF ty_final,
       lw_final TYPE ty_final.
data wa_layout TYPE slis_layout_alv.
wa_layout-colwidth_optimize = 'X'.
wa_layout-zebra = 'X'.
DATA : it_SRRELROLES type TABLE OF SRRELROLES,
       it_SRRELROLES1 type TABLE OF SRRELROLES,
       wa_SRRELROLES type SRRELROLES,
       it_idocrel TYPE TABLE OF idocrel,
       lv_idoc   TYPE EDIDC-DOCNUM,
       lv_idoc1   TYPE EDIDC-DOCNUM,
       li_idoc   TYPE  SRRELROLES-roleid,
       it_foldoc TYPE  WPUSA_T_FOLDOC,
       w_foldoc TYPE WPUSA_FOLDOC.
*       data_foldoc TYPE  WPUSA_T_FOLDOC,
*       wa_foldoc TYPE WPUSA_FOLDOC.
Data: it_fcat type SLIS_T_FIELDCAT_ALV,
      Wa_fcat like line of it_fcat.


SELECTION-SCREEN BEGIN OF BLOCK wper WITH FRAME.
  SELECT-OPTIONS so_invce for SRRELROLES-OBJKEY MODIF ID M1 .
  SELECT-OPTIONS so_idoc for SRRELROLES-roleid MODIF ID M2 .

  Parameter p_com radiobutton group B USER-COMMAND UC.
Parameter p_ven radiobutton group B default 'X'.
  SELECTION-SCREEN END OF BLOCK wper.


At selection-screen output.   " 78
If p_com = 'X'.
Loop at screen.
  If screen-group1 = 'M1'.
Screen-input = 1.
Modify screen.
Elseif screen-group1 = 'M2'.
Screen-input = 0.
Modify screen.
Endif.
Endloop.
Elseif p_ven = 'X'.
Loop at screen.
If screen-group1 = 'M1'.
Screen-input = 0.
Modify screen.
Elseif screen-group1 = 'M2'.
Screen-input = 1.
Modify screen.
Endif.
Endloop.
Endif.


START-OF-SELECTION.
if so_invce is not INITIAL.
SELECT * from   SRRELROLES INTO TABLE it_SRRELROLES
    WHERE objkey in so_invce and OBJTYPE = 'VBRK'.

  IF it_SRRELROLES is not INITIAL.
    SELECT * from idocrel INTO TABLE it_idocrel FOR ALL ENTRIES IN it_SRRELROLES
        WHERE ROLE_A = it_SRRELROLES-ROLEID.
      IF sy-subrc = 0.
           IF it_idocrel is not INITIAL .
          SELECT * from SRRELROLES INTO TABLE it_SRRELROLES1 FOR ALL ENTRIES IN it_idocrel
             WHERE ROLEID = it_idocrel-ROLE_B.
              ENDIF.
           ENDIF.
  ENDIF.
endif.
  IF it_SRRELROLES1 is not INITIAL.
    loop at it_SRRELROLES1 INTO wa_SRRELROLES.
      lv_idoc  = wa_SRRELROLES-objkey+0(6).

      perform IDOC.

    endloop.

   ELSEIF it_SRRELROLES1 is INITIAL.
     if so_idoc is NOT INITIAL.
*          li_idoc = so_idoc.
          LOOP AT so_idoc INTO li_idoc.
            lv_idoc  = li_idoc. " +0(6).
                perform IDOC.

          ENDLOOP.
     endif.
  ENDIF.

*************************************************** Fill Final
* sort data_foldoc by objtype.
LOOP AT data_foldoc INTO wa_foldoc .
  IF  wa_foldoc-objtype = 'BUS2017'.
          lw_final-article = wa_foldoc-key+0(10).
          lw_final-upkey   = wa_foldoc-uploadkey.
          lw_final-idoc =  wa_foldoc-idoc.
    append lw_final to li_final.

  ELSEIF   wa_foldoc-objtype = 'VBRK'.
         lw_final-invoice =  wa_foldoc-key.
         modify li_final from lw_final TRANSPORTING invoice where upkey = wa_foldoc-uploadkey.

  ENDIF.


CLEAR lw_final.
ENDLOOP.
PERFORM display.
*&---------------------------------------------------------------------*
*&      Form  IDOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM IDOC .
   CALL FUNCTION 'POS_SA_GET_DOCUMENT_STATUS'
      EXPORTING
        DOCNUM                  = lv_idoc
*       SEGNUM                  =
*       SEGNUM_END              =
        MESTYP                  = 'WPUBON'
*       HISTORY_FLAG            =
*       INBOUND                 =
*       SNDPRN                  =
*     IMPORTING
*       STATUS                  =
*       STATUS_DISP             =
*       VERARBEND               =
*       VERBUCHUNG              =
*       POSTED                  =
     TABLES
*       DOC_STATUS              =
*       DOC_HISTORY             =
*       DOC_REASON              =
*       DOC_CHANGES             =
*       T_EDIDS                 =
*       T_WPTST                 =
*       T_WPLST                 =
*       T_EXTDOC                =
*       T_UPLDOC                =
       T_FOLDOC                = it_foldoc
*     EXCEPTIONS
*       IDOC_NOT_EXIST          = 1
*       FOREIGN_LOCK            = 2
*       UNKNOWN_EXCEPTION       = 3
*       RANGE_NOT_EXIST         = 4
*       OTHERS                  = 5
              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.


*Append LINES OF it_foldoc to data_foldoc,.
LOOP AT  it_foldoc INTO w_foldoc.
  wa_foldoc-uploadkey = w_foldoc-uploadkey.
  wa_foldoc-objtype = w_foldoc-objtype.
  wa_foldoc-idoc = lv_idoc.
  wa_foldoc-key = w_foldoc-key.
  append wa_foldoc to data_foldoc.
  CLEAR wa_foldoc.
ENDLOOP.
refresh it_foldoc.
CLEAR lv_idoc.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY .

WA_FCAT-FIELDNAME = ' INVOICE'.
WA_FCAT-COL_POS = '1'.
WA_FCAT-SELTEXT_M = 'Invoice'.
APPEND WA_FCAT TO IT_FCAT.
CLEAR WA_FCAT.


WA_FCAT-FIELDNAME = ' IDOC'.
WA_FCAT-COL_POS = '2'.
WA_FCAT-SELTEXT_M = 'Idoc'.
APPEND WA_FCAT TO IT_FCAT.
CLEAR WA_FCAT.


WA_FCAT-FIELDNAME = 'ARTICLE'.
WA_FCAT-COL_POS = '3'.
WA_FCAT-SELTEXT_M = 'Article'.
APPEND WA_FCAT TO IT_FCAT.
CLEAR WA_FCAT.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
*   I_CALLBACK_PROGRAM                = ' '
*   I_CALLBACK_PF_STATUS_SET          = ' '
*   I_CALLBACK_USER_COMMAND           = ' '
*   I_CALLBACK_TOP_OF_PAGE            = ' '
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  =
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
   IS_LAYOUT                         = wa_layout
   IT_FIELDCAT                       = IT_FCAT
*   IT_EXCLUDING                      =
*   IT_SPECIAL_GROUPS                 =
*   IT_SORT                           =
*   IT_FILTER                         =
*   IS_SEL_HIDE                       =
*   I_DEFAULT                         = 'X'
*   I_SAVE                            = ' '
*   IS_VARIANT                        =
*   IT_EVENTS                         =
*   IT_EVENT_EXIT                     =
*   IS_PRINT                          =
*   IS_REPREP_ID                      =
*   I_SCREEN_START_COLUMN             = 0
*   I_SCREEN_START_LINE               = 0
*   I_SCREEN_END_COLUMN               = 0
*   I_SCREEN_END_LINE                 = 0
*   I_HTML_HEIGHT_TOP                 = 0
*   I_HTML_HEIGHT_END                 = 0
*   IT_ALV_GRAPHICS                   =
*   IT_HYPERLINK                      =
*   IT_ADD_FIELDCAT                   =
*   IT_EXCEPT_QINFO                   =
*   IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER           =
*   ES_EXIT_CAUSED_BY_USER            =
  TABLES
    T_OUTTAB                          = LI_FINAL
* EXCEPTIONS
*   PROGRAM_ERROR                     = 1
*   OTHERS                            = 2
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

ENDFORM.
