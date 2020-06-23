*&---------------------------------------------------------------------*
*& Include          ZMM_MAS_CAT_SAL_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data.

  SELECT
    mara~matnr,
    mara~matkl,
    mbew~bwkey,
    mbew~bwtar,
    mbew~lbkum,
    mbew~salk3,
    t023t~spras,
    t023t~wgbez
    INTO TABLE @DATA(gt_data1)
    FROM mbew AS mbew
    INNER JOIN mara AS mara ON mbew~matnr = mara~matnr
    INNER JOIN t023t AS t023t ON mara~matkl = t023t~matkl
    WHERE mara~matkl IN @s_matkl
    AND mbew~bwkey IN ('SSCP' , 'SSPO' , 'SSPU' , 'SSTN' , 'SSWH' , 'SSVG' )
    AND mbew~lbkum <> '0'
    AND mbew~bwtar = ' ' .
*
*  DATA(lv_select) = cl_shdb_seltab=>combine_seltabs(
* it_named_seltabs = VALUE #( ( name = 'MATKL' dref = REF #( s_matkl[] ) )
*                             )
*
*                             iv_client_field = 'MANDT'
*                              ) .
*
*  zmcstock=>get_output_prd(
*  EXPORTING
*  lv_select     = lv_select
*  IMPORTING
*  et_final_data = gt_data1
*  ).


******  BREAK BREDDY .
*******  IF S_PLANT IS NOT INITIAL AND S_MATKL IS NOT INITIAL.
******  IF S_MATKL IS NOT INITIAL .
******    SELECT
******     MARA~MATNR ,
******     MARA~MATKL ,
*******       MARD~WERKS ,
******     MBEW~BWKEY ,
******     MBEW~LBKUM ,
******     MBEW~SALK3  INTO TABLE @GT_DATA
******     FROM MARA AS MARA
*******    INNER JOIN MARD AS MARD ON MARA~MATNR = MARD~MATNR
******     INNER JOIN MBEW AS MBEW ON MARA~MATNR = MBEW~MATNR
*******      FOR ALL ENTRIES IN @IT_MARA
******     WHERE MARA~MATKL IN @S_MATKL
*******  AND  MBEW~BWKEY LIKE  'S%'        ""('SSCP' , 'SSPO' , 'SSPU' , 'SSTN' , 'SSWH' )
******      AND MBEW~BWKEY IN ('SSCP' , 'SSPO' , 'SSPU' , 'SSTN' , 'SSWH' )
*******     AND MBEW~BWKEY IN @S_PLANT
******    AND MBEW~LBKUM <> '0'
******    AND BWTAR = ' ' .
******
******  ELSE .
******    SELECT
******    MARA~MATNR ,
******    MARA~MATKL ,
*******       MARD~WERKS ,
******    MBEW~BWKEY ,
******    MBEW~LBKUM ,
******    MBEW~SALK3  INTO TABLE @GT_DATA
******    FROM MARA AS MARA
*******    INNER JOIN MARD AS MARD ON MARA~MATNR = MARD~MATNR
******    INNER JOIN MBEW AS MBEW ON MARA~MATNR = MBEW~MATNR
*******      FOR ALL ENTRIES IN @IT_MARA
*******   WHERE MARA~MATKL IN @S_MATKL
*******  AND  MBEW~BWKEY LIKE  'S%'        ""('SSCP' , 'SSPO' , 'SSPU' , 'SSTN' , 'SSWH' )
******    WHERE MBEW~BWKEY IN ('SSCP' , 'SSPO' , 'SSPU' , 'SSTN' , 'SSWH' )
*******     AND MBEW~BWKEY IN @S_PLANT
******    AND MBEW~LBKUM <> '0'
******    AND BWTAR = ' ' .
******  ENDIF .
******
******
******  IF gt_data IS NOT INITIAL.
******    SELECT
******      t023t~matkl ,
******      t023t~wgbez  FROM t023t INTO TABLE @DATA(it_t023t)
******                   FOR ALL ENTRIES IN @gt_data
******                   WHERE matkl = @gt_data-matkl .
******  ENDIF.


  DATA : lv_amt TYPE salk3 .
*  DATA(GT_DATA1) = GT_DATA[] .
  SORT gt_data1 BY matkl bwkey.
