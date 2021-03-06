*&---------------------------------------------------------------------*
*& Include          ZMM_MAT_IDC_T_TOP
*&---------------------------------------------------------------------*

TYPES:BEGIN OF TA_FLATFILE,
        """Header data
        MATERIAL(40),
        VARIANT_LONG(40),"Variant
        MATL_TYPE(4),
        MATL_GROUP(9),
        MATL_CAT(2),
        CHAR_PROF(18),
        CONFIG_CLASS_TYPE(3), "config class type
        "color
        CHAR_NAME(30),
        CHAR_VALUE_LONG(70),
        CHAR_VAL_CHAR(70),
        "size
        CHAR_NAME1(30),
        CHAR_VALUE_LONG1(70),
        CHAR_VAL_CHAR1(70),

        ""basic data view
        BASIC_VIEW(1),
        BASE_UOM(3),
        TRANS_GRP(4),
        DIVISION(2),
        BATCH_MGMT(1),
        TAX_CLASS(1),
        ITEM_CAT(4),
        LOADINGGRP(4),
        VAL_CLASS(4),
        MATL_DESC(60),
        ALT_UNIT(3),
        UNIT_OF_WT(3),
        UNIT(03),
        ""Marc
        PLANT(4),
        PUR_GROUP(3),
        MRP_TYPE(2),
        MRP_CTRLER(3),
        PLND_DELRY(4),
        GR_PR_TIME(4),
        PERIOD_IND(1),
        LOTSIZEKEY(2),
        PROC_TYPE(1),
        REORDER_PT(15),
        AVAILCHECK(2),
        PROFIT_CTR(10),
        SERNO_PROF(4),
        CTRL_CODE(16),
        LOT_SIZE(15),
        ""MPOPRT
        MODEL_SP(1),
        INITIALIZE(1),
        TRACKLIMIT(7),
        HIST_VALS(4),
        FORE_PDS(4),
        STGE_LOC(4),
        "E1BPE1MBEWRT
        VAL_AREA(4),
        PRICE_CTRL(1),
        MOVING_PR(25),
        STD_PRICE(25),
        PRICE_UNIT(6),
        PR_CTRL_PP(1),
        MOV_PR_PP(25),
        STD_PR_PP(25),
        PR_UNIT_PP(6),
        VCLASS_PP(4),
        PR_CTRL_PY(1),
        MOV_PR_PY(25),
        STD_PR_PY(25),
        PR_UNIT_PY(6),
        VCLASS_PY(4),
        ML_ACTIVE(1),
        ML_SETTLE(1),
        "E1BPE1MLANRT,
        DEPCOUNTRY(3),
        TAX_TYPE_1(4),
        TAXCLASS_1(1),
        TAX_TYPE_2(4),
        TAXCLASS_2(1),
        TAX_TYPE_3(4),
        TAXCLASS_3(1),
        "E1BPE1MVKERT
        SALES_ORG(4),
        DISTR_CHAN(2),
        CASH_DISC(1),
        ACCT_ASSGT(2),
        LI_PROC_ST(2),
        LI_PROC_DC(2),
        ASSORTLIST(1),
      END OF TA_FLATFILE,
      TA_T_FLATFILE TYPE STANDARD TABLE OF TA_FLATFILE.

TYPES:BEGIN OF TY_DISPLAY,
        MATERIAL   TYPE MATNR,
        TYPE       TYPE BAPI_MTYPE,
        ID         TYPE SYMSGID,
        NUMBER     TYPE SYMSGNO,
        MESSAGE_V1 TYPE MARA-MATNR,
        MESSAGE	   TYPE BAPI_MSG,
      END OF TY_DISPLAY,
      TY_T_DISPLAY TYPE TABLE OF TY_DISPLAY.

DATA:FNAME TYPE LOCALFILE,
     ENAME TYPE CHAR4.
DATA:IT_DISPLAY    TYPE TY_T_DISPLAY.
DATA:TA_FLATFILE   TYPE TA_T_FLATFILE.
DATA:TA_FLATFILE1  TYPE TA_T_FLATFILE.
DATA:TA_FLATFILE2  TYPE TA_T_FLATFILE.
DATA:TA_FLATFILE3  TYPE TA_T_FLATFILE.

DATA:WA_DISPLAY TYPE TY_DISPLAY,
     SERVICE    TYPE BAPISRV_ASMD-SERVICE.

FIELD-SYMBOLS:<FS_FLATFILE>  TYPE TA_FLATFILE,
              <FS_FLATFILE1> TYPE TA_FLATFILE,
              <FS_FLATFILE2> TYPE TA_FLATFILE,
              <FS_FLATFILE3> TYPE TA_FLATFILE.

DATA: LD_WORKFLOW_RESULT       TYPE BDWF_PARAM-RESULT,
      LD_APPLICATION_VARIABLE	 TYPE BDWF_PARAM-APPL_VAR,
      LD_IN_UPDATE_TASK	       TYPE BDWFAP_PAR-UPDATETASK,
      LD_CALL_TRANSACTION_DONE TYPE BDWFAP_PAR-CALLTRANS,
      IT_IDOC_CONTRL           TYPE STANDARD TABLE OF EDIDC, "TABLES PARAM
      WA_IDOC_CONTRL           LIKE LINE OF IT_IDOC_CONTRL,
      IT_IDOC_DATA             TYPE STANDARD TABLE OF EDIDD, "TABLES PARAM
      WA_IDOC_DATA             LIKE LINE OF IT_IDOC_DATA,
      IT_IDOC_STATUS           TYPE STANDARD TABLE OF BDIDOCSTAT, "TABLES PARAM
      WA_IDOC_STATUS           LIKE LINE OF IT_IDOC_STATUS,
      IT_RETURN_VARIABLES	     TYPE STANDARD TABLE OF BDWFRETVAR, "TABLES PARAM
      WA_RETURN_VARIABLES	     LIKE LINE OF IT_RETURN_VARIABLES,
      IT_SERIALIZATION_INFO	   TYPE STANDARD TABLE OF BDI_SER, "TABLES PARAM
      WA_SERIALIZATION_INFO	   LIKE LINE OF IT_SERIALIZATION_INFO.
