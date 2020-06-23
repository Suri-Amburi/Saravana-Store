  FUNCTION zsales_ret_get_tax_code.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_POS_BATCH) TYPE  ZB1_BTCH OPTIONAL
*"     VALUE(I_PLANT) TYPE  WERKS_D OPTIONAL
*"  EXPORTING
*"     VALUE(E_TAXP) TYPE  KBETR
*"     VALUE(E_S4H_BATCH) TYPE  CHARG_D
*"     VALUE(E_MATNR) TYPE  MATNR
*"     VALUE(E_MEINS) TYPE  MEINS
*"     VALUE(E_MAKTX) TYPE  MAKTX
*"----------------------------------------------------------------------
DATA: lv_mwsk1 TYPE konp-mwsk1.

  CHECK i_pos_batch IS NOT INITIAL.
*** Checking for S4 Batch
  SELECT SINGLE s4_batch FROM zb1_s4_map INTO e_s4h_batch WHERE b1_batch = i_pos_batch AND plant = i_plant.
  IF sy-subrc <> 0.
    SELECT SINGLE s4_batch FROM zb1_s4_map INTO e_s4h_batch WHERE b1_batch = i_pos_batch.
  ENDIF.

*** For EAN with different Materials in different Stores
  SELECT SINGLE mard~matnr INTO  @e_matnr
         FROM   mard AS mard
         INNER JOIN mara AS mara ON mara~matnr = mard~matnr  AND mara~ean11 = @i_pos_batch
         WHERE mard~werks = @i_plant AND mard~labst > 0.

  IF sy-subrc <> 0 AND e_s4h_batch IS NOT INITIAL .
    SELECT SINGLE matnr FROM mchb INTO e_matnr WHERE charg =  e_s4h_batch
                                               AND   werks = i_plant.
  ENDIF.


IF e_matnr IS NOT INITIAL.

      SELECT SINGLE meins FROM mara INTO e_meins WHERE matnr = e_matnr.
      SELECT SINGLE maktx FROM makt INTO e_maktx WHERE matnr = e_matnr AND spras = sy-langu.


    SELECT SINGLE konp~mwsk1 INTO lv_mwsk1
        FROM konp AS konp INNER JOIN a519 AS a519 ON a519~knumh = konp~knumh
                          INNER JOIN marc AS marc ON marc~steuc = a519~steuc
                          WHERE marc~matnr = e_matnr
                          AND   a519~datab LE sy-datum
                          AND   a519~datbi GE sy-datum
                          AND   konp~loevm_ko = ' '.

* IF lv_mwsk1 IS NOT INITIAL.  """" commented as per narendra
*   SELECT SUM( kbetr ) AS E_TAXP INTO E_TAXP FROM konp AS konp INNER JOIN a003 AS a003 ON a003~knumh = konp~knumh
*       WHERE  a003~mwskz = lv_mwsk1.
*   IF e_taxp IS NOT INITIAL.
*     e_taxp = e_taxp / 10.
*   ENDIF.
*
* ENDIF.

**************HARDCODING TAX CODE VALUE*****************
IF lv_mwsk1 IS NOT INITIAL.
  CASE lv_mwsk1.
    WHEN 'A0'.
      e_taxp = '0.00'.
    WHEN 'AP'.
      e_taxp = '3.00'.
    WHEN 'AQ'.
      e_taxp = '5.00'.
    WHEN 'AS'.
      e_taxp = '12.00'.
    WHEN 'AT'.
      e_taxp = '18.00'.
    WHEN 'AU'.
      e_taxp = '28.00'.
   WHEN OTHERS.
  ENDCASE.
ENDIF.

ENDIF.


ENDFUNCTION.
