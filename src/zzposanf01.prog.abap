*-------------------------------------------------------------------
***INCLUDE POSANF01 .
*-------------------------------------------------------------------

************************************************************************
FORM article_get TABLES pet_article STRUCTURE wpart.
************************************************************************
* FUNKTION:
* Bestimme alle Artikel, die den angegebenen Selektionsbedingungen
* genügen und fülle sie in Tabelle PET_ARTICLE.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_ARTICLE: Ergebnismenge der selektierten Artikel.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS-Nord)
************************************************************************
  DATA: art_lines TYPE i,
        ean_lines TYPE i,
        wrg_lines TYPE i.

  DATA: BEGIN OF t_article OCCURS 50,
          matnr LIKE mara-matnr.
  DATA: END OF t_article.


  DESCRIBE TABLE so_matar LINES art_lines.
  DESCRIBE TABLE so_eanar LINES ean_lines.
  DESCRIBE TABLE so_wrgar LINES wrg_lines.

* Nur bestimmte Artikel sollen versendet werden.
  IF art_lines <> 0 OR ean_lines <> 0 OR wrg_lines <> 0.
*   Besorge Artikelnummern aus Tabelle MARA.
    IF art_lines <> 0.
      SELECT * FROM mara
            APPENDING CORRESPONDING FIELDS OF TABLE t_article
            WHERE matnr IN so_matar.
    ENDIF.                             " ART_LINES <> 0.

*   Besorge Artikelnummern aus Tabelle MARA, über die EAN's.
    IF ean_lines <> 0.
      SELECT * FROM mean
             APPENDING CORRESPONDING FIELDS OF TABLE t_article
             WHERE ean11 IN so_eanar.
    ENDIF.                             " EAN_LINES <> 0.

*   Besorge Artikelnummern aus Tabelle MARA über Warengruppen.
    IF wrg_lines <> 0.
      SELECT * FROM mara
             APPENDING CORRESPONDING FIELDS OF TABLE t_article
             WHERE matkl IN so_wrgar.
    ENDIF.                             " WRG_LINES <> 0.

*   Lösche alle doppelten Einträge aus T_ARTICLE.
    SORT t_article BY matnr.
    DELETE ADJACENT DUPLICATES FROM t_article
           COMPARING matnr.

*   Übernehme Daten in Ausgabetabelle.
    CLEAR: pet_article.
    pet_article-arttyp = c_artikeltyp.
    LOOP AT t_article.
      pet_article-matnr = t_article-matnr.
      APPEND pet_article.
    ENDLOOP. " at t_article
  ENDIF. " ART_LINES <> 0 OR EAN_LINES <> 0 OR WRG_LINES <> 0.

* Fehlermeldung, falls keine Daten gefunden wurden.
  READ TABLE t_article INDEX 1.
  IF sy-subrc <> 0 AND
     ( art_lines <> 0 OR ean_lines <> 0 OR wrg_lines <> 0 ).
*   'Es konnte kein Material selektiert werden'
    MESSAGE i002.
    STOP.
  ENDIF.                               " sy-subrc <> 0 ...


ENDFORM.                               " ARTICLE_GET


*eject
************************************************************************
FORM article_equal_get
     TABLES pet_article_equal STRUCTURE gt_article_equal.
************************************************************************
* FUNKTION:
* Bestimme die Gesamtmenge der, in den SELECT-OPTION-Tabellen mit
* 'EQUAL' angebenen Artikeln.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_ARTICLE_EQUAL: Ergebnismenge der selektierten Artikel.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS-Nord)
************************************************************************
  DATA: ean_lines TYPE i.

  DATA: BEGIN OF t_eanar OCCURS 10,
          sign(1),
          option(2),
          low       LIKE mean-ean11,
          high      LIKE mean-ean11.
  DATA: END OF t_eanar.

  DATA: BEGIN OF t_article OCCURS 10,
          matnr LIKE mara-matnr.
  DATA: END OF t_article.


  CLEAR:   pet_article_equal.
  REFRESH: pet_article_equal.
  REFRESH: t_eanar.

* Übernehme alle EQUAL-Einträge aus SELECT-OPTION-Tabelle
* SO_MATAR nach PET_ARTICLE_EQUAL.
  LOOP AT so_matar
       WHERE sign   = c_insert
       AND   option = c_equal.
    APPEND so_matar-low TO t_article.
  ENDLOOP.                             " AT SO_MATAR.

* Übernehme alle EQUAL-Einträge aus SELECT-OPTION-Tabelle
* SO_EANAR nach T_EANAR.
  LOOP AT so_eanar
       WHERE sign   = c_insert
       AND   option = c_equal.
    APPEND so_eanar TO t_eanar.
  ENDLOOP.                             " AT SO_EANAR.

  DESCRIBE TABLE t_eanar LINES ean_lines.

* Besorge Artikelnummern aus Tabelle MARA, über die EAN's.
  IF ean_lines <> 0.
    SELECT * FROM mean
           APPENDING CORRESPONDING FIELDS OF TABLE t_article
           WHERE ean11 IN t_eanar.
  ENDIF.                               " EAN_LINES <> 0.

