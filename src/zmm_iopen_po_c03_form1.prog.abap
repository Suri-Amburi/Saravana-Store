*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GIT_FILE
*&---------------------------------------------------------------------*

FORM get_filename  CHANGING p_p_file.

  DATA: LI_FILETABLE    TYPE FILETABLE,
        LX_FILETABLE    TYPE FILE_TABLE,
        LV_RETURN_CODE  TYPE I,
        LV_WINDOW_TITLE TYPE STRING.


  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE            = LV_WINDOW_TITLE
    CHANGING
      FILE_TABLE              = LI_FILETABLE
      RC                      = LV_RETURN_CODE
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      OTHERS                  = 5.

  READ TABLE  LI_FILETABLE INTO LX_FILETABLE INDEX 1.
  p_p_file = LX_FILETABLE-FILENAME.

*  SPLIT FILENAME AND EXTENSION NAME TO VALIDATE FILETYPE
  SPLIT p_p_file AT '.' INTO FNAME ENAME.
  SET LOCALE LANGUAGE SY-LANGU.
  TRANSLATE ENAME TO UPPER CASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GIT_FILE
*&---------------------------------------------------------------------*
FORM get_data  CHANGING p_git_file.
   DATA : I_TYPE    TYPE TRUXS_T_TEXT_DATA.

  DATA:LV_FILE TYPE RLGRAP-FILENAME.

  BREAK KSANTHOSH.
*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.

    REFRESH GIT_FILE[].

    LV_FILE = P_FILE.

*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        I_TAB_RAW_DATA       = I_TYPE
        I_FILENAME           = LV_FILE
      TABLES
        I_TAB_CONVERTED_DATA = GIT_FILE[]
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.


    DELETE GIT_FILE FROM 1 TO 2.

  ELSE.
    MESSAGE E398(00) WITH 'Invalid File Type'  .
  ENDIF.

  IF GIT_FILE IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GIT_FILE
*&---------------------------------------------------------------------*
FORM process_data  USING    p_git_file.

FIELD-SYMBOLS: <FS_FLATFILE>    TYPE GTY_FILE,
                 <FS_FLATFILE_IT> TYPE GTY_FILE,
                 <FS_FLATFILE1>   TYPE GTY_FILE.

  DATA: WA_POHEADER          TYPE BAPIMEPOHEADER,
        WA_POHEADERX         TYPE BAPIMEPOHEADERX,

        WA_POITEM            TYPE BAPIMEPOITEM,
        IT_POITEM            TYPE TABLE OF BAPIMEPOITEM,

        WA_POITEMX           TYPE BAPIMEPOITEMX,
        IT_POITEMX           TYPE TABLE OF BAPIMEPOITEMX,

        WA_POSCHEDULE        TYPE BAPIMEPOSCHEDULE,
        IT_POSCHEDULE        TYPE TABLE OF BAPIMEPOSCHEDULE,

        WA_POSCHEDULEX       TYPE BAPIMEPOSCHEDULX,
        IT_POSCHEDULEX       TYPE TABLE OF BAPIMEPOSCHEDULX,

        IT_POTEXTHEADER      TYPE TABLE OF BAPIMEPOTEXTHEADER,
        WA_POTEXTHEADER      TYPE BAPIMEPOTEXTHEADER,

        IT_POTEXTITEM        TYPE TABLE OF BAPIMEPOTEXT,
        WA_POTEXTITEM        TYPE BAPIMEPOTEXT,

        IT_RETURN            TYPE TABLE OF BAPIRET2,
        WA_RETURN            TYPE  BAPIRET2,

        IT_POACCOUNT         TYPE TABLE OF BAPIMEPOACCOUNT,
        WA_POACCOUNT         TYPE BAPIMEPOACCOUNT,

        IT_POACCOUNTX        TYPE TABLE OF BAPIMEPOACCOUNTX,
        WA_POACCOUNTX        TYPE BAPIMEPOACCOUNTX,

        IT_POSERVICES        TYPE TABLE OF  BAPIESLLC,
        WA_POSERVICES        TYPE  BAPIESLLC,

        IT_POSRVACCESSVALUES TYPE TABLE OF  BAPIESKLC,
        WA_POSRVACCESSVALUES TYPE  BAPIESKLC,

        CNT_ITEM             TYPE I,
        PACKNO               TYPE PACKNO,
        NET_PRICE            TYPE BAPICUREXT,
        UTEMP                TYPE DZEKKN.

