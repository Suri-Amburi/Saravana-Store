*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 28.02.2020 at 12:27:52
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZGROUP_VEN......................................*
DATA:  BEGIN OF STATUS_ZGROUP_VEN                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGROUP_VEN                    .
CONTROLS: TCTRL_ZGROUP_VEN
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZGROUP_VEN                    .
TABLES: ZGROUP_VEN                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
