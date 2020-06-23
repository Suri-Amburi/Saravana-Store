FUNCTION zre_stickering.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_MBLNR) TYPE  MBLNR
*"     REFERENCE(I_TP3_STICKER) TYPE  CHAR1
*"     REFERENCE(I_MJAHR) TYPE  MJAHR
*"     REFERENCE(I_CHARG) TYPE  CHARG_D OPTIONAL
*"     REFERENCE(I_PRINTS) TYPE  ZNO_PRINTS OPTIONAL
*"----------------------------------------------------------------------


  TYPES: BEGIN OF ty_final,
           mblnr        TYPE  matdoc-mblnr,
           zeile        TYPE  matdoc-zeile,
           mjahr        TYPE  matdoc-mjahr,
           parent_id    TYPE  matdoc-parent_id,
           menge        TYPE  matdoc-menge,
           charg        TYPE  matdoc-charg,
           budat        TYPE  matdoc-budat,
           shkzg        TYPE matdoc-shkzg,
           matnr        TYPE mara-matnr,
           zzlabel_desc TYPE mara-zzlabel_desc,
           matkl        TYPE mara-matkl,
           maktx        TYPE makt-maktx,
           price        TYPE konp-kbetr,
         END OF ty_final.

  DATA :
    ls_header   TYPE ztp3_l_s,
    lt_item     TYPE TABLE OF ztp3_l_s,
    lt_item_t   TYPE TABLE OF ztp3_l_s,
    lv_char(10),
    lv_num      TYPE n VALUE 1,
    lv_rem      TYPE ztp3_l_s-no_prints,
    form_name   TYPE rs38l_fnam,
    ls_cparam   TYPE ssfctrlop,
    r_charg     TYPE RANGE OF charg_d.
  CONSTANTS :
    c_1(1) VALUE '1',  " Sinlge Print
    c_2(1) VALUE '2',  " Multible Print
    c_x(1) VALUE 'X'.


  DATA: it_final TYPE TABLE OF ty_final,
        wa_final TYPE ty_final.


  BREAK ppadhy.
  IF i_mblnr IS NOT INITIAL.
    IF i_tp3_sticker EQ abap_true.
      IF i_charg IS INITIAL.

        SELECT
            matdoc~mblnr,
            matdoc~zeile,
            matdoc~mjahr,
            matdoc~parent_id,
            matdoc~matnr,
            matdoc~menge,
            matdoc~charg,
            matdoc~budat,
            matdoc~shkzg,
            mara~zzlabel_desc,
            mara~matkl,
            makt~maktx
            INTO TABLE @DATA(lt_doc)
            FROM  matdoc AS matdoc
            INNER JOIN mara AS mara ON mara~matnr = matdoc~matnr
            INNER JOIN makt AS makt ON mara~matnr = makt~matnr
            WHERE matdoc~mblnr = @i_mblnr AND matdoc~mjahr = @i_mjahr
          AND matdoc~shkzg = 'S'.

      ELSEIF i_charg IS NOT INITIAL.

        SELECT
            matdoc~mblnr
            matdoc~zeile
            matdoc~mjahr
            matdoc~parent_id
            matdoc~matnr
            matdoc~menge
            matdoc~charg
            matdoc~budat
            matdoc~shkzg
            mara~zzlabel_desc
            mara~matkl
            makt~maktx
            INTO TABLE lt_doc
            FROM  matdoc AS matdoc
            INNER JOIN mara AS mara ON mara~matnr = matdoc~matnr
            INNER JOIN makt AS makt ON mara~matnr = makt~matnr
            WHERE matdoc~mblnr = i_mblnr AND matdoc~mjahr = i_mjahr
          AND matdoc~charg =  i_charg AND matdoc~shkzg = 'S'.

      ENDIF.

      IF lt_doc IS NOT INITIAL.

        SELECT
          a511~kappl  ,
          a511~kschl  ,
          a511~matnr  ,
          a511~charg  ,
          a511~kfrst  ,
          a511~datbi  ,
          a511~datab  ,
          a511~kbstat ,
          a511~knumh  ,
          konp~kopos  ,
          konp~kbetr
          FROM a511 AS a511
          INNER JOIN konp AS konp ON a511~knumh = konp~knumh
          FOR ALL ENTRIES IN @lt_doc
          WHERE a511~matnr = @lt_doc-matnr AND a511~charg = @lt_doc-charg
          AND a511~kschl = konp~kschl
          INTO  TABLE @DATA(lt_a511).

        SELECT
          kschl,
          werks,
          vrkme,
          matnr,
          mat_cat,
          batch,
          kbetr FROM zcon_rec_t INTO TABLE @DATA(it_con)
          FOR ALL ENTRIES IN @lt_doc
          WHERE matnr = @lt_doc-matnr AND batch = @lt_doc-charg.

      ENDIF.

      LOOP AT lt_doc INTO DATA(wa_doc).

        wa_final-mblnr        = wa_doc-mblnr  .
        wa_final-zeile        = wa_doc-zeile  .
        wa_final-mjahr        = wa_doc-mjahr  .
        wa_final-parent_id    = wa_doc-parent_id  .
        wa_final-matnr        = wa_doc-matnr  .
        wa_final-menge        = wa_doc-menge  .
        wa_final-charg        = wa_doc-charg  .
        wa_final-budat        = wa_doc-budat  .
        wa_final-matnr        = wa_doc-matnr.
        wa_final-zzlabel_desc = wa_doc-zzlabel_desc.
        wa_final-matkl        = wa_doc-matkl       .
        wa_final-maktx        = wa_doc-maktx       .

