trigger AccountTrigger on Account (before insert, after insert) {

    //before insert logic
    if(Trigger.isBefore && Trigger.isInsert) { 
        for (Account acc : Trigger.new) {
            //update if account type is null
            if (acc.Type == null || acc.Type == '') {
                acc.Type = 'Prospect';
            }
            // set the rating to 'Hot' if the Phone, Website, and Fax ALL have a value.
            if (acc.phone != null && acc.Website != null && acc.Fax != null){
                acc.Rating = 'Hot';
            }
            // Copying Shipping Address to Billing Address
            acc.BillingCity = acc.ShippingCity;
            acc.BillingCountry = acc.ShippingCountry;
            acc.BillingPostalCode = acc.ShippingPostalCode;
            acc.BillingState = acc.ShippingState;
            acc.BillingStreet = acc.ShippingStreet;
        }
    }
    //after insert logic
    if(Trigger.isAfter && Trigger.isInsert) {          
        List<Contact> contacts = new List<Contact>();
        for (Account acc : Trigger.new) {  
            // Create a contact for the new account
            Contact contact = new Contact();
            contact.LastName = 'DefaultContact';
            contact.Email = 'default@email.com';
            contact.AccountId = acc.Id;
            contacts.add(contact);
        }
        insert contacts;
    }
}
    