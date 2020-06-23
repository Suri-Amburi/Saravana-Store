*------------------------------------------------------------------
*           MARC-QSSYS.
* Falls kein Steuerschlüssel für die QM-Beschaffung eingegeben wurde,
* obwohl ein QS-System eingegeben wurde, erfolgt eine entspr. Warnmeldg.
*------------------------------------------------------------------
MODULE MARC-QSSYS.

 CHECK BILDFLAG IS INITIAL.
 CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

 CALL FUNCTION 'MARC_QSSYS'
      EXPORTING
           P_MESSAGE     =  ' '
           P_MARC_QSSYS  =  MARC-QSSYS
           RET_QSSYS     =  LMARC-QSSYS
           P_MARC_SSQSS  =  MARC-SSQSS
           RET_SSQSS     =  LMARC-SSQSS
      IMPORTING
           RET_QSSYS     = LMARC-QSSYS .
ENDMODULE.
