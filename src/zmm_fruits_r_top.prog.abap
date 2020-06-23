*&---------------------------------------------------------------------*
*& Include          ZMM_FRUITS_R_TOP
*&---------------------------------------------------------------------*
TABLES : klah,kssk,mara,mseg,vbrp,t023.
TYPE-POOLS : slis.
INCLUDE <icon>.
TYPES : BEGIN OF ty_klah ,
          clint TYPE clint,
          klart TYPE klassenart,
          class TYPE klasse_d,
          vondt TYPE vondat,
          bisdt TYPE bisdat,
          wwskz TYPE klah-wwskz,
        END OF ty_klah ,


        BEGIN OF TY_KLAH1 ,
          CLINT TYPE CLINT,
          KLART TYPE KLASSENART,
          CLASS TYPE MATKL,
          VONDT TYPE VONDAT,
          BISDT TYPE BISDAT,
          WWSKZ TYPE KLAH-WWSKZ,
        END OF TY_KLAH1 ,

        BEGIN OF TY_KSSK ,
          OBJEK TYPE CUOBN,
          MAFID TYPE KLMAF,
          KLART TYPE KLASSENART,
          CLINT TYPE CLINT,
          ADZHL TYPE ADZHL,
          DATUB TYPE DATUB,
        END OF TY_KSSK ,

       BEGIN OF TY_KSSK1 ,
          OBJEK  TYPE CLINT,
          OBJEK1 TYPE KSSK-OBJEK,
        END OF TY_KSSK1 ,

        BEGIN OF ty_T023T,
          SPRAS TYPE SPRAS,
          MATKL TYPE MATKL,
          WGBEZ TYPE WGBEZ,
          WGBEZ60 TYPE WGBEZ60,
          END OF ty_t023t,


        BEGIN OF ty_mara,
          matnr TYPE matnr,
          matkl TYPE matkl,
          MEINS TYPE MEINS,
        END OF ty_mara,

        BEGIN OF ty_mard,
          MATNR TYPE MATNR,
          WERKS  TYPE  WERKS_D,
          LGORT TYPE LGORT_D,
          LABST TYPE LABST,
          END OF ty_mard.

     TYPES  :BEGIN OF ty_log,
        type  TYPE msgty_co,
        id    TYPE arbgb,
        txtnr TYPE msgnr,
        msgv1 TYPE symsgv,
        msgv2 TYPE symsgv,
        msgv3 TYPE symsgv,
      END OF ty_log,


*         BEGIN OF TY_MBEW,
*           MATNR TYPE MATNR,
*           BWKEY TYPE BWKEY,   " PLANT
*           BWTAR TYPE BWTAR_D,
*           VERPR TYPE VERPR,
*           END OF TY_MBEW,

        BEGIN OF ty_mseg,
          mblnr      TYPE mblnr,
          mjahr      TYPE mjahr,
          zeile      TYPE mblpo,
          line_id    TYPE mb_line_id,
          budat_mkpf TYPE budat,
          matnr      TYPE matnr,
          bwart      TYPE bwart,                    "MOMENT TYPE
          werks      TYPE werks_d,                  "PLANT
          menge      TYPE menge_d,                  "QUANTITY
          dmbtr      TYPE dmbtr_cs,                  "LC AMOUNT
        END OF ty_mseg,

        BEGIN OF ty_mseg02,
          mblnr      TYPE mblnr,
          mjahr      TYPE mjahr,
          zeile      TYPE mblpo,
          line_id    TYPE mb_line_id,
          budat_mkpf TYPE budat,
          matnr      TYPE matnr,
          bwart      TYPE bwart,                    "MOMENT TYPE
          werks      TYPE werks_d,                  "PLANT
          menge      TYPE menge_d,                  "QUANTITY
          dmbtr      TYPE dmbtr_cs,                  "LC AMOUNT
        END OF ty_mseg02,


        BEGIN OF TY_MENGE,
*           mblnr      TYPE mblnr,
           matnr      TYPE matnr,
           date  TYPE budat,
           werks      TYPE werks_d,
           menge_m      TYPE menge_d,
           menge      TYPE menge_d,
          END OF TY_MENGE,

        BEGIN OF TY_MBEW,
          MATNR TYPE MATNR,
          BWKEY TYPE BWKEY,          " PLANT
          BWTAR TYPE MBEW-BWTAR,
          VERPR TYPE VERPR,
          END OF TY_MBEW,

          BEGIN OF TY_T001W ,
            WERKS TYPE WERKS_D,
            NAME1 TYPE NAME1,
            END OF TY_T001W.

            TYPES: BEGIN OF ty_hdr,
        ebeln   TYPE ebeln,
        werks   TYPE werks_d,
    mblnr_541   TYPE mblnr,
    mblnr_101   TYPE mblnr,
    mblnr_542   TYPE mblnr,
    mblnr_201   TYPE mblnr,
       END OF ty_hdr.