*****************************
  DATA: IT_POCOMPONENTS  TYPE TABLE OF BAPIMEPOCOMPONENT,
        WA_POCOMPONENTS  TYPE  BAPIMEPOCOMPONENT,
        IT_POCOMPONENTSX TYPE TABLE OF BAPIMEPOCOMPONENTX,
        WA_POCOMPONENTSX TYPE  BAPIMEPOCOMPONENTX.
*******************************

  DATA: WA_BAPIMEPOHEADER-PO_NUMBER TYPE  BAPIMEPOHEADER-PO_NUMBER,
        WA_EXPHEADER                TYPE  BAPIMEPOHEADER,
        WA_BAPIEIKP                 TYPE  BAPIEIKP.


  BREAK KSANTHOSH.
  IF GIT_FILE IS NOT INITIAL.

    GIT_FILE_IT[] = GIT_FILE_I[] = GIT_FILE[].

        DELETE ADJACENT DUPLICATES FROM GIT_FILE COMPARING sno.
*        DELETE ADJACENT DUPLICATES FROM GIT_FILE_I COMPARING EBELP.

    LOOP AT GIT_FILE ASSIGNING <FS_FLATFILE>.   " WHERE MARK <> 'X'.
      IF <FS_FLATFILE> IS ASSIGNED.

        CLEAR: WA_POHEADER,WA_POHEADERX,WA_POTEXTHEADER.

        WA_POHEADER-DOC_TYPE  = <FS_FLATFILE>-BSART.
        WA_POHEADER-PO_NUMBER = <FS_FLATFILE>-EBELN.
        WA_POHEADER-PURCH_ORG = <FS_FLATFILE>-EKORG.
        WA_POHEADER-PUR_GROUP = <FS_FLATFILE>-EKGRP.
        WA_POHEADER-COMP_CODE = <FS_FLATFILE>-BUKRS.
        WA_POHEADER-VENDOR    = <FS_FLATFILE>-LIFNR.


        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = WA_POHEADER-VENDOR
          IMPORTING
            OUTPUT = WA_POHEADER-VENDOR.


        WA_POHEADER-DOC_DATE  = <FS_FLATFILE>-BEDAT.

        CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
          EXPORTING
            DATE_EXTERNAL            = WA_POHEADER-DOC_DATE
*           ACCEPT_INITIAL_DATE      = 1
          IMPORTING
            DATE_INTERNAL            = WA_POHEADER-DOC_DATE
          EXCEPTIONS
            DATE_EXTERNAL_IS_INVALID = 1
            OTHERS                   = 2.
        IF SY-SUBRC <> 0.
*        Implement suitable error handling here
        ENDIF.

        WA_POHEADER-EXCH_RATE = <FS_FLATFILE>-WKURS.

        WA_POHEADERX-DOC_TYPE  = 'X'.
        WA_POHEADERX-PO_NUMBER = 'X'.
        WA_POHEADERX-PURCH_ORG = 'X'.
        WA_POHEADERX-PUR_GROUP = 'X'.
        WA_POHEADERX-COMP_CODE = 'X'.
        WA_POHEADERX-VENDOR    = 'X'.
        WA_POHEADERX-DOC_DATE  = 'X'.
        WA_POHEADERX-EXCH_RATE = 'X'.

