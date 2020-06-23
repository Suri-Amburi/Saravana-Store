FUNCTION-POOL ZSC2
                   MESSAGE-ID M3.

INCLUDE MMMGTRBB.
INCLUDE MMMGBBAU.
* Retail-Spezifische Deklarationen
INCLUDE MMMWTRBB.
INCLUDE MMMWBBAU.
*---------------------------------
INCLUDE wstr_definition. "Holds BADI global definition
* CWM Integrtion
INCLUDE /CWM/MGD1I01.
INCLUDE /CWM/MGD1O01.
Include /CWM/MGD2I01.

LOAD-OF-PROGRAM.
  IF 1 = 2. ENDIF.                                        "Note 2668968
