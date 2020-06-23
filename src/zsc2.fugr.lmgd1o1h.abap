*----------------------------------------------------------------------*
*   INCLUDE LMGD1O1H                                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  Me_ANZAHL_sub_BERECHNEN  OUTPUT
*&---------------------------------------------------------------------*
*       Rel. 4.6A JW
*       Berechnung der Anzahl der Submengeneinheiten aus den
*       Umrechnungsfaktoren umrez und umren in der Tabelle meinh
*----------------------------------------------------------------------*
MODULE ME_ANZAHL_SUB_BERECHNEN OUTPUT.

DATA: WA_MEINH LIKE SMEINH,
SUB_MEINH LIKE SMEINH.

check not mara-meins is initial.

if not ME_FEHLERFLG IS INITIAL.        " Fehler im letzten PBO
   loop at meinh into wa_meinh where mesub is initial.
     wa_meinh-mesub = mara-meins.
     modify meinh from wa_meinh.
   endloop.

else.                                  " Berechnung azsub, Setzen mesub
  LOOP AT MEINH INTO WA_MEINH.
    IF WA_MEINH-MESUB IS INITIAL.
       WA_MEINH-MESUB = mara-meins.
       MODIFY MEINH FROM WA_MEINH.
    ENDIF.
    CHECK WA_MEINH-UMREN NE 0.
    IF WA_MEINH-MESUB = mara-meins.
      WA_MEINH-AZSUB = WA_MEINH-UMREZ / WA_MEINH-UMREN.
    ELSE.
      READ TABLE MEINH WITH KEY meinh = WA_MEINH-MESUB
               INTO SUB_MEINH.
       IF SY-SUBRC = 0.
         CHECK SUB_MEINH-UMREZ <> 0.
         WA_MEINH-AZSUB = ( WA_MEINH-UMREZ * SUB_MEINH-UMREN ) /
                         ( WA_MEINH-UMREN * SUB_MEINH-UMREZ ).
       ELSE.
*        error Subeinheit ex. nicht.
       ENDIF.
    ENDIF.
    MODIFY MEINH FROM WA_MEINH.
  ENDLOOP.
endif.
ENDMODULE.                 " me_ANZAHL_sub_BERECHNEN  OUTPUT
