({
    init : function(component, event, helper) {
        component.set('v.birthDayLabel', $A.get("$Label.c.BirthdayReport"));
        component.set('v.riskLabel', $A.get("$Label.c.RiskReport"));
        component.set('v.pdpaLabel', $A.get("$Label.c.PDPAReport"));
        component.set('v.marketLabel', $A.get("$Label.c.MarketConductReport"));
        component.set('v.kycLabel', $A.get("$Label.c.KYCReport"));
        component.set('v.IdCardLabel', $A.get("$Label.c.IDCardReport"));
        component.set('v.dormantAccLabel', $A.get("$Label.c.DormantAccountReport"));
        component.set('v.depositInLabel', $A.get("$Label.c.DepositInvestReport"));
        component.set('v.MFMLabel', $A.get("$Label.c.MFMaturityReport"));
        component.set('v.InsuranceAnLabel', $A.get("$Label.c.InsuranceAnReport"));
        component.set('v.InsurancePaidLabel', $A.get("$Label.c.InsurancePaidReport"));
        component.set('v.InsuranceMatureLabel', $A.get("$Label.c.InsuranceMatureReport"));
        component.set('v.AUMPlusLabel', $A.get("$Label.c.AUMPlusReport"));
        component.set('v.AUMMinusLabel', $A.get("$Label.c.AUMMinusReport"));
        component.set('v.largePlusLabel', $A.get("$Label.c.LargeTransactionPlusReport"));
        component.set('v.largeMinusLabel', $A.get("$Label.c.LargeTransactionMinusReport"));
        component.set('v.campaignLabel', $A.get("$Label.c.CampaignReport"));
    },

    handleSectionToggle: function (component, event, helper) {
        var openSections = event.getParam('openSections');
        const sectionName = openSections.join(', ');
    }
})