*&---------------------------------------------------------------------*
*& Include          ZSST_MM_F_032_EOD_PO_GETDATA
*&---------------------------------------------------------------------*

START-OF-SELECTION.
BREAK PPADHY.
  DATA(lv_select) = cl_shdb_seltab=>combine_seltabs(
   it_named_seltabs = VALUE #( ( name = 'AEDAT' dref = REF #( s_date[] ) )
                               )

                               iv_client_field = 'MANDT'
                                ) .

  zeod_po=>get_output_prd(
 EXPORTING
*    lv_date       = s_date-high
   lv_select     = lv_select
  IMPORTING
   et_final_data = it_ekko1
  ).

***  SELECT
***   ekko~ebeln,
***   ekko~aedat,
***   ekko~ekgrp,
***   ekko~lifnr,
***   ekko~bsart,
***   ekpo~ebelp,
***   ekpo~retpo,
***   ekpo~netwr,
***   ekpo~menge,
**** lfa1~LIFNR,
***   lfa1~name1,
***   lfa1~ort01
***   FROM ekko AS ekko INNER JOIN ekpo AS ekpo ON ( ekko~ebeln EQ ekpo~ebeln AND ekpo~retpo NE 'X' )
***   INNER JOIN lfa1 AS lfa1 ON ekko~lifnr = lfa1~lifnr
***   WHERE ekko~aedat IN @s_date AND ekko~bsart IN ('ZLOP','ZOSP','ZTAT','ZVLO','ZOSP') INTO TABLE @DATA(it_ekko1).


****
**SELECT EBELN
**       AEDAT
**       EKGRP
**       LIFNR
**       BSART
**       FROM EKKO INTO TABLE IT_EK WHERE AEDAT IN S_DATE AND BSART IN ('ZLOP','ZOSP','ZTAT','ZVLO','ZOSP').
**
**SELECT A~EBELN
**       A~AEDAT
**       A~EKGRP
**       A~LIFNR
**       A~BSART
**       B~EBELP
**       B~RETPO
**       B~NETWR
**       B~MENGE
**FROM   EKKO AS A INNER JOIN EKPO AS B ON ( A~EBELN EQ B~EBELN AND B~RETPO NE 'X' )
**INTO TABLE IT_EKKO
**FOR ALL ENTRIES IN IT_EK
**WHERE A~EBELN EQ IT_EK-EBELN.
**
**  SELECT EBELN
**         EBELP
**         RETPO
**         NETWR
**         MENGE
**  FROM EKPO
**  INTO TABLE IT_EKPO
**  FOR ALL ENTRIES IN IT_EK
**  WHERE EBELN = IT_EK-EBELN " '4600001982'
**     AND RETPO NE 'X'.
**
**SELECT LIFNR
**       NAME1
**       ORT01
**FROM   LFA1
**INTO TABLE IT_LFA1
**FOR ALL ENTRIES IN IT_EKKO
**WHERE LIFNR EQ IT_EKKO-LIFNR.
**
**SELECT EKGRP
**FROM   EKKO
**INTO TABLE IT_EKGRP
**WHERE AEDAT IN S_DATE.
**
****IF IT_EKKO IS NOT INITIAL.
*****
*****  SELECT EBELN
*****         NETWR
*****         MENGE
*****  FROM   EKPO
*****  INTO TABLE IT_EKPO
*****  FOR ALL ENTRIES IN IT_EKKO
*****  WHERE EBELN = IT_EKKO-EBELN.
****
****ENDIF.
**
**  SORT it_ekgrp BY ekgrp.
**  DELETE ADJACENT DUPLICATES FROM it_ekgrp COMPARING ekgrp.
**
  SELECT ekgrp
         eknam
  FROM   t024
  INTO TABLE it_t024
    WHERE ekgrp NE '001' AND
        ekgrp NE '002' AND
        ekgrp NE '003'.
**FOR ALL ENTRIES IN IT_EKGRP
**WHERE EKGRP = IT_EKGRP-EKGRP.

  DATA(it_ekko2) = it_ekko1.
  SORT it_ekko2 BY ekgrp.
  DELETE ADJACENT DUPLICATES FROM it_ekko2 COMPARING ekgrp.
*  BREAK ppadhy.

  LOOP AT it_t024 INTO wa_t024.
    sr_no          = sr_no + 1 .
    wa_final-sr_no = sr_no .
*    BREAK ppadhy.
    LOOP AT it_ekko1 INTO wa_ekko1 WHERE ekgrp = wa_t024-ekgrp.

      wa_final-or_qty = wa_final-or_qty + wa_ekko1-menge.
      wa_final-ntwr   = wa_final-ntwr + wa_ekko1-netwr.
*   WA_FINAL-OR_QTY = WA_FINAL-OR_QTY + WA_EKKO-MENGE.
*   WA_FINAL-NTWR   = WA_FINAL-NTWR + WA_EKKO-NETWR.
*   MOVE WA_EKKO-UNIQUEID TO WA_SLT-VEN_NO.
*   MOVE WA_EKKO-EBELN TO WA_SLT-EBELN.
*   MOVE WA_EKKO-TXZ01 TO WA_SLT-DESC.
*   MOVE WA_EKKO-EKGRP TO WA_SLT-EKGRP.
*   MOVE WA_EKKO-MENGE TO WA_SLT-MENGE.
*   MOVE WA_EKKO-NETWR TO WA_SLT-NETWR.
*   APPEND WA_SLT TO IT_SLT.
*   CLEAR WA_SLT.

    ENDLOOP.

    LOOP AT it_ekko2 INTO DATA(wa_ekko2) WHERE ekgrp = wa_t024-ekgrp.
      wa_final-no_po  = wa_final-no_po + 1.
    ENDLOOP.

* READ TABLE IT_T024 INTO WA_T024 WITH KEY EKGRP = WA_EKGRP-EKGRP.
* IF SY-SUBRC = 0.

* ENDIF.
    wa_final-group = wa_t024-eknam.
    wa_final-ekgrp = wa_t024-ekgrp.
    tot_qty  = tot_qty  + wa_final-or_qty.
    tot_ntwr = tot_ntwr + wa_final-ntwr.
    tot_po   = tot_po   + wa_final-no_po.

    APPEND wa_final TO it_final.
    CLEAR : wa_final.

  ENDLOOP.