* Lösche alle doppelten Einträge aus T_ARTICLE.
  SORT t_article BY matnr.
  DELETE ADJACENT DUPLICATES FROM t_article
         COMPARING matnr.

* Übernehme Daten in Ausgabetabelle.
  CLEAR: pet_article_equal.
  pet_article_equal-arttyp = c_artikeltyp.
  LOOP AT t_article.
    pet_article_equal-matnr = t_article-matnr.
    APPEND pet_article_equal.
  ENDLOOP. " at t_article


ENDFORM.                               " ARTICLE_EQUAL_GET


*eject
************************************************************************
FORM ean_get TABLES pet_ean STRUCTURE wpart.
************************************************************************
* FUNKTION:
* Bestimme alle EAN-Ref., die den angegebenen Selektionsbedingungen
* genügen und fülle sie in Tabelle PET_EAN.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_EAN: Ergebnismenge der selektierten EAN-Referenzen.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS-Nord)
************************************************************************
  DATA: art_lines TYPE i,
        ean_lines TYPE i,
        wrg_lines TYPE i.

  DATA: BEGIN OF t_article OCCURS 50,
          matnr LIKE mara-matnr.
  DATA: END OF t_article.


  DESCRIBE TABLE so_matea LINES art_lines.
  DESCRIBE TABLE so_eanea LINES ean_lines.
  DESCRIBE TABLE so_wrgea LINES wrg_lines.

* Nur bestimmte Artikel sollen versendet werden.
  IF art_lines <> 0 OR ean_lines <> 0 OR wrg_lines <> 0.
*   Besorge EAN-Referenzen aus Tabelle MARA.
    IF art_lines <> 0.
      SELECT * FROM mara
             APPENDING CORRESPONDING FIELDS OF TABLE t_article
             WHERE matnr IN so_matea.
    ENDIF.                             " ART_LINES <> 0.

*   Besorge EAN-Referenzen aus Tabelle MARA, über die EAN's.
    IF ean_lines <> 0.
      SELECT * FROM mean
             APPENDING CORRESPONDING FIELDS OF TABLE t_article
             WHERE ean11 IN so_eanea.
    ENDIF.                             " EAN_LINES <> 0.

*   Besorge EAN-Referenzen aus Tabelle MARA über Warengruppen.
    IF wrg_lines <> 0.
      SELECT * FROM mara
             APPENDING CORRESPONDING FIELDS OF TABLE t_article
             WHERE matkl IN so_wrgea.
    ENDIF.                             " WRG_LINES <> 0.

*   Lösche alle doppelten Einträge aus PET_ARTICLE.
    SORT t_article BY matnr.
    DELETE ADJACENT DUPLICATES FROM t_article
           COMPARING matnr.

*   Übernehme Daten in Ausgabetabelle.
    CLEAR: pet_ean.
    pet_ean-arttyp = c_eantyp.
    LOOP AT t_article.
      pet_ean-matnr = t_article-matnr.
      APPEND pet_ean.
    ENDLOOP. " at t_article
  ENDIF. " ART_LINES <> 0 OR EAN_LINES <> 0 OR WRG_LINES <> 0.

* Fehlermeldung, falls keine Daten gefunden wurden.
  LOOP AT pet_ean
    WHERE arttyp = c_eantyp.
    EXIT.
  ENDLOOP.                           " AT PET_EAN.

  IF sy-subrc <> 0 AND
     ( art_lines <> 0 OR ean_lines <> 0 OR wrg_lines <> 0 ).
*   'Es konnten keine EAN-Referenzen selektiert werden'
    MESSAGE i003.
    STOP.
  ENDIF. " SY-SUBRC <> 0 and ...


ENDFORM.                               " EAN_GET


*eject
************************************************************************
FORM ean_equal_get
     TABLES pxt_article_equal STRUCTURE gt_article_equal.
************************************************************************
* FUNKTION:
* Bestimme die Gesamtmenge der, in den SELECT-OPTION-Tabellen mit
* 'EQUAL' angebenen Artikeln.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_ARTICLE_EQUAL: Ergebnismenge der selektierten Artikel.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS-Nord)
************************************************************************
  DATA: ean_lines TYPE i.

  DATA: BEGIN OF t_eanea OCCURS 10,
          sign(1),
          option(2),
          low       LIKE mean-ean11,
          high      LIKE mean-ean11.
  DATA: END OF t_eanea.

  DATA: BEGIN OF t_article OCCURS 10,
          matnr LIKE mara-matnr.
  DATA: END OF t_article.

  CLEAR:   pxt_article_equal.
  REFRESH: t_eanea.

* Übernehme alle EQUAL-Einträge aus SELECT-OPTION-Tabelle
* SO_MATAR nach PET_ARTICLE_EQUAL.
  LOOP AT so_matea
       WHERE sign   = c_insert
       AND   option = c_equal.
    APPEND so_matea-low TO t_article.
  ENDLOOP.                             " AT SO_MATEA.

