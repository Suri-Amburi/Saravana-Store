*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 26.09.2019 at 15:09:15
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSST_EMAIL......................................*
DATA:  BEGIN OF STATUS_ZSST_EMAIL                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSST_EMAIL                    .
CONTROLS: TCTRL_ZSST_EMAIL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSST_EMAIL                    .
TABLES: ZSST_EMAIL                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