*Texts
*        WA_POTEXTHEADER-TEXT_ID = 'F07'.
*        WA_POTEXTHEADER-TEXT_FORM = '*'.
*        WA_POTEXTHEADER-TEXT_LINE = <FS_FLATFILE>-07.
*        APPEND WA_POTEXTHEADER TO IT_POTEXTHEADER.
*        CLEAR WA_POTEXTHEADER.
*
*        WA_POTEXTHEADER-TEXT_ID = 'F05'.
*        WA_POTEXTHEADER-TEXT_FORM = '*'.
*        WA_POTEXTHEADER-TEXT_LINE = <FS_FLATFILE>-05.
*        APPEND WA_POTEXTHEADER TO IT_POTEXTHEADER.
*        CLEAR WA_POTEXTHEADER.
*
*        WA_POTEXTHEADER-TEXT_ID = 'F03'.
*        WA_POTEXTHEADER-TEXT_FORM = '*'.
*        WA_POTEXTHEADER-TEXT_LINE = <FS_FLATFILE>-03.
*        APPEND WA_POTEXTHEADER TO IT_POTEXTHEADER.
*        CLEAR WA_POTEXTHEADER.
*
*        WA_POTEXTHEADER-TEXT_ID = 'F08'.
*        WA_POTEXTHEADER-TEXT_FORM = '*'.
*        WA_POTEXTHEADER-TEXT_LINE = <FS_FLATFILE>-08.
*        APPEND WA_POTEXTHEADER TO IT_POTEXTHEADER.
*        CLEAR WA_POTEXTHEADER.
*
*        WA_POTEXTHEADER-TEXT_ID = 'F10'.
*        WA_POTEXTHEADER-TEXT_FORM = '*'.
*        WA_POTEXTHEADER-TEXT_LINE = <FS_FLATFILE>-10.
*        APPEND WA_POTEXTHEADER TO IT_POTEXTHEADER.
*        CLEAR WA_POTEXTHEADER.
*
*        WA_POTEXTHEADER-TEXT_ID = 'F22'.
*        WA_POTEXTHEADER-TEXT_FORM = '*'.
*        WA_POTEXTHEADER-TEXT_LINE = <FS_FLATFILE>-22.
*        APPEND WA_POTEXTHEADER TO IT_POTEXTHEADER.
*        CLEAR WA_POTEXTHEADER.
*
*        WA_POTEXTHEADER-TEXT_ID = 'F23'.
*        WA_POTEXTHEADER-TEXT_FORM = '*'.
*        WA_POTEXTHEADER-TEXT_LINE = <FS_FLATFILE>-23.
*        APPEND WA_POTEXTHEADER TO IT_POTEXTHEADER.
*        CLEAR WA_POTEXTHEADER.

        WA_POHEADER-COLLECT_NO = <FS_FLATFILE>-SUBMI.
        WA_POHEADERX-COLLECT_NO = 'X'.

        CLEAR: PACKNO,NET_PRICE.
        PACKNO = '0000000000'.



        LOOP AT GIT_FILE_I ASSIGNING <FS_FLATFILE1> WHERE sno = <FS_FLATFILE>-sno.
          "EBELN = <FS_FLATFILE>-EBELN AND BSART = <FS_FLATFILE>-BSART AND  MARK <> 'X'.  "WHERE id = 'H'.

          IF <FS_FLATFILE1> IS ASSIGNED.

            WA_POITEM-PO_ITEM        = <FS_FLATFILE1>-EBELP.
            WA_POITEM-MATL_GROUP     = <FS_FLATFILE1>-MATKL.
            WA_POITEM-ACCTASSCAT     = <FS_FLATFILE1>-KNTTP.
            WA_POITEM-ITEM_CAT       = <FS_FLATFILE1>-EPSTP.
            IF WA_POITEM-ITEM_CAT = 'D'.
              WA_POITEM-SHORT_TEXT   = <FS_FLATFILE1>-TXZ01.
            ELSEIF  WA_POITEM-ITEM_CAT = 'L'.
              WA_POITEM-MATERIAL_LONG = <FS_FLATFILE1>-MATNR.
            ELSE.
              WA_POITEM-MATERIAL_LONG = <FS_FLATFILE1>-MATNR.
            ENDIF.
            WA_POITEM-QUANTITY   = <FS_FLATFILE1>-MENGE.
            WA_POITEM-NET_PRICE  = <FS_FLATFILE1>-NETPR." * <FS_FLATFILE1>-MENGE.
            WA_POITEM-PLANT      = <FS_FLATFILE1>-NAME1.
            WA_POITEM-STGE_LOC   = <FS_FLATFILE1>-LGOBE.
            WA_POITEM-PCKG_NO    =  PACKNO + 1.
            WA_POITEM-TAX_CODE   = <FS_FLATFILE1>-MWSKZ.
            WA_POITEM-FREE_ITEM   = <FS_FLATFILE1>-KSCHL.
            WA_POITEM-INFO_UPD   = ' '.
            APPEND WA_POITEM  TO IT_POITEM .
            NET_PRICE	= NET_PRICE	+  WA_POITEM-NET_PRICE .
            CLEAR WA_POITEM .

            WA_POITEMX-PO_ITEM      = <FS_FLATFILE1>-EBELP.
            WA_POITEMX-MATL_GROUP   = 'X'.
            WA_POITEMX-ACCTASSCAT   = 'X'.
            WA_POITEMX-ITEM_CAT     = 'X'.
            IF <FS_FLATFILE1>-EPSTP = 'D' .
              WA_POITEMX-SHORT_TEXT = 'X'.
            ELSEIF <FS_FLATFILE1>-EPSTP = 'L' .
              WA_POITEMX-MATERIAL_LONG   = 'X'.
            ELSE.
              WA_POITEMX-MATERIAL_LONG   = 'X'.
            ENDIF.
            WA_POITEMX-QUANTITY     = 'X'.
            WA_POITEMX-NET_PRICE    = 'X'.
            WA_POITEMX-PLANT        = 'X'.
            WA_POITEMX-STGE_LOC     = 'X'.
            WA_POITEMX-PCKG_NO      = 'X'.
            WA_POITEMX-TAX_CODE     = 'X'.
            WA_POITEMX-FREE_ITEM    =  'X'.
            WA_POITEMX-INFO_UPD     =  'X'.
            APPEND WA_POITEMX TO IT_POITEMX.
            CLEAR WA_POITEMX.

            IF <FS_FLATFILE1>-EPSTP = 'L'.

              WA_POCOMPONENTS-PO_ITEM         = <FS_FLATFILE1>-EBELP.
              WA_POCOMPONENTS-SCHED_LINE      = '0001'.
              WA_POCOMPONENTS-ITEM_NO         = '0010'.
              WA_POCOMPONENTS-MATERIAL_LONG   = <FS_FLATFILE1>-COMPONENT.
              WA_POCOMPONENTS-ENTRY_QUANTITY  = <FS_FLATFILE1>-MENGE.
              WA_POCOMPONENTS-PLANT           = <FS_FLATFILE1>-NAME1.
