FUNCTION MGW_SALES_PRICE_MATRIX_START_.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"--------------------------------------------------------------------
* The following call function is only available in
* a retail addon system .

  bildflag = x.

*   Hier eventuell ein BAPI für die
*   Kundeneigene Preismatrix Lösung

* note 987287: get correct data from buffer for matrix call
  CALL FUNCTION 'MAIN_PARAMETER_GET_ZUS_SUB'
    IMPORTING
      WRMMG1            = RMMG1
      WRMMW1            = RMMW1
      WRMMW1_BEZ        = RMMW1_BEZ
      WCALP             = CALP.
  CALL FUNCTION 'MVKE_GET_BILD'
    EXPORTING
      MATNR             = RMMG1-MATNR
      VKORG             = RMMG1-VKORG
      VTWEG             = RMMG1-VTWEG
    IMPORTING
      WMVKE             = MVKE.
  CALL FUNCTION 'MAKT_GET_BILD'
    EXPORTING
      MATNR             = RMMG1-MATNR
      SPRAS             = RMMG1-SPRAS
    IMPORTING
      WMAKT             = MAKT.
  CALL FUNCTION 'MARM_GET_BILD'
    EXPORTING
      MATNR             = RMMG1-MATNR
    TABLES
      WMEINH            = MEINH.


  data: ADDON_FB3 like rs38l-name.
* Matrix
  ADDON_FB3 = 'MGW_CALL_SALES_PRICE_MATRIX'.
  call function ADDON_FB3
      exporting
        i_rmmw1            = rmmw1
        i_mvke             = mvke
        i_calp             = calp
        i_rmmw1_bez        = rmmw1_bez
        i_rmmg1_bez        = rmmg1_bez
        i_makt             = makt
        i_neuflag          = neuflag
        i_aktyp            = t130m-aktyp
*       I_DISPLAY          = ' '
*       I_SUPPRESS         = ' '
        I_SPERRMODUS       = sperrmodus
      tables
        t_meinh            = meinh
      exceptions
        wrong_call         = 1
        wrong_satnr        = 2
        no_matrix          = 3
        others             = 4.

  if sy-subrc <> 0.
    message id sy-msgid type 'S' number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

ENDFUNCTION.
