class ZNCCX_IINTEGRATION_SERVICE_SAV definition
  public
  inheriting from CX_AI_APPLICATION_FAULT
  create public .

public section.

  data AUTOMATIC_RETRY type PRX_AUTOMATIC_RETRY read-only .
  data CONTROLLER type PRXCTRLTAB read-only .
  data DETAIL type ZNCAPIEXCEPTION read-only .
  data NO_RETRY type PRX_NO_RETRY read-only .
  data WF_TRIGGERED type PRX_WORKFLOW_TRIGGERED read-only .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !AUTOMATIC_RETRY type PRX_AUTOMATIC_RETRY optional
      !CONTROLLER type PRXCTRLTAB optional
      !DETAIL type ZNCAPIEXCEPTION optional
      !NO_RETRY type PRX_NO_RETRY optional
      !WF_TRIGGERED type PRX_WORKFLOW_TRIGGERED optional .
protected section.
private section.
ENDCLASS.



CLASS ZNCCX_IINTEGRATION_SERVICE_SAV IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
me->AUTOMATIC_RETRY = AUTOMATIC_RETRY .
me->CONTROLLER = CONTROLLER .
me->DETAIL = DETAIL .
me->NO_RETRY = NO_RETRY .
me->WF_TRIGGERED = WF_TRIGGERED .
  endmethod.
ENDCLASS.
