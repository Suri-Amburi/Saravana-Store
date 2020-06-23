data: begin of common part clfmto1.
*--------------------------

data: begin of klastab occurs 50.
        include structure rmclk.
data: end of klastab.
*
data: begin of g_klastab_sav occurs 50.
        include structure rmclk.
data:   stepl   like syst-stepl.
data: end of g_klastab_sav.
*
data: begin of cla,
        change,
        aeblg.
data: end   of cla.

data: obj like rmclobtx occurs 1 with header line.
*
data:
      modify_s100,
      messagetype,
      messagee                         value 'E',
      messagew                         value 'W',
      messagei                         value 'I',
      messages                         value 'S',
      messagetext  like t100-text,
      zeile        like syst-stepl,
*-- SOBTAB: die zur aktuellen Bearbeitung selektierte Tabelle
      sobtab       like tcla-obtab,
      pobtab       like tcla-obtab,
*-- MULTI_OBJ: Kennzeichen, daß mehrere Objekttypen in Klassenart mgl.
      multi_obj    like tcla-multobj,
      save_klart   like tcla-klart,
      object_tcode like syst-tcode,
      fkbname      like rs38l-name     value 'OBJECT_CHECK_',
      kreuz        like rmclf-kreuz    value 'X',
      no_datum     like rmclm-basisd,
      no_classify  like rmclm-basisd,
      no_status    like rmclm-basisd,
*-- Hierarchie erlaubt zu KLassenart
      clhier       like tcla-hierarchie,
*-- Änderungsbelege zu KLassenart erlaubt
      claeblg      like tcla-aeblgzuord,
*-- CHANGE_SUBSC_ACT: SUBSCREEN für Änderungsnr. aktiv!!!
      change_subsc_act,
      tablen       type i.

data: end   of common part clfmto1.
