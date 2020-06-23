*&---------------------------------------------------------------------*
*&      Form  OKB_KLAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_klas.
  if zeile ne 0.
    message s002 with rmclf-klart 'Klasse'(500) klastab-objek.
  else.
    okcode = sokcode.
  endif.
endform.                               " OKB_KLAS
