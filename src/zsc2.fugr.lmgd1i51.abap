*&---------------------------------------------------------------------*
*&      Module  MVKE-PMATN  INPUT
*&---------------------------------------------------------------------*
*       Copied from Retail wk zu 4.0
*----------------------------------------------------------------------*
MODULE MVKE-PMATN INPUT.

CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
CHECK BILDFLAG IS INITIAL.

* Industrie added wk for 4.0
CALL FUNCTION 'MVKE_PMATN'
     EXPORTING
          WMVKE_PMATN = MVKE-PMATN
          LMVKE_PMATN = LMVKE-PMATN
          WMARA_MATNR = MARA-MATNR
          WMVKE_VKORG = MVKE-VKORG
          WMVKE_VTWEG = MVKE-VTWEG
          WMARA_ATTYP = MARA-ATTYP
          WMARA_SATNR = MARA-SATNR
          FLG_RETAIL  = RMMG2-FLG_RETAIL.


ENDMODULE.                 " MVKE-PMATN  INPUT