* Übernehme alle EQUAL-Einträge aus SELECT-OPTION-Tabelle
* SO_EANEA nach T_EANEA.
  LOOP AT so_eanea
       WHERE sign   = c_insert
       AND   option = c_equal.
    APPEND so_eanea TO t_eanea.
  ENDLOOP.                             " AT SO_EANEA.

  DESCRIBE TABLE t_eanea LINES ean_lines.

* Besorge Artikelnummern aus Tabelle MARA, über die EAN's.
  IF ean_lines <> 0.
    SELECT * FROM mean
           APPENDING CORRESPONDING FIELDS OF TABLE t_article
           WHERE ean11 IN t_eanea.
  ENDIF.                               " EAN_LINES <> 0.

* Lösche alle doppelten Einträge aus T_ARTICLE.
  SORT t_article BY matnr.
  DELETE ADJACENT DUPLICATES FROM t_article
         COMPARING matnr.

* Übernehme Daten in Ausgabetabelle.
  CLEAR: pxt_article_equal.
  pxt_article_equal-arttyp = c_eantyp.
  LOOP AT t_article.
    pxt_article_equal-matnr = t_article-matnr.
    APPEND pxt_article_equal.
  ENDLOOP. " at t_article


ENDFORM.                               " EAN_EQUAL_GET


*eject
************************************************************************
FORM sets_get TABLES pet_sets STRUCTURE wpart.
************************************************************************
* FUNKTION:
* Bestimme alle Set-Artikel, die den angegebenen Selektionsbedingungen
* genügen und fülle sie in Tabelle PET_ARTICLE.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_SETS: Ergebnismenge der selektierten Set-Artikel.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS-Nord)
************************************************************************
  DATA: art_lines TYPE i,
        ean_lines TYPE i,
        wrg_lines TYPE i.

  DATA: BEGIN OF t_article OCCURS 50,
          matnr LIKE mara-matnr.
  DATA: END OF t_article.


  DESCRIBE TABLE so_matse LINES art_lines.
  DESCRIBE TABLE so_eanse LINES ean_lines.
  DESCRIBE TABLE so_wrgse LINES wrg_lines.

* Nur bestimmte Artikel sollen versendet werden.
  IF art_lines <> 0 OR ean_lines <> 0 OR wrg_lines <> 0.
*   Besorge Artikelnummern aus Tabelle MARA.
    IF art_lines <> 0.
      SELECT * FROM mara
             APPENDING CORRESPONDING FIELDS OF TABLE t_article
             WHERE matnr IN so_matse
             AND   attyp =  c_setartikel.
    ENDIF.                             " ART_LINES <> 0.

*   Besorge Artikelnummern aus Tabelle MARA, über die EAN's.
    IF ean_lines <> 0.
      SELECT e~matnr APPENDING CORRESPONDING FIELDS OF TABLE t_article
                   FROM mean AS e INNER JOIN mara AS m
                   ON    e~matnr =  m~matnr
                   WHERE e~ean11 IN so_eanse
                   AND   m~attyp =  c_setartikel.
    ENDIF.                             " EAN_LINES <> 0.

*   Besorge Artikelnummern aus Tabelle MARA über Warengruppen.
    IF wrg_lines <> 0.
      SELECT * FROM mara
             APPENDING CORRESPONDING FIELDS OF TABLE t_article
             WHERE matkl IN so_wrgse
             AND   attyp =  c_setartikel.
    ENDIF.                             " WRG_LINES <> 0.

*   Lösche alle doppelten Einträge aus T_ARTICLE.
    SORT t_article BY matnr.
    DELETE ADJACENT DUPLICATES FROM t_article
           COMPARING matnr.

*   Übernehme Daten in Ausgabetabelle.
    CLEAR: pet_sets.
    pet_sets-arttyp = c_settyp.
    LOOP AT t_article.
      pet_sets-matnr = t_article-matnr.
      APPEND pet_sets.
    ENDLOOP. " at t_article
  ENDIF. " ART_LINES <> 0 OR EAN_LINES <> 0 OR WRG_LINES <> 0.

* Fehlermeldung, falls keine Daten gefunden wurden.
  LOOP AT pet_sets
    WHERE arttyp = c_settyp.
    EXIT.
  ENDLOOP.                           " AT PET_SETS

  IF sy-subrc <> 0 AND
     ( art_lines <> 0 OR ean_lines <> 0 OR wrg_lines <> 0 ).
*   'Es konnten keine Set-Artikel selektiert werden'
    MESSAGE i005.
    STOP.
  ENDIF. " SY-SUBRC <> 0 and ...


ENDFORM.                               " SETS_GET


*eject
************************************************************************
FORM set_equal_get
     TABLES pxt_article_equal STRUCTURE gt_article_equal.
