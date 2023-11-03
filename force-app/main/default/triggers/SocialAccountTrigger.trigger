trigger SocialAccountTrigger on iigproduct_2__SocialAccount__c (before insert) {
    System.debug('---SocialAccountTrigger---start');
    List<String> rmidList = new List<String>();
    for (iigproduct_2__SocialAccount__c socialAccount : Trigger.new) {
        rmidList.add(socialAccount.iigproduct_2__Social_ID__c);
    }

    Map<String, Account> accMap = new Map<String, Account>();
    for (Account a : [SELECT Id, TMB_Customer_ID_PE__c FROM Account WHERE TMB_Customer_ID_PE__c IN :rmidList]) {
        accMap.put(a.TMB_Customer_ID_PE__c, a);
    }

    for (iigproduct_2__SocialAccount__c sa : Trigger.new) {
        Account account;
        if (accMap.containsKey(sa.iigproduct_2__Social_ID__c)) {
            account = accMap.get(sa.iigproduct_2__Social_ID__c);
        }
        if (account != null) {
            sa.iigproduct_2__Account__c = account.Id;
        }
    }
    System.debug('---SocialAccountTrigger---end');
}