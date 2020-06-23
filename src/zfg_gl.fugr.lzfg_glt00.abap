*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 23.05.2019 at 11:37:09
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZGL_ACC_T.......................................*
DATA:  BEGIN OF STATUS_ZGL_ACC_T                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGL_ACC_T                     .
CONTROLS: TCTRL_ZGL_ACC_T
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZGL_ACC_T                     .
TABLES: ZGL_ACC_T                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
