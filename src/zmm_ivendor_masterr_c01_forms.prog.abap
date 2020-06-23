*&---------------------------------------------------------------------*
*& Include          ZMM_IVENDOR_MASTERR_C01_FORMS
*&---------------------------------------------------------------------*

FORM GET_FILENAME  CHANGING FP_P_FILE TYPE LOCALFILE.

  DATA: LI_FILETABLE    TYPE FILETABLE,
        LX_FILETABLE    TYPE FILE_TABLE,
        LV_RETURN_CODE  TYPE I,
        LV_WINDOW_TITLE TYPE STRING.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE            = LV_WINDOW_TITLE
*     DEFAULT_EXTENSION       =
*     DEFAULT_FILENAME        =
*     FILE_FILTER             =
*     WITH_ENCODING           =
*     INITIAL_DIRECTORY       =
*     MULTISELECTION          =
    CHANGING
      FILE_TABLE              = LI_FILETABLE
      RC                      = LV_RETURN_CODE
*     USER_ACTION             =
*     FILE_ENCODING           =
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      OTHERS                  = 5.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  READ TABLE   LI_FILETABLE INTO LX_FILETABLE INDEX 1.
  FP_P_FILE = LX_FILETABLE-FILENAME.


  SPLIT FP_P_FILE AT '.' INTO FNAME ENAME.
  SET LOCALE LANGUAGE SY-LANGU.
  TRANSLATE ENAME TO UPPER CASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_TA_FLATFILE  text
*----------------------------------------------------------------------*
FORM GET_DATA  CHANGING TA_FLATFILE TYPE TA_T_FLATFILE.

  DATA : LI_TEMP   TYPE TABLE OF ALSMEX_TABLINE,
         LW_TEMP   TYPE ALSMEX_TABLINE,
         LW_INTERN TYPE  KCDE_CELLS,
         LI_INTERN TYPE STANDARD TABLE OF KCDE_CELLS,
         LV_INDEX  TYPE I,
         I_TYPE    TYPE TRUXS_T_TEXT_DATA.

  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.

    REFRESH TA_FLATFILE[].

    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
*       I_FIELD_SEPERATOR    =
*       I_LINE_HEADER        =
        I_TAB_RAW_DATA       = I_TYPE
        I_FILENAME           = P_FILE
      TABLES
        I_TAB_CONVERTED_DATA = TA_FLATFILE[]
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.

    DELETE TA_FLATFILE FROM 1 TO 3.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.
    MESSAGE E398(00) WITH 'Invalid File Type'.
  ENDIF.

  IF TA_FLATFILE IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_VENDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD_VENDOR .


  DATA:IT_RET1          TYPE TABLE OF BAPIRET2,

       IT_VENDORS       TYPE VMDS_EI_EXTERN_T,
       WA_VENDORS       TYPE VMDS_EI_EXTERN,

       LT_BANK          TYPE CVIS_EI_BANKDETAIL_T,
       BANK             TYPE CVIS_EI_CVI_BANKDETAIL,

       IT_COMPANY       TYPE VMDS_EI_COMPANY_T,
       WA_COMPANY       TYPE VMDS_EI_COMPANY,

       WA_COMPANY_DATA  TYPE VMDS_EI_VMD_COMPANY,

       LT_DUNN          TYPE VMDS_EI_DUNNING_T,
       DUNN             TYPE VMDS_EI_DUNNING,

       LT_TAX           TYPE VMDS_EI_WTAX_TYPE_T,
       TAX              TYPE VMDS_EI_WTAX_TYPE,

       IT_COMPANY_DATA  TYPE VMDS_EI_VMD_COMPANY,
       LS_PURCHASE_DATA TYPE VMDS_EI_VMD_PURCHASING,

       IT_PURCHASE      TYPE VMDS_EI_PURCHASING_T,
       WA_PURCHASE      TYPE VMDS_EI_PURCHASING,
       IT_PARTNER_FUNC  TYPE VMDS_EI_FUNCTIONS_T,
       WA_PARTNER_FUNC  TYPE VMDS_EI_FUNCTIONS,

       DATA_CORRECT     TYPE VMDS_EI_MAIN,
       MSG_CORRECT      TYPE CVIS_MESSAGE,
       DATA_DEFECT      TYPE VMDS_EI_MAIN,
       MSG_DEFECT       TYPE CVIS_MESSAGE,
       GIT_FINAL        TYPE VMDS_EI_MAIN,
       WA_RETU          TYPE BAPIRET2,
       RET              TYPE BAPIRET2_T,

       LV_DATE(8).

  TYPES:BEGIN OF TY_BUT000,
          PARTNER	 TYPE BU_PARTNER,
          BU_SORT1 TYPE BU_SORT1,
        END OF TY_BUT000,
        TY_T_BUT000 TYPE TABLE OF TY_BUT000.

  DATA:IT_BUT000 TYPE TY_T_BUT000,
       WA_BUT000 TYPE TY_BUT000.



  LOOP AT TA_FLATFILE ASSIGNING <FS_FLATFILE>.
    IF <FS_FLATFILE> IS ASSIGNED.
      TRANSLATE <FS_FLATFILE>-SORT1 TO UPPER CASE.

      PARTNER = <FS_FLATFILE>-BU_PARTNER.
      PARTNERCATEGORY = <FS_FLATFILE>-ORG.    " 2-Organization, 1- Person changed(from = 'X' TO = <FS_FLATFILE>-ORG.) by ibr on 06.04.2019
      PARTNERGROUP    = <FS_FLATFILE>-CREATION_GROUP. " Externel No. or Internel No.

      CENTRALDATA-TITLE_KEY            = <FS_FLATFILE>-TITLE_MEDI.
      CENTRALDATA-SEARCHTERM1          = <FS_FLATFILE>-SORT1.
      CENTRALDATA-PARTNERTYPE          = <FS_FLATFILE>-BPKIND.
      CENTRALDATA-DATAORIGINTYPE       = <FS_FLATFILE>-SOURCE.
      IF PARTNERCATEGORY = '1'.
        CENTRALDATAPERSON-FIRSTNAME = <FS_FLATFILE>-NAME_ORG1 .
        CENTRALDATAPERSON-LASTNAME = <FS_FLATFILE>-NAME_ORG2 .
        CENTRALDATAPERSON-CORRESPONDLANGUAGE = SY-LANGU ."'EN' ."<FS_FLATFILE>-NAME_ORG2 .
      ELSE .
        CENTRALDATAORGANIZATION-NAME1 = <FS_FLATFILE>-NAME_ORG1.
        CENTRALDATAORGANIZATION-NAME2 = <FS_FLATFILE>-NAME_ORG2.
        CENTRALDATAORGANIZATION-NAME3 = <FS_FLATFILE>-NAME_ORG3.
        CENTRALDATAORGANIZATION-NAME4 = <FS_FLATFILE>-NAME_ORG4.
      ENDIF.





      ADDRESSDATA-STREET     = <FS_FLATFILE>-STREET.
      ADDRESSDATA-STR_SUPPL1 = <FS_FLATFILE>-STR_SUPPL1.
      ADDRESSDATA-STR_SUPPL2 = <FS_FLATFILE>-STR_SUPPL2.
      ADDRESSDATA-STR_SUPPL3 = <FS_FLATFILE>-STR_SUPPL3.
      ADDRESSDATA-POSTL_COD1 = <FS_FLATFILE>-POST_CODE1.
      ADDRESSDATA-HOUSE_NO   = <FS_FLATFILE>-HOUSE_NUM1.
      ADDRESSDATA-CITY       = <FS_FLATFILE>-CITY1.
      ADDRESSDATA-COUNTRY    = <FS_FLATFILE>-COUNTRY.
      ADDRESSDATA-REGION     = <FS_FLATFILE>-REGION.
      ADDRESSDATA-LANGU      = <FS_FLATFILE>-LANGU.
      ADDRESSDATA-TRANSPZONE = <FS_FLATFILE>-TRANSPZONE.


      WA_TELEFONDATA-TELEPHONE = <FS_FLATFILE>-TEL_NUMBER.
      WA_TELEFONDATA-EXTENSION = <FS_FLATFILE>-TEL_EXTENS.
      APPEND WA_TELEFONDATA TO IT_TELEFONDATA.
      CLEAR WA_TELEFONDATA.

      WA_TELEFONDATA-TELEPHONE = <FS_FLATFILE>-MOB_NUMBER.
      WA_TELEFONDATA-R_3_USER  = 3.
      APPEND WA_TELEFONDATA TO IT_TELEFONDATA.
      CLEAR WA_TELEFONDATA.

