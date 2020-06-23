FUNCTION zb1_s4_batch_mapping.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_POS_BATCH) TYPE  ZB1_BTCH OPTIONAL
*"     VALUE(I_PLANT) TYPE  WERKS_D OPTIONAL
*"  EXPORTING
*"     VALUE(E_S4H_BATCH) TYPE  CHARG_D
*"     VALUE(E_MATNR) TYPE  MATNR
*"----------------------------------------------------------------------

  CHECK i_pos_batch IS NOT INITIAL.
*** Checking for S4 Batch
*  SELECT SINGLE s4_batch FROM zb1_s4_map INTO e_s4h_batch WHERE b1_batch = i_pos_batch AND plant = i_plant.  " 30.05.2020
    SELECT SINGLE s4_batch FROM zb1_s4_map INTO e_s4h_batch WHERE b1_batch = i_pos_batch.
***  Not required : 30.05.2020
**** For EAN with different Materials in different Stores
*  SELECT SINGLE mard~matnr INTO @e_matnr
*         FROM mard AS mard
*         INNER JOIN mara AS mara ON mara~matnr = mard~matnr AND mara~ean11 = @i_pos_batch
*         WHERE mard~werks = @i_plant AND mard~labst > 0.
ENDFUNCTION.
