//Generated by FuseIT WSDL2Apex (http://www.fuseit.com/Solutions/SFDC-Explorer/Help-WSDL-Parser.aspx)
//Warning: '<xsd:any>' element type has been changed to dataType List<DOM.XmlNode> called anyElement
	
public class schemasMicrosoftComXmlDiffgramV1 {
	private static final String s_ns0 = 'urn:schemas-microsoft-com:xml-diffgram-v1';
	public class diffgram_before_element {
		private transient String[] apex_schema_type_info = new String[]{s_ns0,'true','false'};
		private transient String[] field_order_type_info = new String[]{};
		public diffgram_before_element(DOM.XmlNode responseNode){
			Set<DOM.XmlNode> nodesParsed = new Set<DOM.XmlNode>();
		}
		public void populateXmlNode(Dom.XmlNode outerNode){
		}
	}
	
	//Warning: '<xsd:any>' element type has been changed to dataType List<DOM.XmlNode> called anyElement
	public class diffgram_element {
		public List<DOM.XmlNode> anyElement;
		public schemasMicrosoftComXmlDiffgramV1.diffgram_before_element before;
		public schemasMicrosoftComXmlDiffgramV1.diffgram_errors_element errors;
		private transient String[] anyElement_type_info = new String[]{'anyElement','urn:schemas-microsoft-com:xml-diffgram-v1','List<DOM.XmlNode>','0','1','true'};
		private transient String[] before_type_info = new String[]{'before',s_ns0,'','0','1','false'};
		private transient String[] errors_type_info = new String[]{'errors',s_ns0,'','0','1','false'};
		private transient String[] apex_schema_type_info = new String[]{s_ns0,'true','false'};
		private transient String[] field_order_type_info = new String[]{'anyElement','before','errors'};
		public diffgram_element(){
		}
		public diffgram_element(DOM.XmlNode responseNode){
			Set<DOM.XmlNode> nodesParsed = new Set<DOM.XmlNode>();
			
			this.anyElement = new List<DOM.XmlNode>();
            for(DOM.XmlNode childNode: responseNode.getChildElements()){
                if(!nodesParsed.contains(childNode)){
                    this.anyElement.add(childNode);
                }
            }
			//System.debug(this.anyElement);			
			DOM.XmlNode beforeNode = responseNode.getChildElement('before', 'urn:schemas-microsoft-com:xml-diffgram-v1');
			if(beforeNode == null){
				this.before = null;
			} else{
				schemasMicrosoftComXmlDiffgramV1.diffgram_before_element beforeObj = new schemasMicrosoftComXmlDiffgramV1.diffgram_before_element(beforeNode);
				nodesParsed.add(beforeNode);
				this.before = beforeObj;
			}
			//System.debug(this.before);			
			DOM.XmlNode errorsNode = responseNode.getChildElement('errors', 'urn:schemas-microsoft-com:xml-diffgram-v1');
			if(errorsNode == null){
				this.errors = null;
			} else{
				schemasMicrosoftComXmlDiffgramV1.diffgram_errors_element errorsObj = new schemasMicrosoftComXmlDiffgramV1.diffgram_errors_element(errorsNode);
				nodesParsed.add(errorsNode);
				this.errors = errorsObj;
			}
			//System.debug(this.errors);			
		}
		public void populateXmlNode(Dom.XmlNode outerNode){
			
			List<DOM.XmlNode> anyElementObj = this.anyElement;
			for(DOM.XmlNode anyNode: this.anyElement){
                Dom.XmlNode anyElementNode = outerNode.addChildElement(anyNode.getName(), anyNode.getNamespace(), ''); 
            }
			
			schemasMicrosoftComXmlDiffgramV1.diffgram_before_element beforeObj = this.before;
			Dom.XmlNode beforeNode = outerNode.addChildElement('before', 'urn:schemas-microsoft-com:xml-diffgram-v1', '');
			if(beforeObj != null){
				beforeObj.populateXmlNode(beforeNode);
			}
			
			schemasMicrosoftComXmlDiffgramV1.diffgram_errors_element errorsObj = this.errors;
			Dom.XmlNode errorsNode = outerNode.addChildElement('errors', 'urn:schemas-microsoft-com:xml-diffgram-v1', '');
			if(errorsObj != null){
				errorsObj.populateXmlNode(errorsNode);
			}
		}
	}
	public class diffgram_errors_element {
		private transient String[] apex_schema_type_info = new String[]{s_ns0,'true','false'};
		private transient String[] field_order_type_info = new String[]{};
		public diffgram_errors_element(DOM.XmlNode responseNode){
			Set<DOM.XmlNode> nodesParsed = new Set<DOM.XmlNode>();
		}
		public void populateXmlNode(Dom.XmlNode outerNode){
		}
	}
}