************************************************************************
* FUNKTION:
* Bestimme die Gesamtmenge der, in den SELECT-OPTION-Tabellen mit
* 'EQUAL' angebenen Artikeln.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_ARTICLE_EQUAL: Ergebnismenge der selektierten Set-Artikel.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS-Nord)
************************************************************************
  DATA: ean_lines TYPE i.

  DATA: BEGIN OF t_eanse OCCURS 10,
          sign(1),
          option(2),
          low       LIKE mean-ean11,
          high      LIKE mean-ean11.
  DATA: END OF t_eanse.

  DATA: BEGIN OF t_article OCCURS 10,
          matnr LIKE mara-matnr.
  DATA: END OF t_article.

  CLEAR:   pxt_article_equal.
  REFRESH: t_eanse.

* Übernehme alle EQUAL-Einträge aus SELECT-OPTION-Tabelle
* SO_MATSE nach PXT_ARTICLE_EQUAL.
  LOOP AT so_matse
       WHERE sign   = c_insert
       AND   option = c_equal.
    APPEND so_matse-low TO t_article.
  ENDLOOP.                             " AT SO_MATSE.

* Übernehme alle EQUAL-Einträge aus SELECT-OPTION-Tabelle
* SO_EANSE nach T_EANSE.
  LOOP AT so_eanse
       WHERE sign   = c_insert
       AND   option = c_equal.
    APPEND so_eanse TO t_eanse.
  ENDLOOP.                             " AT SO_EANSE.

  DESCRIBE TABLE t_eanse LINES ean_lines.

* Besorge Artikelnummern aus Tabelle MARA, über die EAN's.
  IF ean_lines <> 0.
    SELECT * FROM mean
           APPENDING CORRESPONDING FIELDS OF TABLE t_article
           WHERE ean11 IN t_eanse.
  ENDIF.                               " EAN_LINES <> 0.

* Lösche alle doppelten Einträge aus T_ARTICLE.
  SORT t_article BY matnr.
  DELETE ADJACENT DUPLICATES FROM t_article
         COMPARING matnr.

* Übernehme Daten in Ausgabetabelle.
  CLEAR: pxt_article_equal.
  pxt_article_equal-arttyp = c_settyp.
  LOOP AT t_article.
    pxt_article_equal-matnr = t_article-matnr.
    APPEND pxt_article_equal.
  ENDLOOP. " at t_article


ENDFORM.                               " SET_EQUAL_GET


*eject
************************************************************************
FORM nart_get TABLES pet_nart STRUCTURE wpart.
************************************************************************
* FUNKTION:
* Bestimme alle Nachzugsartikel, die den angegebenen
* Selektionsbedingungen genügen und fülle sie in Tabelle PET_ARTICLE.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_NART: Ergebnismenge der selektierten Set-Artikel.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS-Nord)
************************************************************************
   DATA: ART_LINES TYPE I,
        EAN_LINES TYPE I,
        WRG_LINES TYPE I.

  DATA: BEGIN OF T_ARTICLE OCCURS 50,
          MATNR LIKE MARA-MATNR,
          MLGUT LIKE MARA-MLGUT,
          MEINS LIKE MARA-MEINS.
  DATA: END OF T_ARTICLE.

  DATA: ls_t_article LIKE LINE OF t_article,
        lv_is_multi_lvl_struc_art TYPE abap_bool,
        lv_loopcounter TYPE I.

  DESCRIBE TABLE SO_MATNA LINES ART_LINES.
  DESCRIBE TABLE SO_EANNA LINES EAN_LINES.
  DESCRIBE TABLE SO_WRGNA LINES WRG_LINES.

* Nur bestimmte Artikel sollen versendet werden.
  IF ART_LINES <> 0 OR EAN_LINES <> 0 OR WRG_LINES <> 0.
*   Besorge Artikelnummern aus Tabelle MARA.
    IF ART_LINES <> 0.
      "Select full products, displays, prepacks and sales sets
      SELECT * FROM MARA
             APPENDING CORRESPONDING FIELDS OF TABLE T_ARTICLE
             WHERE MATNR IN SO_MATNA
             AND ( MLGUT <> SPACE OR ATTYP = if_struc_art_multi_lvl_const=>co_attyp-display_art
                                  OR ATTYP = if_struc_art_multi_lvl_const=>co_attyp-prepack_art
                                  OR ATTYP = if_struc_art_multi_lvl_const=>co_attyp-sales_set_art ).

    ENDIF.                             " ART_LINES <> 0.

*   Besorge Artikelnummern aus Tabelle MARA, über die EAN's.
    IF EAN_LINES <> 0.
      "Select full products, displays, prepacks and sales sets
      SELECT E~MATNR APPENDING CORRESPONDING FIELDS OF TABLE T_ARTICLE
                   FROM MEAN AS E INNER JOIN MARA AS M
                   ON    E~MATNR =  M~MATNR
                   WHERE E~EAN11 IN SO_EANNA
                  AND ( MLGUT <> SPACE OR ATTYP = if_struc_art_multi_lvl_const=>co_attyp-display_art
                                       OR ATTYP = if_struc_art_multi_lvl_const=>co_attyp-prepack_art
                                       OR ATTYP = if_struc_art_multi_lvl_const=>co_attyp-sales_set_art ).

    ENDIF.                             " EAN_LINES <> 0.