**  SORT it_t023t BY matkl.
**  DELETE ADJACENT DUPLICATES FROM it_t023t COMPARING matkl.
  BREAK ppadhy.

  LOOP AT gt_data1  ASSIGNING FIELD-SYMBOL(<gs_data>) . ""WHERE MATKL = <GS_DATA1>-MATKL AND BWKEY = <GS_DATA1>-BWKEY.
    wa_final-matkl = <gs_data>-matkl .
    wa_final-bwkey = <gs_data>-bwkey .
    wa_final-wgbez = <gs_data>-wgbez .

    IF <gs_data>-bwkey = 'SSTN'.

      wa_final-lbkum1 = <gs_data>-lbkum +  wa_final-lbkum1 .
      wa_final-salk1 = <gs_data>-salk3 +  wa_final-salk1 .
*          MODIFY IT_FINAL FROM wa_final TRANSPORTING LBKUM1 SALK1 where LIFNR = <LS_DATA>-LIFNR  .

    ELSEIF <gs_data>-bwkey = 'SSPU' .

      wa_final-lbkum2 = <gs_data>-lbkum +  wa_final-lbkum2 .
      wa_final-salk2 = <gs_data>-salk3 +  wa_final-salk2 .
*        MODIFY IT_FINAL FROM <RS_FINAL> TRANSPORTING LBKUM2 SALK2   WHERE LIFNR = <LS_DATA>-LIFNR.
    ELSEIF <gs_data>-bwkey = 'SSCP' .

      wa_final-lbkum3 = <gs_data>-lbkum +  wa_final-lbkum3 .
      wa_final-salk3 = <gs_data>-salk3 +  wa_final-salk3 .
*        MODIFY IT_FINAL FROM <RS_FINAL> TRANSPORTING LBKUM3 SALK3  WHERE LIFNR = <LS_DATA>-LIFNR .

    ELSEIF <gs_data>-bwkey = 'SSPO' .

      wa_final-lbkum4 = <gs_data>-lbkum +  wa_final-lbkum4 .
      wa_final-salk4 = <gs_data>-salk3 +  wa_final-salk4 .
*        MODIFY IT_FINAL FROM <RS_FINAL> TRANSPORTING LBKUM4 SALK4  WHERE LIFNR = <LS_DATA>-LIFNR .
    ELSEIF <gs_data>-bwkey = 'SSWH' .

      wa_final-lbkum5 = <gs_data>-lbkum +  wa_final-lbkum5 .
      wa_final-salk5 = <gs_data>-salk3 +  wa_final-salk5 .
*        MODIFY IT_FINAL FROM <RS_FINAL> TRANSPORTING LBKUM5 SALK5  WHERE LIFNR = <LS_DATA>-LIFNR .
    ELSEIF <gs_data>-bwkey = 'SSVG' .
      wa_final-lbkum6 = <gs_data>-lbkum +  wa_final-lbkum6.
      wa_final-salk6 = <gs_data>-salk3 +  wa_final-salk6.
    ENDIF .
    READ TABLE it_final ASSIGNING FIELD-SYMBOL(<rs_final>) WITH KEY matkl  = <gs_data>-matkl  .
    IF sy-subrc = 0 .
      wa_final-cumq = wa_final-lbkum1 + wa_final-lbkum2 + wa_final-lbkum3 + wa_final-lbkum4 + wa_final-lbkum5 + wa_final-lbkum6.
      wa_final-cumv = wa_final-salk1 +  wa_final-salk2 + wa_final-salk3 + wa_final-salk4 + wa_final-salk5 + wa_final-salk6.
      MODIFY it_final FROM wa_final TRANSPORTING lbkum1 salk1 lbkum2 salk2 lbkum3 salk3 lbkum4 salk4 lbkum5 salk5 cumv cumq WHERE matkl  = <gs_data>-matkl  .
    ELSE .
      APPEND wa_final TO it_final .
      CLEAR : wa_final .
    ENDIF .
  ENDLOOP.

