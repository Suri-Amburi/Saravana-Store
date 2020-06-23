*&---------------------------------------------------------------------*
*&  Include           LWPDAF18
*&---------------------------------------------------------------------*
FORM marc_pointer_analyse
     TABLES pet_ot1_f_artstm STRUCTURE gt_ot1_f_artstm
            pet_ot1_f_ean    STRUCTURE gt_ot1_f_ean
            pxt_artdel       STRUCTURE gt_artdel
            pit_filia_group  STRUCTURE gt_filia_group
            pi_pointer       STRUCTURE bdcp
    USING   pi_erstdat       LIKE syst-datum.

  DATA: h_tabix      LIKE sy-tabix
      , wa_ot1       TYPE wpartstm
      , lt_marc      TYPE marc_tab
      , lt_matnr_werks     TYPE pre01_tab
      , ls_matnr_werks     TYPE pre01
      , artdel_tabix       LIKE sy-tabix
      , lv_no_lvorm        TYPE xflag
      , lt_marc_pinter     TYPE STANDARD TABLE OF bdcp
      , lt_matnr           TYPE pre03_tab
      , ls_matnr           TYPE pre03
      .

* Tabelle für Materialnummern.
  DATA: BEGIN OF t_matnr OCCURS 0.
          INCLUDE STRUCTURE gt_matnr.
  DATA: END OF t_matnr.

  FIELD-SYMBOLS:
    <fs_marc> TYPE marc,
    <fs_bdcp> TYPE bdcp.

* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  READ TABLE pi_pointer WITH KEY
       cdobjcl = c_objcl_mat_full
       tabname = 'DMARC'
       BINARY SEARCH
       TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    h_tabix = sy-tabix.
    SORT pit_filia_group BY filia.


    LOOP AT pi_pointer FROM h_tabix.
*       Verlassen der Schleife, wenn letzter relevante Eintrag
*       gelesen wurde.
      IF pi_pointer-tabname <> 'DMARC'.
        EXIT.
      ENDIF.
*     Prüfe, ob diese Filiale in der gerade
*     bearbeiteten Filialgruppe vorkommt. Nur solche Sätze
*     dürfen berücksichtigt werden.
      READ TABLE pit_filia_group WITH KEY
              filia = pi_pointer-tabkey
                    BINARY SEARCH.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
* collect art and art/site in order to prefetch MAra, Marm
* and Marc (read marc to evaluate LVORM)
      ls_matnr-matnr = pi_pointer-cdobjid.
      APPEND ls_matnr TO  lt_matnr.
      IF pi_pointer-fldname = 'LVORM'.
      ls_matnr_werks-matnr = pi_pointer-cdobjid.
      ls_matnr_werks-werks = pi_pointer-tabkey.
      APPEND ls_matnr_werks TO lt_matnr_werks.
      ENDIF.
      APPEND pi_pointer TO lt_marc_pinter.
    ENDLOOP.

* Prefetch MARA, MARM
    IF lt_matnr[] IS NOT INITIAL.
      CALL FUNCTION 'POS_PREFETCH_ARTICLE_DATA'
      EXPORTING
        it_articles = lt_matnr
        i_mara_pref = abap_true
        i_marm_pref = abap_true.
    ENDIF.

*Prefetch MARC
    IF lt_matnr_werks[] IS NOT INITIAL.
    CALL FUNCTION 'MARC_ARRAY_READ'
      TABLES
        ipre01   = lt_matnr_werks
        marc_tab = lt_marc.
      SORT lt_marc BY werks matnr.
    ENDIF.


    LOOP AT lt_marc_pinter ASSIGNING <fs_bdcp>.
*   Bestimme alle Verkaufsmengeneinheiten des Artikels
*   aus Tabelle MARM, die eine EAN besitzen.
      REFRESH: t_matnr.
      t_matnr-matnr = <fs_bdcp>-cdobjid.
      APPEND t_matnr.

      PERFORM marm_select TABLES t_matnr
                                 gt_vrkme
                          USING  'X'   ' '   ' '.
* Prüfe, ob VRKME's gefunden wurden.
      READ TABLE gt_vrkme INDEX 1.

