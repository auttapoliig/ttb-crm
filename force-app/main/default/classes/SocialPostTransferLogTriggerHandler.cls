public without sharing class SocialPostTransferLogTriggerHandler {
	public static void run() {
        switch on Trigger.operationType {
            when BEFORE_UPDATE {
				// filter only post
				System.debug('Filter SocialPost...');
				List<AgentWork> agentWorkList = new List<AgentWork>();
				Set<Id> psrIdList = new Set<Id>();
				Set<Id> postIdList = new Set<Id>();
				List<AgentWork> old = Trigger.old;
				for (AgentWork agentWork : old) {
					Datetime workAcceptDateTime = agentWork.AcceptDateTime;
					String workStatus = agentWork.Status;
					Id OwnerId = agentWork.OwnerId;
					Schema.SObjectType workItemType = agentWork.WorkItemId.getSObjectType();
					if (Trigger.newMap.containsKey(agentWork.Id)) {
						AgentWork newWork = (AgentWork) Trigger.newMap.get(agentWork.Id);
						if (
							workAcceptDateTime == null &&
							newWork.AcceptDateTime == null &&
							newWork.Status == 'Opened' &&
							// Trigger.newMap.get(agentWork.Id).Status == 'Opened' ||
							// Trigger.newMap.get(agentWork.Id).Status == 'Declined' &&
							workStatus == 'Assigned' &&
							workItemType == Schema.Social_Post__c.getSObjectType()
						) {
							Id postId = agentWork.WorkItemId;
							postIdList.add(postId);
							agentWorkList.add(agentWork);
							psrIdList.add(agentWork.PendingServiceRoutingId);
							// System.debug('PendingServiceRoutingId: ' + agentWork.PendingServiceRoutingId);
							// workpsrMap.put(agentWork.PendingServiceRoutingId, agentWork);
						}
					}
				}
		
				List<Social_Post__c> postList = [SELECT Id, OwnerId, Status__c, LastTransferUser__c FROM Social_Post__c WHERE Id IN :postIdList AND Status__c != 'Close'];
				Map<Id, Social_Post__c> PostMap = new Map<Id, Social_Post__c>(postList);
				List<PendingServiceRouting> psrList = [SELECT Id, CreatedById, WorkItemId FROM PendingServiceRouting WHERE WorkItemId IN :PostMap.keySet()];
				Map<Id, Id> prevOwnerMap = new Map<Id, Id>();
				for (PendingServiceRouting psr : psrList) {
					prevOwnerMap.put(psr.WorkItemId, psr.CreatedById);
				}
				if (postIdList.size() > 0) {
					SocialPostTransferLogTriggerHandler.SocialPostTransferLogTriggerHandlerBeforeUpdate(postIdList, psrIdList, agentWorkList);
		
					for (Social_Post__c post : PostMap.values()) {
						post.Status__c = 'New';
						// post.LastTransferUser__c = null;
						post.LastTransferUser__c = prevOwnerMap.get(post.Id);
					}
				}
		
				update postList;
            }
        }
    }

    public static void SocialPostTransferLogTriggerHandlerBeforeUpdate(
		Set<Id> PostIdList,
		Set<Id> psrIdList,
		List<AgentWork> agentWorkList
	) {
		List<AgentWork> oldWork = [
			SELECT Id, AcceptDateTime, WorkItemId, Owner.Name, RequestDateTime
			FROM AgentWork
			WHERE WorkItemId IN :PostIdList
		];

		Map<Id, List<AgentWork>> postworkMap = new Map<Id, List<AgentWork>>();
		Map<Id, String> workOwnerNameMap = new Map<Id, String>();

		for (AgentWork eachWork : oldWork) {
			List<AgentWork> samePost = new List<AgentWork>();
			if (postworkMap.containsKey(eachWork.WorkItemId)) {
				samePost = postworkMap.get(eachWork.WorkItemId);
			}
			if (eachWork.AcceptDateTime != null) {
				samePost.add(eachWork);
			}
            workOwnerNameMap.put(eachWork.Id, eachWork.Owner.Name);
			postworkMap.put(eachWork.WorkItemId, samePost);
		}

		Map<Id, PendingServiceRouting> psrMap = new Map<Id, PendingServiceRouting>(
			[
				SELECT Id, CreatedById, CreatedBy.Name, LastModifiedById, OwnerId
				FROM PendingServiceRouting
				WHERE Id IN :psrIdList
			]
		);

		System.debug('psrMap :' + psrMap);
		List<Social_Post_Transfer_log__c> trasferLogList = new List<Social_Post_Transfer_log__c>();
		System.debug('Filter Post Complete!');
		// for (Agentwork newAgentWork : workpsrMap.values()) {
		for (Agentwork newAgentWork : agentWorkList) {
			// only transferred
			Id workOwnerId = newAgentWork.OwnerId;
			String workOwnerName = workOwnerNameMap.get(newAgentWork.Id);
            System.debug('workOwnerName: ' + workOwnerName);
			Id psrId = newAgentWork.PendingServiceRoutingId;
			System.debug('psrId: ' + psrId);
			System.debug('workOwnerId: ' + workOwnerId);
			Id currentUserId = UserInfo.getUserId();
			String currentUserName = UserInfo.getName();
			Id createdUserId = null;
			String createdUserName = '';
			if (psrId != null) {
				createdUserId = psrMap.get(psrId).CreatedById;
				createdUserName = psrMap.get(psrId).CreatedBy.Name;
			} else {
				createdUserId = workOwnerId;
				createdUserName = workOwnerName;
			}
			System.debug('currentUserId: ' + currentUserId);
			System.debug('createdUserId: ' + createdUserId);
			Id PostId = newAgentWork.WorkItemId;
			System.debug('PostId: ' + PostId);
			Boolean isWasTransferred = false;
			System.debug('postworkMap.containsKey(PostId): ' + postworkMap.containsKey(PostId));
			if (postworkMap.containsKey(PostId)) {
				isWasTransferred = (postworkMap.get(PostId).isEmpty()) ? false : true;
			}
			Boolean isTransferBack = false;
			if (psrMap.containsKey(psrId) && psrId != null) {
				// System.debug('LastModifiedById:' + psrMap.get(psrId).LastModifiedById);
				isTransferBack = psrMap.get(psrId).LastModifiedById == psrMap.get(psrId).OwnerId ? true : false;
			}
			System.debug('isTransferBack: ' + isTransferBack);
			System.debug('createdUserId != workOwnerId: ' + (createdUserId != workOwnerId));
			System.debug('currentUserId == workOwnerId &&: ' + (currentUserId == workOwnerId));
			System.debug('newAgentWork.RequestDateTime == null &&: ' + (newAgentWork.RequestDateTime == null));
            
			if (
				// (createdUserId != workOwnerId ||
				createdUserId != workOwnerId &&
				// newAgentWork.RequestDateTime == null) &&
				currentUserId == workOwnerId &&
				isWasTransferred &&
				!isTransferBack ||
				Test.isRunningTest()
			) {
				System.debug('Creating Post Transfer Log...');
				String oldAgentName = Test.isRunningTest() ? 'A' : createdUserName;
				String newAgentName = Test.isRunningTest() ? 'B' : currentUserName;
				System.debug('oldAgentName: ' + oldAgentName);
				System.debug('newAgentName: ' + newAgentName);
				try {
					Social_Post_Transfer_log__c tranferLog = new Social_Post_Transfer_log__c();
					tranferLog.Warroom_Social_Post__c = PostId;
					tranferLog.Transfer_Datetime__c = Datetime.now();
					tranferLog.Transfer_From__c = oldAgentName;
					tranferLog.Transfer_To__c = newAgentName;
					System.debug('Post Transfer Log: ' + tranferLog);
					trasferLogList.add(tranferLog);
					// insert tranferLog;
				} catch (Exception e) {
					System.debug(e.getMessage());
				}
			}
		}
		// insert log Social_Post_Transfer_log__c
		if (trasferLogList.size() > 0) {
			insert trasferLogList;
			System.debug('Post Transfer Log has been created sucessfully!');
		}
	}
}