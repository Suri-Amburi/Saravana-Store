*---------------------------------------------------------------------*
*       MODULE FILL_RMCBC INPUT                                       *
*---------------------------------------------------------------------*
*       Übertragen der bisher gesetzen Daten in den Modulpool         *
*       SAPLCBCM der Bildbausteine                                    *
*---------------------------------------------------------------------*
module fill_rmcbc.

  check g_sel_changed <> space.                               "H314444

  move-corresponding rmclf to rmcbc.
  call function tclfm-fbs_export
       exporting
            ermcbc      = rmcbc
            table       = sobtab
            read_object = kreuz
            ok_code     = okcode.

endmodule.
