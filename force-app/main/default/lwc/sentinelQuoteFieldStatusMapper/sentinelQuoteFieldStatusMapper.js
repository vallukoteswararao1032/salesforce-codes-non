import { api, LightningElement, track } from 'lwc';

export default class sentinelQuoteFieldStatusMapper extends LightningElement {

    @api quoteMapperList = [];
    @api statusPicklist = [];
    @track entitlementList = [];
    @track showLoader = false;

    connectedCallback() {
        try{
            this.showLoader = true;
            console.log('status---',this.statusPicklist);
            console.log('quoteMapperList---',this.quoteMapperList);
            let arr = [];
            for(let i=0; i<this.quoteMapperList.length; i++) {
                if(this.quoteMapperList[i].Category__c == 'EntitlementStatus' && this.quoteMapperList[i].sObjectName__c == 'Quote' && this.quoteMapperList[i].IsCustomAttribute__c == false) {
                    arr.push(this.quoteMapperList[i]);
                }
            }
            this.entitlementList = JSON.parse(JSON.stringify(arr));
            console.log('entitlementList---',this.entitlementList);
            this.showLoader = false;
        }
        catch(e) {
            console.log(e);
        }
    }

    fieldChanged(event) {
        try{
            let element = this.entitlementList.find(o => o.Id === event.target.dataset.id);
            element.SF_orderfield_value__c = event.target.value;
        }
        catch(e) {
            console.log(e);
        }
    }

    @api 
    passStatusData() {
        return this.entitlementList;
    }
}