interface ZNCII_SAVE_PRODUCT_LIST_INBOUN
  public .


  methods SAVE_PRODUCT_LIST_INBOUND
    importing
      !INPUT type ZNCIINTEGRATION_SERVICE_SAVE_P
    raising
      ZNCCX_IINTEGRATION_SERVICE_SAV .
endinterface.
