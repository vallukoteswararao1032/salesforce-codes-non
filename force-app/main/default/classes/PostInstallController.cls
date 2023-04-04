global class PostInstallController implements InstallHandler {

    public Blob csvFileBody {get;set;}
    public String csvAsString {get;set;}
    public String[] csvFileLines {get;set;}
    //public List < thalescpqdev__Sentinel_Order_Field_Mapping__c > Orderfieldlist { get;set;}  

global void onInstall(InstallContext context) {
    if (context.previousVersion() == null) {
        processStaticResource();
    } 
    else if (context.previousVersion().compareTo(new Version(1, 0)) == 0) {
        processStaticResource();
    }
        if (context.isUpgrade()) {
        processStaticResource();
    }
        if (context.isPush()) {
        processStaticResource(); 
    }
}
global void sendMessage() {}

global void sendEmail(String subject, String messageBody) {
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    message.toAddresses = new String[] {'suraj.koli@stacknexus.io','prem.pal@stacknexus.io','bhavika.ahire@stacknexus.io'};
    message.optOutPolicy = 'FILTER';
    message.subject = subject;
    message.setHtmlBody(messageBody);
    Messaging.SingleEmailMessage[] messages = new List < Messaging.SingleEmailMessage > {message};
    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
}

global void processStaticResource() {
    try{
        List < Sentinel_Order_Field_Mapping__c > Orderfieldlist = New List < Sentinel_Order_Field_Mapping__c > ();
        csvFileLines = new String[] {};
        Blob csvFileBody;
        String csvAsString;
        String[] csvFileLines;
        Map<String, Object> versionCompareMap = new Map<String, Object>();
        StaticResource resource = [SELECT Body, Id, Name FROM StaticResource Where Name = 'OrderFieldMapper'];
        csvFileBody = resource.Body;
        csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n');
        for (Integer i = 1; i < csvFileLines.size(); i++) {
            String csvLine = String.valueOf(csvFileLines[i]);
            String prevLine = csvLine;
            Integer startIndex;
            Integer endIndex;
            while (csvLine.indexOf('"') > -1) {
                if (startIndex == null) {
                    startIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex + 1, csvLine.length());
                }
                else {
                    if (endIndex == null) {
                        endIndex = csvLine.indexOf('"');
                        csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex + 1, csvLine.length());
                    }
                }
                if (startIndex != null && endIndex != null) {
                    String sub = csvLine.substring(startIndex, endIndex);
                    sub = sub.replaceAll(',', ':comma:');
                    csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                    startIndex = null;
                    endIndex = null;
                }
            }
            String[] csvRecordData = csvLine.split(',');
            Sentinel_Order_Field_Mapping__c orderFieldObj = new Sentinel_Order_Field_Mapping__c();
            orderFieldObj.Category__c = csvRecordData[0].replaceAll(':quotes:', '').replaceAll(':comma:', ',');
            orderFieldObj.Field_Description__c = csvRecordData[1].replaceAll(':quotes:', '').replaceAll(':comma:', ',');
            orderFieldObj.Field_Type__c = csvRecordData[2].replaceAll(':quotes:', '').replaceAll(':comma:', ',');
            orderFieldObj.IsCustomAttribute__c = Boolean.valueOf(csvRecordData[3].replaceAll(':quotes:', '').replaceAll(':comma:', ','));
            orderFieldObj.Name = csvRecordData[5].replaceAll(':quotes:', '').replaceAll(':comma:', ',');
            orderFieldObj.Sentinel_Api_Field__c = csvRecordData[6].replaceAll(':quotes:', '').replaceAll(':comma:', ',');
            orderFieldObj.SF_Api_Field__c = csvRecordData[7].replaceAll(':quotes:', '').replaceAll(':comma:', ',');
            orderFieldObj.sObjectName__c = csvRecordData[8].replaceAll(':quotes:', '').replaceAll(':comma:', ',');
            orderFieldObj.Sentinel_Status_value__c = csvRecordData[9].replaceAll(':quotes:', '').replaceAll(':comma:', ',');
            orderFieldObj.SF_orderfield_value__c = csvRecordData[10].replaceAll(':quotes:', '').replaceAll(':comma:', ',');
            orderFieldObj.Sequence__c = Decimal.valueOf(csvRecordData[11].replaceAll(':quotes:', '').replaceAll(':comma:', ','));
            orderFieldObj.Version__c = Decimal.valueOf(csvRecordData[12].replaceAll(':quotes:', '').replaceAll(':comma:', ',')).setScale(2);
            Orderfieldlist.add(orderFieldObj);
            versionCompareMap.put(orderFieldObj.Name, orderFieldObj);
        }
        List < Sentinel_Order_Field_Mapping__c > existingMappingList = [Select Id, Name, Version__c, Sequence__c from Sentinel_Order_Field_Mapping__c ORDER BY Sequence__c DESC];
        List < Sentinel_Order_Field_Mapping__c > newMappingListToInsert = new List < Sentinel_Order_Field_Mapping__c >();
        List < Sentinel_Order_Field_Mapping__c > newMappingListToUpdate = new List < Sentinel_Order_Field_Mapping__c >();
        System.Debug('existingMappingList_____' + existingMappingList.size());
        if(Orderfieldlist.size() > existingMappingList.size()) {
            for(Integer i=existingMappingList.size(); i < Orderfieldlist.size(); i++) {
                newMappingListToInsert.add(Orderfieldlist[i]);
                } 
        }
        if(newMappingListToInsert.size() > 0) {
            insert newMappingListToInsert;
            System.Debug('newMappingListToInsert_____' + newMappingListToInsert.size());
        }
        for(Sentinel_Order_Field_Mapping__c existingOrderMap : existingMappingList) {
            Sentinel_Order_Field_Mapping__c orderFieldMap = (Sentinel_Order_Field_Mapping__c) versionCompareMap.get(existingOrderMap.Name);
            if(orderFieldMap != null && existingOrderMap.Version__c != orderFieldMap.Version__c) {
                orderFieldMap.Id = existingOrderMap.Id;
                newMappingListToUpdate.add(orderFieldMap);
            }
        }
        if(newMappingListToUpdate.size() > 0) {
            update newMappingListToUpdate;
            System.Debug('newMappingListToUpdate_____' + newMappingListToUpdate.size());
        }
        String msgBody = 'Package uploaded successfully. Records inserted -> ' + newMappingListToInsert.size() + ', Records Updated -> ' + newMappingListToUpdate.size() + '.';
        //sendEmail('Success while uploading package Non CPQ', msgBody);
    }
    catch (Exception e) {
        System.debug('Error------>'+e.getMessage());
        System.debug('Error stack------>'+e.getStackTraceString());
        String msg = 'Error ->' + e.getMessage() + '<br>';
        msg += 'Stacktrace -> ' + e.getStackTraceString() + '<br>';
        //sendEmail('Error while uploading package Non CPQ', msg);
    	}
	}
}