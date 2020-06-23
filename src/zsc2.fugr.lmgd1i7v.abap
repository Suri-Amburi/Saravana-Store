*&---------------------------------------------------------------------*
*&  Include           LMGD1I7V
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  COMMODITY_READ  INPUT
*&---------------------------------------------------------------------*
*       Read Commodty Definition after input
*----------------------------------------------------------------------*
MODULE commodity_read INPUT.

  PERFORM commodity_read.

ENDMODULE.                 " COMMODITY_READ  INPUT

*&---------------------------------------------------------------------*
*&      Form  commodity_read
*&---------------------------------------------------------------------*
*       Read Commodty Definition if required
*----------------------------------------------------------------------*
FORM commodity_read.

  IF tbac_physcomm-commodity NE mara-commodity.
    CLEAR tbac_physcomm.
    CLEAR tbac_physcommt.
  ENDIF.

  IF mara-commodity IS NOT INITIAL AND
     tbac_physcomm-commodity NE mara-commodity.

    SELECT SINGLE * FROM tbac_physcomm  WHERE commodity EQ mara-commodity.

    SELECT SINGLE * FROM tbac_physcommt WHERE commodity EQ mara-commodity AND
                                              langu EQ sy-langu.
  ENDIF.

ENDFORM.                 " COMMODITY_READ

*----------------------------------------------------------------------*
*  MODULE commodity_read
*----------------------------------------------------------------------*
*  Read Commodty Definition before output
*----------------------------------------------------------------------*
MODULE commodity_read OUTPUT.

  PERFORM commodity_read.

ENDMODULE.                 " COMMODITY_READ  OUTPUT
