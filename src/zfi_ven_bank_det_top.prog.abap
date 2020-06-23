*&---------------------------------------------------------------------*
*& Include          ZFI_VEN_BANK_DET_TOP
*&---------------------------------------------------------------------*




TYPES : BEGIN OF TY_GT_DATA  ,
          AUGBL      TYPE AUGBL,
          AUGDT      TYPE AUGDT,
          DMBTR      TYPE DMBTR,
          LIFNR      TYPE LIFNR ,            ""vendor
          BANKL      TYPE BANKK ,           "" bank key
          BANKN      TYPE BANKN ,           ""bank account
          BANKA      TYPE BANKA ,           ""BANK NAME
          STRAS      TYPE STRAS_GP ,        ""street
          ORT01      TYPE ORT01_GP ,        ""city
          BRNCH      TYPE BRNCH ,           ""bank name
          CITY1      TYPE AD_CITY1,
          NAME1      type AD_NAME1,
          POST_CODE1 TYPE AD_PSTCD1,
          STREET     TYPE AD_STREET,
        END OF TY_GT_DATA  .

DATA : GT_DATA   TYPE  TY_GT_DATA,
       WA_HEADER TYPE  ZHEADER_BD.
