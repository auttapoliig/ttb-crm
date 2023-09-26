public with sharing class BusinessOutcomeMappingUtil {
    
    public static String calculateCompletionCode( Integer numberOfProduct,Integer count_Of_YES_Complete_Sale,Integer count_Of_NIN_Not_Interest,Integer count_Of_NQF_Not_Qualify,Integer count_Of_Not_Interest_Recall )
    {
        String completionCode;

        if(numberOfProduct == count_Of_YES_Complete_Sale)
        {
            completionCode = 'YES';//'YES Complete Sale';
        }
        else if(numberOfProduct == count_Of_NIN_Not_Interest)
        {
            completionCode = 'NIN';//'NIN Not Interest';
        }
        else if(numberOfProduct == count_Of_NQF_Not_Qualify)
        {
            completionCode = 'NQF';//'NQF Not Qualify';
        }
        else if(numberOfProduct == count_Of_Not_Interest_Recall)
        {
            completionCode = 'NIN_Recall';//'NIN Not Interest - Recall';
        }
        else if(count_Of_YES_Complete_Sale > 0 && count_Of_NIN_Not_Interest > 0 && count_Of_NQF_Not_Qualify == 0 && count_Of_Not_Interest_Recall == 0)
        {
            completionCode = 'Yes_Partial';//'Yes Partial';
        }
        else if(count_Of_YES_Complete_Sale > 0 && count_Of_NIN_Not_Interest == 0 && count_Of_NQF_Not_Qualify > 0 && count_Of_Not_Interest_Recall == 0)
        {
            completionCode = 'Yes_Partial';//'Yes Partial';
        }
        else if(count_Of_YES_Complete_Sale > 0 && count_Of_NIN_Not_Interest == 0 && count_Of_NQF_Not_Qualify == 0 && count_Of_Not_Interest_Recall > 0)
        {
            completionCode = 'Yes_Recall';//'Yes - Recall';
        }
        else if(count_Of_YES_Complete_Sale == 0 && count_Of_NIN_Not_Interest > 0 && count_Of_NQF_Not_Qualify > 0 && count_Of_Not_Interest_Recall == 0)
        {
            completionCode = 'NQF';//'NQF Not Qualify';
        }
        else if(count_Of_YES_Complete_Sale == 0 && count_Of_NIN_Not_Interest > 0 && count_Of_NQF_Not_Qualify == 0 && count_Of_Not_Interest_Recall > 0)
        {
            completionCode = 'NIN_Recall';//'NIN Not Interest - Recall';
        }
        else if(count_Of_YES_Complete_Sale == 0 && count_Of_NIN_Not_Interest == 0 && count_Of_NQF_Not_Qualify > 0 && count_Of_Not_Interest_Recall > 0)
        {
            completionCode = 'NIN_Recall';//'NIN Not Interest - Recall';
        }
        else if(count_Of_YES_Complete_Sale > 0 && count_Of_NIN_Not_Interest > 0 && count_Of_NQF_Not_Qualify > 0 && count_Of_Not_Interest_Recall == 0)
        {
            completionCode = 'Yes_Partial';//'Yes Partial';
        }
        else if(count_Of_YES_Complete_Sale > 0 && count_Of_NIN_Not_Interest > 0 && count_Of_NQF_Not_Qualify == 0 && count_Of_Not_Interest_Recall > 0)
        {
            completionCode = 'Yes_Recall';//'Yes - Recall';
        }
        else if(count_Of_YES_Complete_Sale > 0 && count_Of_NIN_Not_Interest == 0 && count_Of_NQF_Not_Qualify > 0 && count_Of_Not_Interest_Recall > 0)
        {
            completionCode = 'Yes_Recall';//'Yes - Recall';
        }
        else if(count_Of_YES_Complete_Sale == 0 && count_Of_NIN_Not_Interest > 0 && count_Of_NQF_Not_Qualify > 0 && count_Of_Not_Interest_Recall > 0)
        {
            completionCode = 'NIN_Recall';//'NIN Not Interest - Recall';
        }
        else if(count_Of_YES_Complete_Sale > 0 && count_Of_NIN_Not_Interest > 0 && count_Of_NQF_Not_Qualify > 0 && count_Of_Not_Interest_Recall > 0)
        {
            completionCode = 'Yes_Recall';//'Yes - Recall';
        }

        return completionCode;
    }
}