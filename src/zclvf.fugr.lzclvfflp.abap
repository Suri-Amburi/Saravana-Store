*&---------------------------------------------------------------------*
*&  Include           LCLVFFLP
*&---------------------------------------------------------------------*
 LOAD-OF-PROGRAM.

   GET BADI gr_badi_clf_update.
   IF gr_badi_clf_update IS BOUND.
     gv_num_badi_clf_update_impl = cl_badi_query=>number_of_implementations( gr_badi_clf_update ).
   ENDIF.
