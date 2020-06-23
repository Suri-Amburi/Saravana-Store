*&---------------------------------------------------------------------*
*& Report ZMM_CONTRACT_PO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE ZMM_CONTRACT_POTOP                      .    " Global Data

* INCLUDE ZMM_CONTRACT_POO01                      .  " PBO-Modules
* INCLUDE ZMM_CONTRACT_POI01                      .  " PAI-Modules
 INCLUDE ZMM_CONTRACT_POF01                      .  " FORM-Routines

 START-OF-SELECTION.
 PERFORM RETRIEVE_DATA.
 PERFORM PROCESS_DATA.
 PERFORM DISPLAY.
