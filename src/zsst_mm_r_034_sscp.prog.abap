*&---------------------------------------------------------------------*
*& Report ZSST_MM_R_034_SSCP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSST_MM_R_034_SSCP.

TYPES : BEGIN OF TY_DATA,
          CLASS TYPE KLAH-CLASS,
          CLINT TYPE KLAH-CLINT,
          OBJEK TYPE KSSK-OBJEK,
          MATKL TYPE MARA-MATKL,
        END OF TY_DATA,

        BEGIN OF TY_MARA,
          MATKL TYPE MARA-MATKL,
          MATNR TYPE MARA-MATNR,
        END OF TY_MARA,

        BEGIN OF TY_VBRP,
          VBELN TYPE VBRP-VBELN,
          POSNR TYPE VBRP-POSNR,
          MATNR TYPE VBRP-MATNR,
          MATKL TYPE VBRP-MATKL,
          NETWR TYPE VBRP-NETWR,
          PRSDT TYPE VBRP-PRSDT,
          FKIMG TYPE VBRP-FKIMG,
          WERKS TYPE VBRP-WERKS,
        END OF TY_VBRP,

        BEGIN OF TY_MBEW,
          MATNR TYPE MBEW-MATNR,
          BWKEY TYPE MBEW-BWKEY,
          BWTAR TYPE MBEW-BWTAR,
          LBKUM TYPE MBEW-LBKUM,
          SALK3 TYPE MBEW-SALK3,
        END OF TY_MBEW,

*        BEGIN OF TY_MB,
*          MATNR TYPE MBEW-MATNR,
*          BWKEY TYPE MBEW-BWKEY,
**          BWTAR TYPE MBEW-BWTAR,
*          LBKUM TYPE MBEW-LBKUM,
*          SALK3 TYPE MBEW-SALK3,
*        END OF TY_MB,

        BEGIN OF TY_HDR,
          QR_CODE  TYPE ZINW_T_HDR-QR_CODE ,
          INWD_DOC TYPE ZINW_T_HDR-INWD_DOC,
          EBELN    TYPE ZINW_T_HDR-EBELN   ,
          LIFNR    TYPE ZINW_T_HDR-LIFNR   ,
          STATUS   TYPE ZINW_T_HDR-STATUS  ,
        END OF TY_HDR,

        BEGIN OF TY_ITEM,
          QR_CODE TYPE ZINW_T_ITEM-QR_CODE,
          EBELN   TYPE ZINW_T_ITEM-EBELN  ,
          EBELP   TYPE ZINW_T_ITEM-EBELP  ,
          MATNR   TYPE ZINW_T_ITEM-MATNR  ,
          MENGE_P TYPE ZINW_T_ITEM-MENGE_P,
          NETPR_P TYPE ZINW_T_ITEM-NETPR_P,
          WERKS   TYPE ZINW_T_ITEM-WERKS,
        END OF TY_ITEM,

        BEGIN OF TY_KLAH,
          CLINT TYPE KLAH-CLINT,
          CLASS TYPE KLAH-CLASS,
        END OF TY_KLAH,

        BEGIN OF TY_FINAL,
          GROUP TYPE KLAH-CLASS,
          STCK_QUAN TYPE ZINW_T_ITEM-MENGE_P,
          STCK_VAL  TYPE ZINW_T_ITEM-NETPR_P,
          SALE_QUAN  TYPE VBRP-FKIMG,
          SALE_VAL   TYPE VBRP-NETWR,
        END OF TY_FINAL,

        BEGIN OF TY_GRP,
          MATKL TYPE MARA-MATKL,
          STCK_QUAN TYPE ZINW_T_ITEM-MENGE_P,
          STCK_VAL  TYPE ZINW_T_ITEM-NETPR_P,
          SALE_QUAN  TYPE VBRP-FKIMG,
          SALE_VAL   TYPE VBRP-NETWR,
        END OF TY_GRP,

        BEGIN OF TY_STCK,
          GROUP TYPE KLAH-CLASS,
          QUAN_01 TYPE ZINW_T_ITEM-MENGE_P,
          QUAN_02 TYPE ZINW_T_ITEM-MENGE_P,
          VAL_01  TYPE VBRP-NETWR,
          VAL_02  TYPE VBRP-NETWR,
          SSTN_QUAN TYPE MBEW-LBKUM,
          SSPO_QUAN TYPE MBEW-LBKUM,
          SSPU_QUAN TYPE MBEW-LBKUM,
          SSCP_QUAN TYPE MBEW-LBKUM,
          SSWH_QUAN TYPE MBEW-LBKUM,
          SSTN_VAL TYPE MBEW-SALK3,
          SSPO_VAL TYPE MBEW-SALK3,
          SSPU_VAL TYPE MBEW-SALK3,
          SSCP_VAL TYPE MBEW-SALK3,
          SSWH_VAL TYPE MBEW-SALK3,
        END OF TY_STCK,

        BEGIN OF TY_SALE,
          GROUP TYPE KLAH-CLASS,
          SSTN_QUAN TYPE MBEW-LBKUM,
          SSPO_QUAN TYPE MBEW-LBKUM,
          SSPU_QUAN TYPE MBEW-LBKUM,
          SSCP_QUAN TYPE MBEW-LBKUM,
          SSTN_VAL TYPE MBEW-SALK3,
          SSPO_VAL TYPE MBEW-SALK3,
          SSPU_VAL TYPE MBEW-SALK3,
          SSCP_VAL TYPE MBEW-SALK3,
        END OF TY_SALE,

        BEGIN OF TY_VBRK,
          VBELN TYPE VBRK-VBELN,
          FKDAT TYPE VBRK-FKDAT,
        END OF TY_VBRK.