TYPES: BEGIN OF ty_item,
        ebeln TYPE ebeln,
        ebelp TYPE ebelp,
        matnr TYPE matnr,
        maktx TYPE maktx,
        matkl TYPE matkl,
        ean11 TYPE mara-ean11,
       omenge TYPE menge_d,
       rmenge TYPE menge_d,
        meins TYPE meins,
       pur_amt TYPE bprei,
      netpr_s TYPE bprei,
      END OF ty_item.


TYPES : BEGIN OF ty_final,
        CATEGORY     TYPE matkl,
        CATEG(20)    TYPE C,
        WGBEZ60      TYPE WGBEZ60,
        OPEN_QTY     TYPE LABST,
        menge01     TYPE menge_d,
        menge02     TYPE menge_d,
        menge03     TYPE menge_d,
        menge04     TYPE menge_d,
        menge05     TYPE LABST,
        VERPR       TYPE VERPR,
        GRPO_QTY     TYPE menge_d,
        DC_QTY       TYPE menge_d,
        AVAL_QTY     TYPE menge_d,
        TOT_COST     TYPE VERPR,
        check(01),
        check2(5)    TYPE c,
        style    TYPE lvc_t_styl,  """ ADDED
        END OF TY_FINAL.

    DATA: wa_hdr   TYPE ty_hdr,
      wa_item  TYPE ty_item,
      it_item  TYPE TABLE OF ty_item.

        data : it_klah TYPE TABLE OF ty_klah,
               wa_klah TYPE ty_klah,

               it_klah1 TYPE TABLE OF ty_klah1,
               wa_klah1 TYPE ty_klah1,

               it_klah2 TYPE TABLE OF ty_klah,
               wa_klah2 TYPE ty_klah,

               IT_MBEW TYPE TABLE OF TY_MBEW,
               WA_MBEW TYPE TY_MBEW,

               IT_T001W TYPE TABLE OF TY_T001W,
               WA_T001W TYPE TY_T001W,

               it_kssk TYPE TABLE OF ty_kssk,
               wa_kssk TYPE ty_kssk,

               IT_KSSK1   TYPE TABLE OF TY_KSSK1,
                WA_KSSK1   TYPE TY_KSSK1,

                it_T023T TYPE TABLE OF ty_T023T,
                wa_T023T TYPE ty_T023T,

               IT_MARA TYPE TABLE OF TY_MARA,
               IT_MARA2 TYPE TABLE OF TY_MARA,
               WA_MARA TYPE TY_MARA,
               WA_MARA2 TYPE TY_MARA,

               it_mard TYPE TABLE OF ty_mard,
               wa_mard TYPE ty_mard,

               IT_MSEG2 TYPE TABLE OF TY_MSEG,
               WA_MSEG2 TYPE  TY_MSEG,

               IT_MSEG TYPE TABLE OF TY_MSEG,
               WA_MSEG TYPE  TY_MSEG,

               IT_MSEG3 TYPE TABLE OF TY_MSEG,
               WA_MSEG3 TYPE  TY_MSEG,

               IT_MSEG01 TYPE TABLE OF TY_MSEG,
               WA_MSEG01 TYPE  TY_MSEG,

               IT_MSEG02 TYPE TABLE OF TY_MSEG02,
               WA_MSEG02 TYPE  TY_MSEG02,

               it_menge01 TYPE TABLE OF ty_menge,
               wa_menge01 TYPE ty_menge,

               it_menge02 TYPE TABLE OF ty_menge,
               wa_menge02 TYPE ty_menge,

               it_menge03 TYPE TABLE OF ty_menge,
               wa_menge03 TYPE ty_menge,

               it_menge04 TYPE TABLE OF ty_menge,
               wa_menge04 TYPE ty_menge,

               it_menge05 TYPE TABLE OF ty_menge,
               wa_menge05 TYPE ty_menge,

               it_menge06 TYPE TABLE OF ty_menge,
               wa_menge06 TYPE ty_menge,

               it_mengec2 TYPE TABLE OF ty_menge,
               wa_mengec2 TYPE ty_menge,

               it_mengec1 TYPE TABLE OF ty_menge,
               wa_mengec1 TYPE ty_menge,

               it_mengec3 TYPE TABLE OF ty_menge,
               wa_mengec3 TYPE ty_menge,

               it_mengec4 TYPE TABLE OF ty_menge,
               wa_mengec4 TYPE ty_menge,

               it_log   TYPE TABLE OF ty_log,
               wa_log   TYPE ty_log.



        DATA:
                it_fcat TYPE slis_t_fieldcat_alv,
                wa_fcat TYPE slis_fieldcat_alv,

                it_final TYPE TABLE OF ty_final,
                wa_final TYPE ty_final,

                it_final2 TYPE TABLE OF ty_final,
                wa_final2 TYPE ty_final,

                it_fin TYPE TABLE OF ty_final,
                wa_fin TYPE ty_final.

                DATA: OK_CODE LIKE SY-UCOMM.

        DATA : gv_plant       TYPE werks_d.
        DATA :  LV_DATE TYPE ERDAT ,



        LW_LAYO     TYPE LVC_S_LAYO,
       LT_FIELDCAT TYPE  LVC_T_FCAT.
        DATA : LS_STABLE TYPE LVC_S_STBL.
        DATA : gv_subrc     TYPE sy-subrc.
         data : msgv3(50) TYPE c.



*  DATA:CONTAINER   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
*       GRID        TYPE REF TO CL_GUI_ALV_GRID,
*       C_REFRESH TYPE SYUCOMM VALUE 'REF'.
*   DATA: LT_EXCLUDE TYPE UI_FUNCTIONS.
*
*        CLASS EVENT_CLASS DEFINITION DEFERRED.
*  DATA: GR_EVENT TYPE REF TO EVENT_CLASS.
*
*  CLASS EVENT_CLASS DEFINITION.
*    PUBLIC SECTION.
*      METHODS: HANDLE_DATA_CHANGED
*                  FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
*        IMPORTING ER_DATA_CHANGED.
*  ENDCLASS.
*
*********Changes done on 23/04/2020
*
*
**  *** Class Implemntation
*  CLASS EVENT_CLASS IMPLEMENTATION.
*    METHOD HANDLE_DATA_CHANGED.
**      BREAK BREDDY .
*      DATA : ERROR_IN_DATA(1).
**      LOOP AT ER_DATA_CHANGED->MT_MOD_CELLS ASSIGNING FIELD-SYMBOL(<X_MOD_CELLS>).
**        READ TABLE GT_FINAL2 ASSIGNING <GL_FINAL2> INDEX <X_MOD_CELLS>-ROW_ID .
**        IF SY-SUBRC = 0 .
**          IF  <X_MOD_CELLS>-VALUE IS NOT INITIAL.
**            LV_SUM =   <GL_FINAL2>-AMOUNT +   LV_SUM .
**          ENDIF .
*
***        READ TABLE GT_FINAL2 ASSIGNING <GL_FINAL2> INDEX <X_MOD_CELLS>-VALUE .
**        IF <X_MOD_CELLS>-VALUE  IS  INITIAL.
**
**          LV_SUM = LV_SUM - <GL_FINAL2>-AMOUNT .
**
**        ENDIF.
**        ENDIF.
**      ENDLOOP.
*
**** Refreshing Table Data
*      IF GRID IS BOUND.
*        DATA: IS_STABLE TYPE LVC_S_STBL, LV_LINES TYPE INT2.
*        IS_STABLE = 'XX'.
*        IF GRID IS BOUND.
*          CALL METHOD GRID->REFRESH_TABLE_DISPLAY
*            EXPORTING
*              IS_STABLE = IS_STABLE               " With Stable Rows/Columns
*            EXCEPTIONS
*              FINISHED  = 1                       " Display was Ended (by Export)
*              OTHERS    = 2.
*          IF SY-SUBRC <> 0.
*            MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*
*
**** Display Errors
*      IF ERROR_IN_DATA IS NOT INITIAL .
*        CALL METHOD ER_DATA_CHANGED->DISPLAY_PROTOCOL( ).
*      ELSE.
**** Refreshing Main Screen
*        CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*          EXPORTING
*            NEW_CODE = C_REFRESH.
*      ENDIF.
*
*    ENDMETHOD.
*  ENDCLASS .
*








        data : head(20).
