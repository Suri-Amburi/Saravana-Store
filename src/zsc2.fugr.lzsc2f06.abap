*----------------------------------------------------------------------*
***INCLUDE LMGD2F06.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  MAP_INCOTERMS_PBO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAP_INCOTERMS_PBO .

* note 2389622
  IF CL_OPS_SWITCH_CHECK=>MM_SFWS_INCO_VERSIONS( ) EQ ABAP_TRUE.

    MMPUR_INCOTERMS_INFORECORDS-INCOV   = EINE-INCOV.
    MMPUR_INCOTERMS_INFORECORDS-INCO1   = EINE-INCO1.
    MMPUR_INCOTERMS_INFORECORDS-INCO2_L = EINE-INCO2_L.
    MMPUR_INCOTERMS_INFORECORDS-INCO3_L = EINE-INCO3_L.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAP_INCOTERMS_PAI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAP_INCOTERMS_PAI .

* note 2389622
  IF CL_OPS_SWITCH_CHECK=>MM_SFWS_INCO_VERSIONS( ) EQ ABAP_TRUE.

    EINE-INCOV   = MMPUR_INCOTERMS_INFORECORDS-INCOV.
    EINE-INCO1   = MMPUR_INCOTERMS_INFORECORDS-INCO1.
    EINE-INCO2_L = MMPUR_INCOTERMS_INFORECORDS-INCO2_L.
    EINE-INCO3_L = MMPUR_INCOTERMS_INFORECORDS-INCO3_L.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INCOTERMS_2010
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INCOTERMS_2010 .

* note 2389622

* Switch "MM_SFWS_INCO_VERSIONS" deactivated
  IF CL_OPS_SWITCH_CHECK=>MM_SFWS_INCO_VERSIONS( ) NE ABAP_ON.

    CALL FUNCTION 'RV_INCOTERMS_CHECK'
      EXPORTING
        INCO1               = EINE-INCO1
        INCO2               = EINE-INCO2
      EXCEPTIONS
        INCO1_MISSING       = 1
        INCO2_MISSING       = 2
        INCO2_NOT_ALLOWED   = 3
        TINC_NO_ENTRY_FOUND = 4
        OTHERS              = 5.
    CASE SY-SUBRC.
      WHEN 0.
      WHEN 1 OR 4.
        SET CURSOR FIELD 'EINE-INCO1'.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      WHEN 2 OR 3.
        SET CURSOR FIELD 'EINE-INCO2'.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDCASE.

  ELSE. "Switch "MM_SFWS_INCO_VERSIONS" activated

    CALL FUNCTION 'INCO_CHECK'
      EXPORTING
        INCOV                   = MMPUR_INCOTERMS_INFORECORDS-INCOV
        INCO1                   = MMPUR_INCOTERMS_INFORECORDS-INCO1
        INCO2_L                 = MMPUR_INCOTERMS_INFORECORDS-INCO2_L
        INCO3_L                 = MMPUR_INCOTERMS_INFORECORDS-INCO3_L
        APP_ID                  = 'EF'
      EXCEPTIONS
        INCO1_MISSING           = 1
        INCO2_MISSING           = 2
        INCO3_MISSING           = 3
        INCO2_NOT_ALLOWED       = 4
        TINC_NO_ENTRY_FOUND     = 5
        TINCVMAP_NO_ENTRY_FOUND = 6
        INCO3_INVALID           = 7
        TINCV_NO_ENTRY_FOUND    = 8
        INCO2_LENGTHY           = 9
        OTHERS                  = 10.

    CASE SY-SUBRC.
      WHEN 0.
      WHEN 1.
        SET CURSOR FIELD 'MMPUR_INCOTERMS_INFORECORDS-INCO1'.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      WHEN 2 OR 4 OR 9.
        SET CURSOR FIELD 'MMPUR_INCOTERMS_INFORECORDS-INCO2_L'.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      WHEN 3 OR 7.
        " If INCO3 is a required field and is empty, make sure that it is enabled for input
        LOOP AT SCREEN.
          IF SCREEN-NAME EQ 'MMPUR_INCOTERMS_INFORECORDS-INCO3_L' AND SCREEN-INPUT EQ 0.
            SCREEN-INPUT = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.

        SET CURSOR FIELD 'MMPUR_INCOTERMS_INFORECORDS-INCO3_L'.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      WHEN OTHERS.
        SET CURSOR FIELD 'MMPUR_INCOTERMS_INFORECORDS-INCO1'.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDCASE.

  ENDIF.

ENDFORM.
