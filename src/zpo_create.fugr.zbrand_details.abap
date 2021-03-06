FUNCTION ZBRAND_DETAILS.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(ET_DISPLAY) TYPE  ZBRAND_T
*"----------------------------------------------------------------------

  DATA :  WA_BRAND TYPE ZBRAND_TT.

  SELECT WRF_BRANDS~BRAND_ID , WRF_BRANDS_T~LANGUAGE , WRF_BRANDS_T~BRAND_DESCR FROM WRF_BRANDS AS WRF_BRANDS
    LEFT OUTER JOIN WRF_BRANDS_T AS WRF_BRANDS_T ON WRF_BRANDS_T~BRAND_ID = WRF_BRANDS~BRAND_ID
    INTO TABLE @DATA(IT_WRF_BRANDS)
    WHERE WRF_BRANDS~BRAND_ID = WRF_BRANDS_T~BRAND_ID AND WRF_BRANDS_T~LANGUAGE  = @SY-LANGU.

  LOOP AT IT_WRF_BRANDS ASSIGNING FIELD-SYMBOL(<WA_WRF_BRANDS>).

    WA_BRAND-BRAND_ID     = <WA_WRF_BRANDS>-BRAND_ID.
    WA_BRAND-BRAND_DESCR  = <WA_WRF_BRANDS>-BRAND_DESCR.

    APPEND WA_BRAND TO ET_DISPLAY.
    CLEAR WA_BRAND .


  ENDLOOP.



ENDFUNCTION.
