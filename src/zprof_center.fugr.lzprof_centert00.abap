*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 25.10.2019 at 13:31:18
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZPROF_CENTER....................................*
DATA:  BEGIN OF STATUS_ZPROF_CENTER                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPROF_CENTER                  .
CONTROLS: TCTRL_ZPROF_CENTER
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZPROF_CENTER                  .
TABLES: ZPROF_CENTER                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
