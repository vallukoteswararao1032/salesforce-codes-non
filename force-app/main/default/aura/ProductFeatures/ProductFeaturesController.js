({
	doInit : function(component, event, helper) {
		helper.doInit(component, event, helper);
	},
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
        if(event.getSource().get("v.name")=='EXCLUDED'){
          component.set("v.isInclued",false);  
        }
        else{
            component.set("v.isInclued",true); 
            component.set("v.featureLicenceModel",event.getSource().get("v.value"));
       }
   },
   closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", false);
   },
  
   submitDetails: function(component, event, helper) {
      // Set isModalOpen attribute to false
      //Add your code to call apex method or do some processing
      component.set("v.isModalOpen", false);
   },
    updateProductFeatures:function(component, event, helper){
      	helper.updateProductFeatures(component, event, helper);  
    }
})