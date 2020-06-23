*------------------------------------------------------------------*
*        FORM FUELLEN_DELCL                                        *
*------------------------------------------------------------------*
*        Füllen der Löschtabelle                                   *
*        Wird nur in delete_database verwendet.                    *
*------------------------------------------------------------------*
form fuellen_delcl using merkm like ausp-atinn
                         p_allkssk structure rmclkssk .
  if merkm is initial .
    p_allkssk-vbkz = c_delete.
  endif.
  read table delcl with key
                        mafid = p_allkssk-mafid
                        klart = rmclf-klart
                        objek = p_allkssk-objek
                        clint = p_allkssk-clint
                        merkm = merkm
                        transporting no fields.
  check not sy-subrc is initial.

  delcl-mafid = p_allkssk-mafid.
  delcl-klart = rmclf-klart.
  delcl-objek = p_allkssk-objek.
  delcl-clint = p_allkssk-clint.
  delcl-merkm = merkm.
  delcl-cuobj = p_allkssk-cuobj.
  delcl-obtab = p_allkssk-obtab.
  append delcl.
endform.
