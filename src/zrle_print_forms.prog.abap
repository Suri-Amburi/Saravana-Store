*----------------------------------------------------------------------*
*   INCLUDE RLE_PRINT_FORMS                                            *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM PROTOCOL_UPDATE                                          *
*---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.       *
*---------------------------------------------------------------------*

FORM PROTOCOL_UPDATE.

  CHECK XSCREEN = SPACE.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
       EXPORTING
            MSG_ARBGB = SYST-MSGID
            MSG_NR    = SYST-MSGNO
            MSG_TY    = SYST-MSGTY
            MSG_V1    = SYST-MSGV1
            MSG_V2    = SYST-MSGV2
            MSG_V3    = SYST-MSGV3
            MSG_V4    = SYST-MSGV4
       EXCEPTIONS
            OTHERS    = 1.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ADD_SMFRM_PROT
*&---------------------------------------------------------------------*
FORM ADD_SMFRM_PROT.

  DATA: LT_ERRORTAB             TYPE TSFERROR.
* DATA: LF_MSGNR                TYPE SY-MSGNO.   "DEL_HP_335958
  FIELD-SYMBOLS: <FS_ERRORTAB>  TYPE LINE OF TSFERROR.

* get smart form protocoll
  CALL FUNCTION 'SSF_READ_ERRORS'
       IMPORTING
            ERRORTAB = LT_ERRORTAB.

* add smartform protocoll to nast protocoll
  LOOP AT LT_ERRORTAB ASSIGNING <FS_ERRORTAB>.
*    CLEAR LF_MSGNR.                             "DEL_HP_335958
*    LF_MSGNR = <FS_ERRORTAB>-ERRNUMBER.         "DEL_HP_335958
    CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
         EXPORTING
              MSG_ARBGB = <FS_ERRORTAB>-MSGID
*             MSG_NR    = LF_MSGNR               "DEL_HP_335958
              MSG_NR    = <FS_ERRORTAB>-MSGNO    "INS_HP_335958
              MSG_TY    = <FS_ERRORTAB>-MSGTY
              MSG_V1    = <FS_ERRORTAB>-MSGV1
              MSG_V2    = <FS_ERRORTAB>-MSGV2
              MSG_V3    = <FS_ERRORTAB>-MSGV3
              MSG_V4    = <FS_ERRORTAB>-MSGV4
         EXCEPTIONS
              OTHERS    = 1.
  ENDLOOP.

ENDFORM.                               " ADD_SMFRM_PROT

*&---------------------------------------------------------------------*
*&      Form  SET_PRINT_PARAM
*&---------------------------------------------------------------------*
FORM SET_PRINT_PARAM USING    IS_ADDR_KEY LIKE ADDR_KEY
                     CHANGING CS_CONTROL_PARAM TYPE SSFCTRLOP
                              CS_COMPOSER_PARAM TYPE SSFCOMPOP
                              CS_RECIPIENT TYPE  SWOTOBJID
                              CS_SENDER TYPE  SWOTOBJID
                              CF_RETCODE TYPE SY-SUBRC.

  DATA: LS_ITCPO     TYPE ITCPO.
  DATA: LF_REPID     TYPE SY-REPID.
  DATA: LF_DEVICE    TYPE TDDEVICE.
  DATA: LS_RECIPIENT TYPE SWOTOBJID.
  DATA: LS_SENDER    TYPE SWOTOBJID.

  LF_REPID = SY-REPID.

  CALL FUNCTION 'WFMC_PREPARE_SMART_FORM'
       EXPORTING
            PI_NAST       = NAST
            PI_ADDR_KEY   = IS_ADDR_KEY
            PI_REPID      = LF_REPID
       IMPORTING
            PE_RETURNCODE = CF_RETCODE
            PE_ITCPO      = LS_ITCPO
            PE_DEVICE     = LF_DEVICE
            PE_RECIPIENT  = CS_RECIPIENT
            PE_SENDER     = CS_SENDER.

  IF CF_RETCODE = 0.
    MOVE-CORRESPONDING LS_ITCPO TO CS_COMPOSER_PARAM.
