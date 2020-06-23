*& TC     : Suri
*& Date   : 04.03.2020
*& Des    : Custom program to send Materials to POS in Background


REPORT zzrbdmidoc MESSAGE-ID b1.
* Changes:
* XLP 031298: CCMS-Runtime-Monitoring

TABLES: tbdme, edimsgt.
DATA: arcparams LIKE  arc_params,
      pripars   LIKE  pri_params,
      valid.

DATA :
  edidc_dummy TYPE edidc,
  r_fisel     TYPE RANGE OF  werks_d,
  r_matnr     TYPE RANGE OF  matnr.

* Tabelle der reorganisierbaren Pointer-ID's.
DATA: BEGIN OF gt_reorg_pointer OCCURS 0.
        INCLUDE STRUCTURE bdicpident.
      DATA: END OF gt_reorg_pointer.

*** Final Report
TYPES :
  BEGIN OF ty_status,
    matnr   TYPE matnr,
    docnum  TYPE docnum,
    message TYPE  bapi_msg,
    type    TYPE bapi_mtype,
  END OF ty_status.
DATA : gt_status TYPE TABLE OF ty_status.

INCLUDE zzmbdconst.
INCLUDE zzrbdauthi.
INCLUDE zzrsecccms.

CONSTANTS: c_mestype_in_migration TYPE bdcp2_act VALUE 'M'.

DATA: BEGIN OF t_tbdme OCCURS 0.
        INCLUDE STRUCTURE tbdme.
      DATA: END OF t_tbdme.
DATA: t_tbda2  LIKE tbda2 OCCURS 0.
DATA: wa_tbda2 LIKE tbda2.
DATA: read_flag TYPE c VALUE space.
FIELD-SYMBOLS  : <ls_pointers> TYPE bdcp2.
FIELD-SYMBOLS  : <gs_pointers> TYPE bdcp2.
PARAMETERS: mestyp LIKE tbdme-mestyp OBLIGATORY MATCHCODE OBJECT tbdme DEFAULT c_mestype_artstm.

* authority check
AT SELECTION-SCREEN.
  PERFORM authority_check_master_data USING mestyp c_true.

* message type check
AT SELECTION-SCREEN ON mestyp.
  IF read_flag = space.
    SELECT * FROM tbdme INTO TABLE t_tbdme WHERE idocfbname <> space.
    SELECT * FROM tbda2 INTO TABLE t_tbda2.
    read_flag = 'X'.
  ENDIF.

* Check if message type supports change pointers
  READ TABLE t_tbdme TRANSPORTING NO FIELDS
       WITH KEY mestyp = mestyp.
  IF sy-subrc <> 0.
    MESSAGE e157 WITH mestyp.
  ENDIF.

* Check if message type is currently being migrated
  READ TABLE t_tbda2 TRANSPORTING NO FIELDS
       WITH KEY mestyp = mestyp
                bdcp2_act = c_mestype_in_migration.
* if an entry in tbda2 with status 'in migration' exists
* change pointers of this message type may not be
* distributed
  IF sy-subrc EQ 0.
    MESSAGE e169 WITH mestyp.
  ENDIF.

* distribute IDOCs for a given message type
START-OF-SELECTION.

  CALL FUNCTION 'ENQUEUE_E_BDCPS'
    EXPORTING
      mode_bdcps     = 'E'
      mandt          = sy-mandt
*     cpident        =
      mestype        = mestyp
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

  IF sy-subrc = 1.
    MESSAGE i115 WITH mestyp.
    EXIT.
  ELSEIF sy-subrc = 2 OR sy-subrc = 3.
    MESSAGE i156 WITH mestyp.
    EXIT.
  ENDIF.
*** Get Change Pointers
  IF sy-batch = 'X'.
    CALL FUNCTION 'GET_PRINT_PARAMETERS'
      EXPORTING
        mode                   = 'CURRENT'
        no_dialog              = 'X'
      IMPORTING
        out_parameters         = pripars
        out_archive_parameters = arcparams
        valid                  = valid
      EXCEPTIONS
        OTHERS                 = 0.
    PERFORM puch_data_pos.
  ELSE.
    PERFORM puch_data_pos.
  ENDIF.
*** Display Report
  PERFORM display_report.
  CALL FUNCTION 'DEQUEUE_ALL'.

