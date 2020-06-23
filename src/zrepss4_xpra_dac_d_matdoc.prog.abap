*$*$----------------------------------------------------------------$*$*
*$ Correction Inst.         0020751258 0000572479                     $*
*$--------------------------------------------------------------------$*
*$ Valid for       :                                                  $*
*$ Software Component   S4CORE                                        $*
*$  Release 103          To SAPK-10302INS4CORE                        $*
*$*$----------------------------------------------------------------$*$*
*&--------------------------------------------------------------------*
*& Object          REPS S4_XPRA_DAC_D_MATDOC
*& Object Header   PROG S4_XPRA_DAC_D_MATDOC
*&--------------------------------------------------------------------*
*>>>> START OF INSERTION <<<<
*&---------------------------------------------------------------------*
*& Report S4_XPRA_DAC_D_MATDOC
*&---------------------------------------------------------------------*
*& Template for XPRA programs based on guidelines from 2016
*& Data conversion guidelines are available at
*& https://wiki.wdf.sap.corp/wiki/x/OnNKbg
*&---------------------------------------------------------------------*
*>>>> END OF INSERTION <<<<<<
...
*&--------------------------------------------------------------------*
*& REPORT S4_XPRA_DAC_D_MATDOC
*&--------------------------------------------------------------------*
*>>>> START OF INSERTION <<<<
REPORT ZREPSS4_XPRA_DAC_D_MATDOC.

* This XPRA drops the index DAC_D_MATDOC~0 on the client field of table DAC_D_MATDOC.
* This drop is used to reduce memory consumption in the HANA DB which in general generates a concatenated key field for all keys
* Because DDIC requires the definition of keys and just one key field has been defined for this table duplicate record dumps would o
*CCUR IF DATA GETS INSERTED.
* Therefore, this drop is required.

CONSTANTS: GC_LOGID TYPE UPGBA_LOGID VALUE SY-REPID.
DATA:      LV_SUBRC TYPE SY-SUBRC.

CL_UPGBA_LOGGER=>CREATE( EXPORTING IV_LOGID = GC_LOGID IV_LOGTYPE = CL_UPGBA_LOGGER=>GC_LOGTYPE_TR ).
CL_UPGBA_LOGGER=>LOG->CLEANUP( ).

* Ensure only privileged user are allowed to manually start the XPRA
* 1. check for SUM privilege
AUTHORITY-CHECK OBJECT 'S_ADMI_FCD' ID 'S_ADMI_FCD' FIELD 'SUM'.
IF SY-SUBRC NE 0.
*   2. check for application-specific (or developer privilege)
  "authority-check object '<appl_auth_obj>' id '<appl_auth_id>' field '<auth_fld>'.
  AUTHORITY-CHECK OBJECT 'S_DEVELOP'
    ID 'DEVCLASS' FIELD '*'
    ID 'OBJTYPE'  FIELD 'PROG'
    ID 'OBJNAME'  FIELD SY-REPID
    ID 'P_GROUP'  DUMMY "not required in this context
    ID 'ACTVT'    FIELD '02'.
  IF SY-SUBRC NE 0.
    MESSAGE E900(UPGBA) INTO CL_UPGBA_LOGGER=>MV_LOGMSG.
    CL_UPGBA_LOGGER=>LOG->TRACE_SINGLE( ).
    CL_UPGBA_LOGGER=>LOG->CLOSE( ).
    EXIT.
  ENDIF.
ENDIF.

MESSAGE I034(UPGBA) WITH 'Starting to drop index DAC_D_MATDOC~0' SY-DATUM SY-UZEIT INTO CL_UPGBA_LOGGER=>MV_LOGMSG ##NO_TEXT.
CL_UPGBA_LOGGER=>LOG->TRACE_SINGLE( ).

CALL FUNCTION 'DB_EXISTS_INDEX'
  EXPORTING
    TABNAME         = 'DAC_D_MATDOC'
    INDEXNAME       = '0'
  IMPORTING
    SUBRC           = LV_SUBRC
  EXCEPTIONS
    PARAMETER_ERROR = 1
    OTHERS          = 2.
IF LV_SUBRC = 0. "index exists --> drop
  CLEAR LV_SUBRC.
  CALL FUNCTION 'DB_DROP_INDEX'
    EXPORTING
      DBINDEX               = 'DAC_D_MATDOC~0'
      TABNAME               = 'DAC_D_MATDOC'
    IMPORTING
      SUBRC                 = LV_SUBRC
    EXCEPTIONS
      INDEX_NOT_DROPPED     = 1
      PROGRAM_NOT_GENERATED = 2
      PROGRAM_NOT_WRITTEN   = 3
      OTHERS                = 4.
  IF SY-SUBRC <> 0 OR LV_SUBRC <> 0.
    MESSAGE W601(PU) WITH 'Index not dropped' '(due to internal error)' SY-DATUM SY-UZEIT  INTO CL_UPGBA_LOGGER=>MV_LOGMSG ##NO_TEXT
.
    CL_UPGBA_LOGGER=>LOG->TRACE_SINGLE( IV_PLEVEL = CL_UPGBA_LOGGER=>GC_PLEVEL_TWO IV_SEVERITY = CL_UPGBA_LOGGER=>GC_POST_PROCESS_RC
 ).
  ELSE.
    MESSAGE I034(UPGBA) WITH 'Index DAC_D_MATDOC~0 dropped' SY-DATUM SY-UZEIT INTO CL_UPGBA_LOGGER=>MV_LOGMSG ##NO_TEXT.
    CL_UPGBA_LOGGER=>LOG->TRACE_SINGLE( IV_PLEVEL = CL_UPGBA_LOGGER=>GC_PLEVEL_TWO ).
  ENDIF.
ELSE. "index not available, no drop
  MESSAGE I601(PU) WITH 'Index does not exist.' 'Drop not necessary' SY-DATUM SY-UZEIT  INTO CL_UPGBA_LOGGER=>MV_LOGMSG ##NO_TEXT.
  CL_UPGBA_LOGGER=>LOG->TRACE_SINGLE( IV_PLEVEL = CL_UPGBA_LOGGER=>GC_PLEVEL_TWO ).
ENDIF.

CL_UPGBA_LOGGER=>LOG->CLOSE( ).
*>>>> END OF INSERTION <<<<<<
*...
*&--------------------------------------------------------------------*
*>>> A T T E N T I O N: P L E A S E   N O T E:                        <<<
*>>> CORRECTION CONTAINS ADDITIONAL CHANGES THAT ARE NOT SHOWN HERE   <<<
*>>> DISPLAY ALL CHANGES BY NOTE ASSISTANT NOTE DISPLAY FUNCTIONALITY <<<
