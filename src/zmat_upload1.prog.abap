report ZMAT_UPLOAD1
       no standard page heading line-size 255.

* Include bdcrecx1_s:
* The call transaction using is called WITH AUTHORITY-CHECK!
* If you have own auth.-checks you can use include bdcrecx1 instead.
include bdcrecx1_s.

parameters: dataset(132) lower case.
***    DO NOT CHANGE - the generated data section - DO NOT CHANGE    ***
*
*   If it is nessesary to change the data section use the rules:
*   1.) Each definition of a field exists of two lines
*   2.) The first line shows exactly the comment
*       '* data element: ' followed with the data element
*       which describes the field.
*       If you don't have a data element use the
*       comment without a data element name
*   3.) The second line shows the fieldname of the
*       structure, the fieldname must consist of
*       a fieldname and optional the character '_' and
*       three numbers and the field length in brackets
*   4.) Each field must be type C.
*
*** Generated data section with specific formatting - DO NOT CHANGE  ***
data: begin of record,
* data element: WKFIL
        LOCNR_001(004),
* data element: BUKRS
        BUKRS_002(004),
* data element: EKORG
        EKORG_003(004),
* data element: VKOIV
        VKORG_004(004),
* data element: VTWIV
        VTWEG_005(002),
* data element: SPAIV
        SPART_006(002),
* data element: FABKL
        FABKL_007(002),
* data element: MATKL
        MATKL_008(009),
      end of record.

*** End generated data section ***

start-of-selection.

perform open_dataset using dataset.
perform open_group.

do.

read dataset dataset into record.
if sy-subrc <> 0. exit. endif.

perform bdc_dynpro      using 'SAPMWBE3' '0102'.
perform bdc_field       using 'BDC_CURSOR'
                              'WR02D-LOCNR'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENTR'.
perform bdc_field       using 'WR02D-LOCNR'
                              record-LOCNR_001.
perform bdc_dynpro      using 'SAPMWBE3' '0401'.
perform bdc_field       using 'BDC_OKCODE'
                              '=WAGR'.
perform bdc_field       using 'BDC_CURSOR'
                              'T001K-BUKRS'.
perform bdc_field       using 'T001K-BUKRS'
                              record-BUKRS_002.
perform bdc_field       using 'T001W-EKORG'
                              record-EKORG_003.
perform bdc_field       using 'T001W-VKORG'
                              record-VKORG_004.
perform bdc_field       using 'T001W-VTWEG'
                              record-VTWEG_005.
perform bdc_field       using 'T001W-SPART'
                              record-SPART_006.
perform bdc_field       using 'T001W-FABKL'
                              record-FABKL_007.
perform bdc_dynpro      using 'SAPLWR22' '0430'.
perform bdc_field       using 'BDC_CURSOR'
                              'WRF6-ABTNR(01)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=KOPE'.
perform bdc_dynpro      using 'SAPLWR22' '0431'.
perform bdc_field       using 'BDC_CURSOR'
                              'WRF6-MATKL'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'WRF6-MATKL'
                              record-MATKL_008.
perform bdc_dynpro      using 'SAPLWR22' '0431'.
perform bdc_field       using 'BDC_CURSOR'
                              'WRF6-ABTNR'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_dynpro      using 'SAPLWR22' '0431'.
perform bdc_field       using 'BDC_CURSOR'
                              'WRF6-ABTNR'.
perform bdc_field       using 'BDC_OKCODE'
                              '=UPDA'.
perform bdc_dynpro      using 'SAPLWR22' '0430'.
perform bdc_field       using 'BDC_CURSOR'
                              'WRF6-ABTNR(01)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=UPDA'.
perform bdc_transaction using 'WB02'.

enddo.

perform close_group.
perform close_dataset using dataset.