DATA  : IT_DATA TYPE TABLE OF TY_DATA,
        IT_MARA TYPE TABLE OF TY_MARA,
        IT_VBRP TYPE TABLE OF TY_VBRP,
        IT_MBEW TYPE TABLE OF TY_MBEW,
        IT_HDR  TYPE TABLE OF TY_HDR,
        IT_ITEM TYPE TABLE OF TY_ITEM,
        IT_KLAH TYPE TABLE OF TY_KLAH,
        IT_FINAL TYPE TABLE OF TY_FINAL,
        IT_GRP TYPE TABLE OF TY_GRP,
        IT_STCK TYPE TABLE OF TY_STCK,
        IT_SALE TYPE TABLE OF TY_SALE,
*        IT_MB TYPE TABLE OF TY_MB,
*        IT_MR TYPE TABLE OF TY_MARA,
*        IT_MBW TYPE TABLE OF TY_MBEW,
*        IT_FIN TYPE TABLE OF TY_FINAL,
        IT_VBRK TYPE TABLE OF TY_VBRK.

DATA  : WA_DATA TYPE TY_DATA,
        WA_MARA TYPE TY_MARA,
        WA_VBRP TYPE TY_VBRP,
        WA_MBEW TYPE TY_MBEW,
        WA_HDR  TYPE TY_HDR,
        WA_ITEM TYPE TY_ITEM,
        WA_KLAH TYPE TY_KLAH,
        WA_FINAL TYPE TY_FINAL,
        WA_GRP TYPE TY_GRP,
        WA_STCK TYPE TY_STCK,
        WA_SALE TYPE TY_SALE,
*        WA_MB TYPE TY_MB,
*        WA_MR TYPE TY_MARA,
*        WA_MBW TYPE TY_MBEW,
*        WA_FIN TYPE TY_FINAL,
        WA_VBRK TYPE TY_VBRK.

DATA  : QUANTITY TYPE ZINW_T_ITEM-MENGE_P,
        QUAN     TYPE ZINW_T_ITEM-MENGE_P,
        NET_VALUE TYPE ZINW_T_ITEM-NETPR_P,
        VALUE     TYPE ZINW_T_ITEM-NETPR_P.

DATA  : GV_GRP TYPE KLAH-CLASS.

DATA  : FIELDCATALOG TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE.

SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS: S_GRP   FOR GV_GRP .
*                S_MATKL FOR GV_MATKL,
*                S_MATNR FOR GV_MATNR.

SELECTION-SCREEN : END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_GRP-LOW.
** Calling the perform method when the low field of select option pernr's f4 is clicked
  PERFORM GRP_F4.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_GRP-HIGH.
** Calling the perform method when the high field of select option pernr's f4 is clicked
  PERFORM GRP_F4.

START-OF-SELECTION.

REFRESH IT_KLAH.
SELECT CLINT
       CLASS
FROM   KLAH
INTO TABLE IT_KLAH
WHERE KLART = '026' AND WWSKZ = '0' AND
      CLASS IN S_GRP.

SELECT KLAH~CLASS
       KLAH~CLINT
       KSSK~OBJEK
       KLAH1~CLASS AS MATKL
INTO TABLE IT_DATA
FROM KLAH AS KLAH INNER JOIN KSSK AS KSSK ON ( KSSK~CLINT EQ KLAH~CLINT )
                  INNER JOIN KLAH AS KLAH1 ON ( KSSK~OBJEK EQ KLAH1~CLINT )
WHERE KLAH~KLART = '026' AND
      KLAH~WWSKZ = '0' AND
      KLAH~CLASS IN S_GRP.


*      KLAH~CLASS IN S_GRP AND
*      KLAH1~CLASS IN S_MATKL.

IF IT_DATA IS NOT INITIAL.
  SELECT MATKL
         MATNR
  INTO TABLE IT_MARA
  FROM MARA
  FOR ALL ENTRIES IN IT_DATA
  WHERE MATKL EQ IT_DATA-MATKL." AND
*      MATNR IN S_MATNR.
ENDIF.

IF IT_MARA IS NOT INITIAL.

 SELECT VBELN
        FKDAT
 FROM VBRK
 INTO TABLE IT_VBRK
 WHERE FKDAT EQ SY-DATUM.

 SELECT VBELN
         POSNR
         MATNR
         MATKL
         NETWR
         PRSDT
         FKIMG
         WERKS
 FROM   VBRP
 INTO TABLE IT_VBRP
 FOR ALL ENTRIES IN IT_VBRK
 WHERE VBELN = IT_VBRK-VBELN." AND
       "  WERKS IN ('SSTN','SSPO','SSPU','SSCP').