*   CS_CONTROL_PARAM-NO_OPEN
*   CS_CONTROL_PARAM-NO_CLOSE
    CS_CONTROL_PARAM-DEVICE      = LF_DEVICE.
    CS_CONTROL_PARAM-NO_DIALOG   = 'X'.
    CS_CONTROL_PARAM-PREVIEW     = XSCREEN.
    CS_CONTROL_PARAM-GETOTF      = LS_ITCPO-TDGETOTF.
    CS_CONTROL_PARAM-LANGU       = NAST-SPRAS.
*   CS_CONTROL_PARAM-REPLANGU1
*   CS_CONTROL_PARAM-REPLANGU2
*   CS_CONTROL_PARAM-REPLANGU3
*   CS_CONTROL_PARAM-STARTPAGE
  ENDIF.
ENDFORM.                               " SET_PRINT_PARAM
*&---------------------------------------------------------------------*
*& Form PICKING_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
**********************************************PICKING FORM*******************************************
FORM PICKING_LIST .
  TYPES: BEGIN OF TY_LIKP,
         VBELN TYPE VBELN_VL,                ""Delivery
         VSTEL TYPE VSTEL,                   ""Shipping Point/Receiving Point
         KODAT TYPE KODAT,                   ""Picking Date
         KUNNR TYPE KUNWE,                   ""Ship-to party
         BLDAT TYPE BLDAT,                   ""Document Date in Document
       END OF TY_LIKP.

TYPES: BEGIN OF TY_TVST,
         VSTEL TYPE VSTEL,                   ""Shipping Point/Receiving Point
         ADRNR TYPE ADRNR,                   ""Address
       END OF TY_TVST.

TYPES: BEGIN OF TY_ADRC,
         ADDRNUMBER TYPE AD_ADDRNUM,         ""Address Number
         NAME1      TYPE AD_NAME1,           ""Name 1
         CITY1      TYPE AD_CITY1,           ""City
         POST_CODE1 TYPE AD_PSTCD1,          ""City postal code
         STREET     TYPE AD_STREET,          ""Street
         STR_SUPPL1 TYPE AD_STRSPP1,         ""Street 2
         STR_SUPPL2 TYPE AD_STRSPP2,         ""Street 3
       END OF TY_ADRC.

TYPES: BEGIN OF TY_KNA1,
         KUNNR TYPE KUNNR,                  ""Customer Number
         ADRNR TYPE ADRNR,                  ""Address
         LAND1 TYPE	LAND1_GP,               ""Country Key
       END OF TY_KNA1.

TYPES: BEGIN OF TY_T005T,
         SPRAS TYPE SPRAS,                  ""Language Key
         LAND1 TYPE LAND1,                  ""Country Key
         LANDX TYPE LANDX,                  ""Country Name
       END OF TY_T005T.

TYPES: BEGIN OF TY_LIPS,
         VBELN        TYPE VBELN_VL,       ""Delivery
         POSNR        TYPE POSNR_VL,       ""Delivery Item
         MATNR        TYPE MATNR,          ""Material Number
         LGORT        TYPE LGORT_D,        ""Storage location
         LFIMG        TYPE LFIMG,          ""Actual quantity delivered (in sales units)
         VRKME        TYPE VRKME,          ""Sales unit
         VGBEL        TYPE VGBEL,          ""Document number of the reference document
         WRF_CHARSTC2 TYPE WRF_CHARSTC2,   ""Characteristic Value 2
       END OF TY_LIPS.

TYPES: BEGIN OF TY_VBAK,
         VBELN TYPE VBELN_VA,              ""Sales Document
*       MATNR TYPE MATNR,                 ""Material Number
         BSTNK TYPE BSTNK,                 ""Customer Reference
       END OF TY_VBAK.

