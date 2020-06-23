*----------------------------------------------------------------------*
*   INCLUDE LWPUEECO                                                   *
*                                                                      *
*   Enthält Konstante, die die POS-Schnittstelle für weitere           *
*   Programme zur Verfügung stellt.                                    *
*                                                                      *
*----------------------------------------------------------------------*

* IDOC-/Message-Typen ...

**  Währungstabelle
data: c_idoctype_cur  like edimsg-idoctyp value 'WPDCUR01', " Zw.Strukt.
      c_mestype_cur   like edimsg-mestyp  value 'WPDCUR'.   " Msg.-Type.

**  Nachzugsartikel
data: c_idoctype_nart like edimsg-idoctyp value 'WPDNAC01', " Zw.Struk
      c_mestype_nart  like edimsg-mestyp  value 'WPDNAC'.   " Msg.-Type.

**  Setzuordnungen
data: c_idoctype_set like edimsg-idoctyp value 'WPDSET01', " Zw.Strukt.
      c_mestype_set  like edimsg-mestyp  value 'WPDSET'.   " Msg.-Type.

**  Steuersätze
data: c_idoctype_steu like edimsg-idoctyp value 'WPDTAX01', " Zw.Strukt.
      c_mestype_steu  like edimsg-mestyp  value 'WPDTAX'.   " Msg.-Type.

**  Warengruppen
data: c_idoctype_wrgp like edimsg-idoctyp value 'WPDWGR01', " Zw.Struk
      c_mestype_wrgp  like edimsg-mestyp  value 'WPDWGR'.   " Msg.-Type

**  Verkaufsbelege detailliert
data: c_idoctype_bon like edimsg-idoctyp value 'WPUBON01', " Zw.Strukt.
      c_mestype_bon  like edimsg-mestyp  value 'WPUBON'.   " Msg.-Type.
data: c_seg_bon      like edidd-segnam   value 'E1WPB01'.  " ID-Segment

**  Fehlermeldungen
data: c_idoctype_err like edimsg-idoctyp value 'WPUERR01', " Zw.Strukt.
      c_mestype_err  like edimsg-mestyp  value 'WPUERR'.   " Msg.-Type.
data: c_seg_err      like edidd-segnam   value 'E1WER01'.  " ID-Segment

**  Finanzbuchhaltungsbelege (Kassenbelege)
data: c_idoctype_fib like edimsg-idoctyp value 'WPUFIB01', " Zw.Strukt.
      c_mestype_fib  like edimsg-mestyp  value 'WPUFIB'.   " Msg.-Type.
data: c_seg_fib      like edidd-segnam   value 'E1WPF01'.  " ID-Segment

**  Zahlungsliste
data: c_idoctype_tab like edimsg-idoctyp value 'WPUTAB01', " Zw.Strukt.
      c_mestype_tab  like edimsg-mestyp  value 'WPUTAB'.   " Msg.-Type.
data: c_seg_tab      like edidd-segnam   value 'E1WPZ01'.  " ID-Segment

**  Umsatz (verdichtet)
data: c_idoctype_acc like edimsg-idoctyp value 'WPUUMS01', " Zw.Strukt.
      c_mestype_acc  like edimsg-mestyp  value 'WPUUMS'.   " Msg.-Type.
data: c_seg_acc      like edidd-segnam   value 'E1WPU01'.  " ID-Segment

**  Warenbewegungen
data: c_idoctype_inv like edimsg-idoctyp value 'WPUWBW01', " Zw.Strukt.
      c_mestype_inv  like edimsg-mestyp  value 'WPUWBW'.   " Msg.-Type.
data: c_seg_inv      like edidd-segnam   value 'E1WPG01',  " ID-Segment
      c_seg_inv_pos  like edidd-segnam   value 'E1WPG02'.  " ID-Sgement

**  Kassiererstatistik
data: c_idoctype_ksr like edimsg-idoctyp value 'WPUKSR01', " Zw.Strukt.
      c_mestype_ksr  like edimsg-mestyp  value 'WPUKSR'.   " Msg.-Type.
data: c_seg_ksr      like edidd-segnam   value 'E1WPK01',  " Kopf
      c_seg_ksr_pos  like edidd-segnam   value 'E1WPK02'.  " Positionen