*      PRSDT = IT_MSEG-BUDAT_MKPF.

 SELECT MATNR
        BWKEY
        BWTAR
        LBKUM
        SALK3
 FROM MBEW
 INTO TABLE IT_MBEW
 FOR ALL ENTRIES IN IT_MARA
 WHERE MATNR = IT_MARA-MATNR AND
       BWKEY IN ('SSTN','SSPO','SSPU','SSCP','SSWH').
   "AND LBKUM GE '0'.


    SELECT QR_CODE
           INWD_DOC
           EBELN
           LIFNR
           STATUS
    FROM ZINW_T_HDR
    INTO TABLE IT_HDR
    WHERE STATUS LE '02'.

    SELECT QR_CODE
           EBELN
           EBELP
           MATNR
           MENGE_P
           NETPR_P
           WERKS
    FROM ZINW_T_ITEM
    INTO TABLE IT_ITEM
    FOR ALL ENTRIES IN IT_HDR
    WHERE QR_CODE EQ IT_HDR-QR_CODE AND
          WERKS IN ('SSTN','SSPO','SSPU','SSCP','SSWH').

 ENDIF.




* LOOP AT IT_MARA INTO WA_MARA.
*   LOOP AT IT_MBEW INTO WA_MBEW WHERE MATNR = WA_MARA-MATNR.
*     WA_MB-LBKUM = WA_MB-LBKUM + WA_MBEW-LBKUM.
*     WA_MB-SALK3 = WA_MB-SALK3 + WA_MBEW-SALK3.
*     WA_MB-BWKEY = WA_MBEW-BWKEY.
*     CLEAR WA_MBEW.
*   ENDLOOP.
*
*   WA_MB-MATNR = WA_MARA-MATNR.
*   APPEND WA_MB TO IT_MB.
*   CLEAR WA_MB.
* ENDLOOP.

*LOOP AT IT_KLAH INTO WA_KLAH.
*  LOOP AT IT_DATA INTO WA_DATA WHERE CLASS = WA_KLAH-CLASS.
*    FREE : IT_MR[],
*           IT_MBW[].
*    PERFORM MARA TABLES IT_MR USING WA_DATA-MATKL.
*    PERFORM MBEW TABLES IT_MBW USING IT_MR."CHANGING IT_MBW.
*    LOOP AT IT_MR INTO WA_MR.
*      LOOP AT IT_MBW INTO WA_MBW WHERE MATNR = WA_MR-MATNR.
*        QUANTITY = QUANTITY + WA_MBW-LBKUM .
*        NET_VALUE = NET_VALUE + WA_MBW-SALK3.
*      ENDLOOP.
*      WA_FIN-STCK_QUAN = WA_FIN-STCK_QUAN + QUANTITY + QUAN.
*      WA_FIN-STCK_VAL = WA_FIN-STCK_VAL + NET_VALUE + VALUE.
*      CLEAR : QUANTITY,
*               QUAN,
*               NET_VALUE,
*               VALUE.
*
*    ENDLOOP.
*
*  ENDLOOP.
*  WA_FIN-GROUP = WA_KLAH-CLASS.
*  APPEND WA_FIN TO IT_FIN.
*  CLEAR : WA_FIN,
*          WA_KLAH.
*
*ENDLOOP.
FREE IT_FINAL[].
 LOOP AT IT_KLAH INTO WA_KLAH.
   LOOP AT IT_DATA INTO WA_DATA WHERE CLASS = WA_KLAH-CLASS.
     LOOP AT IT_MARA INTO WA_MARA WHERE MATKL = WA_DATA-MATKL.
       LOOP AT IT_MBEW INTO WA_MBEW WHERE MATNR =  WA_MARA-MATNR.
         QUANTITY = QUANTITY + WA_MBEW-LBKUM .
         NET_VALUE = NET_VALUE + WA_MBEW-SALK3.
       ENDLOOP.
       LOOP AT IT_ITEM INTO WA_ITEM WHERE MATNR = WA_MARA-MATNR.
         QUAN = QUAN + WA_ITEM-MENGE_P.
         VALUE = VALUE + WA_ITEM-NETPR_P.
       ENDLOOP.
       WA_FINAL-STCK_QUAN = WA_FINAL-STCK_QUAN + QUANTITY + QUAN.
       WA_FINAL-STCK_VAL = WA_FINAL-STCK_VAL + NET_VALUE + VALUE.
       CLEAR : QUANTITY,
               QUAN,
               NET_VALUE,
               VALUE,
               WA_ITEM,
               WA_MBEW.
       LOOP AT IT_VBRP INTO WA_VBRP WHERE MATNR = WA_MARA-MATNR.
         WA_FINAL-SALE_QUAN = WA_FINAL-SALE_QUAN + WA_VBRP-FKIMG.
         WA_FINAL-SALE_VAL  = WA_FINAL-SALE_VAL + WA_VBRP-NETWR.
         CLEAR : WA_VBRP.
       ENDLOOP.
     ENDLOOP.
   ENDLOOP.
   WA_FINAL-GROUP = WA_KLAH-CLASS.
   APPEND WA_FINAL TO IT_FINAL.
   CLEAR : WA_FINAL,
           WA_DATA,
           WA_MARA.
 ENDLOOP.

FREE FIELDCATALOG[].
PERFORM FLD_CATALOG USING:
            'GROUP' 'GROUP' 'GROUP' '01',
            'STCK_QUAN' 'STOCK QUANTITY' 'STOCK QUANTITY' '02',
            'STCK_VAL' 'STOCK VALUE' 'STOCK VALUE' '03',
            'SALE_QUAN' 'SALE QUANTITY' 'SALE QUANTITY' '04',
            'SALE_VAL' 'SALE VALUE' 'SALE VALUE' '05'.
