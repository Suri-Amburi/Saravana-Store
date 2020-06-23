*----------------------------------------------------------------------*
*   INCLUDE LMGD1I7L                                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  GET_TEXT  INPUT
*&---------------------------------------------------------------------*
*
*       Übergabe des Langtextes vom TextEdit-Control zum ABAP
*
*----------------------------------------------------------------------*

  MODULE get_text INPUT.
*===Okcode merken für PBO===============================================
    CALL FUNCTION 'SET_ACTIONCODE'
         EXPORTING
              actioncode_in = rmmzu-okcode.
    CALL FUNCTION 'SET_TC_LONGTEXT_PARAMS'
         EXPORTING
              tc_longtext_height_in   = tc_longtext_height
              tc_longtext_top_line_in = tc_longtext-top_line.
*===Text vom Textdit-Control übertragen=================================
    CLEAR ismodified.
    IF NOT <editor_obj> IS INITIAL.
      CALL METHOD <editor_obj>->GET_TEXT_AS_STREAM
        IMPORTING
          TEXT                   = textstream
          IS_MODIFIED            = ismodified
        EXCEPTIONS
          ERROR_DP               = 1
          ERROR_CNTL_CALL_METHOD = 2
          others                 = 3.
      DATA HELP_TLINETAB LIKE TLINE OCCURS 0 WITH HEADER LINE.
* note 1136835: specify language to get correct ITF text for 1,2,3,J,M
      CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
           EXPORTING
                LANGUAGE    = RM03M-SPRAS
           TABLES
                TEXT_STREAM = TEXTSTREAM
                ITF_TEXT    = HELP_TLINETAB.
      REFRESH TDLINETAB.
      LOOP AT HELP_TLINETAB.
        APPEND HELP_TLINETAB-TDLINE TO TDLINETAB.
      ENDLOOP.
*<<<<<<<<BEGIN OF INSERTION NOTE 335328<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      CALL FUNCTION 'APPEND_LANGTEXT_REFS'
           EXPORTING
                IV_MODUS                  = 'T'.
*<<<<<<<<END OF INSERTION NOTE 335328<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      CALL METHOD cl_gui_cfw=>flush  "TF 4.6C for safety
          EXCEPTIONS                 "TF 4.6C for safety
              OTHERS = 1.            "TF 4.6C for safety
    ENDIF.

*===Im TextEdit-Control wurden Aktionen durchgeführt====================
*<<<<<<<<BEGIN OF DELETION NOTE 407677<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*    IF NOT ismodified IS INITIAL.
*      REFRESH tlinetab.
**=====Formatinformation einfügen=======================================
*      LOOP AT tdlinetab INTO wtdline.
**       IF SY-INDEX = 1.                             DELETE NOTE 375187
*       IF SY-TABIX = 1.                             "INSERT NOTE 375187
**        WTLINETAB-TDFORMAT = '/ '. WTLINETAB-TDLINE = WTDLINE."N389045
*         WTLINETAB-TDFORMAT = '* '. WTLINETAB-TDLINE = WTDLINE."N389045
*        ELSE.
**        WTLINETAB-TDFORMAT = '* '. WTLINETAB-TDLINE = WTDLINE."N389045
*         WTLINETAB-TDFORMAT = '/ '. WTLINETAB-TDLINE = WTDLINE."N389045
*        ENDIF.
*        APPEND wtlinetab TO tlinetab.
*      ENDLOOP.
*    ENDIF.
*<<<<<<<<END OF DELETION NOTE 407677<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*<<<<<<<<BEGIN OF INSERTION NOTE 407677<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    IF NOT ismodified IS INITIAL.
      data: gt_tlinetab like tline occurs 0 with header line.
      data: sy_tabix2 like sy-tabix.
      gt_tlinetab[] = tlinetab[].
      REFRESH tlinetab.
*=====Formatinformation einfügen========================================
      LOOP AT tdlinetab INTO wtdline.
        sy_tabix2 = sy-tabix.

*       note 1133360: keep extended lines instead of a new line break!
*       note 1136835: also for continuous text, used for languages 1,2,3,J,M
        read table HELP_TLINETAB index sy_tabix2.
        IF HELP_TLINETAB-TDFORMAT = '= ' OR HELP_TLINETAB-TDFORMAT = '  '.
          WTLINETAB = HELP_TLINETAB.
        ELSE.
          read table gt_tlinetab index sy_tabix2.
