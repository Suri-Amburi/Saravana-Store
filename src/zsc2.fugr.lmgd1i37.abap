*------------------------------------------------------------------
*  Module MBEW-HRKFT
*
*------------------------------------------------------------------
MODULE MBEW-HRKFT.
 CHECK BILDFLAG = SPACE.

 CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

 CHECK NOT MBEW-HRKFT IS INITIAL.

 CALL FUNCTION 'TKKH1_SINGLE_READ'
      EXPORTING
           KZRFB       = KZRFB
           TKKH1_KOKRS = RMMG2-KOKRS
           TKKH1_KOATY = '02'
           TKKH1_HRKFT = MBEW-HRKFT
*     IMPORTING
*          WTKKH1      =
      EXCEPTIONS
           NOT_FOUND   = 01.

 IF SY-SUBRC NE 0.
   MESSAGE E574 WITH RMMG2-KOKRS '02' MBEW-HRKFT.
 ENDIF.
ENDMODULE.