PERFORM DISPLAY TABLES IT_FINAL.
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
*   EXPORTING
**     I_INTERFACE_CHECK                 = ' '
**     I_BYPASSING_BUFFER                = ' '
**     I_BUFFER_ACTIVE                   = ' '
*     I_CALLBACK_PROGRAM                = SY-REPID
*     I_CALLBACK_PF_STATUS_SET          = 'SET_PF_STATUS'
*     I_CALLBACK_USER_COMMAND           = 'USER_COMMAND'
**     I_CALLBACK_TOP_OF_PAGE            = ' '
**     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
**     I_CALLBACK_HTML_END_OF_LIST       = ' '
**     I_STRUCTURE_NAME                  =
**     I_BACKGROUND_ID                   = ' '
**     I_GRID_TITLE                      =
**     I_GRID_SETTINGS                   =
**     IS_LAYOUT                         =
*     IT_FIELDCAT                       = FIELDCATALOG[]
**     IT_EXCLUDING                      =
**     IT_SPECIAL_GROUPS                 =
**     IT_SORT                           =
**     IT_FILTER                         =
**     IS_SEL_HIDE                       =
**     I_DEFAULT                         = 'X'
**     I_SAVE                            = ' '
**     IS_VARIANT                        =
**     IT_EVENTS                         =
**     IT_EVENT_EXIT                     =
**     IS_PRINT                          =
**     IS_REPREP_ID                      =
**     I_SCREEN_START_COLUMN             = 0
**     I_SCREEN_START_LINE               = 0
**     I_SCREEN_END_COLUMN               = 0
**     I_SCREEN_END_LINE                 = 0
**     I_HTML_HEIGHT_TOP                 = 0
**     I_HTML_HEIGHT_END                 = 0
**     IT_ALV_GRAPHICS                   =
**     IT_HYPERLINK                      =
**     IT_ADD_FIELDCAT                   =
**     IT_EXCEPT_QINFO                   =
**     IR_SALV_FULLSCREEN_ADAPTER        =
**     O_PREVIOUS_SRAL_HANDLER           =
**   IMPORTING
**     E_EXIT_CAUSED_BY_CALLER           =
**     ES_EXIT_CAUSED_BY_USER            =
*    TABLES
*      T_OUTTAB                          =  IT_FINAL
**   EXCEPTIONS
**     PROGRAM_ERROR                     = 1
**     OTHERS                            = 2
*            .
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.


 FORM SET_PF_STATUS USING RT_EXTAB   TYPE  SLIS_T_EXTAB.

  SET PF-STATUS 'ZSSCP_STAT' EXCLUDING RT_EXTAB.

ENDFORM.

FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                         RS_SELFIELD TYPE SLIS_SELFIELD.
*  CASE COLUMN.
  BREAK KKIRTI.
  CASE RS_SELFIELD-fieldname.
    WHEN 'STCK_QUAN' OR 'STCK_VAL'.
      FREE IT_STCK[].
      LOOP AT IT_KLAH INTO WA_KLAH.
        LOOP AT IT_DATA INTO WA_DATA WHERE CLASS = WA_KLAH-CLASS.
*          PERFORM MATNR USING WA_DATA-MATKL CHANGING IT_MA.
          LOOP AT IT_MARA INTO WA_MARA WHERE MATKL = WA_DATA-MATKL.
            LOOP AT IT_MBEW INTO WA_MBEW WHERE MATNR =  WA_MARA-MATNR.
              CASE WA_MBEW-BWKEY.
                WHEN 'SSTN'.
                    WA_STCK-SSTN_QUAN = WA_STCK-SSTN_QUAN + WA_MBEW-LBKUM .
                    WA_STCK-SSTN_VAL = WA_STCK-SSTN_VAL + WA_MBEW-SALK3.
                WHEN 'SSPO'.
                    WA_STCK-SSPO_QUAN = WA_STCK-SSPO_QUAN + WA_MBEW-LBKUM .
                    WA_STCK-SSPO_VAL = WA_STCK-SSPO_VAL + WA_MBEW-SALK3.
                WHEN 'SSPU'.
                    WA_STCK-SSPU_QUAN = WA_STCK-SSPU_QUAN + WA_MBEW-LBKUM.
                    WA_STCK-SSPU_VAL = WA_STCK-SSPU_VAL + WA_MBEW-SALK3.
                WHEN 'SSCP'.
                  WA_STCK-SSCP_QUAN = WA_STCK-SSCP_QUAN + WA_MBEW-LBKUM .
                  WA_STCK-SSCP_VAL  = WA_STCK-SSCP_VAL  + WA_MBEW-SALK3.
                WHEN 'SSWH'.
                  WA_STCK-SSWH_QUAN = WA_STCK-SSWH_QUAN + WA_MBEW-LBKUM .
                  WA_STCK-SSWH_VAL = WA_STCK-SSWH_VAL + WA_MBEW-SALK3.
                ENDCASE.
              CLEAR : WA_MBEW.
           ENDLOOP.
           LOOP AT IT_HDR INTO WA_HDR .
             CASE WA_HDR-STATUS.
               WHEN '01'.
                 LOOP AT IT_ITEM INTO WA_ITEM WHERE QR_CODE = WA_HDR-QR_CODE.
                   WA_STCK-QUAN_01 = WA_STCK-QUAN_01 + WA_ITEM-MENGE_P.
                   WA_STCK-VAL_01 = WA_STCK-VAL_01 + WA_ITEM-NETPR_P.
                   CLEAR WA_ITEM.
                 ENDLOOP.
               WHEN '02'.
                 LOOP AT IT_ITEM INTO WA_ITEM WHERE QR_CODE = WA_HDR-QR_CODE.
                   WA_STCK-QUAN_02 = WA_STCK-QUAN_02 + WA_ITEM-MENGE_P.
                   WA_STCK-VAL_02 = WA_STCK-VAL_02 + WA_ITEM-NETPR_P.
                   CLEAR WA_ITEM.
                 ENDLOOP.
             ENDCASE.
           ENDLOOP.
