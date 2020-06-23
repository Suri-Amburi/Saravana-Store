*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 05.02.2020 at 19:55:14
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSIZE_VAL.......................................*
DATA:  BEGIN OF STATUS_ZSIZE_VAL                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSIZE_VAL                     .
CONTROLS: TCTRL_ZSIZE_VAL
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZSIZE_VAL                     .
TABLES: ZSIZE_VAL                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
