({
	doInit : function(component, event, helper) {
        var orderId=component.get('v.recordId');
            var action = component.get("c.getOrderJson");
        action.setParams({ orderId : orderId });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                if (result.getReturnValue().length > 0) {
                    console.log('result first', result.getReturnValue());
                    var jsonData = JSON.parse(result.getReturnValue());
        			var entitlement=jsonData.entitlements[0].entitlement;
      			 	component.set("v.gridData",entitlement);
                }
            } else if (state == "ERROR") {
                alert("Error in calling server side action");
            }
        });
        $A.enqueueAction(action);  
	},
    updateProductFeatures : function(component,event,helper){
         var jsonEntilementList=component.get('v.gridData');
        component.set('v.loaded', "false");
		var entilementData=jsonEntilementList;
		var entilementJson='{"EID":"'+entilementData.eId+'",'+
            			   '"status":"'+entilementData.state+'",'+
                           '"startDate":"'+entilementData.startDate+'",'+
                           '"endDate":"'+entilementData.expiry.endDate+'",'+
            			   '"product":[';
        for(var prod of entilementData.productKeys.productKey){
			var ProdJson='{"externalId":"'+  prod.item.itemProduct.product.externalId+'","feature":[';
            for(var feature of prod.item.itemProduct.itemProductFeatures.itemProductFeature){
                ProdJson=ProdJson+'{"featureId":"'+feature.feature.id +'",'+
                                '"licenseModelId":"'+feature.itemFeatureLicenseModel.licenseModel.id+'",'+
                  				'"licenseModelName":"'+feature.itemFeatureLicenseModel.licenseModel.name+'",'+
                                '"itemFeatureState":"'+feature.itemFeatureState+'",'+
                    			'"featureName":"'+feature.feature.nameVersion.name+'",'	;
                if(feature.itemFeatureLicenseModel.attributes !== null ){
                    var featureAtt=JSON.stringify(feature.itemFeatureLicenseModel.attributes);
                    var featureAttributes = featureAtt.substring(1, featureAtt.length-1);
                    ProdJson=ProdJson+featureAttributes+'},';
                    // console.log('ProdJson----if-ProdJson------ ',ProdJson);
                 }
                else{
                    var ProdJsonRsemi=ProdJson.substring(0,ProdJson.lastIndexOf(","));
                    ProdJson=ProdJsonRsemi+'},';
                   // console.log('else---ProdJson-------- ',ProdJson);
                }
            }
			
			var prodJsonsubString=ProdJson.substring(0, ProdJson.lastIndexOf(",")); 
            ProdJson=prodJsonsubString+']},';  
            entilementJson=entilementJson+ProdJson;
        }
		var entilementJsonsubString=entilementJson.substring(0, entilementJson.lastIndexOf(","));
        entilementJson=entilementJsonsubString+']}';
        console.log('entilementJson---------- ',entilementJson);
        var orderId=component.get('v.recordId');
        var action = component.get("c.updateFeatures");
        action.setParams({ jsonEntilementObj : entilementJson,orderId : orderId });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                if (result.getReturnValue().length > 0) {
                     component.set('v.loaded', "true");
					this.showSuccessToast(component);
                }
            } else if (state == "ERROR") {
                this.showErrorToast(component);
                alert("Error in calling server side action");
            }
        });
        $A.enqueueAction(action);

    },
    showSuccessToast: function (component) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": "success",
            "message": "The record has been saved successfully."
        });
        toastEvent.fire();
    },
    showErrorToast: function (component) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type": "error",
            "message": "There was error saving record. Please retry."
        });
        toastEvent.fire();
    },
})