FUNCTION zlable_print.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MBLNR) TYPE  MBLNR OPTIONAL
*"     VALUE(I_TP3_STICKER) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_MJAHR) TYPE  MJAHR OPTIONAL
*"     REFERENCE(I_CHARG) TYPE  CHARG_D OPTIONAL
*"     REFERENCE(I_PRINTS) TYPE  ZNO_PRINTS OPTIONAL
*"----------------------------------------------------------------------
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
    c_1(1)    VALUE '1',  " Sinlge Print
    c_2(1)    VALUE '2',  " Multible Print
    c_x(1)    VALUE 'X',
    c_zmrp(4) VALUE 'ZMRP'.


  IF i_mblnr IS NOT INITIAL.
    IF i_tp3_sticker EQ abap_true.
***  Fetching Material Details
***********************************************************************************************
      IF i_charg IS INITIAL.
        SELECT matdoc~mblnr,
               matdoc~zeile,
               matdoc~mjahr,
               matdoc~matnr,
               matdoc~ebeln,
               matdoc~ebelp,
               matdoc~menge,
               matdoc~charg,
               matdoc~budat,
               zinw_t_hdr~qr_code,
               mara~zzlabel_desc,
               zinw_t_item~maktx,
               zinw_t_item~netpr_s,
               zinw_t_item~no_roll,
               mara~matkl,
               lfa1~sortl
               INTO TABLE @DATA(lt_doc)
               FROM  matdoc AS matdoc
               INNER JOIN zinw_t_hdr AS zinw_t_hdr ON zinw_t_hdr~mblnr = matdoc~mblnr
               INNER JOIN zinw_t_item ON zinw_t_hdr~qr_code = zinw_t_item~qr_code AND zinw_t_item~ebeln = matdoc~ebeln AND zinw_t_item~ebelp = matdoc~ebelp
               INNER JOIN mara AS mara ON mara~matnr = zinw_t_item~matnr
               INNER JOIN lfa1 AS lfa1 ON zinw_t_hdr~lifnr = lfa1~lifnr
               WHERE matdoc~mblnr = @i_mblnr AND matdoc~mjahr = @i_mjahr.
        IF sy-subrc <> 0.
***  For Local Purchage
          SELECT matdoc~mblnr
                 matdoc~zeile
                 matdoc~mjahr
                 matdoc~matnr
                 matdoc~ebeln
                 matdoc~ebelp
                 matdoc~menge
                 matdoc~charg
                 matdoc~budat
                 zinw_t_hdr~qr_code
                 mara~zzlabel_desc
                 zinw_t_item~maktx
                 zinw_t_item~netpr_s
                 zinw_t_item~no_roll
                 mara~matkl
                 lfa1~sortl
                 INTO TABLE lt_doc
                 FROM  matdoc AS matdoc
                 INNER JOIN zinw_t_hdr AS zinw_t_hdr ON zinw_t_hdr~mblnr_103 = matdoc~mblnr
                 INNER JOIN zinw_t_item ON zinw_t_hdr~qr_code = zinw_t_item~qr_code AND zinw_t_item~ebeln = matdoc~ebeln AND zinw_t_item~ebelp = matdoc~ebelp
                 INNER JOIN mara AS mara ON mara~matnr = zinw_t_item~matnr
                 INNER JOIN lfa1 AS lfa1 ON zinw_t_hdr~lifnr = lfa1~lifnr
                 WHERE matdoc~mblnr = i_mblnr AND matdoc~mjahr = i_mjahr.
        ENDIF.
      ELSEIF i_charg IS NOT INITIAL.
**********************************************ADDED BY SKN ON 22.02.2020*************************************************
        CLEAR : lt_doc.
        SELECT matdoc~mblnr
               matdoc~zeile
               matdoc~mjahr
               matdoc~matnr
               matdoc~ebeln
               matdoc~ebelp
               matdoc~menge
               matdoc~charg
               matdoc~budat
               zinw_t_hdr~qr_code
               mara~zzlabel_desc
               zinw_t_item~maktx
               zinw_t_item~netpr_s
               zinw_t_item~no_roll
               mara~matkl
               lfa1~sortl
               INTO TABLE lt_doc
               FROM  matdoc AS matdoc
               INNER JOIN zinw_t_hdr AS zinw_t_hdr ON zinw_t_hdr~mblnr = matdoc~mblnr
               INNER JOIN zinw_t_item ON zinw_t_hdr~qr_code = zinw_t_item~qr_code AND zinw_t_item~ebeln = matdoc~ebeln AND zinw_t_item~ebelp = matdoc~ebelp
               INNER JOIN mara AS mara ON mara~matnr = zinw_t_item~matnr
               INNER JOIN lfa1 AS lfa1 ON zinw_t_hdr~lifnr = lfa1~lifnr
               WHERE matdoc~mblnr = i_mblnr AND matdoc~mjahr = i_mjahr AND matdoc~charg =  i_charg.
        IF sy-subrc <> 0.
