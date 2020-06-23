*&---------------------------------------------------------------------*
*& Include          ZFI_AS91_AB01_ABLDT_FORMS
*&---------------------------------------------------------------------*
FORM GET_DATA  CHANGING FP_I_EXCELTAB TYPE TY_T_EXCELTAB.

  DATA : LI_TEMP     TYPE TABLE OF ALSMEX_TABLINE,
         LW_TEMP     TYPE ALSMEX_TABLINE,
         LW_EXCELTAB TYPE TY_EXCELTAB,
         LV_MAT      TYPE MATNR,
         LW_INTERN   TYPE  KCDE_CELLS,
         LI_INTERN   TYPE STANDARD TABLE OF KCDE_CELLS,
         LV_INDEX    TYPE I,
         I_TYPE      TYPE TRUXS_T_TEXT_DATA.


*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.

    REFRESH FP_I_EXCELTAB[].


*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
*       I_FIELD_SEPERATOR    =
*       I_LINE_HEADER        =
        I_TAB_RAW_DATA       = I_TYPE
        I_FILENAME           = P_FILE
      TABLES
        I_TAB_CONVERTED_DATA = FP_I_EXCELTAB[]
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.

    DELETE FP_I_EXCELTAB FROM 1 TO 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.
    MESSAGE E398(00) WITH 'Invalid File Type'  .

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_I_EXCELTAB  text
*&---------------------------------------------------------------------*
FORM PROCESS_DATA USING    FP_I_EXCELTAB TYPE TY_T_EXCELTAB.

  DATA: WA_KEY          LIKE BAPI1022_KEY,
        WA_GEN          LIKE BAPI1022_FEGLG001,
        WA_GENX         LIKE BAPI1022_FEGLG001X,
        WA_POST         LIKE BAPI1022_FEGLG002,
        WA_POSTX        LIKE BAPI1022_FEGLG002X,
        WA_TIM          LIKE BAPI1022_FEGLG003,
        WA_TIMX         LIKE BAPI1022_FEGLG003X,
        WA_ORIGIN       LIKE BAPI1022_FEGLG009,
        WA_ORIGINX      LIKE BAPI1022_FEGLG009X,
        ASSETNO         LIKE BAPI1022_1-ASSETMAINO,

        COMPANYCODE     TYPE  BAPI1022_1-COMP_CODE,

        SUBNUMBER       TYPE  BAPI1022_1-ASSETSUBNO,
        ASSETCREATED    TYPE  BAPI1022_REFERENCE,
        WA_RET          LIKE BAPIRET2,
        IT_RET          LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,

        WA_DEP_AREA     TYPE  BAPI1022_DEP_AREAS,
        IT_DEP_AREA     TYPE TABLE OF BAPI1022_DEP_AREAS,
        WA_DEP_AREAX    TYPE  BAPI1022_DEP_AREASX,
        IT_DEP_AREAX    TYPE TABLE OF BAPI1022_DEP_AREASX,

        WA_CUMVAL       TYPE BAPI1022_CUMVAL,
        IT_CUMVAL       TYPE TABLE OF BAPI1022_CUMVAL,
        WA_POSTEDVALUES TYPE BAPI1022_POSTVAL,
        IT_POSTEDVALUES TYPE TABLE OF BAPI1022_POSTVAL,

        IT_TRANSACTIONS TYPE TABLE OF BAPI1022_TRTYPE,
        WA_TRANSACTIONS TYPE BAPI1022_TRTYPE,

        LV_SNO          TYPE I VALUE 2,
        LV_DATC         TYPE CHAR2,
        LV_DAT          TYPE NUMC2,
        LV_MONC         TYPE CHAR2,
        LV_MON          TYPE NUMC2,
        LV_YEAR         TYPE CHAR4,
        LV_DATE         TYPE CHAR8,
        LV_INIACQ       TYPE CHAR8,
        LV_POSDATE      TYPE CHAR8,
*        LV_DUMDATE      TYPE CHAR10,
        LV_DUMDATE      TYPE DATS,
        LV_PDATE        TYPE CHAR8,
