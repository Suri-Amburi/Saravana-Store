*&---------------------------------------------------------------------*
*& Include          ZHR_ABSENT_REP_TOP
*&---------------------------------------------------------------------*

***********tables************

TABLES : PERNR,PA0001,PA2001.

INFOTYPES : 0001 , 2001.

TYPES : BEGIN OF TY_PA0001,     "HR Master Record: Infotype 0001 (Org. Assignment)
          PERNR TYPE PA0001-PERNR,      "Personnel number
          SNAME TYPE PA0001-SNAME,      "Employee Name
          ENAME TYPE PA0001-ENAME,      " Formated Name OF employee
          BEGDA TYPE PA0001-BEGDA,
        END OF TY_PA0001.

TYPES :BEGIN OF TY_PA2001,      "HR Time Record: Infotype 2001 (Absences)
         PERNR TYPE PA2001-PERNR,      "Personnel number
         SUBTY TYPE PA2001-SUBTY,      "Subtype
         KALTG TYPE PA2001-KALTG,      "Calendar Days
         ABWTG TYPE PA2001-ABWTG,
       END OF TY_PA2001.

TYPES : BEGIN OF TY_FINAL,
          SL    TYPE I,                      " Serial Number
          PERNR TYPE PA0001-PERNR,        "Personnel number
          ENAME TYPE PA0001-ENAME,        "Employee Name
          ABWTG TYPE PA2001-ABWTG,
        END OF TY_FINAL.


data : it_pa2001 type table of ty_pa2001,
       wa_pa2001 type ty_pa2001.
*       PYPERNR type pa0001-pernr.

data : it_pa0001 type table of ty_pa0001,
       wa_pa0001 type ty_pa0001.

data : it_final type table of ty_final,
       wa_final type ty_final.

DATA :    sl       type i.


data: it_fieldcat type slis_t_fieldcat_alv,
      wa_fieldcat type slis_fieldcat_alv.

data: t_header      type slis_t_listheader,
        wa_header     type slis_listheader.
data: lv_date        type  pa0001-begda,
      wa_layout      type  slis_layout_alv.