**        READ TABLE lt_a511 INTO DATA(wa_a511) WITH KEY matnr = wa_doc-matnr charg = wa_doc-charg.
**        IF sy-subrc = 0.
**          wa_final-price = wa_a511-kbetr.
**        ELSE.
        READ TABLE it_con INTO DATA(wa_con) WITH KEY matnr = wa_doc-matnr batch = wa_doc-charg.
        IF sy-subrc = 0.
          wa_final-price = wa_con-kbetr.
        ELSE.
          READ TABLE lt_a511 INTO DATA(wa_a511) WITH KEY matnr = wa_doc-matnr charg = wa_doc-charg.
          IF sy-subrc = 0.
            wa_final-price = wa_a511-kbetr.
          ENDIF.
        ENDIF.

        APPEND wa_final TO it_final.
        CLEAR wa_final.

      ENDLOOP.



      CHECK it_final IS NOT INITIAL.
      DELETE it_final WHERE charg IS INITIAL.
      SORT it_final BY parent_id.
      DELETE ADJACENT DUPLICATES FROM it_final COMPARING mblnr matnr parent_id.

      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      LOOP AT it_final ASSIGNING FIELD-SYMBOL(<ls_doc>).
        ls_header-charg = <ls_doc>-charg.
        IF <ls_doc>-zzlabel_desc IS NOT INITIAL.
**          IF <ls_doc>-sortl IS NOT INITIAL.
**            <ls_doc>-sortl = condense( <ls_doc>-sortl ).
**            TRANSLATE <ls_doc>-zzlabel_desc TO LOWER CASE.
**            ls_header-maktx = <ls_doc>-zzlabel_desc+0(24) && '-' && <ls_doc>-sortl(4).
**          ELSE.
          TRANSLATE <ls_doc>-zzlabel_desc TO LOWER CASE.
          ls_header-maktx = <ls_doc>-zzlabel_desc+0(28).
**          ENDIF.
        ELSE.
*          IF <ls_doc>-sortl IS NOT INITIAL.
*            <ls_doc>-sortl = condense( <ls_doc>-sortl ).
          TRANSLATE <ls_doc>-maktx TO LOWER CASE.
          ls_header-maktx = <ls_doc>-maktx+0(24) && '-'."&& <ls_doc>-sortl(4).
*          ELSE.
          TRANSLATE <ls_doc>-maktx TO LOWER CASE.
          ls_header-maktx = <ls_doc>-maktx+0(28).
*          ENDIF.
        ENDIF.
        ls_header-matnr = <ls_doc>-matnr.
        ls_header-price = <ls_doc>-price.
