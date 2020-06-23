*&---------------------------------------------------------------------*
*& Include          ZMM_IVENDOR_MASTERR_C01_TOP
*&---------------------------------------------------------------------*

TYPES : BEGIN OF TA_FLATFILE,

          ORG(5),
          BU_PARTNER(10),
          CREATION_GROUP(4),
          PARTNER_ROLE(7),
          TITLE_MEDI(30),                  " Genaral Data
          NAME_ORG1(40),
          NAME_ORG2(40),
          NAME_ORG3(40),
          NAME_ORG4(40),
          SORT1             TYPE BU_SORT1,
          STREET(60),
          HOUSE_NUM1(10),
          STR_SUPPL1(40),
          STR_SUPPL2(40),
          STR_SUPPL3(40),
          STR_SUPPL4(40),
          POST_CODE1(10),
          CITY1(40),
          COUNTRY(03),
          REGION(03),
          LANGU(04),
          TEL_NUMBER(30),
          TEL_EXTENS(10),
          MOB_NUMBER(10),
          FAX_NUMBER(30),
          SMTP_ADDR(241),
          CALENDARID(02),
          FOUND_DAT(10),
          BPEXT(20),
          BPKIND(04),                      " Control
          SOURCE(04),
          PROFS(32),
          KONZS(10),
          SPERZ(01),
          FITYP(02),                       " Supplier: Tax Data
          FISKN(10),
          J_1IEXCD(40),                    " Vendor: Cntry Specific Enh. - CIN
          J_1IEXRN(40),
          J_1IEXRG(60),
          J_1IEXDI(60),
          J_1IEXCO(60),
          J_1IVTYP(02),
          J_1I_CUSTOMS(01),
          J_1IEXCIVE(01),
          J_1ISSIST(01),
          J_1IVENCRE(01),
          J_1ICSTNO(40),
          J_1ILSTNO(40),
          J_1ISERN(40),
          J_1IPANNO(40),
          VEN_CLASS(01),
          J_1IPANVALDT(10),
          BUKRS(04),                       " Company Code
          AKONT(10),
          LNRZE(10),
          ZUAWA(03),
          FDGRV(10),
          QSSKZ(02),
          QLAND(03),
          QSREC(02),
          QSZNR(10),
          QSZDT(10),
          XAUSZ(01),
          ZTERM(04),                       " Supplier: Payment Transaction
          GUZTE(04),
          REPRF(01),
          ZWELS(10),
          ZAHLS(01),
          XVERR(01),
          """""Tax numbers tax cat and no adden on 22/12/2017 by THB
          TAXTYPE(04),"
          TAXNUMXL(60),
          """"""""""""""""""""ended
          BANKS(3),
          BANKL(15),
          BANKN(18),
          WITHT(2),
          WT_WITHCD(2),
          WT_SUBJCT,
          QSREC1(2),
*          wt_wtstcd(16),
          WITHT1(2),  ""added on 22/12/2017
          WT_WITHCD1(2),
          WT_SUBJCT1,
          QSREC2(02),
          ""ended
          PARTNER_ROLE1(07),
          EKORG(04),                       " Purchasing
          WAERS(05),
          INCO1(03),
          INCO2_L(70),
          INCO3_L(70),
          VERKF(30),
          TELF1(16),
          LFABC(01),
          VSBED(02),
          WEBRE(01),
          NRGEW(01),
          LEBRE(01),
          KZABS(01),                       " Purchasing Organization Level
          EKGRP(03),
          PLIFZ(03),
          KALSK(04),
          MEPRF(01),
          BSTAE(04),
          MRPPP(10),
          "new fields
          TRANSPZONE(10),
          BPROLE(10),
          VKORG(5),                                                         " Sales organization
          VTWEG(3),                                                         " Distribution channel
          SPART(2),                                                         " Division
          BZIRK             TYPE KNVV-BZIRK,
          KONDA             TYPE KNVV-KONDA,                                 " Price Group
          KALKS             TYPE KNVV-KALKS,                                 " Cust.Pric.Procedure
          LPRIO             TYPE CVIS_KNVV_DYNP-LPRIO,                       " Delivery Priority
          VSBED1            TYPE KNVV-VSBED,                                 " Shipping conditions
          TAXKD1            TYPE KNVI-TAXKD,                                 " Tax classification
          TAXKD2            TYPE KNVI-TAXKD,                                 " Tax classification
          TAXKD3            TYPE KNVI-TAXKD,                                 " Tax classification
          TAXKD4            TYPE KNVI-TAXKD,                                 " Tax classification
          TAXKD5            TYPE KNVI-TAXKD,                                 " Tax classification

        END OF TA_FLATFILE,
        TA_T_FLATFILE TYPE TABLE OF TA_FLATFILE.

FIELD-SYMBOLS: <FS_FLATFILE> TYPE TA_FLATFILE.


DATA: TA_FLATFILE             TYPE TA_T_FLATFILE,
      WA_FLATFILE             TYPE TA_FLATFILE,

      TA_EXCEL                TYPE TRUXS_T_TEXT_DATA,
      WA_EXCEL                TYPE ALSMEX_TABLINE,

      PARTNER                 TYPE BAPIBUS1006_HEAD-BPARTNER,
      PARTNER_ROLE            TYPE BUS_JOEL_MAIN-PARTNER_ROLE,
      PARTNERCATEGORY         TYPE BAPIBUS1006_HEAD-PARTN_CAT,
      PARTNERTYPE             TYPE BAPIBUS1006_HEAD-PARTN_TYP,
      PARTNERGROUP            TYPE BAPIBUS1006_HEAD-PARTN_GRP,
      CENTRALDATA             TYPE BAPIBUS1006_CENTRAL,
      CENTRALDATAPERSON       TYPE BAPIBUS1006_CENTRAL_PERSON,
      CENTRALDATAORGANIZATION TYPE BAPIBUS1006_CENTRAL_ORGAN,
*      businesspartnerextern   TYPE bapibus1006_head-partnerrole
      CENTRALDATAGROUP        TYPE BAPIBUS1006_CENTRAL_GROUP,
      ADDRESSDATA             TYPE BAPIBUS1006_ADDRESS,

      WA_TELEFONDATA          TYPE BAPIADTEL,
      IT_TELEFONDATA          TYPE TABLE OF BAPIADTEL,             " Telephone Numbers

      WA_FAXDATA              TYPE BAPIADFAX,
      IT_FAXDATA              TYPE TABLE OF BAPIADFAX,                 " Fax Numbers

      WA_E_MAILDATA           TYPE BAPIADSMTP,
      IT_E_MAILDATA           TYPE STANDARD TABLE OF BAPIADSMTP,             " E-Mail Addresses

      IT_RETURN               TYPE TABLE OF BAPIRET2,
      WA_RETURN               TYPE BAPIRET2,
      ET_RETURN               TYPE BAPIRET2 OCCURS 0 WITH HEADER LINE,
      BAPIRETURN              TYPE BAPIRET2,
      TITLE_KEY               TYPE AD_TITLE,
      SEARCHTERM1             TYPE  BU_SORT1,
      SEARCHTERM2             TYPE  BU_SORT2.
DATA : LV_SLNO(5) TYPE I .
TYPES: BEGIN OF TY_DISPLAY,
         SLNO(5) TYPE I,
         ID      TYPE SYMSGID,
         ROLE    TYPE BAPIBUS1006_BPROLES-PARTNERROLECATEGORY,
         BP_NUM  TYPE PARTNER,
         MESSAGE TYPE BAPI_MSG,
         LIFNR   TYPE LIFNR,
         SORT    TYPE BU_SORT1_TXT,
       END OF TY_DISPLAY,
       TY_T_DISPLAY TYPE TABLE OF TY_DISPLAY.

DATA: FNAME TYPE LOCALFILE,
      ENAME TYPE CHAR4.

DATA: WA_DISPLAY TYPE TY_DISPLAY,
      IT_DISPLAY TYPE TY_T_DISPLAY.


DATA: CTUMODE LIKE CTU_PARAMS-DISMODE VALUE 'N',
      CUPDATE LIKE CTU_PARAMS-UPDMODE VALUE 'A'.

DATA:WA_TAXNUM TYPE DFKKBPTAXNUM.
DATA :F_OPTION   TYPE CTU_PARAMS,
      WA_BDCDATA TYPE BDCDATA,
      IT_BDCDATA TYPE STANDARD TABLE OF BDCDATA,
      IT_MSGCOLL TYPE STANDARD TABLE OF BDCMSGCOLL.
