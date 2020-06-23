*       - Prüfung bzgl Serialnummernprofil
*       - Prüfung, ob Standardprodukt zugeo. ist
*       - Prüfung, ob das Material als Standardprodukt verwendet wird
*------------------------------------------------------------------
MODULE mara-meins.

  CHECK bildflag IS INITIAL.           "Neu 20.02.93/MK
  CHECK t130m-aktyp NE aktypa AND t130m-aktyp NE aktypz.

* Prüfstatus zurücksetzen, falls Felder geändert wurden.
  IF ( NOT rmmzu-ps_meins  IS INITIAL ) AND
* Note 316843
     ( ( umara-meins NE mara-meins ) OR
* Da im Retail von einem SA auf eine VAR gewechselt werden kann, muß
* auch die MATNR in den Vergleich miteinbezogen werden, weil ansonsten
* die Prüfung für die VAR nicht mehr läuft, wenn die Prüfung schon für
* den SA gelaufen ist und die Daten bei beiden den gleichen Stand haben.
       ( umara-matnr NE mara-matnr ) ).
    CLEAR rmmzu-ps_meins.
  ENDIF.
* Wenn Prüfstatus = Space, Prüfbaustein aufrufen.
  IF ( rmmzu-ps_meins IS INITIAL ).
*mk/4.0 Kopie LMGD2I05 wieder mit Original LMGD1I01 vereint
*im Retailfall wird ein anderer Baustein aufgerufen
    IF rmmg2-flg_retail IS INITIAL.
      CALL FUNCTION 'MARA_MEINS'
        EXPORTING
          wmara            = mara
          wmarc            = marc
*         ret_meins        = lmara-meins          "TF 4.5B H126371
          aktyp            = t130m-aktyp
          neuflag          = neuflag
          matnr            = rmmg1-matnr
          zmara            = *mara
          flg_uebernahme   = ' '
          kz_meins_dimless = rmmg2-meins_diml
          p_message        = ' '
          rmmg2_kzmpn      = rmmg2-kzmpn  "mk/4.0A
          repid            = sy-repid               "note 2309145
          dynnr            = sy-dynnr               "note 2309145
        IMPORTING
          flag1            = flag1
          flag2            = flag2
          wmara            = mara
        TABLES
          meinh            = meinh
        CHANGING                                     "TF 4.5B H126371
          ret_meins        = lmara-meins          "TF 4.5B H126371
        EXCEPTIONS
          error_mpn        = 01.
      IF NOT sy-subrc IS INITIAL.
        bildflag = 'X'.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ELSE.                              "Retailfall
      CALL FUNCTION 'MARA_MEINS_RETAIL' "BE/030996
        EXPORTING
          wmara            = mara
*         ret_meins        = lmara-meins          "TF 4.5B H126371
          aktyp            = t130m-aktyp
          neuflag          = neuflag
          matnr            = rmmg1-matnr
          zmara            = *mara
          kz_meins_dimless = rmmg2-meins_diml
          rmmg2_kzmpn      = rmmg2-kzmpn     "mk/4.0A
        IMPORTING
          flag1            = flag1
          flag2            = flag2
          wmara            = mara
        TABLES
          meinh            = meinh
        CHANGING                                     "TF 4.5B H126371
          ret_meins        = lmara-meins.         "TF 4.5B H126371
    ENDIF.
    IF NOT flag1 IS INITIAL OR NOT flag2 IS INITIAL.
      rmmzu-ps_meins = x.
      umara = mara.
    ELSE.
      CLEAR rmmzu-ps_meins.
    ENDIF.
  ELSE.
* Wenn Prüfstatus = X und Felder wurden nicht geändert, Folgebearbeitung
*--- Aktualisieren der internen Tabelle Meinh und alte ME--------------
    PERFORM meinh_aktualisieren.
    CLEAR: flag1, flag2.
  ENDIF.
