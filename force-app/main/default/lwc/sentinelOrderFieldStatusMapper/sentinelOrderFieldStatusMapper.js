import { api, LightningElement, track } from 'lwc';

export default class SentinelOrderFieldStatusMapper extends LightningElement {

    @api orderMapperList = [];
    @api statusPicklist = [];
    @track entitlementList = [];
    @track showLoader = false;

    connectedCallback() {
        try{
            this.showLoader = true;
            console.log('status---',this.statusPicklist);
            console.log('orderMapperList---',this.orderMapperList);
            let arr = [];
            for(let i=0; i<this.orderMapperList.length; i++) {
                if(this.orderMapperList[i].Category__c == 'EntitlementStatus' && this.orderMapperList[i].sObjectName__c == 'Order' && this.orderMapperList[i].IsCustomAttribute__c == false) {
                    arr.push(this.orderMapperList[i]);
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