*        LV_COMPDATE     TYPE CHAR10,
        LV_COMPDATE     TYPE DATS,
        LV_NAME1        TYPE NAME1_GP,

        LW_EXCELTAB     TYPE TY_EXCELTAB.

  "Changes by kamesh

  LOOP AT FP_I_EXCELTAB INTO LW_EXCELTAB.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LW_EXCELTAB-ANLKL
      IMPORTING
        OUTPUT = LW_EXCELTAB-ANLKL.

    MODIFY FP_I_EXCELTAB FROM LW_EXCELTAB TRANSPORTING ANLKL.

  ENDLOOP.

  SELECT * FROM ANKB INTO TABLE GT_ANKB FOR ALL ENTRIES IN FP_I_EXCELTAB
                                                WHERE ANLKL = FP_I_EXCELTAB-ANLKL
                                                  AND AFABE = '02'.      "'15'.
  "end of changes by kamesh

  LOOP AT FP_I_EXCELTAB INTO LW_EXCELTAB.

    CLEAR:ASSETNO, IT_RET, WA_KEY, WA_GEN,WA_GENX, WA_TIM, WA_TIMX,WA_POST,WA_POSTX,LV_DATE,
          WA_CUMVAL,COMPANYCODE,ASSETNO,SUBNUMBER,ASSETCREATED,WA_ORIGIN,WA_ORIGINX.

    REFRESH:IT_DEP_AREAX, IT_DEP_AREA,IT_CUMVAL,IT_TRANSACTIONS.

*    LV_COMPDATE = LW_EXCELTAB-AKTIV.

    REPLACE ALL OCCURRENCES OF '.' IN LW_EXCELTAB-AKTIV WITH '/'.
    REPLACE ALL OCCURRENCES OF '.' IN LW_EXCELTAB-BZDAT WITH '/'.
    REPLACE ALL OCCURRENCES OF '.' IN LW_EXCELTAB-BUDAT WITH '/'.

    SPLIT LW_EXCELTAB-AKTIV AT '/' INTO LV_MONC LV_DATC LV_YEAR.
    LV_MON = LV_MONC.
    LV_DAT = LV_DATC.
    CONCATENATE LV_YEAR LV_DAT LV_MON  INTO LV_DATE.
    CONDENSE LV_DATE.

    LV_COMPDATE = LV_DATE.
*    CONCATENATE '30.09.'  LV_YEAR INTO LV_DUMDATE.
    CONCATENATE LV_YEAR '0930' INTO LV_DUMDATE.

    IF LV_COMPDATE <= LV_DUMDATE.
      CONCATENATE LV_YEAR '0401.'  INTO LV_PDATE.
    ELSE.
      CONCATENATE LV_YEAR '1001'  INTO LV_PDATE.
    ENDIF.

    CLEAR : LV_YEAR, LV_MON, LV_DAT, LV_MONC, LV_DATC.

    SPLIT LW_EXCELTAB-BZDAT AT '/' INTO LV_MONC LV_DATC LV_YEAR.
    LV_MON = LV_MONC.
    LV_DAT = LV_DATC.
    CONCATENATE LV_YEAR LV_DAT LV_MON  INTO LV_INIACQ.
    CONDENSE LV_INIACQ.
    CLEAR : LV_YEAR, LV_MON, LV_DAT, LV_MONC, LV_DATC.

    SPLIT LW_EXCELTAB-BUDAT AT '/' INTO LV_MONC LV_DATC LV_YEAR.
    LV_MON = LV_MONC.
    LV_DAT = LV_DATC.
    CONCATENATE LV_YEAR LV_DAT LV_MON  INTO LV_POSDATE.
    CONDENSE LV_POSDATE.
    CLEAR : LV_YEAR, LV_MON, LV_DAT, LV_MONC, LV_DATC.



*    WA_KEY-ASSET = LW_EXCELTAB-ANLKL.
*
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        INPUT  = WA_KEY-ASSET
*      IMPORTING
*        OUTPUT = WA_KEY-ASSET.

    WA_KEY-COMPANYCODE = LW_EXCELTAB-BUKRS.

    WA_GEN-ASSETCLASS = LW_EXCELTAB-ANLKL.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = WA_GEN-ASSETCLASS
      IMPORTING
        OUTPUT = WA_GEN-ASSETCLASS.

    WA_GEN-DESCRIPT   = LW_EXCELTAB-TXT50.
    WA_GEN-DESCRIPT2  = LW_EXCELTAB-TXA50.
    WA_GEN-MAIN_DESCRIPT = LW_EXCELTAB-ANLHTTXT.

