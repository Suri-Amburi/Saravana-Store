*----------------------------------------------------------------------*
*   INCLUDE LMGD2I15                                                   *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   INCLUDE LMGD2I15                                                   *
*----------------------------------------------------------------------*
* jw/4.6B/4.10.99:
* neu zu 4.6B: Änderung des Bezugswegschlüssels führt zur Anpassung der
* Logistikdaten, deswegen wird eine Warnung ausgegeben. Sowohl in den
* Grunddaten (MARA-BWSCL) als auch in den Logistikdaten (MARC-BWSCL).

*&---------------------------------------------------------------------*
*&      Module  MARC-BWSCL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module marc-bwscl input.

* jw/23.12.99: in form-routine gekapselt
*  check lmarc-bwscl ne marc-bwscl.
*  check twpa-vlief ne 1 and twpa-vlief ne 2.  "wird lt. Cust. kopiert?

*  message w245(mh).
  perform bwscl_geaendert using space.

endmodule.                             " MARC-BWSCL  INPUT

*&---------------------------------------------------------------------*
*&      Module  MARA-BWSCL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module mara-bwscl input.

* jw/23.12.99: in form-routine gekapselt
*  check lmara-bwscl ne mara-bwscl.
*  check twpa-vlief ne 1 and twpa-vlief ne 2.  "wird lt. Cust. kopiert?

*  message w246(mh).

  perform bwscl_geaendert using x.

endmodule.                             " MARA-BWSCL  INPUT

*&---------------------------------------------------------------------*
*&      Form  bwscl_geaendert
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_X  text
*----------------------------------------------------------------------*
FORM bwscl_geaendert USING   value(p_grunddaten) type xfeld.

  data: marc_tab like standard table of marc,
        pre03_tab like standard table of pre03,
        wa_pre03 like pre03.

  check neuflag is initial.                   " jw/07.01.2000

  if p_grunddaten = x.
    check lmara-bwscl ne mara-bwscl.
  else.
    check lmarc-bwscl ne marc-bwscl.
  endif.

  check twpa-vlief ne 1 and twpa-vlief ne 2.  "wird lt. Cust. kopiert?

* jw/23.12.99: nur dann Warnung ausgeben, wenn überhaupt marc-Saetze
* existieren.
  wa_pre03-matnr = mara-matnr.
  append wa_pre03 to pre03_tab.

  CALL FUNCTION 'MARC_ARRAY_READ_MAT_ALL_BUFFER'
    TABLES
      IPRE03            = pre03_tab
      MARC_TAB          = marc_tab
*   MARC_DB_TAB       =
            .

  if not marc_tab[] is initial.
    if p_grunddaten = x.
      message w246(mh).
    else.
      message w245(mh).
    endif.
  endif.

ENDFORM.                               " bwscl_geaendert

* JH/29.05.01/4.7 Retrofit HPR - A
*&---------------------------------------------------------------------*
*&      Module  maw1-bbtyp  INPUT
*&---------------------------------------------------------------------*
* MAW1-BBTYP redundant in MARA wg. Sort.listenzugriffe (Performance)
*----------------------------------------------------------------------*
MODULE maw1-bbtyp INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CALL FUNCTION 'MAW1_MARA_BBTYP'
    EXPORTING
      MAW1_BBTYP       = maw1-bbtyp
    CHANGING
      MARA_BBTYP       = mara-bbtyp.


* JH/29.05.01/4.7 Retrofit HPR - E

ENDMODULE.                 " maw1-bbtyp  INPUT

*}   INSERT
