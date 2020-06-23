*&---------------------------------------------------------------------*
*& Include          ZXM06U36
*&---------------------------------------------------------------------*
*IF SY-TCODE = 'ME21N' OR SY-TCODE = 'ME22N' OR SY-TCODE = 'ME23N' .

  EKKO_CI-AGENT_NAME   = I_CI_EKKO-AGENT_NAME   .
  EKKO_CI-USER_NAME    = I_CI_EKKO-USER_NAME    .
  EKKO_CI-ERDATE       = I_CI_EKKO-ERDATE       .
  EKKO_CI-APPROVER1    = I_CI_EKKO-APPROVER1    .
  EKKO_CI-APPROVER1_DT = I_CI_EKKO-APPROVER1_DT .
  EKKO_CI-APPROVER2    = I_CI_EKKO-APPROVER2    .
  EKKO_CI-APPROVER2_DT = I_CI_EKKO-APPROVER2_DT .
  EKKO_CI-ZDAYS = I_CI_EKKO-ZDAYS .

*ENDIF.