*              wa_pocomponents-req_date        = sy-datum.
              WA_POCOMPONENTS-REQ_QUAN        = <FS_FLATFILE1>-ERFMG.
              WA_POCOMPONENTS-CHANGE_ID       = 'I'.
              APPEND WA_POCOMPONENTS TO IT_POCOMPONENTS.
              CLEAR WA_POCOMPONENTS.

              WA_POCOMPONENTSX-PO_ITEM        = <FS_FLATFILE1>-EBELP.
              WA_POCOMPONENTSX-PO_ITEMX        = 'X'.
              WA_POCOMPONENTSX-SCHED_LINE     = '0001'.
              WA_POCOMPONENTSX-SCHED_LINEX     = 'X'.
              WA_POCOMPONENTSX-ITEM_NO        = '0010'.
              WA_POCOMPONENTSX-ITEM_NOX       = 'X'.
              WA_POCOMPONENTSX-MATERIAL_LONG  = 'X'.
              WA_POCOMPONENTSX-ENTRY_QUANTITY = 'X'.
              WA_POCOMPONENTSX-PLANT          = 'X'.
              WA_POCOMPONENTSX-REQ_QUAN       = 'X'.
              WA_POCOMPONENTSX-CHANGE_ID      = 'X'.
              APPEND WA_POCOMPONENTSX TO IT_POCOMPONENTSX.
              CLEAR:WA_POCOMPONENTSX.
            ENDIF.

            CLEAR WA_POITEM .

            WA_POSCHEDULE-PO_ITEM = <FS_FLATFILE1>-EBELP.
            WA_POSCHEDULE-DELIVERY_DATE = <FS_FLATFILE1>-EEIND.
            CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
              EXPORTING
                DATE_EXTERNAL            = WA_POSCHEDULE-DELIVERY_DATE
              IMPORTING
                DATE_INTERNAL            = WA_POSCHEDULE-DELIVERY_DATE
              EXCEPTIONS
                DATE_EXTERNAL_IS_INVALID = 1
                OTHERS                   = 2.

            WA_POSCHEDULE-SCHED_LINE = 0001.
            APPEND WA_POSCHEDULE TO IT_POSCHEDULE.
            CLEAR WA_POSCHEDULE.

            WA_POSCHEDULEX-PO_ITEM = <FS_FLATFILE1>-EBELP.
            WA_POSCHEDULEX-DELIVERY_DATE = 'X'.
            WA_POSCHEDULEX-SCHED_LINE = 0001.
            APPEND WA_POSCHEDULEX TO IT_POSCHEDULEX.
            CLEAR WA_POSCHEDULEX.

