*&---------------------------------------------------------------------*
*& Include          ZFI_VENDOR_AGING_NC_SEL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZFI_VENDOR_AGING_NC_SEL
*&---------------------------------------------------------------------*
selection-screen begin of block bk1 with frame.

 Select-options :
                  s_bldat for gv_bldat no-display ,
                  s_lifnr for gv_LIFNR ,
                  s_gjahr for gv_gjahr no-display ."no intervals.

 PARAMETERS :     s_budat type bsik-budat  default sy-datum,
                  s_bukrs type bsik-bukrs  default '1000'.
* PARAMETERS:p_date TYPE sy-datum,
* p_days type T5A4A-DLYDY.
SELECTION-SCREEN BEGIN OF LINE.
skip 1.
SELECTION-SCREEN END OF LINE.
*PARAMETERS : P_GJAHR TYPE GJAHR.
*  parameters : r1 radiobutton   group g1,
*               R2 RADIOBUTTON GROUP G1.
  selection-screen end of block bk1.


    SELECTION-SCREEN BEGIN OF BLOCK BK2 WITH FRAME TITLE text-003.
      parameters : r3 radiobutton   group g2,
               R4 RADIOBUTTON GROUP G2.

SELECTION-SCREEN END OF BLOCK BK2.
  SELECTION-SCREEN BEGIN OF BLOCK BK3 WITH FRAME TITLE text-001.

 SELECTION-SCREEN BEGIN OF LINE .
PARAMETERS : P_SLAB1  TYPE NUMC4,
            P_SLAB2  TYPE NUMC4,
            P_SLAB3  TYPE NUMC4,
            P_SLAB4   TYPE NUMC4,
            P_SLAB5 TYPE NUMC4,
            p_slab6 type numc4,"changed on 4-dec-16 by naveen
            p_slab7 type numc4 no-display."changed on 4-dec-16 by naveen
SELECTION-SCREEN END OF LINE .
**
  SELECTION-SCREEN END OF BLOCK BK3.
