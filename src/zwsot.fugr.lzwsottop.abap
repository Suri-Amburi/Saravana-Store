FUNCTION-POOL ZWSOT MESSAGE-ID WM.


* ==================================================================== *
*   Funktionsgruppe WSOT
*   globale Daten
*
*   Änderung:
*   21.05.97    PETERW    Freigabe interner Test
*
*
* ==================================================================== *

include mwwconst.                "globale Konstanten WWS
include mwwglobv.                "globale Variable WWS
include mm07mabc.                "Alphabet, Zahlen, ...

************************************************************************
*  1.  Table Controls
************************************************************************

************************************************************************
*  2.  Sonstiges
************************************************************************
* Tabellen ************************************************************

tables : wrsz, wrs1, wrst, wrs6.



tables : twlv, twlag, v_sonu,
         twpa,
         *twlv,
         twlvt,
         twss,
         twsp, *twsp,
         tvtw, *tvtw, tvtwt,
         tvko, *tvko, tvkot,
         mvke,
         marm,
         wrf4,
         wrf1, wint_sortr, v_sotr,
               wint_carrh, *wint_carrh,
               wint_carrs, *wint_carrs,
               wint_carrw, *wint_carrw,
               wint_carrl, *wint_carrl,
               wint_carra, *wint_carra,
         twglv,
         wrf6,
         wrf3,
         t149d, t077d, tpakd,
         t023,
         t023t,
         t001w, t001k, tvkov,         *t001w,
         wint_betr, tvkwz,
         *wint_betr,
         wint_loc,
         wint_sl,
         wint_pos, *wint_pos,
         wint_ferr,
         twlwr,
         kna1, knvv, knvp, tpar,
         inri,
         dd07t, dd07v,
         t100, t001l,
         t6wp1,  tmbw1, tmbw2,
         t6wp2,
         wlk1, *wlk1,
         wlk11, *wlk11,
         wlk2, *wlk2,
         wsoh, *wsoh,
         wsop, *wsop,
         wsot, *wsot,
         wsof, *wsof,
         wscor,
         mara,
         maw1,
         mbew,
         *mbew,
         mard,
         *mara, malg,
         marc, *marc,
         makt, *makt,
         twpfi,
         t134, t134m,
         t023w, t023x, t023s.

* Material-Views *****************************************************

tables :
        rm03m,
        rm03k,
        mwws1,
        mwws2,
        mwws3,
        mtcom,
        mtcor.
data : begin of seq_dummy occurs 1,
          dummy(1),
       end of seq_dummy.


* Klassen
* Klasse fuer BADI "listing_badi"
class cl_exithandler definition load.     "Vorwaertsdeklaration
data INSTANCE type ref to IF_EX_LISTING_BADI. "Interfacereferenz

data IMPL_ACTIVE type sy-batch.

* Strukturen für Änderungsbelege ***********************************

  data : wrs1_alt like wrs1.
  data : wrs1_neu like wrs1.
  data : wrst_alt like wrst.
  data : wrst_neu like wrst.
  data : wrsz_alt like wrsz.
  data : wrsz_neu like wrsz.
  data : wrs6_alt like wrs6.
  data : wrs6_neu like wrs6.

  data : begin of t_cdtxt occurs 1.
           include structure cdtxt.
  data : end of t_cdtxt.


* allgemeine Daten-Definitionen *************************************

data : q_all_fi_h(1) value space,   "alle Kopfdaten je Typ
       q_all_vz_h(1) value space,
       q_all_kd_h(1) value space.
data : q_all_fi_6(1) value space,   "alle WRF6-Daten je Typ
       q_all_vz_6(1) value space,
       q_all_kd_6(1) value space.
data : q_all_fi_4(1) value space,   "alle WRF4-Daten je Typ
       q_all_vz_4(1) value space,
       q_all_kd_4(1) value space.
data : q_all_fi_3(1) value space,   "alle WRF3-Daten je Typ
       q_all_vz_3(1) value space,
       q_all_kd_3(1) value space,
       q_buffer_wrsz_all(1) value space,
       trans_world(1) value 'S',
*       so-tcode like sy-tcode,
*       so-subrc like sy-subrc,
       subrc like sy-subrc,
       q_a(1),
       n_locnr(10) type n.

data begin of so.
  data: tcode like sy-tcode,
        subrc like sy-subrc.
data end of so.

