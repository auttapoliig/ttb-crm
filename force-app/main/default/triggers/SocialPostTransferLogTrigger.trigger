trigger SocialPostTransferLogTrigger on AgentWork (before insert, before update) {
    System.debug('-----Start SocialPostTransferLog Trigger------');
	SocialPostTransferLogTriggerHandler.run();
	System.debug('-----End PostTransferLog Trigger------');
}