*---------------------------------------------------------------------*
*       FORM F4HELP_FBNAME_CHECK                                      *
*---------------------------------------------------------------------*
FORM f4help_fbname_check TABLES t_tbdme STRUCTURE tbdme.

  DATA: BEGIN OF t_help_value OCCURS 0.
          INCLUDE STRUCTURE help_value.
        DATA: END OF t_help_value.

  DATA: BEGIN OF values OCCURS 0, string(50), END OF values.

  t_help_value-tabname = 'EDIMSG'.     " field title EDIMSG-MESTYP
  t_help_value-fieldname = 'MESTYP'.
  MOVE 'X' TO t_help_value-selectflag.
  APPEND t_help_value.
  t_help_value-tabname = 'EDIMSGT'.    " field title EDIMSGT-DESCRP
  t_help_value-fieldname = 'DESCRP'.
  MOVE ' ' TO t_help_value-selectflag.
  APPEND t_help_value.
  LOOP AT t_tbdme.
    MOVE t_tbdme-mestyp TO values.
    APPEND values.
    CLEAR edimsgt.
    SELECT SINGLE * FROM edimsgt
         WHERE mestyp = t_tbdme-mestyp AND langua = sy-langu.
    MOVE edimsgt-descrp TO values.
    APPEND values.
  ENDLOOP.

  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
    IMPORTING
      select_value = mestyp
    TABLES
      fields       = t_help_value
      valuetab     = values.

ENDFORM.

FORM puch_data_pos.
  DATA : docnum     TYPE edi_docnum,
         mara_ivend TYPE zmara_ivend.
***Idoc Open
  edidc_dummy-direct = 1.
  edidc_dummy-mestyp = mestyp.

  CALL FUNCTION 'IDOC_CCMS_OPEN'                              "XLP031298
    EXPORTING
      i_edidc      = edidc_dummy
      idocfunction = idoc_fill
      idocprocess  = idoc_output_change_pointer
    EXCEPTIONS
      insert_error = 1
      OTHERS       = 2.
*** For Idoc
  APPEND VALUE #( low = 'SSTN' option = 'EQ' sign = 'I' ) TO r_fisel.
*** Get Change Pinters
  SELECT * FROM bdcp2 INTO TABLE @DATA(gt_chag_pointer) WHERE mestype = @c_mestype_artstm AND cdobjcl = @c_chg_doc_obj AND process = @space.
  IF sy-subrc <> 0.
    MESSAGE s091(zmsg_cls).
    EXIT.
  ENDIF.
*** Sort by Change Pointer ID
  SORT gt_chag_pointer BY cpident.
  DATA(lt_pointers) = gt_chag_pointer.
  SORT lt_pointers BY cdobjid.
*** Delete Adjacent Duplicates
  DELETE ADJACENT DUPLICATES FROM lt_pointers COMPARING cdobjid.
  REFRESH : gt_status.
  LOOP AT lt_pointers ASSIGNING <ls_pointers>.
    DATA(lv_tabix) = sy-tabix.
    APPEND VALUE #( low = <ls_pointers>-cdobjid option = 'EQ' sign = 'I' ) TO r_matnr.
    LOOP AT gt_chag_pointer ASSIGNING <gs_pointers> WHERE cdobjid = <ls_pointers>-cdobjid.
      APPEND VALUE #( cpident = <gs_pointers>-cpident  ) TO gt_reorg_pointer.
    ENDLOOP.
*** Free Idoc Memory ID
    FREE MEMORY ID 'IDOC'.
*** Trigget Material IDoc
    SUBMIT zzrwdposan WITH pa_vkorg = c_vkorg
                      WITH pa_vtweg = c_vtweg
                      WITH so_fisel IN r_fisel[]
                      WITH pa_art   = c_x
                      WITH so_matar IN r_matnr[]
                      AND RETURN EXPORTING LIST TO MEMORY.
*** Importing Idoc Number
    CLEAR : docnum.
    IMPORT docnum FROM MEMORY ID 'IDOC'.
    IF sy-subrc IS INITIAL.
*** Update Change pointers to DB on Successful Creation of IDOC
      CALL FUNCTION 'CHANGE_POINTERS_STATUS_WRITE'
        EXPORTING
          message_type           = c_mestype_artstm
        TABLES
          change_pointers_idents = gt_reorg_pointer.
      MESSAGE s093(zmsg_cls) WITH docnum <ls_pointers>-cdobjid.
      IMPORT mara_ivend FROM MEMORY ID 'MARA_IVEND'.
      IF mara_ivend-group IS INITIAL OR mara_ivend-tax_code IS INITIAL.
        APPEND VALUE #( matnr = <ls_pointers>-cdobjid docnum = docnum message = 'Idoc Created without Group / Tax Code' type = 'W' ) TO gt_status.
      ELSE.
        APPEND VALUE #( matnr = <ls_pointers>-cdobjid docnum = docnum message = 'Success' type = 'S' ) TO gt_status.
      ENDIF.
    ELSE.
      APPEND VALUE #( matnr = <ls_pointers>-cdobjid docnum = '' message = 'Failed' type = 'E' ) TO gt_status.
      MESSAGE s092(zmsg_cls) WITH <ls_pointers>-cdobjid.
    ENDIF.
    REFRESH : gt_reorg_pointer , r_matnr.
  ENDLOOP.
*** Close Idoc
  CALL FUNCTION 'IDOC_CCMS_CLOSE'.
ENDFORM.

FORM display_report.
  IF gt_status IS NOT INITIAL.
    cl_demo_output=>display(
   EXPORTING
     data =   gt_status ).
  ENDIF.
ENDFORM.