***  For Local Purchage
          SELECT matdoc~mblnr
                 matdoc~zeile
                 matdoc~mjahr
                 matdoc~matnr
                 matdoc~ebeln
                 matdoc~ebelp
                 matdoc~menge
                 matdoc~charg
                 matdoc~budat
                 zinw_t_hdr~qr_code
                 mara~zzlabel_desc
                 zinw_t_item~maktx
                 zinw_t_item~netpr_s
                 zinw_t_item~no_roll
                 mara~matkl
                 lfa1~sortl
                 INTO TABLE lt_doc
                 FROM  matdoc AS matdoc
                 INNER JOIN zinw_t_hdr AS zinw_t_hdr ON zinw_t_hdr~mblnr_103 = matdoc~mblnr
                 INNER JOIN zinw_t_item ON zinw_t_hdr~qr_code = zinw_t_item~qr_code AND zinw_t_item~ebeln = matdoc~ebeln AND zinw_t_item~ebelp = matdoc~ebelp
                 INNER JOIN mara AS mara ON mara~matnr = zinw_t_item~matnr
                 INNER JOIN lfa1 AS lfa1 ON zinw_t_hdr~lifnr = lfa1~lifnr
                 WHERE matdoc~mblnr = i_mblnr AND matdoc~mjahr = i_mjahr AND matdoc~charg =  i_charg.
        ENDIF.
      ENDIF.

      CHECK lt_doc IS NOT INITIAL.
      DELETE lt_doc WHERE charg IS INITIAL.
***   Batach Managed - Branded
      SELECT a515~matnr,
             konp~kbetr
             INTO TABLE @DATA(lt_mrp)
             FROM konp AS konp
             INNER JOIN a515 AS a515 ON konp~knumh = a515~knumh
             FOR ALL ENTRIES IN @lt_doc
             WHERE a515~kschl = @c_zmrp AND a515~matnr = @lt_doc-matnr AND a515~datab LE @sy-datum AND a515~datbi GE @sy-datum AND konp~loevm_ko = @space.

      SORT lt_doc BY zeile.
      DELETE ADJACENT DUPLICATES FROM lt_doc COMPARING mblnr matnr zeile.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
      LOOP AT lt_doc ASSIGNING FIELD-SYMBOL(<ls_doc>).
        ls_header-charg = <ls_doc>-charg.
        IF <ls_doc>-zzlabel_desc IS NOT INITIAL.
          IF <ls_doc>-sortl IS NOT INITIAL.
            <ls_doc>-sortl = condense( <ls_doc>-sortl ).
            TRANSLATE <ls_doc>-zzlabel_desc TO LOWER CASE.
            ls_header-maktx = <ls_doc>-zzlabel_desc+0(24) && '-' && <ls_doc>-sortl(4).
          ELSE.
            TRANSLATE <ls_doc>-zzlabel_desc TO LOWER CASE.
            ls_header-maktx = <ls_doc>-zzlabel_desc+0(28).
          ENDIF.
        ELSE.
          IF <ls_doc>-sortl IS NOT INITIAL.
            <ls_doc>-sortl = condense( <ls_doc>-sortl ).
            TRANSLATE <ls_doc>-maktx TO LOWER CASE.
            ls_header-maktx = <ls_doc>-maktx+0(24) && '-'&& <ls_doc>-sortl(4).
          ELSE.
            TRANSLATE <ls_doc>-maktx TO LOWER CASE.
            ls_header-maktx = <ls_doc>-maktx+0(28).
          ENDIF.
        ENDIF.
        ls_header-matnr = <ls_doc>-matnr.
        READ TABLE lt_mrp ASSIGNING FIELD-SYMBOL(<ls_mrp>) WITH KEY matnr = <ls_doc>-matnr.
        IF sy-subrc IS INITIAL.
          ls_header-price = <ls_mrp>-kbetr.
        ELSE.
          ls_header-price = <ls_doc>-netpr_s.
        ENDIF.

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

        IF <ls_doc>-no_roll IS NOT INITIAL.
          ls_header-no_prints = <ls_doc>-no_roll.
        ELSE.
          ls_header-no_prints = <ls_doc>-menge.
        ENDIF.

        ls_header-matkl = <ls_doc>-matkl.
        ls_header-item = <ls_doc>-zeile.
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
        ELSE.                                          """"" ADDED BY SKN ON 22.02.2020
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