******  LOOP AT gt_data  ASSIGNING FIELD-SYMBOL(<gs_data>) . ""WHERE MATKL = <GS_DATA1>-MATKL AND BWKEY = <GS_DATA1>-BWKEY.
******    wa_final-matkl = <gs_data>-matkl .
******    wa_final-bwkey = <gs_data>-bwkey .
******    READ TABLE it_t023t ASSIGNING FIELD-SYMBOL(<ls_t023t>) WITH KEY matkl = <gs_data>-matkl .
******    IF sy-subrc = 0.
******      wa_final-wgbez = <ls_t023t>-wgbez .
******
******    ENDIF.
******
******    IF <gs_data>-bwkey = 'SSTN'.
******
******
******      wa_final-lbkum1 = <gs_data>-lbkum +  wa_final-lbkum1 .
******      wa_final-salk1 = <gs_data>-salk3 +  wa_final-salk1 .
*******          MODIFY IT_FINAL FROM wa_final TRANSPORTING LBKUM1 SALK1 where LIFNR = <LS_DATA>-LIFNR  .
******
******    ELSEIF <gs_data>-bwkey = 'SSCP' .
******
******      wa_final-lbkum2 = <gs_data>-lbkum +  wa_final-lbkum2 .
******      wa_final-salk2 = <gs_data>-salk3 +  wa_final-salk2 .
*******        MODIFY IT_FINAL FROM <RS_FINAL> TRANSPORTING LBKUM2 SALK2   WHERE LIFNR = <LS_DATA>-LIFNR.
******    ELSEIF <gs_data>-bwkey = 'SSWH' .
******
******      wa_final-lbkum3 = <gs_data>-lbkum +  wa_final-lbkum3 .
******      wa_final-salk3 = <gs_data>-salk3 +  wa_final-salk3 .
*******        MODIFY IT_FINAL FROM <RS_FINAL> TRANSPORTING LBKUM3 SALK3  WHERE LIFNR = <LS_DATA>-LIFNR .
******
******    ELSEIF <gs_data>-bwkey = 'SSPO' .
******
******      wa_final-lbkum4 = <gs_data>-lbkum +  wa_final-lbkum4 .
******      wa_final-salk4 = <gs_data>-salk3 +  wa_final-salk4 .
*******        MODIFY IT_FINAL FROM <RS_FINAL> TRANSPORTING LBKUM4 SALK4  WHERE LIFNR = <LS_DATA>-LIFNR .
******    ELSEIF <gs_data>-bwkey = 'SSPU' .
******
******      wa_final-lbkum5 = <gs_data>-lbkum +  wa_final-lbkum5 .
******      wa_final-salk5 = <gs_data>-salk3 +  wa_final-salk5 .
*******        MODIFY IT_FINAL FROM <RS_FINAL> TRANSPORTING LBKUM5 SALK5  WHERE LIFNR = <LS_DATA>-LIFNR .
******    ENDIF .
******    READ TABLE it_final ASSIGNING FIELD-SYMBOL(<rs_final>) WITH KEY matkl  = <gs_data>-matkl  .
******    IF sy-subrc = 0 .
******      wa_final-cumq = wa_final-lbkum1 + wa_final-lbkum2 + wa_final-lbkum3 + wa_final-lbkum4 + wa_final-lbkum5 .
******      wa_final-cumv = wa_final-salk1 +  wa_final-salk2 + wa_final-salk3 + wa_final-salk4 + wa_final-salk5 .
******      MODIFY it_final FROM wa_final TRANSPORTING lbkum1 salk1 lbkum2 salk2 lbkum3 salk3 lbkum4 salk4 lbkum5 salk5 cumv cumq WHERE matkl  = <gs_data>-matkl  .
******    ELSE .
******
******      APPEND wa_final TO it_final .
******      CLEAR : wa_final .
******    ENDIF .
******  ENDLOOP.

  wa_fcat-col_pos  = 01.
  wa_fcat-fieldname = 'MATKL'.
  wa_fcat-seltext_m = 'Category '.
  wa_fcat-tabname = 'IT_FINAL'.
  wa_fcat-outputlen   = 12.
  wa_fcat-just        = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos  = 02.
  wa_fcat-fieldname = 'WGBEZ'.
  wa_fcat-seltext_m = 'Description'.
  wa_fcat-tabname = 'IT_FINAL'.
  wa_fcat-outputlen   = 20.
  wa_fcat-just        = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.


  wa_fcat-col_pos  = 03.
  wa_fcat-fieldname = 'LBKUM1'.
  wa_fcat-seltext_m = 'Quantity'.
  wa_fcat-tabname = 'IT_FINAL'.
*  WA_FCAT-DO_SUM  = 'X' .
  wa_fcat-outputlen   = 15.
  wa_fcat-just        = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos  = 04.
  wa_fcat-fieldname = 'SALK1'.
  wa_fcat-seltext_m = 'Value'.
  wa_fcat-tabname = 'IT_FINAL'.
