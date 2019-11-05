public class ProjectCalloutService {
	//Complete the implementation for business and callout logic
	@InvocableMethod
	public static void postOpportunityToPMS(List<Id> opportunityId){

	}

	class QueueablePMSCall implements Queueable {

		public final List<Id> opportunityIds;

		QueueablePMSCall(List<Id> opportunityIdsFromProcess){
			opportunityIds = opportunityIdsFromProcess;
		}

		public void execute(QueueableContext context){

			List<Opportunity> opportunities = [
				SELECT Id,Name,CloseDate,Amount,Account.Name
				FROM Opportunity
				WHERE Opportunity.Id 
				IN :opportunityIds
			];

			List<String> serializedOpportunities = new List<String>();

			for (Opportunity item : opportunities) {
				WrapperJSON wrapper = new WrapperJSON();
				wrapper.opportunityId = item.Id;
				wrapper.opportunityName = item.Name;
				wrapper.accountName = item.Account.Name;
				wrapper.closeDate = item.CloseDate;
				wrapper.amount = item.Amount;

				serializedOpportunities.add(JSON.serialize(wrapper));
			}

			for (String item : serializedOpportunities) {
				Http http = new Http();
				HttpRequest request = new HttpRequest();
				request.setHeader('key', ServiceTokens__c.getInstance('ProjectServiceToken').Token__c);
				request.setEndpoint('https://sb-integration-pms.herokuapp.com/projects');
				request.setMethod('POST');
				request.setBody(item);
				HttpResponse response = http.send(request);

				System.debug(response.getStatusCode());
			}

		}

	}

	class WrapperJSON {
		Id opportunityId { get; set;}
		String opportunityName { get; set;}
		String accountName { get; set;}
		Date closeDate { get; set;}
		Decimal amount { get; set;}
	}
}