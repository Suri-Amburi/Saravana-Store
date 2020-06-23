*§-----------------------------------------------------------------*
*        FORM BEENDEN_TAB_LOESCH                                   *
*------------------------------------------------------------------*
*        Beenden Klassifizierung                                   *
*------------------------------------------------------------------*
form beenden_tab_loesch.
  data: aendern                value 'V'.


  loop at allkssk.
    loop at viewk where class = allkssk-objek
                    and klart = rmclf-klart.
      loop at allausp where objek = rmclf-objek
                        and klart = rmclf-klart
                        and mafid = mafido
                        and atinn = viewk-merkm
                        and statu ne space.
        check allausp-statu ne aendern.
        case allausp-statu.
          when loeschen.
            clear allausp-statu.
            modify allausp.
          when hinzu.
            delete allausp.
        endcase.
      endloop.
    endloop.
  endloop.
  loop at allkssk where objek = rmclf-objek
                    and klart = rmclf-klart
                    and vbkz eq space .
*>>> Was bedeutet das ???
    if not allkssk-cuobj is initial.
      call function 'CUOB_DELETE_OBJECT_FROM_BUFFER'
           EXPORTING
                object_id = allkssk-cuobj.
    endif.
*+  endif.
  endloop.
endform.