*  WA_FCAT-DO_SUM  = 'X' .
  wa_fcat-outputlen  = 15.
  wa_fcat-just   = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos  = 05.
  wa_fcat-fieldname = 'LBKUM2'.
  wa_fcat-seltext_m = 'Quantity'.
  wa_fcat-tabname = 'IT_FINAL'.
*  WA_FCAT-DO_SUM  = 'X' .
  wa_fcat-outputlen   = 15.
  wa_fcat-just        = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos  = 06.
  wa_fcat-fieldname = 'SALK2'.
  wa_fcat-seltext_m = 'Value'.
  wa_fcat-tabname = 'IT_FINAL'.
*  WA_FCAT-DO_SUM  = 'X' .
  wa_fcat-outputlen  = 15.
  wa_fcat-just   = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos  = 07.
  wa_fcat-fieldname = 'LBKUM3'.
  wa_fcat-seltext_m = 'Quantity'.
  wa_fcat-tabname = 'IT_FINAL'.
*  WA_FCAT-DO_SUM  = 'X' .
  wa_fcat-outputlen   = 15.
  wa_fcat-just        = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos  = 08.
  wa_fcat-fieldname = 'SALK3'.
  wa_fcat-seltext_m = 'Value'.
  wa_fcat-tabname = 'IT_FINAL'.
*  WA_FCAT-DO_SUM  = 'X' .
  wa_fcat-outputlen  = 15.
  wa_fcat-just   = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos  = 09.
  wa_fcat-fieldname = 'LBKUM4'.
  wa_fcat-seltext_m = 'Quantity'.
  wa_fcat-tabname = 'IT_FINAL'.
*  WA_FCAT-DO_SUM  = 'X' .
  wa_fcat-outputlen   = 15.
  wa_fcat-just        = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos  = 10.
  wa_fcat-fieldname = 'SALK4'.
  wa_fcat-seltext_m = 'Value'.
  wa_fcat-tabname = 'IT_FINAL'.
*  WA_FCAT-DO_SUM  = 'X' .
  wa_fcat-outputlen  = 15.
  wa_fcat-just   = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos  = 11.
  wa_fcat-fieldname = 'LBKUM5'.
  wa_fcat-seltext_m = 'Quantity'.
  wa_fcat-tabname = 'IT_FINAL'.
*  WA_FCAT-DO_SUM  = 'X' .
  wa_fcat-outputlen   = 15.
  wa_fcat-just        = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos  = 12.
  wa_fcat-fieldname = 'SALK5'.
  wa_fcat-seltext_m = 'Value'.
  wa_fcat-tabname = 'IT_FINAL'.
*  WA_FCAT-DO_SUM  = 'X' .
  wa_fcat-outputlen  = 15.
  wa_fcat-just   = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.


  wa_fcat-col_pos  = 13.
  wa_fcat-fieldname = 'LBKUM6'.
  wa_fcat-seltext_m = 'Quantity'.
  wa_fcat-tabname = 'IT_FINAL'.
*  WA_FCAT-DO_SUM  = 'X' .
  wa_fcat-outputlen   = 15.
  wa_fcat-just        = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos  = 14.
  wa_fcat-fieldname = 'SALK6'.
  wa_fcat-seltext_m = 'Value'.
  wa_fcat-tabname = 'IT_FINAL'.
*  WA_FCAT-DO_SUM  = 'X' .
  wa_fcat-outputlen  = 15.
  wa_fcat-just   = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos  = 15.
  wa_fcat-fieldname = 'CUMQ'.
  wa_fcat-seltext_m = 'Quantity'.
  wa_fcat-tabname = 'IT_FINAL'.
*  WA_FCAT-DO_SUM  = 'X' .
  wa_fcat-outputlen   = 15.
  wa_fcat-just        = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos  = 16.
  wa_fcat-fieldname = 'CUMV'.
  wa_fcat-seltext_m = 'Value'.
  wa_fcat-tabname = 'IT_FINAL'.
*  WA_FCAT-DO_SUM  = 'X' .
  wa_fcat-outputlen  = 15.
  wa_fcat-just   = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.


  wa_events-name = slis_ev_top_of_page .
  wa_events-form = 'TOP_PAGE'.
  wa_events-form = 'TOP_OF_PAGE'.
  APPEND wa_events TO it_events.
  CLEAR wa_events.


  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
