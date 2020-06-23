class ZCL_ZGW_VENDOR_DPC_EXT definition
  public
  inheriting from ZCL_ZGW_VENDOR_DPC
  create public .

public section.
protected section.

  methods VENDOR_TYPESET_GET_ENTITYSET
    redefinition .
  methods VENDOR_TYPESET_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZGW_VENDOR_DPC_EXT IMPLEMENTATION.


  METHOD VENDOR_TYPESET_GET_ENTITY.
*    FIELD-SYMBOLS : <LS_KEY_TAB> TYPE /IWBEP/S_MGW_NAME_VALUE_PAIR.
*    DATA : LV_LIFNR TYPE LIFNR.
**** Get the key property values
*    READ TABLE IT_KEY_TAB WITH KEY NAME = 'Lifnr' ASSIGNING <LS_KEY_TAB>.
*    IF SY-SUBRC = 0.
*      LV_LIFNR = <LS_KEY_TAB>-VALUE.
*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          INPUT  = LV_LIFNR
*        IMPORTING
*          OUTPUT = LV_LIFNR.
*      SELECT SINGLE
*      LIFNR
*      LAND1
*      NAME1
*      NAME2
*      ORT01
*      ORT02
*      PSTLZ
*      REGIO
*      STRAS
*      ADRNR
*      ADDR2_STREET
*      ADDR2_HOUSE_NUM
*      FROM LFA1 INTO CORRESPONDING FIELDS OF ER_ENTITY WHERE
*LIFNR  = LV_LIFNR.
*    ENDIF.
  ENDMETHOD.


  METHOD VENDOR_TYPESET_GET_ENTITYSET.

*    TYPES:
*      BEGIN OF TY_KLAH_H,
*        CLINT TYPE KLAH-CLINT,
*        KLART TYPE KLAH-KLART,
*        CLASS TYPE KLAH-CLASS,
*        OBJEK TYPE KSSK-OBJEK,
*      END OF TY_KLAH_H,
*
**** Item Data
*      BEGIN OF TY_KLAH_I,
*        CLINT TYPE KLAH-CLINT,
*        KLART TYPE KLAH-KLART,
*        CLASS TYPE MARA-MATKL,
*      END OF TY_KLAH_I,

*      BEGIN OF TY_LFA1,
*        MATKL           TYPE MARA-MATKL,
*        LIFNR           TYPE A502-LIFNR,
*        LAND1           TYPE LFA1-LAND1,
*        NAME1           TYPE LFA1-NAME1,
*        NAME2           TYPE LFA1-NAME2,
*        ORT01           TYPE LFA1-ORT01,
*        ORT02           TYPE LFA1-ORT02,
*        PSTLZ           TYPE LFA1-PSTLZ,
*        REGIO           TYPE LFA1-REGIO,
*        STRAS           TYPE LFA1-STRAS,
*        ADRNR           TYPE LFA1-ADRNR,
*        ADDR2_STREET    TYPE LFA1-ADDR2_STREET,
*        ADDR2_HOUSE_NUM TYPE LFA1-ADDR2_HOUSE_NUM,
*      END OF TY_LFA1.


    DATA :
*      LT_KLAH_H      TYPE STANDARD TABLE OF TY_KLAH_H,
*      LT_KLAH_I      TYPE STANDARD TABLE OF TY_KLAH_I,
*      LT_LFA1        TYPE STANDARD TABLE OF TY_LFA1,
      R_LIFNR        TYPE RANGE OF LIFNR,
      R_LO           TYPE RANGE OF REGIO,
      R_GROUP_ID     TYPE RANGE OF KLASSE_D,
      LV_LIFNR       TYPE LIFNR,
      LV_ID          TYPE KLASSE_D,
      LV_LOCALOUT(1),
      LS_ENTITY      TYPE LINE OF ZCL_ZGW_VENDOR_MPC=>TT_VENDOR_TYPE.

    CONSTANTS :
      C_CLASS(5)    VALUE 'Class',
      C_LOCALOUT(8) VALUE 'LocalOut',
      C_LIFNR(8)    VALUE 'Lifnr',
      C_O(1)        VALUE 'O',
      C_L(1)        VALUE 'L',
      C_X(1)        VALUE 'X',
      C_33(2)       VALUE '33'.

*** Filters
*** Select Options
    CHECK IT_FILTER_SELECT_OPTIONS  IS NOT INITIAL.
    LOOP AT IT_FILTER_SELECT_OPTIONS ASSIGNING FIELD-SYMBOL(<LS_FILTER>).
      IF SY-SUBRC = 0.
        CASE <LS_FILTER>-PROPERTY.
          WHEN C_CLASS.
            READ TABLE <LS_FILTER>-SELECT_OPTIONS ASSIGNING FIELD-SYMBOL(<LS_SEL_OPT>) INDEX 1.
            IF SY-SUBRC = 0.
              LV_ID = <LS_SEL_OPT>-LOW.
              APPEND VALUE #( LOW = LV_ID SIGN = 'I' OPTION = 'EQ' ) TO R_GROUP_ID.
            ENDIF.
          WHEN C_LOCALOUT.
            READ TABLE <LS_FILTER>-SELECT_OPTIONS ASSIGNING <LS_SEL_OPT> INDEX 1.
            IF SY-SUBRC = 0.
              LV_LOCALOUT = <LS_SEL_OPT>-LOW.
              IF <LS_SEL_OPT>-LOW  = C_O.
                APPEND VALUE #( LOW = C_33 SIGN = 'I' OPTION = 'NE' ) TO R_LO.
              ELSEIF <LS_SEL_OPT>-LOW  = C_L.
                APPEND VALUE #( LOW = C_33 SIGN = 'I' OPTION = 'EQ' ) TO R_LO.
              ENDIF.
            ENDIF.
          WHEN C_LIFNR.
            READ TABLE <LS_FILTER>-SELECT_OPTIONS ASSIGNING <LS_SEL_OPT> INDEX 1.
            IF SY-SUBRC = 0.
              LV_LIFNR = <LS_SEL_OPT>-LOW.
              APPEND VALUE #( LOW = LV_LIFNR SIGN = 'I' OPTION = 'EQ' ) TO R_LIFNR.
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDLOOP.

