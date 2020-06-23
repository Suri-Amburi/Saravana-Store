***INCLUDE RSECCCMS
* constants for process names-during IDOC processing for CCMS statistics

CONSTANTS:
  IDOC_OUTPUT_WITH_NAST(1)           VALUE '1',
  IDOC_OUTPUT_CHANGE_POINTER(1)      VALUE '2',
  IDOC_OUTPUT_WITHOUT_NAST(1)        VALUE '3',
  IDOC_OUTBOUND_SEND(1)              VALUE '4',
  IDOC_SELECT_AND_WRITE_TO_DB(1)     VALUE '5',
  IDOC_PROCESS_INBOUND(1)            VALUE '6'.

* constants for function names-during IDOC processing for CCMS statistic
CONSTANTS:
  IDOC_FILL(1)     VALUE 'A',
  IDOC_SAVE(1)     VALUE 'B',
  IDOC_SEND(1)     VALUE 'C',
  IDOC_PROCESS(1)  VALUE 'D'.

CONSTANTS:
  TRFC(1)   VALUE '1',
  DATEI(1)  VALUE '3',
  CPIC(1)   VALUE '0'.

CONSTANTS:
  INBOUND(1) VALUE '2'.
