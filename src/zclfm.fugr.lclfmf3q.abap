*&---------------------------------------------------------------------*
*&      Form  LESEN_TCLC
*&---------------------------------------------------------------------*
*       Read classification status from TCLC
*       depending on class type.
*       -> set table xtclc, global variables cl*
*----------------------------------------------------------------------*
form lesen_tclc using p_klart like rmclf-klart.

*-- read status table

  read table xtclc with key mandt = sy-mandt
                            klart = p_klart.

  if sy-subrc = 0.
    clear cl_statusf.
    clear cl_statusge.
    clear cl_statusum.
    clear cl_statusus.
    read table xtclc with key mandt = sy-mandt
                              klart = p_klart
                              frei  = kreuz.
    if sy-subrc = 0.
      cl_statusf = xtclc-statu.
    endif.
    read table xtclc with key mandt    = sy-mandt
                              klart    = p_klart
                              gesperrt = kreuz.
    if sy-subrc = 0.
      cl_statusge = xtclc-statu.
    endif.
    read table xtclc with key mandt     = sy-mandt
                              klart     = p_klart
                              unvollstm = kreuz.
    if sy-subrc = 0.
      cl_statusum = xtclc-statu.
    endif.
    read table xtclc with key mandt     = sy-mandt
                              klart     = p_klart
                              unvollsts = kreuz.
    if sy-subrc = 0.
      cl_statusus = xtclc-statu.
    endif.

  else.
    select * from tclc                                  "#EC CI_NOORDER
             where klart = p_klart
               and loeschvorm ne kreuz.
      xtclc = tclc.
      if tclc-frei = kreuz.
        xtclc-stattxt = text-200.
        cl_statusf    = tclc-statu.
      endif.
      if tclc-gesperrt = kreuz.
        xtclc-stattxt = text-201.
        cl_statusge   = tclc-statu.
      endif.
      if tclc-unvollstm = kreuz.
        xtclc-stattxt = text-202.
        cl_statusum   = tclc-statu.
      endif.
      if tclc-unvollsts = kreuz.
        xtclc-stattxt = text-203.
        cl_statusus   = tclc-statu.
      endif.
      append xtclc.
    endselect.

    if sy-subrc <> 0.
*      message e541 with p_klart.                              "1930745
      message e541 with p_klart                                "1930745
        RAISING error_class_status.                            "1930745
    endif.
    clear xtclc.
    sort xtclc by mandt klart statu.
  endif.

* status 'incomplete by system' has to exist
  if cl_statusus is initial.
    message e028 with text-203.
  endif.

* remember class type for status has been read successfully      2653421
  cl_status_klart = p_klart.                                  "  2653421

* setup table itlc:
* - status of current classtype ecxept incomplete-system.
* - only used for status popups windows.
  refresh itclc.
  loop at xtclc where klart = p_klart
                  and unvollsts = space.
    itclc-statu   = xtclc-statu.
    itclc-stattxt = xtclc-stattxt.
    append itclc.
  endloop.

endform.                               " LESEN_TCLC
