*-----------------------------------------------------------------------
*  Module MARA-MHDRZ
* Verprobungen zu Mindestrestlaufzeit/Gesamthaltbarkeit/Lagerprozentsatz
*-----------------------------------------------------------------------
MODULE mara-mhdrz.

  CHECK bildflag = space.
  CHECK t130m-aktyp NE aktypa AND t130m-aktyp NE aktypz.

  CALL FUNCTION 'MARA_MHDRZ'
    EXPORTING
      p_mara_mhdrz = mara-mhdrz
      ret_mhdrz    = lmara-mhdrz
      p_mara_mhdhb = mara-mhdhb
      ret_mhdhb    = lmara-mhdhb
      p_mara_mhdlp = mara-mhdlp
      ret_mhdlp    = lmara-mhdlp
* AHE: 19.03.98 - A (4.0c)
      p_mara_iprkz = mara-iprkz
      ret_iprkz    = lmara-iprkz
* AHE: 19.03.98 - E
    IMPORTING
      ret_mhdrz    = lmara-mhdrz
      ret_mhdhb    = lmara-mhdhb
      ret_mhdlp    = lmara-mhdlp
* AHE: 19.03.98 - A (4.0c)
      ret_iprkz    = lmara-iprkz.
* AHE: 19.03.98 - E

ENDMODULE.