*           WA_STCK-SSTN_QUAN = WA_STCK-SSTN_QUAN + QUAN_SSTN.
*           WA_STCK-SSPO_QUAN = WA_STCK-SSPO_QUAN + QUAN_SSPO.
*           WA_STCK-SSPU_QUAN = WA_STCK-SSPU_QUAN + QUAN_SSPU.
*           WA_STCK-SSCP_QUAN = WA_STCK-SSCP_QUAN + QUAN_SSCP.
*           WA_STCK-SSWH_QUAN = WA_STCK-SSWH_QUAN + QUAN_SSWH.

*           CLEAR : QUAN_SSTN ,
*                   QUAN_SSPO ,
*                   QUAN_SSPU ,
*                   QUAN_SSCP ,
*                   QUAN_SSWH .

*           LOOP AT IT_ITEM INTO WA_ITEM WHERE MATNR = WA_MARA-MATNR.
*               CASE WA_ITEM-STATUS.
*                 WHEN '01'.
*                   WA_STCK-QUAN_01 = WA_STCK-QUAN_01 + WA_ITEM-MENGE_P.
*                   WA_STCK-VAL_01 = WA_STCK-VAL_01 + WA_ITEM-NETPR_P.
*                 WHEN '02'.
*                   WA_STCK-QUAN_02 = WA_STCK-QUAN_02 + WA_ITEM-MENGE_P.
*                   WA_STCK-VAL_02 = WA_STCK-VAL_02 + WA_ITEM-NETPR_P.
**             QUAN = QUAN + WA_ITEM-MENGE_P.
**             VALUE = VALUE + WA_ITEM-NETPR_P.
*                   CLEAR : WA_ITEM.
*           ENDLOOP.
*           WA_STCK-SSTN_QUAN = WA_STCK-SSTN_QUAN + QUAN_SSTN + QUAN.         "STILL CHANGING"
*           WA_FINAL-STCK_VAL = WA_FINAL-STCK_VAL + NET_VALUE + VALUE.
*           CLEAR : QUANTITY,
*                   QUAN,
*                   NET_VALUE,
*                   VALUE,
*                   WA_ITEM,
*                   WA_MBEW.

*             WA_FINAL-SALE_QUAN = WA_FINAL-SALE_QUAN + WA_VBRP-FKIMG.
*             WA_FINAL-SALE_VAL  = WA_FINAL-SALE_VAL + WA_VBRP-NETWR.
*             CLEAR : WA_VBRP.
            CLEAR : WA_MARA.
          ENDLOOP.
          CLEAR : WA_DATA.
        ENDLOOP.
        WA_STCK-GROUP = WA_KLAH-CLASS.
        APPEND WA_STCK TO IT_STCK.
        CLEAR : WA_STCK,
                WA_KLAH.
      ENDLOOP.
      FREE FIELDCATALOG[].
      PERFORM FLD_CATALOG USING:
            'GROUP' 'GROUP' 'GROUP' '01',
            'QUAN_01' 'TRANSIT_QUAN' 'BUNDLES IN TRANSIT QUANTITY' '02',
            'VAL_01' 'TRANIT_VAL' 'BUNDLES IN TRANSIT VALUE' '03',
            'QUAN_02' 'WH_QUAN' 'BUNDLES IN WARE HOUSE QUANTITY' '04',
            'VAL_02' 'WH_VAL' 'BUNDLES IN WARE HOUSE VALUE' '05',
            'SSTN_QUAN' 'TNAGAR_QUANTITY' 'T NAGAR QUANTITY' '06',
            'SSTN_VAL' 'TNAGAR_VALUE' 'T NAGAR VALUE' '07',
            'SSPO_QUAN' 'PORUR_QUANTITY' 'PORUR QUANTITY' '08',
            'SSPO_VAL' 'PORUR_VALUE' 'PORUR VALUE' '09',
            'SSPU_QUAN' 'PRWKM_QUAN' 'PURUSHWAKAM QUANTITY' '10',
            'SSPU_VAL' 'PRWKM_VALUE' 'PURUSHWAKAM VALUE' '11',
            'SSCP_QUAN' 'CHMPT_QUAN' 'CHROMPET QUANTITY' '12',
            'SSCP_VAL' 'CHMPT_VALUE' 'CHROMPET VALUE' '13',
            'SSWH_QUAN' 'MDWRM_QUAN' 'MADHAWARAM QUANTITY' '14',
            'SSWH_VAL' 'MDWRM_VALUE' 'MADHAWARAM VALUE' '15'.

       CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
     I_CALLBACK_PROGRAM                = SY-REPID
     I_CALLBACK_PF_STATUS_SET          = 'SET_PF_STATUS'
     I_CALLBACK_USER_COMMAND           = 'USER_COMMAND'
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE                      =
*     I_GRID_SETTINGS                   =
*     IS_LAYOUT                         =
     IT_FIELDCAT                       = FIELDCATALOG[]
