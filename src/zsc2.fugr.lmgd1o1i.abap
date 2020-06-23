*----------------------------------------------------------------------*
*   INCLUDE LMGD1O1I                                                   *
*----------------------------------------------------------------------*

module megrp_set_values output.
* jw/20.01.99/4.6A: Umstellung des Feldes 'RM03E-MEGRP' auf Dropdown-
* Listbox. Füllen der Werteliste.

  type-pools: vrm.
  data: id_megrp type vrm_id,
        megrp_values type vrm_values with header line.
*  TYPES: STRUCT LIKE RM03E-MEGRP,
*        TY_MEGRP TYPE STANDARD TABLE OF STRUCT.
  data: h_megrp like t006m-megrp,
        itab_t006m like standard table of t006m with header line,
        wa_t006m like t006m.

  id_megrp = 'RM03E-MEGRP'.
* Check if Valueset already exists
  call function 'VRM_GET_VALUES'
       exporting
            id           = id_megrp
*    IMPORTING
*         VALUES       =
       exceptions
            id_not_found = 1
            others       = 2
            .
  case sy-subrc.
    when 0.
    when 1.

      select * from t006m into table itab_t006m.
      sort itab_t006m by megrp meinh.
      clear h_megrp.

      loop at itab_t006m into wa_t006m.
*       neue Mengeneinheitengruppe:
        if wa_t006m-megrp ne h_megrp.
*         alte Mengeneinheitengruppe noch abschliessen
*         (nur beim ersten Satz nicht)
          if sy-tabix ne 1.
            concatenate megrp_values-text ')'
                 into megrp_values-text.
            append megrp_values.
            clear megrp_values.
          endif.
*         neue Mengeneinheitengruppe, erste Mengeneinheit:
          h_megrp = wa_t006m-megrp.
          megrp_values-key = wa_t006m-megrp.
          concatenate wa_t006m-megrp '('
                 into megrp_values-text separated by space.
          concatenate megrp_values-text wa_t006m-meinh
                 into megrp_values-text.
        else.
*         Mengeneinheitengruppe hat sich nicht verändert, ME dazufügen
          concatenate megrp_values-text wa_t006m-meinh
                 into megrp_values-text separated by space.
        endif.
      endloop.
*     Letzten Satz noch hinzufügen
      if sy-subrc = 0.        "nur wenn überhaupt was gefunden wurde
        concatenate megrp_values-text ')'
             into megrp_values-text.
        append megrp_values.
      endif.

      call function 'VRM_SET_VALUES'
           exporting
                id              = id_megrp
                values          = megrp_values[]
           exceptions
                id_illegal_name = 1
                others          = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.

    when others.
      message id sy-msgid type sy-msgty number sy-msgno
        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endcase.

endmodule.
