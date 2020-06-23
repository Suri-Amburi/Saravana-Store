* INCLUDE LCLFMF60

************************************************************************

*&---------------------------------------------------------------------*
*&      Form  CHANGE_CLFY_STATUS
*&---------------------------------------------------------------------*
*       Change classification status
*----------------------------------------------------------------------*
*       P_NEWVALUE = space : call popup to ask for value.
*                  <> space: set directly in field,
*                            no popup, but checks.

  INCLUDE LCLFMF3M .  " CHANGE_CLFY_STATUS

  INCLUDE LCLFMF3L .  " PRUEFE_STATUS_AND_REKURSION

  INCLUDE LCLFMF3K .  " BUILD_SEL_API

  INCLUDE LCLFMF3J .  " CHECK_DELOB_ALL_TABS

  INCLUDE LCLFMF3I .  " EXPAND_UDEF
