*&---------------------------------------------------------------------*
*& Include          ZFI_GL_UPD_TOP
*&---------------------------------------------------------------------*
TYPES: BEGIN OF TY_DATA,
         SAKNR    TYPE GLACCOUNT_SCREEN_KEY-SAKNR,          "Gl Account
         BUKRS    TYPE GLACCOUNT_SCREEN_KEY-BUKRS,          " Company code
         GLTYP    TYPE GLACCOUNT_SCREEN_COA-GLACCOUNT_TYPE, "GL Account Type
         KTOKS    TYPE GLACCOUNT_SCREEN_COA-KTOKS,        "Account Group
         TXT20_ML TYPE GLACCOUNT_SCREEN_COA-TXT20_ML,  "Short Text
         TXT50_ML TYPE GLACCOUNT_SCREEN_COA-TXT50_ML,  "Long Text
         WAERS    TYPE GLACCOUNT_SCREEN_CCODE-WAERS,      " Currency
         XSALH    TYPE GLACCOUNT_SCREEN_CCODE-XSALH,      "Bal in local currency
         MWSKZ    TYPE GLACCOUNT_SCREEN_CCODE-MWSKZ,      "Tax Category
         XMWNO    TYPE GLACCOUNT_SCREEN_CCODE-XMWNO,      "Tax Code not required field
         MITKZ    TYPE GLACCOUNT_SCREEN_CCODE-MITKZ,      "Recon. Acct. Type
         XOPVW    TYPE GLACCOUNT_SCREEN_CCODE-XOPVW,      "Openitem mgt
         ZUAWA    TYPE GLACCOUNT_SCREEN_CCODE-ZUAWA,      "Sort Key
         KATYP    TYPE GLACCOUNT_SCREEN_CAREA-KATYP,      "Cost Element Category
         FSTAG    TYPE GLACCOUNT_SCREEN_CCODE-FSTAG,      "Field Status Group
         XINTB    TYPE GLACCOUNT_SCREEN_CCODE-XINTB,      "Post Automatically
         XGKON    TYPE GLACCOUNT_SCREEN_CCODE-XGKON,      "Relavant to Cash flow

       END OF TY_DATA,


       BEGIN OF TY_LOG,

         SAKNR    TYPE GLACCOUNT_SCREEN_KEY-SAKNR,          "Gl Account
         BUKRS    TYPE GLACCOUNT_SCREEN_KEY-BUKRS,          " Company code
         TCODE    TYPE BDC_TCODE,
         DYNAME   TYPE BDC_MODULE,
         DYNUMB   TYPE BDC_DYNNR,
         MSGTYP   TYPE BDC_MART,
         MSGSPRA  TYPE  BDC_SPRAS,
         MSGID    TYPE  BDC_MID,
         MSGNR    TYPE  BDC_MNR,
         MSGV1    TYPE  BDC_VTEXT1,
         MSGV2    TYPE BDC_VTEXT1,
         MSGV3    TYPE BDC_VTEXT1,
         MSGV4    TYPE BDC_VTEXT1,
         ENV      TYPE BDC_AKT,
         FLDNAME  TYPE  FNAM_____4,
         MSG_TEXT TYPE STRING,
       END OF TY_LOG.


DATA: GT_DATA TYPE TABLE OF TY_DATA,
      WA_DATA TYPE TY_DATA.

DATA: IT_BDCDATA  TYPE TABLE OF BDCDATA,
      WA_BDCDATA  TYPE BDCDATA,
      IT_MESSTAB  TYPE TABLE OF BDCMSGCOLL,
      WA_MESSTAB  TYPE BDCMSGCOLL,
      IT_LOG      TYPE TABLE OF TY_LOG,
      WA_LOG      TYPE TY_LOG,
      IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      WA_LAYOUT   TYPE SLIS_LAYOUT_ALV.

DATA: CTUMODE LIKE CTU_PARAMS-DISMODE VALUE 'N',
      CUPDATE LIKE CTU_PARAMS-UPDMODE VALUE 'A',
      LS_OPT  TYPE CTU_PARAMS.