TYPES: BEGIN OF TY_MARA,
         MATNR       TYPE MATNR,           ""Material Number
         MATKL       TYPE MATKL,           ""Material Group
         SATNR       TYPE SATNR,           ""Cross-Plant Configurable Material
         COLOR_ATINN TYPE WRF_COLOR_ATINN, ""Internal Charactieristic Number for Color Characteristics
         COLOR       TYPE WRF_COLOR,       ""Characteristic Value for Colors of Variants
         SIZE1       TYPE WRF_SIZE1,       ""Characteristic Value for Main Sizes of Variants
       END OF TY_MARA.

TYPES: BEGIN OF TY_WRF_CHARVALT,
         ATINN TYPE ATINN,                 ""Internal characteristic
         ATWRT TYPE WRF_ATWRT,             ""Characteristic Value (Seasonal Procurement)
         SPRAS TYPE SPRAS,                 ""Language Key
         ATWTB TYPE ATWTB,                 ""Characteristic value description
       END OF TY_WRF_CHARVALT.

TYPES: BEGIN OF TY_T006,
         MSEHI   TYPE MSEHI,               ""Unit of Measurement
         FAMUNIT TYPE FAMUNIT,             ""Unit of measurement family
       END OF TY_T006.

TYPES: BEGIN OF TY_VBFA,
         RUUID TYPE SD_DOC_REL_UUID,       ""SD Unique Document Relationship Identification
         VBELV TYPE VBELN_VON,             ""Preceding sales and distribution document
         POSNV TYPE POSNR_VON,             ""Preceding Item of an SD Document
         VBELN TYPE VBELN_NACH,            ""Subsequent Sales and Distribution Document
       END OF TY_VBFA,
********************added on (30-3-20)   ******************
       BEGIN OF TY_MAKT,
         MATNR TYPE MAKT-MATNR,
         SPRAS TYPE MAKT-SPRAS,
         MAKTX TYPE MAKT-MAKTX,
       END OF TY_MAKT.

TYPES : BEGIN OF TY_EKBE,
          EBELN TYPE EKBE-EBELN,
          BELNR TYPE EKBE-BELNR,
          BEWTP TYPE EKBE-BEWTP,
        END OF TY_EKBE,

        BEGIN OF TY_EKKO,
          EBELN     TYPE EKKO-EBELN,
          USER_NAME TYPE EKKO-USER_NAME,
        END OF TY_EKKO,

        BEGIN OF TY_EKPO,
          EBELN TYPE EKPO-EBELN,
          EBELP TYPE ekpo-EBELP,
          END OF TY_EKPO.
************************ end (30-3-20)  ******************************
DATA: XVBELN TYPE VBELN_VL.

DATA: IT_LIKP         TYPE TABLE OF TY_LIKP,
      WA_LIKP         TYPE TY_LIKP,
      IT_LIPS         TYPE TABLE OF TY_LIPS,
      WA_LIPS         TYPE TY_LIPS,
      IT_VBFA         TYPE TABLE OF TY_VBFA,
      WA_VBFA         TYPE TY_VBFA,
      IT_TVST         TYPE TABLE OF TY_TVST,
      WA_TVST         TYPE TY_TVST,
      IT_KNA1         TYPE TABLE OF TY_KNA1,
      WA_KNA1         TYPE TY_KNA1,
      IT_T005T        TYPE TABLE OF TY_T005T,
      WA_T005T        TYPE TY_T005T,
      IT_T005T1       TYPE TABLE OF TY_T005T,
      WA_T005T1       TYPE TY_T005T,
      IT_ADRC         TYPE TABLE OF TY_ADRC,
      WA_ADRC         TYPE TY_ADRC,
      IT_ADRC1        TYPE TABLE OF TY_ADRC,
      WA_ADRC1        TYPE TY_ADRC,
      IT_VBAK         TYPE TABLE OF TY_VBAK,
      WA_VBAK         TYPE TY_VBAK,
      IT_MARA         TYPE TABLE OF TY_MARA,
      WA_MARA         TYPE TY_MARA,
      IT_T006         TYPE TABLE OF TY_T006,
      WA_T006         TYPE TY_T006,
      IT_EKBE         TYPE TABLE OF TY_EKBE,
      WA_EKBE         TYPE TY_EKBE,
      IT_EKKO   TYPE TABLE OF TY_EKKO,
      WA_EKKO TYPE TY_EKKO,
      IT_EKPO TYPE TABLE OF TY_EKPO,
      WA_EKPO TYPE TY_EKPO,
      IT_MAKT         TYPE TABLE OF  TY_MAKT,
      WA_MAKT         TYPE  TY_MAKT,




      IT_WRF_CHARVALT TYPE TABLE OF TY_WRF_CHARVALT,
      WA_WRF_CHARVALT TYPE TY_WRF_CHARVALT,
      IT_FINAL        TYPE TABLE OF ZFINAL_PICK,
      WA_FINAL        TYPE ZFINAL_PICK,
      WA_HEADER       TYPE ZHEADER_PICK.