* Hilfsfelder *********************************************************
data   : h1(20),
         zl like sy-tabix,
         z1 like sy-tabix,
         z2 like sy-tabix,
         z3 like sy-tabix,
         z_loop like sy-tabix,
         q2(1),
         q1(1),
         q3(1),
         q4(1),
         q_ch_117(1),
         q_ok_117(1),
         q_ch_135(1),
         q_ok_135(1),
         tmp_wlk1 like wlk1,
         wrsc like wint_carrh,
         act_inttab_row type i,
         old_wlk1 like wlk1,
         xaender(1),
         merk_asort like wrsz-asort,
         merk_user like wrsz-locnr,
         merk_fil like wrs1-asort,
         merkdat like sy-datum,
         merk_art like mara-matnr,
         merk_man_art like mara-matnr,
         merk_c_matnr like mara-matnr,
         merk_matnr like mara-matnr,
         merk_vkorg like mvke-vkorg,
         merk_vtweg like mvke-vtweg,
         merk_bwkey like mbew-bwkey,
         manuell_list(1),
         mark_pos like sy-tabix,
         h_kzexi like sy-marky,
         hierarchie_flag like wtdy-typ01,
         datum   like wlk1-datbi,
         h_tabix like sy-tabix,
         h_lfdnr like wlk1-lfdnr.
data : begin of wscom.
         include structure wscor.
data : end of wscom.

* Tabelle zum Speichern der negierten WLK1-Sätze
  data: begin of pet_list_kond_neg occurs 1.
          include structure wpwlk1.
*         INCLUDE STRUCTURE TWWLK1POS.
  data: end of pet_list_kond_neg.

  data: begin of i_key1,
          arthier like wpwlk1-arthier,
*         ARTHIER LIKE TWWLK1POS-ARTHIER,
          mandt   like wlk1-mandt,
          artnr   like wlk1-artnr,
          vrkme   like wlk1-vrkme,
          filia   like wlk1-filia,
          datbi   like wlk1-datbi.
  data: end of i_key1.

* Tabellen zur Zeitsteuerung Listungs-Konditionen ********************

data : begin of hack_dat occurs 1,
         datab like sy-datum,
         datub like sy-datum,
         stat(1),
         type(1),
         baustein like wsoh-skopf,
         strli like wlk1-strli.
data : end of hack_dat.

data : begin of hack occurs 1,
         datab like sy-datum,
         datub like sy-datum,
         stat(1),
         type(1),
         vrkme like wlk1-vrkme.
data : end of hack.

data : begin of ha_dat occurs 1,
         datab like sy-datum,
         datub like sy-datum,
         stat(1),
         type(1),
         baustein like wsoh-skopf,
         strli like wlk1-strli.
*        INCLUDE STRUCTURE WLK1.
  data : filia like wlk1-filia,
         artnr like wlk1-artnr,
         vrkme like wlk1-vrkme,
         lfdnr like wlk1-lfdnr,
         ursac like wlk1-ursac,
         quell like wlk1-quell,
         pflkn like wlk1-pflkn,
         anzal like wlk1-anzal,
         datae like wlk1-datae,
         negat like wlk1-negat,
         aktio like wlk1-aktio,
         thema like wlk1-thema,      "ggf. bei Änderungen anpassen
*        INCLUDE STRUCTURE WSOP.
         skopf like wsop-skopf,
         sposi like wsop-sposi,
         ersda like wsop-ersda,
         ernam like wsop-ernam,
         satnr like wsop-satnr,
         lstfl like wsop-lstfl,
         atfsa like wsop-atfsa,
         kzfsa like wsop-kzfsa,
         sstuf like wsop-sstuf,
         lstvz like wsop-lstvz.
data : end of ha_dat.


* Feldsymbole ******************************************************
field-symbols : <f1>.

* lokale Puffer ****************************************************

* FORM : WRF1_read ***********************

data : begin of local_wrf1 occurs 1.
         include structure wrf1.
*        include structure wint_wrf1.
data : end of local_wrf1.

data : q_wrf1(1), z_wrf1 like sy-tabix.

* FORM : KNA1_read ***********************

data : begin of local_kna1 occurs 1.
*        INCLUDE STRUCTURE KNA1.
         include structure wint_kna1.
data : end of local_kna1.

data : q_kna1(1), z_kna1 like sy-tabix.


* FORM : WRF3_read ***********************

data : begin of local_wrf3 occurs 1.
         include structure wrf3.
data : end of local_wrf3.
data : begin of local_no_wrf3 occurs 1,
         locnr like wrf3-locnr,
         matkl like wrf3-matkl.
data : end of local_no_wrf3.

data : q_wrf3(1), z_wrf3 like sy-tabix, p_wrf3_pref(1).

* FORM : WRF4_read ***********************

data : begin of local_wrf4 occurs 1.
         include structure wrf4.
