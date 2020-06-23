REPORT ZZRWDPOSAN MESSAGE-ID WC.

*  IF sy-tcode = 'WPMA'.
*    "--------------------------------------------------------
*    " shall not be executable as long as Retail is hidden
*    DATA: lv_is_s4h TYPE abap_bool.
*
*    CALL METHOD cl_cos_utilities=>is_s4h
*      RECEIVING
*        rv_is_s4h = lv_is_s4h.
*
*    IF lv_is_s4h = abap_true.
*        WRITE: / 'Feature not supported'(004).
*        RETURN.
*    ENDIF.
*    "----------------------------------------------------
*
*  ENDIF.


*ENHANCEMENT-POINT RWDPOSAN_G4 SPOTS ES_RWDPOSAN STATIC.
*ENHANCEMENT-POINT RWDPOSAN_G5 SPOTS ES_RWDPOSAN.
*ENHANCEMENT-POINT RWDPOSAN_G6 SPOTS ES_RWDPOSAN STATIC.
*ENHANCEMENT-POINT RWDPOSAN_G7 SPOTS ES_RWDPOSAN.

* Datendeklarationen.
INCLUDE ZZPOSANT01.
*INCLUDE POSANTOP.

* Benötigte FORM-Routinen.
INCLUDE ZZPOSANF01.
*INCLUDE POSANF01.

* Benötigte FORM-Routinen aus Report RWDPOSIN.
INCLUDE ZZPOSINF01.
*INCLUDE POSINF01.

* Ereignisse
INCLUDE ZZPOSANE01.
*INCLUDE POSANE01.
