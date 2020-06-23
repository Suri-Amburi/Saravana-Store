*----------------------------------------------------------------------*
***INCLUDE ZPHOTO_PO_APP_REP_STATUS_90O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
 SET PF-STATUS 'ZGUI_9000'.
 SET TITLEBAR 'TITLE'.
IF CONTAINER IS NOT BOUND.
    CREATE OBJECT CONTAINER
      EXPORTING
        CONTAINER_NAME = 'MYCONTAINER'.
    CREATE OBJECT GRID
      EXPORTING
        I_PARENT = CONTAINER.
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.
    PERFORM PREPARE_FCAT.
    PERFORM DISPLAY_DATA_SCR3.




ENDMODULE.
