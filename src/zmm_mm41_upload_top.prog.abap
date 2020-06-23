*&---------------------------------------------------------------------*
*& Include          ZMM_MM41_UPLOAD_TOP
*&---------------------------------------------------------------------*
data: wa_head like bapie1mathead,
      wa_return like bapireturn1.

types: begin of t_clientext.
       include structure bapie1maraextrt.
types: end of t_clientext.
data: wa_clientext type t_clientext,
      it_clientext type table of t_clientext.

types: begin of t_clientextx.
       include structure bapie1maraextrtx.
types: end of t_clientextx.
data: wa_clientextx type t_clientextx,
      it_clientextx type table of t_clientextx.
TYPE-POOLS:slis.

TYPES:BEGIN OF ta_flatfile,
        sitemmasterid(20),  " Field Description
*        matnr(40),         " Material no.
*        mbrsh(1),          " Industry sector
        mtart(4),           " Material type
        matkl(9),           " Material Group
        ATTYP(2),           " Material Cat
  "basic data1
        MAKTX(50) ,         " Material Desc
        MEINH(3),           "UOM
        EAN11(18),          "EAN Nor
        NUMTP(3),           "Category of International Article Number
       spart(2),            " Division
       WBKLA(4),            "Valuation Class
       TRAGR(4),              "Trasfer Group
        WLADG(4),             "Loading Group
*Organizational data
        werks(4),           " Plant
        lgort(4),           " Storage Location
        vkorg(4),           " Sales Organization
        vtweg(2),           " Distribution Channel
        dispr(10),          " MRP Profile
*Basic Data1
        bd1(1),
*        maktx(50),          " Material Description
        meins(3),          " Base Unit of Measure

        bismt(40),          " Old Material No
        extwg(9),           " External Material Group

        labor(30),           " Lab/Office
        brgew(13),           " Gross Weight
        gewei(2),           " Weight Unit
        ntgew(13),           " Net weight
        volum(10),          " Volume
        voleh(10),          " Volume Unit
        groes(30),          " Size/Dimensions
        maktx1(50),         " Basic Data Text
*Basic Data2
*        bd2(1),
*        ferth(25),          " Prod./Insp.memo
*        normt(15),          " Ind. Std Desc.
*        formt(1),           " Page Format
*        wrkst(9),           " Basic Material
*        msbookpartno(60),   " MS Book Part Number
*        zeinr(20),          " Document
*        zeiar(3),           " Document Type
*        zeivr(10),          " Document Version
*        adspc_spc(1),       " Spare Part Class Code
*        ovlpn(10),          " Overlength Part Number
*        umren(10),          " Unit of Measure
*        meinh(10),          " Alternative Unit of Measure
*        umrez(10),          " Units of Measure ( Numerator for conversion to base unit of measure)
**Classification View
*        cv(1),
*        klart(3),           " Class Type
*        class(18),           " Class
**Sales Org1
*        sod1(1),
*        dwerk(4),           " Delivering Plant
*        taxkm(1),           " Tax classification material
**Slaes Org2
*        sod2(1),
*        versg(1),           " Matl statistics grp
*        prodh(10),          " Product hierarchy
*        ktgrm(10),          " Acct assignment grp
*        mtpos(4),           " Item category group
**Sales: General/Plant
*        sgp(1),
*        mtvfp(2),           " Availability check
*        mfrgr(8),           " Material freight grp
*        tragr(4),           " Trans. Grp
*        ladgr(4),           " LoadingGrp
*        prctr(4),           " Profit Center
**SOTF "Sales and Distributit
*        sotf(1),
*        stext(60),          " SALES TEXT
**PF "Purchasing
*        pf(1),
*        ekgrp(3),           " Purchasing Group
*        kautb(1),           " Automatic PO
*        xchpf(1),           " Batch Management
*        ekwsl(4),           " Purchasing Value Key
*        webaz(5),           " GR Processing Time
*        kzkri(1),           " Indicator: Critical part
*        mprof(10),          " Mfr Part Profile
*        mfrpn(10),          " Mfr. Part NumPOTEXTber
*        mfrnr(10),          " Manufact.
**POV " Purchase order text
*        pov(1),
*        potext(60),         " PURCHASE ORDER TEXT
**MRP1
*        mrp1(1),
*        disgr(4),           " MRP group
*        maabc(1),           " ABC Indicator
*        dismm(2),           " MRP Type
*        minbe(3),           " Reorder Point
*        dispo(3),           " MRP Controller
*        disls(2),           " Lot Size
*        bstmi(15),          " Minimum Lot Size
*        bstma(15),          " Maximum Lot Size
*        bstfe(3),           " Fixed Lot Size
**MRP2
*        mrp2(1),
*        beskz(1),           " Procurement Type
*        sobsl(2),           " Special Procurement
*        lgpro(4),           " Prod. Storage Location
*        rgekz(1),           " Indicator: Backflush
*        schgt(10),          " Indicator: Bulk Material
*        dzeit(2),           " In-house Production
*        plifz(2),           " Plnd delivery time
*        fhori(3),           " Schedulemargin Key
*        eisbe(15),              " Safety STock
**MRP3
*        mrp3(1),
*        strgr(2),           " Strategy Group
*        vrmod(1),           " Consumption Mode
*        vint1(2),           " Bwd. Consumption per.
*        vint2(2),           " Fwd. Consumption Per.
**MRP4
*        mrp4(1),
*        sbdkz(1),           " Individual/Coll
**Forecast View
*        fv(1),
*        prmod(1),           " Forecast Model
**        lgpbe(10),          " Storage Bin
**WS
*        ws(1),
*        sfcpf(6),           " Production Scheduling Profile
*        sernp(20),          " Serial No. Profile
**PRT
*        prt(1),
*        planv(10),          " Task list usage
*        steuf(20),          " Control key
**PDS1
*        pds1(1),
*        lgpbe(12),          " Storage Bin
*        maxlx(20),          " Maximum Storage Period
*        lzeih(3),           " Time Unit
**QMV "Quality Management
*        qmv(1),
*        kzdkz(1),           " Documentation required indicator
*        qmpur(1),           " QM in Procurement is Active
*        ssqss(4),           " Control Key for Quality Management in Procurement
*        qzgtp(3),           " Certificate Type
*        art(2),             " Inspection Type
*        aktiv(1),           " Inspection Type active
**AC1 "Accounting 1
*        ac1(1),
*        bklas(4),           " Valuation Class
*        mlast(1),           " Price Determination
*        vprsv(1),           " Price Control
*        pvprs_1(15),         " Periodic Unit Price
*        stprs(15),           " Standard Price
**CEV
*        cev(1),
*        ekalr(1),           " With Quantity Structure
*        hkmat(1),           " Material Origin
*        ncost,              " Do not check
*        kosgr(10),          " Overhead Group
      END OF ta_flatfile,
      ta_t_flatfile TYPE STANDARD TABLE OF ta_flatfile,
        wa_t_flatfile TYPE  ta_flatfile.

TYPES:BEGIN OF ty_display,
        type       TYPE bapi_mtype,
        id         TYPE symsgid,
        number     TYPE symsgno,
        message_v1 TYPE mara-matnr,
        message	   TYPE bapi_msg,
      END OF ty_display,
      ty_t_display TYPE TABLE OF ty_display.

DATA:fname TYPE localfile,
     ename TYPE char4.


DATA:it_display TYPE ty_t_display.


DATA:ta_flatfile   TYPE ta_t_flatfile.
