*&---------------------------------------------------------------------*
*& Include          ZMM_MAS_CAT_SAL_FORM_L
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
  BREAK CLIKHITHA.
*if s_matkl is NOT INITIAL.
*  s_from[] = r_from[].
*  s_size[] = r_size[].
*****  SELECT
*****    MARA~MATNR,
*****    MARA~MATKL,
*****    mara~zzprice_frm,
*****    mara~zzprice_to,
*****    mara~size1,
*****    MBEW~BWKEY,
*****    MBEW~BWTAR,
*****    MBEW~LBKUM,
*****    MBEW~SALK3,
*****    T023T~SPRAS,
*****    T023T~WGBEZ
*****    INTO TABLE @DATA(GT_DATA1)
*****    FROM MBEW AS MBEW
*****    INNER JOIN MARA AS MARA ON MBEW~MATNR = MARA~MATNR
*****    INNER JOIN T023T AS T023T ON MARA~MATKL = T023T~MATKL
*****    WHERE MARA~MATKL IN @S_MATKL
***************    ADDED ON(4-4-20)
*****    AND   zzprice_frm IN @s_from
*****   AND   zzprice_to   IN @r_to
*****   AND   size1 IN @s_size
******************    END(4-4-20))
*****    AND MBEW~BWKEY IN @S_PLANT   " added on (3-4-20)
******    AND mbew~bwkey IN ('SSCP' , 'SSPO' , 'SSPU' , 'SSTN' , 'SSWH' , 'SSVG' )          " commented on (3-4-20)
*****    AND MBEW~LBKUM <> '0'
*****    AND MBEW~BWTAR = ' ' .

*else.
  SELECT
    MARA~MATNR,
    MARA~MATKL,
    mara~zzprice_frm,
    mara~zzprice_to,
    mara~size1,
    MBEW~BWKEY,
    MBEW~BWTAR,
    MBEW~LBKUM,
    MBEW~SALK3,
    T023T~SPRAS,
    T023T~WGBEZ
    INTO TABLE @DATA(GT_DATA1)
    FROM MBEW AS MBEW
    INNER JOIN MARA AS MARA ON MBEW~MATNR = MARA~MATNR
    INNER JOIN T023T AS T023T ON MARA~MATKL = T023T~MATKL
    WHERE MARA~MATKL IN @S_MATKL
**********    ADDED ON(4-4-20)
    AND   zzprice_frm IN @s_from
   AND   zzprice_to   IN @r_to
   AND   size1 IN @s_size
*************    END(4-4-20))
    AND MBEW~BWKEY IN @S_PLANT   " added on (3-4-20)
*    AND mbew~bwkey IN ('SSCP' , 'SSPO' , 'SSPU' , 'SSTN' , 'SSWH' , 'SSVG' )          " commented on (3-4-20)
    AND MBEW~LBKUM <> '0'
    AND MBEW~BWTAR = ' ' .
*    endif..
*    **************************************************************************************************************






  DATA : LV_AMT TYPE SALK3 .
*  DATA(GT_DATA1) = GT_DATA[] .
  SORT GT_DATA1 BY MATKL BWKEY.
*  SORT GT_DATA2 BY MATKL BWKEY.
IF S_PLANT IS NOT INITIAL.
    SELECT WERKS
           ADRNR
           NAME1
    FROM  T001W
    INTO TABLE IT_T001W
    WHERE WERKS IN S_PLANT."('SSCP' ,'SSPO','SSPU','SSTN','SSWH' ,'SSVG').
      READ TABLE IT_T001W INTO WA_T001W INDEX 1.
    wa_hdr-werks = wa_t001w-name1.
  ENDIF.
*      ELSE.

  IF S_PLANT  IS INITIAL.
    SELECT WERKS
          ADRNR
          NAME1
   FROM  T001W
   INTO TABLE IT_T001W
   WHERE WERKS IN ('SSCP' ,'SSPO','SSPU','SSTN','SSWH' ,'SSVG').
  ELSE.
    SELECT WERKS
          ADRNR
          NAME1
   FROM  T001W
   INTO TABLE IT_T001W
   WHERE WERKS IN S_PLANT .
  ENDIF.
SELECT A~ADDRNUMBER
           A~NAME1
           A~NAME2
           A~STREET
           A~STR_SUPPL1
           A~CITY1
           A~POST_CODE1
           B~BEZEI
    FROM   ADRC AS A
    INNER JOIN T005U AS B ON ( A~REGION = B~BLAND AND B~SPRAS = SY-LANGU AND A~COUNTRY = B~LAND1 )
    INTO TABLE IT_ADRC
    FOR ALL ENTRIES IN IT_T001W
    WHERE ADDRNUMBER = IT_T001W-ADRNR .

