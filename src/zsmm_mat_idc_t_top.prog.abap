*&---------------------------------------------------------------------*
*& Include          ZMM_MAT_IDC_T_TOP
*&---------------------------------------------------------------------*

 TYPES:BEGIN OF TA_FLATFILE,
         SLNO(6),
         FLAG(1),  " G - Generic / S - Single   " Added Suri : 10.09.2019
         MATERIAL(40),
         MATL_DESC(60),
*         MATL_TYPE(4),
         MATL_GROUP(9),
         MATL_CAT(2),
         CHAR_PROF(18),
         CONFIG_CLASS_TYPE(3),
         VARIANT_LONG(40),
         BATCH_MGMT(1),
         """colour
         CHAR_NAME(30),
         CHAR_VALUE_LONG(70),
*    CHAR_VAL_char(70),
         """SiZe
         CHAR_NAME1(30),
         CHAR_VALUE_LONG1(70),
*    CHAR_VAL_char1(70),
         """Inseam
**    CHAR_NAME2(30),
**    CHAR_VALUE_LONG2(70),
*    CHAR_VAL_char2(70),
*    BASIC_VIEW(1),
         BASE_UOM(3),

         "BASIC DATA 1f
         AUOM(3),
         NUMERATOR(6),
         DENOMINATR(6),
**    LUN(3),
         EAN_UPC(18),
         CATEGORY(2),
         GROSSWT(15),
         NETWEIGHT(15),
         WT(15),
***    LENGTH(15),
***    WIDTH(15),
***    HEIGHT(15),
***    UNItdim(3),
***    VOLUME(15),
***    volumeunit(3),
***    FREE_CHAR(18),
         BRAND_ID(4),
         PROD_HIER(18),
**    FIBER_CODE_1(3),
**    FIBER_PART_1(3),
**    FIBER_CODE_2(3),
**    FIBER_PART_2(3),
**    FIBER_CODE_3(3),
**    FIBER_PART_3(3),
**    FIBER_CODE_4(3),
**    FIBER_PART_4(3),
**    FIBER_CODE_5(3),
**    FIBER_PART_5(3),
*         DIVISION(2),
*         PRPROFVAR(1),
*    ALLOW_PMAT_IGNO(1),
*         TAX_CLASS(1),
*         VAL_CLASS(4),
*    COUNTRYORI(3),
*         LOADINGGRP(4),
*    TRANS_GRP(4),
*    MAT_GRP_SM(4),
*         ITEM_CAT(4),

         ""BASIC DATA FASHION
*    SGT_CSGR(4),
*    EXTMATLGRP(18),"452
         FASHION_GRADE(4),
*    SGT_COVSA(8),
*    FSH_SC_MID(2),
         FSH_MG_ATTRIBUTE1(10),
         FSH_MG_ATTRIBUTE2(10),
         FSH_MG_ATTRIBUTE3(10),

         ""LISTING
*         SALES_ORG(4),
*         DISTR_CHAN(2),
*         LI_PROC_ST(2),
         VAL_CAT(1),
***    ASSORT_LEV(2),
*    LI_PROC_DC(2),

         ""Purchasing


         ""SALES
**    SALES_UNIT(3),
*    SELL_ST_FR(10),
         CASH_DISC(1),
*         ITEM_CAT1(4),
         ACCT_ASSGT(2),


         ""LOGISTICS DC1
*    MRP_TYPE(2),
*    MRP_CTRLER(3),
*    LOT_size(2),
*    REORDER_PT(15),
*    MIN_SAFETY_STK(15),
*    MAX_STOCK(15),
*    PROC_TYPE(1),
*    SPPROCTYPE(2),
*    ISS_ST_LOC(4),
*    STGE_LOC(4),
*    PLAN_STRGP(2),
*    PLND_DELRY(4),
*    GR_PR_TIME(4),
*    MRP_GROUP(4),
*    UNDER_TOL(5),
*    OVER_TOL(5),
*    PRODUCTION_SCHEDULER(3),
*    PROD_PROF(6),
*    SERNO_PROF(4),
*    PROFIT_CTR(10),
         CTRL_CODE(16),

         ""LOGISTIC DC2
*         AVAILCHECK(2),


         ""LOGISTICS DC FASHION
*    SGT_COVSA(8),
**    DEFAULT_STOCK_SEGMENT(18),

         """others
**    SAFETY_STK(15),
**    PERIOD_IND(1),
*    LOT_size(2),
*    PROC_TYPE(1),
**    BACKFLUSH(1),
**    SLOC_EXPRC(4),
**    BATCHENTRY(1),
**    DEP_REQ_ID(1),
**    SM_KEY(3),
**    INHSEPRODT(4),
         ""account
*         VAL_CLASS1(6),
         MOVING_PR(25),
