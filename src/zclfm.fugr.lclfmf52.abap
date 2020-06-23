*&---------------------------------------------------------------------*
*&      Form  ok_obj_disp
*&---------------------------------------------------------------------*
*       Display master data to selected object: class/object.
*       Calls corresponding transaction.
*----------------------------------------------------------------------*
form ok_obj_disp.

  data:
    l_class         like klah-class,
    l_noparam       like sy-batch.

  perform read_selected_line changing l_class.

  if l_class is initial.
*   display object
    call function 'CLCV_CONVERT_OBJECT_TO_FIELDS'
         EXPORTING
              table          = sobtab
              rmclfstru      = rmclf
              set_param      = kreuz
         IMPORTING
              tcode          = ssytcode
              rmclfstru      = rmclf
              no_param       = l_noparam
         tables
              lengthtab      = laengtab
         EXCEPTIONS
              tclo_not_found = 1.
    check not ssytcode is initial.
    if not l_noparam is initial.
*     no SET/GET parameter for this object type:
*     call not possible.
      message e514 with sobtab.
    endif.
    call transaction ssytcode with authority-check            "1909745
                              and skip first screen.

  else.
*   display class
    authority-check object 'C_KLAH_BKP'
    id 'ACTVT' field '03'
    id 'BGRKP' dummy.
    if syst-subrc ne 0.
      message e075 with tcodecl03.
    endif.
    klah-class = l_class.
    set parameter id c_param_kla field klah-class.
    set parameter id c_param_kar field rmclf-klart.     " neu in 4.5A
    set parameter id c_param_aen field rmclf-aennr1.

    CALL FUNCTION 'CLMO_CLASS_OBJECT_DISPLAY_RFC'        "begin 1785587
         DESTINATION 'NONE'
         EXPORTING
             iv_classtype          = rmclf-klart
             iv_classname          = klah-class
             iv_objectname         = ' '
             iv_changenumber       = rmclf-aennr1
             iv_skip               = kreuz
         EXCEPTIONS
              retailtype_missing = 1
              no_authority       = 2
              others             = 3.                      "end 1785587
    if sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    endif.
  endif.

endform.                               " ok_obj_disp
