CLASS zcl_po_data_008 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES : if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_po_data_008 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA : itab TYPE TABLE OF zpo_008.
    GET TIME STAMP FIELD DATA(zv_tsl).

    itab = VALUE #( ( client = sy-mandt
                      ebeln = '4600002052'
                      ebelp = '00020'
                      matnr = '314035-18'
                      txz01 = 'G-COTTON FROCK-MUM-LX-201/400,18'
                      werks = 'SSWH'
                      menge = '5'
                      meins = 'EA'
                      netpr = '500'
                      waers = 'INR'
                      netwr = '2500'
                      aedat = '20200405'
                      erdat = '20200405'
                      ernam = 'Umair' ) ).

*     DELETE FROM zpo_008.
     INSERT zpo_008 FROM TABLE @itab.
     SELECT * FROM zpo_008 INTO TABLE @itab.
     out->write( sy-dbcnt ).
     out->write( 'PO data has been inserted successfully!' ).
ENDMETHOD.

ENDCLASS.
