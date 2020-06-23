*------------------------------------------------------------------
*  Module MBEW-BWTTY
*
*  Der Bewertungstyp ist nur eingebbar für den Fall, daß die
*  Bewertungsart ungefüllt ist. Die Eingabe wird über Fremdschlüssel-
*  Beziehung verprobt.
*
*- Anlage eines Bewertungskopfsatzes mit Bewertungstyp
*  - vorhandene MARC-Sätze zum Bewertungskreis sind zu aktualisieren
*    hinsichtlich des Kz. Chargenführung sowie des Bewertungstyps
*    (im Verbucher, dabei wird auch ein evtl. parallel angelegter
*    MARC-Satz berücksichtigt)
*    Dazu wird die MARC exklusiv und generisch zum Material gesperrt
*    Im Falle von Chargeneinzelbewertung wird die Chargenpflicht für
*    -  bereits vorhandene Werke zugehörige Werke geprüft. Es muß
*       für alle diese Werke Chargenpflicht vereinbart sein, sonst
*       ist der Bewertungstyp nicht erlaubt
*    -  ein parallel anzulegendes/angelegtes Werk hart gesetzt
*       (im Modul Sonfausw_in_fgruppen, falls Bild mit Chargenpflicht
*       prozessiert wird, ansonsten im Okcode_buchen).
*- Ändern des Bewertungstyps
*  Beim Ändern des Bewertungstyps wird geprüft, ob diese Änderung
*  erlaubt ist. Sobald dafür mehrere Werke gelesen werden müssen,
*  wird die MARC exclusiv und generisch zum Material gesperrt:
*  1. Wechsel von einheitlicher Bewertung auf getrennte Bewertung:
*     - bewerteter Bestand darf nicht vorhanden sein und es darf
*       keine Inventur aktiv sein
*     - Chargen dürfen nicht vorhanden sein (Bewertungsart fehlt)
*       ---> Reservierungen ok, Sonderbestände ok
*     - Bestellungen dürfen nicht vorhanden sein, da BWTTY
*       aus Bestellung an Bestandsführung übergeben wird und beim
*       Ändern der Bewertungsart verwendet werden
*  2. Wechsel von getrennter Bewertung auf einheitliche Bewertung:
*     - bewerteter Bestand darf nicht vorhanden sein
*     - Einzelbewertungssätze dürfen nicht vorhanden sein
*       ---> keine Chargen vorhanden --> keine Inventur aktiv
*     - Bestellungen dürfen nicht vorhanden sein (siehe Punkt 1)
*  3. Wechsel des Typs der getrennten Bewertung
*     - die vorhandenen Bewertungseinzelsätze müssen zum neuen
*       Bewertungstyp passen (nur kritisch, wenn für den neuen
*       Bewertungstyp keine automatische Anlage der Einzelsätze
*       vorgesehen ist) ---> Chargen ok, Bestand ok, Inventur ok
*     - Bestellungen dürfen nicht vorhanden sein (siehe Punkt 1)
*       Ist dies der Fall, so wird ein Kennzeichen zur Anpassung der
*       Bewertungstypen der Einzelsätze im Verbucher gesetzt
*  4. Zusatzprüfung, falls der neue Bewertungstyp Chargeneinzelbe-
*     wertung vereinbart:
*     Prüfen aller zugehörigen Werke zum Bewertungstyp auf Chargen-
*     pflicht
*  - aktualisieren der MARC-Sätze zum Bewertungskreis hinsichtlich
*    des Kz. Chargenführung im Verbucher, falls der Bewertungstyp von
*    space auf ungleich space bzw. umgedreht geändert wird
*    zusätzlich immer hinsichtlich des Bewertungstyps
*
*  Lesen der T149 zum neuen Bewertungstyp, falls er nicht initial ist.
*------------------------------------------------------------------
MODULE mbew-bwtty.

  IF mbew-bwtty IS NOT INITIAL.
    IF mbew-bwtty EQ 'R' AND mara-/cwm/xcwmat EQ 'X'.
      LOG-POINT ID /cwm/enh SUBKEY to_upper( sy-tcode && '\/CWM/APPL_MM_LMGD1I3R_EHP4\EHP604_LMGD1I3R_01\' && sy-cprog ) FIELDS /cwm/cl_enh_layer=>get_field( ).
      MESSAGE e089(/cwm/mm).
** Split Valuation with the valuation category “Retail” will be in CWM not supported.
      bildflag = x.
      EXIT.
    ENDIF.
  ENDIF.

ENHANCEMENT-POINT ehp604_lmgd1i3r_01 SPOTS es_lmgd1i3r INCLUDE BOUND .

  CHECK t130m-aktyp NE aktypa AND t130m-aktyp NE aktypz.
  CHECK bildflag IS INITIAL.             "mk/21.04.95

  CALL FUNCTION 'MBEW_BWTTY'
    EXPORTING
      wmbew_bwtty     = mbew-bwtty
      wmbew_bwkey     = mbew-bwkey
      wmbew_bwtar     = mbew-bwtar
      wmbew_salk3     = mbew-salk3
      wmbew_lbkum     = mbew-lbkum
      wmbew_mlmaa     = mbew-mlmaa
      wmbew_kaln1     = mbew-kaln1
      ombew_bwtty     = *mbew-bwtty
      wrmmg1_werks    = rmmg1-werks
      wmarc_sernp     = marc-sernp
      wmarc_xchpf     = marc-xchpf                   "BE/241096
      wmara_xchpf     = mara-xchpf
      wmara_mtart     = mara-mtart             "ch zu 4.0
      wrmmg1_matnr    = rmmg1-matnr
* (del)     FLGBWTTY          = RMMG2-FLGBWTTY               "BE/081196
* (del)     FLGXCHAR_BEW      = RMMG2-XCHAR_BEW              "BE/081196
* (del)     FLGXCHPF_HART     = RMMG2-XCHPF_HART             "BE/301096
      neuflag         = neuflag
      p_aktyp         = t130m-aktyp
      chargen_ebene   = rmmg2-chargebene
      flg_retail      = rmmg2-flg_retail       "ch zu 4.0C
    IMPORTING
      wmbew_bwtty     = mbew-bwtty
      wmarc_xchpf     = marc-xchpf                   "BE/241096
      wmara_xchpf     = mara-xchpf             "ch zu 3.0C
* (del)     FLGBWTTY          = RMMG2-FLGBWTTY               "BE/081196
* (del)     FLGXCHAR_BEW      = RMMG2-XCHAR_BEW              "BE/081196
* (del)     FLGXCHPF_HART     = RMMG2-XCHPF_HART             "BE/301096
    TABLES
      p_ptab          = ptab
    EXCEPTIONS
      error_bwtty     = 01
      set_error_bwtty = 02.

  CASE sy-subrc.
    WHEN '1'.
*---- Bewertungstyp nicht änderbar ---------------------------------
      MOVE *mbew-bwtty TO mbew-bwtty.
      rmmzu-flg_fliste = x.
      rmmzu-err_bwtty  = x.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      bildflag = x.
    WHEN '2'.
*---- Bewertungstyp nicht änderbar ---------------------------------
      MOVE *mbew-bwtty TO mbew-bwtty.
      rmmzu-flg_fliste = x.
      rmmzu-err_bwtty  = x.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      bildflag = x.
  ENDCASE.

ENDMODULE.