*    wa_gen-invent_no  = lw_exceltab-invnr.

    WA_GEN-QUANTITY   = LW_EXCELTAB-MENGE.
    WA_GEN-BASE_UOM   = LW_EXCELTAB-MEINS.

    WA_GENX-ASSETCLASS = 'X'.
    WA_GENX-DESCRIPT   = 'X'.
    WA_GENX-DESCRIPT2  = 'X'.
    WA_GENX-MAIN_DESCRIPT = LW_EXCELTAB-ANLHTTXT.

    WA_GENX-INVENT_NO  = 'X'.
    WA_GENX-QUANTITY   = 'X'.
    WA_GENX-BASE_UOM   = 'X'.

    WA_POST-CAP_DATE = LV_DATE.
*    WA_POST-INITIAL_ACQ = LV_POSDATE.


    WA_POSTX-CAP_DATE = 'X'.
*    WA_POSTX-INITIAL_ACQ = 'X'.

    WA_TIM-BUS_AREA   = LW_EXCELTAB-GSBER.
    WA_TIM-COSTCENTER = LW_EXCELTAB-KOSTL.
    WA_TIM-PLANT      = LW_EXCELTAB-WERKS.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = WA_TIM-PLANT
      IMPORTING
        OUTPUT = WA_TIM-PLANT.

    WA_TIMX-BUS_AREA   = 'X'.
    WA_TIMX-COSTCENTER = 'X'.
    WA_TIMX-PLANT      = 'X'.

    WA_ORIGIN-VENDOR_NO = LW_EXCELTAB-LIFNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = WA_ORIGIN-VENDOR_NO
      IMPORTING
        OUTPUT = WA_ORIGIN-VENDOR_NO.

    WA_ORIGIN-TYPE_NAME = LW_EXCELTAB-TYPBZ.
*    WA_ORIGIN-ORIG_VALUE = LW_EXCELTAB-ANBTR.
*    WA_ORIGIN-CURRENCY = 'INR'.

    WA_ORIGINX-VENDOR_NO = 'X'.
    WA_ORIGINX-TYPE_NAME = 'X'.
    WA_ORIGINX-ORIG_VALUE = 'X'.
    WA_ORIGIN-CURRENCY    = 'X'.

    WA_DEP_AREA-AREA     = '01'.
    WA_DEP_AREA-DEP_KEY  = 'DAM1'.  "UMDK
    WA_DEP_AREA-ODEP_START_DATE = LV_DATE.
***************************************************added by skn*****06.08.2018****************
    IF LW_EXCELTAB-ANLKL = '00300000' AND LW_EXCELTAB-ULIFE IS NOT INITIAL.
      WA_DEP_AREA-ULIFE_YRS = LW_EXCELTAB-ULIFE.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = WA_DEP_AREA-ULIFE_YRS
        IMPORTING
          OUTPUT = WA_DEP_AREA-ULIFE_YRS.
    ENDIF.
***************************************************************************************
    APPEND WA_DEP_AREA TO IT_DEP_AREA.
    CLEAR WA_DEP_AREA.

    WA_DEP_AREAX-AREA     = '01'.
    WA_DEP_AREAX-DEP_KEY  = 'X'.
    WA_DEP_AREAX-ODEP_START_DATE = 'X'.
    IF LW_EXCELTAB-ANLKL = '00300000' AND LW_EXCELTAB-ULIFE IS NOT INITIAL.
      WA_DEP_AREAX-ULIFE_YRS = 'X'.                              "added by skn 06.08.2018
    ENDIF.
    APPEND WA_DEP_AREAX TO IT_DEP_AREAX.
    CLEAR WA_DEP_AREAX.

    READ TABLE GT_ANKB INTO WA_ANKB WITH KEY ANLKL = LW_EXCELTAB-ANLKL
                                             AFABE = '02'.    "'15'.
    WA_DEP_AREA-AREA     = '02'.     "'15'.
