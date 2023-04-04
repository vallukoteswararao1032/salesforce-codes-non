/*----------------------------------------------------
* @name           SentinelPostInstall 
* @date           10 May 2020
* @description    This is a post install script class. 
* ------------------------------------------------------*/
global class SentinelPostInstall implements InstallHandler {
    global void onInstall(InstallContext context) {
        if(context.previousVersion() == null) {
            try {
                List<Sentinel_Order_Field_Mapping__c> settingList = getListOrderMapFields(SentinelConstants.categoryVsSentinelFieldMap, false);
                settingList.addAll(getListOrderMapFields(SentinelConstants.categoryVsCustomAttributeMap, true));
                insert settingList;
            } catch(Exception e) {
                system.debug('Error:' + e.getMessage());
            }
       }
    }

    global List<Sentinel_Order_Field_Mapping__c> getListOrderMapFields(Map<String, List<String>> catFieldMap , Boolean isCustom) {
        List<Sentinel_Order_Field_Mapping__c> settingList = new List<Sentinel_Order_Field_Mapping__c>();
        Map<String, Map<String, String>> catVsFieldvsDesMap = SentinelConstants.catVsFieldvsDescriptionMap;
        Map<String, Map<String, String>> catVsFieldvsDefaultValueMap = SentinelConstants.catVsFieldvsDefaultValuesMap;
        Integer i=0;
        if(isCustom) i=100;
        for(String category : catFieldMap.keySet()) {
            system.debug('+++++ category---->' + category);
            system.debug('+++++ catFieldMap.get(category)---->' + catFieldMap.get(category));

            for(String field : catFieldMap.get(category)) {
                Sentinel_Order_Field_Mapping__c odrSetting = new Sentinel_Order_Field_Mapping__c(
                    name = category + i++,
                    Category__c = category,
                    IsCustomAttribute__c = isCustom,
                    Sentinel_Api_Field__c = field);
                	System.debug('odrSetting___' + odrSetting);
                if(isCustom) {
                    odrSetting.Field_Description__c = 'Name of the user-defined custom attributes.';
                } else {
                    system.debug('category->' + category);
                    system.debug('(catVsFieldvsDesMap.containsKey(category)->' + catVsFieldvsDesMap.containsKey(category));
                    system.debug('catVsFieldvsDesMap.get(odrSetting.Category__c).containsKey(field)->' + catVsFieldvsDesMap.get(odrSetting.Category__c).containsKey(field));
                    if(catVsFieldvsDesMap.containsKey(category) && 
                        catVsFieldvsDesMap.get(odrSetting.Category__c).containsKey(field)) {
                            system.debug('added field description');
                            odrSetting.Field_Description__c = catVsFieldvsDesMap.get(odrSetting.Category__c).get(field);
                    } else {
                        odrSetting.Field_Description__c = '';
                    }
                    if(catVsFieldvsDefaultValueMap.containsKey(category) && 
                        catVsFieldvsDefaultValueMap.get(odrSetting.Category__c).containsKey(field)) {
                            system.debug('added field default values');
                            odrSetting.SF_Api_Field__c = catVsFieldvsDefaultValueMap.get(odrSetting.Category__c).get(field);
                    } else {
                        odrSetting.SF_Api_Field__c = '';
                    }
                }
                settingList.add(odrSetting);
            }
        }
        return settingList;
    }
}