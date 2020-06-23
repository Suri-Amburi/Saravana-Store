***INCLUDE POSANTOP.
* Tabellendeklarationen.
TABLES: t001w,
        t001l,
        mara,
        mean,
        knvv,
        konbbyh, "Erweiterung Bonus-Buys 07.01.1999 GL
        wakh. "Erweiterung Aktionsrabatte, rz 19.05.00

* Gemeinsame Datendeklarationen der Reports RWDPOSIN und RWDPOSAN
* und RWDPOSUP.
INCLUDE dlpostop.


* Konstantendeklarationen.
DATA: c_equal(2)      VALUE 'EQ',
      c_artikeltyp(5) VALUE 'ART',
      c_eantyp(5)     VALUE 'EAN',
      c_narttyp(5)    VALUE 'NART',
      c_settyp(5)     VALUE 'SET',
      c_setartikel    LIKE mara-attyp   VALUE '10',
      c_insert        VALUE 'I'.

* Globale Datendeklarationen.
DATA: g_del_line1(35) TYPE c,
      g_del_line2(35) TYPE c,
      g_popup_answer.

DATA: BEGIN OF gt_filia OCCURS 100.
    INCLUDE STRUCTURE wpfilia.
DATA: END OF gt_filia.

DATA: BEGIN OF gt_article OCCURS 100.
    INCLUDE STRUCTURE wpart.
DATA: END OF gt_article.

DATA: BEGIN OF gt_article_equal OCCURS 10.
    INCLUDE STRUCTURE wpart.
DATA: END OF gt_article_equal.

DATA: BEGIN OF gt_kunnr OCCURS 100.
    INCLUDE STRUCTURE wppdot3.
DATA: END OF gt_kunnr.

* Erweiterung Bonus-Buys (Release 99a, GL)
DATA: BEGIN OF gt_bbuy OCCURS 100.
    INCLUDE STRUCTURE wpbobuy.
DATA: END OF gt_bbuy.
* ***

* Erweiterung Aktionsrabatte, rz 19.05.00
DATA: BEGIN OF gt_promo OCCURS 100.
    INCLUDE STRUCTURE wpromo.
DATA: END OF gt_promo.
* rz

* Parameter & Select-Options.
SELECTION-SCREEN BEGIN OF BLOCK orgebene
                 WITH FRAME TITLE TEXT-004.
PARAMETERS: pa_vkorg LIKE t001w-vkorg obligatory,
            pa_vtweg LIKE t001w-vtweg obligatory.
SELECT-OPTIONS:  so_fisel FOR  t001l-werks.

SELECTION-SCREEN END   OF BLOCK orgebene.

SELECTION-SCREEN BEGIN OF BLOCK daten
                 WITH FRAME TITLE TEXT-005.
SELECTION-SCREEN BEGIN OF BLOCK article
                 WITH FRAME TITLE TEXT-006.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) FOR FIELD pa_art.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS:     pa_art LIKE edidoc1-syntax DEFAULT ' '.
SELECTION-SCREEN END OF LINE.
SELECT-OPTIONS: so_matar FOR mara-matnr MATCHCODE OBJECT mat1,
                so_eanar FOR mean-ean11,
                so_wrgar FOR mara-matkl.
SELECTION-SCREEN END OF BLOCK article.

SELECTION-SCREEN BEGIN OF BLOCK ean
                 WITH FRAME TITLE TEXT-007.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) FOR FIELD pa_ean.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS:     pa_ean LIKE edidoc1-syntax DEFAULT ' '.
SELECTION-SCREEN END OF LINE.
SELECT-OPTIONS: so_matea FOR mara-matnr MATCHCODE OBJECT mat1,
                so_eanea FOR mean-ean11,
                so_wrgea FOR mara-matkl.
SELECTION-SCREEN END OF BLOCK ean.

SELECTION-SCREEN BEGIN OF BLOCK nart
                 WITH FRAME TITLE TEXT-008.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) FOR FIELD pa_nart.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS:     pa_nart LIKE edidoc1-syntax DEFAULT ' '.
