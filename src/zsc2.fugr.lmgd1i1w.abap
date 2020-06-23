*------------------------------------------------------------------
*  Module MARC-WEBAZ.
*  Falls QM-Prüfdaten gepflegt sind (in diesem Fall sitzt MARC-QMATV),
*  muß die Prüfdauer des WEs <= der WE-Bearbeitungszeit sein.
*------------------------------------------------------------------
MODULE MARC-WEBAZ.

*
* Prüfung kann entfallen -> deaktiviert zu 4.0C (H: 86848)
*
* CHECK BILDFLAG = SPACE.
* CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
*
* CALL FUNCTION 'MARC_WEBAZ'
*      EXPORTING
*           P_QMATV = MARC-QMATV
*           P_MATNR = RMMG1-MATNR
*           P_WERKS = RMMG1-WERKS
*           P_WEBAZ = MARC-WEBAZ.
*      EXCEPTIONS
*           P_ERR_MARC_WEBAZ = 01.

ENDMODULE.
