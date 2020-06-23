*&---------------------------------------------------------------------*
*& Include          ZHR_I6789_INFOTYPE_CNV_TOP
*&---------------------------------------------------------------------*

  TYPES:BEGIN OF gty_0006,
          pernr(8),
          begda(10),
          endda(10),
          subty(4),
          stras(60),
          locat(40),
          pstlz(10),
          ort01(40),
          ort02(40),
          state(3),
          land1(3),
          telnr(10),
          busrt(3),
        END OF gty_0006,
        gty_t_0006 TYPE STANDARD TABLE OF gty_0006,

        BEGIN OF gty_0007,
          pernr(8),
          begda(10),
          endda(10),
          schkz(8),
          zterf,
          empct(7),
          arbst(7),
          wkwdy(6),
        END OF gty_0007,
        gty_t_0007 TYPE STANDARD TABLE OF gty_0007,

        BEGIN OF gty_0008,
          pernr(8),
          begda(10),
          endda(10),
          trfar(2),
          bsgrd(7),
          trfgb(2),
          divgv(7),
          trfgr(8),
          trfst(2),
          ancur(5),
          waers(5),
          lga01(5),
          bet01(15),
          lga02(5),
          bet02(15),
          lga03(5),
          bet03(15),
          lga04(5),
          bet04(15),
          lga05(5),
          bet05(15),
          lga06(5),
          bet06(15),
          lga07(5),
          bet07(15),
          lga08(5),
          bet08(15),
          lga09(5),
          bet09(15),
          lga10(5),
          bet10(15),
          lga11(5),
          bet11(15),
          lga12(5),
          bet12(15),
          lga13(5),
          bet13(15),
          lga14(5),
          bet14(15),
          lga15(5),
          bet15(15),
          lga16(5),
          bet16(15),
          lga17(5),
          bet17(15),
          lga18(5),
          bet18(15),
          lga19(5),
          bet19(15),
          lga20(5),
          bet20(15),
        END OF gty_0008,
        gty_t_0008 TYPE STANDARD TABLE OF gty_0008,

        BEGIN OF gty_0009,
          pernr(8),
          begda(10),
          endda(10),
          bnksa(4),
          emftx(40),
          bkplz(10),
          bkort(25),
          banks(4),
          bankl(15),
          bankn(18),
          zlsch,
          waers(5),
        END OF gty_0009,
        gty_t_0009 TYPE STANDARD TABLE OF gty_0009.

  DATA:it_0006 TYPE gty_t_0006,
       wa_0006 TYPE gty_0006,

       it_0007 TYPE gty_t_0007,
       wa_0007 TYPE gty_0007,

       it_0008 TYPE gty_t_0008,
       wa_0008 TYPE gty_0008,

       it_0009 TYPE gty_t_0009,
       wa_0009 TYPE gty_0009.

  DATA:fname      TYPE localfile,
       ename      TYPE char4,

       lv_begda   TYPE p0001-begda,
       lv_endda   TYPE p0001-endda,
       gwa_return TYPE bapireturn1.

  TYPES:BEGIN OF gty_display,
          type  TYPE bapi_mtype,
          pernr TYPE pernr,
          infty TYPE infty,
          msg	  TYPE bapi_msg,
        END OF gty_display,
        gty_t_display TYPE STANDARD TABLE OF gty_display.

  DATA:gwa_display TYPE gty_display,
       git_display TYPE gty_t_display.