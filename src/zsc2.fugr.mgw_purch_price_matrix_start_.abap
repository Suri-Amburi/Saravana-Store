FUNCTION MGW_PURCH_PRICE_MATRIX_START_.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"--------------------------------------------------------------------
* The following call function is only available in
* a retail addon system .

  bildflag = x.


*   Hier eventuell ein BAPI für die
*   Kundeneigene Preismatrix Lösung


 CALL FUNCTION 'MAIN_PARAMETER_GET_RMMW3'
   IMPORTING
     WRMMW3        = rmmw3.
           .

* note 987287: get correct data from buffer for matrix call
  CALL FUNCTION 'MAIN_PARAMETER_GET_ZUS_SUB'
    IMPORTING
      WRMMW2            = RMMW2
      WRMMG1            = RMMG1
      WRMMW1            = RMMW1
      WRMMW1_BEZ        = RMMW1_BEZ.
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
  CALL FUNCTION 'EINA_E_GET_BILD'
    EXPORTING
      MATNR   = RMMG1-MATNR
      LIFNR   = RMMW2-LIFNR
      EKORG   = RMMW2-EKORG
      WERKS   = RMMW2-EKWRK
    IMPORTING
      WMGEINE = MGEINE
      WEINA   = EINA.
  HMGEINE = MGEINE.
  EINE    = HMGEINE-HEINE.

  data: ADDON_FB2 like rs38l-name.
* Matrix
  ADDON_FB2 = 'MGW_CALL_PURCHASE_PRICE_MATRIX'.
  call function ADDON_FB2
    exporting
      i_rmmw1           = rmmw1
      i_eina            = eina
      i_eine            = eine
      I_RMMW1_BEZ       = rmmw1_bez
      I_MAKT            = makt
      i_neuflag         = neuflag
      i_aktyp           = t130m-aktyp
*     I_DISPLAY         = ' '
    tables
      t_meinh           = meinh
    changing
        c_ekaend        = rmmw3-ekaend
    EXCEPTIONS
      WRONG_CALL        = 1
      WRONG_SATNR       = 2
      NO_MATRIX         = 3
      OTHERS            = 4.
  if sy-subrc <> 0.
    message id sy-msgid type 'S' number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  CALL FUNCTION 'MAIN_PARAMETER_SET_RMMW3'
    EXPORTING
      WRMMW3        = rmmw3
            .

* Setzen des Kennzeichen, daß Einkaufsdaten geändert wurden
  perform zusatzdaten_set_sub.





ENDFUNCTION.
