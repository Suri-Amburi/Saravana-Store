*&---------------------------------------------------------------------*
*& Report ZJOBCARD2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE ZJOBCARD2TOP                            .    " Global Data

* INCLUDE ZJOBCARD2O01                            .  " PBO-Modules
* INCLUDE ZJOBCARD2I01                            .  " PAI-Modules
 INCLUDE ZJOBCARD2F01                            .  " FORM-Routines

 START-OF-SELECTION.
 PERFORM RETRIEVE_DATA.
 PERFORM PROCESS_DATA.
 PERFORM DISPLAY.

*INCLUDE zjobcard2_retrieve_dataf01.