*   Besorge Artikelnummern aus Tabelle MARA über Warengruppen.
    IF WRG_LINES <> 0.
      "Select full products, displays, prepacks and sales sets
      SELECT * FROM MARA
             APPENDING CORRESPONDING FIELDS OF TABLE T_ARTICLE
              WHERE MATKL IN SO_WRGNA
              AND ( MLGUT <> SPACE OR ATTYP = if_struc_art_multi_lvl_const=>co_attyp-display_art
                                   OR ATTYP = if_struc_art_multi_lvl_const=>co_attyp-prepack_art
                                   OR ATTYP = if_struc_art_multi_lvl_const=>co_attyp-sales_set_art ).
    ENDIF.                             " WRG_LINES <> 0.

*   Lösche alle doppelten Einträge aus T_ARTICLE.
    SORT T_ARTICLE BY MATNR.
    DELETE ADJACENT DUPLICATES FROM T_ARTICLE
           COMPARING MATNR.

  CLEAR lv_loopcounter.
*Remove all displays, prepacks and sales sets which are no MSA, they have no follow on items
  LOOP AT T_ARTICLE INTO LS_T_ARTICLE.
    lv_loopcounter = lv_loopcounter + 1.
    lv_is_multi_lvl_struc_art = cl_struc_art_multi_lvl_generic=>get_single_instance( )->is_multi_lvl_struc_art(
          iv_matnr = ls_t_article-matnr
          iv_erfme = ls_t_article-meins
          ).
    "Only remove it is neither a full product, nor a MSA
    IF lv_is_multi_lvl_struc_art = abap_false AND LS_T_ARTICLE-MLGUT = space.
      DELETE t_article INDEX lv_loopcounter.
    ENDIF.
  ENDLOOP.

*   Übernehme Daten in Ausgabetabelle.
    CLEAR: PET_NART.
    PET_NART-ARTTYP = C_NARTTYP.
    LOOP AT T_ARTICLE.
      PET_NART-MATNR = T_ARTICLE-MATNR.
      APPEND PET_NART.
    ENDLOOP. " at t_article
  ENDIF. " ART_LINES <> 0 OR EAN_LINES <> 0 OR WRG_LINES <> 0.

* Fehlermeldung, falls keine Daten gefunden wurden.
  LOOP AT PET_NART
    WHERE ARTTYP = C_NARTTYP.
    EXIT.
  ENDLOOP.                           " AT PET_NART

  IF SY-SUBRC <> 0 AND
     ( ART_LINES <> 0 OR EAN_LINES <> 0 OR WRG_LINES <> 0 ).
*   'Es konnten keine Nachzugsartikel selektiert werden'
    MESSAGE I006.
    STOP.
  ENDIF. " SY-SUBRC <> 0 and ...



ENDFORM.                               " NART_GET


*eject
************************************************************************
FORM nart_equal_get
     TABLES pxt_article_equal STRUCTURE gt_article_equal.
************************************************************************
* FUNKTION:
* Bestimme die Gesamtmenge der, in den SELECT-OPTION-Tabellen mit
* 'EQUAL' angebenen Artikeln.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_ARTICLE_EQUAL: Ergebnismenge der selektierten Nachzugsartikel.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS-Nord)
************************************************************************
  DATA: ean_lines TYPE i.

  DATA: BEGIN OF t_eanna OCCURS 10,
          sign(1),
          option(2),
          low       LIKE mean-ean11,
          high      LIKE mean-ean11.
  DATA: END OF t_eanna.

  DATA: BEGIN OF t_article OCCURS 10,
          matnr LIKE mara-matnr.
  DATA: END OF t_article.

  CLEAR:   pxt_article_equal.
  REFRESH: t_eanna.

* Übernehme alle EQUAL-Einträge aus SELECT-OPTION-Tabelle
* SO_MATNA nach PXT_ARTICLE_EQUAL.
  LOOP AT so_matna
       WHERE sign   = c_insert
       AND   option = c_equal.
    APPEND so_matna-low TO t_article.
  ENDLOOP.                             " AT SO_MATNA.

* Übernehme alle EQUAL-Einträge aus SELECT-OPTION-Tabelle
* SO_EANNA nach T_EANNA.
  LOOP AT so_eanna
       WHERE sign   = c_insert
       AND   option = c_equal.
    APPEND so_eanna TO t_eanna.
  ENDLOOP.                             " AT SO_EANNA.

  DESCRIBE TABLE t_eanna LINES ean_lines.

* Besorge Artikelnummern aus Tabelle MARA, über die EAN's.
  IF ean_lines <> 0.
    SELECT * FROM mean
           APPENDING CORRESPONDING FIELDS OF TABLE t_article
           WHERE ean11 IN t_eanna.
  ENDIF.                               " EAN_LINES <> 0.

* Lösche alle doppelten Einträge aus T_ARTICLE.
  SORT t_article BY matnr.
  DELETE ADJACENT DUPLICATES FROM t_article
         COMPARING matnr.

