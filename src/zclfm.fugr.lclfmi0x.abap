*---------------------------------------------------------------------*
*       MODULE FILL_RMCLF INPUT                                       *
*---------------------------------------------------------------------*
*       Abholen der in den Bildbausteinen gesetzten Felder            *
*---------------------------------------------------------------------*
module fill_rmclf.

  check g_sel_changed <> space.                             " 336748

  call function tclfm-fbs_import
       importing
            irmcbc = rmcbc.

  move-corresponding rmcbc to rmclf.

endmodule.
