*&---------------------------------------------------------------------*
*& Report ZMM_TRAY_STICKER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_tray_stic_l.

DATA : ls_hdr TYPE zhu_s.
SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
PARAMETERS : p_hu TYPE exidv.
SELECTION-SCREEN : END OF BLOCK b1 .
CONSTANTS :
c_x(1) VALUE 'X'.
*** Fetch HU Data
SELECT
    vekp~venum,
    vekp~exidv,
    vepo~vepos,
    vepo~vbeln,
    vepo~vemng,
    vepo~vemeh
*    likp~kunnr,
*    lfa1~name1
    INTO TABLE @DATA(lt_hu)
    FROM  vekp AS vekp
    INNER JOIN vepo AS vepo ON vekp~venum = vepo~venum
*    INNER JOIN likp AS likp ON likp~vbeln = vepo~vbeln
*    INNER JOIN lfa1 AS lfa1 ON likp~kunnr = lfa1~kunnr
    WHERE vekp~exidv = @p_hu.

IF lt_hu IS INITIAL.
  MESSAGE s043(zmsg_cls) DISPLAY LIKE 'E'.
  LEAVE LIST-PROCESSING.
ELSE.
  LOOP AT lt_hu ASSIGNING FIELD-SYMBOL(<ls_hu>).
    ls_hdr-exidv = <ls_hu>-exidv.
*    ls_hdr-vbeln = <ls_hu>-vbeln.
    ls_hdr-vemeh = <ls_hu>-vemeh.
*    ls_hdr-name1 = <ls_hu>-name1.
    ADD <ls_hu>-vemng TO ls_hdr-vemng.
  ENDLOOP.

  ls_hdr-exidv = |{ ls_hdr-exidv ALPHA = IN }|.
*** Calling Smartforms
  DATA :
    form_name TYPE rs38l_fnam,
    ls_cparam TYPE ssfctrlop,
    ls_output TYPE ssfcompop.
***   Getting Dynamic FM
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'ZTRAY_LABEL'
    IMPORTING
      fm_name            = form_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  ls_cparam-no_open = space.
  ls_cparam-no_close = c_x.
*--> No Dialog -> sjena <- 11.02.2020 12:20:14
  ls_cparam-no_dialog = c_x.

  ls_output-tdimmed = c_x.
  ls_output-tdnoprev = c_x.

  CALL FUNCTION form_name
    EXPORTING
      control_parameters = ls_cparam
      output_options     = ls_output
      user_settings      = 'X'
      is_hdr             = ls_hdr
    EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      OTHERS             = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDIF.