*Operation Text
*            WA_POTEXTITEM-PO_ITEM = <FS_FLATFILE1>-EBELP.
*            WA_POTEXTITEM-TEXT_ID = 'F11'.
*            WA_POTEXTITEM-TEXT_FORM = '*'.
*            WA_POTEXTITEM-TEXT_LINE = <FS_FLATFILE1>-11.
*            APPEND WA_POTEXTITEM TO IT_POTEXTITEM.
*            CLEAR WA_POTEXTITEM.

            IF <FS_FLATFILE1>-EPSTP = 'D'  OR  <FS_FLATFILE1>-KNTTP = 'K'.

              WA_POACCOUNT-PO_ITEM = <FS_FLATFILE1>-EBELP.
              WA_POACCOUNT-SERIAL_NO = '01'."utemp'.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  INPUT  = <FS_FLATFILE1>-SAKNR
                IMPORTING
                  OUTPUT = <FS_FLATFILE1>-SAKNR.
              WA_POACCOUNT-GL_ACCOUNT = <FS_FLATFILE1>-SAKNR.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  INPUT  = <FS_FLATFILE1>-KOSTL
                IMPORTING
                  OUTPUT = <FS_FLATFILE1>-KOSTL.
              WA_POACCOUNT-COSTCENTER = <FS_FLATFILE1>-KOSTL.
              WA_POACCOUNT-CO_AREA = <FS_FLATFILE1>-KOKRS.

              APPEND WA_POACCOUNT TO IT_POACCOUNT.
              CLEAR WA_POACCOUNT.

              WA_POACCOUNTX-PO_ITEM     = <FS_FLATFILE1>-EBELP.
              WA_POACCOUNTX-SERIAL_NO   = '01'.
              WA_POACCOUNTX-PO_ITEMX    = 'X'.
              WA_POACCOUNTX-GL_ACCOUNT  = 'X'.
              WA_POACCOUNTX-SERIAL_NOX  = 'X'.
              WA_POACCOUNTX-COSTCENTER  = 'X'.
              IF NOT <FS_FLATFILE1>-KOKRS IS INITIAL.
                WA_POACCOUNTX-CO_AREA   = 'X'.
              ENDIF.
              APPEND WA_POACCOUNTX TO IT_POACCOUNTX.
              CLEAR WA_POACCOUNTX.

            ENDIF.
          ENDIF.
*          CLEAR <FS_FLATFILE1>.
        ENDLOOP.

        IF <FS_FLATFILE>-EPSTP = 'D'.

          WA_POSERVICES-PCKG_NO    = PACKNO."'0000000001'.
          WA_POSERVICES-LINE_NO    = PACKNO."'0000000001'.
          WA_POSERVICES-EXT_LINE   = '0000000010'.
          WA_POSERVICES-SUBPCKG_NO = PACKNO + 1.".'0000000002'.
*          APPEND WA_POSERVICES TO IT_POSERVICES.
*          CLEAR WA_POSERVICES.

          WA_POSERVICES-PCKG_NO    = PACKNO + 1."'0000000002'.
          WA_POSERVICES-LINE_NO    = PACKNO + 1."wa_poservices-line_no + 1.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = <FS_FLATFILE>-SERVICE
            IMPORTING
              OUTPUT = <FS_FLATFILE>-SERVICE.
          WA_POSERVICES-SERVICE    = <FS_FLATFILE>-SERVICE.
          WA_POSERVICES-OUTL_IND   = 'X'.
          WA_POSERVICES-QUANTITY   = <FS_FLATFILE>-MENGE.
          WA_POSERVICES-GR_PRICE   = NET_PRICE."<FS_FLATFILE>-NETPR."
*          WA_POSERVICES-SUBPCKG_NO = '0000000000'.
          APPEND WA_POSERVICES TO IT_POSERVICES.
          CLEAR WA_POSERVICES.

          WA_POSRVACCESSVALUES-PCKG_NO   = PACKNO + 1.".'0000000002'.
          WA_POSRVACCESSVALUES-LINE_NO   = PACKNO + 1."'0000000002'.
          WA_POSRVACCESSVALUES-SERIAL_NO = '01'.
          APPEND WA_POSRVACCESSVALUES TO IT_POSRVACCESSVALUES.
          CLEAR WA_POSRVACCESSVALUES.
        ENDIF.


