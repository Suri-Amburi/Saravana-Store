*&---------------------------------------------------------------------*
*& Include          ZMM_MAS_CAT_SAL_SEL_L
*&---------------------------------------------------------------------*
SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001 .

SELECT-OPTIONS : s_matkl FOR lv_matkl ,
                 S_PLANT FOR LV_PLANT NO INTERVALS no-EXTENSION,
                 s_size  FOR gv_size  NO INTERVALS NO-EXTENSION,
                 s_from  FOR gv_zzprice_frm NO INTERVALS NO-EXTENSION.

SELECTION-SCREEN : END OF BLOCK b1 .
*if s_matkl is NOT INITIAL.
*BREAK CLIKHITHA..
CHECK S_PLANT[] IS NOT INITIAL.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_size-low.
*endif.
*  if s_matkl is NOT INITIAL.
  DATA : return TYPE TABLE OF ddshretval.
  CHECK s_matkl[] IS NOT INITIAL.
  s_matkl = s_matkl[ 1 ].
*BREAK CLIKHITHA.
  SELECT size1 FROM mara INTO TABLE @DATA(lt_size) WHERE matkl = @s_matkl-low.
  SORT lt_size AS TEXT BY size1.
  DELETE ADJACENT DUPLICATES FROM lt_size COMPARING size1.
*BREAK CLIKHITHA.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE         = ' '
      RETFIELD               = 'SIZE1'
*     PVALKEY                = ' '
 DYNPROFIELD                 = 'S_SIZE'
     DYNPPROG                = sy-repid
     DYNPNR                  = sy-dynnr
*     DYNPROFIELD            = 'S_SIZE'
*     STEPL                  = 0
*     WINDOW_TITLE           =
*     VALUE                  = ' '
*     VALUE_ORG              = 'S'
     MULTIPLE_CHOICE         = 'X'
     VALUE_ORG               = 'S'
*     DISPLAY                = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM          = ' '
*     CALLBACK_METHOD        =
*     MARK_TAB               =
*   IMPORTING
*     USER_RESET             =
    TABLES
      VALUE_TAB              = lt_size
*     FIELD_TAB              =
     RETURN_TAB             = return.
*     DYNPFLD_MAPPING        =
*   EXCEPTIONS
*     PARAMETER_ERROR        = 1
*     NO_VALUES_FOUND        = 2
*     OTHERS                 = 3
            .
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.
  CLEAR s_size. REFRESH : s_size[] , r_size.
  LOOP AT return ASSIGNING FIELD-SYMBOL(<ls_return>).
    s_size-sign = 'I'.
    s_size-option = 'EQ'.
    s_size-low = <ls_return>-fieldval.
    append s_size to s_size[].
    APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_return>-fieldval ) TO r_size[].
  ENDLOOP.
*  endif.
*BREAK CLIKHITHA.
  AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_from-low.
*    if s_matkl is NOT INITIAL.
  DATA : return TYPE TABLE OF ddshretval.
*  CHECK s_size[] IS NOT INITIAL.
*  BREAK CLIKHITHA.
  SELECT  zzprice_frm , zzprice_to FROM mara INTO TABLE @DATA(lt_price) WHERE matkl = @s_matkl-low AND size1 IN @s_size[].
  SORT lt_price BY zzprice_frm zzprice_to.
  DELETE ADJACENT DUPLICATES FROM lt_price COMPARING zzprice_frm zzprice_to.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE         = ' '
      RETFIELD               = 'SIZE1'
*     PVALKEY                = ' '
     DYNPROFIELD            = 'S_FROM'
     DYNPPROG               = sy-repid
     DYNPNR                 = sy-dynnr
*     DYNPROFIELD            = 'S_FROM'
*     STEPL                  = 0
*     WINDOW_TITLE           =
*     VALUE                  = ' '
*     VALUE_ORG              = 'S'
     MULTIPLE_CHOICE        = 'X'
     VALUE_ORG              = 'S'
*     DISPLAY                = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM          = ' '
*     CALLBACK_METHOD        =
*     MARK_TAB               =
*   IMPORTING
*     USER_RESET             =
    TABLES
      VALUE_TAB              = lt_price
*     FIELD_TAB              =
     RETURN_TAB             = return.
*     DYNPFLD_MAPPING        =
*   EXCEPTIONS
*     PARAMETER_ERROR        = 1
*     NO_VALUES_FOUND        = 2
*     OTHERS                 = 3
            .
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.
  CLEAR s_from. REFRESH :s_from[] , r_to[].
*BREAK CLIKHITHA.
  LOOP AT return ASSIGNING FIELD-SYMBOL(<ls_return>).
    REPLACE ALL OCCURRENCES OF ',' IN <ls_return>-fieldval WITH ''.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_return>-fieldval ) TO r_to[].
  ENDLOOP.

  DELETE lt_price WHERE zzprice_to NOT IN r_to.
  LOOP AT lt_price ASSIGNING FIELD-SYMBOL(<ls_price>).
    IF SY-SUBRC = 0.
    REPLACE ALL OCCURRENCES OF ',' IN <ls_return>-fieldval WITH ''.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_price>-zzprice_frm ) TO r_from[].
    s_from-sign = 'I'.
    s_from-option = 'EQ'.
    s_from-low = <ls_price>-zzprice_frm.
    append s_from to s_from[].
    ENDIF.
  ENDLOOP.

*AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name = '%_S_SIZE_%_APP_%-VALU_PUSH' OR screen-name = '%_S_FROM_%_APP_%-VALU_PUSH'.
*      screen-invisible = '1'.
*      MODIFY SCREEN.
    ENDIF.
    ENDLOOP.
*endif.
**    LOOP AT SCREEN.
*    IF screen-name = '%_S_FROM_%_APP_%-VALU_PUSH' ."OR screen-name = '%_S_FROM_%_APP_%-VALU_PUSH'.
**      screen-invisible = '1'.
**      MODIFY SCREEN.
*    ENDIF.
*    ENDLOOP.
