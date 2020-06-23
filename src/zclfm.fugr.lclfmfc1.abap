*----------------------------------------------------------------------*
*   INCLUDE LCLFMFC1                                                   *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   Form ON_CTMENU_ALLOC
*----------------------------------------------------------------------*

form on_ctmenu_alloc
     using p_menu type ref to cl_ctmenu.

  data  l_fcodes         type ui_functions.
  data: begin of lwa_fcodes,
          fcode          type ui_func,
        end of lwa_fcodes.

* load menue for allocation subscreen

  call method p_menu->load_gui_status
      exporting program = c_prog_clfm
                status  = ctstatalloc
                menu    = p_menu.

endform.
