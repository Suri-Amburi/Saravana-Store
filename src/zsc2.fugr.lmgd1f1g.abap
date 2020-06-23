*&---------------------------------------------------------------------*
*&      Form  DEL_EAN_LIEF_MEINH
*&---------------------------------------------------------------------*
*       Prüft, ob bei einer zu löschenden EAN ein Lieferantenbezug
*       besteht. Wenn ja, wird im hier vorliegenden Aufruffall
*       (aus Mengeneinheitenbild) das Löschen nicht erlaubt.
*       Löschen ist nur aus dem EAN-Bild heraus möglich.
*       Form wird nur im Retail-Fall aufgerufen.
*----------------------------------------------------------------------*
* AHE: 19.06.96 - Neues Form ! !
FORM DEL_EAN_LIEF_MEINH USING FLAG_EXIT TYPE C.

  CLEAR FLAG_EXIT.

* Check, ob Lieferantenbezug besteht:
  IF RMMW2-ATTYP = '01' and NOT RMMW2-VARNR IS INITIAL.
* Mit Variantenartikelnummer lesen
  READ TABLE TMLEA WITH KEY MATNR = RMMW2-varnr
                            MEINH = MEINH-MEINH
*                           LIFNR = RMMW2_LIEF
                            EAN11 = MEINH-EAN11
                                    BINARY SEARCH.

  else.
* Sammelartikel order Einzelartikelfall
  READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
                            MEINH = MEINH-MEINH
*                           LIFNR = RMMW2_LIEF
                            EAN11 = MEINH-EAN11
                                    BINARY SEARCH.
  endif.
  IF SY-SUBRC = 0.
* es existiert ein relevanter Lieferantenbezug zur EAN =>
* Löschen ist nicht erlaubt weil:
* - u. U. ist diese EAN bei einigen oder allen Lieferanten als
*   Haupt-EAN-Lief gekennzeichnet. Wenn Löschen hier erlaubt wäre,
*   müßten von hier aus all die Lieferanten, bei denen diese EAN
*   als Haupt-EAN gekennzeichnet ist, eine neue Haupt-EAN erhalten.

*   CLEAR RMMZU-OKCODE.
    IF BILDFLAG IS INITIAL.
      BILDFLAG = X.
    ENDIF.
    FLAG_EXIT = 'N'.
    MEINH-EANGEPRFT = X.
    MESSAGE I151(MH) WITH MEINH-EAN11.

  ENDIF.

ENDFORM.                               " DEL_EAN_LIEF_MEINH
