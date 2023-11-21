public without sharing class QueueableDispatcher Implements Queueable, Database.AllowsCallouts
{
	/**
	* @author Keattisak Chinburarat
	* @date 2/21/2016
	* @description Defines the interface for Queueable Apex
	*/	
	string asyncReqId;

	public QueueableDispatcher(string a)
	{
		asyncReqId=a;		
	}
	public Interface IQueueableDispatched 
	{ 
	    void execute(QueueableContext sc,string arId); 
	}   
	public void execute(QueueableContext sc) 
	{
		// QueueableHandler q = new QueueableHandler(asyncReqId);
		// q.execute(sc);
		 Type targettype = Type.forName('QueueableHandler');   
		 if(targettype!=null) {
		 	IQueueableDispatched obj = (IQueueableDispatched)targettype.NewInstance();
		 	obj.execute(sc,asyncReqId);   
		 }  
	} 	  

}