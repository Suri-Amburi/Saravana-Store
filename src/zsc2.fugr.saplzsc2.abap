
*******************************************************************
*   System-defined Include-files.                                 *
*******************************************************************
  INCLUDE LZSC2TOP.                    " Global Data
  INCLUDE LZSC2UXX.                    " Function Modules
*******************************************************************
*   User-defined Include-files (if necessary).                    *
*******************************************************************

* DIESES INCLUDE NICHT MEHR AENDERN!                              *
* NEUE INCLUDES IN BESTEHENDE INCLUDES AUFNEHMEN!                 *

*------------------------------------------------------------------
*           PBO-Module
*------------------------------------------------------------------
* Spezielle Retail-Includes
*NCLUDE LMGD1OXX.     "zentrale PBO-Module Bildbausteine
INCLUDE LZSC2OXX.
*  INCLUDE LMGD2OXX.     "zentrale PBO-Module Bildbausteine       Kopie
*wk/4.0 rejoined following includes
  INCLUDE LMGD1O01.                    "PBO-Module für Kurztexthandling
*nclude lmgd2o01.     "PBO-Module für Kurztexthandling         Kopie
*NCLUDE LMGD1O02.     "PBO-Module für Steuerhandling
INCLUDE LZSC2O02.
*  INCLUDE LMGD2O02.     "PBO-Module für Steuerhandling           Kopie
*wk/4.0 rejoined following includes
  INCLUDE LMGD1O03.                    "PBO-Module für Verbrauchswerte
*nclude lmgd2o07.     "PBO-Module für Verbrauchswerte Retail Kopie
  INCLUDE LMGD1O04.                    "PBO-Mdoule Mengeneinheiten
*NCLUDE LMGD1O05.     "PBO-Module für Prognosewerte
INCLUDE LZSC2O06.
*  INCLUDE LMGD2O06.     "PBO-Module für Prognosewerte Retail Kopie
  INCLUDE LMGD1O06.                    "PBO-Module für EAN
  INCLUDE LMGD1O07.                    "PBO-Module für Langtexte
INCLUDE LZSC2O03.
*  INCLUDE LMGD2O03.     "PBO-Module für Bon-/Etikettentexte spez. Retail
INCLUDE LZSC2O05.
*  INCLUDE LMGD2O05.     "PBO-Module für Plazierungsgruppen spez. Retail
  INCLUDE LMGD1O08.                    "PBO-Modules for Table controls
  include lmgd1O1J.                    "PBO Document subscreen

*------------------------------------------------------------------
*           PAI-Module
*------------------------------------------------------------------
INCLUDE LZSC2I01.
*  INCLUDE LMGD2I01.     "Prüfmodule Speziell für Retail      Ergänzung
INCLUDE LZSC2I02.
*INCLUDE LMGD2I02.     "Prüfmodule Speziell für Retail-Bon-/Etikettentext
INCLUDE LZSC2I03.
*INCLUDE LMGD2I03.     "Prüfmodule Speziell für Retail-Plazierungsgruppen
*INCLUDE LMGD1IXX.    "zentrale PAI-Module Bildbausteine
INCLUDE LZSC2IXX.
*  INCLUDE LMGD2IXX.     "zentrale PAI-Module Bildbausteine    Kopie

INCLUDE LMGD1IYY.     "Gemeinsame PAI-Module Bildbaustein/Trägerprogramm
*mk/4.0 Kopie LMGD2I05 wieder mit Original LMGD1I01 vereint
 INCLUDE LMGD1I01.    "Prüfmodule Datenbilder  MARA, MAKT (Kopfbaustein)
*nclude lmgd2i05.     "Prüfmodule Datenbilder  MARA, MAKT (Kopfbaustein)
  INCLUDE LMGD1I02.     "Prüfmodule Datenbilder  MARC, MARD, MPGD
  INCLUDE LMGD1I03.     "Prüfmodule Datenbilder  QM-Daten (MARA/MARC)
  INCLUDE LMGD1I04.                    "Prüfmodule Datenbilder  MBEW
  INCLUDE LMGD1I05.                    "Prüfmodule Datenbilder  MFHM
  INCLUDE LMGD1I06.     "Prüfmodule Datenbilder  MLGN, MLGT
  INCLUDE LMGD1I07.                    "Prüfmodule Datenbilder  MPOP
  INCLUDE LMGD1I08.                    "Prüfmodule Datenbilder  MVKE
*wk/4.0 reunited following includes
  INCLUDE LMGD1I09.                    "Prüfmodule für Kurztexthandling
*nclude lmgd2i09.     "Prüfmodule für Kurztexthandling        Kopie
*NCLUDE LMGD1I10.     "PAI-Module für Steuerhandling
INCLUDE LZSC2I10.
*  INCLUDE LMGD2I10.     "PAI-Module für Steuerhandling           Kopie
*wk/4.0 rejoined following includes
  INCLUDE LMGD1I11.                    "PAI-Module für Verbrauchswerte
*nclude lmgd2i12.     "PAI-Module für Verbrauchswerte Retail Kopie
*NCLUDE LMGD1I13.     "PAI-Module für Prognosewerte
INCLUDE LZSC2I11.
*  INCLUDE LMGD2I11.     "PAI-Module für Prognosewerte Retail Kopie
  INCLUDE LMGD1I14.                    "PAI-Module EAN
  INCLUDE LMGD1I12.                    "PAI-Module Mengeneinheiten
  INCLUDE LMGD1I15.                    "PAI-Module für Langtexte
  INCLUDE LMGD1I17.                    "PAI-Module für TC-Steuerung
  include LMGD1I7Q.                    "PAI-Modules Document Subscreens
