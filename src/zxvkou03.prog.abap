*&---------------------------------------------------------------------*
*& Include          ZXVKOU03
*& TC     : Suri
*& Date   : 21.03.2020
*& Des    :To Update Custom Segment in COND_A - Outbound if Key is available to POS
*&---------------------------------------------------------------------*

CONSTANTS :
  c_e1komg(7)  VALUE 'E1KOMG',
  c_zcond_a(7) VALUE 'ZCOND_A'.

*** Adding Custom Segment ZCOND_A In Basic Type COND_A04 for Sending Batch Key
READ TABLE idoc_data ASSIGNING FIELD-SYMBOL(<ls_data>) WITH KEY segnam = c_e1komg.
IF sy-subrc IS INITIAL.
  IF <ls_data>-sdata+119(10) IS NOT INITIAL.
*** Get the Key from Batch Info table
*    SELECT SINGLE batchsrl_informationkey FROM zbatch_info INTO @DATA(ls_key) WHERE u_batch_serial_number = @<ls_data>-sdata+119(10).
    SELECT SINGLE zzbatchsrl_informationkey FROM mch1 INTO @DATA(ls_key) WHERE charg = @<ls_data>-sdata+119(10).
    IF sy-subrc IS INITIAL.
***   Insert Extenstion Segment - ZCOND_A
      INSERT INITIAL LINE INTO idoc_data ASSIGNING FIELD-SYMBOL(<ls_zcond>) INDEX 2.
      IF sy-subrc IS INITIAL .
        <ls_zcond>-segnam = c_zcond_a.
        SHIFT ls_key LEFT DELETING LEADING '0'.
        <ls_zcond>-sdata  = ls_key.
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.