*  ****************************************************( 4-4-20)
if s_plant is INITIAL.
   LOOP AT gt_data1  ASSIGNING FIELD-SYMBOL(<gs_data>) . ""WHERE MATKL = <GS_DATA1>-MATKL AND BWKEY = <GS_DATA1>-BWKEY.
    wa_final-matNR = <gs_data>-matNR .
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
      APPEND wa_final TO it_final .
      CLEAR : wa_final .
*    ENDIF .
  ENDLOOP.


  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZMCSTOCK_FORM'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      FM_NAME            = F_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
**break clikhitha.
CALL FUNCTION F_NAME"'/1BCDWB/SF00000079'
* EXPORTING
*   ARCHIVE_INDEX              =
*   ARCHIVE_INDEX_TAB          =
*   ARCHIVE_PARAMETERS         =
*   CONTROL_PARAMETERS         =
*   MAIL_APPL_OBJ              =
*   MAIL_RECIPIENT             =
*   MAIL_SENDER                =
*   OUTPUT_OPTIONS             =
*   USER_SETTINGS              = 'X'
*wa_hdr      = wa_hdr
* IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
  TABLES
    IT_ITEM                    = IT_FINAL
 EXCEPTIONS
   FORMATTING_ERROR           = 1
   INTERNAL_ERROR             = 2
   SEND_ERROR                 = 3
   USER_CANCELED              = 4
   OTHERS                     = 5
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.


else.


*************************************************************************************************************************
LOOP AT gt_data1  ASSIGNING FIELD-SYMBOL(<gs_data2>) . ""WHERE MATKL = <GS_DATA1>-MATKL AND BWKEY = <GS_DATA1>-BWKEY.
    wa_final2-matNR = <gs_data2>-matNR .
    wa_final2-matkl = <gs_data2>-matkl .
    wa_final2-bwkey = <gs_data2>-bwkey .
    wa_final2-wgbez = <gs_data2>-wgbez .

    IF <gs_data2>-bwkey = 'SSTN'.

      wa_final2-lbkum1 = <gs_data2>-lbkum +  wa_final2-lbkum1 .
      wa_final2-salk1 = <gs_data2>-salk3 +  wa_final2-salk1 .
*          MODIFY IT_FINAL FROM wa_final TRANSPORTING LBKUM1 SALK1 where LIFNR = <LS_DATA>-LIFNR  .

    ELSEIF <gs_data2>-bwkey = 'SSPU' .

     wa_final2-lbkum1 = <gs_data2>-lbkum +  wa_final2-lbkum1 .
      wa_final2-salk1 = <gs_data2>-salk3 +  wa_final2-salk1 .
*        MODIFY IT_FINAL FROM <RS_FINAL> TRANSPORTING LBKUM2 SALK2   WHERE LIFNR = <LS_DATA>-LIFNR.
    ELSEIF <gs_data2>-bwkey = 'SSCP' .

    wa_final2-lbkum1 = <gs_data2>-lbkum +  wa_final2-lbkum1 .
      wa_final2-salk1 = <gs_data2>-salk3 +  wa_final2-salk1 .
*        MODIFY IT_FINAL FROM <RS_FINAL> TRANSPORTING LBKUM3 SALK3  WHERE LIFNR = <LS_DATA>-LIFNR .

    ELSEIF <gs_data2>-bwkey = 'SSPO' .

      wa_final2-lbkum1 = <gs_data2>-lbkum +  wa_final2-lbkum1 .
      wa_final2-salk1 = <gs_data2>-salk3 +  wa_final2-salk1 .
*        MODIFY IT_FINAL FROM <RS_FINAL> TRANSPORTING LBKUM4 SALK4  WHERE LIFNR = <LS_DATA>-LIFNR .
    ELSEIF <gs_data2>-bwkey = 'SSWH' .

      wa_final2-lbkum1 = <gs_data2>-lbkum +  wa_final2-lbkum1 .
      wa_final2-salk1 = <gs_data2>-salk3 +  wa_final2-salk1 .
*        MODIFY IT_FINAL FROM <RS_FINAL> TRANSPORTING LBKUM5 SALK5  WHERE LIFNR = <LS_DATA>-LIFNR .
    ELSEIF <gs_data2>-bwkey = 'SSVG' .
      wa_final2-lbkum1 = <gs_data2>-lbkum +  wa_final2-lbkum1 .
      wa_final2-salk1 = <gs_data2>-salk3 +  wa_final2-salk1 .
    ENDIF .

