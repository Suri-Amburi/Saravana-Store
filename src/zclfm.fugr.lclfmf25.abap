*§-----------------------------------------------------------------*
*        FORM LOESCHEN_DUNKEL                                      *
*------------------------------------------------------------------*
*        Löschkennzeichen in ALLKSSK,ALLAUSP und VIEW              *
*        Fortschreiben der Tabelle DELCL.                          *
*------------------------------------------------------------------*
form loeschen_dunkel using alte_klasse like klah-class
                           standard    like allkssk-stdcl.
  DATA:                                                        "1167642
    lv_smsgv TYPE sy-msgv1.                                    "1167642
*----------------------------------------------------------------------

  loop at allkssk where objek = rmclf-objek
                    and klart = rmclf-klart.
    check allkssk-lock ne kreuz.
* Sperren Beziehung Objekt - Klasse
    CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'          "begin 1141804
      EXPORTING
        iv_enqmode           = 'S'
        iv_klart             = rmclf-klart
        IV_CLASS             = rmclf-class
        IV_MAFID             = mafido
        IV_OBJEK             = rmclf-objek
      EXCEPTIONS
        FOREIGN_LOCK         = 1
        SYSTEM_FAILURE       = 2.
    case sy-subrc.                                         "end 1141804
      WHEN 1.                                            "begin 1167642
        IF sy-msgv1 IS INITIAL.
*         "classification not possible at the moment"
          MESSAGE e517
                  RAISING foreign_lock.
        ELSE.
*         "class type & : class & locked by user &"
          lv_smsgv = sy-msgv1.
          MESSAGE e518
                  WITH rmclf-klart
                       rmclf-class
                       lv_smsgv
                  RAISING foreign_lock.
        ENDIF.
      WHEN 2.
*       "locking errors"
        MESSAGE e519
                RAISING system_failure.                    "end 1167642
    endcase.
    allkssk-lock = kreuz.
    modify allkssk.
    if view_complete ne kreuz.
      klastab-clint = allkssk-clint.
      klastab-objek = allkssk-class.
      perform build_viewtab using klastab-clint
                                 klastab-objek.
    endif.
  endloop.
  loop at allkssk where objek = rmclf-objek
                    and class = alte_klasse
                    and klart = rmclf-klart.
    standard = allkssk-stdcl.
*>>> VBKZ auf D setzen, sofern es nicht auf I steht!!!
    if allkssk-vbkz ne c_insert .
      allkssk-vbkz = c_delete.
      perform delete_database using allkssk space.
      del_counter = del_counter + 1.
    else.
      clear: allkssk-vbkz , allkssk-objek .
    endif.
    modify allkssk.
    exit.
  endloop.
  if syst-subrc ne 0.
    raise classification_not_found.
  endif.
  loop at allausp where objek = rmclf-objek
                    and klart = rmclf-klart.
    allausp-delkz = kreuz.
    modify allausp.
  endloop.
  view_complete = kreuz.
endform.