*     IT_EXCLUDING                      =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT                           =
*     IT_FILTER                         =
*     IS_SEL_HIDE                       =
*     I_DEFAULT                         = 'X'
*     I_SAVE                            = ' '
*     IS_VARIANT                        =
*     IT_EVENTS                         =
*     IT_EVENT_EXIT                     =
*     IS_PRINT                          =
*     IS_REPREP_ID                      =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0
*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   =
*     IT_HYPERLINK                      =
*     IT_ADD_FIELDCAT                   =
*     IT_EXCEPT_QINFO                   =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER           =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      T_OUTTAB                          =  IT_STCK
*   EXCEPTIONS
*     PROGRAM_ERROR                     = 1
*     OTHERS                            = 2
            .
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

*    WHEN 'STCK_VAL'.
*      WRITE : 'STCK VALUE'.
    WHEN 'SALE_QUAN' OR 'SALE_VAL'.
      FREE IT_SALE[].
     LOOP AT IT_KLAH INTO WA_KLAH.
        LOOP AT IT_DATA INTO WA_DATA WHERE CLASS = WA_KLAH-CLASS.
          LOOP AT IT_MARA INTO WA_MARA WHERE MATKL = WA_DATA-MATKL.
            LOOP AT IT_VBRP INTO WA_VBRP WHERE MATNR = WA_MARA-MATNR.
              CASE WA_VBRP-WERKS.
                WHEN 'SSTN'.
                    WA_SALE-SSTN_QUAN = WA_SALE-SSTN_QUAN + WA_VBRP-FKIMG .
                    WA_SALE-SSTN_VAL = WA_SALE-SSTN_VAL + WA_VBRP-NETWR.
                WHEN 'SSPO'.
                    WA_SALE-SSPO_QUAN = WA_SALE-SSPO_QUAN + WA_VBRP-FKIMG .
                    WA_SALE-SSPO_VAL = WA_SALE-SSPO_VAL + WA_VBRP-NETWR.
                WHEN 'SSPU'.
                    WA_SALE-SSPU_QUAN = WA_SALE-SSPU_QUAN + WA_VBRP-FKIMG.
                    WA_SALE-SSPU_VAL = WA_SALE-SSPU_VAL + WA_VBRP-NETWR.
                WHEN 'SSCP'.
                  WA_SALE-SSCP_QUAN = WA_SALE-SSCP_QUAN + WA_VBRP-FKIMG.
                  WA_SALE-SSCP_VAL  = WA_STCK-SSCP_VAL  + WA_VBRP-NETWR.
*                WHEN 'SSWH'.
*                  WA_SALE-SSWH_QUAN = WA_SALE-SSWH_QUAN + WA_VBRP-FKIMG .
*                  WA_SALE-SSWH_VAL = WA_SALE-SSWH_VAL + WA_VBRP-NETWR.
                ENDCASE.
*         WA_FINAL-SALE_QUAN = WA_FINAL-SALE_QUAN + WA_VBRP-FKIMG.
*         WA_FINAL-SALE_VAL  = WA_FINAL-SALE_VAL + WA_VBRP-NETWR.
         CLEAR : WA_VBRP.
       ENDLOOP.
            CLEAR : WA_MARA.
          ENDLOOP.
          CLEAR WA_DATA.
        ENDLOOP.
        WA_SALE-GROUP = WA_KLAH-CLASS.
        APPEND WA_SALE TO IT_SALE.
        CLEAR : WA_SALE,
                WA_KLAH.
     ENDLOOP.

     FREE FIELDCATALOG[].
      PERFORM FLD_CATALOG USING:
            'GROUP' 'GROUP' 'GROUP' '01',
            'SSTN_QUAN' 'TNAGAR_QUANTITY' 'T NAGAR QUANTITY' '02',
            'SSTN_VAL' 'TNAGAR_VALUE' 'T NAGAR VALUE' '03',
            'SSPO_QUAN' 'PORUR_QUANTITY' 'PORUR QUANTITY' '04',
            'SSPO_VAL' 'PORUR_VALUE' 'PORUR VALUE' '05',
            'SSPU_QUAN' 'PRWKM_QUAN' 'PURUSIWAKAM QUANTITY' '06',
            'SSPU_VAL' 'PRWKM_VALUE' 'PURUSIWAKAM VALUE' '07',
            'SSCP_QUAN' 'CHMPT_QUAN' 'CHROMPET QUANTITY' '08',
            'SSCP_VAL' 'CHMPT_VALUE' 'CHROMPET VALUE' '09'.

PERFORM DISPLAY TABLES IT_SALE.