*        BREAK KSANTHOSH.
        CALL FUNCTION 'BAPI_PO_CREATE1'
          EXPORTING
            POHEADER          = WA_POHEADER
            POHEADERX         = WA_POHEADERX
          IMPORTING
            EXPPURCHASEORDER  = WA_BAPIMEPOHEADER-PO_NUMBER
            EXPHEADER         = WA_EXPHEADER
            EXPPOEXPIMPHEADER = WA_BAPIEIKP
          TABLES
            RETURN            = IT_RETURN[]
            POITEM            = IT_POITEM
            POITEMX           = IT_POITEMX
*           POADDRDELIVERY    =
            POSCHEDULE        = IT_POSCHEDULE
            POSCHEDULEX       = IT_POSCHEDULEX
            POACCOUNT         = IT_POACCOUNT
*           POACCOUNTPROFITSEGMENT       =
            POACCOUNTX        = IT_POACCOUNTX
*           POCONDHEADER      =
*           POCONDHEADERX     =
*           POCOND            =
*           POCONDX           =
*           POLIMITS          =
*           POCONTRACTLIMITS  =
            POSERVICES        = IT_POSERVICES
            POSRVACCESSVALUES = IT_POSRVACCESSVALUES
*           POSERVICESTEXT    =
*           EXTENSIONIN       =
*           EXTENSIONOUT      =
*           POEXPIMPITEM      =
*           POEXPIMPITEMX     =
            POTEXTHEADER      = IT_POTEXTHEADER
            POTEXTITEM        = IT_POTEXTITEM
*           ALLVERSIONS       =
*           POPARTNER         =
            POCOMPONENTS      = IT_POCOMPONENTS
            POCOMPONENTSX     = IT_POCOMPONENTSX
*           POSHIPPING        =
*           POSHIPPINGX       =
*           POSHIPPINGEXP     =
*           SERIALNUMBER      =
*           SERIALNUMBERX     =
*           INVPLANHEADER     =
*           INVPLANHEADERX    =
*           INVPLANITEM       =
*           INVPLANITEMX      =
*           NFMETALLITMS      =
          .

        CLEAR : IT_POTEXTHEADER[],IT_POTEXTITEM[],IT_POCOMPONENTS[],IT_POCOMPONENTSX[],IT_POITEM[],IT_POITEMX[],
        IT_POSCHEDULE[], IT_POSCHEDULEX[],IT_POACCOUNTX[],IT_POACCOUNT[].

        LOOP AT  IT_RETURN INTO WA_RETURN.

          IF WA_RETURN-TYPE = 'S' .
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                WAIT = 'X'.

            GWA_DISPLAY-PO_ITEM = WA_BAPIMEPOHEADER-PO_NUMBER.
            GWA_DISPLAY-sno = <FS_FLATFILE1>-sno.
            GWA_DISPLAY-TYPE = WA_RETURN-TYPE.
            GWA_DISPLAY-MESSAGE = WA_RETURN-MESSAGE.
            APPEND GWA_DISPLAY TO GIT_DISPLAY.
            CLEAR GWA_DISPLAY.

          ELSEIF WA_RETURN-TYPE = 'E' .
           GWA_DISPLAY-sno = <FS_FLATFILE1>-sno.
            GWA_DISPLAY-PO_ITEM = WA_BAPIMEPOHEADER-PO_NUMBER.
            GWA_DISPLAY-TYPE = WA_RETURN-TYPE.
            GWA_DISPLAY-MESSAGE = WA_RETURN-MESSAGE.
            APPEND GWA_DISPLAY TO GIT_DISPLAY.
            CLEAR GWA_DISPLAY.

            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ENDIF.
        ENDLOOP.
        CLEAR : WA_POHEADER, WA_BAPIMEPOHEADER-PO_NUMBER.
      ENDIF.
      CLEAR: IT_POITEM, IT_RETURN, IT_POSCHEDULE, IT_POTEXTHEADER , IT_POTEXTITEM,IT_POACCOUNTX,IT_POACCOUNT.
    ENDLOOP.

