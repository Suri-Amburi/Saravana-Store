@AbapCatalog.sqlViewName: 'ZV_PO_VEN_008'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Get Vendor Detail'
@OData.publish: true
define view ZI_PO_VEN_008 as select from ZI_PO_008 
association[0..1] to lfa1 as _lfa1 on $projection.lifnr = _lfa1.lifnr
association[1..1] to makt as _makt on $projection.matnr = _makt.matnr

{
//ZI_PO_008
key ebeln,
key ebelp,
matnr,
txz01,
werks,
@Semantics.quantity.unitOfMeasure : 'zpo_008.meins'
menge,
meins,
@Semantics.amount.currencyCode : 'zpo_008.waers'
netpr,
waers,
@Semantics.amount.currencyCode : 'zpo_008.waers'
netwr,

/* Admin Data */
@Semantics.user.lastChangedBy: true
aedat,
@Semantics.systemDateTime.createdAt: true
erdat,
@Semantics.user.createdBy: true
ernam,
lifnr,

  /* Public associations */
_lfa1,
_makt

    
}