* Übernehme Daten in Ausgabetabelle.
  CLEAR: pxt_article_equal.
  pxt_article_equal-arttyp = c_narttyp.
  LOOP AT t_article.
    pxt_article_equal-matnr = t_article-matnr.
    APPEND pxt_article_equal.
  ENDLOOP. " at t_article


ENDFORM.                               " NART_EQUAL_GET


*eject
************************************************************************
FORM kunnr_get TABLES pet_kunnr STRUCTURE wppdat.
************************************************************************
* FUNKTION:
* Bestimme alle Kundennummern, die den angegebenen
* Selektionsbedingungen genügen und fülle sie in Tabelle PET_ARTICLE.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_KUNNR: Ergebnismenge der selektierten Kundennummern.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS-Nord)
************************************************************************
  DATA: kunnr_lines TYPE i.

  DATA: BEGIN OF t_kunnr OCCURS 1,
          kunnr     LIKE knvv-kunnr,
          cvp_xblck LIKE kna1-cvp_xblck.
  DATA: END OF t_kunnr.


  REFRESH: pet_kunnr.
  CLEAR:   pet_kunnr.
  DESCRIBE TABLE so_kunnr LINES kunnr_lines.

* Nur bestimmte Kundennummern sollen versendet werden.
  IF kunnr_lines <> 0.
*   Besorge Kundennummern zur Vertriebsschiene aus Tabelle KNVV.
    SELECT v~kunnr cvp_xblck INTO CORRESPONDING FIELDS OF TABLE t_kunnr
           FROM knvv AS v INNER JOIN kna1 AS a
           ON    v~kunnr =  a~kunnr
           WHERE v~kunnr IN so_kunnr
           AND   v~vkorg  = pa_vkorg
           AND   v~vtweg  = pa_vtweg
           AND   a~werks =  space.

    IF sy-subrc <> 0.
*     'Es konnten keine Kundennummern für Vkorg. &
*      und Vtweg. & selekt. werden'.
      MESSAGE i007 WITH pa_vkorg pa_vtweg.
      STOP.
    ENDIF. " SY-SUBRC <> 0

*   Lösche alle doppelten Einträge aus T_KUNNR.
    SORT t_kunnr BY kunnr.
    DELETE ADJACENT DUPLICATES FROM t_kunnr
           COMPARING kunnr.

*   Übernehme die Einträge in Ausgabetabelle.
    LOOP AT t_kunnr.
      APPEND t_kunnr TO pet_kunnr.
    ENDLOOP. " at t_kunnr.

  ENDIF. " KUNNR_LINES <> 0.


ENDFORM.                               " KUNNR_GET
*&---------------------------------------------------------------------*
*&      Form  BBUY_GET
*&---------------------------------------------------------------------*
FORM bbuy_get TABLES   pt_bbuy        STRUCTURE gt_bbuy
              USING    pi_loeschen    LIKE      wpstruc-modus
                       pi_bby_ext_del LIKE      wpstruc-modus.
************************************************************************
* FUNKTION:
* Bestimme alle Bonus-Käufe, die den angegebenen
* Selektionsbedingungen genügen und fülle sie in Tabelle PT_BBUY.
* ---------------------------------------------------------------------*
* PARAMETER:
* PT_BBUY    : Ergebnismenge der selektierten Bonus-Käufe.
*
* PI_LOESCHEN: = 'X', wenn Löschdatensätze erzeugt werden sollen.
*
* PI_BBY_EXT_DEL: Löschen der Bonuskäufe über externen Programm, d. h.
*                 alle nötigen Löschdaten werden bereits mitgegeben.
* ----------------------------------------------------------------------
* Erweiterung Bonus-Buys (Release 99A, GL)
************************************************************************
* Deklarationen
  DATA: bbuy_lines TYPE i,
        l_datfr    LIKE sy-datum,
        l_datbis   LIKE sy-datum,
        l_vkorg    LIKE t001w-vkorg,
        l_vtweg    LIKE t001w-vtweg,
        l_unit     LIKE mara-meins.
  DATA: dat_ab_temp  LIKE sy-datum,
        dat_bis_temp LIKE sy-datum.
  DATA: i_vzeit LIKE twpfi-vzeit.
  DATA: l_t_filmat LIKE konbby_key OCCURS 0 WITH HEADER LINE.

  DATA: single_values_bby LIKE sy-marky.                    "914690

  DATA: BEGIN OF t_bbynr OCCURS 10,
          bbynr LIKE konbbyh-bbynr.
  DATA: END OF t_bbynr.

  REFRESH: pt_bbuy.
  CLEAR:   pt_bbuy.
  CLEAR: dat_ab_temp.
  CLEAR: dat_bis_temp.

  DATA: l_vake    LIKE vake,
        l_komg    LIKE komg,
        l_kvewe   LIKE  vake-kvewe,
        l_kappl   LIKE  vake-kappl,
        l_kotabnr LIKE  vake-kotabnr,
        l_kschl   LIKE  vake-kschl.


