FUNCTION-POOL ZCLVF       MESSAGE-ID CL.

* Datenbanktabellen
tables:
    ausp,
    kssk,
    tcla,
    auspc_v1,
    auspc_v2,
    auspc_v3,
    auspn_v1,
    auspn_v2,
    auspn_v3,
    auspn_v4.

* Feldleisten
tables:
    rmclkssk,
    rmclausp,
    rmcldel.

* Hilfsfelder.
data:
    dupl,
*-- Stichtag bei ALE mit Effectivity-Datum
    g_ale_datuv    like sy-datum,
*-- Merker, falls es bereits gelöscht wurde (und die dann nicht nochmals
*-- gelöscht werden dürfen)
    g_ausp_already_del(1),
*-- G_EFFECTIVITY_USED: Flag, das gesetzt wird, falls Änderungsnr.
*-- zur neuen Eff.-Logik definiert ist
    g_effectivity_used like rmclf-kreuz,
    g_effectivity_date like tcla-effe_datum,
    ksskflag,
    max_atzhl      like ausp-atzhl,
    max_adzhl      like ausp-adzhl,
    xaennr         like kssk-aennr,
    xdatuv         like sy-datum,
    tabmara        like tcla-obtab  value 'MARA',
    tabmarc        like tcla-obtab  value 'MARC',
    tabkssk        like tcla-obtab  value 'KSSK',
    tabausp        like tcla-obtab  value 'AUSP'.

* Begin Correction 27.01.2004 0701214 *******************
* global flag to activate the modifications
* for the module EH&S (class-type 100)
  DATA G_FLG_EHS_MOD_ACTIVE(1) TYPE C VALUE 'X'.
* End Correction 27.01.2004 0701214 *********************

*
*-- TYPES wg. Effectivity
type-pools cc01.
*-- Include wg. Tabellennamen Effectivity
include mclefto1 .
*
types : begin of t_redun,
          klart     type kssk-klart.
          include   structure rmclobj.
types:    konfobj   type tcla-konfobj,
          ausp_new  type tcla-ausp_new,
          ausp_gen  type tcla-ausp_gen,
        end   of t_redun.

data  : redun type t_redun occurs 0 with header line.
*
*-- TABKEY für ALE-Strukturen
data: begin of g_tabkey,
        mafid like kssk-mafid,
        klart like kssk-klart,
        objek like kssk-objek,
        aennr like kssk-aennr.
data: end   of g_tabkey.

*-- Interne Tabelle für Klassen-Aennr-Zuordnungen bei Effectivity
data: g_claennr_tab  like claennr occurs 5 with header line.


data: begin of objid,
        objek like inob-cuobj,
        mafid like kssk-mafid.
data: end   of objid.
*
data: begin of kvi occurs 0,
        index      like sy-tabix,      "Index
        ugkla      type c,             "Kz. untergeordnete Klasse
      end   of kvi.
*
data: begin of ghclh  occurs 0.
        include structure ghcl.
data: end of ghclh.
*
data: begin of iklah occurs 0.
        include structure klah.
data: end   of iklah.
*
data: begin of hkssk occurs 0.
        include structure kssk.
data: end   of hkssk.
*
data: begin of vkssk occurs 0.
        include structure kssk.
data: end   of vkssk.
*
data: begin of v1kssk occurs 0.
        include structure kssk.
data: end   of v1kssk.
*
data: begin of lkssk occurs 0.
        include structure kssk.
data: end   of lkssk.
*
data: begin of hausp occurs 0.
        include structure ausp.
data: end   of hausp.
*
data: begin of hausp1 occurs 0.
        include structure ausp.
data: end   of hausp1.
*
data: begin of vausp occurs 0.
        include structure ausp.
data: end   of vausp.
*
data: begin of vausp1 occurs 0.
        include structure ausp.
data: end   of vausp1.
*
data: begin of lausp occurs 0.
        include structure ausp.
data: end   of lausp.
*
*-- Merktabelle für Löschsätze
data: g_ausp_del like ausp occurs 0 with header line .


data: begin of iausp occurs 0.
        include structure ausp.
