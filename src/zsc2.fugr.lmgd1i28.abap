
*&---------------------------------------------------------------------*
*&      Module  mara-sernp  INPUT
*&---------------------------------------------------------------------*
*       Prüfung des Serialnummernprofils
*----------------------------------------------------------------------*

MODULE marc-sernp.

  CHECK bildflag = space.
  CHECK t130m-aktyp NE aktypa AND t130m-aktyp NE aktypz.

  CALL FUNCTION 'MARC_SERNP'
    EXPORTING
      wmarc_sernp      = marc-sernp
      wmarc_xchpf      = marc-xchpf
      wmarc_bwtty      = marc-bwtty
      wmarc_rgekz      = marc-rgekz  "neu zu 3.0e/ch
      wmara_meins      = mara-meins
      wrmmg1_matnr     = rmmg1-matnr
      lmarc_sernp      = lmarc-sernp
      wmbew_bwtar      = mbew-bwtar
      kz_meins_dimless = rmmg2-meins_diml
      wmarc_werks      = marc-werks  "NOTE 350004
    IMPORTING
      wmarc_sernp      = marc-sernp
      kz_meins_dimless = rmmg2-meins_diml.

ENDMODULE.                    "MARC-SERNP


*&---------------------------------------------------------------------*
*&      Module  mara-serlv  INPUT
*&---------------------------------------------------------------------*
*       TF 4.7 Ebene der Eindeutigkeit für Serialnummer
*----------------------------------------------------------------------*

MODULE mara-serlv INPUT.

  CHECK t130m-aktyp NE aktypa AND t130m-aktyp NE aktypz.
  CHECK bildflag = space.

  CHECK mara-serlv NE lmara-serlv.

  CALL FUNCTION 'MARA_SERLV_CHECK'
    EXPORTING
      i_matnr   = rmmg1-matnr
      i_serlv   = mara-serlv
      old_serlv = lmara-serlv.

ENDMODULE.                 " mara-serlv  INPUT
