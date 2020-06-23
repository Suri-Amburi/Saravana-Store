*&---------------------------------------------------------------------*
*& Report ZTEST_QR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTEST_QR.

PARAMETERS: BARCODE LIKE TFO05-TDBARCODE DEFAULT 'ZQR_CODE',
            BARCDATA(50) TYPE C LOWER CASE DEFAULT '1234567890',
            FILENAME TYPE STRING LOWER CASE DEFAULT 'c:\this pc\downloads'.


DATA:ERRMSG(80)   TYPE C,
      BC_CMD       LIKE ITCOO,
      BP_CMD       LIKE ITCOO,
      BITMAPSIZE   TYPE I,
      BITMAP2_SIZE TYPE I,
      W            TYPE I,
      H            TYPE I,
      BITMAP       LIKE RSPOLPBI OCCURS 10 WITH HEADER LINE,
      BITMAP2      LIKE RSPOLPBI OCCURS 10 WITH HEADER LINE,
      L_BITMAP     TYPE XSTRING,
      OTF          LIKE ITCOO OCCURS 10 WITH HEADER LINE.

PERFORM GET_OTF_BC_CMD  IN PROGRAM SAPMSSCO
                       USING BARCODE
                             BARCDATA
                             BC_CMD.

CHECK SY-SUBRC = 0.
BP_CMD-TDPRINTCOM = 'BP'.

PERFORM GET_OTF_BP_CMD  IN PROGRAM SAPMSSCO
                        USING BARCODE
                             BP_CMD-TDPRINTPAR.

CHECK SY-SUBRC = 0.

PERFORM RENDERBARCODE IN PROGRAM SAPMSSCO
                     TABLES BITMAP
                      USING BC_CMD
                            BP_CMD
                            BARCDATA
                            BITMAPSIZE
                            W
                            H
                            ERRMSG.

CHECK SY-SUBRC = 0.
PERFORM BITMAP2OTF IN PROGRAM SAPMSSCO
                   TABLES BITMAP
                          OTF
                    USING BITMAPSIZE
                          W
                          H.

DATA LENGTH TYPE I.
DATA HEX TYPE XSTRING.
DATA BITMAP3 TYPE XSTRING.
FIELD-SYMBOLS  <FS>   TYPE X.
CLEAR: HEX, BITMAP3.

LOOP AT OTF.
  LENGTH = OTF-TDPRINTPAR+2(2).
  ASSIGN OTF-TDPRINTPAR+4(LENGTH) TO <FS> CASTING.
  HEX = <FS>(LENGTH).
  CONCATENATE BITMAP3 HEX INTO BITMAP3 IN BYTE MODE.
ENDLOOP.

* convert from old format to new format

  HEX = 'FFFFFFFF01010000'.
CONCATENATE BITMAP3(8) HEX BITMAP3+8 INTO BITMAP3 IN BYTE MODE.
CLEAR HEX.
SHIFT HEX RIGHT BY 90 PLACES IN BYTE MODE.
CONCATENATE BITMAP3(42) HEX BITMAP3+42 INTO BITMAP3 IN BYTE MODE.
DATA BITMAP4 TYPE SBDST_CONTENT.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      BUFFER                = BITMAP3 " XSTRING
    TABLES
      BINARY_TAB            = BITMAP4.
DATA BITMAP4_SIZE TYPE I.
BITMAP4_SIZE = XSTRLEN( BITMAP3 ).

CALL FUNCTION 'SAPSCRIPT_CONVERT_BITMAP'
EXPORTING
   OLD_FORMAT                     = 'BDS'
   NEW_FORMAT                     = 'BMP'
   BITMAP_FILE_BYTECOUNT_IN       = BITMAP4_SIZE
IMPORTING
   BITMAP_FILE_BYTECOUNT          = BITMAP2_SIZE
  TABLES
    BITMAP_FILE                    = BITMAP2
   BDS_BITMAP_FILE                = BITMAP4
