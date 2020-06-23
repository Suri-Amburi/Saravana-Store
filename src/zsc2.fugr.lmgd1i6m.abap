*---------------------------------------------------------------------*
*            XTHEAD_LEER_DEL                                          *
*---------------------------------------------------------------------*
*     - Alle noch nicht bearbeiteten Vorlage-Texte werden gesichert   *
*---------------------------------------------------------------------*
MODULE XTHEAD_LEER_DEL.
*=TF 4.6A===============================================================
  CALL FUNCTION 'LTEXT_STEPLOOP'
       IMPORTING
            E_ISOLD = GV_ISOLD.
  IF GV_ISOLD IS INITIAL.
*<<<<<<<<BEGIN OF DELETION NOTE 328641<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*    CLEAR BILDFLAG.
*    IF TC_LONGTEXT-TOP_LINE = TC_LONGTEXT_TOP_LINE.
*      CALL FUNCTION 'XTHEAD_LEER_DEL'
*           EXPORTING
*                OK_CODE      = RMMZU-OKCODE
*           IMPORTING
*                BILDFLAG_DEL = BILDFLAG.
*    ENDIF.
*<<<<<<<<END OF DELETION NOTE 328641<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*<<<<<<<<BEGIN OF INSERTION NOTE 328641<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    if not ( rmmzu-okcode is initial and not bildflag is initial ).
     if rmmzu-okcode = fcode_tean or
        rmmzu-okcode = fcode_tlan or
        rmmzu-okcode = fcode_telo or
        rmmzu-okcode = fcode_rlva or
        rmmzu-okcode = fcode_rlvp or
        rmmzu-okcode = fcode_pagn or
        rmmzu-okcode = fcode_pagp or
        rmmzu-okcode = fcode_ltex.
       CLEAR BILDFLAG.
     endif.
     if bildflag is initial.
      IF TC_LONGTEXT-TOP_LINE = TC_LONGTEXT_TOP_LINE.
        CALL FUNCTION 'XTHEAD_LEER_DEL'
             EXPORTING
                  OK_CODE      = RMMZU-OKCODE
             CHANGING
                  BILDFLAG_DEL = BILDFLAG.
        if not bildflag is initial.
          clear rmmzu-okcode.
        endif.
      ENDIF.
      endif.
    endif.
*<<<<<<<<END OF INSERTION NOTE 328641<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ELSE.
*=TF 4.6A===============================================================
  CALL FUNCTION 'XTHEAD_LEER_DEL'
       EXPORTING
            OK_CODE = RMMZU-OKCODE.
  ENDIF.  "TF 4.6A
ENDMODULE.