*    WA_DEP_AREA-DEP_KEY  = 'AM01'.
    WA_DEP_AREA-DEP_KEY  = WA_ANKB-AFASL.
*    WA_DEP_AREA-ODEP_START_DATE = LV_DATE.
    WA_DEP_AREA-ODEP_START_DATE = LV_PDATE.
*******************************************************Added by SKN*06.08.2018************************************
    IF LW_EXCELTAB-ANLKL = '00300000' AND LW_EXCELTAB-ULIFE IS NOT INITIAL.
      WA_DEP_AREA-ULIFE_YRS = LW_EXCELTAB-ULIFE.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = WA_DEP_AREA-ULIFE_YRS
        IMPORTING
          OUTPUT = WA_DEP_AREA-ULIFE_YRS.

    ENDIF.
********************************************************************************************************
    APPEND WA_DEP_AREA TO IT_DEP_AREA.
    CLEAR WA_DEP_AREA.

    WA_DEP_AREAX-AREA     = '02'.    "'15'.
    WA_DEP_AREAX-DEP_KEY  = 'X'.
    WA_DEP_AREAX-ODEP_START_DATE = 'X'.
    IF LW_EXCELTAB-ANLKL = '00300000' AND LW_EXCELTAB-ULIFE IS NOT INITIAL.
      WA_DEP_AREAX-ULIFE_YRS = 'X'.                                                "added by skn 06.08.2018
    ENDIF.
    APPEND WA_DEP_AREAX TO IT_DEP_AREAX.
    CLEAR WA_DEP_AREAX.

    WA_CUMVAL-FISC_YEAR = LW_EXCELTAB-GJAHR.            "change by Kamesh 7.11.17
    WA_CUMVAL-AREA      = '01'.
    WA_CUMVAL-ACQ_VALUE = LW_EXCELTAB-ACQ_VALUE.
    WA_CUMVAL-ORD_DEP   = LW_EXCELTAB-ORD_DEP * -1.
    APPEND WA_CUMVAL TO IT_CUMVAL.
    CLEAR WA_CUMVAL.

    WA_CUMVAL-FISC_YEAR = LW_EXCELTAB-GJAHR.            "change by Kamesh 7.11.17
    WA_CUMVAL-AREA      = '02'.    "'15'.
    WA_CUMVAL-ACQ_VALUE = LW_EXCELTAB-ACQ_VALUE.
    WA_CUMVAL-ORD_DEP   = LW_EXCELTAB-ORD_DEP1 * -1.
    APPEND WA_CUMVAL TO IT_CUMVAL.
    CLEAR WA_CUMVAL.

    IF LW_EXCELTAB-NAFAG IS NOT INITIAL.

      WA_POSTEDVALUES-FISC_YEAR = LW_EXCELTAB-GJAHR.     "change by Kamesh 7.11.17
      WA_POSTEDVALUES-AREA = '01'.
      WA_POSTEDVALUES-ORD_DEP = LW_EXCELTAB-NAFAG * -1.
      APPEND WA_POSTEDVALUES TO IT_POSTEDVALUES.
      CLEAR WA_POSTEDVALUES.

      WA_POSTEDVALUES-FISC_YEAR = LW_EXCELTAB-GJAHR.
      WA_POSTEDVALUES-AREA = '02'.
      WA_POSTEDVALUES-ORD_DEP = LW_EXCELTAB-NAFAG * -1.
      APPEND WA_POSTEDVALUES TO IT_POSTEDVALUES.
      CLEAR WA_POSTEDVALUES.
    ENDIF.

    WA_TRANSACTIONS-FISC_YEAR = '2018'.
    WA_TRANSACTIONS-CURRENT_NO = '00001'.
    WA_TRANSACTIONS-AREA = '01'.
    WA_TRANSACTIONS-VALUEDATE = LV_INIACQ.
    WA_TRANSACTIONS-ASSETTRTYP = LW_EXCELTAB-ASSETTRTYP.
    WA_TRANSACTIONS-AMOUNT = LW_EXCELTAB-ANBTR.
    WA_TRANSACTIONS-CURRENCY = 'INR'.

    APPEND WA_TRANSACTIONS TO IT_TRANSACTIONS.
    CLEAR WA_TRANSACTIONS.