data : end of local_wrf4.
data : begin of local_no_wrf4 occurs 1,
         locnr like wrf4-locnr.
data : end of local_no_wrf4.

data : q_wrf4(1), z_wrf4 like sy-tabix.

* FORM : WRF6_read ***********************

data : begin of local_wrf6 occurs 100.
         include structure wrf6.
data : end of local_wrf6.

data : begin of local_no_wrf6 occurs 1,
         locnr like wrf6-locnr,
         matkl like wrf6-matkl.
data : end of local_no_wrf6.

data : q_wrf6(1), z_wrf6 like sy-tabix.


* FORM : KNVV_read ***********************

data : begin of local_knvv occurs 1.
         include structure knvv.
data : end of local_knvv.

data : q_knvv(1), q_pref_knvv(1),
       z_knvv like sy-tabix.

* FORM : WRs6_read ***********************

data : begin of local_wrs6 occurs 1.
         include structure wrs6.
data : end of local_wrs6.

*DATA : BEGIN OF LOCAL_NO_WRS6 OCCURS 1,
*         ASORT LIKE WRS6-ASORT,
*         MATKL LIKE WRS6-MATKL.
*DATA : END OF LOCAL_NO_WRS6.

data : begin of wrs6_read occurs 1,
         matkl like wrs6-matkl,
         locnr like wrs6-asort,
         data_read(1),
         data_exist(1).
data : end of wrs6_read.

data : q_wrs6(1), z_wrs6 like sy-tabix.

* FORM : T001W_READ **********************

data : begin of local_t001w occurs 1.
*        INCLUDE STRUCTURE T001W.
         include structure wint_t001w.
data : end of local_t001w.

data : begin of i_werk1 occurs 1.
         include structure t001w.
data : end of i_werk1.

data : q_t001w(1), z_t001w like sy-tabix.


* Merktabelle, für welche VTLinien schon die Werke gelesen wurden

data : begin of vtl_werke occurs 1,
         vkorg like tvko-vkorg,
         vtweg like tvtw-vtweg,
         flag(1).
data : end of vtl_werke.

* Puffer **************************************************************

data : begin of buffer_wlk1 occurs 1.
         include structure wlk1.
data : end of buffer_wlk1.

data : begin of buffer_wlk1_access occurs 1,
         artnr like wlk1-artnr,
         filia like wlk1-filia,
         data_found(1).
data : end of buffer_wlk1_access.

*data : begin of buffer_wrs1 occurs 1.
*         include structure wrs1.
*data : end of buffer_wrs1.

data: buffer_wrs1 type hashed table of wrs1 with unique key PRIMARY_KEY COMPONENTS asort.
data wa_buffer_wrs1 like line of buffer_wrs1.

*data : begin of buffer_wrs1_s occurs 1.
*         include structure wrs1.
*         data : spras like wrst-spras,
*                name1 like wrst-name1.
*data : end of buffer_wrs1_s.

types:
  begin of gty_buffer_wrs1_s,
    asort           type wrs1-asort,
    statu           type wrs1-statu,
    kzlik           type wrs1-kzlik,
    nlmatfb         type wrs1-nlmatfb,
    vkorg           type wrs1-vkorg,
    vtweg           type wrs1-vtweg,
    lstfl           type wrs1-lstfl,
    datab           type wrs1-datab,
    datbi           type wrs1-datbi,
    kopro           type wrs1-kopro,
    laypr           type wrs1-laypr,
    sotyp           type wrs1-sotyp,
    layvr           type wrs1-layvr,
    posds           type wrs1-posds,
    exclu           type wrs1-exclu,
    category        type wrs1-category,
    lay_list_utime  type wrs1-lay_list_utime,
    spras           type wrst-spras,
    name1           type wrst-name1,
  end of gty_buffer_wrs1_s.

data buffer_wrs1_s type hashed table of gty_buffer_wrs1_s with unique key primary_key components asort.
data wa_buffer_wrs1_s like line of buffer_wrs1_s.

*data : begin of buffer_wrf3 occurs 1.
*         include structure wrf3.
*data : end of buffer_wrf3.

data buffer_wrf3 type sorted table of wrf3 with non-unique key primary_key components locnr matkl.
field-symbols <wa_buffer_wrf3> like line of buffer_wrf3.

data buffer_wrf4 type sorted table of wrf4 with non-unique key primary_key components locnr.

data wa_buffer_wrf4 like line of buffer_wrf4.


*data : begin of buffer_wrs6 occurs 1.
*         include structure wrs6.
*data : end of buffer_wrs6.

