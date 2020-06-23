*---------------------------------------------------------------------*
* Module     THEAD_BEARBEITEN                                         *
*---------------------------------------------------------------------*
*       Aufgrund der Bildschirmeingabe wird durch die                 *
*       FIELD- Anweisung im Dynpro die Workarea XTHEAD gepflegt.      *
*---------------------------------------------------------------------*
MODULE THEAD_BEARBEITEN.
  call function 'LTEXT_STEPLOOP' importing e_isold = gv_isold.

  IF NOT ISMODIFIED IS INITIAL or not gv_isold is initial.
    if not gv_isold is initial.             "<<<INSERT NOTE328641<<<<<<<
    CALL FUNCTION 'THEAD_BEARBEITEN'
         EXPORTING
              P_SPRAS     = RM03M-SPRAS
              P_LTEX1     = RM03M-LTEX1
              P_LTEX2     = RM03M-LTEX2
              P_LTEX3     = RM03M-LTEX3
              P_LTEX4     = RM03M-LTEX4
              OK_CODE     = RMMZU-OKCODE
              P_KZLTX     = RM03M-KZLTX
              P_AKTYP     = T130M-AKTYP
              ISMODIFIED  = ISMODIFIED "TF 4.6A
         IMPORTING
              P_LTEX1     = RM03M-LTEX1
              P_LTEX2     = RM03M-LTEX2
              P_LTEX3     = RM03M-LTEX3
              P_LTEX4     = RM03M-LTEX4
              BILDFLAG    = BILDFLAG
         TABLES
              TLINETAB_IN = TLINETAB.
*<<<<<<<<<BEGIN OF INSERTION NOTE328641<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    else.
    CALL FUNCTION 'THEAD_BEARBEITEN'
         EXPORTING
              P_SPRAS     = RM03M-SPRAS
              P_LTEX1     = RM03M-LTEX1
              P_LTEX2     = RM03M-LTEX2
              P_LTEX3     = RM03M-LTEX3
              P_LTEX4     = RM03M-LTEX4
              OK_CODE     = RMMZU-OKCODE
              P_KZLTX     = RM03M-KZLTX
              P_AKTYP     = T130M-AKTYP
              ISMODIFIED  = ISMODIFIED "TF 4.6A
         IMPORTING
              P_LTEX1     = RM03M-LTEX1
              P_LTEX2     = RM03M-LTEX2
              P_LTEX3     = RM03M-LTEX3
              P_LTEX4     = RM03M-LTEX4
*             BILDFLAG    = BILDFLAG
         TABLES
              TLINETAB_IN = TLINETAB.
    endif.
*<<<<<<<<<END OF INSERTION NOTE328641<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ENDIF.
ENDMODULE.