*
      WA_FAXDATA-FAX       = <FS_FLATFILE>-FAX_NUMBER.
      APPEND WA_FAXDATA TO IT_FAXDATA.
      CLEAR WA_FAXDATA.

      WA_E_MAILDATA-E_MAIL = <FS_FLATFILE>-SMTP_ADDR.
      APPEND WA_E_MAILDATA TO IT_E_MAILDATA.
      CLEAR WA_E_MAILDATA.

      CALL FUNCTION 'BAPI_BUPA_FS_CREATE_FROM_DATA2'
        EXPORTING
          BUSINESSPARTNEREXTERN   = PARTNER
          PARTNERCATEGORY         = PARTNERCATEGORY
          PARTNERGROUP            = PARTNERGROUP
          CENTRALDATA             = CENTRALDATA
          CENTRALDATAPERSON       = CENTRALDATAPERSON
          CENTRALDATAORGANIZATION = CENTRALDATAORGANIZATION
          CENTRALDATAGROUP        = CENTRALDATAGROUP
          ADDRESSDATA             = ADDRESSDATA
        IMPORTING
          BUSINESSPARTNER         = PARTNER
        TABLES
          TELEFONDATA             = IT_TELEFONDATA
          FAXDATA                 = IT_FAXDATA
          E_MAILDATA              = IT_E_MAILDATA
          RETURN                  = IT_RETURN.

      IF PARTNER IS NOT INITIAL.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.

        REFRESH:IT_RET1.
        CALL FUNCTION 'BAPI_BUPA_ROLE_ADD_2'
          EXPORTING
            BUSINESSPARTNER             = PARTNER
            BUSINESSPARTNERROLECATEGORY = 'FLVN00'
            VALIDFROMDATE               = SY-DATUM
            VALIDUNTILDATE              = '99991231'
          TABLES
            RETURN                      = IT_RET1.


        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.

        REFRESH:IT_RET1.

        CALL FUNCTION 'BAPI_BUPA_ROLE_ADD_2'
          EXPORTING
            BUSINESSPARTNER             = PARTNER
            BUSINESSPARTNERROLECATEGORY = 'FLVN01'
            VALIDFROMDATE               = SY-DATUM
            VALIDUNTILDATE              = '99991231'
          TABLES
            RETURN                      = IT_RET1.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.


        REFRESH:IT_RET1.

        READ TABLE IT_RETURN INTO WA_RETURN WITH KEY TYPE = 'S'.
        LV_SLNO = LV_SLNO + 1 .
        WA_DISPLAY-SLNO = LV_SLNO .
        WA_DISPLAY-ID      = WA_RETURN-TYPE.
        WA_DISPLAY-ROLE    = '000000'.
        WA_DISPLAY-BP_NUM  = PARTNER.
        WA_DISPLAY-MESSAGE = WA_RETURN-MESSAGE.
        APPEND WA_DISPLAY TO IT_DISPLAY.
        CLEAR:WA_DISPLAY,WA_RETURN.

*********************************************************
        WAIT UP TO 1 SECONDS.
        DATA :EV_LIFNR TYPE  LIFNR,
              ES_ERROR TYPE  CVIS_MESSAGE.
*
*          CALL METHOD vmd_ei_api=>get_number
*            EXPORTING
*              iv_ktokk = <fs_flatfile>-creation_group "'ZDOM'
*            IMPORTING
*              ev_lifnr = ev_lifnr
*              es_error = es_error.

        EV_LIFNR = PARTNER.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = EV_LIFNR
          IMPORTING
            OUTPUT = EV_LIFNR.

