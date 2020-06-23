*------------------------------------------------------------------
*  Module MARC-XCHPF.
*
*  Beim Ändern des Kennzeichens Chargenpflicht wird geprüft, ob
*  diese Änderung erlaubt ist.
*  - die vorhandenen Objekte zum Material werden überprüft. Dies
*    geschieht auch bei der Erweiterung eines Werkes, da bei kundenspez.
*    Änderung des Pflegestatus des Feldes Chargenpflicht ein Werk
*    ohne Pflege der Chargenpflicht angelegt werden könnte.
*    ab 2.0 auch Prüfung bzgl. Kundenkonsi- und Kundenleergutbestände
*    ab 2.1 auch Prüfung bzgl. Lieferantenbeistellungs- und Kunden-
*       auftragsbestand
*  - Chargeneinzelbewertung darf bei Rücknahme der Chargenpflicht nicht
*    vereinbart sein (Für MBEW-BWTTY sitzt Kz. Bewertungsart automat.)
*    (auch bei Neuanlage zu überprüfen, da Buchhaltungsdaten zuerst
*    gepflegt werden können)
*  Nach erfolgreicher Änderung wird das Rettfeld RET_XCHPF aktualisiert.
*------------------------------------------------------------------
MODULE marc-xchpf.

  CHECK t130m-aktyp NE aktypa AND t130m-aktyp NE aktypz.
  CHECK bildflag IS INITIAL.           "mk/21.04.95


*
*if rmmg2-chargebene <> chargen_ebene_0 and mara-xchpf = 'X'.
*    LOOP AT SCREEN.
*
*      IF screen-name EQ 'MARC-XCHPF'.
*
*        screen-invisible = '0'.
*        screen-active = '1'.
*        screen-input = '1'.
*
*        MODIFY SCREEN.
*      ENDIF.
*
*    ENDLOOP.
*    ELSEif rmmg2-chargebene <> chargen_ebene_0 and mara-xchpf <> 'X'.
*      LOOP AT SCREEN.
*
*      IF screen-name EQ 'MARC-XCHPF'.
*
*        screen-invisible = '0'.
*        screen-active = '1'.
*        screen-input = '0'.
*
*        MODIFY SCREEN.
*      ENDIF.
*
*    ENDLOOP.
*  ENDIF.

  IF rmmg2-chargebene = chargen_ebene_0.    "ch zu 3.0C
    hxchpf = lmarc-xchpf.              "-> IPr. 366/1996
  ELSE.
    hxchpf = lmarc-xchpf. "lmara-xchpf change to lmarc-xchpf after new batch handling scenario
  ENDIF.


ENHANCEMENT-SECTION     lmgd1i1v_01 SPOTS es_lmgd1i1v INCLUDE BOUND.
  IF rmmg1-werks IS NOT INITIAL.
      CALL FUNCTION 'MARC_XCHPF'
      EXPORTING
        neuflag           = neuflag
        chargen_ebene     = rmmg2-chargebene
        mara_in_matnr     = rmmg1-matnr
        wmarc_xchpf       = marc-xchpf
        wmara_xchpf       = mara-xchpf
        ret_xchpf         = hxchpf
        marc_in_werks     = rmmg1-werks
        wrmmg1_bwkey      = rmmg1-bwkey
        wmarc_sernp       = marc-sernp
        wmara_mtart       = mara-mtart  "ch zu 4.0
        wmara_kzwsm       = mara-kzwsm  "ch zu 4.0
        wmara_vpsta       = mara-vpsta  "ch zu 4.5b
        p_kz_no_warn      = space  "ch zu 3.0F
        sperrmodus        = sperrmodus  "fbo/171298
* Mill 0024 Single Unit Batch SW            "/SAPMP/PIECEBATCH "{ ENHO /SAPMP/PIECEBATCH_LMGD1I1V IS-MP-MM /SAPMP/SINGLE_UNIT_BATCH }
        wmara_dpcbt       = mara-dpcbt
        wmarc_dpcbt       = marc-dpcbt  "/SAPMP/PIECEBATCH "{ ENHO /SAPMP/PIECEBATCH_LMGD1I1V IS-MP-MM /SAPMP/SINGLE_UNIT_BATCH }
      IMPORTING
        wmarc_xchpf       = marc-xchpf
        wmara_xchpf       = mara-xchpf
      EXCEPTIONS
        error_nachricht   = 01
        error_call_screen = 02.
 ENDIF.
