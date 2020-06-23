@AbapCatalog.sqlViewName: 'ZV1_PO_008'
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'UI PO Consuption'


/* UI Info */
@UI: {
 headerInfo: { typeName: 'Purchase Order', typeNamePlural: 'Purchase Orders',title: { type: #STANDARD, value: 'ebeln' } } }


@Search.searchable: true
define view ZC_PO_008
  as select from ZI_PO_VEN_008
{
      //ZI_PO_VEN_008
      @UI.facet: [ { id:              'ebeln',
                     purpose:         #STANDARD,
                     type:            #IDENTIFICATION_REFERENCE,
                     label:           'Travel',
                     position:        10 } ]
   @UI: {
          lineItem:       [ { position: 20, importance: #HIGH } ],
          identification: [ { position: 20 } ],
          selectionField: [ { position: 20 } ] }
      @Consumption.valueHelpDefinition: [{ entity : {name: '_lfa1', element: 'Purchase Order'  } }]
      
   @ObjectModel.text.element: ['Vendor Name']
   @Search.defaultSearchElement: true
  key ebeln,
   @UI: {
          lineItem:       [ { position: 30, importance: #MEDIUM } ],
          identification: [ { position: 30, label: 'Line Item' } ] }
  key ebelp,
  @UI: {
          lineItem:       [ { position: 40, importance: #HIGH } ],
          identification: [ { position: 40 } ],
          selectionField: [ { position: 40 } ] }
      @Consumption.valueHelpDefinition: [{ entity : {name: '_makt', element: 'Material No.'  } }]

      @ObjectModel.text.element: ['CustomerName']
      @Search.defaultSearchElement: true
      matnr,
      txz01,
      werks,
       @UI: {
          lineItem:       [ { position: 60, importance: #MEDIUM } ],
          identification: [ { position: 60, label: 'Total Quantity' } ] }
          @Semantics.quantity.unitOfMeasure : 'zpo_008.meins'
      menge,
      meins,
      netpr,
      waers,
       @UI: {
          lineItem:       [ { position: 70, importance: #MEDIUM } ],
          identification: [ { position: 70, label: 'Total Price' } ] }
      @Semantics.amount.currencyCode : 'zpo_008.waers'
      netwr,
      aedat,
      erdat,
      ernam,
      lifnr,
      /* Associations */
      //ZI_PO_VEN_008
      _lfa1,
     _makt

}
