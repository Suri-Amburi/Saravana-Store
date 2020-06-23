*&---------------------------------------------------------------------*
*& Include          ZMM_SEARCH_SEL
*&---------------------------------------------------------------------*

TABLES : mara .
SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001 .

SELECT-OPTIONS : s_plant FOR gv_plant NO INTERVALS OBLIGATORY,
                 s_matkl FOR gv_matkl NO INTERVALS NO-EXTENSION OBLIGATORY,
                 s_size  FOR gv_size  NO INTERVALS,                      " Suri : 31.03.2020
                 s_from  FOR gv_zzprice_frm NO INTERVALS.
*                 s_to  FOR mara-zzprice_to NO INTERVALS NO-EXTENSION.
SELECTION-SCREEN : END OF BLOCK b1 .

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_size-low.

  DATA : return TYPE TABLE OF ddshretval.
  CHECK s_matkl[] IS NOT INITIAL.
  s_matkl = s_matkl[ 1 ].
  SELECT size1 FROM mara INTO TABLE @DATA(lt_size) WHERE matkl = @s_matkl-low.
  SORT lt_size AS TEXT BY size1.
  DELETE ADJACENT DUPLICATES FROM lt_size COMPARING size1.
  break samburi.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'SIZE1'
      dynprofield     = 'S_SIZE'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      multiple_choice = 'X'
      value_org       = 'S'
    TABLES
      value_tab       = lt_size
      return_tab      = return.

  CLEAR s_size. REFRESH : s_size[] , r_size.
  LOOP AT return ASSIGNING FIELD-SYMBOL(<ls_return>).
    s_size-sign = 'I'.
    s_size-option = 'EQ'.
    s_size-low = <ls_return>-fieldval.
    append s_size to s_size[].
    APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_return>-fieldval ) TO r_size[].
  ENDLOOP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_from-low.
  DATA : return TYPE TABLE OF ddshretval.
  CHECK s_size[] IS NOT INITIAL.
  SELECT  zzprice_frm , zzprice_to FROM mara INTO TABLE @DATA(lt_price) WHERE matkl = @s_matkl-low AND size1 IN @s_size[].
  SORT lt_price BY zzprice_frm zzprice_to.
  DELETE ADJACENT DUPLICATES FROM lt_price COMPARING zzprice_frm zzprice_to.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'SIZE1'
      dynprofield     = 'S_FROM'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      multiple_choice = 'X'
      value_org       = 'S'
    TABLES
      value_tab       = lt_price
      return_tab      = return.

  CLEAR s_from. REFRESH :s_from[] , r_to[].
  BREAK samburi.
  LOOP AT return ASSIGNING FIELD-SYMBOL(<ls_return>).
    REPLACE ALL OCCURRENCES OF ',' IN <ls_return>-fieldval WITH ''.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_return>-fieldval ) TO r_to[].
  ENDLOOP.

  DELETE lt_price WHERE zzprice_to NOT IN r_to.
  LOOP AT lt_price ASSIGNING FIELD-SYMBOL(<ls_price>).
    REPLACE ALL OCCURRENCES OF ',' IN <ls_return>-fieldval WITH ''.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_price>-zzprice_frm ) TO r_from[].
    s_from-sign = 'I'.
    s_from-option = 'EQ'.
    s_from-low = <ls_price>-zzprice_frm.
    append s_from to s_from[].
  ENDLOOP.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name = '%_S_SIZE_%_APP_%-VALU_PUSH' OR screen-name = '%_S_FROM_%_APP_%-VALU_PUSH'.
      screen-invisible = '1'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
