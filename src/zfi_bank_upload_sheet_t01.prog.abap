*&---------------------------------------------------------------------*
*& Include          ZFI_BANK_UPLOAD_SHEET_T01
*&---------------------------------------------------------------------*


  TYPES :
    BEGIN OF ty_final,
      sno           TYPE int8,            " SNo
      trxn_type     TYPE char1,           " Transaction Type
      lifnr         TYPE lifnr,           " BP Code
      acc_no        TYPE bankn,           " Vendor Account Number
*      amount        type NEBTR,           " Instrument Amount
*      amount        type p DECIMALS 2,           " Instrument Amount
      amount(20),           " Instrument Amount
      name(40),                           " Bene Name
      e_f1(10),
      e_f2(10),
      e_f3(10),
      e_f4(10),
      e_f5(10),
      e_f6(10),
      e_f7(10),
      e_f8(10),
      cust_ref(15),                        " Customer Ref No. only for NEFT
      v_inv1(15),                          " Vendor Invoice 1
      v_inv2(15),                          " Vendor Invoice 2
      v_inv3(15),                          " Vendor Invoice 3
      v_inv4(15),                          " Vendor Invoice 4
      v_inv5(15),                          " Vendor Invoice 5
      v_inv6(15),                          " Vendor Invoice 6
      v_inv7(15),                          " Vendor Invoice 7
      e_f9(10),
      budat         TYPE budat,             " Inst. Date
      e_f10(10),
      ifsc_code     TYPE bankl,             " IFSC_Code
      bank_name(35),                        " Bank Name
      branch        TYPE brnch,             " Branch
      email         TYPE ad_smtpadr,        " Email
    END OF ty_final.

*** Internal Tables
  DATA : gt_final TYPE STANDARD TABLE OF ty_final.
*** Posting Date
  DATA : gv_budat TYPE budat.
*** Constants
  CONSTANTS :
    c_back   TYPE sy-ucomm VALUE 'BACK',
    c_cancel TYPE sy-ucomm VALUE 'CANCEL',
    c_exit   TYPE sy-ucomm VALUE 'EXIT',
    c_down   TYPE sy-ucomm VALUE 'DOWN',
    c_x(1)   VALUE 'X',
    c_cheque TYPE zpay_mode VALUE 'C'.
