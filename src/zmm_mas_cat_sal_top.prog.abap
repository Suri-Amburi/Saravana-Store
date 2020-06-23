*&---------------------------------------------------------------------*
*& Include          ZMM_MAS_CAT_SAL_TOP
*&---------------------------------------------------------------------*

TYPES : BEGIN OF TY_MARA ,
          MATNR TYPE MATNR,
          MATKL TYPE MATKL,
        END OF TY_MARA .

TYPES : BEGIN OF TY_MBEW ,
          MATNR TYPE MATNR,
          BWKEY TYPE BWKEY,
          LBKUM TYPE LBKUM,
          SALK3 TYPE SALK3,
        END OF TY_MBEW .

TYPES : BEGIN OF TY_MARD ,
          WERKS TYPE WERKS_D,
          LABST TYPE LABST,
        END OF TY_MARD .


TYPES : BEGIN OF TY_FINAL ,
          MATKL TYPE MATKL ,
          BWKEY TYPE BWKEY ,
          LBKUM TYPE LBKUM ,
          SALK3 TYPE SALK3 ,
        END OF TY_FINAL.

TYPES : BEGIN OF TY_DATA ,
          MATNR TYPE MATNR,
          MATKL TYPE MATKL,
*        WERKS TYPE WERKS_D ,
          BWKEY TYPE BWKEY ,        ""PLANT
          LBKUM TYPE LBKUM ,         ""QTY
          SALK3 TYPE SALK3 ,        ""AMOUNT
        END OF TY_DATA.

DATA : GT_DATA TYPE TABLE OF TY_DATA,
       IT_MARA TYPE TABLE OF TY_MARA,
       IT_MBEW TYPE TABLE OF TY_MBEW,
       IT_FINAL TYPE TABLE OF TY_FINAL,
       WA_FINAL TYPE TY_FINAL,
       IT_MARD TYPE TABLE OF TY_MARD.
DATA : LV_MATKL TYPE MATKL,
       LV_PLANT TYPE BWKEY.