data: end   of iausp.
*
* function module UPDATE_MATERIAL_CLASSIFICATION               v 1984597
* and DDIC structure PRE03
* are available only in SAP_APPL not in SAP_ABA
* -> encapsulate dynamic processing of structure and function call

CLASS lcl_material DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS:
      class_constructor,
      add                 IMPORTING p_material TYPE cuobn, "objnum,  "MFLE: 2170766
      sort,
      update              IMPORTING after_mat_create TYPE xfeld OPTIONAL.

  PRIVATE SECTION.

    CLASS-DATA:
      mc_upd_mat_clf TYPE rs38l-name VALUE 'UPDATE_MATERIAL_CLASSIFICATION',
      mc_pre03       TYPE string     VALUE 'PRE03',
      mc_matnr       TYPE string     VALUE 'MATNR',
      m_sorted       TYPE c,

      mattab         TYPE REF TO data,
      matrow         TYPE REF TO data.

ENDCLASS.                                                     "^ 1984597
*
data: begin of abkssk occurs 0.
        include structure vabkssk.
data: end   of abkssk.
*
data: begin of abausp occurs 0.
        include structure vabausp.
data: end   of abausp.
*
data: begin of iklart occurs 10.
        include structure rmclobj.
data: end   of iklart.
*
data: begin of ale_stru occurs 0.
        include structure bdi_chptr.
data: end   of ale_stru.
*
******change-pointers for BW   not: 323412 ->
DATA: GT_ALE_STRU_CLBW LIKE STANDARD TABLE OF BDI_CHPTR
              WITH HEADER LINE.
********************* <- note: 323412
*
data  : begin of ap0,
          objek like ausp-objek,
          atinn like ausp-atinn,
          atzhl like ausp-atzhl,
          mafid like ausp-mafid,
          klart like ausp-klart,
          adzhl like ausp-adzhl.
data  : end   of ap0.
*
data  : begin of ap2 occurs 0,
          objek like ausp-objek,
          atinn like ausp-atinn,
          atzhl like ausp-atzhl,
          mafid like ausp-mafid,
          klart like ausp-klart,
          datuv like ausp-datuv,
          aennr like ausp-aennr.
data  : end   of ap2.
*
data  : begin of ks,
          objek like kssk-objek,
          mafid like kssk-mafid,
          klart like kssk-klart,
          clint like kssk-clint,
          adzhl like kssk-adzhl.
data  : end   of ks.
*
data: begin of auspcv1 occurs 0.
        include structure auspc_v1.
data: end   of auspcv1.
*
data: begin of auspcv2 occurs 0.
        include structure auspc_v2.
data: end   of auspcv2.
*
data: begin of auspcv3 occurs 0.
        include structure auspc_v3.
data: end   of auspcv3.
*
data: begin of auspnv1 occurs 0.
        include structure auspn_v1.
data: end   of auspnv1.
*
data: begin of auspnv2 occurs 0.
        include structure auspn_v2.
data: end   of auspnv2.
*
data: begin of auspnv3 occurs 0.
        include structure auspn_v3.
data: end   of auspnv3.
*
data: begin of auspnv4 occurs 0.
        include structure auspn_v4.
data: end   of auspnv4.
*
constants:
*     Startwerte für atzhl für ein- und mehrwertige Merkmale
      c_atzhl_single  like ausp-atzhl   value 1,
      c_atzhl_mult    like ausp-atzhl   value 2,
      c_adzhl_start   like ausp-adzhl   value 1,
      konst_d                          value 'D',
      konst_i                          value 'I',
      konst_u                          value 'U',
      hinzu                            value 'H',
      veraend                          value 'V',
      loeschen                         value 'L',
      mafidk                           value 'K',
      mafido                           value 'O',
      kreuz        like rmclf-kreuz    value 'X'.

field-symbols:
* fields for assigning loops
  <gf_kssk> like rmclkssk,
  <gf_ausp> like rmclausp.

* BADI for updates
DATA: gr_badi_clf_update          TYPE REF TO cacl_classification_update,
      gv_num_badi_clf_update_impl TYPE i.

* Änderungsbelege
*+++ Die folgenden Vereinbarungen sind eine Notlösung, weil TS
*+++ den Originalinclude gelöscht hatte (Verw.Nachweis war fehlerhaft)
include fclabcdt.