EXCEPTIONS
   NO_BITMAP_FILE                 = 1
   FORMAT_NOT_SUPPORTED           = 2
   BITMAP_FILE_NOT_TYPE_X         = 3
   NO_BMP_FILE                    = 4
   BMPERR_INVALID_FORMAT          = 5
   BMPERR_NO_COLORTABLE           = 6
   BMPERR_UNSUP_COMPRESSION       = 7
   BMPERR_CORRUPT_RLE_DATA        = 8
   BMPERR_EOF                     = 9
   BDSERR_INVALID_FORMAT          = 10
   BDSERR_EOF                     = 11.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      BIN_FILESIZE = BITMAP2_SIZE
      FILENAME     = FILENAME
      FILETYPE     = 'BIN'
    CHANGING
      DATA_TAB     = BITMAP2[]
    EXCEPTIONS
      OTHERS       = 3.

*  DATA: gi_filename    type rlgrap–filename,
*      gi_name        type stxbitmaps–tdname,
*      gi_object      type stxbitmaps–tdobject,
*      gi_id          type stxbitmaps–tdid,
*      gi_btype       type stxbitmaps–tdbtype,
*      gi_resident    type stxbitmaps–resident,
*      gi_autoheight  type stxbitmaps–autoheight,
*      gi_bmcomp      type stxbitmaps–bmcomp,
*      gi_resolution  type stxbitmaps–resolution.
*
*  ""Graphic handling
*constants:
*      c_stdtext  like thead–tdobject value ‘TEXT’,
*      c_graphics like thead–tdobject value ‘GRAPHICS’,
*      c_bmon     like thead–tdid     value ‘BMON’,
*      c_bcol     like thead–tdid     value ‘BCOL’.
*
*  gi_name = ‘QRCODE10’.         ""name of the qrcode will be in se78 after one time running this program
*  gi_object = ‘GRAPHICS’.
*  gi_id = ‘BMAP’.
*  gi_btype = ‘BCOL’. “If u want black and white pass BMON
*  gi_resident = ‘ ‘.
*  gi_autoheight =  ‘X’.
*  gi_bmcomp = ‘X’.
*  l_extension = ‘BMP’.
*
*  ""importing the image into se78 before displaying it in the smartform.
*
*  perform import_bitmap_bds    using blob
*                                   gi_name
*                                   gi_object
*                                   gi_id
*                                   gi_btype
*                                   l_extension
*                                   ‘ ‘
*                                   gi_resident
*                                   gi_autoheight
*                                   gi_bmcomp
*                          changing l_docid
*                                   gi_resolution.
*
*IF sy–subrc = 0.
*
*  DATA:fname TYPE rs38l_fnam.
*
*  ""gettingt the name FM of the smartform
*  CALL FUNCTION ‘SSF_FUNCTION_MODULE_NAME’
*   EXPORTING
*     formname                 = ‘ZTEST_QR’
**   VARIANT                  = ‘ ‘
**   DIRECT_CALL              = ‘ ‘
*  IMPORTING
*    fm_name                  = fname
* EXCEPTIONS
*   NO_FORM                  = 1
*   NO_FUNCTION_MODULE       = 2
*   OTHERS                   = 3  .
*
*""Calling the FM of the smartform for display
*  CALL FUNCTION fname
*    EXPORTING
**    ARCHIVE_INDEX              =
**    ARCHIVE_INDEX_TAB          =
**    ARCHIVE_PARAMETERS         =
**    CONTROL_PARAMETERS         =
**    MAIL_APPL_OBJ              =
**    MAIL_RECIPIENT             =
**    MAIL_SENDER                =
**    OUTPUT_OPTIONS             =
**    USER_SETTINGS              = ‘X’
*      w_name                     = ‘QRCODE10’
**  IMPORTING
**    DOCUMENT_OUTPUT_INFO       =
**    JOB_OUTPUT_INFO            =
**    JOB_OUTPUT_OPTIONS         =
*  EXCEPTIONS
*    FORMATTING_ERROR           = 1
*    INTERNAL_ERROR             = 2
*    SEND_ERROR                 = 3
*    USER_CANCELED              = 4
*    OTHERS                     = 5            .
*
*  IF sy–subrc <> 0.
** Implement suitable error handling here
*  ENDIF.
*
*ENDIF.
*
*ENDFORM.
