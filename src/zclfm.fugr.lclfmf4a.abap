*&---------------------------------------------------------------------*
*&      Form  CALL_CLFM_FUNCTION
*&---------------------------------------------------------------------*
*       Calls CLFM_OBJECT_CLASSIFICATION to start classsification.
*       Function called after ok-code
*       ok_clfm_change / _display or oknezu
*----------------------------------------------------------------------*

form call_clfm_function
     using value(p_mode).

  data: l_klart    like rmclf-klart,
        l_upd      like sy-batch.


  classif_status = p_mode.

  case g_zuord.

    when c_zuord_0.
      if no_class <> space and classif_status = c_change.
*       only master data classification allowed
        message s502 with rmclf-klart.
        clear rmclf-klart.
        set parameter id c_param_kar field space.
        leave to transaction sy-tcode.
      endif.

      if not sobtab is initial.
*--     Aktuelle SOBTAB merken wg. Einstiegsbild
        set parameter id c_param_klt field sobtab.
      endif.

      l_klart = rmclf-klart.
      call function 'CLFM_OBJECT_CLASSIFICATION'
           exporting
                table                    = sobtab
                ptable                   = pobtab
                object                   = rmclf-objek
                objtxt                   = rmclf-obtxt
                classtype                = rmclf-klart
                typetext                 = rmclf-artxt
                status                   = classif_status
                initflag                 = kreuz
                multi_classif            = multi_class
                meins                    = rmclf-meins
                change_service_number    = rmclf-aennr1
                i_effectivity_used       = g_effectivity_used
                date_of_change           = rmclf-datuv1
                obj_has_change_service   = kreuz
                hierarchy_allowed        = tcla-hierarchie
                variant_klart            = tcla-varklart
           importing
                classtype                = l_klart
                updateflag               = l_upd
                ok_code                  = sokcode
           exceptions
                classification_not_found = 1
                foreign_lock             = 2
                system_failure           = 3
                change_nr_not_compatible = 4
                others                   = 5.

      case sy-subrc.
*-- Es wird was gesperrt, Klassifizierung kann nicht vollst.erfolgen
        when 0.
        when 1.
          message s509 with rmclf-klart.
          leave to transaction sy-tcode.
        when 2.
          message s519.
          leave to transaction sy-tcode.
        when 4.
*         message s182 with rmclf-aennr1.
          leave to transaction sy-tcode.
        when others.
          message id sy-msgid type sy-msgty number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endcase.

    when c_zuord_2.
      call function 'CLFM_CLASS_CLASSIFICATION'
           exporting
                table                 = sobtab
                object                = rmclf-clasn
                objtxt                = rmclf-ktext
                clintn                = klah-clint
                classtype             = rmclf-klart
                typetext              = rmclf-artxt
                multi_classif         = multi_class
                status                = classif_status
                klah_vwstl            = klah-vwstl
                change_service_number = rmclf-aennr1
                i_effectivity_used    = g_effectivity_used
                date_of_change        = rmclf-datuv1
           importing
                updateflag            = l_upd
                ok_code               = sokcode
           exceptions
                change_nr_changed     = 1
                change_nr_same_date   = 2.

      case sy-subrc.
        when 1.
          message s096.
          leave to transaction sy-tcode.
        when 2.
          leave to transaction sy-tcode.
      endcase.

      if not sklasse is initial.
        set parameter id c_param_kla field sklasse.
      endif.
      if syst-calld = kreuz.
        export l_upd to memory id tcodecl22.
      endif.


    when c_zuord_4.
      if no_class <> space and classif_status = c_change.
*       only master data classification allowed
        message s502 with rmclf-klart.
        clear rmclf-klart.
        set parameter id c_param_kar field space.
        leave to transaction sy-tcode.
      endif.

      call function 'CLFM_OBJECTS_CLASSIFICATION'
           exporting
                table                 = sobtab
                object                = rmclf-clasn
                objtxt                = rmclf-ktext
                clintn                = klah-clint
                classtype             = rmclf-klart
                typetext              = rmclf-artxt
                multi_classif         = multi_class
                mult_obj              = multi_obj
                sicht                 = klah-sicht
                pruefen               = klah-praus
                status                = classif_status
                class_only            = no_class
                klah_vwstl            = klah-vwstl
                klah_meins            = klah-meins
                change_service_number = rmclf-aennr1
                i_effectivity_used    = g_effectivity_used
                date_of_change        = rmclf-datuv1
                hierarchy_allowed     = tcla-hierarchie
           importing
                updateflag            = l_upd
                ok_code               = sokcode
           exceptions
                change_nr_changed     = 1.

      if sy-subrc > 0.
        leave to transaction sy-tcode.
      endif.
      if not sklasse is initial.
        set parameter id c_param_kla field sklasse.
      endif.
      if syst-calld = kreuz.
        export l_upd to memory id tcodecl22.
      endif.

  endcase.                             "g_zuord

  clear okcode.
  clear sokcode.

endform.                               " CALL_FUNCTION_OBJECT
