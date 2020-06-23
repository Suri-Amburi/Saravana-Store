*---------------------------------------------------------------------*
*       FORM CREATE_ICON                                              *
*---------------------------------------------------------------------*
*       ICON ermitteln                                                *
*---------------------------------------------------------------------*
form create_icon.
  call function 'ICON_CREATE'
       EXPORTING
            name                  = 'ICON_CHECKED'
       IMPORTING
            result                = icon1
       EXCEPTIONS
            icon_not_found        = 01
            outputfield_too_short = 02.
  call function 'ICON_CREATE'
       EXPORTING
            name                  = 'ICON_LOCKED'
       IMPORTING
            result                = icon2
       EXCEPTIONS
            icon_not_found        = 01
            outputfield_too_short = 02.
  call function 'ICON_CREATE'
       EXPORTING
            name                  = 'ICON_INCOMPLETE'
       IMPORTING
            result                = icon3
       EXCEPTIONS
            icon_not_found        = 01
            outputfield_too_short = 02.
  call function 'ICON_CREATE'
       EXPORTING
            name                  = 'ICON_FAILURE'
       IMPORTING
            result                = icon4
       EXCEPTIONS
            icon_not_found        = 01
            outputfield_too_short = 02.

endform.
