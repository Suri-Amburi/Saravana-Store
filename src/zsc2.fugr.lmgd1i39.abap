*------------------------------------------------------------------
*  Module MBEW-ZPLP.
*
* Planpreise Kalkulation und zugehöriges Datum muessen gleichzeitig
* gesetzt werden.
* Das  Datum darf nicht in der Vergangenheit liegen.
*------------------------------------------------------------------
MODULE MBEW-ZPLP.
*CHECK BILDFLAG = SPACE.                         "ch zu 3.1I / H: 84583
 CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

 CALL FUNCTION 'MBEW_ZPLP'
      EXPORTING
           WMBEW           = MBEW
           LMBEW           = LMBEW               "ch zu 3.1I / H: 84583
           UMBEW           = UMBEW               "ch zu 3.1I / H: 84583
           P_AKTYP         = T130M-AKTYP
           P_MESSAGE       = ' '
      IMPORTING
           WMBEW           = MBEW.
*     EXCEPTIONS
*          ERROR_NACHRICHT = 01.
ENDMODULE.
