*----------------------------------------------------------------------*
* INCLUDE LCLFMTO4 .
* top module for classification 99.
*----------------------------------------------------------------------*

constants:
    c_prog_myself like syst-repid    value 'SAPLCLFM',
    c_prog_clfm   like syst-repid    value 'SAPLCLFM',
    c_prog_ctms   like syst-repid    value 'SAPLCTMS',

* characteristics subscreen: name , dynnr
    c_char_subscreen(30) type c      value 'SUBSCR_BEWERT',
    c_dynnr_ctms  like syst-dynnr    value '5000',

* ok codes CL*
    ok_clfm_change   like sy-ucomm value 'CLFM_CHNG',
    ok_clfm_display  like sy-ucomm value 'CLFM_DISP',
*   CL24N: load all objects
    ok_all_chng      like sy-ucomm value 'ALL_CHNG',
    ok_all_disp      like sy-ucomm value 'ALL_DISP',

* fixed dynpro numbers
    dynpro199     like syst-dynnr    value '0199',
    dynp1100      like syst-dynnr    value '1100',
    dynp1101      like syst-dynnr    value '1101',
    dynp1102      like syst-dynnr    value '1102',
    dynp1110      like syst-dynnr    value '1110',

* object to a class
    dynp1500      like syst-dynnr    value '1500',    "long
    dynp1600      like syst-dynnr    value '1600',    "short

* objects of a class ...
*   ... overview screen
    dynp1511      like syst-dynnr    value '1511',    "long
    dynp1611      like syst-dynnr    value '1611',    "short
*   ... 1 object type of a class
    dynp1510      like syst-dynnr    value '1510',    "long
    dynp1610      like syst-dynnr    value '1610',    "short
*   ... classes of a class
    dynp1512      like syst-dynnr    value '1512',    "long
    dynp1612      like syst-dynnr    value '1612'.    "short

data:
    cl_status,
    dynpro1xx      like syst-dynnr,    "Subscreen-Nr.
    fromcl20,
    no_class       like tcla-tracl,
    sklasse        like klah-class,

    g_sel_changed  like sy-batch,
* G_SEL_CHANGED: neue Selektionsdaten eingegeben. Prüfung notwendig,
*                ob altes Objekt gesichert werden muss (ab 4.6).

    g_save_pobtab  like tclao-obtab,
* G_SAVE_POBTAB: Wird gesetzt, falls das Objektauswahlbild
* einmal richtig bearbeitet wurde

    g_modus,
* g_modus: nur als Paramter für ClCA-PROCESS-CLASSTYPE
*          = 2  wenn in cl20/21
*          = 1  sonst
* g_ok_code_1: further processing of oc_code (my be changed !)

    g_main_dynnr     like sy-dynnr,
    g_alloc_dynnr    like sy-dynnr,
    g_value_dynnr    like sy-dynnr,
* main:  dynpro number of main screen (called for object trx)
* alloc: dynpro number of allocation subscreen
* value: dynpro number of character value assignment subscreen

    g_alloc_dynlg    like sy-batch.
* dynpro of size long (x) or short(_)
* dynpro data set when trx's are started




























