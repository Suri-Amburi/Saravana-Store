*----------------------------------------------------------------------*
***INCLUDE LCLFMF2O .
*----------------------------------------------------------------------*
*                                                        "begin 1143722
*&---------------------------------------------------------------------*
*&      Form  allkssk_zaehl_set
*&---------------------------------------------------------------------*
*       set position counter for KSSK-table
*----------------------------------------------------------------------*
*      -->IV_OBJEK   classified object
*      -->IV_KLART   class type
*      -->IV_MAFID   classification id (O = object, K = class)
*      <--CV_ZAEHL   position counter for table KSSK
*----------------------------------------------------------------------*
FORM allkssk_zaehl_set
         USING
            iv_objek TYPE kssk-objek
            iv_klart TYPE kssk-klart
            iv_mafid TYPE kssk-mafid
         CHANGING
            cv_zaehl TYPE kssk-zaehl.

  statics:
    sv_objek TYPE kssk-objek,
    sv_klart TYPE kssk-klart,
    sv_mafid TYPE kssk-mafid,
    st_char_prof TYPE TABLE OF klah-class,                    "v 2178165
    s_char_prof  TYPE klah-class,
    s_init       TYPE c.                                      "^ 2178165

  FIELD-SYMBOLS:
    <ls_kssk> LIKE allkssk.


  IF iv_klart <> '026' OR iv_mafid <> 'K'.                    "v 2178165
*   no retail class to class assignment
    CLEAR s_char_prof.
  ELSE.
    IF NOT s_char_prof IS INITIAL AND iv_objek = s_char_prof.
*     same characterisic profile as previously -> keep it
    ELSE.
      IF s_init IS INITIAL.
*       get all characteristic profiles
        SELECT class FROM klah INTO TABLE st_char_prof
          WHERE klart = '026' AND wwskz = '2'.
        SORT st_char_prof BY table_line.
        s_init = 'X'.
      ENDIF.

*     get subordinated class, if it is a characteristic profile
      CLEAR s_char_prof.
      READ TABLE st_char_prof INTO s_char_prof
        WITH KEY table_line = iv_objek BINARY SEARCH.
    ENDIF.
  ENDIF.

  IF NOT s_char_prof IS INITIAL.
*   KSSK-ZAEHL is always 0 for characteristic profiles
    hzaehl = 0.
  ELSEIF g_zuord NE c_zuord_4.                                "^ 2178165
*   classes' assignment to object
*   counter was set for this object classification before
    IF iv_objek ne sv_objek or
       iv_klart ne sv_klart or
       iv_mafid ne sv_mafid or
       hzaehl is initial.
*     initialize counter after change of object
      CLEAR hzaehl.                                            "1471329
*     set classification object
      sv_objek = iv_objek.
      sv_klart = iv_klart.
      sv_mafid = iv_mafid.
*     get highest counter in allkssk
      LOOP AT allkssk ASSIGNING <ls_kssk>
                      WHERE objek = iv_objek
                        AND klart = iv_klart
                        AND mafid = iv_mafid.
        CHECK <ls_kssk>-zaehl > hzaehl.
        hzaehl = <ls_kssk>-zaehl.
      ENDLOOP.
    endif.
*   set new counter
    hzaehl = hzaehl + 10 .
*   set return parameter
    cv_zaehl = hzaehl.
  ELSE.
*   objects' assignment to class
    cv_zaehl = 1.
  ENDIF.
ENDFORM.                               " ALLKSSK_ZAEHL_SET "end 1143722
