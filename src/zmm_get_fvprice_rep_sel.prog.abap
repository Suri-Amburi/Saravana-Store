*&---------------------------------------------------------------------*
*& Include          ZMM_GET_FVPRICE_REP_SEL
*&---------------------------------------------------------------------*

"Selction Screen / Input Screen

SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS : p_date TYPE datum DEFAULT sy-datum OBLIGATORY,   "Valid On date
             p_file TYPE string NO-DISPLAY .  "File Path
SELECTION-SCREEN : END OF BLOCK b1 .
**
**AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
**
**  PERFORM get_filename CHANGING p_file.

START-OF-SELECTION .

  PERFORM get_data USING p_date CHANGING xfv_prlist[].

  CHECK xfv_prlist[] IS NOT INITIAL.

  PERFORM display_prlist USING xfv_prlist[].    "Display ALV Grid
