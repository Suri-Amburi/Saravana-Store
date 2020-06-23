*&---------------------------------------------------------------------*
*& Include          ZMM_BP_VEND_EXT_TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF ta_flatfile,

          org(5),
          bu_partner(10),
          creation_group(4),
          partner_role(7),
          title_medi(30),                  " Genaral Data
          name_org1(40),
          name_org2(40),
          name_org3(40),
          name_org4(40),
          sort1             TYPE bu_sort1,
          street(60),
          house_num1(10),
          str_suppl1(40),
          str_suppl2(40),
          str_suppl3(40),
          str_suppl4(40),
          post_code1(10),
          city1(40),
          country(03),
          region(03),
          langu(04),
          tel_number(30),
          tel_extens(10),
          mob_number(10),
          fax_number(30),
          smtp_addr(241),
          calendarid(02),
          found_dat(10),
          bpext(20),
          bpkind(04),                      " Control
          source(04),
          profs(32),
          konzs(10),
          sperz(01),
          fityp(02),                       " Supplier: Tax Data
          fiskn(10),
          j_1iexcd(40),                    " Vendor: Cntry Specific Enh. - CIN
          j_1iexrn(40),
          j_1iexrg(60),
          j_1iexdi(60),
          j_1iexco(60),
          j_1ivtyp(02),
          j_1i_customs(01),
          j_1iexcive(01),
          j_1issist(01),
          j_1ivencre(01),
          j_1icstno(40),
          j_1ilstno(40),
          j_1isern(40),
          j_1ipanno(40),
          VEN_CLASS(01),
          j_1ipanvaldt(10),
          bukrs(04),                       " Company Code
          akont(10),
          lnrze(10),
          zuawa(03),
          fdgrv(10),
          qsskz(02),
          qland(03),
          qsrec(02),
          qsznr(10),
          qszdt(10),
          xausz(01),
          zterm(04),                       " Supplier: Payment Transaction
          guzte(04),
          reprf(01),
          zwels(10),
          zahls(01),
          xverr(01),
       """""Tax numbers tax cat and no adden on 22/12/2017 by THB
          TAXTYPE(04),"
          TAXNUMXL(60),
       """"""""""""""""""""ended
          banks(3),
          bankl(15),
          bankn(18),
          witht(2),
          wt_withcd(2),
          wt_subjct,
          qsrec1(2),
*          wt_wtstcd(16),
          witht1(2),  ""added on 22/12/2017
          wt_withcd1(2),
          wt_subjct1,
          qsrec2(02),
          ""ended
          partner_role1(07),
          ekorg(04),                       " Purchasing
          waers(05),
          inco1(03),
          inco2_l(70),
          inco3_l(70),
          verkf(30),
          telf1(16),
          lfabc(01),
          vsbed(02),
          webre(01),
          nrgew(01),
          lebre(01),
          kzabs(01),                       " Purchasing Organization Level
          ekgrp(03),
          plifz(03),
          kalsk(04),
          meprf(01),
          bstae(04),
          mrppp(10),
          "new fields
          transpzone(10),
          bprole(10),
          vkorg(5),                                                         " Sales organization
          vtweg(3),                                                         " Distribution channel
          spart(2),                                                         " Division
          bzirk             TYPE knvv-bzirk,
          konda             TYPE knvv-konda,                                 " Price Group
          kalks             TYPE knvv-kalks,                                 " Cust.Pric.Procedure
          lprio             TYPE cvis_knvv_dynp-lprio,                       " Delivery Priority
          vsbed1            TYPE knvv-vsbed,                                 " Shipping conditions
          taxkd1            TYPE knvi-taxkd,                                 " Tax classification
          taxkd2            TYPE knvi-taxkd,                                 " Tax classification
          taxkd3            TYPE knvi-taxkd,                                 " Tax classification
          taxkd4            TYPE knvi-taxkd,                                 " Tax classification
          taxkd5            TYPE knvi-taxkd,                                 " Tax classification

        END OF ta_flatfile,
        ta_t_flatfile TYPE TABLE OF ta_flatfile.

FIELD-SYMBOLS: <fs_flatfile> TYPE ta_flatfile.


DATA: ta_flatfile             TYPE ta_t_flatfile,
      wa_flatfile             TYPE ta_flatfile,

      ta_excel                TYPE truxs_t_text_data,
      wa_excel                TYPE alsmex_tabline,

      partner                 TYPE bapibus1006_head-bpartner,
      partner_role            TYPE bus_joel_main-partner_role,
      partnercategory         TYPE bapibus1006_head-partn_cat,
      partnertype             TYPE bapibus1006_head-partn_typ,
      partnergroup            TYPE bapibus1006_head-partn_grp,
      centraldata             TYPE bapibus1006_central,
      centraldataperson       TYPE bapibus1006_central_person,
      centraldataorganization TYPE bapibus1006_central_organ,
*      businesspartnerextern   TYPE bapibus1006_head-partnerrole
      centraldatagroup        TYPE bapibus1006_central_group,
      addressdata             TYPE bapibus1006_address,

      wa_telefondata          TYPE bapiadtel,
      it_telefondata          TYPE TABLE OF bapiadtel,             " Telephone Numbers

      wa_faxdata              TYPE bapiadfax,
      it_faxdata              TYPE TABLE OF bapiadfax,                 " Fax Numbers

      wa_e_maildata           TYPE bapiadsmtp,
      it_e_maildata           TYPE STANDARD TABLE OF bapiadsmtp,             " E-Mail Addresses

      it_return               TYPE TABLE OF bapiret2,
      wa_return               TYPE bapiret2,
      et_return               TYPE bapiret2 OCCURS 0 WITH HEADER LINE,
      bapireturn              TYPE bapiret2,
      title_key               TYPE ad_title,
      searchterm1             TYPE  bu_sort1,
      searchterm2             TYPE  bu_sort2.

TYPES: BEGIN OF ty_display,
         id      TYPE symsgid,
         role    TYPE bapibus1006_bproles-partnerrolecategory,
         bp_num  TYPE partner,
         message TYPE bapi_msg,
         lifnr   TYPE lifnr,
         sort    TYPE bu_sort1_txt,
       END OF ty_display,
       ty_t_display TYPE TABLE OF ty_display.

DATA: fname TYPE localfile,
      ename TYPE char4.

DATA: wa_display TYPE ty_display,
      it_display TYPE ty_t_display.


  DATA: CTUMODE LIKE CTU_PARAMS-DISMODE VALUE 'N',
        CUPDATE LIKE CTU_PARAMS-UPDMODE VALUE 'A'.

data:wa_taxnum TYPE DFKKBPTAXNUM.
DATA :F_OPTION TYPE CTU_PARAMS,
      WA_BDCDATA  TYPE BDCDATA,
      IT_BDCDATA  TYPE STANDARD TABLE OF BDCDATA,
      IT_MSGCOLL  TYPE STANDARD TABLE OF BDCMSGCOLL.