*-----------------------------------------------------------------------
* Selektion der Bonus-Käufe
*-----------------------------------------------------------------------
* 1. Schritt: Lesen Bonuskaufnummern aus KONBBYH
*-----------------------------------------------------------------------
  DESCRIBE TABLE so_bbuy LINES bbuy_lines.

* Falls manuelle Auswahl.
  IF bbuy_lines <> 0.
*   Löschen nicht über externes Programm, d. h. Existenzprüfung nötig.
    IF pi_bby_ext_del IS INITIAL.

*     check if in SO_BBUY are only single values       begin 914690 *
      single_values_bby = 'X'.

      LOOP AT so_bbuy WHERE NOT sign   EQ 'I'  OR
                            NOT option EQ 'EQ'.
*       no single value
        CLEAR single_values_bby.
        EXIT.
      ENDLOOP.                                        "end   914690

*     Lesen der angegebenen Bonuskäufe
      IF single_values_bby IS NOT INITIAL.            "begin 914690
        SELECT bbynr INTO  CORRESPONDING FIELDS OF TABLE t_bbynr
                     FROM  konbbyh
                     FOR ALL ENTRIES IN so_bbuy
                     WHERE bbynr = so_bbuy-low.
      ELSE.                                           "end   914690
        SELECT bbynr INTO  CORRESPONDING FIELDS OF TABLE t_bbynr
                     FROM  konbbyh
                     WHERE bbynr IN so_bbuy.
      ENDIF.                                                "914690

*   Löschen über externes Programm, d. h. keine Existenzprüfung nötig.
    ELSE. " not pi_bby_ext_del is initial.
      LOOP AT so_bbuy.
        APPEND so_bbuy-low TO t_bbynr.
      ENDLOOP. " at so_bbuy.
    ENDIF. " pi_bby_ext_del is initial.

* Fall Download über alle Bonuskäufe.
  ELSE.
*   Lesen aller Bonuskäufe
    SELECT bbynr INTO CORRESPONDING FIELDS OF TABLE t_bbynr
                 FROM konbbyh.
  ENDIF.

* Falls nur Lösch-IDOC's erzeugt werden sollen, dann keine
* weiteren Daten besorgen. Die Bonuskaufnr. reicht aus.
  IF NOT pi_loeschen IS INITIAL.
*   Aufbau der Übergabetabelle.
    CLEAR: t_bbynr.
    LOOP AT t_bbynr.
      pt_bbuy-bby_nr   = t_bbynr-bbynr.
      APPEND pt_bbuy.
    ENDLOOP. "at t_bbynr.

    EXIT.
  ENDIF. " not pi_loeschen is initial.

** Zeitintervall für Bonuskauf
*  if pa_datbi is initial.
** Zeitintervall aus aktuellem Datum und maximalem Vorschauhorizont
*    select max( vzeit ) from twpfi into i_vzeit.
*    if sy-subrc = 0.
*      dat_bis_temp = sy-datum + i_vzeit.
*    else.
*      dat_bis_temp = sy-datum + 999.
*    endif.
*    if dat_ab_temp is initial.
*      dat_ab_temp = sy-datum.
*    else.
*      dat_ab_temp = pa_datab.
*    endif.
*
*  else.
** Zeitintervall von Selektionsbild
*    dat_ab_temp = pa_datab.
*    dat_bis_temp = pa_datbi.
*  endif.

* Ermittle Zeitintervalle für Bonuskauf
  IF pa_datab IS INITIAL.
    dat_ab_temp = sy-datum.
  ELSE.
    dat_ab_temp = pa_datab.
  ENDIF.

  IF pa_datbi IS INITIAL.

    SELECT MAX( vzeit ) FROM twpfi INTO i_vzeit.
    IF sy-subrc = 0.
      dat_bis_temp = dat_ab_temp + i_vzeit.
    ELSE.
      dat_bis_temp = dat_ab_temp + 999.
    ENDIF.

  ELSE.
* Zeitintervall von Selektionsbild
    dat_bis_temp = pa_datbi.
  ENDIF.

  CHECK dat_bis_temp >= dat_ab_temp .




*-----------------------------------------------------------------------
* 2. Schritt: Aufbau der Übergabetabelle pt_bby für MASTERIDOC_CREATE
*-----------------------------------------------------------------------
  LOOP AT t_bbynr.

    CLEAR l_t_filmat.
    REFRESH l_t_filmat.

    CALL FUNCTION 'BBY_GET_CONDITION_BY_BBYNR'
      EXPORTING
        ip_bbynr               = t_bbynr-bbynr
        ip_date_from           = dat_ab_temp
        ip_date_to             = dat_bis_temp
      IMPORTING
        ep_kvewe               = l_kvewe
        ep_kappl               = l_kappl
        ep_kotabnr             = l_kotabnr
        ep_kschl               = l_kschl
      TABLES
        et_key_data            = l_t_filmat
      EXCEPTIONS
        invalid_date           = 1
        kotab_not_found        = 2
        matnr_not_in_kotab     = 3
        cond_data_not_found    = 4
        access_data_not_found  = 5
        kotab_structure_faulty = 6
        OTHERS                 = 7.

    IF sy-subrc <> 0.