*************************************************************

        WA_VENDORS-HEADER-OBJECT_TASK = 'M'.
        WA_VENDORS-HEADER-OBJECT_INSTANCE = EV_LIFNR.

        WA_VENDORS-CENTRAL_DATA-CENTRAL-DATA-KTOKK       = <FS_FLATFILE>-CREATION_GROUP. "'ZDOM'.      "Vendor account group  0001
        WA_VENDORS-CENTRAL_DATA-CENTRAL-DATA-KONZS       = <FS_FLATFILE>-KONZS.
        WA_VENDORS-CENTRAL_DATA-CENTRAL-DATA-SPERZ       = <FS_FLATFILE>-SPERZ.
        WA_VENDORS-CENTRAL_DATA-CENTRAL-DATA-PLKAL       = <FS_FLATFILE>-CALENDARID.
        WA_VENDORS-CENTRAL_DATA-CENTRAL-DATA-FITYP        = <FS_FLATFILE>-FITYP.
        WA_VENDORS-CENTRAL_DATA-CENTRAL-DATA-FISKN        = <FS_FLATFILE>-FISKN.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = WA_VENDORS-CENTRAL_DATA-CENTRAL-DATA-FISKN
          IMPORTING
            OUTPUT = WA_VENDORS-CENTRAL_DATA-CENTRAL-DATA-FISKN.




        IF NOT WA_VENDORS-CENTRAL_DATA-CENTRAL-DATA-KONZS  IS INITIAL.
          WA_VENDORS-CENTRAL_DATA-CENTRAL-DATAX-KONZS        = 'X'.
        ENDIF.
        IF NOT WA_VENDORS-CENTRAL_DATA-CENTRAL-DATA-SPERZ IS INITIAL.
          WA_VENDORS-CENTRAL_DATA-CENTRAL-DATAX-SPERZ        = 'X'.
        ENDIF.
        IF NOT WA_VENDORS-CENTRAL_DATA-CENTRAL-DATA-PLKAL  IS INITIAL.
          WA_VENDORS-CENTRAL_DATA-CENTRAL-DATAX-PLKAL        = 'X'.
        ENDIF.

        IF NOT WA_VENDORS-CENTRAL_DATA-CENTRAL-DATA-FITYP IS INITIAL.
          WA_VENDORS-CENTRAL_DATA-CENTRAL-DATAX-FITYP        = 'X'.
        ENDIF.
        IF NOT WA_VENDORS-CENTRAL_DATA-CENTRAL-DATA-FISKN IS INITIAL.
          WA_VENDORS-CENTRAL_DATA-CENTRAL-DATAX-FISKN        = 'X'.
        ENDIF.


        WA_COMPANY-TASK                    = 'M'.
        WA_COMPANY-DATA_KEY-BUKRS = <FS_FLATFILE>-BUKRS.

*          wa_company_DATA-CURRENT_STATE = 'X'.

        WA_COMPANY-DATA-AKONT = <FS_FLATFILE>-AKONT.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = WA_COMPANY-DATA-AKONT
          IMPORTING
            OUTPUT = WA_COMPANY-DATA-AKONT.
        WA_COMPANY-DATA-LNRZE = <FS_FLATFILE>-LNRZE.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = WA_COMPANY-DATA-LNRZE
          IMPORTING
            OUTPUT = WA_COMPANY-DATA-LNRZE.
        WA_COMPANY-DATA-ZUAWA = <FS_FLATFILE>-ZUAWA.
*      wa_company-data-begru = <fs_flatfile>-begru.
        WA_COMPANY-DATA-FDGRV = <FS_FLATFILE>-FDGRV.
*      wa_company-data-frgrp = <fs_flatfile>-frgrp.
        WA_COMPANY-DATA-QSSKZ = <FS_FLATFILE>-QSSKZ.

        WA_COMPANY-DATA-QLAND = <FS_FLATFILE>-QLAND.
        WA_COMPANY-DATA-QSREC = <FS_FLATFILE>-QSREC.
        WA_COMPANY-DATA-QSZNR = <FS_FLATFILE>-QSZNR.
*        wa_company-data-qszdt = <fs_flatfile>-qszdt.
*
*        CLEAR lv_date.
*        CONCATENATE <fs_flatfile>-qszdt+6(4) <fs_flatfile>-qszdt+3(2) <fs_flatfile>-qszdt+0(2) INTO lv_date.
*        wa_company-data-qszdt = lv_date.
*        CLEAR lv_date.
*      wa_company-data-qsbgr = <fs_flatfile>-qsbgr.
        WA_COMPANY-DATA-XAUSZ = <FS_FLATFILE>-XAUSZ.
        WA_COMPANY-DATA-ZTERM = <FS_FLATFILE>-ZTERM.
        WA_COMPANY-DATA-GUZTE = <FS_FLATFILE>-GUZTE.
*      wa_company-data-togru = <fs_flatfile>-togru.
        WA_COMPANY-DATA-REPRF = <FS_FLATFILE>-REPRF.
        WA_COMPANY-DATA-ZWELS = <FS_FLATFILE>-ZWELS.
        WA_COMPANY-DATA-ZAHLS = <FS_FLATFILE>-ZAHLS.
*      wa_company-data-lnrzb = <fs_flatfile>-lnrzb.
*      wa_company-data-webtr = <fs_flatfile>-webtr.
        WA_COMPANY-DATA-XVERR = <FS_FLATFILE>-XVERR.
*      wa_company-data-xedip = <fs_flatfile>-xedip.
*      wa_company-data-togrr = <fs_flatfile>-togrr.
        IF WA_COMPANY-DATA-AKONT IS NOT INITIAL.
          WA_COMPANY-DATAX-AKONT = 'X'.
        ENDIF.
        IF NOT WA_COMPANY-DATA-LNRZE IS INITIAL.
          WA_COMPANY-DATAX-LNRZE = 'X'.
        ENDIF.
        IF NOT WA_COMPANY-DATA-ZUAWA IS INITIAL.
          WA_COMPANY-DATAX-ZUAWA = 'X'.
        ENDIF.
*        wa_company-datax-begru = 'X'.
        IF NOT WA_COMPANY-DATA-FDGRV IS INITIAL.
          WA_COMPANY-DATAX-FDGRV = 'X'.
        ENDIF.
