*------------------------------------------------------------------
*  Module MARC-RWPRO
*  Pruefung des Reichweitenprofils      " AHE: 05.02.97 noch zu 3.1G
*------------------------------------------------------------------
MODULE MARC-RWPRO.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_RWPRO'
       EXPORTING
            P_WERKS = MARC-WERKS
            P_RWPRO = MARC-RWPRO.
*      EXCEPTIONS
*           P_ERR_MARC_RWPRO = 1
*           OTHERS           = 2.

ENDMODULE.