DATA : LV_CNT TYPE I VALUE 0.


DATA: FMNAME      TYPE RS38L_FNAM,
      LV_TOTAL(5) TYPE C,
      IT_LINES    TYPE TABLE OF TLINE,
      WA_LINES    TYPE TLINE,
      IT_O_WGH01  TYPE TABLE OF WGH01,
      WA_O_WGH01  TYPE WGH01,
      LV_1(10)    TYPE C,
      LV_2(10)    TYPE C,
      LV_3(10)    TYPE C,
      LV_VBELN    TYPE LIKP-VBELN.

*SELECTION-SCREEN: BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
*
*PARAMETERS: P_VBELN TYPE VBELN_VL.  ""Delivery
*
*SELECTION-SCREEN : END OF BLOCK B1.
BREAK BREDDY.
  lv_VBELN = NAST-OBJKY.

SELECT
  VBELN
  VSTEL
  KODAT
  KUNNR
  BLDAT FROM LIKP INTO TABLE IT_LIKP
  WHERE VBELN =  lv_VBELN.

IF IT_LIKP IS NOT INITIAL.

  SELECT
     VBELN
     POSNR
     MATNR
     LGORT
     LFIMG
     VRKME
     VGBEL
     WRF_CHARSTC2 FROM LIPS INTO TABLE IT_LIPS
     FOR ALL ENTRIES IN IT_LIKP
     WHERE VBELN = IT_LIKP-VBELN
    AND PSTYV = 'NLN'.

  SELECT
    VSTEL
    ADRNR FROM TVST INTO TABLE IT_TVST
    FOR ALL ENTRIES IN IT_LIKP
    WHERE VSTEL = IT_LIKP-VSTEL.
ENDIF.

READ TABLE IT_LIKP INTO WA_LIKP INDEX 1.
IF WA_LIKP IS NOT INITIAL.
  SELECT SINGLE
    KUNNR
    ADRNR
    LAND1 FROM KNA1 INTO WA_KNA1
    WHERE KUNNR = WA_LIKP-KUNNR.

ENDIF.

READ TABLE IT_TVST INTO WA_TVST INDEX 1.
IF WA_TVST IS NOT INITIAL.

  SELECT SINGLE
     ADDRNUMBER
     NAME1
     CITY1
     POST_CODE1
     STREET
     STR_SUPPL1
     STR_SUPPL2 FROM ADRC INTO WA_ADRC
     WHERE ADDRNUMBER = WA_TVST-ADRNR.

ENDIF.

IF WA_KNA1 IS NOT INITIAL.
  SELECT SINGLE
      ADDRNUMBER
      NAME1
      CITY1
      POST_CODE1
      STREET
      STR_SUPPL1
      STR_SUPPL2 FROM ADRC INTO WA_ADRC1
      WHERE ADDRNUMBER = WA_KNA1-ADRNR.

  SELECT SINGLE
    SPRAS
    LAND1
    LANDX FROM T005T INTO WA_T005T
    WHERE LAND1 = WA_KNA1-LAND1
    AND SPRAS   = SY-LANGU.