**  EAN-Zuordnungen
data: c_idoctype_ean like edimsg-idoctyp value 'WP_EAN01', " Zw.Strukt.
      c_mestype_ean  like edimsg-mestyp  value 'WP_EAN',   " Msg.-Type.
      c_seg_eanref   like edidd-segnam   value 'E1WPE01',  " ID-Segment
      c_seg_ean_item like edidd-segnam   value 'E1WPE02'.  " Position

**  Personenstamm (Kunden, Mitarbeiter)
data: c_idoctype_pers like edimsg-idoctyp value 'WP_PER01', " Zw.Strukt.
      c_mestype_pers  like edimsg-mestyp  value 'WP_PER'. " Msg.-Type.

**  Artikelstamm
*{   REPLACE        XB4K001679                                        1
*\data: c_idoctype_artstm  like edimsg-idoctyp                         \
*\   value 'WP_PLU02'," Zw.Struk
* WRF_POSOUT
data: c_idoctype_artstm  like edimsg-idoctyp value 'WP_PLU03'," Zw.Struk
* WRF_POSOUT
*}   REPLACE
      c_idoctype_artstm01  like edimsg-idoctyp value 'WP_PLU01',
      c_mestype_artstm  like edimsg-mestyp  value 'WP_PLU'. " Msg.-Type
data: c_seg_artstm      like edidd-segnam   value 'E1WPA01'." ID-Segment

*** Bonuskäufe/Erweiterung Rel. 99a (GL)
data: c_idoctype_bby like edimsg-idoctyp value 'WPDBBY01',
      c_mestype_bby  like edimsg-mestyp  value 'WPDBBY'.
**

* begin of insertion, note 315443
* Erweiterung Aktionsrabatte, rz 22.05.00
data: c_idoctype_prom like edimsg-idoctyp value 'WPDREB01',
      c_mestype_prom  like edimsg-mestyp  value 'WPDREB'.
* rz
* end of insertion, note 315443

* Verarbeitungs-Funktionen für IDOC's (Eingangsseite) ...

**  IDOC-Parser allgemein ...
data: c_function_pars like wplst-function value 'PARS'.

**  POS-Eingangsverarbeitung allgemein ...
data: c_function_pinp like wplst-function value 'PINP'.

**  Faktura an Kunden der Filiale
data: c_function_fakt like wplst-function value 'FAKT'.

**  Bestandsführung
data: c_function_best like wplst-function value 'BEST'.

**  Faktura an Kreditkarten-Institut
data: c_function_kfak like wplst-function value 'KFAK'.

**  Rechnungswesen-Beleg
data: c_function_fibu like wplst-function value 'FB01'.

**  Statistik-Schnittstelle
data: c_function_stat like wplst-function value 'STAT'.

**  WE zur Bestellung
data: c_function_mb01 like wplst-function value 'MB01'.

**  WE zur unbekannten Bestellung
data: c_function_mb0a like wplst-function value 'MB0A'.

**  WE zur unbekannten Bestellung
data: c_function_me21 like wplst-function value 'ME21'.

**  WE zur Lieferung
data: c_function_vl07 like wplst-function value 'VL07'.

** WE (Versandelement) zur Bestellung
data: c_function_shun like wplst-function value 'SHUN'.

**  Warenbewegung ohne Referenzbeleg
data: c_function_mb11 like wplst-function value 'MB11'.

** Fehler in den WE-Buchungen: Report
data: c_function_repo like wplst-function value 'REPO'.

**  Automatische EAN-Anlage
data: c_function_ean  like wplst-function value 'AEAN'.

**  Filialinventur und Umbewertung
data: c_function_wvin like wplst-function value 'WVIN'.

** Function name for delivery IDoc
data: c_function_delv like wplst-function value 'VL33'.

** Filialaufträge
constants: c_function_ords like wplst-function value 'ORDS'.
constants: c_function_wgsr like wplst-function value 'WGSR'.
constants: c_function_allo like wplst-function value 'ALLO'.

* Message-ID's

** Meldungen von externen Systemen

data: c_message_id_external_systems like sy-msgid value 'W9'.
