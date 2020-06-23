class ZMM42_UDP_T definition
  public
  final
  create public .

public section.

  class-methods GET_MAT_UPDT
    importing
      !IM_MATNR type ZMM41_C
    exporting
      !EX_MARA type CHAR100 .
protected section.
private section.
ENDCLASS.



CLASS ZMM42_UDP_T IMPLEMENTATION.


  METHOD GET_MAT_UPDT.
    UPDATE MARA SET ZZARTICLE         = IM_MATNR-ZZARTICLE
                    ZZLABEL_DESC      = IM_MATNR-ZZLABEL_DESC
                    ZZIVEND_DESC      = IM_MATNR-ZZIVEND_DESC
                    ZZEMP_CODE        = IM_MATNR-ZZEMP_CODE
                    ZZEMP_PER         = IM_MATNR-ZZEMP_PER
                    ZZPO_ORDER_TXT    = IM_MATNR-ZZPO_ORDER_TXT
                    ZZDISC_ALLOW      = IM_MATNR-ZZDISC_ALLOW
                    ZZISEXCHANGE      = IM_MATNR-ZZISEXCHANGE
                    ZZISNONSTOCK      = IM_MATNR-ZZISNONSTOCK
                    ZZISREFUND        = IM_MATNR-ZZISREFUND
                    ZZISSALEABLE      = IM_MATNR-ZZISSALEABLE
                    ZZISWEIGHED       = IM_MATNR-ZZISWEIGHED
                    ZZISVALID         = IM_MATNR-ZZISVALID
                    ZZISTAXEXEMPT     = IM_MATNR-ZZISTAXEXEMPT
                    ZZISOPENPRICE     = IM_MATNR-ZZISOPENPRICE
                    ZZISOPENDESC      = IM_MATNR-ZZISOPENDESC
                    ZZISINCTAX        = IM_MATNR-ZZISINCTAX
                    ZZRET_DAYS        = IM_MATNR-ZZRET_DAYS
                    ZZPRICE_FRM       = IM_MATNR-ZZPRICE_FRM
                    ZZPRICE_to        = IM_MATNR-ZZPRICE_to
                    WHERE MATNR       = IM_MATNR-MATNR.
    IF SY-SUBRC  IS INITIAL.
      COMMIT WORK.
      EX_MARA = 'Updated Sucessfully'.
    ELSE.
      EX_MARA = 'Not Updated'.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