ENDIF.

IF IT_LIPS IS NOT INITIAL.

  SELECT
    VBELN
    BSTNK FROM VBAK INTO TABLE IT_VBAK
    FOR ALL ENTRIES IN IT_LIPS
    WHERE VBELN = IT_LIPS-VGBEL.

  SELECT
    MATNR
    MATKL
    SATNR
    COLOR_ATINN
    COLOR
    SIZE1 FROM MARA INTO TABLE IT_MARA
    FOR ALL ENTRIES IN IT_LIPS
    WHERE MATNR = IT_LIPS-MATNR.

****************    added on (30-3-20)   ************
    SELECT MATNR
         SPRAS
         MAKTX
         FROM MAKT INTO TABLE IT_MAKT
         FOR ALL ENTRIES IN IT_MARA
         WHERE MATNR = IT_MARA-MATNR.
***************    end(30-3-20)  ******************

  SELECT
    MSEHI
    FAMUNIT FROM T006 INTO TABLE IT_T006
    FOR ALL ENTRIES IN IT_LIPS
    WHERE MSEHI = IT_LIPS-VRKME.

ENDIF.
IF IT_MARA IS NOT INITIAL.

  SELECT
    ATINN
    ATWRT
    SPRAS
    ATWTB FROM WRF_CHARVALT INTO TABLE IT_WRF_CHARVALT
    FOR ALL ENTRIES IN IT_MARA
    WHERE ATINN = IT_MARA-COLOR_ATINN
    AND   ATWRT = IT_MARA-COLOR
    AND   SPRAS = SY-LANGU.





ENDIF.
READ TABLE IT_LIPS INTO WA_LIPS INDEX 1.
IF WA_LIPS IS NOT INITIAL.

  SELECT SINGLE
  RUUID
  VBELV
  POSNV
  VBELN FROM VBFA INTO WA_VBFA
  WHERE VBELN = WA_LIPS-VBELN.

ENDIF.

****************added on (30-3-20)  *********************
IF IT_LIKP IS NOT INITIAL.
  SELECT  EBELN
          BELNR
          BEWTP FROM EKBE INTO TABLE IT_EKBE
          FOR ALL ENTRIES IN IT_LIKP
          WHERE BELNR = IT_LIKP-VBELN AND BEWTP = 'L'.
ENDIF.

IF IT_EKBE IS NOT INITIAL .
  SELECT EBELN
         USER_NAME FROM EKKO INTO TABLE IT_EKKO
         FOR ALL ENTRIES IN IT_EKBE
         WHERE EBELN = IT_EKBE-EBELN.
SELECT EBELN EBELP FROM EKPO INTO TABLE IT_EKPO
          FOR ALL ENTRIES IN IT_EKBE
          WHERE EBELN = IT_EKBE-EBELN.
  ENDIF.
*****************end(30-3-20)  *****************

WA_HEADER-NAME1         = WA_ADRC-NAME1.
WA_HEADER-CITY1         = WA_ADRC-CITY1.
WA_HEADER-POST_CODE1    = WA_ADRC-POST_CODE1.
WA_HEADER-STREET        = WA_ADRC-STREET.
WA_HEADER-STR_SUPPL1    = WA_ADRC-STR_SUPPL1.
WA_HEADER-STR_SUPPL2    = WA_ADRC-STR_SUPPL2.
WA_HEADER-NAME1_SH      = WA_ADRC1-NAME1.
WA_HEADER-CITY1_SH      = WA_ADRC1-CITY1.
WA_HEADER-POST_CODE1_SH = WA_ADRC1-POST_CODE1.
WA_HEADER-STREET_SH     = WA_ADRC1-STREET.
WA_HEADER-STR_SUPPL1_SH = WA_ADRC1-STR_SUPPL1.
WA_HEADER-STR_SUPPL2_SH = WA_ADRC1-STR_SUPPL2.
WA_HEADER-VBELN         = WA_LIKP-VBELN.
WA_HEADER-BLDAT         = WA_LIKP-BLDAT.
WA_HEADER-KODAT         = WA_LIKP-KODAT.
WA_HEADER-LANDX         = WA_T005T-LANDX.
WA_HEADER-LANDX1        = WA_T005T-LANDX.
WA_HEADER-PO_NUM        = WA_LIPS-VGBEL.

