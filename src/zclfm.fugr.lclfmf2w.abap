*---------------------------------------------------------------------*
*       FORM lesen_udef.                                              *
*---------------------------------------------------------------------*
*       Wenn beim kopieren Klassifizierung eine Klasse mitgegeben wird*
*       so wird diese Klasse zugeordnet und die Merkmale mit den      *
*       Merkmalen der Referenzklasse abgemischt.                      *
*---------------------------------------------------------------------*
form lesen_udef tables tksml structure ksml
                using merkmal like ksml-imerk.


  data: begin of tcabn occurs 0.
          include structure cabn.
  data: end   of tcabn.

  ranges: rimerk for ksml-imerk.

  rimerk-sign   = incl.
  rimerk-option = equal.
  rimerk-low    = merkmal.
  append rimerk.
  call function 'CLSE_SELECT_CABN'
       exporting
            key_date        = rmclf-datuv1
*            i_aennr         = rmclf-aennr1             "4.6.98 CF
       tables
            in_cabn                      = rimerk
            t_cabn                       = tcabn
       exceptions
            no_entry_found               = 1
            others                       = 2.
  read table tcabn index 1.
  check syst-subrc = 0.
  tksml-clint = tcabn-clint.
  append tksml.
  call function 'CLSE_SELECT_KSML'
       EXPORTING
            key_date       = rmclf-datuv1
            i_aennr        = rmclf-aennr1
       TABLES
            imp_exp_ksml   = tksml
       EXCEPTIONS
            no_entry_found = 1
            others         = 2.
endform.
