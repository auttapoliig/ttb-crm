trigger chatSessionTrigger on iigproduct_2__ChatSession__c (before insert, before update, after update) {
    System.debug('---chatSessionTrigger---1');

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            Map<Id, iigproduct_2__ChatSession__c> chatSessionListMap = new Map<Id, iigproduct_2__ChatSession__c>();
            Set<Id> socialIdList = new Set<Id>();
            Set<String> rmidList = new Set<String>();
            for (iigproduct_2__ChatSession__c chatSession : Trigger.new) {
                if (chatSession.iigproduct_2__RMID__c != NULL) {
                    socialIdList.add(chatSession.iigproduct_2__Social_ID__c);
                    rmidList.add(chatSession.iigproduct_2__RMID__c);
                }
            }
            Map<String, Account> accMap = new Map<String, Account>();
            for (Account a : [SELECT Id, TMB_Customer_ID_PE__c, RTL_Customer_Name_TH__c, Customer_Name_PE_Eng__c, First_Name_PE__c, First_Name_Eng_PE__c FROM Account WHERE TMB_Customer_ID_PE__c IN :rmidList]) {
                accMap.put(a.TMB_Customer_ID_PE__c, a);
            }
            
            List<iigproduct_2__SocialAccount__c> saList = [SELECT Id, iigproduct_2__Social_ID__c, iigproduct_2__Account__c, iigproduct_2__Display_Name__c FROM iigproduct_2__SocialAccount__c WHERE iigproduct_2__Social_ID__c IN :rmidList];
            System.debug('saList: ' + saList);
            for (iigproduct_2__SocialAccount__c sa : saList) {
                sa.iigproduct_2__Display_Name__c = sa.iigproduct_2__Display_Name__c != null && sa.iigproduct_2__Display_Name__c != '' ? sa.iigproduct_2__Display_Name__c : '-';
                Account account = accMap.get(sa.iigproduct_2__Social_ID__c);
                if (account != null) {
                    sa.iigproduct_2__Account__c = account.Id;
                    if (account.First_Name_PE__c != null) {
                        sa.iigproduct_2__Display_Name__c = account.First_Name_PE__c;
                    } else if (account.First_Name_Eng_PE__c != null) {
                        sa.iigproduct_2__Display_Name__c = account.First_Name_Eng_PE__c;
                    }
                    sa.iigproduct_2__FirstName__c = account.First_Name_PE__c;
                    sa.iigproduct_2__First_Name_EN__c = account.First_Name_Eng_PE__c;
                }
            }
            update saList;
        }
        if (Trigger.isUpdate) {
            System.debug('---chatSessionTriggerB4Update');
            List<Id> sessionIdList = new List<Id>();
            Map<Id, iigproduct_2__ChatSession__c> chatSessionMap = new Map<Id, iigproduct_2__ChatSession__c>();
            for (iigproduct_2__ChatSession__c oneappSession : Trigger.new) {
                iigproduct_2__ChatSession__c oldSession = Trigger.oldMap.get(oneappSession.Id);
                if (oldSession.iigproduct_2__EndedBy__c == null && oneappSession.iigproduct_2__EndedBy__c != null) {
                    sessionIdList.add(oneappSession.Id);
                }
            }
            if (!sessionIdList.isEmpty()) {
                ChatSessionTriggerHandler.setFirstCustomerMessage(sessionIdList, Trigger.newMap);
            }
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            System.debug('---chatSessionTrigger---2');
            List<Id> sessionIdList = new List<Id>();
            for (iigproduct_2__ChatSession__c oneappSession : Trigger.new) {
                iigproduct_2__ChatSession__c oldSession = Trigger.oldMap.get(oneappSession.Id);
                if (oneappSession.iigproduct_2__EndedBy__c == 'Disconnected' && oldSession.iigproduct_2__EndedBy__c != oneappSession.iigproduct_2__EndedBy__c) {
                    sessionIdList.add(oneappSession.Id);
                }
            }
            if (!sessionIdList.isEmpty()) {
                ChatSessionTriggerHandler.sendNoti(sessionIdList);
                System.debug('---chatSessionTrigger---4');
            }
        }
    }
}