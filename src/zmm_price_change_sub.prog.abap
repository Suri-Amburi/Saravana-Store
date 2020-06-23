*&---------------------------------------------------------------------*
*& Include          ZMM_PRICE_CHANGE_SUB
*&---------------------------------------------------------------------*

SELECT
  MATNR
  MATKL
  ZZPO_ORDER_TXT FROM MARA INTO TABLE IT_MARA
                 WHERE MATKL IN GROUP .

IF IT_MARA IS NOT INITIAL.

  SELECT
    A502~KSCHL ,
    A502~LIFNR ,
    A502~MATNR ,
    A502~DATBI FROM A502 INTO TABLE @DATA(IT_A502)
          FOR ALL ENTRIES IN @IT_MARA
          WHERE MATNR = @IT_MARA-MATNR .

  SELECT
    A515~KSCHL ,
    A515~DATBI ,
    A515~KNUMH FROM A515 INTO TABLE @DATA(IT_A515)
               FOR ALL ENTRIES IN @IT_MARA
               WHERE MATNR = @IT_MARA-MATNR .
ENDIF.

IF IT_A502 IS NOT INITIAL.

  SELECT
    LFA1~LIFNR ,
    LFA1~NAME1 FROM LFA1 INTO TABLE @DATA(IT_LFA1)
               FOR ALL ENTRIES IN @IT_A502
               WHERE LIFNR = @IT_A502-LIFNR .
ENDIF.


LOOP AT it_mara ASSIGNING FIELD-SYMBOL(<ls_mara>).



ENDLOOP.
