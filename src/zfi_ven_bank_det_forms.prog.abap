*&---------------------------------------------------------------------*
*& Include          ZFI_VEN_BANK_DET_FORMS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

  BREAK BREDDY.
  SELECT SINGLE
  BSEG~AUGBL ,
  BSEG~AUGDT ,
  BSEG~DMBTR ,
  BSEG~LIFNR ,
  LFBK~BANKL ,
  LFBK~BANKN ,
  BNKA~BANKA ,
  BNKA~STRAS ,
  BNKA~ORT01 ,
  BNKA~BRNCH ,
  ADRC~CITY1 ,
  ADRC~NAME1 ,
  ADRC~POST_CODE1 ,
  ADRC~STREET INTO @GT_DATA
  FROM BSEG AS BSEG
  LEFT OUTER JOIN LFBK AS LFBK ON BSEG~LIFNR = LFBK~LIFNR
  LEFT OUTER JOIN BNKA AS BNKA ON LFBK~BANKL = BNKA~BANKL
  LEFT OUTER JOIN LFA1 AS LFA1 ON BSEG~LIFNR = LFA1~LIFNR
  LEFT OUTER JOIN ADRC AS ADRC ON LFA1~ADRNR = ADRC~ADDRNUMBER
  WHERE AUGBL = @CL_DOC AND BSEG~H_BLART = 'KZ'.



  WA_HEADER-AUGDT      = GT_DATA-AUGDT.
  WA_HEADER-DMBTR      = GT_DATA-DMBTR.
  WA_HEADER-LIFNR      = GT_DATA-LIFNR.
  WA_HEADER-BANKL      = GT_DATA-BANKL.
  WA_HEADER-BANKN      = GT_DATA-BANKN.
  WA_HEADER-BANKA      = GT_DATA-BANKA.
  WA_HEADER-STRAS      = GT_DATA-STRAS.
  WA_HEADER-ORT01      = GT_DATA-ORT01.
  WA_HEADER-BRNCH      = GT_DATA-BRNCH.
  WA_HEADER-CITY1      = GT_DATA-CITY1.
  WA_HEADER-NAME1      = GT_DATA-NAME1.
  WA_HEADER-POST_CODE1 = GT_DATA-POST_CODE1.
  WA_HEADER-STREET     = GT_DATA-STREET.





ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_FORM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ALV_FORM .
  DATA FMNAME TYPE RS38L_FNAM.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZFI_VEN_BANK_DET_FORM'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
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
    EXCEPTIONS
      FORMATTING_ERROR = 1
      INTERNAL_ERROR   = 2
      SEND_ERROR       = 3
      USER_CANCELED    = 4
      OTHERS           = 5.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
