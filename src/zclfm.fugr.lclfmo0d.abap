*------------------------------------------------------------------*
*       MODULE SORT_KLASTAB OUTPUT                                 *
*------------------------------------------------------------------*
*       Sortieren klastab nach Positionsnummer
*       cl20(N) , cl22(N) , Objekttransaktionen
*       Alle klastab-objek gleich !
*------------------------------------------------------------------*
module sort_klastab output.

* sort class list by position number and internal index
  sort klastab by zaehl index_tab.

endmodule.