data buffer_wrs6 type hashed table of wrs6 with unique key primary_key components asort matkl.
data wa_buffer_wrs6 like line of buffer_wrs6.


data :buffer_wrst type hashed table of wrst with unique key primary_key components asort spras,
      wa_buffer_wrst like line of buffer_wrst.

data : begin of buffer_wrsz occurs 1.
         include structure wrsz.
data : end of buffer_wrsz.

data : begin of buffer_sonu occurs 1.
         include structure v_sonu.
data : end of buffer_sonu.

data : buffer_sonu_t type HASHED TABLE OF v_sonu with UNIQUE key PRIMARY_KEY COMPONENTS locnr.
data : wa_buffer_sonu_t like line of buffer_sonu_t.

* sonstige interne Tabellen *******************************************

data : begin of i_wrsz occurs 1.
         include structure wrsz.
data : end of i_wrsz.

data : begin of t_users occurs 1.
         include structure wrsz.
data : end of t_users.

data : begin of t_asort occurs 1.
         include structure wrs1.
data : end of t_asort.

data : begin of t_user occurs 1.
         include structure wrsz.
data : end of t_user.

data : begin of t_carriers occurs 1.
         include structure wrs1.
data : end of t_carriers.

data : begin of wlk1_results_1 occurs 1.
         include structure wlk1.
data : end of wlk1_results_1.

data : begin of wlk1_input_tmp occurs 1.
         include structure wlk1.
data : end of wlk1_input_tmp.

data : begin of wlk1_temp occurs 1.
         include structure wlk1.
data : end of wlk1_temp.

* Duplikate **********************

data : begin of dwlk1 occurs 1.
         include structure wlk1.
data : end of dwlk1.

data : dwlk1_u type wlk1_u.                                    " TC 4.6C

data : begin of dwlk2 occurs 1.
         include structure wlk2.
data : end of dwlk2.

data : begin of dwsof occurs 1.
         include structure wsof.
data : end of dwsof.

data : begin of i_wsof occurs 1.
         include structure wsof.
data : end of i_wsof.

data : begin of buffer_wsof occurs 1.
         include structure wsof.
data : end of buffer_wsof.

data : begin of dwsot occurs 1.
         include structure wsot.
data : end of dwsot.

data : begin of dwsop occurs 1.
         include structure wsop.
data : end of dwsop.
data : begin of wsop_tabs occurs 1.     "Pos.-Infos Original - Tab.
         include structure wsop.
data : end of wsop_tabs.
data : begin of wsop_texte occurs 1.    "Texte zu den Positionen
         include structure makt.
data : end of wsop_texte.

data : begin of fil_twlv.
         include structure twlv.
data : end of fil_twlv.

data : begin of vz_twlv.
         include structure twlv.
data : end of vz_twlv.

data : begin of sammel_item occurs 1.
         include structure wint_wam1.
data : end of sammel_item.

data : begin of int_wemtb occurs 1.
         data : matnr like mara-matnr.
data : end of int_wemtb.

data : begin of int_mwws1 occurs 1.
         include structure mwws1.
data : end of int_mwws1.

data : begin of sammel_sales_line occurs 1,
         vtweg like tvtw-vtweg,     "??? weitere Daten
       end of sammel_sales_line.

data : begin of mk.
         include structure wint_loc.
data : end of mk.

data : begin of plant_list_d occurs 1.
         include structure wint_loc.
data : end of plant_list_d.

data : begin of plant_list_man occurs 1.
         include structure wint_loc.
data : end of plant_list_man.

data : m_it like wint_wam1.
data : m_sl like wint_sl.
data : n_sl like wint_sl.

data : begin of plant_result occurs 1.
         include structure wint_loc.
data : end of plant_result.

data : begin of plant_orig occurs 1.
         include structure wint_loc.
data : end of plant_orig.

data : begin of plant_list_err occurs 1.
         include structure wint_err.
*        INCLUDE STRUCTURE WINT_LOC.
*        INCLUDE STRUCTURE WSCOR.
data : end of plant_list_err.

data : begin of p_list occurs 1.
         include structure wint_loc.
data : end of p_list.

data : begin of plant_list_all occurs 1.
         include structure wint_loc.
data : end of plant_list_all.

data : begin of m_manuel_list occurs 1.
         include structure wint_loc.
data : end of m_manuel_list.

data : begin of plant_list_checked occurs 1.
         include structure wint_loc.
data : end of plant_list_checked.

data : begin of plant_list_mark occurs 1,
         artnr like mara-matnr,
         asort like wrf1-locnr,
         vkorg like mvke-vkorg,
         vtweg like mvke-vtweg.
