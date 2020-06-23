*&---------------------------------------------------------------------*
*& Include          ZGSTR3_R_TOP
*&---------------------------------------------------------------------*

TYPES : BEGIN OF TY_RBKP ,

          BELNR	 TYPE RE_BELNR, "invoic doc no
          GJAHR	 TYPE GJAHR,  "fiscal year
          BLART	 TYPE BLART,  "document type (condition = 'RE')
          BUDAT	 TYPE BUDAT,  "posting date (check with input)
          RMWWR	 TYPE RMWWR,  "gross invoice amount
          WMWST1 TYPE FWSTEV,  "tax amount
          XRECH	 TYPE XRECH,  "invoice ind
          STBLG	 TYPE RE_STBLG,  "reversed by

        END OF TY_RBKP .

TYPES : BEGIN OF TY_RSEG ,

          BELNR TYPE BELNR_D,  "(condition with RBKP table)
          GJAHR TYPE GJAHR,  "(condition with RBKP table)
          BUZEI TYPE RBLGP,  "(key field)
          MATNR TYPE MATNR,  "material
          MWSKZ TYPE MWSKZ,  "tax code
          SALK3 TYPE SALK3,  "total amount

        END OF TY_RSEG .

TYPES : BEGIN OF TY_A003 ,

          KAPPL TYPE KAPPL,  "application
          KSCHL TYPE KSCHA,  "condition type
          ALAND TYPE ALAND,  "depature country (condition = 'IN')
          MWSKZ TYPE MWSKZ,  "tax Code(condition with RSEG table)
          KNUMH TYPE KNUMH,  "condition record no.

        END OF TY_A003 .


TYPES : BEGIN OF TY_KONP ,

          KNUMH TYPE KNUMH,  "(condition with a003 table)
          KOPOS TYPE KOPOS,  "(key field)
          KBETR TYPE KBETR_KOND,  "tax%

        END OF TY_KONP .


TYPES : BEGIN OF TY_MARA ,

          MATNR TYPE MATNR,  "(condition with RBKP table)
          MTART TYPE MTART,  "material type

        END OF TY_MARA .