*       CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
*   EXPORTING
**     I_INTERFACE_CHECK                 = ' '
**     I_BYPASSING_BUFFER                = ' '
**     I_BUFFER_ACTIVE                   = ' '
*     I_CALLBACK_PROGRAM                = SY-REPID
*     I_CALLBACK_PF_STATUS_SET          = 'SET_PF_STATUS'
*     I_CALLBACK_USER_COMMAND           = 'USER_COMMAND'
**     I_CALLBACK_TOP_OF_PAGE            = ' '
**     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
**     I_CALLBACK_HTML_END_OF_LIST       = ' '
**     I_STRUCTURE_NAME                  =
**     I_BACKGROUND_ID                   = ' '
**     I_GRID_TITLE                      =
**     I_GRID_SETTINGS                   =
**     IS_LAYOUT                         =
*     IT_FIELDCAT                       = FIELDCATALOG[]
**     IT_EXCLUDING                      =
**     IT_SPECIAL_GROUPS                 =
**     IT_SORT                           =
**     IT_FILTER                         =
**     IS_SEL_HIDE                       =
**     I_DEFAULT                         = 'X'
**     I_SAVE                            = ' '
**     IS_VARIANT                        =
**     IT_EVENTS                         =
**     IT_EVENT_EXIT                     =
**     IS_PRINT                          =
**     IS_REPREP_ID                      =
**     I_SCREEN_START_COLUMN             = 0
**     I_SCREEN_START_LINE               = 0
**     I_SCREEN_END_COLUMN               = 0
**     I_SCREEN_END_LINE                 = 0
**     I_HTML_HEIGHT_TOP                 = 0
**     I_HTML_HEIGHT_END                 = 0
**     IT_ALV_GRAPHICS                   =
**     IT_HYPERLINK                      =
**     IT_ADD_FIELDCAT                   =
**     IT_EXCEPT_QINFO                   =
**     IR_SALV_FULLSCREEN_ADAPTER        =
**     O_PREVIOUS_SRAL_HANDLER           =
**   IMPORTING
**     E_EXIT_CAUSED_BY_CALLER           =
**     ES_EXIT_CAUSED_BY_USER            =
*    TABLES
*      T_OUTTAB                          =  IT_SALE
**   EXCEPTIONS
**     PROGRAM_ERROR                     = 1
**     OTHERS                            = 2
*            .
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.

*    WHEN 'SALE_VAL'.
*      WRITE : 'SALE VALUE'.
  ENDCASE.

  CASE R_UCOMM.
    WHEN '&IC1'.
      READ TABLE IT_KLAH INTO WA_KLAH WITH KEY CLASS = RS_SELFIELD-VALUE.
      IF SY-SUBRC EQ 0.
        FREE IT_GRP[].
        LOOP AT IT_DATA INTO WA_DATA WHERE CLASS = WA_KLAH-CLASS.
          LOOP AT IT_MARA INTO WA_MARA WHERE MATKL = WA_DATA-MATKL.
            LOOP AT IT_MBEW INTO WA_MBEW WHERE MATNR = WA_MARA-MATNR.
              QUANTITY = QUANTITY + WA_MBEW-LBKUM .
              NET_VALUE = NET_VALUE + WA_MBEW-SALK3.
            ENDLOOP.
            LOOP AT IT_ITEM INTO WA_ITEM WHERE MATNR = WA_MARA-MATNR.
            QUAN = QUAN + WA_ITEM-MENGE_P.
            VALUE = VALUE + WA_ITEM-NETPR_P.
            ENDLOOP.
            WA_GRP-STCK_QUAN = WA_FINAL-STCK_QUAN + QUANTITY + QUAN.
            WA_GRP-STCK_VAL = WA_FINAL-STCK_VAL + NET_VALUE + VALUE.
            CLEAR : QUANTITY,
                    QUAN,
                    NET_VALUE,
                    VALUE,
                    WA_ITEM,
                    WA_MBEW.
*             LOOP AT IT_VBRP INTO WA_VBRP WHERE MATNR = WA_MARA-MATNR.
*               WA_GRP-SALE_QUAN = WA_FINAL-SALE_QUAN + WA_VBRP-FKIMG.
*               WA_GRP-SALE_VAL  = WA_FINAL-SALE_VAL + WA_VBRP-NETWR.
*               CLEAR : WA_VBRP.
*             ENDLOOP.

             CLEAR WA_MARA.
          ENDLOOP.
          WA_GRP-MATKL = WA_DATA-MATKL.
          APPEND WA_GRP TO IT_GRP.
          CLEAR : WA_GRP,
                  WA_MARA,
                  WA_DATA.
       ENDLOOP.

      ENDIF.
      FREE FIELDCATALOG[].
      PERFORM FLD_CATALOG USING:
            'MATKL' 'CAT COD' 'CAT COD' '01',
            'STCK_QUAN' 'STOCK QUANTITY' 'STOCK QUANTITY' '02',
            'STCK_VAL' 'STOCK VALUE' 'STOCK VALUE' '03'.
*            'SAL_QUAN' 'SALE QUANTITY' 'SALE QUANTITY' '04',
*            'SAL_VAL' 'SALE VALUE' 'SALE VALUE' '05'.
 IF IT_GRP IS NOT INITIAL.
   PERFORM DISPLAY TABLES IT_GRP.