data : end of plant_list_mark.

data : begin of plant_list_dc occurs 1.
         include structure wint_loc.
data : end of plant_list_dc.

data : begin of int_fil.
         include structure wint_fdef.
data : end of int_fil.

data : begin of plant_quell occurs 1.
         include structure wint_loc.
data : end of plant_quell.

data : begin of m_plant_quell occurs 1.
         include structure wint_loc.
data : end of m_plant_quell.

data : begin of int_pos occurs 1.
         include structure wint_pos.
data : end of int_pos.

data : begin of varianten occurs 1.
         include structure mara.
data : end of varianten.

data : begin of i_tvkwz occurs 1.
         include structure tvkwz.
data : end of i_tvkwz.


* WLK1 - Kommunikationsstrukturen

data : begin of com_wlk1 occurs 1.
         include structure com_wlk1.
data : end of com_wlk1.
data : q_com_wlk1(1) value ' '.

data : begin of com_wlk1_belege occurs 1.
         include structure wlk1.
data : end of com_wlk1_belege.

data : begin of in_wlk1 occurs 1.
         include structure wlk1.
data : end of in_wlk1.

data : begin of iwlk1 occurs 1.
         include structure wlk1.
data : end of iwlk1.


* Ergebnistabelle aus dem Aufruf des Funktionsbausteins
* 'Material_Read'.
  data: begin of t_seqmat01 occurs 1.
          include structure meng2.
  data: end of t_seqmat01.

* Schlüsseltabelle zum Aufruf des Funktionsbausteins
* 'Material_Read'.
  data: begin of t_mtcom occurs 1.
          include structure mtcom.
  data: end of t_mtcom.

* Ergebnistabelle aus dem Aufruf des Funktionsbausteins
* 'Material_Read'.
  data: begin of t_mtcor occurs 1.
          include structure mtcor.
  data: end of t_mtcor.

* Ergebnistabelle aus dem Aufruf des Funktionsbausteins
* 'Wlk1_Read'
  data: begin of t_wlk1_input occurs 1.
          include structure wlk1.
  data: end of t_wlk1_input.

* Ergebnistabelle aus dem Aufruf des Funktionsbausteins
* 'Wlk2_Read'
  data: begin of t_wlk2_input occurs 1.
          include structure wlk2.
  data: end of t_wlk2_input.

* Tabelle zum Speichern der geführten VRKME eines Artikels
  data: begin of t_vrkme occurs 1,
          vrkme like marm-meinh,
          MATERIAL_LISTING(1).
  data: end of t_vrkme.


* lokale Gedächtnisse einzelner Funktionen ***************************

* LISTING_CHECK ************************
data : g_werks like wlk2-werks,
       g_matnr like wlk2-matnr.

data: g_upd_mode like rmmg2-call_mode2 value space.   " COLLETT 4.6A

************************************************************************
* Typen
************************************************************************

types: begin of skopf_matnr, " OCCURS 0,
         skopf like wsoh-skopf,
         matnr like mara-matnr,
      end of skopf_matnr.
types: t_skopf_matnr type skopf_matnr occurs 0.

************************************************************************
* Konstanten
************************************************************************

constants:
   c_sort_filia(1) value '1',
   c_sort_artnr(1) value '2'.


constants:
  variante(1) value 'V',
  komponente(1) value 'K',
  einzelmaterial(1) value 'E'.


data: msg_text(80) type c,
      info like rfcsi,
      semaphore(1) value space,   "Für WAIT-Bedingung
      ret_subrc like sy-subrc,    "Behandlung von SUBRC
      taskname(4) type n value '0001',
      jobs type i value 3,
      snd_jobs type i value 0.


* Steuerungsfelder für die Verbuchung
data s_wsor_ctrl type wsor_ctrl.
data create_change_document like wtdy-typ01.


* Klasse fuer BADI "LIST_DISCONTINUATION"
class cl_exithandler definition load.             "Vorwaertsdeklaration
data exit_LIST_DISCONTINUATION
          type ref to IF_EX_LIST_DISCONTINUATION. "Interfacereferenz

data:  first_call_LIST_DISCONT type char1.
      " wenn first_call_exit initial, werden Instanzen erzeugt
data: list_discontinuation_impl_act type sy-batch.

* begin multiple assignment 4.7
  data:   all_wrs1_read(1) value space.

  data:   buffer_wrsz_locnr type wrsz occurs 0
        , buffer_no_wrsz_locnr type locnr occurs 0
        .
* end multiple assignment 4.7

data gv_new_listing_check type c length 1 value '?'. "note 1983021