WA_HEADER-USER_NAME    = WA_EKKO-USER_NAME.  " added on (30-3-20)

LOOP AT IT_LIPS INTO WA_LIPS.
  LV_1 = WA_LIPS-LFIMG.
  SPLIT LV_1 AT '.' INTO LV_2 LV_3.
  LV_CNT                = LV_CNT + 1.
  WA_FINAL-SL           = LV_CNT .
  WA_FINAL-VRKME        = WA_LIPS-VRKME.
  WA_FINAL-WRF_CHARSTC2 = WA_LIPS-WRF_CHARSTC2.
  WA_FINAL-LFIMG        = LV_2.
  LV_TOTAL              = LV_TOTAL + WA_LIPS-LFIMG.
  WA_FINAL-LGORT        = WA_LIPS-LGORT.
READ TABLE IT_LIKP INTO WA_LIKP WITH KEY VBELN = WA_LIKP-VBELN.  " added on (30-3-20)
*  CALL FUNCTION 'READ_TEXT'
*    EXPORTING
**     CLIENT                        = SY-MANDT
*      ID                            = 'GRUN'
*      LANGUAGE                      = 'EN'
*      NAME                          = MATNR
*      OBJECT                        = 'LIPS'
**     ARCHIVE_HANDLE                = 0
**     LOCAL_CAT                     = ' '
**   IMPORTING
**     HEADER                        =
**     OLD_LINE_COUNTER              =
*    TABLES
*      LINES                         = IT_LINES
**   EXCEPTIONS
**     ID                            = 1
**     LANGUAGE                      = 2
**     NAME                          = 3
**     NOT_FOUND                     = 4
**     OBJECT                        = 5
**     REFERENCE_CHECK               = 6
**     WRONG_ACCESS_TO_ARCHIVE       = 7
**     OTHERS                        = 8
*            .
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.
*IF sy-subrc = 0.
*
*READ TABLE IT_LINES INTO WA_LINES index 1.
*
*WA_FINAL-COLOUR = wa_tlines-tdline.
*CLEAR wa_tline.
*
*ENDIF.


  READ TABLE IT_VBAK INTO WA_VBAK WITH KEY VBELN = WA_LIPS-VGBEL.
  IF SY-SUBRC = 0.
    WA_FINAL-BSTNK        = WA_VBAK-BSTNK.
  ENDIF.

  READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_LIPS-MATNR.
  IF SY-SUBRC = 0.
    WA_FINAL-SATNR = WA_MARA-SATNR.
    WA_FINAL-MATKL = WA_MARA-MATKL.
    WA_FINAL-MATNR = WA_MARA-MATNR.
    WA_FINAL-SIZE  = WA_MARA-SIZE1.
  ENDIF.

******************    added on (30-3-20)  ****************
READ TABLE IT_MAKT INTO WA_MAKT WITH KEY MATNR = WA_MARA-MATNR.
  IF SY-SUBRC = 0.
    WA_FINAL-MAKTX = WA_MAKT-MAKTX.
  ENDIF.
*******************   end(30-3-20)  ***********************
  READ TABLE IT_WRF_CHARVALT INTO WA_WRF_CHARVALT WITH KEY ATINN = WA_MARA-COLOR_ATINN
                                                           ATWRT = WA_MARA-COLOR
                                                           SPRAS = SY-LANGU.
  IF SY-SUBRC = 0.

    WA_FINAL-COLOR = WA_WRF_CHARVALT-ATWTB.

  ENDIF.