SELECTION-SCREEN END OF LINE.
SELECT-OPTIONS: so_matna FOR mara-matnr MATCHCODE OBJECT mat1,
                so_eanna FOR mean-ean11,
                so_wrgna FOR mara-matkl.
SELECTION-SCREEN END OF BLOCK nart.

SELECTION-SCREEN BEGIN OF BLOCK sets
                 WITH FRAME TITLE TEXT-009.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) FOR FIELD pa_sets.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS:     pa_sets LIKE edidoc1-syntax DEFAULT ' '.
SELECTION-SCREEN END OF LINE.
SELECT-OPTIONS: so_matse FOR mara-matnr MATCHCODE OBJECT mat1,
                so_eanse FOR mean-ean11,
                so_wrgse FOR mara-matkl.
SELECTION-SCREEN END OF BLOCK sets.

SELECTION-SCREEN BEGIN OF BLOCK pers
                 WITH FRAME TITLE TEXT-010.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) FOR FIELD pa_pdat.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS:     pa_pdat LIKE edidoc1-syntax DEFAULT ' '.
SELECTION-SCREEN END OF LINE.
SELECT-OPTIONS: so_kunnr FOR knvv-kunnr MATCHCODE OBJECT debi.
SELECTION-SCREEN END OF BLOCK pers.

* Erweiterung Bonus-Buys (G. Lammers, Release 99A)
SELECTION-SCREEN BEGIN OF BLOCK bbuy
                 WITH FRAME TITLE TEXT-014.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) FOR FIELD pa_bbuy.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS:      pa_bbuy LIKE edidoc1-syntax DEFAULT ' '.
SELECTION-SCREEN END OF LINE.
SELECT-OPTIONS:  so_bbuy FOR konbbyh-bbynr.
SELECTION-SCREEN END OF BLOCK bbuy.

* Erweiterung Aktionsrabatte, rz 19.05.00
SELECTION-SCREEN BEGIN OF BLOCK promreb
                 WITH FRAME TITLE TEXT-015. " (Aktionsrabatte)
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) FOR FIELD pa_promo.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS:      pa_promo LIKE edidoc1-syntax DEFAULT ' '.
SELECTION-SCREEN END OF LINE.
SELECT-OPTIONS:  so_promo FOR wakh-aktnr MATCHCODE OBJECT wakh.
SELECTION-SCREEN END OF BLOCK promreb.
* rz

SELECTION-SCREEN BEGIN OF BLOCK rest_data
                 WITH FRAME TITLE TEXT-011.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) FOR FIELD pa_wrg.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS: pa_wrg LIKE edidoc1-syntax DEFAULT ' '.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) FOR FIELD pa_steu.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS:     pa_steu  LIKE edidoc1-syntax DEFAULT ' '.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) FOR FIELD pa_wkurs.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS:    pa_wkurs LIKE edidoc1-syntax DEFAULT ' '.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK rest_data.
SELECTION-SCREEN END OF BLOCK daten.

SELECTION-SCREEN BEGIN OF BLOCK time_range
                 WITH FRAME TITLE TEXT-012.
PARAMETERS: pa_datab LIKE wpstruc-datum,
            pa_datbi LIKE wpstruc-datum DEFAULT '00000000'.
SELECTION-SCREEN END OF BLOCK time_range.

SELECTION-SCREEN BEGIN OF BLOCK options
                 WITH FRAME TITLE TEXT-013.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) FOR FIELD pa_dele.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS: pa_dele  LIKE edidoc1-syntax DEFAULT ' '.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) FOR FIELD pa_debug.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS:  pa_debug LIKE edidoc1-syntax DEFAULT ' '.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK options.

* Unsichtbare zusätzliche Optionen.
* Kein Dialog erwünscht, d. h. kein PopUp und keine Listausgabe.
PARAMETERS: pa_nodia  LIKE edidoc1-syntax DEFAULT ' ' NO-DISPLAY.

* Löschen von Bonuskäufen über externes Programm: ==> keine
* weiteren internen Prüfungen nötig. Alle benötigten Daten werden
* komplett übergeben.
PARAMETERS: pa_bbyde  LIKE edidoc1-syntax DEFAULT ' ' NO-DISPLAY.