*    BREAK KNOWDURI.
    CALL FUNCTION 'BAPI_FIXEDASSET_OVRTAKE_CREATE'
      EXPORTING
        KEY                 = WA_KEY
*       REFERENCE           =
*       CREATESUBNUMBER     =
*       CREATEGROUPASSET    =
*       TESTRUN             = ' '
        GENERALDATA         = WA_GEN
        GENERALDATAX        = WA_GENX
*       INVENTORY           =
*       INVENTORYX          =
        POSTINGINFORMATION  = WA_POST
        POSTINGINFORMATIONX = WA_POSTX
        TIMEDEPENDENTDATA   = WA_TIM
        TIMEDEPENDENTDATAX  = WA_TIMX
*       ALLOCATIONS         =
*       ALLOCATIONSX        =
        ORIGIN              = WA_ORIGIN
        ORIGINX             = WA_ORIGINX
*       INVESTACCTASSIGNMNT =
*       INVESTACCTASSIGNMNTX       =
*       NETWORTHVALUATION   =
*       NETWORTHVALUATIONX  =
*       REALESTATE          =
*       REALESTATEX         =
*       INSURANCE           =
*       INSURANCEX          =
*       LEASING             =
*       LEASINGX            =
      IMPORTING
        COMPANYCODE         = COMPANYCODE
        ASSET               = ASSETNO
        SUBNUMBER           = SUBNUMBER
        ASSETCREATED        = ASSETCREATED
      TABLES
        DEPRECIATIONAREAS   = IT_DEP_AREA
        DEPRECIATIONAREASX  = IT_DEP_AREAX
*       INVESTMENT_SUPPORT  =
*       EXTENSIONIN         =
        CUMULATEDVALUES     = IT_CUMVAL    "ABLDT
        POSTEDVALUES        = IT_POSTEDVALUES
        TRANSACTIONS        = IT_TRANSACTIONS
*       PROPORTIONALVALUES  =
        RETURN              = IT_RET[]
*       POSTINGHEADERS      =
      .

    LV_SNO = LV_SNO + 1.
    IF ASSETNO IS NOT INITIAL .

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'
*   IMPORTING
*         RETURN        =
        .

      CALL FUNCTION 'DEQUEUE_ALL'.

      LOOP AT IT_RET.
        WA_ERRMSG-SNO    = LV_SNO.
        WA_ERRMSG-MSGTYP = IT_RET-TYPE.
        IF IT_RET-TYPE = 'S' AND IT_RET-ID = 'FAA_POST'  AND IT_RET-NUMBER = '092'.
          WA_ERRMSG-DOCNUM = IT_RET-MESSAGE_V2.
        ELSE.
          WA_ERRMSG-DOCNUM = ASSETNO.
        ENDIF.
        WA_ERRMSG-MESSG  = IT_RET-MESSAGE.
        APPEND WA_ERRMSG TO I_ERRMSG.
        CLEAR WA_ERRMSG.
      ENDLOOP.

    ELSE.

      LOOP AT IT_RET.
        WA_ERRMSG-SNO    = LV_SNO.
        WA_ERRMSG-MSGTYP = IT_RET-TYPE.
        WA_ERRMSG-MESSG  = IT_RET-MESSAGE.
        APPEND WA_ERRMSG TO I_ERRMSG.
        CLEAR WA_ERRMSG.
      ENDLOOP.

    ENDIF.

    CLEAR LW_EXCELTAB.
    REFRESH:IT_CUMVAL,IT_RET[], IT_POSTEDVALUES.

  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form ERRMSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_I_ERRMSG  text
*&---------------------------------------------------------------------*
FORM ERRMSG  USING    FP_I_ERRMSG TYPE TY_T_ERRMSG.

  PERFORM BUILD_FIELDCAT CHANGING I_FIELDCATALOG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      <--P_I_FIELDCATALOG  text
*&---------------------------------------------------------------------*
FORM BUILD_FIELDCAT  CHANGING FP_I_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

  PERFORM FIELDCAT USING '1' 'SNO' 'Line no' '8' CHANGING FP_I_FIELDCAT.
  PERFORM FIELDCAT USING '3' 'MSGTYP' 'Msg Type' '8' CHANGING FP_I_FIELDCAT.
  PERFORM FIELDCAT USING '5' 'MESSG' 'Messages Log' '75' CHANGING FP_I_FIELDCAT.
  PERFORM FIELDCAT USING '2' 'DOCNUM' 'Asset/Document No' '20' CHANGING FP_I_FIELDCAT.

  PERFORM DISP_ERRMSG USING I_ERRMSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_       text
