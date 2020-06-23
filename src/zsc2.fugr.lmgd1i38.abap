*------------------------------------------------------------------
*  Module MBEW-ZPLPR                          ch zu 3.1I / H: 84583
*
* Zukünftiger Planpreis der Kalkulation
*------------------------------------------------------------------
MODULE MBEW-ZPLPR.
 CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
 CALL FUNCTION 'MBEW_ZPLPR'
      EXPORTING
           WMBEW   =  MBEW
           LMBEW   =  LMBEW
           UMBEW   =  UMBEW
      IMPORTING
           WMBEW   =  MBEW
      EXCEPTIONS
           OTHERS  = 1.
ENDMODULE.