* Falls keine VRKME's gefunden wurden.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF <fs_bdcp>-fldname = 'LVORM'.
        READ TABLE lt_marc ASSIGNING <fs_marc>
                           WITH KEY werks = <fs_bdcp>-tabkey
                                    matnr = <fs_bdcp>-cdobjid
                           BINARY SEARCH.
        IF sy-subrc = 0.
          IF <fs_marc>-lvorm = 'X'.
            LOOP AT gt_vrkme.
*        Fülle Objekttabelle 1 (filialabhängig).
              CLEAR: wa_ot1.
              wa_ot1-artnr    = gt_vrkme-matnr.
              wa_ot1-vrkme    = gt_vrkme-meinh.
              wa_ot1-datum    = pi_erstdat.
              wa_ot1-upd_flag = c_del.
              wa_ot1-filia    = <fs_bdcp>-tabkey.
              APPEND wa_ot1 TO pet_ot1_f_artstm.
            ENDLOOP.                 " AT GT_VRKME.
          ELSE.  " lvorm is initial.
            lv_no_lvorm = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.
      IF <fs_bdcp>-fldname = 'KEY' OR lv_no_lvorm = 'X'.
*   Vorbesetzen einiger Feldinhalte der Ausgabetabelle.
        CLEAR: wa_ot1.
        wa_ot1-datum = <fs_bdcp>-acttime(8).
        wa_ot1-artnr = <fs_bdcp>-cdobjid.
        wa_ot1-filia = <fs_bdcp>-tabkey.
        wa_ot1-init  = 'X'.
        CLEAR: wa_ot1-upd_flag.

*   Falls das Aktivierungsdatum des Pointers in der
*   Vergangenheit liegt, dann setze auf Versendedatum.
        IF <fs_bdcp>-acttime(8) < pi_erstdat.
          wa_ot1-datum = pi_erstdat.
        ENDIF. " PI_POINTER-ACTTIME(8) < PI_ERSTDAT.


*     Merken, das der Pointer aufgrund einer
*     Materialstammänderung erzeugt wurde.
        wa_ot1-aetyp_sort = c_mat_sort_index.

*     Falls das Aktivierungsdatum des Pointers in der
*     Vergangenheit liegt, dann setze auf Versendedatum.
        IF <fs_bdcp>-acttime(8) < pi_erstdat.
          wa_ot1-datum = pi_erstdat.
        ENDIF. " PI_POINTER-ACTTIME(8) < PI_ERSTDAT.

        LOOP AT gt_vrkme.
          wa_ot1-vrkme = gt_vrkme-meinh.
          APPEND: wa_ot1 TO pet_ot1_f_artstm, wa_ot1 TO pet_ot1_f_ean.
        ENDLOOP.                 " AT GT_VRKME.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  POS_LISTING_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_WLK2  text
*      -->P_GT_LISTUNG  text
*      -->P_PI_VKORG  text
*      -->P_PI_VTWEG  text
*      -->P_PI_FILIA  text
*      -->P_PIT_ARTIKEL_MATNR  text
*      -->P_PIT_ARTIKEL_VRKME  text
*      -->P_GT_WLK2  text
*      -->P_REFRESH  text
*      -->P_T_MATNR  text
*----------------------------------------------------------------------*
FORM pos_listing_get  TABLES   pit_wlk2    STRUCTURE gt_wlk2
                               pet_listung STRUCTURE gt_listung
                      USING    pi_vkorg    TYPE vkorg
                               pi_vtweg    TYPE vtweg
                               pi_filia    TYPE werks_d
                               pi_matnr    TYPE matnr.

  DATA: BEGIN OF t_matnr OCCURS 0,
          matnr LIKE mara-matnr.
  DATA: END OF t_matnr.

  DATA: BEGIN OF t_marm OCCURS 0.
          INCLUDE STRUCTURE wpos_short_marm.
  DATA: END OF t_marm.

 READ TABLE pit_wlk2 WITH KEY
                     matnr = pi_matnr
                     vkorg = pi_vkorg
                     vtweg = pi_vtweg
                     werks = pi_filia
                     BINARY SEARCH.

  APPEND pi_matnr TO t_matnr.
  PERFORM marm_select     TABLES t_matnr
                                 t_marm
                           USING 'X'                  " pi_with_ean
                                 ' '                  " pi_matnr
                                 ' '.                 " pi_meinh
  PERFORM gt_listung_fill TABLES t_marm
                                 gt_listung
                           USING pit_wlk2.


ENDFORM.                    " POS_LISTING_GET