*      -->P_       text
*      -->P_       text
*      -->P_       text
*      <--P_FP_I_FIELDCAT  text
*&---------------------------------------------------------------------*
FORM FIELDCAT USING    P_POS1 TYPE SYCUCOL
                        P_FNAME1 TYPE SLIS_FIELDNAME
                        P_STXT1 TYPE SCRTEXT_L
                        P_OUTL1 TYPE DD03P-OUTPUTLEN
               CHANGING FP_I_FIELDCATALOG TYPE SLIS_T_FIELDCAT_ALV.

  DATA : LW_FIELDCAT TYPE SLIS_FIELDCAT_ALV.


  LW_FIELDCAT-COL_POS = P_POS1.
  LW_FIELDCAT-FIELDNAME = P_FNAME1.
  LW_FIELDCAT-SELTEXT_L = P_STXT1.
  LW_FIELDCAT-TABNAME = 'I_ERRMSG'.
  LW_FIELDCAT-OUTPUTLEN = P_OUTL1.
  APPEND LW_FIELDCAT TO FP_I_FIELDCATALOG.
  CLEAR LW_FIELDCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_ERRMSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_I_ERRMSG  text
*&---------------------------------------------------------------------*
FORM DISP_ERRMSG  USING    FP_I_ERRMSG TYPE TY_T_ERRMSG.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK           = ' '
*     I_BYPASSING_BUFFER          = ' '
*     I_BUFFER_ACTIVE             = ' '
      I_CALLBACK_PROGRAM          = SY-CPROG
*     I_CALLBACK_PF_STATUS_SET    = ' '
*     I_CALLBACK_USER_COMMAND     = ' '
*     I_CALLBACK_TOP_OF_PAGE      = ' '
      I_CALLBACK_HTML_TOP_OF_PAGE = 'TOP_OF_PAGE'
*     I_CALLBACK_HTML_END_OF_LIST = ' '
*     I_STRUCTURE_NAME            =
*     I_BACKGROUND_ID             = ' '
*     I_GRID_TITLE                =
*     I_GRID_SETTINGS             =
*     IS_LAYOUT                   =
      IT_FIELDCAT                 = I_FIELDCATALOG
*     IT_EXCLUDING                =
*     IT_SPECIAL_GROUPS           =
*     IT_SORT                     =
*     IT_FILTER                   =
*     IS_SEL_HIDE                 =
      I_DEFAULT                   = 'X'
*     I_SAVE                      = ' '
*     IS_VARIANT                  =
*     IT_EVENTS                   =
*     IT_EVENT_EXIT               =
*     IS_PRINT                    =
*     IS_REPREP_ID                =
*     I_SCREEN_START_COLUMN       = 0
*     I_SCREEN_START_LINE         = 0
*     I_SCREEN_END_COLUMN         = 0
*     I_SCREEN_END_LINE           = 0
*     I_HTML_HEIGHT_TOP           = 0
*     I_HTML_HEIGHT_END           = 0
*     IT_ALV_GRAPHICS             =
*     IT_HYPERLINK                =
*     IT_ADD_FIELDCAT             =
*     IT_EXCEPT_QINFO             =
*     IR_SALV_FULLSCREEN_ADAPTER  =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER     =
*     ES_EXIT_CAUSED_BY_USER      =
    TABLES
      T_OUTTAB                    = FP_I_ERRMSG
    EXCEPTIONS
      PROGRAM_ERROR               = 1
      OTHERS                      = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      <--P_P_FILE  text
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
*
  FP_P_FILE = LX_FILETABLE-FILENAME.


*  SPLIT FILENAME AND EXTENSION NAME TO VALIDATE FILETYPE
  SPLIT FP_P_FILE AT '.' INTO FNAME ENAME.
  SET LOCALE LANGUAGE SY-LANGU.
  TRANSLATE ENAME TO UPPER CASE.


ENDFORM.
