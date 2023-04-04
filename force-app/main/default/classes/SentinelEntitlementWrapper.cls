/*----------------------------------------------------
* @name           SentinelEntitlementWrapper 
* @date           15 May 2020
* @description    This is a wrapper class for update/create request. 
* ------------------------------------------------------*/
public class SentinelEntitlementWrapper {
	
	public class Customer {
		public String customerName;
		public String externalId;
		public String customerIdentifier;
		public String CRMID;
		public String refId;
		public List<CustomAttribute> customAttribute;
	}

	public class CustomAttribute {
		public String attributeName;
		public String attributeValue;
	}

	public class ChannelPartner {
		public String partnerIdentifier;
		public String partnerName;
		public String externalId;
		public String refId1;
		public String refId2;
		public String status;
		public PartnerLogin partnerLogin;
		public BillingAddress billingAddress;
		public ShippingAddress shippingAddress;
		public List<CustomAttribute> customAttribute;
	}

	public class Product {
		public String startDate;
		public String endDate;
		public String totalQuantity;
		public String externalId;
		public String refId1;
		public String refId2;
		public String availableQuantity;
		public String fixedQuantity;
		public String itemState;
		public String activationMethod;
		public List<CustomAttribute> customAttribute;
	}

	public class BillingAddress {
		public String address;
		public String city;
		public String country;
		public String state;
		public String postalCode;
		public String useBillingAddressasShippingAddress;
	}

	public class PartnerLogin {
		public String userIdentifier;
		public String email;
		public String userName;
		public String externalId;
		public String password;
	}

	public class ShippingAddress {
		public String address;
		public String city;
		public String country;
		public String state;
		public String postalCode;
	}

	public class CustomerContact {
		public String contactName;
		public String contactEmail;
		public String customerName;
		public String externalId;
		public String refId1;
		public String refId2;
		public String loginAllowed;
		public String Password;
		public BillingAddress billingAddress;
		public ShippingAddress shippingAddress;
		public List<CustomAttribute> customAttribute;
	} 
  /*public class status {
		public String Draft;
        public String Commited;
		public String Closed;
		public String Disabled;
	}
   public class EntitlementStatus {
		public status Status;
		public List<CustomAttribute> customAttribute;
	}*/
    
	public String refId1;
	public String externalId;
	public String refId2;
	public String EID;
	public String startDate;
	public String endDate;
	public String status;
	public String entitlementAsWhole;
	public String userRegistration;
	public String activationAllowed;
	public String revocationAllowed;
	public String sendNotification;
	public String ccEmail;
	public List<CustomAttribute> customAttribute;
	public Customer customer;
	public CustomerContact customerContact;
	public List<ChannelPartner> channelPartner;
	public List<Product> product; 
}