*        wa_company-datax-frgrp = 'X'.
        IF NOT WA_COMPANY-DATA-QSSKZ IS INITIAL.
          WA_COMPANY-DATAX-QSSKZ = 'X'.
        ENDIF.
        IF NOT WA_COMPANY-DATA-QLAND IS INITIAL.
          WA_COMPANY-DATAX-QLAND = 'X'.
        ENDIF.
        IF NOT WA_COMPANY-DATA-QSREC IS INITIAL.
          WA_COMPANY-DATAX-QSREC = 'X'.
        ENDIF.
        IF NOT WA_COMPANY-DATA-QSREC IS INITIAL.
          WA_COMPANY-DATAX-QSZNR = 'X'.
        ENDIF.
*        wa_company-datax-qszdt = 'X'.
*        wa_company-datax-qsbgr = 'X'.
        IF NOT WA_COMPANY-DATA-XAUSZ IS INITIAL.
          WA_COMPANY-DATAX-XAUSZ = 'X'.
        ENDIF.
        IF NOT WA_COMPANY-DATA-ZTERM IS INITIAL.
          WA_COMPANY-DATAX-ZTERM = 'X'.
        ENDIF.
        IF NOT WA_COMPANY-DATA-GUZTE IS INITIAL.
          WA_COMPANY-DATAX-GUZTE = 'X'.
        ENDIF.
*        wa_company-datax-togru = 'X'.
        IF NOT WA_COMPANY-DATA-REPRF IS INITIAL.
          WA_COMPANY-DATAX-REPRF = 'X'.
        ENDIF.
        IF NOT WA_COMPANY-DATA-ZWELS IS INITIAL.
          WA_COMPANY-DATAX-ZWELS = 'X'.
        ENDIF.
        IF NOT WA_COMPANY-DATA-ZAHLS IS INITIAL.
          WA_COMPANY-DATAX-ZAHLS = 'X'.
        ENDIF.
*        wa_company-datax-lnrzb = 'X'.
*        wa_company-datax-webtr = 'X'.
        IF NOT WA_COMPANY-DATA-XVERR IS INITIAL.
          WA_COMPANY-DATAX-XVERR = 'X'.
        ENDIF.