*    READ TABLE IT_T001W INTO WA_T001W WITH KEY WERKS = <gs_data2>-bwkey.
*    WA_FINAL2-WERKS = <gs_data2>-bwkey.

      APPEND wa_final2 TO it_final2 .
      CLEAR : wa_final2 .
*    ENDIF .
  ENDLOOP.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZMCSTOCK_PW'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      FM_NAME            = F_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
break clikhitha.
CALL FUNCTION F_NAME"'/1BCDWB/SF00000080'
 EXPORTING
*   ARCHIVE_INDEX              =
*   ARCHIVE_INDEX_TAB          =
*   ARCHIVE_PARAMETERS         =
*   CONTROL_PARAMETERS         =
*   MAIL_APPL_OBJ              =
*   MAIL_RECIPIENT             =
 wa_hdr     = wa_hdr
*   MAIL_SENDER                =
*   OUTPUT_OPTIONS             =
*   USER_SETTINGS              = 'X'
* IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
  TABLES
    IT_ITEM                    = IT_FINAL2
 EXCEPTIONS
   FORMATTING_ERROR           = 1
   INTERNAL_ERROR             = 2
   SEND_ERROR                 = 3
   USER_CANCELED              = 4
   OTHERS                     = 5
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.
*


ENDIF.
****************************  END(4-4-20)

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM DISPLAY_DATA .
*  if s_plant is INITIAL .
* CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*    EXPORTING
*      FORMNAME           = 'ZMCSTOCK_FORM'
**     VARIANT            = ' '
**     DIRECT_CALL        = ' '
*    IMPORTING
*      FM_NAME            = F_NAME
*    EXCEPTIONS
*      NO_FORM            = 1
*      NO_FUNCTION_MODULE = 2
*      OTHERS             = 3.
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.
**break clikhitha.
*CALL FUNCTION '/1BCDWB/SF00000079'
** EXPORTING
**   ARCHIVE_INDEX              =
**   ARCHIVE_INDEX_TAB          =
**   ARCHIVE_PARAMETERS         =
**   CONTROL_PARAMETERS         =
**   MAIL_APPL_OBJ              =
**   MAIL_RECIPIENT             =
**   MAIL_SENDER                =
**   OUTPUT_OPTIONS             =
**   USER_SETTINGS              = 'X'
**wa_hdr      = wa_hdr
** IMPORTING
**   DOCUMENT_OUTPUT_INFO       =
**   JOB_OUTPUT_INFO            =
**   JOB_OUTPUT_OPTIONS         =
*  TABLES
*    IT_ITEM                    = IT_FINAL
* EXCEPTIONS
*   FORMATTING_ERROR           = 1
*   INTERNAL_ERROR             = 2
*   SEND_ERROR                 = 3
*   USER_CANCELED              = 4
*   OTHERS                     = 5
*          .
*IF SY-SUBRC <> 0.
** Implement suitable error handling here
*ENDIF.
*else.
*   CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*    EXPORTING
*      FORMNAME           = 'ZMCSTOCK_PW'
**     VARIANT            = ' '
**     DIRECT_CALL        = ' '
*    IMPORTING
*      FM_NAME            = F_NAME
*    EXCEPTIONS
*      NO_FORM            = 1
*      NO_FUNCTION_MODULE = 2
*      OTHERS             = 3.
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.
**break clikhitha.
*CALL FUNCTION '/1BCDWB/SF00000080'
* EXPORTING
**   ARCHIVE_INDEX              =
**   ARCHIVE_INDEX_TAB          =
**   ARCHIVE_PARAMETERS         =
**   CONTROL_PARAMETERS         =
**   MAIL_APPL_OBJ              =
**   MAIL_RECIPIENT             =
* wa_hdr     = wa_hdr
**   MAIL_SENDER                =
**   OUTPUT_OPTIONS             =
**   USER_SETTINGS              = 'X'
** IMPORTING
**   DOCUMENT_OUTPUT_INFO       =
**   JOB_OUTPUT_INFO            =
**   JOB_OUTPUT_OPTIONS         =
*  TABLES
*    IT_ITEM                    = IT_FINAL2
* EXCEPTIONS
*   FORMATTING_ERROR           = 1
*   INTERNAL_ERROR             = 2
*   SEND_ERROR                 = 3
*   USER_CANCELED              = 4
*   OTHERS                     = 5
*          .
*IF SY-SUBRC <> 0.
** Implement suitable error handling here
*ENDIF.
*ENDIF.
*ENDFORM.
