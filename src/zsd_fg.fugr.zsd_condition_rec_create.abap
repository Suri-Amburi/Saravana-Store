FUNCTION ZSD_CONDITION_REC_CREATE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(QR_CODE) TYPE  ZQR_CODE
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
*** Selling Price details from Touch Point 2
  SELECT * FROM ZINW_T_ITEM INTO TABLE @DATA(LT_ITEM) WHERE QR_CODE = @QR_CODE.
  IF SY-SUBRC <> 0.
    WA_RETURN-LOG_MSG_NO = '001'.
    WA_RETURN-MESSAGE = 'Invalid QR Code'.
    APPEND WA_RETURN TO RETURN.
    RETURN.
  ENDIF.

  LOOP AT LT_ITEM ASSIGNING <LS_ITEM>.
    CASE <LS_ITEM>-MAT_CAT.
      WHEN C_B.
        PERFORM UPLOAD_CONDTION_RECORD_B.
      WHEN C_S.
        PERFORM UPLOAD_CONDTION_RECORD_S.
      WHEN C_E.
        PERFORM UPLOAD_CONDTION_RECORD_E.
      WHEN C_G.
        PERFORM UPLOAD_CONDTION_RECORD_G.
    ENDCASE.

  ENDLOOP.
ENDFUNCTION.