**    STD_PRICE(25),
**    PRICE_UNIT(6),
**    PRICE_CTRL(1),
**    ML_SETTLE(1),
*    *MOV_PR_pp(25),
*    *STD_PR_Pp(25),
*    *PR_UNIT_Pp(6),
*    *MOV_PR_py(25),
*    *STD_PR_Py(25),
*    *PR_UNIT_Py(6),
**    OVERHEAD_GRP(10),
**    VARIANCE_KEY(6),
**    WITH_QTY_STRUCT(1),

*         PLANT(4),
*    ORIG_MAT(1),
****Additional fields

         ZZLABEL_DESC(40),
         ZZIVEND_DESC(40),
         ZZEMP_CODE(8),
         ZZEMP_PER(6),
         ZZPO_ORDER_TXT(80),
         ZZDISC_ALLOW(1),
         ZZISEXCHANGE(1),
         ZZISNONSTOCK(1),
         ZZISREFUND(1),
         ZZISSALEABLE(1),
         ZZISWEIGHED(1),
         ZZISVALID(1),
         ZZISTAXEXEMPT(1),
         ZZISOPENPRICE(1),
         ZZISOPENDESC(1),
         ZZISINCTAX(1),
         ZZRET_DAYS(3),
         ZZARTICLE(60),
         ZZPRICE_FRM(8),
         ZZPRICE_TO(8),
         ZZSTYLE(40),

       END OF TA_FLATFILE,
       TA_T_FLATFILE TYPE STANDARD TABLE OF TA_FLATFILE.


 TYPES:BEGIN OF TY_DISPLAY,
         SLNO       TYPE CHAR6,
         MATERIAL   TYPE MATNR,
         TYPE       TYPE BAPI_MTYPE,
         ID         TYPE SYMSGID,
         NUMBER     TYPE SYMSGNO,
         MESSAGE_V1 TYPE MARA-MATNR,
         MESSAGE    TYPE BAPI_MSG,
       END OF TY_DISPLAY,
       TY_T_DISPLAY TYPE TABLE OF TY_DISPLAY.

 DATA:FNAME TYPE LOCALFILE,
      ENAME TYPE CHAR4.
 DATA:IT_DISPLAY TYPE TY_T_DISPLAY.
 DATA:TA_FLATFILE    TYPE TA_T_FLATFILE.
 DATA:TA_FLATFILE1   TYPE TA_T_FLATFILE.
 DATA:TA_FLATFILE2   TYPE TA_T_FLATFILE.
 DATA:TA_FLATFILE3   TYPE TA_T_FLATFILE.

 DATA:WA_DISPLAY TYPE TY_DISPLAY.
 FIELD-SYMBOLS:<FS_FLATFILE>  TYPE TA_FLATFILE,
               <FS_FLATFILE1> TYPE TA_FLATFILE,
               <FS_FLATFILE2> TYPE TA_FLATFILE,
               <FS_FLATFILE3> TYPE TA_FLATFILE,
               <FS_STEUERTAB> TYPE MG03STEUER.

 DATA :IT_IDOC_CONTRL        TYPE TABLE OF EDIDC WITH HEADER LINE,
       WA_IDOC_CONTRL        TYPE EDIDC,
       IT_IDOC_DATA          TYPE TABLE OF EDIDD,
       WA_IDOC_DATA          TYPE EDIDD,
       IT_IDOC_STATUS        TYPE TABLE OF BDIDOCSTAT,
       WA_IDOC_STATUS        TYPE BDIDOCSTAT,
       IT_RETURN_VARIABLES   TYPE TABLE OF BDWFRETVAR,
       WA_RETURN_VARIABLES   TYPE BDWFRETVAR,
       IT_SERIALIZATION_INFO TYPE TABLE OF BDI_SER,
       WA_SERIALIZATION_INFO TYPE BDI_SER.


 CONSTANTS:MATL_TYPE(4)  TYPE C VALUE 'HAWA',
           DIVISION(2)   TYPE C VALUE '10',
           PRPROFVAR(1)  TYPE C VALUE ' ',
           TAX_CLASS(1)  TYPE C VALUE '0',
           VAL_CLASS(4)  TYPE C VALUE '3100',
           LOADINGGRP(4) TYPE C VALUE '0001',
           ITEM_CAT(4)   TYPE C VALUE 'NORM',
           SALES_ORG(4)  TYPE C VALUE '1000',
           DISTR_CHAN(2) TYPE C VALUE '10',
           LI_PROC_ST(2) TYPE C VALUE '02',
           ITEM_CAT1(4)  TYPE C VALUE 'NORM',
           AVAILCHECK(2) TYPE C VALUE '01',
           VAL_CLASS1(6) TYPE C VALUE '3100',
           TRANS_GRP(4)  TYPE C VALUE '0001'.
