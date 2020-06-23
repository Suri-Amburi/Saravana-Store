*----------------------------------------------------------------------*
***INCLUDE LWSOTF06.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FILL_WRSZ_BUFFER_BY_LOCNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PiRT_LOCNR  text
*----------------------------------------------------------------------*
FORM fill_wrsz_buffer  USING  pirt_locnr    TYPE locnr_rtty
                              pi_user_type TYPE  vlfkz.

  DATA: lt_buffer_wrsz       TYPE TABLE OF wrsz,
        l_last_locnr         TYPE locnr,
        l_last_kunnr         TYPE kunnr,
        l_tabix              TYPE sy-tabix.

  FIELD-SYMBOLS: <fs_wrsz> TYPE wrsz.

* Fill a local buffer for all locations
  IF pi_user_type IS NOT INITIAL.
    SELECT *  FROM wrsz INTO TABLE lt_buffer_wrsz
       WHERE locnr IN pirt_locnr
       ORDER BY locnr kunnr. "#EC CI_BYPASS
  ELSE.
    SELECT *  FROM wrsz INTO TABLE lt_buffer_wrsz
       WHERE kunnr IN pirt_locnr
       ORDER BY locnr kunnr. "#EC CI_BYPASS
  ENDIF.

  IF buffer_wrsz_locnr IS INITIAL.
* If the global buffer contains no entries, copy the local buffer completely
    buffer_wrsz_locnr = lt_buffer_wrsz.
  ELSE.
* If the global buffer contains entries, ensure the sort order by adding the
* new entries at the right position.
    LOOP AT lt_buffer_wrsz ASSIGNING <fs_wrsz>.
      IF l_last_locnr <> <fs_wrsz>-locnr OR
         l_last_kunnr <> <fs_wrsz>-kunnr.
* next block, determine start index.
        READ TABLE buffer_wrsz_locnr
             WITH KEY locnr = <fs_wrsz>-locnr
                      kunnr = <fs_wrsz>-kunnr
             BINARY SEARCH
             TRANSPORTING NO FIELDS.
* subrc should always be 4 here, checked before if the location is part of the buffer
        l_tabix = sy-tabix.
      ELSE.
        l_tabix = l_tabix + 1.
      ENDIF.

* insert new entry at the right position
      INSERT <fs_wrsz> INTO buffer_wrsz_locnr INDEX l_tabix.
      l_last_locnr = <fs_wrsz>-locnr.
      l_last_kunnr = <fs_wrsz>-kunnr.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " FILL_WRSZ_BUFFER
