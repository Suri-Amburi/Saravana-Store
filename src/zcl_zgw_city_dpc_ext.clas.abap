class ZCL_ZGW_CITY_DPC_EXT definition
  public
  inheriting from ZCL_ZGW_CITY_DPC
  create public .

public section.
protected section.

  methods CITY_TYPESET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZGW_CITY_DPC_EXT IMPLEMENTATION.


  METHOD CITY_TYPESET_GET_ENTITYSET.

    CONSTANTS :
      C_CLASS(5)    VALUE 'Class',
      C_LOCALOUT(8) VALUE 'LocalOut',
      C_LIFNR(8)    VALUE 'Lifnr',
      C_O(1)        VALUE 'O',
      C_L(1)        VALUE 'L',
      C_X(1)        VALUE 'X',
      C_33(2)       VALUE '33'.

    DATA :
      R_LIFNR        TYPE RANGE OF LIFNR,
      R_LO           TYPE RANGE OF REGIO,
      R_GROUP_ID     TYPE RANGE OF KLASSE_D,
      LV_LIFNR       TYPE LIFNR,
      LV_ID          TYPE KLASSE_D,
      LV_LOCALOUT(1),
      LS_ENTITY      TYPE LINE OF ZCL_ZGW_CITY_MPC=>TT_CITY_TYPE.

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
    SORT LT_LFA1 BY ORT01.
    DELETE ADJACENT DUPLICATES FROM LT_LFA1 COMPARING ORT01.
    LOOP AT LT_LFA1 ASSIGNING FIELD-SYMBOL(<LS_LFA1>).
      MOVE-CORRESPONDING <LS_LFA1> TO LS_ENTITY.
      APPEND LS_ENTITY TO ET_ENTITYSET.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