***     Date Converstion to Alphabet code
***      1 - A , 2 - B , 3 - C , 4 - D , 5 - E , 6 - F , 7 - G , 8 - H , 9 - I , 0 - X.
        lv_char = <ls_doc>-budat.
        IF lv_char+0(1) = 0.
          ls_header-date = 'X'.
        ELSE.
          lv_num  = lv_char+0(1) - 1.
          ls_header-date = sy-abcde+lv_num(1).
          CLEAR : lv_num.
        ENDIF.

        IF lv_char+1(1) = 0.
          ls_header-date = ls_header-date && 'X'.
        ELSE.
          lv_num = lv_char+1(1) - 1.
          ls_header-date = ls_header-date &&  sy-abcde+lv_num(1).
          CLEAR : lv_num.
        ENDIF.

        IF lv_char+2(1) = 0.
          ls_header-date = ls_header-date && 'X'.
        ELSE.
          lv_num = lv_char+2(1) - 1.
          ls_header-date =  ls_header-date && sy-abcde+lv_num(1).
          CLEAR : lv_num.
        ENDIF.

        IF lv_char+3(1) = 0.
          ls_header-date = ls_header-date && 'X'.
        ELSE.
          lv_num = lv_char+3(1) - 1.
          ls_header-date =  ls_header-date && sy-abcde+lv_num(1).
          CLEAR : lv_num.
        ENDIF.

        IF lv_char+4(1) = 0.
          ls_header-date = ls_header-date && 'X'.
        ELSE.
          lv_num = lv_char+4(1) - 1.
          ls_header-date =  ls_header-date && sy-abcde+lv_num(1).
          CLEAR : lv_num.
        ENDIF.

        IF lv_char+5(1) = 0.
          ls_header-date = ls_header-date && 'X'.
        ELSE.
          lv_num = lv_char+5(1) - 1.
          ls_header-date =  ls_header-date && sy-abcde+lv_num(1).
          CLEAR : lv_num.
        ENDIF.

        IF lv_char+6(1) = 0.
          ls_header-date = ls_header-date && 'X'.
        ELSE.
          lv_num = lv_char+6(1) - 1.
          ls_header-date =  ls_header-date && sy-abcde+lv_num(1).
          CLEAR : lv_num.
        ENDIF.

        IF lv_char+7(1) = 0.
          ls_header-date = ls_header-date && 'X'.
        ELSE.
          lv_num = lv_char+7(1) - 1.
          ls_header-date =  ls_header-date && sy-abcde+lv_num(1).
          CLEAR : lv_num.
        ENDIF.
        ls_header-date = ls_header-date+6(2) && '.' && ls_header-date+4(2) && '.' && ls_header-date+2(2).


*        IF <ls_doc>-no_roll IS NOT INITIAL.
*          ls_header-no_prints = <ls_doc>-no_roll.
*        ELSE.
        ls_header-no_prints = <ls_doc>-menge.
*        ENDIF.

        ls_header-matkl = <ls_doc>-matkl.
        ls_header-item  = <ls_doc>-parent_id.
        APPEND ls_header TO lt_item.
        CLEAR : ls_header.
      ENDLOOP.
      DATA : ls_output TYPE ssfcompop.

      ls_cparam-no_open = 'X'.
      ls_cparam-no_close = c_x.
      ls_cparam-device = 'PRINTER'.
      ls_output-tdimmed = c_x.
      ls_output-tdnoprev = c_x.

      CALL FUNCTION 'SSF_OPEN'
        EXPORTING
          user_settings      = 'X'
          control_parameters = ls_cparam
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.

***   Getting Dynamic FM
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZTP3_LABLE'
        IMPORTING
          fm_name            = form_name
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.

***  Printing All Multible Prints
      SORT lt_item BY item.
      DATA(lv_count) = 1.
      LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
        CLEAR : lv_rem.
        IF i_prints IS  INITIAL.
          DATA(lv_qty) = <ls_item>-no_prints.
          DATA(lv_mod) = <ls_item>-no_prints MOD 2 .
        ELSE.
          lv_qty = i_prints.
          lv_mod = i_prints MOD 2.
        ENDIF.
        lv_rem  = lv_qty.
        DO lv_qty TIMES.
          REFRESH : lt_item_t.
          CHECK lv_rem > 0.
          IF lv_rem >= 2.
            <ls_item>-no_prints = 2.
            <ls_item>-count = lv_count.
            <ls_item>-count1 = lv_count + 1.
            <ls_item>-print_mode = 2.
            lv_count = lv_count + 2.
          ELSEIF lv_rem = 1.
            <ls_item>-no_prints = 1.
            <ls_item>-count = lv_count.
            lv_count = lv_count + 1.
            <ls_item>-print_mode = 1.
          ELSEIF lv_rem = 0.
            <ls_item>-no_prints = 1.
            <ls_item>-count = lv_count.
            lv_count = lv_count + 1.
            <ls_item>-print_mode = 1.
          ELSE.
            EXIT.
          ENDIF.
          lv_rem = lv_rem - <ls_item>-no_prints .
          APPEND <ls_item> TO lt_item_t.
          CALL FUNCTION form_name
            EXPORTING
              control_parameters = ls_cparam
              output_options     = ls_output
              user_settings      = 'X'
            TABLES
              i_item             = lt_item_t
            EXCEPTIONS
              formatting_error   = 1
              internal_error     = 2
              send_error         = 3
              user_canceled      = 4
              OTHERS             = 5.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.
        ENDDO.
      ENDLOOP.
    ENDIF.
    CLEAR : ls_header.

    CALL FUNCTION 'SSF_CLOSE'.
  ENDIF.


ENDFUNCTION.
