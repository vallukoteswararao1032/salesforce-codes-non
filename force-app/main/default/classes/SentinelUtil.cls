public with sharing class SentinelUtil{
    private static final String Client = 'SFDC-STD-1.0';
    public static List<Sentinel_User_Info__c> rd = [SELECT Request_Timeout__c, Username__c, Password__c, Org_URL__c, DML_Url__c, Order_Sync__c, Quote_Sync__c, Subscription_Sync__c, ProdDML_Url__c, ProdOrg_URL__c, ProdUsername__c, ProdPassword__c, StageOrg_URL__c, StageDML_Url__c, StageUsername__c, StagePassword__c, Selected_Org__c
                                                    FROM Sentinel_User_Info__c /* WHERE Name='Primary User' */];
    static List<String> hexMap = new List<String>{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
    
    
    public static String newGuid(){
        String randomStringAsHex = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));

        String versionHexBits = randomStringAsHex.SubString(14, 16); // 7th bit
        String variantHexBits = randomStringAsHex.SubString(18, 20); // 9th bit

        Integer versionIntBits = convertHexToInt(versionHexBits);
        Integer variantIntBits = convertHexToInt(variantHexBits);

        Integer versionShiftedIntBits = versionIntBits & 15 | 64;  // (i & 0x0f) | 0x40
        Integer variantShiftedIntBits = variantIntBits & 63 | 128; // (i & 0x3f) | 0x80

        String versionShiftedHexBits = convertIntToHex(versionShiftedIntBits); // Always begins with 4
        String variantShiftedHexBits = convertIntToHex(variantShiftedIntBits); // Always begins with one of 8,9,a,b

        String guid = randomStringAsHex.SubString(0, 8) + '-' + randomStringAsHex.SubString(8, 12) + '-' + versionShiftedHexBits + randomStringAsHex.SubString(14, 16) + '-' + variantShiftedHexBits + randomStringAsHex.SubString(18, 20) + '-' + randomStringAsHex.substring(20);

        return guid;
    }

    static Integer convertHexToInt(String hex){
        Integer d0 = hexMap.IndexOf(hex.Substring(1, 2));
        Integer d1 = hexMap.IndexOf(hex.Substring(0, 1));

        Integer intval = d0 + (d1 * 16);
        return intval;
    }

    static String convertIntToHex(Integer intval){
        String hs0 = hexMap.Get(intval & 15);
        String hs1 = hexMap.Get(((intval >> 4) & 15));
        return hs1 + hs0;
    }

    public static List<Sentinel_Order_Field_Mapping__c> getListOrderMapFields(Map<String, List<String>> catFieldMap, Boolean isCustom){
        List<Sentinel_Order_Field_Mapping__c> settingList = new List<Sentinel_Order_Field_Mapping__c>();
        System.debug('settingList___' + settingList);
        Integer i = 0;
        if (isCustom)
            i = 100;
        for (String category : catFieldMap.keySet()){
            System.debug('catFieldMap.keySet()__________' + catFieldMap.keySet());
            for (String field : catFieldMap.get(category)){
                System.debug('field___' + field);
                Sentinel_Order_Field_Mapping__c odrSetting = new Sentinel_Order_Field_Mapping__c(name = category + i++, Category__c = category, IsCustomAttribute__c = isCustom, Sentinel_Api_Field__c = field);
                System.debug('odrSetting_______' + odrSetting);
                settingList.add(odrSetting);
            }
        }
        return settingList;
    }

    @future(callout = true)
    public static void syncEntitlements(Set<String> orderIdList, String operation){
        system.debug('operation : ' + operation);
        System.debug('orderIdList: ' + orderIdList);
        try{
            //fetch custom settting mappings
            Map<String, List<Sentinel_Order_Field_Mapping__c>> catVsOrderFieldMap = new Map<String, List<Sentinel_Order_Field_Mapping__c>>();
            System.debug('catVsOrderFieldMap_______1' + catVsOrderFieldMap.get('EntitlementStatus'));
            String orderItemSubquery = ' Select Product2Id ,Product2.Thales__c ,';
            String orderQueryString = ' Select ';
            for (Sentinel_Order_Field_Mapping__c orderMapping : Sentinel_Order_Field_Mapping__c.getall().values()){
                if (!String.isBlank(orderMapping.SF_Api_Field__c)){
                    system.debug('mapping field (Category__c, SF_Api_Field__c, Sentinel_Api_Field__c, IsCustomAttribute__c, sObjectName__c, Name, Field_Description__c) : (' + orderMapping.Category__c + ',' + orderMapping.SF_Api_Field__c + ',' + orderMapping.Sentinel_Api_Field__c + ',' + orderMapping.IsCustomAttribute__c + ',' + orderMapping.sObjectName__c + ',' + orderMapping.Name + ',' + orderMapping.Field_Description__c + ')');
                } else{
                    system.debug('mapping field : ' + ' is empty');
                }
            }


            for (Sentinel_Order_Field_Mapping__c orderMapping : Sentinel_Order_Field_Mapping__c.getall().values()){
				System.debug('orderMapping______' + orderMapping);
                if (orderMapping.sObjectName__c.equalsIgnoreCase('Order')){


                    system.debug(' orderMapping of ' + orderMapping.Category__c + ' : ' + orderMapping);
                    if (catVsOrderFieldMap.containsKey(orderMapping.Category__c)){
                        List<Sentinel_Order_Field_Mapping__c> tempList = catVsOrderFieldMap.get(orderMapping.Category__c);
                        System.debug('tempList___' + tempList);
                        tempList.add(orderMapping);
                    } else{
                        catVsOrderFieldMap.put(orderMapping.Category__c, new List<Sentinel_Order_Field_Mapping__c>{ orderMapping });
                    }

                    if (!String.isBlank(orderMapping.SF_Api_Field__c) && !orderQueryString.contains(',' + orderMapping.SF_Api_Field__c + ' ,') && !orderQueryString.contains('Select ' + orderMapping.SF_Api_Field__c + ' ,') && !orderMapping.Category__c.equalsIgnoreCase('Product')){
                        system.debug('Adding =' + orderMapping.SF_Api_Field__c);
                        system.debug('orderQueryString=' + orderQueryString);
                        orderQueryString += orderMapping.SF_Api_Field__c + ' ,';
                    }

                    if (!String.isBlank(orderMapping.SF_Api_Field__c) && !orderItemSubquery.contains(',' + orderMapping.SF_Api_Field__c + ' ,') && !orderItemSubquery.contains('Select ' + orderMapping.SF_Api_Field__c + ' ,') && orderMapping.Category__c.equalsIgnoreCase('Product')){
                        orderItemSubquery += orderMapping.SF_Api_Field__c + ' ,';
                    }

                    if (!orderQueryString.contains('EID__c')){
                        orderQueryString += 'EID__c ,';
                    }
                    if (!orderQueryString.contains('Account.Type')){
                        orderQueryString += 'Account.Type ,';
                    }
                    //Added status to query by Bhavika
                    if (!orderQueryString.contains('Status')){
                        orderQueryString += 'Status ,';
                    }
                }
            }

            if (!catVsOrderFieldMap.isEmpty()){
                orderQueryString = orderQueryString.removeEnd(',');
                system.debug('orderItemSubquery--------->>>>' + orderItemSubquery);
                //orderItemSubquery = orderItemSubquery.removeEnd(',');
                if (!orderItemSubquery.contains(',Id ,') && !orderItemSubquery.contains('Select Id ,')){
                    orderQueryString += ' ,(' + orderItemSubquery + ' Id from OrderItems )';
                } else{
                    orderQueryString += ' ,(' + orderItemSubquery.removeEnd(',') + ' from OrderItems )';
                }

                orderQueryString += ' from Order where Id IN: orderIdList Limit 1';
                system.debug('ORDER QUERY--------->>>>' + orderQueryString);
                for (Order odr : Database.query(orderQueryString)){
                    system.debug('Order-->' + odr);
                    Boolean sendCustomer = false;
                    try{

                        try{
                            String accountType = (String) odr.getSobject('Account').get('Type');
                            // sendCustomer = accountType.equalsIgnoreCase('Prospect') || accountType.equalsIgnoreCase('Customer - Direct');
                            sendCustomer = true; // Customer Info need to send always irrespective of Account Type
                        } catch (Exception e){
                            System.debug('Error:' + e.getMessage());
                        }
                        SentinelEntitlementWrapper jsonObj = new SentinelEntitlementWrapper();
                        if (!String.isBlank(odr.EID__c)){
                            jsonObj.EID = odr.EID__c;
                        }
						 if(odr.Status != null) {
                            Map<String, String> statusMap = getMappedodrstatusvalue();
                            System.debug('-----ssss'+statusMap);
                            System.debug('-----ssss'+odr.Status);
                            jsonObj.status = statusMap.get(odr.Status);
                            System.debug('-----ssss'+statusMap.get(odr.Status));
                        }                        
						System.debug('catVsOrderFieldMap_______' + catVsOrderFieldMap.get('EntitlementStatus'));
                        
                        //Entitlement mapping
                        if (catVsOrderFieldMap.containsKey('Entitlement') && !catVsOrderFieldMap.get('Entitlement').isEmpty()){
                            List<SentinelEntitlementWrapper.CustomAttribute> entCusAttrList = new List<SentinelEntitlementWrapper.CustomAttribute>();
                            for (Sentinel_Order_Field_Mapping__c fieldMapObj : catVsOrderFieldMap.get('Entitlement')){
                                system.debug('FieldMapp-------->' + fieldMapObj);
                                if (fieldMapObj.IsCustomAttribute__c){
                                    system.debug('custom------->');
                                    if (!String.isBlank(fieldMapObj.Sentinel_Api_Field__c) && !String.isBlank(fieldMapObj.SF_Api_Field__c)){
                                        SentinelEntitlementWrapper.CustomAttribute entCusAttr = new SentinelEntitlementWrapper.CustomAttribute();
                                        if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('DATE')){
                                            entCusAttr.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Date');
                                        } else{
                                            entCusAttr.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        entCusAttr.attributeName = fieldMapObj.Sentinel_Api_Field__c;
                                        entCusAttrList.add(entCusAttr);
                                        System.debug('attributeName__' + entCusAttr.attributeName);
                                    }
                                } else{
                                    system.debug('system------->');
                                    system.debug('fieldMapObj.Sentinel_Api_Field__c------->' + fieldMapObj.Sentinel_Api_Field__c);

                                    switch on fieldMapObj.Sentinel_Api_Field__c{
                                        when 'externalId'{
                                            jsonObj.externalId = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            System.debug('jsonObj.externalId____________' + jsonObj.externalId);
                                        }
                                        when 'refId1'{
                                            jsonObj.refId1 = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'refId2'{
                                            jsonObj.refId2 = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'startDate'{
                                            jsonObj.startDate = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Date');
                                        }
                                        when 'endDate'{
                                            jsonObj.endDate = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Date');
                                        }
                                        //when 'status'{
                                           // jsonObj.status = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        //} //Status removed from Entitlement window and move to Entitlement status
                                        when 'entitlementAsWhole'{
                                            jsonObj.entitlementAsWhole = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'userRegistration'{
                                            jsonObj.userRegistration = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'activationAllowed'{
                                            jsonObj.activationAllowed = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                        }
                                        when 'revocationAllowed'{
                                            jsonObj.revocationAllowed = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                        }
                                        when 'sendNotification'{
                                            jsonObj.sendNotification = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                        }
                                        when 'ccEmail'{
                                            jsonObj.ccEmail = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                    }
                                }
                            }
                            if (!entCusAttrList.isEmpty()){
                                jsonObj.customAttribute = entCusAttrList;
                            }
                        }
						
                        // Customer Contact mapping
                        if (catVsOrderFieldMap.containsKey('CustomerContact') && !catVsOrderFieldMap.get('CustomerContact').isEmpty()){
                            system.debug('customer contact--->');
                            List<SentinelEntitlementWrapper.CustomAttribute> entCusAttrCCList = new List<SentinelEntitlementWrapper.CustomAttribute>();
                            SentinelEntitlementWrapper.CustomerContact ccObj = new SentinelEntitlementWrapper.CustomerContact();
                            SentinelEntitlementWrapper.BillingAddress ccBillAdd = new SentinelEntitlementWrapper.BillingAddress();
                            SentinelEntitlementWrapper.shippingAddress ccShipAdd = new SentinelEntitlementWrapper.shippingAddress();

                            for (Sentinel_Order_Field_Mapping__c fieldMapObj : catVsOrderFieldMap.get('CustomerContact')){
                                if (fieldMapObj.IsCustomAttribute__c){
                                    system.debug('custom------->');
                                    if (!String.isBlank(fieldMapObj.Sentinel_Api_Field__c) && !String.isBlank(fieldMapObj.SF_Api_Field__c)){
                                        SentinelEntitlementWrapper.CustomAttribute entCusAttrCC = new SentinelEntitlementWrapper.CustomAttribute();
                                        if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('DATE')){
                                            entCusAttrCC.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Date');
                                        } else if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('Boolean')){
                                            entCusAttrCC.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                        } else{
                                            entCusAttrCC.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        entCusAttrCC.attributeName = fieldMapObj.Sentinel_Api_Field__c;
                                        system.debug('customer contact---  entCusAttrCC--->' + entCusAttrCC);
                                        if (entCusAttrCC.attributeValue != null){
                                            // Add Custom Attribute If Value is existed
                                            entCusAttrCCList.add(entCusAttrCC);
                                        }
                                    }
                                } else{
                                    system.debug('customer contact--- system------->');
                                    system.debug('customer contact--- fieldMapObj.Sentinel_Api_Field__c------->' + fieldMapObj.Sentinel_Api_Field__c);

                                    switch on fieldMapObj.Sentinel_Api_Field__c{
                                        when 'contactName'{
                                            ccObj.contactName = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'contactEmail'{
                                            ccObj.contactEmail = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'customerName'{
                                            ccObj.customerName = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'externalId'{
                                            ccObj.externalId = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'refId1'{
                                            ccObj.refId1 = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'refId2'{
                                            ccObj.refId2 = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'loginAllowed'{
                                            ccObj.loginAllowed = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                        }
                                        when 'Password'{
                                            ccObj.Password = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'billingAddress.address'{
                                            ccBillAdd.address = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'billingAddress.city'{
                                            ccBillAdd.city = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'billingAddress.country'{
                                            ccBillAdd.country = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'billingAddress.state'{
                                            ccBillAdd.state = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'billingAddress.postalCode'{
                                            ccBillAdd.postalCode = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'billingAddress.useBillingAddressasShippingAddress'{
                                            ccBillAdd.useBillingAddressasShippingAddress = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                        }
                                        when 'shippingAddress.address'{
                                            ccShipAdd.address = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'shippingAddress.city'{
                                            ccShipAdd.city = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'shippingAddress.country'{
                                            ccShipAdd.country = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'shippingAddress.state'{
                                            ccShipAdd.state = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'shippingAddress.postalCode'{
                                            ccShipAdd.postalCode = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                    }
                                }
                            }
                            if (!entCusAttrCCList.isEmpty()){
                                ccObj.customAttribute = entCusAttrCCList;
                            }
                            ccObj.billingAddress = ccBillAdd;
                            ccObj.shippingAddress = ccShipAdd;
                            system.debug('-------CustomContact=====' + ccObj);

                            // Send Contact Object to SentinelConnect API if any one field value is not null otherwise will skip Contact Object.
                            // Modified on 16/Jul/2021
                            if (checkAnyFieldValueExisted(JSON.serialize(ccObj), 'customerContact')){
                                jsonObj.customerContact = ccObj;
                            } else{
                                jsonObj.customerContact = null;
                            }
                        }

                        // Customer mapping
                        if (catVsOrderFieldMap.containsKey('Customer') && !catVsOrderFieldMap.get('Customer').isEmpty() && sendCustomer || Test.IsRunningTest()){
                            List<SentinelEntitlementWrapper.CustomAttribute> entCusAttrCusList = new List<SentinelEntitlementWrapper.CustomAttribute>();
                            SentinelEntitlementWrapper.Customer customerObj = new SentinelEntitlementWrapper.Customer();
                            for (Sentinel_Order_Field_Mapping__c fieldMapObj : catVsOrderFieldMap.get('Customer')){
                                if (fieldMapObj.IsCustomAttribute__c){
                                    system.debug('custom------->');
                                    if (!String.isBlank(fieldMapObj.Sentinel_Api_Field__c) && !String.isBlank(fieldMapObj.SF_Api_Field__c)){
                                        SentinelEntitlementWrapper.CustomAttribute entCus = new SentinelEntitlementWrapper.CustomAttribute();
                                        if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('DATE')){
                                            entCus.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Date');
                                        } else if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('Boolean')){
                                            entCus.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                        } else{
                                            entCus.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        entCus.attributeName = fieldMapObj.Sentinel_Api_Field__c;
                                        entCusAttrCusList.add(entCus);
                                    }
                                } else{
                                    system.debug('system------->');
                                    system.debug('fieldMapObj.Sentinel_Api_Field__c------->' + fieldMapObj.Sentinel_Api_Field__c);

                                    switch on fieldMapObj.Sentinel_Api_Field__c{
                                        when 'externalId'{
                                            customerObj.externalId = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'customerName'{
                                            customerObj.customerName = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'customerIdentifier'{
                                            customerObj.customerIdentifier = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'CRMID'{
                                            customerObj.CRMID = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'refId'{
                                            customerObj.refId = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                    }
                                }
                            }
                            if (!entCusAttrCusList.isEmpty()){
                                customerObj.customAttribute = entCusAttrCusList;
                            }
                            jsonObj.customer = customerObj;
                        }

                        // Channel Partner mapping
                        if (catVsOrderFieldMap.containsKey('ChannelPartner') && !catVsOrderFieldMap.get('ChannelPartner').isEmpty()){
                            system.debug('Channel Partner-->');
                            List<SentinelEntitlementWrapper.CustomAttribute> entCusAttrCusList = new List<SentinelEntitlementWrapper.CustomAttribute>();
                            List<SentinelEntitlementWrapper.ChannelPartner> channelPartObjList = new List<SentinelEntitlementWrapper.ChannelPartner>();
                            SentinelEntitlementWrapper.ChannelPartner channelPartObj = new SentinelEntitlementWrapper.ChannelPartner();
                            SentinelEntitlementWrapper.BillingAddress ccPartBillAdd = new SentinelEntitlementWrapper.BillingAddress();
                            SentinelEntitlementWrapper.shippingAddress ccPartShipAdd = new SentinelEntitlementWrapper.shippingAddress();
                            SentinelEntitlementWrapper.PartnerLogin ccPartLogin = new SentinelEntitlementWrapper.PartnerLogin();
                            Boolean isAnyFieldMapped = false;
                            for (Sentinel_Order_Field_Mapping__c fieldMapObj : catVsOrderFieldMap.get('ChannelPartner')){
                                if (!String.isBlank(fieldMapObj.Sentinel_Api_Field__c) && (!String.isBlank(fieldMapObj.SF_Api_Field__c) && (fieldMapObj.SF_Api_Field__c != null))){
                                    System.debug('channelPartner SF API Field : ' + fieldMapObj.SF_Api_Field__c);
                                    if (isAnyFieldMapped == false){
                                        if (getFieldValue(odr, fieldMapObj.SF_Api_Field__c) != null){
                                            System.debug('channelPartner SF API Field : ' + fieldMapObj.SF_Api_Field__c + ' value is not empty');
                                            isAnyFieldMapped = true;
                                        } else{
                                            System.debug('channelPartner SF API Field : ' + fieldMapObj.SF_Api_Field__c + ' value is empty');
                                        }
                                    }

                                    if (fieldMapObj.IsCustomAttribute__c){
                                        system.debug('custom------->');
                                        SentinelEntitlementWrapper.CustomAttribute entCus = new SentinelEntitlementWrapper.CustomAttribute();
                                        if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('DATE')){
                                            entCus.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Date');
                                        } else if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('Boolean')){
                                            entCus.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                        } else{
                                            entCus.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        entCus.attributeName = fieldMapObj.Sentinel_Api_Field__c;
                                        entCusAttrCusList.add(entCus);
                                    } else{
                                        switch on fieldMapObj.Sentinel_Api_Field__c{
                                            when 'partnerName'{
                                                channelPartObj.partnerName = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'partnerIdentifier'{
                                                channelPartObj.partnerIdentifier = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'externalId'{
                                                channelPartObj.externalId = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'refId1'{
                                                channelPartObj.refId1 = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'refId2'{
                                                channelPartObj.refId2 = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'status'{
                                                channelPartObj.status = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'billingAddress.address'{
                                                ccPartBillAdd.address = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'billingAddress.city'{
                                                ccPartBillAdd.city = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'billingAddress.country'{
                                                ccPartBillAdd.country = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'billingAddress.state'{
                                                ccPartBillAdd.state = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'billingAddress.postalCode'{
                                                ccPartBillAdd.postalCode = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'billingAddress.useBillingAddressasShippingAddress'{
                                                ccPartBillAdd.useBillingAddressasShippingAddress = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                            }
                                            when 'shippingAddress.address'{
                                                ccPartShipAdd.address = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'shippingAddress.city'{
                                                ccPartShipAdd.city = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'shippingAddress.country'{
                                                ccPartShipAdd.country = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'shippingAddress.state'{
                                                ccPartShipAdd.state = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'shippingAddress.postalCode'{
                                                ccPartShipAdd.postalCode = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'partnerLogin.userIdentifier'{
                                                ccPartLogin.userIdentifier = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'partnerLogin.email'{
                                                ccPartLogin.email = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'partnerLogin.userName'{
                                                ccPartLogin.userName = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'partnerLogin.externalId'{
                                                ccPartLogin.externalId = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'partnerLogin.password'{
                                                ccPartLogin.password = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                        }
                                    }
                                }
                            }
                            if (!entCusAttrCusList.isEmpty()){
                                channelPartObj.customAttribute = entCusAttrCusList;
                            }
                            channelPartObj.billingAddress = ccPartBillAdd;
                            channelPartObj.shippingAddress = ccPartShipAdd;
                            channelPartObj.partnerLogin = ccPartLogin;
                            if (isAnyFieldMapped){
                                channelPartObjList.add(channelPartObj);
                            }

                            if (!channelPartObjList.isEmpty()){
                                jsonObj.channelPartner = channelPartObjList;
                            }
                        }                        
                        //Order Item products
                        if (catVsOrderFieldMap.containsKey('Product') && !catVsOrderFieldMap.get('Product').isEmpty() && odr.getSObjects('OrderItems') != null){
                            List<SentinelEntitlementWrapper.Product> proObjList = new List<SentinelEntitlementWrapper.Product>();
                            for (OrderItem odrItem : (List<OrderItem>)odr.getSObjects('OrderItems')){

                                // added Thale flag check , 3 Dec 2020
                                system.debug('odrItem=' + odrItem.Product2.Thales__c);
                                if (odrItem.Product2.Thales__c){
                                    system.debug('odrItem=' + odrItem);
                                    List<SentinelEntitlementWrapper.CustomAttribute> entCusAttrCusList = new List<SentinelEntitlementWrapper.CustomAttribute>();
                                    SentinelEntitlementWrapper.Product proObj = new SentinelEntitlementWrapper.Product();
                                    for (Sentinel_Order_Field_Mapping__c fieldMapObj : catVsOrderFieldMap.get('Product')){
                                        if (fieldMapObj.IsCustomAttribute__c){
                                            system.debug('custom------->');
                                            system.debug('custom-----fieldMapObj.Sentinel_Api_Field__c-->' + fieldMapObj.Sentinel_Api_Field__c);
                                            system.debug('custom-----fieldMapObj.SF_Api_Field__c-->' + fieldMapObj.SF_Api_Field__c);

                                            if (!String.isBlank(fieldMapObj.Sentinel_Api_Field__c) && !String.isBlank(fieldMapObj.SF_Api_Field__c)){
                                                system.debug('processing customAtt -->' + fieldMapObj.SF_Api_Field__c);
                                                SentinelEntitlementWrapper.CustomAttribute entCus = new SentinelEntitlementWrapper.CustomAttribute();
                                                if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('DATE')){
                                                    entCus.attributeValue = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Date');
                                                } else if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('Boolean')){
                                                    entCus.attributeValue = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                                } else{
                                                    entCus.attributeValue = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text');
                                                    if (fieldMapObj.SF_Api_Field__c.equalsIgnoreCase('quantity')){
                                                        if (!String.isBlank(entCus.attributeValue)){
                                                            try{
                                                                entCus.attributeValue = String.valueOf(Integer.valueOf(entCus.attributeValue));
                                                            } catch (Exception e){
                                                                system.debug('Error:' + e.getMessage());
                                                            }
                                                        }
                                                    }
                                                }
                                                entCus.attributeName = fieldMapObj.Sentinel_Api_Field__c;
                                                system.debug('adding customAtt -->' + fieldMapObj.SF_Api_Field__c);

                                                entCusAttrCusList.add(entCus);
                                            }
                                        } else{
                                            switch on fieldMapObj.Sentinel_Api_Field__c{
                                                when 'totalQuantity'{
                                                    proObj.totalQuantity = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text');
                                                    if (!String.isBlank(proObj.totalQuantity)){
                                                        try{
                                                            proObj.totalQuantity = String.valueOf(Integer.valueOf(proObj.totalQuantity));
                                                        } catch (Exception e){
                                                            system.debug('Error:' + e.getMessage());
                                                        }
                                                    }
                                                }
                                                when 'startDate'{
                                                    proObj.startDate = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Date');
                                                }
                                                when 'refId1'{
                                                    proObj.refId1 = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text');
                                                }
                                                when 'refId2'{
                                                    proObj.refId2 = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text');
                                                }
                                                when 'externalId'{
                                                    proObj.externalId = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text');
                                                    if (String.isBlank(proObj.externalId)){
                                                        proObj.externalId = odrItem.Product2Id;
                                                    }
                                                }
                                                when 'endDate'{
                                                    proObj.endDate = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Date');
                                                }
                                                when 'availableQuantity'{
                                                    proObj.availableQuantity = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text');
                                                    if (!String.isBlank(proObj.availableQuantity)){
                                                        try{
                                                            proObj.availableQuantity = String.valueOf(Integer.valueOf(proObj.availableQuantity));
                                                        } catch (Exception e){
                                                            system.debug('Error:' + e.getMessage());
                                                        }
                                                    }
                                                }
                                                when 'fixedQuantity'{
                                                    proObj.fixedQuantity = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text');
                                                    if (!String.isBlank(proObj.fixedQuantity)){
                                                        try{
                                                            proObj.fixedQuantity = String.valueOf(Integer.valueOf(proObj.fixedQuantity));
                                                        } catch (Exception e){
                                                            system.debug('Error:' + e.getMessage());
                                                        }
                                                    }
                                                }
                                                when 'itemState'{
                                                    proObj.itemState = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text');
                                                }
                                                when 'activationMethod'{
                                                    proObj.activationMethod = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text'); // later
                                                }
                                            }
                                        }
                                    }
                                    if (!entCusAttrCusList.isEmpty()){
                                        proObj.customAttribute = entCusAttrCusList;
                                    }
                                    system.debug('Product wrapper=' + proObj);
                                    proObjList.add(proObj);
                                    system.debug('Added to proObjList');
                                }
                            }
                            system.debug('finished product ');
                            jsonObj.product = proObjList;
                        }
                        system.debug('calling createEntitleMent');
                        if (String.isBlank(jsonObj.externalId)){
                            jsonObj.externalId = null;//odr.id;
                        }

                        if (operation == 'create' || operation == 'createWithEid'){

                            if (odr.EID__c != null && operation == 'createWithEid')
                                jsonObj.EID = odr.EID__c;
                            else if (odr.EID__c == null)
                                jsonObj.EID = null;
                            //SentinelUtil.newGuid(); // 1 Dec 2020 change

                            createEntitleMent(JSON.serialize(jsonObj), odr, 'create');

                        } else{
                            createEntitleMent(JSON.serialize(jsonObj), odr, operation);
                        }

                    } catch (Exception e){
                        try{
                            system.debug('Error: ' + e.getMessage());
                            odr.Sync_Error__c = 'Error updating order : ' + e.getMessage() + '  line number' + e.getLineNumber();
                            update odr;
                        } catch (Exception e2){
                            system.debug('Érror updating order : ' + e2.getMessage());
                            odr.Sync_Error__c = 'Error updating order : ' + e2.getMessage() + '  line number' + e2.getLineNumber();
                            update odr;
                        }
                    }
                }
            }
        } catch (Exception e){
            system.debug('Error: ' + e.getMessage());
            system.debug('Érror updating order : ' + e.getMessage());
            order odr = new order();
            odr.id = (new list<string>(orderIdList))[0];
            odr.Sync_Error__c = 'Error updating order : ' + e.getMessage() + '  line number' + e.getLineNumber();
            update odr;
        }
    }

    public static String fetchPopulateField(sobject odr, String apiField, String type){
        system.debug('fetchPopulateField------->');
        system.debug('odr-->' + odr);
        system.debug('apiField--->' + apiField);
        system.debug('type---->' + type);

        if (odr != null && !String.isBlank(apiField)){
            Object fieldValue = getFieldValue(odr, apiField);
            system.debug('fieldValue->' + fieldValue);
            if (fieldValue != null){
                if (type.equalsIgnoreCase('Date')){
                    try{
                        Date tempDate = (Date) fieldValue;
                        String dateF = tempDate.year() + '-';
                        if (tempDate.month() < 10){
                            dateF += '0' + tempDate.month() + '-';
                        } else{
                            dateF += tempDate.month() + '-';
                        }
                        if (tempDate.day() < 10){
                            dateF += '0' + tempDate.day();
                        } else{
                            dateF += tempDate.day();
                        }
                        return dateF;
                    } catch (Exception e){
                        return null;
                    }
                } else if (type.equalsIgnoreCase('Boolean')){
                    try{
                        return String.valueOf(Boolean.valueOf(fieldValue));
                    } catch (Exception e){
                        return null;
                    }
                } else if (type.equalsIgnoreCase('Text')){
                    try{
                        return String.ValueOf(fieldValue);
                    } catch (Exception e){
                        return null;
                    }
                }
            }
        }
        return null;
    }

    public static Map<String, String> getMappedodrstatusvalue(){
        Map<String, String> ordFieldValue = new Map<String, String>();
        List<Sentinel_Order_Field_Mapping__c> orderMappingFieldList = Sentinel_Order_Field_Mapping__c.getall().values();
        for (Sentinel_Order_Field_Mapping__c mapstatus : orderMappingFieldList){
            if (mapstatus.sObjectName__c.equalsIgnoreCase('Order') && !String.isBlank(mapstatus.SF_orderfield_value__c) && !mapstatus.SF_orderfield_value__c.contains('.') && !mapstatus.Category__c.equalsIgnoreCase('Product')){
                ordFieldValue.put(mapstatus.SF_orderfield_value__c, mapstatus.Sentinel_Status_value__c);
                System.debug('ordFieldValue_____' + ordFieldValue);
            }
        }
        return ordFieldValue;
    }

    public static Object getFieldValue(sobject odr, String apiField){
        //try {
        System.debug('---------------getFieldValue------------------');
        System.debug('odr->' + odr);
        System.debug('apiField->' + apiField);
        List<String> splitFieldNames = apiField.split('\\.');
        System.debug('splitFieldNames->' + splitFieldNames);
        if (splitFieldNames.size() == 1){
            System.debug('odr.get(splitFieldNames[0])=' + odr.get(splitFieldNames[0]));
            return odr.get(splitFieldNames[0]);
        } else if (splitFieldNames.size() == 2 && odr.getSobject(splitFieldNames[0]) != null){
            system.debug('odr.getSobject(splitFieldNames[0]).get(splitFieldNames[1])=' + odr.getSobject(splitFieldNames[0]).get(splitFieldNames[1]));
            return odr.getSobject(splitFieldNames[0]).get(splitFieldNames[1]);
        } else if (splitFieldNames.size() == 3){
            if (odr.getSobject(splitFieldNames[0]) != null && odr.getSobject(splitFieldNames[0]).getSobject(splitFieldNames[1]) != null){
                System.debug('odr.getSobject(splitFieldNames[0]).getSobject(splitFieldNames[1]).get(splitFieldNames[2])==' + odr.getSobject(splitFieldNames[0]).getSobject(splitFieldNames[1]).get(splitFieldNames[2]));
                return odr.getSobject(splitFieldNames[0]).getSobject(splitFieldNames[1]).get(splitFieldNames[2]);
            } else{
                if (odr.getSobject(splitFieldNames[0]) != null){
                    System.debug('odr.getSobject(splitFieldNames[0]))' + odr.getSobject(splitFieldNames[0]));
                }
                return null;
            }
        }
        // } catch (Exception e) {
        // System.debug('Error :' + e.getMessage());
        // }
        return null;
    }

    public static string getAuthenticationToken(Sentinel_User_Info__c rd){
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            if (rd.Selected_Org__c.equalsIgnoreCase('dev')){
                request.setEndpoint(rd.Org_URL__c);
                request.setBody('{"Username": "' + rd.Username__c + '", "Password": "' + rd.Password__c + '"}');
            } else if (rd.Selected_Org__c.equalsIgnoreCase('stage')){
                request.setEndpoint(rd.StageOrg_URL__c);
                request.setBody('{"Username": "' + rd.StageUsername__c + '", "Password": "' + rd.StagePassword__c + '"}');
            } else if (rd.Selected_Org__c.equalsIgnoreCase('prod')){
                request.setEndpoint(rd.ProdOrg_URL__c);
                request.setBody('{"Username": "' + rd.ProdUsername__c + '", "Password": "' + rd.ProdPassword__c + '"}');
            }

            request.setMethod('POST');
            system.debug('Token request-->' + request);
            system.debug('Token request body-->' + request.getBody());
            HttpResponse response = http.send(request);
            String authToken;
            if (response.getStatusCode() == 200){
                Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                authToken = (String) results.get('token');
            }
            return authToken;
        } catch (Exception e){
            system.debug('Authentication Error : ' + e.getMessage());
        }
        return null;
    }

    public static void createEntitleMent(String requestBody, Order odr, String operation){

        // List<Sentinel_User_Info__c> rd = [SELECT Request_Timeout__c, Username__c, Password__c, Org_URL__c, DML_Url__c, Order_Sync__c, ProdDML_Url__c, ProdOrg_URL__c, ProdUsername__c, ProdPassword__c, StageOrg_URL__c, StageDML_Url__c, StageUsername__c, StagePassword__c, Selected_Org__c
        //                                   FROM Sentinel_User_Info__c
        //                                   WHERE Name = 'Primary User'];
        if (rd != null && !rd.isEmpty()){
            String accesstoken = getAuthenticationToken(rd[0]);
            system.debug('accesstoken=' + accesstoken);
            system.debug('requestbody------>' + requestBody);
            if (!String.isBlank(accesstoken)){
                try{
                    Http http2 = new Http();
                    HttpRequest request2 = new HttpRequest();
                    if (rd[0].Selected_Org__c.equalsIgnoreCase('dev')){
                        request2.setEndpoint(rd[0].DML_URL__c);
                    } else if (rd[0].Selected_Org__c.equalsIgnoreCase('stage')){
                        request2.setEndpoint(rd[0].StageDML_URL__c);
                    } else if (rd[0].Selected_Org__c.equalsIgnoreCase('prod')){
                        request2.setEndpoint(rd[0].ProdDML_URL__c);
                    }

                    if (operation.equalsIgnoreCase('create')){
                        request2.setMethod('POST');
                    } else{
                        request2.setMethod('PUT');
                    }

                    request2.setHeader('Authorization', accesstoken);
                    request2.setHeader('Content-Type', 'application/json');
                    request2.setHeader('Connection', 'keep-alive');
                    request2.setHeader('Accept-Encoding', 'gzip, deflate, br');
                    request2.setHeader('guid', newGuid());
                    request2.setHeader('RequestClient', Client);
                    if (rd[0].Request_Timeout__c != null){
                        system.debug('Requesttimeout-->' + Integer.valueOf(rd[0].Request_Timeout__c));
                        request2.setTimeout(Integer.valueOf(rd[0].Request_Timeout__c));
                    } else{
                        request2.setTimeout(6000);
                    }

                    request2.setBody(requestBody);
                    system.debug('DML request-->' + request2);
                    system.debug('DML request body-->' + request2.getBody());
                    HttpResponse response = http2.send(request2);
                    system.debug('status=' + response.getStatus());
                    system.debug('getStatusCode=' + response.getStatusCode());
                    system.debug('response body=' + response.getBody());
                    if (response.getStatusCode() == 201 || response.getStatusCode() == 200){
                        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                        List<Object> resultEntitlementIdList = (List<Object>)results.get('entitlements');
                        Map<String, Object> resultObj = (Map<String, Object>)resultEntitlementIdList[0];

                        Map<String, Object> resultObj1 = (Map<String, Object>)resultobj.get('entitlement');
                        //Map<String, Object> resultObj2 = (Map<String, Object>) resultobj1.get('eId');
                        //String tempEID = (String) resultObj.get('eId');
                        String tempEID = (String) resultObj1.get('eId');
                        if (!String.isBlank(tempEID)){
                            if (String.isBlank(odr.Eid__c) || (!String.isBlank(odr.Eid__c) && !odr.Eid__c.equalsIgnoreCase(tempEID))){
                                odr.Eid__c = tempEID;
                            }
                        }
                        odr.Last_Sync__c = system.now();
                        odr.Sync_Error__c = '';
                        // Added recotype to secondstage when we get the EID.
                        odr.RecordTypeId = [Select Id
                                            from recordtype
                                            where sObjectType = 'Order' and DeveloperName = 'SecondStage'].Id;
                        List<Order_JSON__c> orderJsonList = new List<Order_JSON__c>();
                        orderJsonList = [Select id, Order__c, (Select Id, ParentId, Name, ContentType
                                                               From Attachments)
                                         from Order_JSON__c
                                         where Order__c = :odr.id];
                        if (orderJsonList != null && orderJsonList.size() > 0){
                            Attachment attachment = new Attachment(id = orderJsonList[0].Attachments[0].id);
                            attachment.Body = Blob.valueOf(response.getBody());
                            attachment.Name = String.valueOf('JSON_' + system.today() + '.json');
                            update attachment;

                        } else{
                            Order_JSON__c orderJson = new Order_JSON__c();
                            //orderJson.Name=odr.name;
                            orderJson.Order__c = odr.id;
                            insert orderJson;
                            Attachment attachment = New Attachment();
                            attachment.Body = Blob.valueOf(response.getBody());
                            attachment.Name = String.valueOf('JSON_' + system.today() + '.json');
                            attachment.ParentId = orderJson.id;
                            insert attachment;
                        }


                    } else{
                        String errorbody = JSON.serialize(response.getBody());
                        if (errorbody.length() > 131070){
                            odr.Sync_Error__c = errorbody.substring(0, 131070);
                        } else{
                            odr.Sync_Error__c = errorbody.substring(0, errorbody.length());
                        }
                    }

                } catch (Exception e){

                    odr.Sync_Error__c = 'Error in sync: ' + e.getMessage() + '  line number' + e.getLineNumber();
                }
            } else{
                odr.Sync_Error__c = 'Access token not found. Please verify the Authentication URL.';
            }
        } else{
            odr.Sync_Error__c = 'No configuration found. Please configure sentinel connect using User Settings page and retry.';
        }
        try{

            update odr;
        } catch (Exception e){
            system.debug('Érror updating order=' + e.getMessage() + '  line number-----  ' + e.getLineNumber());
        }
    }

    public static Boolean checkAnyFieldValueExisted(String serializedObject, String entitiyType){
        try{
            if (serializedObject != null){
                JSONParser parser = JSON.createParser(serializedObject);
                String propertyName = '';
                String propertyValue = '';
                while (parser.nextToken() != null){
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME){

                        propertyName = parser.getText();
                        system.debug('Token Name :' + propertyName);
                        // Get the value.
                        parser.nextToken();
                        propertyValue = parser.getText();
                        if (String.isNotEmpty(propertyValue) && propertyValue != 'null' && propertyValue != '{' && propertyValue != '}' && propertyValue != '[' && propertyValue != ']'){
                            system.debug('Value existed for the ' + entitiyType + ' object. Property Name : ' + propertyName + ' and Value is : ' + propertyValue);
                            return true;
                        }
                    }
                }
            }
        } catch (Exception e){
            system.debug('Check any field value in ' + entitiyType + 'object Error : ' + e.getMessage());
        }
        system.debug('No Value existed for the ' + entitiyType + ' object');
        return false;
    }

    // for Quote logic
    public static void createQuoteEntitleMent(String requestBody, SObject odr, String operation){
        if (rd != null && !rd.isEmpty()){
            String accesstoken = getAuthenticationToken(rd[0]);
            system.debug('accesstoken=' + accesstoken);
            system.debug('requestbody------>' + requestBody);
            if (!String.isBlank(accesstoken)){
                try{
                    Http http2 = new Http();
                    HttpRequest request2 = new HttpRequest();
                    if (rd[0].Selected_Org__c.equalsIgnoreCase('dev')){
                        request2.setEndpoint(rd[0].DML_URL__c);
                    } else if (rd[0].Selected_Org__c.equalsIgnoreCase('stage')){
                        request2.setEndpoint(rd[0].StageDML_URL__c);
                    } else if (rd[0].Selected_Org__c.equalsIgnoreCase('prod')){
                        request2.setEndpoint(rd[0].ProdDML_URL__c);
                    }

                    if (operation.equalsIgnoreCase('create')){
                        request2.setMethod('POST');
                    } else{
                        request2.setMethod('PUT');
                    }

                    request2.setHeader('Authorization', accesstoken);
                    request2.setHeader('Content-Type', 'application/json');
                    request2.setHeader('Connection', 'keep-alive');
                    request2.setHeader('Accept-Encoding', 'gzip, deflate, br');
                    request2.setHeader('RequestClient', Client);

                    system.debug('++eid entered ' + odr.get('Eid__c'));

                    request2.setHeader('guid', newGuid());

                    if (rd[0].Request_Timeout__c != null){
                        system.debug('Requesttimeout-->' + Integer.valueOf(rd[0].Request_Timeout__c));
                        request2.setTimeout(Integer.valueOf(rd[0].Request_Timeout__c));
                    } else{
                        request2.setTimeout(30000);
                    }

                    request2.setBody(requestBody);
                    system.debug('DML request-->' + request2);
                    system.debug('DML request body-->' + request2.getBody());
                    HttpResponse response = http2.send(request2);
                    system.debug('status=' + response.getStatus());
                    system.debug('getStatusCode=' + response.getStatusCode());
                    system.debug('response body=' + response.getBody());
                    if (response.getStatusCode() == 201 || response.getStatusCode() == 200){
                        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                        List<Object> resultEntitlementIdList = (List<Object>)results.get('entitlements');
                        Map<String, Object> resultObj = (Map<String, Object>)resultEntitlementIdList[0];

                        Map<String, Object> resultObj1 = (Map<String, Object>)resultobj.get('entitlement');
                        //Map<String, Object> resultObj2 = (Map<String, Object>) resultobj1.get('eId');
                        //String tempEID = (String) resultObj.get('eId');
                        String tempEID = (String) resultObj1.get('eId');

                        system.debug('++eid entered ' + odr.get('Eid__c')); //change 07/01/2021

                        if (!String.isBlank(tempEID) && odr.get('Eid__c') == null){

                            system.debug('++eid entered ' + odr.get('Eid__c'));
                            String Eidquo = (String)odr.get('Eid__c');
                            if (String.isBlank(Eidquo) || (!String.isBlank(Eidquo) && !Eidquo.equalsIgnoreCase(tempEID))){
                                odr.put('Eid__c' , tempEID);
                            }
                        }
                        system.debug('++eid entered ' + odr);

                        odr.put('Last_Sync__c' , system.now());
                        odr.put('Sync_Error__c','');
                        // Added recotype to secondstage when we get the EID.
                        //odr.RecordTypeId = [Select Id from recordtype where sObjectType='Quote' and DeveloperName='SecondStage'].Id;

                        // commenting due to package unmanaged deployment/creation, 4 Nov 2020, remove namespace
                        /*List<SENTNL__Order_JSON__c> orderJsonList=new List<SENTNL__Order_JSON__c>();
                         orderJsonList=[Select id,SENTNL__Order__c, (Select Id,ParentId, Name,ContentType From Attachments) from SENTNL__Order_JSON__c where SENTNL__Order__c=:odr.id];*/
						
                        Schema.SObjectType quotjson = Schema.getGlobalDescribe().get('Quote_JSON__c');
            						sObject quoteJson = quotjson.newSObject();
                        List<SObject> orderJsonList = new List<SObject>();
                        Id quotid =  (Id)odr.get('id');
                        string orderJsonList1 ='Select id, Quote__c,';
                        string orderJsonList2 = '(Select Id, ParentId, Name, ContentType From Attachments)';
                        string orderJsonList3 = 'from Quote_JSON__c where ';
                        String orderJsonListfinal= (orderJsonList1 + ' ' + orderJsonList2 + ' ' + orderJsonList3 + ' ' + 'Quote__c = :quotid'); 
                        orderJsonList = Database.query(orderJsonListfinal);
                         System.debug('orderJsonList____________' + orderJsonList);
                        
                        if (orderJsonList != null && orderJsonList.size() > 0){
                        	System.debug('orderJsonList[0]____' + orderJsonList[0]);
                            List<Attachment> attachmentlist = (List<Attachment>)orderJsonList[0].getSObjects('Attachments');
                            System.debug('attachmentlist_' + attachmentlist);
                            Attachment attachment = new Attachment(id = attachmentlist[0].id);
                            System.debug('attachment______' + attachment);
                            
                            attachment.Body = Blob.valueOf(response.getBody());
                            System.debug('attachment.Body____' + attachment.Body);
                            attachment.Name = String.valueOf('JSON_' + system.today() + '.json');
                            System.debug('attachment.Name_______' + attachment.Name);
                            update attachment;

                        } else{
                            //SENTNL__Order_JSON__c orderJson=new SENTNL__Order_JSON__c();//unmanaged pkg  4 Nov 2020, remove namespace
                            sObject orderJson = quotjson.newSObject();
                            //Quote_JSON__c orderJson = new Quote_JSON__c();
                            //orderJson.Name=odr.name;
                            //orderJson.SENTNL__Order__c=odr.id;//unmanaged pkg  4 Nov 2020, remove namespace
                            orderJson.put('Quote__c' , odr.id);
                            insert orderJson;
                            Attachment attachment = New Attachment();
                            attachment.Body = Blob.valueOf(response.getBody());
                            attachment.Name = String.valueOf('JSON_' + system.today() + '.json');
                            attachment.ParentId = orderJson.id;
                            insert attachment;
                        }


                    } else{
                        String errorbody = JSON.serialize(response.getBody());
                        if (errorbody.length() > 131070){
                            odr.put('Sync_Error__c' , errorbody.substring(0, 131070));
                        } else{
                            odr.put('Sync_Error__c' , errorbody.substring(0, errorbody.length()));
                        }
                    }

                } catch (Exception e){

                    odr.put('Sync_Error__c', 'Error in sync: ' + e.getMessage() + '  line number' + e.getLineNumber());
                }
            } else{
                odr.put('Sync_Error__c' , 'Access token not found. Please verify the Authentication URL.');
            }
        } else{
            odr.put('Sync_Error__c' , 'No configuration found. Please configure sentinel connect using User Settings page and retry.');
        }
        try{

            update odr;
        } catch (Exception e){
            system.debug('Érror updating Quote=' + e.getMessage() + '  line number-----  ' + e.getLineNumber());
        }
    }

    // for Quote callout
    // for Quote callout
    @future(callout = true)
    public static void syncQuoteEntitlements(Set<String> orderIdList, String operation){
        System.debug('orderIdList: ' + orderIdList);
        system.debug('++eidchecked' + SentinelConstants.isEidEntered);

        if (rd != null && !rd.isEmpty()){
            if (rd[0].Quote_Sync__c){

                //try {
                //fetch custom settting mappings
                Map<String, List<Sentinel_Order_Field_Mapping__c>> catVsOrderFieldMap = new Map<String, List<Sentinel_Order_Field_Mapping__c>>();
                String orderItemSubquery = ' Select ';
                String orderQueryString = ' Select ';
                for (Sentinel_Order_Field_Mapping__c orderMapping : Sentinel_Order_Field_Mapping__c.getall().values()){

                    if (orderMapping.sObjectName__c.equalsIgnoreCase('Quote')){

                        if (catVsOrderFieldMap.containsKey(orderMapping.Category__c)){
                            List<Sentinel_Order_Field_Mapping__c> tempList = catVsOrderFieldMap.get(orderMapping.Category__c);
                            tempList.add(orderMapping);
                        } else{

                            catVsOrderFieldMap.put(orderMapping.Category__c, new List<Sentinel_Order_Field_Mapping__c>{ orderMapping });
                        }

                        if (!String.isBlank(orderMapping.SF_Api_Field__c) && !orderQueryString.contains(',' + orderMapping.SF_Api_Field__c + ' ,') && !orderQueryString.contains('Select ' + orderMapping.SF_Api_Field__c + ' ,') && !orderMapping.Category__c.equalsIgnoreCase('ProductQuote')){

                            system.debug('Adding =' + orderMapping.SF_Api_Field__c);
                            system.debug('orderQueryString=' + orderQueryString);
                            orderQueryString += orderMapping.SF_Api_Field__c + ' ,';
                        }

                        if (!String.isBlank(orderMapping.SF_Api_Field__c) && !orderItemSubquery.contains(',' + orderMapping.SF_Api_Field__c + ' ,') && !orderItemSubquery.contains('Select ' + orderMapping.SF_Api_Field__c + ' ,') && orderMapping.Category__c.equalsIgnoreCase('ProductQuote')){
                            orderItemSubquery += orderMapping.SF_Api_Field__c + ' ,';
                        }
                        // // commenting due to package unmanaged deployment/creation, 4 Nov 2020, remove namespace
                        /* if(!orderQueryString.contains('SENTNL__EID__c')) {
                         orderQueryString += 'SENTNL__EID__c ,';
                         } */
                        if (!orderQueryString.contains('EID__c')){
                            orderQueryString += 'EID__c ,';
                        }
                        if (!orderQueryString.contains('Last_Sync__c')){
                            // added new 26 nov
                            orderQueryString += 'Last_Sync__c ,';
                        }
                        if (!orderQueryString.contains('Account.Type')){
                            orderQueryString += 'Account.Type ,';
                        }

                    }
                }

                if (!catVsOrderFieldMap.isEmpty()){
                    orderQueryString = orderQueryString.removeEnd(',');
                    system.debug('orderItemSubquery--------->>>>' + orderItemSubquery);
                    //orderItemSubquery = orderItemSubquery.removeEnd(',');
                    if (!orderItemSubquery.contains(',Id ,') && !orderItemSubquery.contains('Select Id ,')){
                        orderQueryString += ' ,(' + orderItemSubquery + ' Id,Product2.Thales__c from QuoteLineItems )';
                        //orderQueryString += ' ,(Select Product2Id, SBQQ__ProductName__c ,Quantity , SBQQ__ProductCode__c , Id from QuoteLineItems )';

                    } else{
                        orderQueryString += ' ,(' + orderItemSubquery.removeEnd(',') + ' ,Product2.Thales__c from QuoteLineItems )';
                        //orderQueryString += ' ,(Select Product2Id, SBQQ__ProductName__c ,Quantity , SBQQ__ProductCode__c , Id Id from QuoteLineItems )';
                    }

                    orderQueryString += ' from Quote where Id IN: orderIdList Limit 1';
                    system.debug('ORDER QUERY--------->>>>' + orderQueryString);

                    //// for correction
                    //orderQueryString ='Select EID__c ,Account.Type ,SBQQ__StartDate__c ,SBQQ__EndDate__c ,Name ,Id ,Status,userRegistration__c ,Exist__c ,Email ,SBQQ__PrimaryContact__r.Name ,Company_Name__c ,Account.BillingStreet ,Account.BillingCity ,Account.BillingCountry ,Account.BillingState ,Account.BillingPostalCode ,Account.ShippingStreet ,Account.ShippingCity ,Account.ShippingCountry ,Account.ShippingState ,Account.ShippingPostalCode ,Account.AccountNumber ,Account.Name ,AccountId  ,( Select  SBQQ__Quote__r.Company_Name__c ,SBQQ__Quote__r.Name ,SBQQ__Quote__r.SBQQ__StartDate__c ,Quantity ,SBQQ__EffectiveStartDate__c ,Product2Id ,Product2.ProductCode ,SBQQ__EndDate__c ,SBQQ__Quote__r.Status ,SBQQ__Quote__r.Quote_Number__c, Id from QuoteLineItems ) from Quote  where Id IN: orderIdList Limit 1';
                    for (SObject odr : Database.query(orderQueryString)){
                        system.debug('Order-->' + odr);
                        Boolean sendCustomer = false;
                        //try {


                        try{
                            String accountType = (String) odr.getSobject('Account').get('Type');
                            system.debug('Order-->1 ' + accountType);
                            // sendCustomer = accountType.equalsIgnoreCase('Prospect') || accountType.equalsIgnoreCase('Customer - Direct');
                            sendCustomer = true; // Customer Info need to send always irrespective of Account Type
                            System.debug('Order-->1 ' + sendCustomer);
                        } catch (Exception e){
                            System.debug('Error:' + e.getMessage());
                        }
                        SentinelEntitlementWrapper jsonObj = new SentinelEntitlementWrapper();
                        // commenting due to package unmanaged deployment/creation, 4 Nov 2020, remove namespace
                        /*if(!String.isBlank(odr.SENTNL__EID__c)) {
                         jsonObj.EID = odr.SENTNL__EID__c;
                         }*/
                        String quoteid = (String)odr.get('EID__c');
                        
                        if (!String.isBlank(quoteid)){
                            jsonObj.EID = quoteid;
                        }

                        //Entitlement mapping
                        if (catVsOrderFieldMap.containsKey('EntitlementQuote') && !catVsOrderFieldMap.get('EntitlementQuote').isEmpty()){
                            List<SentinelEntitlementWrapper.CustomAttribute> entCusAttrList = new List<SentinelEntitlementWrapper.CustomAttribute>();
                            for (Sentinel_Order_Field_Mapping__c fieldMapObj : catVsOrderFieldMap.get('EntitlementQuote')){
                                system.debug('FieldMapp-------->' + fieldMapObj);
                                if (fieldMapObj.IsCustomAttribute__c){
                                    system.debug('custom------->');
                                    if (!String.isBlank(fieldMapObj.Sentinel_Api_Field__c) && !String.isBlank(fieldMapObj.SF_Api_Field__c)){
                                        SentinelEntitlementWrapper.CustomAttribute entCusAttr = new SentinelEntitlementWrapper.CustomAttribute();
                                        if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('DATE')){
                                            entCusAttr.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Date');
                                        } else{
                                            entCusAttr.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        entCusAttr.attributeName = fieldMapObj.Sentinel_Api_Field__c;
                                        entCusAttrList.add(entCusAttr);
                                    }
                                } else{
                                    system.debug('system------->');
                                    system.debug('fieldMapObj.Sentinel_Api_Field__c------->' + fieldMapObj.Sentinel_Api_Field__c);

                                    switch on fieldMapObj.Sentinel_Api_Field__c{


                                        when 'externalId'{

                                            system.debug('++-------> ' + fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text'));

                                            jsonObj.externalId = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');  //odr.Id; //null;//fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'refId1'{
                                            jsonObj.refId1 = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');// later **
                                        }
                                        when 'refId2'{
                                            jsonObj.refId2 = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');// later **
                                        }
                                        when 'startDate'{
                                            jsonObj.startDate = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Date');// later **
                                        }
                                        when 'endDate'{
                                            jsonObj.endDate = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Date'); // later **
                                        }
                                        when 'status'{
                                            //jsonObj.status = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            // As per discussion with team on 07/Jun/2021, We need to set Entitlement Status as Draft always
                                            jsonObj.status = 'Draft';
                                        }
                                        when 'entitlementAsWhole'{
                                            jsonObj.entitlementAsWhole = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'userRegistration'{
                                            jsonObj.userRegistration = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'activationAllowed'{
                                            jsonObj.activationAllowed = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                        }
                                        when 'revocationAllowed'{
                                            jsonObj.revocationAllowed = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                        }
                                        when 'sendNotification'{
                                            jsonObj.sendNotification = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                        }
                                        when 'ccEmail'{
                                            jsonObj.ccEmail = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                    }
                                }
                            }
                            if (!entCusAttrList.isEmpty()){
                                jsonObj.customAttribute = entCusAttrList; // ***********************
                            }
                        }
                        system.debug('++json1' + jsonObj);

                        // Customer Contact mapping
                        if (catVsOrderFieldMap.containsKey('CustomerContactQuote') && !catVsOrderFieldMap.get('CustomerContactQuote').isEmpty()){
                            system.debug('customer contact--->');
                            List<SentinelEntitlementWrapper.CustomAttribute> entCusAttrCCList = new List<SentinelEntitlementWrapper.CustomAttribute>();
                            SentinelEntitlementWrapper.CustomerContact ccObj = new SentinelEntitlementWrapper.CustomerContact();
                            SentinelEntitlementWrapper.BillingAddress ccBillAdd = new SentinelEntitlementWrapper.BillingAddress();
                            SentinelEntitlementWrapper.shippingAddress ccShipAdd = new SentinelEntitlementWrapper.shippingAddress();

                            for (Sentinel_Order_Field_Mapping__c fieldMapObj : catVsOrderFieldMap.get('CustomerContactQuote')){
                                if (fieldMapObj.IsCustomAttribute__c){
                                    system.debug('custom------->');
                                    if (!String.isBlank(fieldMapObj.Sentinel_Api_Field__c) && !String.isBlank(fieldMapObj.SF_Api_Field__c)){
                                        SentinelEntitlementWrapper.CustomAttribute entCusAttrCC = new SentinelEntitlementWrapper.CustomAttribute();
                                        if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('DATE')){
                                            entCusAttrCC.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Date');
                                        } else if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('Boolean')){
                                            entCusAttrCC.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                        } else{
                                            entCusAttrCC.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        entCusAttrCC.attributeName = fieldMapObj.Sentinel_Api_Field__c;
                                        system.debug('customer contact---  entCusAttrCC--->' + entCusAttrCC);
                                        if (entCusAttrCC.attributeValue != null){
                                            // Add Custom Attribute If Value is existed
                                            entCusAttrCCList.add(entCusAttrCC);
                                        }
                                    }
                                } else{
                                    system.debug('customer contact--- system------->');
                                    system.debug('customer contact--- fieldMapObj.Sentinel_Api_Field__c------->' + fieldMapObj.Sentinel_Api_Field__c);

                                    switch on fieldMapObj.Sentinel_Api_Field__c{
                                        when 'contactName'{
                                            ccObj.contactName = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'contactEmail'{
                                            ccObj.contactEmail = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'customerName'{
                                            ccObj.customerName = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'externalId'{
                                            ccObj.externalId = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'refId1'{
                                            ccObj.refId1 = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'refId2'{
                                            ccObj.refId2 = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'loginAllowed'{
                                            ccObj.loginAllowed = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                        }
                                        when 'Password'{
                                            ccObj.Password = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'billingAddress.address'{
                                            ccBillAdd.address = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'billingAddress.city'{
                                            ccBillAdd.city = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'billingAddress.country'{
                                            ccBillAdd.country = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'billingAddress.state'{
                                            ccBillAdd.state = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'billingAddress.postalCode'{
                                            ccBillAdd.postalCode = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'billingAddress.useBillingAddressasShippingAddress'{
                                            ccBillAdd.useBillingAddressasShippingAddress = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                        }
                                        when 'shippingAddress.address'{
                                            ccShipAdd.address = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'shippingAddress.city'{
                                            ccShipAdd.city = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'shippingAddress.country'{
                                            ccShipAdd.country = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'shippingAddress.state'{
                                            ccShipAdd.state = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'shippingAddress.postalCode'{
                                            ccShipAdd.postalCode = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                    }
                                }
                            }
                            if (!entCusAttrCCList.isEmpty()){
                                ccObj.customAttribute = entCusAttrCCList;
                            }
                            ccObj.billingAddress = ccBillAdd;
                            ccObj.shippingAddress = ccShipAdd;
                            system.debug('-------CustomContact=====' + ccObj);
                            // Send Contact Object to SentinelConnect API if any one field value is not null otherwise will skip Contact Object.
                            // Modified by 16/Jul/2021
                            if (checkAnyFieldValueExisted(JSON.serialize(ccObj), 'CustomerContactQuote')){
                                jsonObj.customerContact = ccObj;
                            } else{
                                jsonObj.customerContact = null;
                            }
                        }
                        system.debug('++json2' + jsonObj);

                        // Customer mapping
                        if (catVsOrderFieldMap.containsKey('CustomerQuote') && !catVsOrderFieldMap.get('CustomerQuote').isEmpty() && sendCustomer// || Test.IsRunningTest()
                        ){
                            List<SentinelEntitlementWrapper.CustomAttribute> entCusAttrCusList = new List<SentinelEntitlementWrapper.CustomAttribute>();
                            //system.debug('-------CustomerQuote123=====' + catVsOrderFieldMap.containsKey('CustomerQuote'));
                            system.debug('-------CustomerQuote123Obj=====' + catVsOrderFieldMap.get('CustomerQuote'));
                            SentinelEntitlementWrapper.Customer customerObj = new SentinelEntitlementWrapper.Customer();
                            for (Sentinel_Order_Field_Mapping__c fieldMapObj : catVsOrderFieldMap.get('CustomerQuote')){
                                if (fieldMapObj.IsCustomAttribute__c){
                                    system.debug('custom------->');
                                    if (!String.isBlank(fieldMapObj.Sentinel_Api_Field__c) && !String.isBlank(fieldMapObj.SF_Api_Field__c)){
                                        SentinelEntitlementWrapper.CustomAttribute entCus = new SentinelEntitlementWrapper.CustomAttribute();
                                        if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('DATE')){
                                            entCus.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Date');
                                        } else if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('Boolean')){
                                            entCus.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                        } else{
                                            entCus.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        entCus.attributeName = fieldMapObj.Sentinel_Api_Field__c;
                                        entCusAttrCusList.add(entCus);
                                    }
                                } else{
                                    system.debug('system------->');
                                    system.debug('fieldMapObj.Sentinel_Api_Field__c------->' + fieldMapObj.Sentinel_Api_Field__c);

                                    switch on fieldMapObj.Sentinel_Api_Field__c{
                                        when 'externalId'{
                                            system.debug('++-------> ' + fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text'));
                                            customerObj.externalId = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');// ************* LAT
                                        }
                                        when 'customerName'{
                                            customerObj.customerName = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'customerIdentifier'{
                                            customerObj.customerIdentifier = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'CRMID'{
                                            customerObj.CRMID = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        when 'refId'{
                                            customerObj.refId = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                    }
                                }
                            }
                            if (!entCusAttrCusList.isEmpty()){
                                customerObj.customAttribute = entCusAttrCusList;
                            }
                            jsonObj.customer = customerObj;  // ************************
                        }
                        system.debug('++json3' + jsonObj);

                        // Channel Partner mapping
                        if (catVsOrderFieldMap.containsKey('ChannelPartnerQuote') && !catVsOrderFieldMap.get('ChannelPartnerQuote').isEmpty()){
                            system.debug('Channel Partner-->');
                            List<SentinelEntitlementWrapper.CustomAttribute> entCusAttrCusList = new List<SentinelEntitlementWrapper.CustomAttribute>();
                            List<SentinelEntitlementWrapper.ChannelPartner> channelPartObjList = new List<SentinelEntitlementWrapper.ChannelPartner>();
                            SentinelEntitlementWrapper.ChannelPartner channelPartObj = new SentinelEntitlementWrapper.ChannelPartner();
                            SentinelEntitlementWrapper.BillingAddress ccPartBillAdd = new SentinelEntitlementWrapper.BillingAddress();
                            SentinelEntitlementWrapper.shippingAddress ccPartShipAdd = new SentinelEntitlementWrapper.shippingAddress();
                            SentinelEntitlementWrapper.PartnerLogin ccPartLogin = new SentinelEntitlementWrapper.PartnerLogin();
                            Boolean isAnyFieldMapped = false;
                            for (Sentinel_Order_Field_Mapping__c fieldMapObj : catVsOrderFieldMap.get('ChannelPartnerQuote')){
                                if (!String.isBlank(fieldMapObj.Sentinel_Api_Field__c) && (!String.isBlank(fieldMapObj.SF_Api_Field__c) && (fieldMapObj.SF_Api_Field__c != null))){
                                    if (isAnyFieldMapped == false){
                                        if (getFieldValue(odr, fieldMapObj.SF_Api_Field__c) != null){
                                            System.debug('channelPartner SF API Field : ' + fieldMapObj.SF_Api_Field__c + ' value is not empty');
                                            isAnyFieldMapped = true;
                                        } else{
                                            System.debug('channelPartner SF API Field : ' + fieldMapObj.SF_Api_Field__c + ' value is empty');
                                        }
                                    }

                                    if (fieldMapObj.IsCustomAttribute__c){
                                        system.debug('custom------->');
                                        SentinelEntitlementWrapper.CustomAttribute entCus = new SentinelEntitlementWrapper.CustomAttribute();
                                        if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('DATE')){
                                            entCus.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Date');
                                        } else if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('Boolean')){
                                            entCus.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                        } else{
                                            entCus.attributeValue = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                        }
                                        entCus.attributeName = fieldMapObj.Sentinel_Api_Field__c;
                                        entCusAttrCusList.add(entCus);
                                    } else{
                                        switch on fieldMapObj.Sentinel_Api_Field__c{
                                            when 'partnerName'{
                                                channelPartObj.partnerName = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'partnerIdentifier'{
                                                channelPartObj.partnerIdentifier = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'externalId'{
                                                channelPartObj.externalId = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'refId1'{
                                                channelPartObj.refId1 = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'refId2'{
                                                channelPartObj.refId2 = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'status'{
                                                channelPartObj.status = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'billingAddress.address'{
                                                ccPartBillAdd.address = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'billingAddress.city'{
                                                ccPartBillAdd.city = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'billingAddress.country'{
                                                ccPartBillAdd.country = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'billingAddress.state'{
                                                ccPartBillAdd.state = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'billingAddress.postalCode'{
                                                ccPartBillAdd.postalCode = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'billingAddress.useBillingAddressasShippingAddress'{
                                                ccPartBillAdd.useBillingAddressasShippingAddress = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                            }
                                            when 'shippingAddress.address'{
                                                ccPartShipAdd.address = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'shippingAddress.city'{
                                                ccPartShipAdd.city = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'shippingAddress.country'{
                                                ccPartShipAdd.country = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'shippingAddress.state'{
                                                ccPartShipAdd.state = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'shippingAddress.postalCode'{
                                                ccPartShipAdd.postalCode = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'partnerLogin.userIdentifier'{
                                                ccPartLogin.userIdentifier = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'partnerLogin.email'{
                                                ccPartLogin.email = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'partnerLogin.userName'{
                                                ccPartLogin.userName = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'partnerLogin.externalId'{
                                                ccPartLogin.externalId = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                            when 'partnerLogin.password'{
                                                ccPartLogin.password = fetchPopulateField(odr, fieldMapObj.SF_Api_Field__c, 'Text');
                                            }
                                        }
                                    }
                                }
                            }

                            if (!entCusAttrCusList.isEmpty()){
                                channelPartObj.customAttribute = entCusAttrCusList;
                            }
                            // System.debug('billing '+ccPartBillAdd);
                            // System.debug('billing '+ccPartShipAdd);
                            // System.debug('billing '+ccPartLogin);
                            channelPartObj.billingAddress = ccPartBillAdd;
                            channelPartObj.shippingAddress = ccPartShipAdd;
                            channelPartObj.partnerLogin = ccPartLogin;
                            if (isAnyFieldMapped){
                                channelPartObjList.add(channelPartObj);
                            }
                            if (!channelPartObjList.isEmpty()){
                                jsonObj.channelPartner = channelPartObjList; // ************************
                            }
                        }
                        system.debug('++json4' + jsonObj);

                        //Quote Item products mapping
                        Schema.SObjectType quote1 = Schema.getGlobalDescribe().get('QuoteLineItem');
                        system.debug('++odr++=' + odr);
                        if (catVsOrderFieldMap.containsKey('ProductQuote') && !catVsOrderFieldMap.get('ProductQuote').isEmpty() && odr.getSObjects('QuoteLineItems') != null){
                            List<SentinelEntitlementWrapper.Product> proObjList = new List<SentinelEntitlementWrapper.Product>();
                            
                            Set<Id> prodIds = new Set<Id>();
            				Map<Id, Id> mapQLineVsProdIds = new Map<Id, Id>();
                            
                            for (SObject odrItem : (List<SObject>)odr.getSObjects('QuoteLineItems')){
                                system.debug('odrItem=' + odrItem);

                                Id prodId = (Id)odrItem.get('Product2Id');
                                prodIds.add(prodId);
                                mapQLineVsProdIds.put(odrItem.Id, prodId); 
                            }
                            
                            List<Product2> prods = [SELECT Id, Thales__c FROM Product2 WHERE ID IN:prodIds];

                            if(!prods.isEmpty()) {
                                Map<ID, Product2> mapIdProds = new Map<ID, Product2>();
                                mapIdProds.putAll(prods);
                                
                                for (SObject odrItem : (List<SObject>)odr.getSObjects('QuoteLineItems')){
                                
                                	// added Thale flag check , 3 Dec 2020
                                	//SObject prod2 = (SObject)odrItem.get('Product2');
                                	SObject prod2 = mapIdProds.get(mapQLineVsProdIds.get(odrItem.Id));
                					Boolean prodthales = (Boolean)prod2.get('Thales__c');
                                	system.debug('odrItem=' + prodthales);
                                	if (odrItem.get('Product2Id') != null && prodthales){

                                    List<SentinelEntitlementWrapper.CustomAttribute> entCusAttrCusList = new List<SentinelEntitlementWrapper.CustomAttribute>();
                                    SentinelEntitlementWrapper.Product proObj = new SentinelEntitlementWrapper.Product();
                                    for (Sentinel_Order_Field_Mapping__c fieldMapObj : catVsOrderFieldMap.get('ProductQuote')){


                                        if (fieldMapObj.IsCustomAttribute__c){
                                            system.debug('custom------->');
                                            system.debug('custom-----fieldMapObj.Sentinel_Api_Field__c-->' + fieldMapObj.Sentinel_Api_Field__c);
                                            system.debug('custom-----fieldMapObj.SF_Api_Field__c-->' + fieldMapObj.SF_Api_Field__c);

                                            if (!String.isBlank(fieldMapObj.Sentinel_Api_Field__c) && !String.isBlank(fieldMapObj.SF_Api_Field__c)){
                                                system.debug('processing customAtt -->' + fieldMapObj.SF_Api_Field__c);
                                                SentinelEntitlementWrapper.CustomAttribute entCus = new SentinelEntitlementWrapper.CustomAttribute();
                                                if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('DATE')){
                                                    entCus.attributeValue = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Date');
                                                } else if (!String.isBlank(fieldMapObj.Field_Type__c) && fieldMapObj.Field_Type__c.equalsIgnoreCase('Boolean')){
                                                    entCus.attributeValue = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Boolean');
                                                } else{
                                                    entCus.attributeValue = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text');
                                                    if (fieldMapObj.SF_Api_Field__c.equalsIgnoreCase('quantity')){
                                                        if (!String.isBlank(entCus.attributeValue)){
                                                            try{
                                                                entCus.attributeValue = String.valueOf(Integer.valueOf(entCus.attributeValue));
                                                            } catch (Exception e){
                                                                system.debug('Error:' + e.getMessage());
                                                            }
                                                        }
                                                    }
                                                }
                                                entCus.attributeName = fieldMapObj.Sentinel_Api_Field__c;
                                                system.debug('adding customAtt -->' + fieldMapObj.SF_Api_Field__c);

                                                entCusAttrCusList.add(entCus);
                                            }
                                        } else{
                                            switch on fieldMapObj.Sentinel_Api_Field__c{
                                                when 'totalQuantity'{
                                                    proObj.totalQuantity = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text');
                                                    if (!String.isBlank(proObj.totalQuantity)){
                                                        try{
                                                            proObj.totalQuantity = String.valueOf(Integer.valueOf(proObj.totalQuantity));
                                                        } catch (Exception e){
                                                            system.debug('Error:' + e.getMessage());
                                                        }
                                                    }
                                                }
                                                when 'startDate'{
                                                    proObj.startDate = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Date');
                                                }
                                                when 'refId1'{
                                                    proObj.refId1 = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text'); //later
                                                }
                                                when 'refId2'{
                                                    proObj.refId2 = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text');// later
                                                }
                                                when 'externalId'{
                                                    proObj.externalId = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text');
                                                    String prod2Id = (String)odrItem.get('Product2Id');
                                                    if (String.isBlank(proObj.externalId)){
                                                        proObj.externalId = prod2Id;
                                                    }
                                                }
                                                when 'endDate'{
                                                    proObj.endDate = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Date');
                                                }
                                                when 'availableQuantity'{
                                                    proObj.availableQuantity = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text');// later
                                                    if (!String.isBlank(proObj.availableQuantity)){
                                                        try{
                                                            proObj.availableQuantity = String.valueOf(Integer.valueOf(proObj.availableQuantity));
                                                        } catch (Exception e){
                                                            system.debug('Error:' + e.getMessage());
                                                        }
                                                    }
                                                }
                                                when 'fixedQuantity'{
                                                    proObj.fixedQuantity = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text');// later
                                                    if (!String.isBlank(proObj.fixedQuantity)){
                                                        try{
                                                            proObj.fixedQuantity = String.valueOf(Integer.valueOf(proObj.fixedQuantity));
                                                        } catch (Exception e){
                                                            system.debug('Error:' + e.getMessage());
                                                        }
                                                    }
                                                }
                                                when 'itemState'{
                                                    proObj.itemState = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text'); // later
                                                }
                                                when 'activationMethod'{
                                                    proObj.activationMethod = fetchPopulateField(odrItem, fieldMapObj.SF_Api_Field__c, 'Text'); // later
                                                }
                                            }
                                        }
                                    }
                                    if (!entCusAttrCusList.isEmpty()){
                                        proObj.customAttribute = entCusAttrCusList;
                                    }
                                    system.debug('Product wrapper=' + proObj);
                                    proObjList.add(proObj);
                                    system.debug('Added to proObjList');
                                }
                            	}
                            }
                            
                            
                            
                            system.debug('finished product ');
                            jsonObj.product = proObjList; // ************
                        }
                        system.debug('calling createEntitleMent');

                        system.debug('++json5' + jsonObj);
                        system.debug('++eid ' + jsonObj.EID);

                        if (String.isBlank(jsonObj.externalId)){
                            jsonObj.externalId = null; //odr.id; ///////////////// just now
                        }
                        // commenting due to package unmanaged deployment/creation, 4 Nov 2020, remove namespace
                        // added for 26 Nov
                        System.debug('Quote Operation : ' + operation);
                        if (/*String.isBlank(odr.SENTNL__EID__c)*/operation == 'create' || operation == 'createWithEid'){
                             String eidquo = (String)odr.get('EID__c');
                            if (odr.get('EID__c') != null && operation == 'createWithEid')
                                jsonObj.EID = eidquo;
                            else if (odr.get('EID__c') == null)
                                jsonObj.EID = null;
                            //SentinelUtil.newGuid(); // 1 Dec 2020, changed

                            createQuoteEntitleMent(JSON.serialize(jsonObj), odr, 'create');

                        } else{
                            createQuoteEntitleMent(JSON.serialize(jsonObj), odr, operation);
                        }

                        /*} catch(Exception e) {
                         try {
                         system.debug('Error: ' + e.getMessage());
                         odr.Sync_Error__c = 'Error updating order : ' + e.getMessage() +'  line number'+e.getLineNumber();
                         update odr;
                         } catch(Exception e2) {
                         system.debug('Érror updating order : ' + e2.getMessage());
                         odr.Sync_Error__c = 'Error updating order : ' + e2.getMessage() +'  line number'+e2.getLineNumber();
                         update odr;
                         }
                         }*/
                    }
                }

                /*} catch(Exception e) {
                 system.debug('Error: ' + e.getMessage());
                 system.debug('Érror updating order : ' + e.getMessage());
                 order odr=new order();
                 odr.id =(new list<string>(orderIdList) )[0];
                 odr.Sync_Error__c = 'Error updating order : ' + e.getMessage() +'  line number'+e.getLineNumber();
                 update odr;
                 }*/
            }
        }
    }
}