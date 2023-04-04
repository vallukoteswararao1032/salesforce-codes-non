({
  scriptLoaded: function (component, event, helper) {
    helper.doInit(component, event);
  },

  onRender: function (component, event) {
    var selectedList = component.get("v.selectedFieldList");

    for (var i = 1; i <= selectedList.length; i++) {
      $("." + selectedList[i - 1]).each(function (j, obj) {
        if ($(obj).attr("data-level") == i) {
          $(obj).addClass('selectedDiv');
        }
      });
    }
  },

  showModal: function (component, event, helper) {
    component.set("v.isModalOpen", true);
  },

  clearFieldValue: function (component, event, helper) {
    component.set("v.fieldApiName", "");
    component.set("v.selectedFieldList", []); //changed from selectFieldList to selectedFieldList 10th feb 2022
    component.set("v.thirdLevelFieldList", []);
    component.set("v.secondLevelFieldList", []);
  },

  closeModel: function (component, event, helper) {
    component.set("v.isModalOpen", false);
  },

  firstListClickHandler: function (component, event, helper) {
    $(event.target).addClass("selectedDiv");
    var selectedList = [];
    selectedList[0] = event.target.id;
    component.set("v.selectedFieldList", selectedList);
    if (event.target.getAttribute("data-type") == "REFERENCE") {
      helper.retrieveFieldList(component, event.target.getAttribute("data-referenceTo"), 2);
    } else {
      component.set("v.fieldType", event.target.getAttribute("data-type"));
      helper.setFieldApiName(component);
      component.set("v.secondLevelFieldList", []);
      component.set("v.thirdLevelFieldList", []);
      component.set("v.isModalOpen", false);
    }
  },

  secondListClickHandler: function (component, event, helper) {
    $(event.target).addClass("selectedDiv");
    var selectedList = component.get("v.selectedFieldList");
    selectedList[1] = event.target.id;
    if (selectedList.length == 3) selectedList.pop();
    component.set("v.selectedFieldList", selectedList);
    if (event.target.getAttribute("data-type") == "REFERENCE") {
      helper.retrieveFieldList(component, event.target.getAttribute("data-referenceTo"), 3);
    } else {
      component.set("v.fieldType", event.target.getAttribute("data-type"));
      helper.setFieldApiName(component);
      component.set("v.thirdLevelFieldList", []);
      component.set("v.isModalOpen", false);
    }
  },

  thirdListClickHandler: function (component, event, helper) {
    $(event.target).addClass("selectedDiv");
    var selectedList = component.get("v.selectedFieldList");
    selectedList[2] = event.target.id;
    component.set("v.fieldType", event.target.getAttribute("data-type"));
    component.set("v.selectedFieldList", selectedList);
    helper.setFieldApiName(component);
    component.set("v.isModalOpen", false);
  },


});