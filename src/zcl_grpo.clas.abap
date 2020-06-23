CLASS ZCL_GRPO DEFINITION PUBLIC FINAL CREATE PUBLIC .

  PUBLIC SECTION.
*** STANDARD AMDP INTERFACE
    INTERFACES IF_AMDP_MARKER_HDB.
*** TYPES DECLARATION
    TYPES:
      BEGIN OF TY_GRPO,
        EBELN TYPE EBELN,
        EBELP TYPE EBELP,
        MATNR TYPE MATNR,
        MAKTX TYPE MAKTX,
        WERKS TYPE EWERK,
        LGORT TYPE LGORT_D,
        MENGE TYPE BSTMG,
        MEINS TYPE BSTME,
      END OF TY_GRPO,
      TT_GRPO TYPE STANDARD TABLE OF TY_GRPO,

*** TYPES DECLARATION FOR OUTPUT DATA STRUCTURE
      BEGIN OF TY_DET,
        EBELN    TYPE EBELN,
        MBLNR    TYPE MBLNR,
        MJAHR    TYPE MJAHR,
        MSG_TYPE TYPE CHAR1,
        MESSAGE  TYPE BAPI_MSG,
      END OF TY_DET,
      TT_DET TYPE STANDARD TABLE OF TY_DET,

* TYPES DECLARATION FOR PO ITEM DATA
      BEGIN OF TY_EKPO,
        EBELN          TYPE EBELN,
        EBELP          TYPE EBELP,
        MATNR          TYPE MATNR,
        WERKS          TYPE WERKS_D,
        LGORT          TYPE LGORT_D,
        MATKL          TYPE MATKL,
        MENGE          TYPE BSTMG,
        MEINS          TYPE BSTME,
        NETPR          TYPE BPREI,
        NETWR          TYPE BWERT,
        MWSKZ          TYPE MWSKZ,
        UEBTO          TYPE UEBTO,
        EAN11          TYPE EAN11,
        ZZSET_MATERIAL TYPE MATNR,
        MAKTX          TYPE MAKTX,
        OPEN_QTY       TYPE BSTMG,
      END OF TY_EKPO,
      TT_EKPO TYPE STANDARD TABLE OF TY_EKPO,

* TYPES DECLARATION FOR PO ITEM DATA
      BEGIN OF TY_MSEG,
        MBLNR TYPE MBLNR,
        MATNR TYPE MATNR,
        EBELN TYPE EBELN,
        EBELP TYPE EBELP,
        CHARG TYPE CHARG_D,
      END OF TY_MSEG,
      TT_MSEG TYPE STANDARD TABLE OF TY_MSEG,

* Bom Components
      BEGIN OF TY_COMP,
        MATNR TYPE MATNR,
        WERKS TYPE WERKS_D,
        STLNR TYPE STNUM,
        STLAL TYPE STALT,
        STLKN TYPE STLKN,
        IDNRK TYPE IDNRK,
        POSNR TYPE SPOSN,
        MENGE TYPE KMPMG,
        MEINS TYPE KMPME,
      END OF TY_COMP,
      TT_COMP TYPE STANDARD TABLE OF TY_COMP,

      TT_ITEM TYPE STANDARD TABLE OF ZINW_T_ITEM.
*** METHODS
*** PO ITEM
    CLASS-METHODS  GET_PO_ITEM
      IMPORTING
        VALUE(I_EBELN) TYPE EBELN
      EXPORTING
        VALUE(T_EKPO)  TYPE TT_EKPO.

    CLASS-METHODS  GET_INW_ITEM
      IMPORTING
                VALUE(I_QR)   TYPE ZQR_CODE
      EXPORTING
                VALUE(T_ITEM) TYPE TT_ITEM
      RAISING   CX_AMDP_ERROR.

* GET MSEG DETAILS
    CLASS-METHODS  GET_MSEG
      IMPORTING
                VALUE(T_DET)  TYPE TT_DET
      EXPORTING
                VALUE(T_MSEG) TYPE TT_MSEG
      RAISING   CX_AMDP_ERROR .

* Get BOM Components
*   CLASS-METHODS  GET_COMPONENTS
*      IMPORTING
*                VALUE(T_EKPO)  TYPE TT_EKPO
*      EXPORTING
*                VALUE(T_COMP) TYPE TT_COMP
*      RAISING   CX_AMDP_ERROR .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_GRPO IMPLEMENTATION.


  METHOD GET_INW_ITEM BY DATABASE PROCEDURE
                      FOR HDB
                      LANGUAGE SQLSCRIPT
                      OPTIONS READ-ONLY
                      USING  ZINW_T_ITEM.

    T_ITEM = SELECT * FROM ZINW_T_ITEM WHERE QR_CODE = I_QR;

  ENDMETHOD.


  METHOD GET_MSEG BY DATABASE PROCEDURE
                    FOR HDB
                    LANGUAGE SQLSCRIPT
                    OPTIONS READ-ONLY
                    USING  NSDM_V_MSEG.

    T_MSEG = SELECT NSDM_V_MSEG.MBLNR,
                    NSDM_V_MSEG.MATNR,
                    NSDM_V_MSEG.EBELN,
                    NSDM_V_MSEG.EBELP,
                    NSDM_V_MSEG.CHARG
                    FROM NSDM_V_MSEG AS NSDM_V_MSEG
                    WHERE EXISTS ( SELECT MBLNR FROM :T_DET AS T_DET
                                   WHERE NSDM_V_MSEG.MBLNR = T_DET.MBLNR
                                   AND NSDM_V_MSEG.EBELN = T_DET.EBELN ) ;

  ENDMETHOD.

  METHOD GET_PO_ITEM BY DATABASE PROCEDURE
                           FOR HDB
                           LANGUAGE SQLSCRIPT
                           OPTIONS READ-ONLY
                           USING  EKPO EKET MAKT.

    T_EKPO = SELECT  EKPO.EBELN,
                     EKPO.EBELP,
                     EKPO.MATNR,
                     EKPO.WERKS,
                     EKPO.LGORT,
                     EKPO.MATKL,
                     EKPO.MENGE,
                     EKPO.MEINS,
                     EKPO.NETPR,
                     EKPO.NETWR,
                     EKPO.MWSKZ,
                     EKPO.UEBTO,
                     ekpo.ean11,
                     EKPO.ZZSET_MATERIAL,
                     MAKT.MAKTX,
                     (  EKET.MENGE  - EKET.WEMNG ) AS OPEN_QTY
                     FROM EKPO AS EKPO
                     INNER JOIN MAKT AS MAKT
                     ON EKPO.MATNR = MAKT.MATNR
                     INNER JOIN EKET AS EKET
                     ON EKPO.EBELN = EKET.EBELN AND EKPO.EBELP = EKET.EBELP
                     WHERE EKPO.EBELN = I_EBELN ;
  ENDMETHOD.
ENDCLASS.