****************************

        IF NOT <FS_FLATFILE>-WITHT IS INITIAL.
          TAX-TASK           = 'M'.
        ENDIF.

        TAX-DATA_KEY-WITHT = <FS_FLATFILE>-WITHT.""""added by thippesh
        TAX-DATA-WT_WITHCD = <FS_FLATFILE>-WT_WITHCD.
        TAX-DATA-WT_SUBJCT = <FS_FLATFILE>-WT_SUBJCT.
        TAX-DATA-QSREC     = <FS_FLATFILE>-QSREC1.

        IF NOT TAX-DATA-WT_WITHCD IS INITIAL.
          TAX-DATAX-WT_WITHCD = 'X'.
        ENDIF.
        IF NOT TAX-DATA-WT_SUBJCT IS INITIAL.
          TAX-DATAX-WT_SUBJCT = 'X'.
        ENDIF.
        IF NOT TAX-DATA-WT_WTSTCD IS  INITIAL.
          TAX-DATAX-WT_WTSTCD = 'X'.
        ENDIF.
        IF NOT TAX-DATA-QSREC  IS INITIAL.
          TAX-DATAX-QSREC     = 'X'.
        ENDIF.

        IF NOT TAX IS INITIAL.
          APPEND TAX TO LT_TAX[].
          CLEAR TAX.
        ENDIF.

        IF NOT <FS_FLATFILE>-WITHT1 IS INITIAL.
          TAX-TASK           = 'M'.
        ENDIF.

        TAX-DATA_KEY-WITHT = <FS_FLATFILE>-WITHT1.
        TAX-DATA-WT_WITHCD = <FS_FLATFILE>-WT_WITHCD1.
        TAX-DATA-WT_SUBJCT = <FS_FLATFILE>-WT_SUBJCT1.
        TAX-DATA-QSREC     = <FS_FLATFILE>-QSREC2.

        IF NOT TAX-DATA-WT_WITHCD IS INITIAL.
          TAX-DATAX-WT_WITHCD = 'X'.
        ENDIF.
        IF NOT TAX-DATA-WT_SUBJCT IS INITIAL.
          TAX-DATAX-WT_SUBJCT = 'X'.
        ENDIF.
        IF NOT TAX-DATA-WT_WTSTCD IS INITIAL.
          TAX-DATAX-WT_WTSTCD = 'X'.
        ENDIF.
        IF NOT TAX-DATA-QSREC  IS INITIAL.
          TAX-DATAX-QSREC     = 'X'.
        ENDIF.

        IF NOT TAX IS INITIAL.
          APPEND TAX TO LT_TAX[].
          CLEAR TAX.
        ENDIF.
        IF LT_TAX IS NOT INITIAL.
          WA_COMPANY-WTAX_TYPE-WTAX_TYPE = LT_TAX[].
        ENDIF.
        """""""""""""""""""end of changes
        APPEND WA_COMPANY TO IT_COMPANY.
*          it_company_data-CURRENT_STATE = 'X'.
        IT_COMPANY_DATA-COMPANY = IT_COMPANY[].
        WA_VENDORS-COMPANY_DATA = IT_COMPANY_DATA.
*********
        WA_PURCHASE-TASK                   = 'M'.
        WA_PURCHASE-DATA_KEY-EKORG = <FS_FLATFILE>-EKORG.

*          wa_purchase-CURRENT_STATE = 'X'.
*******
        WA_PURCHASE-DATA-ZTERM          = <FS_FLATFILE>-ZTERM.
        WA_PURCHASE-DATA-WAERS          = <FS_FLATFILE>-WAERS.
*      wa_purchase-data-minbw          = <fs_flatfile>-minbw.
        WA_PURCHASE-DATA-INCO1          = <FS_FLATFILE>-INCO1.
        WA_PURCHASE-DATA-INCO2_L        = <FS_FLATFILE>-INCO2_L.
        WA_PURCHASE-DATA-INCO3_L        = <FS_FLATFILE>-INCO3_L.
        WA_PURCHASE-DATA-VERKF          = <FS_FLATFILE>-VERKF.
        WA_PURCHASE-DATA-TELF1          = <FS_FLATFILE>-TELF1.
        WA_PURCHASE-DATA-LFABC          = <FS_FLATFILE>-LFABC.
        WA_PURCHASE-DATA-VSBED          = <FS_FLATFILE>-VSBED.
        WA_PURCHASE-DATA-WEBRE          = <FS_FLATFILE>-WEBRE.
        WA_PURCHASE-DATA-NRGEW          = <FS_FLATFILE>-NRGEW.
        WA_PURCHASE-DATA-LEBRE          = <FS_FLATFILE>-LEBRE.
*      wa_purchase-data-vendor_rma_req = <fs_flatfile>-vendor_rma_req.
*      wa_purchase-data-prfre          = <fs_flatfile>-prfre.
*      wa_purchase-data-boind          = <fs_flatfile>-boind.
*      wa_purchase-data-blind          = <fs_flatfile>-blind.
*      wa_purchase-data-xersr          = <fs_flatfile>-xersr.
        WA_PURCHASE-DATA-KZABS          = <FS_FLATFILE>-KZABS.
*        wa_purchase-data-expvz          = <fs_flatfile>-expvz.
        WA_PURCHASE-DATA-EKGRP          = <FS_FLATFILE>-EKGRP.
        WA_PURCHASE-DATA-PLIFZ          = <FS_FLATFILE>-PLIFZ.
*      wa_purchase-data-agrel          = <fs_flatfile>-agrel.
*      wa_purchase-data-loevm          = <fs_flatfile>-loevm.
        WA_PURCHASE-DATA-KALSK          = <FS_FLATFILE>-KALSK.
*      wa_purchase-data-kzaut          = <fs_flatfile>-kzaut.
*      wa_purchase-data-xersy          = <fs_flatfile>-xersy.
        WA_PURCHASE-DATA-MEPRF          = <FS_FLATFILE>-MEPRF.
*      wa_purchase-data-sperm          = <fs_flatfile>-sperm.
        WA_PURCHASE-DATA-BSTAE          = <FS_FLATFILE>-BSTAE.
*      wa_purchase-data-kzret          = <fs_flatfile>-kzret.
*      wa_purchase-data-aubel          = <fs_flatfile>-aubel.
*      wa_purchase-data-hscabs         = <fs_flatfile>-hscabs.
*      wa_purchase-data-xersy          = <fs_flatfile>-xersy1.
        WA_PURCHASE-DATA-MRPPP          = <FS_FLATFILE>-MRPPP.
*      wa_purchase-data-lipre          = <fs_flatfile>-lipre.
*      wa_purchase-data-liser          = <fs_flatfile>-liser.
*****
        IF NOT WA_PURCHASE-DATA-ZTERM  IS INITIAL.
          WA_PURCHASE-DATAX-ZTERM          = 'X'.
        ENDIF.
        IF NOT WA_PURCHASE-DATA-WAERS  IS INITIAL.
          WA_PURCHASE-DATAX-WAERS          = 'X'.
        ENDIF.

*        wa_purchase-datax-minbw          = 'X'.

        IF NOT WA_PURCHASE-DATA-INCO1  IS INITIAL.
          WA_PURCHASE-DATAX-INCO1          = 'X'.
        ENDIF.
        IF NOT WA_PURCHASE-DATA-INCO2_L  IS INITIAL.
          WA_PURCHASE-DATAX-INCO2_L        = 'X'.
        ENDIF.
        IF NOT WA_PURCHASE-DATA-INCO3_L  IS INITIAL.
          WA_PURCHASE-DATAX-INCO3_L        = 'X'.
        ENDIF.
        IF NOT WA_PURCHASE-DATA-VERKF  IS INITIAL.
          WA_PURCHASE-DATAX-VERKF          = 'X'.
        ENDIF.
        IF NOT WA_PURCHASE-DATA-TELF1  IS INITIAL.
          WA_PURCHASE-DATAX-TELF1          = 'X'.
        ENDIF.
        IF NOT WA_PURCHASE-DATA-LFABC  IS INITIAL.
          WA_PURCHASE-DATAX-LFABC          = 'X'.
        ENDIF.
        IF NOT  WA_PURCHASE-DATA-VSBED   IS INITIAL.
          WA_PURCHASE-DATAX-VSBED          = 'X'.
        ENDIF.
        IF NOT WA_PURCHASE-DATA-WEBRE  IS INITIAL.
          WA_PURCHASE-DATAX-WEBRE          = 'X'.
        ENDIF.
        IF NOT WA_PURCHASE-DATA-NRGEW   IS INITIAL.
          WA_PURCHASE-DATAX-NRGEW          = 'X'.
        ENDIF.
        IF NOT WA_PURCHASE-DATA-LEBRE  IS INITIAL.
          WA_PURCHASE-DATAX-LEBRE          = 'X'.
        ENDIF.
*         wa_purchase-datax-vendor_rma_req = 'X'.
*        wa_purchase-datax-prfre          = 'X'.
*        wa_purchase-datax-boind          = 'X'.
*        wa_purchase-datax-blind          = 'X'.
*        wa_purchase-datax-xersr          = 'X'.
        IF NOT WA_PURCHASE-DATA-KZABS  IS INITIAL.
          WA_PURCHASE-DATAX-KZABS          = 'X'.
        ENDIF.

*         wa_purchase-datax-expvz          = 'X'.
        IF NOT WA_PURCHASE-DATA-EKGRP  IS INITIAL.
          WA_PURCHASE-DATAX-EKGRP          = 'X'.
        ENDIF.
        IF NOT WA_PURCHASE-DATA-PLIFZ   IS INITIAL.
          WA_PURCHASE-DATAX-PLIFZ          = 'X'.
        ENDIF.
*        wa_purchase-datax-agrel          = 'X'.
*        wa_purchase-datax-loevm          = 'X'.
        IF NOT WA_PURCHASE-DATA-KALSK  IS INITIAL.
          WA_PURCHASE-DATAX-KALSK          = 'X'.
        ENDIF.

*        wa_purchase-datax-kzaut          = 'X'.
*        wa_purchase-datax-xersy          = 'X'.
        IF NOT WA_PURCHASE-DATA-MEPRF  IS INITIAL.
          WA_PURCHASE-DATAX-MEPRF          = 'X'.
        ENDIF.

*        wa_purchase-datax-sperm          = 'X'.
        IF NOT WA_PURCHASE-DATA-BSTAE  IS INITIAL.
          WA_PURCHASE-DATAX-BSTAE          = 'X'.
        ENDIF.

*        wa_purchase-datax-kzret          = 'X'.
*        wa_purchase-datax-aubel          = 'X'.
*        wa_purchase-datax-hscabs         = 'X'.
*        wa_purchase-datax-xersy          = 'X'.
        IF NOT WA_PURCHASE-DATA-MRPPP  IS INITIAL.
          WA_PURCHASE-DATAX-MRPPP          = 'X'.
        ENDIF.

*        wa_purchase-datax-lipre          = 'X'.
*        wa_purchase-datax-liser          = 'X'.
*****

************        ,
***        wa_partner_func-task = 'M'.
***        wa_partner_func-data_key-parvw = 'BA'."<fs_flatfile>-parvw1.
***        wa_partner_func-data-partner   = partner. "ev_lifnr.   "partner. "<fs_flatfile>-ktonr.
***        wa_partner_func-datax-partner   = 'X'.
***        APPEND wa_partner_func TO it_partner_func[].
***        CLEAR wa_partner_func.
***
***        wa_partner_func-task = 'M'.
***        wa_partner_func-data_key-parvw = 'LF'."<fs_flatfile>-parvw2.
***        wa_partner_func-data-partner   = partner. "<fs_flatfile>-ktonr.
***        wa_partner_func-datax-partner   = 'X'.
***        APPEND wa_partner_func TO it_partner_func[].
***        CLEAR wa_partner_func.
***        wa_partner_func-task = 'M'.
***        wa_partner_func-data_key-parvw = 'RS'."<fs_flatfile>-parvw3.
***        wa_partner_func-data-partner   = partner. "<fs_flatfile>-ktonr.
***        wa_partner_func-datax-partner   = 'X'.
***        APPEND wa_partner_func TO it_partner_func[].
***        CLEAR wa_partner_func.
***        wa_partner_func-task = 'M'.
***        wa_partner_func-data_key-parvw = 'WL'."<fs_flatfile>-parvw4.
***        wa_partner_func-data-partner   = partner. "<fs_flatfile>-ktonr.
***        wa_partner_func-datax-partner   = 'X'.
***        APPEND wa_partner_func TO it_partner_func[].
***        CLEAR wa_partner_func.
        WA_PURCHASE-FUNCTIONS-FUNCTIONS  = IT_PARTNER_FUNC[].
        APPEND WA_PURCHASE TO IT_PURCHASE.
*          ls_purchase_data-CURRENT_STATE = 'X'.
        LS_PURCHASE_DATA-PURCHASING = IT_PURCHASE[].
        WA_VENDORS-PURCHASING_DATA = LS_PURCHASE_DATA.
        APPEND WA_VENDORS TO IT_VENDORS.

        GIT_FINAL-VENDORS = IT_VENDORS.

        VMD_EI_API=>INITIALIZE( ).

        CALL METHOD VMD_EI_API=>MAINTAIN_BAPI
          EXPORTING
*           iv_test_run              = SPACE
            IV_COLLECT_MESSAGES      = 'X'   "SPACE
            IS_MASTER_DATA           = GIT_FINAL
          IMPORTING
            ES_MASTER_DATA_CORRECT   = DATA_CORRECT
            ES_MESSAGE_CORRECT       = MSG_CORRECT
            ES_MASTER_DATA_DEFECTIVE = DATA_DEFECT
            ES_MESSAGE_DEFECTIVE     = MSG_DEFECT.
*BREAK samburi .
        IF MSG_DEFECT-IS_ERROR IS INITIAL.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = 'X'.

          DATA:WA_BP001      TYPE BP001,
               WA_J_1IMOVEND TYPE J_1IMOVEND.
          SELECT SINGLE * FROM BP001 INTO WA_BP001 WHERE PARTNER = PARTNER.
          IF SY-SUBRC = 0.
            WA_BP001-CALENDARID = <FS_FLATFILE>-CALENDARID.
            MODIFY BP001 FROM WA_BP001.
            CLEAR WA_BP001.
          ENDIF.

          CLEAR LV_DATE.
          CONCATENATE <FS_FLATFILE>-FOUND_DAT+6(4) <FS_FLATFILE>-FOUND_DAT+3(2) <FS_FLATFILE>-FOUND_DAT+0(2) INTO LV_DATE.

          UPDATE BUT000 SET BPEXT     = <FS_FLATFILE>-BPEXT
                            FOUND_DAT = LV_DATE
                      WHERE PARTNER = PARTNER.

          ""added by THB for tax cat and number
*          data:wa_taxnum TYPE DFKKBPTAXNUM.
*
*          wa_taxnum-partner =  partner.
*          wa_taxnum-TAXTYPE = <fs_flatfile>-TAXTYPE.
*          wa_taxnum-TAXTYPE = <fs_flatfile>-TAXNUMXL.
*          MODIFY DFKKBPTAXNUM FROM wa_taxnum.

**to update identification tab for tax category and tax number* edited by thippesh*******
          PERFORM IDENTIFI_TAXCAT_TAXNUM.
          PERFORM BANK_DETAIL.
**************end************************************************************************
          CLEAR LV_DATE.
          CONCATENATE <FS_FLATFILE>-J_1IPANVALDT+6(4) <FS_FLATFILE>-J_1IPANVALDT+3(2) <FS_FLATFILE>-J_1IPANVALDT+0(2) INTO LV_DATE.

          UPDATE LFA1 SET PROFS        = <FS_FLATFILE>-PROFS
                          J_1IEXCD     = <FS_FLATFILE>-J_1IEXCD
                          J_1IEXRN     = <FS_FLATFILE>-J_1IEXRN
                          J_1IEXRG     = <FS_FLATFILE>-J_1IEXRG
                          J_1IEXDI     = <FS_FLATFILE>-J_1IEXDI
                          J_1IEXCO     = <FS_FLATFILE>-J_1IEXCO
                          J_1IVTYP     = <FS_FLATFILE>-J_1IVTYP
                          J_1I_CUSTOMS = <FS_FLATFILE>-J_1I_CUSTOMS
                          J_1IEXCIVE   = <FS_FLATFILE>-J_1IEXCIVE
                          J_1ISSIST    = <FS_FLATFILE>-J_1ISSIST
                          J_1IVENCRE   = <FS_FLATFILE>-J_1IVENCRE
                          J_1ICSTNO    = <FS_FLATFILE>-J_1ICSTNO
                          J_1ILSTNO    = <FS_FLATFILE>-J_1ILSTNO
                          J_1ISERN     = <FS_FLATFILE>-J_1ISERN
                          J_1IPANNO    = <FS_FLATFILE>-J_1IPANNO
                          VEN_CLASS    = <FS_FLATFILE>-VEN_CLASS
                          J_1IPANVALDT = LV_DATE
                    WHERE LIFNR = EV_LIFNR.

*          LOOP AT IT_DISPLAY INTO WA_DISPLAY.
*
          WA_DISPLAY-LIFNR = EV_LIFNR.
          WA_DISPLAY-SORT = <FS_FLATFILE>-SORT1.
          MODIFY IT_DISPLAY FROM WA_DISPLAY TRANSPORTING LIFNR SORT WHERE SLNO = LV_SLNO .
          CLEAR WA_DISPLAY .
*          ENDLOOP.


        ELSE.
          RET[] = MSG_DEFECT-MESSAGES[].
          LV_SLNO = LV_SLNO + 1 .
          LOOP AT RET INTO WA_RETU.
            WA_DISPLAY-SLNO = LV_SLNO.
            WA_DISPLAY-ID      = WA_RETU-TYPE.
            WA_DISPLAY-ROLE    = '000000'.
            WA_DISPLAY-MESSAGE = WA_RETU-MESSAGE.
            APPEND WA_DISPLAY TO IT_DISPLAY.
            CLEAR:WA_DISPLAY,WA_RETU.
          ENDLOOP.
          REFRESH RET[]  .
        ENDIF.

      ELSE.
        LV_SLNO = LV_SLNO + 1 .
        LOOP AT IT_RETURN INTO WA_RETURN WHERE TYPE = 'E'.
          WA_DISPLAY-SLNO = LV_SLNO.
          WA_DISPLAY-ID      = WA_RETURN-TYPE.
          WA_DISPLAY-BP_NUM  = PARTNER.
          WA_DISPLAY-MESSAGE = WA_RETURN-MESSAGE.
          WA_DISPLAY-SORT = <FS_FLATFILE>-SORT1.
          APPEND WA_DISPLAY TO IT_DISPLAY.
          CLEAR:WA_DISPLAY,WA_RETURN.
        ENDLOOP.
        REFRESH IT_RETURN .
      ENDIF.

      CLEAR:PARTNERCATEGORY,PARTNERGROUP,CENTRALDATA,CENTRALDATAPERSON,CENTRALDATAORGANIZATION,CENTRALDATAGROUP,ADDRESSDATA,EV_LIFNR,PARTNER,
            WA_VENDORS-HEADER,WA_VENDORS-CENTRAL_DATA-CENTRAL,WA_COMPANY, WA_COMPANY-DATA,IT_COMPANY,WA_COMPANY,IT_COMPANY_DATA,WA_PURCHASE,
            WA_VENDORS-COMPANY_DATA,WA_PURCHASE-DATA,IT_PURCHASE,LS_PURCHASE_DATA-PURCHASING,LS_PURCHASE_DATA,WA_VENDORS-PURCHASING_DATA,
            IT_VENDORS,GIT_FINAL-VENDORS,GIT_FINAL,DATA_CORRECT,MSG_CORRECT,DATA_DEFECT,MSG_DEFECT,LV_DATE.

      REFRESH:IT_TELEFONDATA,IT_FAXDATA,IT_E_MAILDATA,IT_RETURN,GIT_FINAL-VENDORS,IT_COMPANY,IT_VENDORS,IT_PURCHASE.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA .

  DATA :LWA_LAYOUT TYPE SLIS_LAYOUT_ALV,
        WA_FCAT    TYPE SLIS_FIELDCAT_ALV,
        IT_FCAT    TYPE SLIS_T_FIELDCAT_ALV.

  WA_FCAT-FIELDNAME = 'SLNO'.
  WA_FCAT-SELTEXT_M = 'Sl. No.'.
  WA_FCAT-TABNAME = 'IT_DISPLAY'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.


  WA_FCAT-FIELDNAME = 'ID'.
  WA_FCAT-SELTEXT_M = 'Type'.
  WA_FCAT-TABNAME = 'IT_DISPLAY'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

*  WA_FCAT-FIELDNAME = 'ROLE'.
*  WA_FCAT-SELTEXT_M = 'BP role'.
*  WA_FCAT-TABNAME = 'IT_DISPLAY'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'BP_NUM'.
  WA_FCAT-SELTEXT_M = 'Business Partner'.
  WA_FCAT-TABNAME = 'IT_DISPLAY'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'LIFNR'.
  WA_FCAT-SELTEXT_M = 'Vendor Number'.
  WA_FCAT-TABNAME = 'IT_DISPLAY'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'SORT'.
  WA_FCAT-SELTEXT_M = 'Search Term'.
  WA_FCAT-TABNAME = 'IT_DISPLAY'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'MESSAGE'.
  WA_FCAT-SELTEXT_M = 'Message'.
  WA_FCAT-TABNAME = 'IT_DISPLAY'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.


  LWA_LAYOUT-ZEBRA = 'X'.
  LWA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
*     I_CALLBACK_PROGRAM                = ' '
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE  =
*     I_GRID_SETTINGS                   =
      IS_LAYOUT     = LWA_LAYOUT
      IT_FIELDCAT   = IT_FCAT
*     IT_EXCLUDING  =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT       =
*     IT_FILTER     =
*     IS_SEL_HIDE   =
      I_DEFAULT     = 'X'
      I_SAVE        = 'X'
*     IS_VARIANT    =
*     IT_EVENTS     =
*     IT_EVENT_EXIT =
*     IS_PRINT      =
*     IS_REPREP_ID  =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0
*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   =
*     IT_HYPERLINK  =
*     IT_ADD_FIELDCAT                   =
*     IT_EXCEPT_QINFO                   =
*     IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      T_OUTTAB      = IT_DISPLAY
    EXCEPTIONS
      PROGRAM_ERROR = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_CUSTOMER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ADD_CUSTOMER  USING PAR TYPE BUT000-PARTNER.
* SALES AND DISTRIBUTION
  BREAK URAMPUR.
  DATA:LV_VKORG    TYPE VKORG,
       LV_VTWEG    TYPE VTWEG,
       LV_SPART    TYPE SPART,
       KNVV_APP_DI TYPE KNVV_APP_DI,
       IT_KNVI     TYPE TABLE OF KNVI_APP_DI,
       IT_RET      TYPE TABLE OF BUS0MSG1,
       WA_KNVI     TYPE  KNVI_APP_DI.
  .


  LV_VKORG  = <FS_FLATFILE>-VKORG.
  LV_VTWEG  = <FS_FLATFILE>-VTWEG.
  LV_SPART  = <FS_FLATFILE>-SPART.

  KNVV_APP_DI-BZIRK = <FS_FLATFILE>-BZIRK.
  KNVV_APP_DI-KONDA = <FS_FLATFILE>-KONDA.                          " Price Group
  KNVV_APP_DI-KALKS = <FS_FLATFILE>-KALKS.                          " Cust.Pric.Procedure
  KNVV_APP_DI-LPRIO = <FS_FLATFILE>-LPRIO.                          " Delivery Priority
  KNVV_APP_DI-VSBED = <FS_FLATFILE>-VSBED1.                          " Shipping conditions
  KNVV_APP_DI-WAERS_KNVV = <FS_FLATFILE>-WAERS.                          " Shipping conditions

  WA_KNVI-ALAND = 'IN'.
  WA_KNVI-TATYP = 'JOCG'.
  WA_KNVI-TAXKD = <FS_FLATFILE>-TAXKD1.                          " Tax classification
  WA_KNVI-CHIND_KNVI = 'I'.
  APPEND WA_KNVI TO IT_KNVI.
  CLEAR WA_KNVI.


  WA_KNVI-ALAND = 'IN'.
  WA_KNVI-TATYP = 'JOIG'.
  WA_KNVI-TAXKD = <FS_FLATFILE>-TAXKD2.                          " Tax classification
  WA_KNVI-CHIND_KNVI = 'I'.
  APPEND WA_KNVI TO IT_KNVI.
  CLEAR WA_KNVI.

  WA_KNVI-ALAND = 'IN'.
  WA_KNVI-TATYP = 'JOSG'.
  WA_KNVI-TAXKD = <FS_FLATFILE>-TAXKD3.                          " Tax classification
  WA_KNVI-CHIND_KNVI = 'I'.
  APPEND WA_KNVI TO IT_KNVI.
  CLEAR WA_KNVI.


  WA_KNVI-ALAND = 'IN'.
  WA_KNVI-TATYP = 'JOUG'.
  WA_KNVI-TAXKD = <FS_FLATFILE>-TAXKD4.                          " Tax classification
  WA_KNVI-CHIND_KNVI = 'I'.
  APPEND WA_KNVI TO IT_KNVI.
  CLEAR WA_KNVI.

  WA_KNVI-ALAND = 'IN'.
  WA_KNVI-TATYP = 'JCOS'.
  WA_KNVI-TAXKD = <FS_FLATFILE>-TAXKD5.                          " Tax classification
  WA_KNVI-CHIND_KNVI = 'I'.
  APPEND WA_KNVI TO IT_KNVI.
  CLEAR WA_KNVI.





*        i_bpext = <fs_flatfile>-bpext.
**************************************************
  REFRESH IT_RETURN.

  CALL FUNCTION 'FICU_BUPA_DARK_MAINTAIN_INTERN'
    EXPORTING
      I_AKTYP    = '02'        "01 Create, 02  Change, 03  Display & 06  Delete
      I_XUPDTASK = 'X'
      I_XCOMMIT  = 'X'
      I_PARTNER  = PAR
*     i_bpext    = i_bpext
      I_TYPE     = '2'
*     i_bpkind   = lv_bpkind
      I_ROLE1    = 'FLCU01'
      I_VKORG    = LV_VKORG
      I_VTWEG    = LV_VTWEG
      I_SPART    = LV_SPART
      I_KNVV     = KNVV_APP_DI
    TABLES
      T_KNVI     = IT_KNVI
      T_MESSAGE  = IT_RET.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form IDENTIFI_TAXCAT_TAXNUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM IDENTIFI_TAXCAT_TAXNUM .
  DATA:IT_TERUN TYPE TABLE OF BAPIRET2.
  DATA:LD_TAXTYPE   TYPE BAPIBUS1006TAX-TAXTYPE,
       LD_TAXNUMBER TYPE BAPIBUS1006TAX-TAXNUMBER.

*SELECT SINGLE partner FROM DFKKBPTAXNUM INTO wa_taxnum WHERE partner  = partner.
*
*if wa_taxnum IS INITIAL.

  LD_TAXTYPE   = <FS_FLATFILE>-TAXTYPE.
  LD_TAXNUMBER = <FS_FLATFILE>-TAXNUMXL.

  CALL FUNCTION 'BAPI_BUPA_TAX_ADD'
    EXPORTING
      BUSINESSPARTNER = PARTNER
      TAXTYPE         = LD_TAXTYPE
      TAXNUMBER       = LD_TAXNUMBER
    TABLES
      RETURN          = IT_TERUN.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.

  REFRESH:IT_TERUN.CLEAR:LD_TAXTYPE,LD_TAXNUMBER.
*ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BANK_DETAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BANK_DETAIL .
  DATA:IT_TERUN TYPE TABLE OF BAPIRET2.
  DATA:WA_BANKDETAIL TYPE BAPIBUS1006_BANKDETAIL.


  WA_BANKDETAIL-BANK_CTRY  = <FS_FLATFILE>-BANKS.
  WA_BANKDETAIL-BANK_KEY   = <FS_FLATFILE>-BANKL.
  WA_BANKDETAIL-BANK_ACCT  = <FS_FLATFILE>-BANKN.

  CALL FUNCTION 'BAPI_BUPA_BANKDETAIL_ADD'
    EXPORTING
      BUSINESSPARTNER = PARTNER
      BANKDETAILID    = '0001'
      BANKDETAILDATA  = WA_BANKDETAIL
*   IMPORTING
*     BANKDETAILIDOUT =
    TABLES
      RETURN          = IT_TERUN.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.

  .
  CLEAR:WA_BANKDETAIL.REFRESH:IT_TERUN.
ENDFORM.
