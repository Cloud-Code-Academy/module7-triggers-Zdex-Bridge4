trigger OpportunityTrigger on Opportunity (before insert, before update, before delete) {

    if(Trigger.isBefore){
        
        //When an opportunity is updated validate that the amount is greater than 5000
        if(Trigger.isUpdate){
            Set<Id> accountIds = new Set<Id>();
            for(Opportunity opp : Trigger.new){
                if(opp.Amount <= 5000) {
                    opp.addError('Opportunity amount must be greater than 5000');
                }
                //When an opportunity is updated set the primary contact on the opportunity to the contact on the same account with the title of 'CEO'
                //Collect all Account IDs from the Opportunities being updated
                if(opp.AccountId != null){
                    accountIds.add(opp.AccountId);                
                }

            }
            //Query Contacts with the title 'CEO' for the relevant Account IDs
            Map<Id, Contact> primaryCEOContacts = new Map<Id, Contact>();
            if (!accountIds.isEmpty()){
                for (Contact con : [SELECT Id, AccountId, Title FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO']){
                    primaryCEOContacts.put(con.AccountId, con);
                }
            }
            //Set the Primary Contact on each Opportunity if a CEO Contact exists
            for(Opportunity opp : Trigger.new){
                if(opp.AccountId != null && primaryCEOContacts.containsKey(opp.AccountId)) {
                    opp.Primary_Contact__c = primaryCEOContacts.get(opp.AccountId).Id;
                }
            }
        }
        //prevent the deletion of a closed won opportunity if the account industry is 'Banking'
        if(Trigger.isDelete){
            // Step 1: Collect all Account IDs from Opportunities being deleted
            Set<Id> accountIds = new Set<Id>();
            for (Opportunity opp : Trigger.old) {
                if (opp.AccountId != null) {
                    accountIds.add(opp.AccountId);
                }
            }

            // Step 2: Query the Accounts and store them in a Map
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN :accountIds]);

            // Step 3: Check the condition for each Opportunity
            for (Opportunity opp : Trigger.old) {
                if (opp.StageName == 'Closed Won' && accountMap.containsKey(opp.AccountId)) {
                    Account relatedAccount = accountMap.get(opp.AccountId);
                    if (relatedAccount.Industry == 'Banking') {
                        opp.addError('Cannot delete closed opportunity for a banking account that is won');
                    }
                }
            }  
        }
    }
}