@AbapCatalog.sqlViewName: 'ZV_PO_008'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'zpo_008 + ekko'
define view ZI_PO_008 as select from zpo_008
 association[0..1] to ekko as _ekko on $projection.ebeln = _ekko.ebeln
{
   //zpo_008
   key client,
   key ebeln,
   key ebelp,
   matnr,
   txz01,
   werks,
   menge,
   meins,
   netpr,
   waers,
   netwr,
   aedat,
   erdat,
   ernam ,
   _ekko.lifnr
}