*********************************  added on (30-3-30)   *******************
  READ TABLE IT_EKBE INTO WA_EKBE WITH KEY BELNR = WA_LIKP-VBELN.
READ TABLE IT_EKKO INTO WA_EKKO WITH KEY EBELN = WA_EKBE-EBELN.
READ TABLE IT_EKPO INTO WA_EKPO WITH KEY EBELN = WA_EKBE-EBELN.
DATA : DNAME  TYPE  THEAD-TDNAME.
  DATA : IT_RLINES TYPE TABLE OF TLINE,
         WA_RLINES TYPE TLINE.
*  DNAME  = WA_ekPO-EBELN.
 CONCATENATE WA_ekPO-EBELN WA_ekPO-EBElp INTO DNAME.
 CALL FUNCTION 'READ_TEXT'
   EXPORTING
    CLIENT                        = SY-MANDT
     ID                            = 'F01'
     LANGUAGE                      = SY-LANGU
     NAME                          = DNAME
     OBJECT                        = 'EKPO'
*    ARCHIVE_HANDLE                = 0
*    LOCAL_CAT                     = ' '
*  IMPORTING
*    HEADER                        =
*    OLD_LINE_COUNTER              =
   TABLES
     LINES                         = IT_RLINES
  EXCEPTIONS
    ID                            = 1
    LANGUAGE                      = 2
    NAME                          = 3
    NOT_FOUND                     = 4
    OBJECT                        = 5
    REFERENCE_CHECK               = 6
    WRONG_ACCESS_TO_ARCHIVE       = 7
    OTHERS                        = 8
           .
 IF SY-SUBRC <> 0.
* Implement suitable error handling here
 ENDIF.
 READ TABLE IT_RLINES INTO WA_RLINES INDEX 1.
  WA_FINAL-TDLINE1 = WA_RLINES-TDLINE.
  CLEAR WA_RLINES .

************************  end(30-3-20)  ********************


  CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
    EXPORTING
      MATKL       = WA_FINAL-MATKL
      SPRAS       = SY-LANGU
    TABLES
      O_WGH01     = IT_O_WGH01
    EXCEPTIONS
      NO_BASIS_MG = 1
      NO_MG_HIER  = 2
      OTHERS      = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  READ TABLE IT_O_WGH01 INTO WA_O_WGH01 INDEX 1.
  IF SY-SUBRC = 0.

    WA_FINAL-HIER = WA_O_WGH01-WWGHA.
    WA_HEADER-HIER = WA_FINAL-HIER.    " added on (30-3-20) for gruop name
    CLEAR WA_O_WGH01.
  ENDIF.



  READ TABLE IT_T006 INTO WA_T006 WITH KEY MSEHI = WA_LIPS-VRKME.

  IF SY-SUBRC = 0.
    WA_FINAL-FAMUNIT = WA_T006-FAMUNIT.
  ENDIF.

  APPEND WA_FINAL TO IT_FINAL.
  CLEAR: WA_FINAL,WA_T006,WA_LIPS.

ENDLOOP.


CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    FORMNAME           = 'ZSD_PICK_LISTF'
*   VARIANT            = ' '
*   DIRECT_CALL        = ' '
  IMPORTING
    FM_NAME            = FMNAME
  EXCEPTIONS
    NO_FORM            = 1
    NO_FUNCTION_MODULE = 2
    OTHERS             = 3.
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

CALL FUNCTION FMNAME
  EXPORTING
    WA_HEADER        = WA_HEADER
    LV_TOTAL         = LV_TOTAL
    lv_vbeln         = lv_VBELN
  TABLES
    IT_FINAL         = IT_FINAL
  EXCEPTIONS
    FORMATTING_ERROR = 1
    INTERNAL_ERROR   = 2
    SEND_ERROR       = 3
    USER_CANCELED    = 4
    OTHERS           = 5.
IF SY-SUBRC <> 0.
*           Implement suitable error handling here
ENDIF.

ENDFORM.