***      IS_LAYOUT          = WA_LAYOUT
      it_fieldcat        = it_fcat[]
      it_events          = it_events
      i_default          = 'X'
      i_save             = 'U'
    TABLES
      t_outtab           = it_final
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
FORM top_of_page .

  DATA: it_o_wgh01 TYPE TABLE OF wgh01,
        wa_o_wgh01 TYPE wgh01.
  DATA : lv_top(40) TYPE c .
*  IF CATEGORY IS NOT INITIAL AND GROUP-LOW IS NOT INITIAL .
  IF s_matkl-low IS NOT INITIAL .
    WRITE : / sy-uline.
    WRITE : sy-vline , (20) 'Category Code :' LEFT-JUSTIFIED,(12)s_matkl-low LEFT-JUSTIFIED.
    WRITE :/(242) sy-vline .
*  WRITE : / .

*    WRITE : / SY-ULINE.
*    WRITE : SY-VLINE , (15)'Category Code :' LEFT-JUSTIFIED,(25)GROUP-LOW LEFT-JUSTIFIED.
******       SY-VLINE, (10) 'Plant'   CENTERED,
******       SY-VLINE, (15) 'Plant1'  CENTERED,
******       SY-VLINE, (30) 'Plant2'  LEFT-JUSTIFIED,SY-VLINE.
*SY-VLINE.
*  ELSEIF CATEGORY IS NOT INITIAL AND GROUP-LOW IS INITIAL.

*    WRITE : / SY-ULINE.
*    WRITE : SY-VLINE , (08) 'Group :' LEFT-JUSTIFIED,(12)CATEGORY LEFT-JUSTIFIED.
*    WRITE :/(242) SY-VLINE .

*  ELSEIF CATEGORY IS   INITIAL .

*    CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
*      EXPORTING
*        MATKL       = S_MATKL
*        SPRAS       = SY-LANGU
*      TABLES
*        O_WGH01     = IT_O_WGH01
*      EXCEPTIONS
*        NO_BASIS_MG = 1
*        NO_MG_HIER  = 2
*        OTHERS      = 3.
*    IF SY-SUBRC <> 0.
** Implement suitable error handling here
*    ENDIF.

    BREAK breddy .
    CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
      EXPORTING
        matkl       = s_matkl-low
        spras       = sy-langu
      TABLES
        o_wgh01     = it_o_wgh01
      EXCEPTIONS
        no_basis_mg = 1
        no_mg_hier  = 2
        OTHERS      = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE it_o_wgh01 INTO wa_o_wgh01 INDEX 1.
    IF sy-subrc = 0.
      lv_top =  wa_o_wgh01-wwgha .
    ENDIF.

    WRITE : / sy-uline.
    WRITE : sy-vline , (08) 'Group :' LEFT-JUSTIFIED,(12)lv_top LEFT-JUSTIFIED.
    WRITE :/(242) sy-vline .
  ENDIF .

  WRITE: / sy-uline.
***  Start of Chnages by Suri : 02.04.2020 : 12.51
*  WRITE: / sy-vline ,(18) 'CATEGORY CODE' CENTERED , sy-vline ,(18) 'DESCRIPTION' ,sy-vline ,(39) 'SSTN' CENTERED,  sy-vline ,
*  (39) 'SSCP' CENTERED , sy-vline, (39) 'SSWH' CENTERED, sy-vline , (39) 'SSPO' CENTERED ,
*   sy-vline , (39) 'SSPU' CENTERED , sy-vline , (39) 'CUMMULATIVE' CENTERED , sy-vline .

  WRITE: / sy-vline ,(10) 'CATEGORY' CENTERED , sy-vline ,(18) 'DESCRIPTION' CENTERED ,sy-vline ,(29) 'SSTN' CENTERED,  sy-vline ,
 (29) 'SSPU' CENTERED , sy-vline, (29) 'SSCP' CENTERED, sy-vline , (29) 'SSPO' CENTERED ,
  sy-vline , (29) 'SSWH' CENTERED , sy-vline , (29) 'SSVG' CENTERED , sy-vline , (29) 'CUMMULATIVE' CENTERED , sy-vline .

***  End of Chnages by Suri : 02.04.2020 : 12.51
ENDFORM .