*
  INCLUDE LMGD1IHX.                    "Eingabehilfen Datenbilder
INCLUDE LZSC2IHX.
*  INCLUDE LMGD2IHX.     "Eingabehilfen Datenbilder Retail   Ergänzung
*------------------------------------------------------------------
*
*           FORM-Routinen
*
*------------------------------------------------------------------
*NCLUDE LMGD1FXX.        "zentrale Formroutinen Bildbaustein
*NCLUDE LMGD1FYY.        "Gemeinsame Form-Routinen Bildbaustein/Tägerpr.
  INCLUDE LMGD1FSC.        "zentrale Blätterroutinen   Bildbausteine
  INCLUDE LMGD1F01.                    "Form-Routinen Kurztexthandling
*NCLUDE LMGD1F02.        "Form-Routinen Steuerhandling
INCLUDE LZSC2F02.
*  INCLUDE LMGD2F02.        "Form-Routinen Steuerhandling         Kopie
 INCLUDE LMGD1F03.        "Form-Routinen Verbrauchswerte / Prognosewerte
  INCLUDE LMGD1F04.                    "Form-Routinen Mengeneinheiten
  INCLUDE LMGD1F05.                    "Form-Routinen EAN
INCLUDE LMGD1F06.        "Form-Routinen II Verbrauchswerte/Prognosewerte
INCLUDE LZSC2F03.
* INCLUDE LMGD2F03.        "Form-Routinen Bon/Etikettentexte Retail Spez.
INCLUDE LZSC2F04.
* INCLUDE LMGD2F04.        "Form-Routinen Plazierungsgruppen Retail Spez.
* AHE: 09.04.99 - A (4.6a)
INCLUDE LZSC2F05.
* INCLUDE LMGD2F05.        "Form-Routinen Varianten-EAN-Pfl. aus SA Spez.
* AHE: 09.04.99 - E
INCLUDE LZSC2F06.
* INCLUDE lmgd2f06.    "Incoterms        "note 2389622
  INCLUDE LMGD1FHX.       "spezielle Eingabehilfen Bildbausteine
INCLUDE LZSC2FHX.
* INCLUDE LMGD2FHX.       "spezielle Eingabehilfen Bildbausteine   Retail
INCLUDE LMGMMFHX.       "allg. Routinen Eingabehilfen  Bildbaust/Tägerpg
* Spezielle Retail-Includes
INCLUDE LZSC2FXX.
*  INCLUDE LMGD2FXX.        "zentrale Formroutinen Bildbausteine    Kopie
INCLUDE LZSC2FYY.
*  INCLUDE LMGD2FYY.        "Gemeinsame.Forms Bildbaust./Tägerpr.   Kopie

* Form-Routinen für Datenbeschaffung Bildbausteine
* # Industrie - Daten ( generiert )
  INCLUDE MMMGXGUW.        "Holen der Daten auf den Bildbaustein
  INCLUDE MMMGXSUW.        "Übergeben der Daten vom Bildbaustein
* # Retail - Daten
  INCLUDE MMMWXGUW.        "Holen der Daten auf den Bildbaustein
  INCLUDE MMMWXSUW.        "Übergeben der Daten vom Bildbaustein
* generierte Form-Routinen für Bildbausteine
  INCLUDE MMMGXRBD.        "Zus. Vorschlagshandling before  Dialog
  INCLUDE MMMGXRAD.        "Zus. Vorschlagshandling after   Dialog

INCLUDE LZSC2O04.
*  INCLUDE LMGD2O04.

INCLUDE LZSC2I04.
*  INCLUDE LMGD2I04.

INCLUDE LZSC2O08.
*  INCLUDE LMGD2O08.         " PBO - Module Varianten - EANs Retail
INCLUDE LZSC2I13.
*  INCLUDE LMGD2I13.         " PAI - Module Varianten - EANs Retail

* AHE: 04.03.99 - A (4.6a)
INCLUDE LZSC2O09.
*  INCLUDE LMGD2O09.         " PBO - Module Pflege VAR-EANs aus SA
INCLUDE LZSC2I14.
*  INCLUDE LMGD2I14.         " PAI - Module Pflege VAR-EANs aus SA
* AHE: 04.03.99 - E

* JB: 21.04.1999 - A (4.6a)
INCLUDE LZSC2O10.
*  include lmgd2o10.         " PBO-Feldauswahl für Subscreen Listung
* JB: 21.04.1999 - E

INCLUDE LZSC2O11.
*  INCLUDE lmgd2o11.    "Incoterms        "note 2389622

INCLUDE LZSC2I15.
*  INCLUDE LMGD2I15.  "jw/4.6B

* DIESES INCLUDE NICHT MEHR AENDERN!                                 *
* NEUE INCLUDES IN BESTEHENDE INCLUDES AUFNEHMEN!                    *

INCLUDE LZSC2I16.
*INCLUDE lmgd2i16.    "Incoterms        "note 2389622

  INCLUDE lmgd1o21.    "DPP

INCLUDE LZSC2I17.
*INCLUDE lmgd2i17.

INCLUDE LZSC2I22.
*INCLUDE lmgd2i22.

INCLUDE ZSC20900.

INCLUDE lzsc2o01.

INCLUDE lzsc2o07.