*         note 1133360: keep old line format only for unchanged text lines
          if sy-subrc = 0 AND wtdline = gt_tlinetab-tdline.
            wtlinetab-tdformat = gt_tlinetab-tdformat.
            wtlinetab-tdline = wtdline.
          else.
            IF SY_TABIX2 = 1.                            "INSERT NOTE 375187
              WTLINETAB-TDFORMAT = '* '. WTLINETAB-TDLINE = WTDLINE. "N389045
            ELSE.
              WTLINETAB-TDFORMAT = '/ '. WTLINETAB-TDLINE = WTDLINE. "N389045
            ENDIF.
          ENDIF.
        ENDIF.
        APPEND wtlinetab TO tlinetab.
      ENDLOOP.
    ENDIF.
*<<<<<<<<END OF INSERTION NOTE 407677<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*===Schnittstellenparameter für xthead_bearbeiten füllen================
    LOOP AT tlinetab INTO wtlinetab.
*      CASE SY-INDEX.                                 DELETE NOTE 375187
      CASE SY-TABIX.                                 "INSERT NOTE 375187
        WHEN 1.
          rm03m-ltex1 = wtlinetab.
        WHEN 2.
          rm03m-ltex2 = wtlinetab.
        WHEN 3.
          rm03m-ltex3 = wtlinetab.
        WHEN 4.
          rm03m-ltex4 = wtlinetab.
        WHEN OTHERS.
          EXIT.
      ENDCASE.
    ENDLOOP.

  ENDMODULE.                           " GET_TEXT  INPUT

*&---------------------------------------------------------------------*
*&      Module  DESC_LANGU_SETZEN  INPUT
*&---------------------------------------------------------------------*
*       Tabelle der gepflegten Sprachen an DropDownListbox übergeben
*----------------------------------------------------------------------*
  MODULE desc_langu_setzen INPUT.

    CALL FUNCTION 'DESC_LANGU_SETZEN'
         EXPORTING
              desc_langu_listbox = desc_langu_listbox.

  ENDMODULE.                           " DESC_LANGU_SETZEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_TC_GDTXT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  MODULE get_tc_longtext INPUT.
*    if lang_tc_tab_tc-mark = 'X'.
*      <desc_langu> = lang_tc_tab_tc-sprsl.
*    endif.
  ENDMODULE.                           " GET_TC_GDTXT  INPUT
*&---------------------------------------------------------------------*
*&      Module  MARK_TC_LONGTEXT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  MODULE mark_tc_longtext OUTPUT.
    IF lang_tc_tab_tc-mark = 'X'.
      LOOP AT SCREEN.
        IF screen-name = 'LANG_TC_TAB_TC-SPTXT'.
          screen-intensified = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMODULE.                           " MARK_TC_LONGTEXT  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_LANGTEXTBILD_T130M_AKTYP  INPUT
*&---------------------------------------------------------------------*
*       TF 4.6A
*----------------------------------------------------------------------*
  MODULE set_langtextbild_t130m_aktyp INPUT.
    IF ltext_input = 0.
      langtext_t130m_aktyp_save = t130m-aktyp.
      t130m-aktyp = aktypa.
    ENDIF.
  ENDMODULE.                 " SET_LANGTEXTBILD_T130M_AKTYP  INPUT
*&---------------------------------------------------------------------*
*&      Module  RESET_LANGTEXTBILD_T130M_AKTYP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  MODULE reset_langtextbild_t130m_aktyp INPUT.
    IF NOT langtext_t130m_aktyp_save IS INITIAL.
      t130m-aktyp = langtext_t130m_aktyp_save.
      CLEAR langtext_t130m_aktyp_save.
    ENDIF.
  ENDMODULE.                 " CLEAR_LANGTEXTBILD_T130M_AKTYP  INPUT
*&---------------------------------------------------------------------*
*&      Module  RESET_FCODE_TLAN  INPUT
*&---------------------------------------------------------------------*
*       TF 4.6A
*----------------------------------------------------------------------*
  MODULE reset_fcode_tlan INPUT.
*<BEGIN OF INSERTION NOTE 163770<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    IF  rmmzu-okcode IS INITIAL AND
* JH/02.08.99/4.6C (Anfang)
* Die Änderung von Hinweis 163770 führt dazu, daß das Grunddatenbild
* nicht mehr mit ENTER verlassen werden kann
* (weitere Infos s. int. Meld. 222053).
        NOT tc_longtext_top_line IS INITIAL AND
* JH/02.08.99/4.6C (Ende)
        tc_longtext_top_line <> tc_longtext-top_line.
      bildflag = 'X'.
    ENDIF.
*<BEGIN OF INSERTION NOTE 163770<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    IF rmmzu-okcode = fcode_tlan.
      CLEAR rmmzu-okcode.
      bildflag = 'X'.
    ENDIF.
  ENDMODULE.                           " RESET_FCODE_TLAN  INPUT