*
* begin of Note 1170778
* If an error happens in the CWM part, get and display the log
  DATA: lv_/cwm/log_handle TYPE balloghndl,
        lv_/cwm/msg_handle TYPE balmsghndl.
  IF   /cwm/cl_switch_check=>main( ) = /cwm/cl_switch_check=>true.
    LOG-POINT ID /cwm/enh SUBKEY to_upper( sy-tcode && '\/CWM/APPL_MD_LMGD1I0T\LMGD1I0T_02\' && sy-cprog ) FIELDS /cwm/cl_enh_layer=>get_field( ).

    IF flag2 EQ 'X'.
      CLEAR lv_/cwm/msg_handle.
      CALL FUNCTION 'BAL_GLB_MSG_CURRENT_HANDLE_GET'
        IMPORTING
          e_s_msg_handle = lv_/cwm/msg_handle
        EXCEPTIONS
          no_current_msg = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSE.
        CALL FUNCTION 'BAL_LOG_EXIST'
          EXPORTING
            i_log_handle  = lv_/cwm/msg_handle-log_handle
          EXCEPTIONS
            log_not_found = 1
            OTHERS        = 2.
        IF sy-subrc <> 0.
          CLEAR lv_/cwm/msg_handle.                         "n_1592202
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ELSE.
          PERFORM appl_log_show IN PROGRAM /cwm/saplmdmd
                            USING 'X'
                                  '11'
                                  lv_/cwm/msg_handle-log_handle.
* Delete application log from memory, if necessary
          PERFORM appl_log_refresh IN PROGRAM /cwm/saplmdmd
                           USING lv_/cwm/msg_handle-log_handle.
        ENDIF.
      ENDIF.
    ENDIF.
* end of Note 1170778
  ENDIF.
ENHANCEMENT-POINT lmgd1i0t_02 SPOTS es_lmgd1i0t INCLUDE BOUND .


  IF NOT flag1 IS INITIAL AND flag2 IS INITIAL.
*----Basis-ME änderbar - aber abhängige Objekte sind zu prüfen ---
    IF NOT sy-binpt IS INITIAL.
      MESSAGE w188 WITH *mara-meins mara-meins.
    ELSE.
* Aufruf Warnungsbild 551
      rmmzu-hokcode   = ok-code.
      rmmzu-okcode    = fcode_bmew.
      rmmzu-bildfolge = x.
      bildflag        = x.
    ENDIF.
  ENDIF.

  IF NOT flag2 IS INITIAL.
*---- Basis-ME nicht änderbar --------------------------------------
    MOVE *mara-meins TO mara-meins.
*mk/3.0C UMARA zu früh gefüllt, deswegen ging der 2. Änderungsversuch
*mit der gleichen ME durch
    umara = mara.                      "mk/3.0C
    rmmzu-err_bme = x.
    rmmzu-flg_fliste = x.

* ch/4.6C: Dequeue deaktiviert, da dieser die MARA-Sperre zurücknimmt !!
* (Ansonsten hat dieser Dequeue keine Wirkung gehabt, da er ohne
* OrgEbene abgesetzt wurde und daher nur generische (MARC-/MBEW-/..)
* Sperren ohne OrgEbene zurücksetzen würde. Solche Sperren werden aber
* schon lange nicht mehr abgesetzt)         "
*   CALL FUNCTION 'DEQUEUE_EMMATAE'         "
*        EXPORTING                          "
*             MATNR = RMMG1-MATNR.

* JH/20.03.98/4.0C Neues Sperrobj. für die Basismengeneinheit (Anfang)
    CALL FUNCTION 'DEQUEUE_EMMARME'
      EXPORTING
        matnr = rmmg1-matnr.     "generisch alle ME
    IF lmara-attyp = attyp_samm.
      PERFORM dequeue_variants USING rmmg1-matnr.
    ENDIF.
* JH/20.03.98/4.0C Neues Sperrobj. für die Basismengeneinheit (Ende)
    IF NOT sy-binpt IS INITIAL OR NOT sy-batch IS INITIAL.
      MESSAGE e189.
    ENDIF.
    MESSAGE s189.                      "Änderung GUI-Status
    bildflag = x.
  ENDIF.
  IF   /cwm/cl_switch_check=>main( ) = /cwm/cl_switch_check=>true.
    IF mara-/cwm/xcwmat IS INITIAL.
      LOG-POINT ID /cwm/enh SUBKEY to_upper( sy-tcode && '\/CWM/APPL_MD_LMGD1I0T\LMGD1I0T_01\' && sy-cprog ) FIELDS /cwm/cl_enh_layer=>get_field( ).
      mara-/cwm/valum = mara-meins.
      CLEAR mara-/cwm/tolgr.
    ENDIF.
* begin of Note 1170778
* overwrite the standard message
    IF NOT lv_/cwm/msg_handle IS INITIAL AND flag2 EQ 'X'.
      CLEAR rmmzu-flg_fliste.
      MESSAGE s001.
    ENDIF.
* end of Note 1170778
  ENDIF.
ENHANCEMENT-POINT lmgd1i0t_01 SPOTS es_lmgd1i0t INCLUDE BOUND.


ENDMODULE.