*CLEAR <FS_FLATFILE>.
*        GWA_FILE-MARK = 'X'.
*        MODIFY GIT_FILE FROM GWA_FILE TRANSPORTING MARK WHERE EBELN = WA_POHEADER-PO_NUMBER.
*        WAIT UP TO 2 SECONDS.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELD_CATLOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM field_catlog .

  PERFORM CREATE_FIELDCAT USING:
      '01' '01' 'SNO'       'GIT_DISPLAY' 'L' 'SNO',
      '01' '02' 'ID'        'GIT_DISPLAY' 'L' 'ID',
      '01' '03' 'PO_ITEM'   'GIT_DISPLAY' 'L' 'PO NUM',
      '01' '04' 'TYPE'      'GIT_DISPLAY' 'L' 'TYPE',
      '01' '05' 'MESSAGE'   'GIT_DISPLAY' 'L' 'MESSAGE'.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0387   text
*      -->P_0388   text
*      -->P_0389   text
*      -->P_0390   text
*      -->P_0391   text
*      -->P_0392   text
*----------------------------------------------------------------------*
FORM CREATE_FIELDCAT  USING FP_ROWPOS    TYPE SYCUROW
                            FP_COLPOS    TYPE SYCUCOL
                            FP_FLDNAM    TYPE FIELDNAME
                            FP_TABNAM    TYPE TABNAME
                            FP_JUSTIF    TYPE CHAR1
                            FP_SELTEXT   TYPE DD03P-SCRTEXT_L..


  DATA: WA_FCAT    TYPE  SLIS_FIELDCAT_ALV.
  WA_FCAT-ROW_POS        =  FP_ROWPOS.     "Row
  WA_FCAT-COL_POS        =  FP_COLPOS.     "Column
  WA_FCAT-FIELDNAME      =  FP_FLDNAM.     "Field Name
  WA_FCAT-TABNAME        =  FP_TABNAM.     "Internal Table Name
  WA_FCAT-JUST           =  FP_JUSTIF.     "Screen Justified
  WA_FCAT-SELTEXT_L      =  FP_SELTEXT.    "Field Text

  APPEND WA_FCAT TO IT_FIELDCAT.

  CLEAR WA_FCAT.

ENDFORM.



*&---------------------------------------------------------------------*
*& Form DISPLAY_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_output .

DATA: L_REPID TYPE SYREPID .


  IF GIT_DISPLAY IS NOT INITIAL.

    WA_LAYOUT-ZEBRA = 'X'.
    WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
*       I_INTERFACE_CHECK  = ' '
*       I_BYPASSING_BUFFER = ' '
*       I_BUFFER_ACTIVE    = ' '
        I_CALLBACK_PROGRAM = L_REPID
*       I_CALLBACK_PF_STATUS_SET          = ' '
*       I_CALLBACK_USER_COMMAND           = ' '
*       I_CALLBACK_TOP_OF_PAGE            = ' '
*       I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*       I_CALLBACK_HTML_END_OF_LIST       = ' '
*       I_STRUCTURE_NAME   =
*       I_BACKGROUND_ID    = ' '
*       I_GRID_TITLE       =
*       I_GRID_SETTINGS    =
        IS_LAYOUT          = WA_LAYOUT
        IT_FIELDCAT        = IT_FIELDCAT
*       IT_EXCLUDING       =
*       IT_SPECIAL_GROUPS  =
*       IT_SORT            =
*       IT_FILTER          =
*       IS_SEL_HIDE        =
*       I_DEFAULT          = 'X'
        I_SAVE             = 'X'
*       IS_VARIANT         =
*       IT_EVENTS          =
*       IT_EVENT_EXIT      =
*       IS_PRINT           =
*       IS_REPREP_ID       =
*       I_SCREEN_START_COLUMN             = 0
*       I_SCREEN_START_LINE               = 0
*       I_SCREEN_END_COLUMN               = 0
*       I_SCREEN_END_LINE  = 0
*       I_HTML_HEIGHT_TOP  = 0
*       I_HTML_HEIGHT_END  = 0
*       IT_ALV_GRAPHICS    =
*       IT_HYPERLINK       =
*       IT_ADD_FIELDCAT    =
*       IT_EXCEPT_QINFO    =
*       IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*       E_EXIT_CAUSED_BY_CALLER           =
*       ES_EXIT_CAUSED_BY_USER            =
      TABLES
        T_OUTTAB           = GIT_DISPLAY
      EXCEPTIONS
        PROGRAM_ERROR      = 1
        OTHERS             = 2.
    IF SY-SUBRC <> 0.
* MESSAGE 'ERROR IN ALV DISPLAY'(010) TYPE 'I'.
    ENDIF.
  ENDIF.

ENDFORM.