*    CHECK LV_ID IS NOT INITIAL.
*    TRY.
*        ZCL_OD_VENDOR=>GET_CLASS_HEADER(
*          EXPORTING
*            I_CLASS  = LV_ID
*          IMPORTING
*            T_KLAH_H =  LT_KLAH_H ).
*      CATCH CX_AMDP_ERROR. " Exceptions when calling AMDP methods
*    ENDTRY.
*
*    IF LT_KLAH_H IS NOT INITIAL.
*      TRY.
*          ZCL_OD_VENDOR=>GET_CLASS_ITEM(
*            EXPORTING
*              IT_KLAH_H = LT_KLAH_H
*            IMPORTING
*              T_KLAH_I  = LT_KLAH_I ).
*
*        CATCH CX_AMDP_ERROR. " Exceptions when calling AMDP methods
*      ENDTRY.
*      IF LT_KLAH_I IS NOT INITIAL .
*        TRY .
*            ZCL_OD_VENDOR=>GET_VENDOR_DETAILS(
*              EXPORTING
*                IT_KLAH_I = LT_KLAH_I
*              IMPORTING
*                T_LFA1    = LT_LFA1 ).
*          CATCH CX_AMDP_ERROR. " Exceptions when calling AMDP methods
*        ENDTRY.
*      ENDIF.
*    ENDIF.

*    IF  LT_LFA1 IS NOT INITIAL.
**      IF LV_LOCALOUT = C_O.
**        DELETE LT_LFA1 WHERE REGIO = C_33.
**      ELSEIF LV_LOCALOUT = C_L.
**        DELETE LT_LFA1 WHERE REGIO <> C_33.
**      ENDIF.
*      SORT LT_LFA1 BY MATKL LIFNR .
*      DELETE ADJACENT DUPLICATES FROM LT_LFA1 COMPARING MATKL LIFNR.
*
*      LOOP AT LT_LFA1 ASSIGNING <LS_LFA1>.
*        READ TABLE LT_KLAH_I ASSIGNING <LS_KLAH_I> WITH KEY  CLASS = <LS_LFA1>-MATKL.
*        IF SY-SUBRC = 0.
*          READ TABLE LT_KLAH_H ASSIGNING <LS_KLAH_H> WITH KEY OBJEK = <LS_KLAH_I>-CLINT.
*          IF SY-SUBRC = 0.
*            MOVE-CORRESPONDING <LS_LFA1> TO LS_ENTITY.
*            LS_ENTITY-CLASS = <LS_KLAH_H>-CLASS.
*            APPEND LS_ENTITY TO ET_ENTITYSET.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.


*** Converting Renges into Query
    TRY .
        DATA(Q_GROUP_ID) = CL_SHDB_SELTAB=>COMBINE_SELTABS( IT_NAMED_SELTABS = VALUE #( ( NAME = 'CLASS' DREF = REF #( R_GROUP_ID[] ) ) ) ).
      CATCH CX_SHDB_EXCEPTION.
    ENDTRY.

    TRY .
        DATA(Q_LIFNR) = CL_SHDB_SELTAB=>COMBINE_SELTABS( IT_NAMED_SELTABS = VALUE #( ( NAME = 'LIFNR' DREF = REF #( R_LIFNR[] ) )
                                                                                     ( NAME = 'REGIO' DREF = REF #( R_LO[] ) ) ) ) .
      CATCH CX_SHDB_EXCEPTION.
    ENDTRY.
    TRY .
        ZCL_OD_VENDOR=>GET_VENDOR(
          EXPORTING
            I_CLIENT    = SY-MANDT
            IQ_LIFNR    = Q_LIFNR
            IQ_GROUP_ID = Q_GROUP_ID
          IMPORTING
            T_LFA1      = DATA(LT_LFA1) ).
      CATCH CX_AMDP_ERROR.
    ENDTRY.

***   NEW CHANGES TO SERVICE TO GET VENDOR DATAILS
    REFRESH : ET_ENTITYSET.
    CHECK LT_LFA1 IS NOT INITIAL.
    LOOP AT LT_LFA1 ASSIGNING FIELD-SYMBOL(<LS_LFA1>).
      MOVE-CORRESPONDING <LS_LFA1> TO LS_ENTITY.
      APPEND LS_ENTITY TO ET_ENTITYSET.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
