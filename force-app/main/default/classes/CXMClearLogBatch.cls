global class CXMClearLogBatch implements Database.Batchable<sObject>, Database.stateful {

    private String query; 
    private Date lastNDay;

    public CXMClearLogBatch(String q, Date lastNDay) {
            this.query = q;
            this.lastNDay = lastNDay;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('::::::::: Start CXMClearLogBatch ::::::::::::::::');
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope){
        System.debug('::::::::: Execute CXMClearLogBatch ::::::::::::::::');
        if(scope.size() > 0){
            Database.DeleteResult[] logDeleteResult = Database.delete(scope, false);
        }       
    }
    global void finish(Database.BatchableContext bc){
        System.debug('::::::::: Finish CXMClearLogBatch ::::::::::::::::');
    }


}