END-ENHANCEMENT-SECTION.


  IF sy-subrc NE 0.                    "Zurücksetzen der Chargenebene
    IF rmmg2-chargebene NE chargen_ebene_a.
      IF mara-xchpf = space AND marc-xchpf <> space.
        mara-xchpf = x.
*      ELSEIF marc-xchpf = space.
*        marc-xchpf = x.
*        mara-xchpf = x.
      ENDIF.

    ELSE.
      IF marc-xchpf = space.
        marc-xchpf = x.
      ELSE.
        marc-xchpf = space.
      ENDIF.
    ENDIF.
  ENDIF.

ENHANCEMENT-POINT lmgd1i1v_02 SPOTS es_lmgd1i1v INCLUDE BOUND.

  CASE sy-subrc.
    WHEN '1'.
*---- Chargenpflicht nicht änderbar --------------------------------
      MOVE lmarc-xchpf TO marc-xchpf.
      rmmzu-flg_fliste = x.
      rmmzu-err_chpf   = x.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      bildflag = x.
    WHEN '2'.
*---- Chargenpflicht nicht änderbar --------------------------------
      MOVE lmarc-xchpf TO marc-xchpf.
      rmmzu-flg_fliste = x.
      rmmzu-err_chpf   = x.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      bildflag = x.
  ENDCASE.

  IF rmmg2-chargebene NE chargen_ebene_a.
    IF mara-xchpf IS INITIAL AND mara-sgt_covsa IS NOT INITIAL AND mara-sgt_scope EQ '1'.
      mara-xchpf = x.
      MESSAGE w126(sgt_01).
*   Batch management is mandatory when scope of segmentation strategy is 1
    ENDIF.
  ELSE.
    IF marc-xchpf IS INITIAL AND marc-sgt_covs IS NOT INITIAL AND marc-sgt_scope EQ '1'.
      marc-xchpf = x.
      MESSAGE w126(sgt_01).
*   Batch management is mandatory when scope of segmentation strategy is 1
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MARA_XCHPF  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mara_xchpf INPUT.

  IF marc-werks IS NOT INITIAL.

*    SELECT SINGLE xchpf INTO lv_temp_mxchpf FROM mara BYPASSING BUFFER WHERE matnr = marc-matnr.
*    IF sy-subrc = 0 AND lv_temp_mxchpf = 'X'.
*
*      SELECT SINGLE xchpf INTO lv_temp_xchpf FROM marc BYPASSING BUFFER WHERE werks = marc-werks AND matnr = marc-matnr.
*
*      IF sy-subrc = 0 AND lv_temp_xchpf IS INITIAL.
*        EXIT.
*      ENDIF.
*    ENDIF.
    IF rmmg2-flg_isbatch <> 'X' or gv_isbatch IS INITIAL. "Global flag
      "default

      IF mara-xchpf IS NOT INITIAL.
        IF cl_vb_batch_factory=>util( )->get_default_batch_handling( iv_plant = marc-werks ).
          marc-xchpf = mara-xchpf.
          marc-xchar = marc-xchpf.
          IF t130m-aktyp NE aktypa OR t130m-aktyp NE aktypz.
            MESSAGE w662(mm).
          ENDIF.
        ELSE.
          CLEAR marc-xchpf.
          CLEAR marc-xchar.
        ENDIF.

        rmmg2-flg_isbatch  = 'X'.
        gv_isbatch = 'X'.
      ENDIF.
    ELSE.
      IF mara-xchpf IS INITIAL.

        CLEAR rmmg2-flg_isbatch.
        CLEAR gv_isbatch.
      ENDIF.
    ENDIF.

  ENDIF.

ENDMODULE.
