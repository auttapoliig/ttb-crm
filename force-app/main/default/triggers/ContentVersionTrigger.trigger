trigger ContentVersionTrigger on ContentVersion (before  insert) {
    if(Trigger.isBefore && Trigger.isInsert) {
        FileExtensionHandler.getInstance().checkRestrictedFileUpload(Trigger.New);
    }
}