class ZCL_LABLE_PRINT definition
  public
  final
  create public .

public section.

  methods TP3_LABLE_PRINT
    importing
      !I_MBLNR type MBLNR
      !I_TP3_STICKER type CHAR1
      !I_MJAHR type MJAHR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_LABLE_PRINT IMPLEMENTATION.


  METHOD TP3_LABLE_PRINT.

    DATA : LS_HEADER TYPE ZTP3_L_S,
           LT_ITEM   TYPE TABLE OF ZTP3_L_S.
    CONSTANTS :
      C_1(1) VALUE '1',  " Sinlge Print
      C_2(1) VALUE '2',  " Multible Print
      C_X(1) VALUE 'X'.
    IF I_MBLNR IS NOT INITIAL.
      IF I_TP3_STICKER EQ ABAP_TRUE.
***  Fetching Material Details
        SELECT MATDOC~MBLNR,
               MATDOC~ZEILE,
               MATDOC~MJAHR,
               MATDOC~MATNR,
               MATDOC~EBELN,
               MATDOC~EBELP,
               MATDOC~MENGE,
               MATDOC~CHARG,
               MATDOC~BUDAT,
               ZINW_T_HDR~QR_CODE,
               ZINW_T_ITEM~MAKTX,
               ZINW_T_ITEM~NETPR_S
               INTO TABLE @DATA(LT_DOC)
               FROM  MATDOC AS MATDOC
               INNER JOIN ZINW_T_HDR AS ZINW_T_HDR ON ZINW_T_HDR~MBLNR_103 = MATDOC~MBLNR
               INNER JOIN ZINW_T_ITEM ON ZINW_T_HDR~QR_CODE = ZINW_T_ITEM~QR_CODE AND ZINW_T_ITEM~EBELN = MATDOC~EBELN AND ZINW_T_ITEM~EBELP = MATDOC~EBELP
               WHERE MATDOC~MBLNR = @I_MBLNR AND MATDOC~MJAHR = @I_MJAHR.

        SORT LT_DOC BY MBLNR MATNR.
        DELETE ADJACENT DUPLICATES FROM LT_DOC COMPARING MBLNR MATNR ZEILE.
        CHECK LT_DOC IS NOT INITIAL.
        DATA : FORM_NAME TYPE RS38L_FNAM.
        DATA  LS_CPARAM TYPE SSFCTRLOP.
        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            FORMNAME           = 'ZTP3_LABLE'
          IMPORTING
            FM_NAME            = FORM_NAME
          EXCEPTIONS
            NO_FORM            = 1
            NO_FUNCTION_MODULE = 2
            OTHERS             = 3.
        IF SY-SUBRC <> 0.
* Implement suitable error handling here
        ENDIF.
        BREAK SAMBURI.
        LOOP AT LT_DOC ASSIGNING FIELD-SYMBOL(<LS_DOC>).
          LS_HEADER-CHARG = <LS_DOC>-CHARG.
          LS_HEADER-MAKTX = <LS_DOC>-MAKTX.
          LS_HEADER-MATNR = <LS_DOC>-MATNR.
          LS_HEADER-PRICE = <LS_DOC>-NETPR_S.
          LS_HEADER-DATE  = <LS_DOC>-BUDAT.
***     CHECHING FOR MULTIBLE OR SINGLE PRINTS
          IF <LS_DOC>-MENGE GE 2.
            LS_HEADER-PRINT_MODE = C_2.
          ENDIF.
          LS_HEADER-NO_PRINTS = <LS_DOC>-MENGE.
          APPEND LS_HEADER TO LT_ITEM.
          CLEAR : LS_HEADER.
        ENDLOOP.
        DATA : LS_OUTPUT TYPE SSFCOMPOP.

        LS_CPARAM-NO_OPEN = SPACE.
        LS_CPARAM-NO_CLOSE = C_X.
        LS_CPARAM-NO_DIALOG = C_X.
        LS_CPARAM-DEVICE = 'PRINTER'.

*      LS_OUTPUT-TDDEST = 'ZCITIZENCLS703'.
        LS_OUTPUT-TDIMMED = C_X.
        LS_OUTPUT-TDNOPREV = C_X.

***  Printing All Multible Prints
        CALL FUNCTION FORM_NAME
          EXPORTING
            CONTROL_PARAMETERS = LS_CPARAM
            OUTPUT_OPTIONS     = LS_OUTPUT
            USER_SETTINGS      = 'X'
          TABLES
            I_ITEM             = LT_ITEM
          EXCEPTIONS
            FORMATTING_ERROR   = 1
            INTERNAL_ERROR     = 2
            SEND_ERROR         = 3
            USER_CANCELED      = 4
            OTHERS             = 5.
        IF SY-SUBRC <> 0.
* Implement suitable error handling here
        ENDIF.
        LEAVE TO LIST-PROCESSING.
      ENDIF.
      CLEAR : LS_HEADER.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