*     Bearbeitung des Bonuskaufs fehlerhaft
      CONTINUE.
    ENDIF.

*   Aufbau der Übergabetabelle
    LOOP AT l_t_filmat.
      MOVE-CORRESPONDING l_t_filmat TO l_vake.
      l_vake-kvewe = l_kvewe.
      l_vake-kappl = l_kappl.
      l_vake-kotabnr = l_kotabnr.
      l_vake-kschl = l_kschl.

      CALL FUNCTION 'MM_VAKEY_TO_2LINES'
        EXPORTING
          variable_key            = l_vake
          only_komg               = 'X'
        IMPORTING
          e_komg                  = l_komg
        EXCEPTIONS
          invalid_condition_table = 1
          error_calculating_vakey = 2
          OTHERS                  = 3.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      l_vkorg = l_komg-vkorg.
      l_vtweg = l_komg-vtweg.
      l_datfr = l_t_filmat-datab.
      l_datbis = l_t_filmat-datbi.

*     Check Verkaufsorganisation und Vertriebsweg
      IF ( NOT l_vkorg IS INITIAL AND l_vkorg NE pa_vkorg ) OR
         ( NOT l_vtweg IS INITIAL AND l_vtweg NE pa_vtweg ).
*       Falsche Vertriebslinie => Bearbeitung dieses Bonuskaufes fehlerh.
        CONTINUE.
      ENDIF.

      pt_bbuy-bby_nr   = t_bbynr-bbynr.
      pt_bbuy-knumh    = l_t_filmat-knumh.
      pt_bbuy-datab    = l_datfr.
      pt_bbuy-datbis   = l_datbis.
      pt_bbuy-vkorg    = pa_vkorg.
      pt_bbuy-vtweg    = pa_vtweg.
      pt_bbuy-filiale  = l_t_filmat-storenr.
      pt_bbuy-mat_nr   = l_t_filmat-matnr.
      pt_bbuy-pltyp    = l_t_filmat-pltyp.

      IF l_t_filmat-matunit IS INITIAL.
*        Lesen der Basismengeneinheit aus MARA
        SELECT SINGLE meins FROM mara INTO l_unit
                            WHERE matnr = l_t_filmat-matnr.
        IF sy-subrc = 0.
          l_t_filmat-matunit = l_unit.
        ENDIF.
      ENDIF.
      pt_bbuy-mat_unit = l_t_filmat-matunit.
      pt_bbuy-var_key  = l_t_filmat-vakey.
      APPEND pt_bbuy.
    ENDLOOP. "at l_t_filmat.

  ENDLOOP. "at t_bbynr.


ENDFORM.                    " BBUY_GET
*&---------------------------------------------------------------------*
*&      Form  PROMOTION_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_PROMO  text
*      -->P_GT_LOCNR  text
*----------------------------------------------------------------------*
FORM promotion_get TABLES   pet_promo STRUCTURE gt_promo.
************************************************************************
* FUNKTION:
* Bestimme alle Aktionen, die den angegebenen
* Selektionsbedingungen genügen und fülle sie in Tabelle PET_PROMO.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_PROMO: Ergebnismenge der selektierten Aktionen.
* ----------------------------------------------------------------------
* Erweiterung Aktionsrabatte, rz 19.05.00
************************************************************************

  DATA: l_datab LIKE sy-datum,
        l_datbi LIKE sy-datum.

  CHECK NOT so_promo[] IS INITIAL.

* Bestimme Zeitraum für Selektion
  IF pa_datab IS INITIAL.
    l_datab = sy-datum.
  ELSE.
    l_datab = pa_datab.
  ENDIF.
  IF pa_datbi IS INITIAL.
    l_datbi = l_datab + 1000.
*   (größtmöglicher Vorschauhorizont für Filialen 999 Tage)
  ELSE.
    l_datbi = pa_datbi.
  ENDIF.

  CLEAR pet_promo.
  REFRESH pet_promo.

* Suche alle Aktionen mit aktivierten Aktionsrabatten
  SELECT wakh~aktnr
    FROM wakh INNER JOIN wakr
      ON wakh~aktnr = wakr~aktnr
    INTO TABLE pet_promo
   WHERE wakh~aktnr IN so_promo
     AND wakh~vkdab LE l_datbi
     AND wakh~vkdbi GE l_datab
     AND wakr~reb_status = 'B'.        " aktiviert

* Fehlermeldung, falls keine Daten gefunden wurden.
  IF sy-subrc <> 0.
*   'Es konnte keine Aktion selektiert werden'
    MESSAGE i040.
    STOP.
  ENDIF.                               " sy-subrc <> 0 ...

* Duplikate entfernen
  SORT pet_promo.
  DELETE ADJACENT DUPLICATES FROM pet_promo.

ENDFORM.                    " PROMOTION_GET
