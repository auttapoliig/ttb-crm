({
    init : function(component, event, helper) {
        component.set('v.birthDayLabel', $A.get("$Label.c.BirthdayReport"));
        component.set('v.riskLabel', $A.get("$Label.c.RiskReport"));
        component.set('v.kycLabel', $A.get("$Label.c.KYCReport"));
        component.set('v.IdCardLabel', $A.get("$Label.c.IDCardReport"));
        component.set('v.dormantAccLabel', $A.get("$Label.c.Customer_Dormant_Accounts"));
        component.set('v.depositInLabel', $A.get("$Label.c.Customer_Deposit_Mature"));
        component.set('v.MFMLabel', $A.get("$Label.c.Customer_MF_Mature"));
        component.set('v.InsuranceAnLabel', $A.get("$Label.c.Customer_Insurance_Anniversary"));
        component.set('v.InsuranceMatureLabel', $A.get("$Label.c.Customer_Insurance_Mature"));
        component.set('v.LargeWealthLabel', $A.get("$Label.c.LargeTransactionWealthAlertReport"));
        component.set('v.LargeNonWealthLabel', $A.get("$Label.c.LargeTransactionNonWealthAlertReport"));
        component.set('v.riskMisMatchLabel', $A.get("$Label.c.RiskMisMatchAlertReport"));
        component.set('v.mfAdjustLabel', $A.get("$Label.c.MFAdjustAlertReportLabel"));
        component.set('v.aumChangeLabel', $A.get("$Label.c.AUMChangeAlertReport"));
        component.set('v.campaignLabel', $A.get("$Label.c.CampaignReport"));
        component.set('v.campaignInstantLabel', $A.get("$Label.c.CampaignInstantLendingAlertReport"));
        component.set('v.campaignFulfillLabel', $A.get("$Label.c.CampaignFulfillmentAlertReport"));
        component.set('v.campaignTTBReserveLabel', $A.get("$Label.c.CampaignTTBReserveAlertReport"));
    },

    handleSectionToggle: function (component, event, helper) {
        var openSections = event.getParam('openSections');
        const sectionName = openSections.join(', ');
    }
})