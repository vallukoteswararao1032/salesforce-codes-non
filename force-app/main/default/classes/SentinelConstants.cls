/*----------------------------------------------------
* @name           SentinelConstants 
* @date           10 May 2020
* @description    This is class to having all the constants used. 
* ------------------------------------------------------*/
public without sharing class SentinelConstants {
    public static Boolean integrationDone = false;

    public static Boolean isEidEntered = false;

    public static final Map<String, List<String>> categoryVsSentinelFieldMap = new Map<String, List<String>>{
        'Entitlement' =>  new List<String>{'startDate', 'endDate', 'refId2', 'refId1', 'externalId', 'status', 
            'entitlementAsWhole', 'userRegistration', 'sendNotification', 'activationAllowed', 'revocationAllowed', 'ccEmail','EID'} ,
        'CustomerContact' => new List<String>{'contactName', 'contactEmail', 'customerName', 'externalId', 'refId1', 'refId2' ,
            'loginAllowed', 'Password', 'billingAddress.address', 'billingAddress.city','billingAddress.country',
            'billingAddress.state','billingAddress.postalCode','billingAddress.useBillingAddressasShippingAddress', 
            'shippingAddress.address', 'shippingAddress.city','shippingAddress.country',
            'shippingAddress.state','shippingAddress.postalCode'} ,
        'Customer' => new List<String>{'externalId', 'customerName', 'customerIdentifier', 'CRMID', 'refId'} ,
        'ChannelPartner' => new List<String>{'partnerName', 'partnerIdentifier', 'externalId', 'refId1', 'refId2', 'status',
            'billingAddress.address', 'billingAddress.city','billingAddress.country', 'billingAddress.state','billingAddress.postalCode',
            'billingAddress.useBillingAddressasShippingAddress', 'shippingAddress.address', 'shippingAddress.city','shippingAddress.country',
            'shippingAddress.state','shippingAddress.postalCode', 'partnerLogin.userIdentifier','partnerLogin.email',
            'partnerLogin.userName','partnerLogin.externalId','partnerLogin.password'} ,
        'Product' => new List<String>{'totalQuantity', 'startDate', 'refId1', 'externalId', 'refId2', 
            'endDate', 'activationMethod', 'availableQuantity', 'fixedQuantity', 'itemState'},
        'EntitlementStatus' => new List<String>{'Draft', 'Commited', 'Closed', 'Disabled'}
    };

    public static final Map<String, List<String>> categoryVsCustomAttributeMap = new Map<String, List<String>>{
        'Entitlement' =>  new List<String>{'Commercial' } ,
        'Product' => new List<String>{'Initial', '1001'}
    };

    public static final Map<String, Map<String, String>> catVsFieldvsDescriptionMap = new  Map<String, Map<String, String>>{
        'Entitlement' => new Map<String, String>{
            'EID' => 'A unique friendly name for the entitlement. If not provided, Sentinel EMS automatically generates the eId after creating an entitlement.',
            'refId1' => 'First reference identifier of the entitlement as used by external ERP/CRM systems.',
            'refId2' => 'Second reference identifier of the entitlement as used by external ERP/CRM systems.',
            'externalId' => 'Unique external identifier of the entitlement.',
            'startDate' => 'Start date of the entitlement. Default: Current date',
            'endDate' => 'The end date of the entitlement.',
            'status' => 'State of the entitlement. Default: commit( draft, commit, disable, closed )',
            'entitlementAsWhole' => 'Whether to perform activations/revocations on all associated products (also referred to as product keys) together.Default: false',
            'userRegistration' => 'Whether end user registration is required when logging in to Sentinel. (NONE, OPTIONAL, MANDATORY)',
            'activationAllowed' => 'activations are allowed for the entitlement. deafult true',
            'revocationAllowed' => 'revocations are allowed for the entitlement. default false',
            'sendNotification' => 'Whether to send notification to contacts after a successful operation.',
            'ccEmail' => 'Email addresses to receive entitlement certificate. You can specify up to 15 email addresses.'
        },
        'CustomerContact' => new Map<String, String>{
            'contactName' => 'Name of the contact.',
            'contactEmail' => 'Email address of the contact.',
            'customerName' => 'Name of the customer.',
            'externalId' => 'Unique external identifier of the contact.',
            'refId1' => 'First reference identifier of the contact as used by external ERP/CRM systems.',
            'refId2' => 'Second reference identifier of the contact as used by external ERP/CRM systems.',
            'loginAllowed' => 'true', 
            'Password' => 'Password of the contact. The minimum length should be 6 six characters.', 
            'billingAddress.address' => 'The billing address of the contact.Minimum length: 1 Maximum length: 100', 
            'billingAddress.city' => 'The billing city of the contact.Minimum length: 1 Maximum length: 100',
            'billingAddress.country' => 'The billing country of the contact.Minimum length: 1 Maximum length: 100',
            'billingAddress.state' => 'The billing state of the contact.Minimum length: 1 Maximum length: 100',
            'billingAddress.postalCode' => 'The billing postalCode of the contact.Minimum length: 1 Maximum length: 100',
            'billingAddress.useBillingAddressasShippingAddress' => 'true', 
            'shippingAddress.address' => 'The shipping address of the contact.Minimum length: 1 Maximum length: 100', 
            'shippingAddress.city' => 'The shipping city of the contact.Minimum length: 1 Maximum length: 100',
            'shippingAddress.country' => 'The shipping country of the contact.Minimum length: 1 Maximum length: 100',
            'shippingAddress.state' => 'The shipping state of the contact.Minimum length: 1 Maximum length: 100',
            'shippingAddress.postalCode' => 'The shipping postalCode of the contact.Minimum length: 1 Maximum length: 100'
        },
        'Customer' => new Map<String, String>{
            'customerName' => 'Name of the customer.',
            'externalId' => 'Unique external identifier of the customer.',
            'customerIdentifier' => '3221522',
            'CRMID' => 'The Customer Relationship Management (CRM) identification number.',
            'refId' => 'Reference identifier of the customer as used by external ERP/CRM systems.'
        },
        'ChannelPartner'  => new Map<String, String>{
            'partnerIdentifier' => 'User-defined or system-generated identifier of the partner.',
            'partnerName' => 'Name of the partner.',
            'refId1'=> 'First reference identifier of the partner as used by external ERP/CRM systems.',
            'refId2'=> 'Second reference identifier of the partner as used by external ERP/CRM systems.',
            'externalId' => 'Unique external identifier of the partner.',
            'status' => 'State of the partner. The partner users for the partner can access Sentinel EMS only if the state is set to ENABLE.',
            'billingAddress.address' => 'The billing address of the channelPartner.Minimum length: 1 Maximum length: 100', 
            'billingAddress.city' => 'The billing city of the channelPartner.Minimum length: 1 Maximum length: 100',
            'billingAddress.country' => 'The billing country of the channelPartner.Minimum length: 1 Maximum length: 100',
            'billingAddress.state' => 'The billing state of the channelPartner.Minimum length: 1 Maximum length: 100',
            'billingAddress.postalCode' => 'The billing postalCode of the channelPartner.Minimum length: 1 Maximum length: 100',
            'billingAddress.useBillingAddressasShippingAddress' => 'true', 
            'shippingAddress.address' => 'The shipping address of the channelPartner.Minimum length: 1 Maximum length: 100', 
            'shippingAddress.city' => 'The shipping city of the channelPartner.Minimum length: 1 Maximum length: 100',
            'shippingAddress.country' => 'The shipping country of the channelPartner.Minimum length: 1 Maximum length: 100',
            'shippingAddress.state' => 'The shipping state of the channelPartner.Minimum length: 1 Maximum length: 100',
            'shippingAddress.postalCode' => 'The shipping postalCode of the channelPartner.Minimum length: 1 Maximum length: 100',
            'partnerLogin.userIdentifier' => 'Unique login ID of the partner user. This is used to log in to Sentinel EMS.\\Length: 6 to 35 character.Special characters are not allowed, except for underscore.',
            'partnerLogin.email' => 'Email address of the partner userchannelPartner.',
            'partnerLogin.userName' => 'Name of the partner user.',
            'partnerLogin.externalId' => 'Unique external identifier of the partner user.',
            'partnerLogin.password' => 'Password of the partner user. This should be at least 6 characters long.'
        },
        'Product' => new Map<String, String> {
            'totalQuantity' => 'Total number of licenses that can be generated for product keys (products associated with the entitlement). Default: 1',
            'startDate' => 'Start date of the associated products. This should not be earlier than the entitlement start date.',
            'refId1' => 'First reference identifier of the product as used by external ERP/CRM systems.',
            'refId2' => 'Second reference identifier of the product as used by external ERP/CRM systems.',
            'externalId' => 'Unique external identifier of the product.',
            'endDate' => 'The end date of the entitlement.',
            'activationMethod' => 'Activation method for the product. SAOT,FIXED,PARTIAL,FULL,UNLIMITED',
            'availableQuantity' => 'Remaining quantity available for the activation. For draft entitlements, this is equal to total quantity. Its value is relevant only for activated entitlements.',
            'fixedQuantity' => 'Quantity to be consumed when the activation method is fixed.',
            'itemState' => 'State of the associated product (productkey).DRAFT, ENABLE, DISABLE, CLOSED'
        },
        'EntitlementStatus' => new Map<String, String> {
            'Draft' => 'State of the entitlement. Default: commit( draft )',
            'Commit' => 'State of the entitlement. Default: commit( commit )',
            'Closed' => 'State of the entitlement. Default: commit( closed )',
            'Disabled' => 'State of the entitlement. Default: commit( disable )'
        }
    };
    public static final Map<String, Map<String, String>> catVsFieldvsDefaultValuesMap = new  Map<String, Map<String, String>>{
        'Entitlement' => new Map<String, String>{
            'EID' => 'EID__c',
            'refId1' => 'PoNumber',
            'refId2' => 'OrderNumber',
            'externalId' => 'OriginalOrder.OrderNumber',
            'startDate' => 'EffectiveDate',
            'endDate' => 'EndDate',
            'status' => 'status__c',
            'entitlementAsWhole' => '',
            'userRegistration' => 'userRegistration__c',
            'activationAllowed' => '',
            'revocationAllowed' => 'Exist__c',
            'sendNotification' => '',
            'ccEmail' => 'BillToContact.Email'
        },
        'CustomerContact' => new Map<String, String>{
            'contactName' => 'BillToContact.Name',
            'contactEmail' => 'BillToContact.Email',
            'customerName' => 'Account.Name',
            'externalId' => '',
            'refId1' => '',
            'refId2' => '',
            'loginAllowed' => '', 
            'Password' => '', 
            'billingAddress.address' => 'Account.BillingStreet', 
            'billingAddress.city' => 'Account.BillingCity',
            'billingAddress.country' => 'Account.BillingCountry',
            'billingAddress.state' => 'Account.BillingState',
            'billingAddress.postalCode' => 'Account.BillingPostalCode',
            'billingAddress.useBillingAddressasShippingAddress' => '', 
            'shippingAddress.address' => 'Account.ShippingStreet', 
            'shippingAddress.city' => 'Account.ShippingCity',
            'shippingAddress.country' => 'Account.ShippingCountry',
            'shippingAddress.state' => 'Account.ShippingState',
            'shippingAddress.postalCode' => 'Account.ShippingPostalCode'
        },
        'Customer' => new Map<String, String>{
            'customerName' => 'Account.Name',
            'externalId' => 'Account.AccountNumber',
            'customerIdentifier' => 'Account.AccountNumber',
            'CRMID' => '',
            'refId' => 'Account.AccountNumber'
        },
        'ChannelPartner'  => new Map<String, String>{
            'partnerIdentifier' => 'Account.AccountNumber',
            'partnerName' => 'Account.Name',
            'refId1'=> 'Account.AccountNumber',
            'refId2'=> '',
            'externalId' => '',
            'status' => '',
            'billingAddress.address' => 'Account.BillingStreet', 
            'billingAddress.city' => 'Account.BillingCity',
            'billingAddress.country' => 'Account.BillingCountry',
            'billingAddress.state' => 'Account.BillingState',
            'billingAddress.postalCode' => 'Account.BillingPostalCode',
            'billingAddress.useBillingAddressasShippingAddress' => '', 
            'shippingAddress.address' => 'Account.ShippingStreet', 
            'shippingAddress.city' => 'Account.ShippingCity',
            'shippingAddress.country' => 'Account.ShippingCountry',
            'shippingAddress.state' => 'Account.ShippingState',
            'shippingAddress.postalCode' => 'Account.ShippingPostalCode',
            'partnerLogin.userIdentifier' => '',
            'partnerLogin.email' => '',
            'partnerLogin.userName' => '',
            'partnerLogin.externalId' => '',
            'partnerLogin.password' => ''
        },
        'Product' => new Map<String, String> {
            'totalQuantity' => 'Quantity',
            'startDate' => 'ServiceDate',
            'refId1' => '',
            'refId2' => '',
            'externalId' => 'Product2.ProductCode',
            'endDate' => 'EndDate',
            'activationMethod' => '',
            'availableQuantity' => '',
            'fixedQuantity' => '',
            'itemState' => 'Order.itemState__c'
        }
    };
}