*      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
*   EXPORTING
**     I_INTERFACE_CHECK                 = ' '
**     I_BYPASSING_BUFFER                = ' '
**     I_BUFFER_ACTIVE                   = ' '
*     I_CALLBACK_PROGRAM                = SY-REPID
*     I_CALLBACK_PF_STATUS_SET          = 'SET_PF_STATUS'
*     I_CALLBACK_USER_COMMAND           = 'USER_COMMAND'
**     I_CALLBACK_TOP_OF_PAGE            = ' '
**     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
**     I_CALLBACK_HTML_END_OF_LIST       = ' '
**     I_STRUCTURE_NAME                  =
**     I_BACKGROUND_ID                   = ' '
**     I_GRID_TITLE                      =
**     I_GRID_SETTINGS                   =
**     IS_LAYOUT                         =
*     IT_FIELDCAT                       = FIELDCATALOG[]
**     IT_EXCLUDING                      =
**     IT_SPECIAL_GROUPS                 =
**     IT_SORT                           =
**     IT_FILTER                         =
**     IS_SEL_HIDE                       =
**     I_DEFAULT                         = 'X'
**     I_SAVE                            = ' '
**     IS_VARIANT                        =
**     IT_EVENTS                         =
**     IT_EVENT_EXIT                     =
**     IS_PRINT                          =
**     IS_REPREP_ID                      =
**     I_SCREEN_START_COLUMN             = 0
**     I_SCREEN_START_LINE               = 0
**     I_SCREEN_END_COLUMN               = 0
**     I_SCREEN_END_LINE                 = 0
**     I_HTML_HEIGHT_TOP                 = 0
**     I_HTML_HEIGHT_END                 = 0
**     IT_ALV_GRAPHICS                   =
**     IT_HYPERLINK                      =
**     IT_ADD_FIELDCAT                   =
**     IT_EXCEPT_QINFO                   =
**     IR_SALV_FULLSCREEN_ADAPTER        =
**     O_PREVIOUS_SRAL_HANDLER           =
**   IMPORTING
**     E_EXIT_CAUSED_BY_CALLER           =
**     ES_EXIT_CAUSED_BY_USER            =
*    TABLES
*      T_OUTTAB                          =  IT_GRP
**   EXCEPTIONS
**     PROGRAM_ERROR                     = 1
**     OTHERS                            = 2
*            .
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.
  ENDIF.
  ENDCASE.

ENDFORM.

FORM FLD_CATALOG USING FP_FLDNAM TYPE FIELDNAME
                       FP_SELTEXT_M TYPE DD03P-SCRTEXT_M
                       FP_SELTEXT_L TYPE DD03P-SCRTEXT_L
                       FP_COLPOS    TYPE SYCUCOL.


    FIELDCATALOG-FIELDNAME   = FP_FLDNAM.
    FIELDCATALOG-SELTEXT_M   = FP_SELTEXT_M.
    FIELDCATALOG-SELTEXT_L   = FP_SELTEXT_L.
    FIELDCATALOG-COL_POS     = FP_COLPOS.
    APPEND FIELDCATALOG.
    CLEAR  FIELDCATALOG.

ENDFORM.
FORM GRP_F4.

SELECT CLINT
       CLASS
FROM   KLAH
INTO TABLE IT_KLAH
WHERE KLART = '026' AND WWSKZ = '0'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE         = ' '
      RETFIELD               = 'CLASS'
*     PVALKEY                = ' '
     DYNPPROG               = SY-REPID
     DYNPNR                 = SY-DYNNR
     DYNPROFIELD            = 'S_GRP'
*     STEPL                  = 0
*     WINDOW_TITLE           =
*     VALUE                  = ' '
     VALUE_ORG              = 'S'
*     MULTIPLE_CHOICE        = ' '
*     DISPLAY                = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM          = ' '
*     CALLBACK_METHOD        =
*     MARK_TAB               =
*   IMPORTING
*     USER_RESET             =
    TABLES
      VALUE_TAB              = IT_KLAH
*     FIELD_TAB              =
*     RETURN_TAB             =
*     DYNPFLD_MAPPING        =
   EXCEPTIONS
     PARAMETER_ERROR        = 1
     NO_VALUES_FOUND        = 2
     OTHERS                 = 3
            .
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.



  ENDFORM.

  FORM DISPLAY TABLES IT_TAB.
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
     I_CALLBACK_PROGRAM                = SY-REPID
     I_CALLBACK_PF_STATUS_SET          = 'SET_PF_STATUS'
     I_CALLBACK_USER_COMMAND           = 'USER_COMMAND'
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE                      =
*     I_GRID_SETTINGS                   =
*     IS_LAYOUT                         =
     IT_FIELDCAT                       = FIELDCATALOG[]
*     IT_EXCLUDING                      =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT                           =
*     IT_FILTER                         =
*     IS_SEL_HIDE                       =
*     I_DEFAULT                         = 'X'
*     I_SAVE                            = ' '
*     IS_VARIANT                        =
*     IT_EVENTS                         =
*     IT_EVENT_EXIT                     =
*     IS_PRINT                          =
*     IS_REPREP_ID                      =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0
*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   =
*     IT_HYPERLINK                      =
*     IT_ADD_FIELDCAT                   =
*     IT_EXCEPT_QINFO                   =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER           =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      T_OUTTAB                          =  IT_TAB
*   EXCEPTIONS
*     PROGRAM_ERROR                     = 1
*     OTHERS                            = 2
            .
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
 FREE IT_TAB[].
  ENDFORM.

* FORM MARA TABLES MARA_T LIKE IT_MR USING MAT_GRP TYPE MARA-MATKL ."CHANGING MAR_T TYPE
*
*   SELECT MATKL
*         MATNR
*  INTO TABLE MARA_T
*  FROM MARA
*  WHERE MATKL EQ MAT_GRP.
*
*ENDFORM.
*
*FORM MBEW TABLES MBEW_T LIKE IT_MBEW USING MARA_TB LIKE IT_MR.
*
*  SELECT MATNR
*           BWKEY
*           BWTAR
*           LBKUM
*           SALK3
*    FROM MBEW
*    INTO TABLE MBEW_T
*    FOR ALL ENTRIES IN MARA_TB
*    WHERE MATNR = MARA_TB-MATNR AND
*          BWKEY IN ('SSTN','SSPO','SSPU','SSCP','SSWH').
*
*ENDFORM.
