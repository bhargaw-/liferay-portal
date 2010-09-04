<%
/**
 * Copyright (c) 2000-2010 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
%>

<%@ include file="/html/portlet/enterprise_admin/init.jsp" %>

<%
String className = (String)request.getAttribute("emailAddresses.className");
long classPK = (Long)request.getAttribute("emailAddresses.classPK");

List<EmailAddress> emailAddresses = Collections.EMPTY_LIST;

int[] emailAddressesIndexes = null;

String emailAddressesIndexesParam = ParamUtil.getString(request, "emailAddressesIndexes");

ArrayList<String> emailAddressesIndexesValue = new ArrayList<String>();

if (Validator.isNotNull(emailAddressesIndexesParam)) {
	emailAddresses = new ArrayList<EmailAddress>();

	emailAddressesIndexes = StringUtil.split(emailAddressesIndexesParam, 0);

	for (int emailAddressesIndex : emailAddressesIndexes) {
		emailAddresses.add(new EmailAddressImpl());
	}
}
else {
	if (classPK > 0) {
		emailAddresses = EmailAddressServiceUtil.getEmailAddresses(className, classPK);

		emailAddressesIndexes = new int[emailAddresses.size()];

		for (int i = 0; i < emailAddresses.size() ; i++) {
			emailAddressesIndexes[i] = i;
		}
	}

	if (emailAddresses.isEmpty()) {
		emailAddresses = new ArrayList<EmailAddress>();

		emailAddresses.add(new EmailAddressImpl());

		emailAddressesIndexes = new int[] {0};
	}

	if (emailAddressesIndexes == null) {
		emailAddressesIndexes = new int[0];
	}
}
%>

<liferay-ui:error-marker key="errorSection" value="additionalEmailAddresses" />

<h3><liferay-ui:message key="additional-email-addresses" /></h3>

<liferay-ui:error exception="<%= EmailAddressException.class %>" message="please-enter-a-valid-email-address" />
<liferay-ui:error key="<%= NoSuchListTypeException.class.getName() + className + ListTypeConstants.EMAIL_ADDRESS %>" message="please-select-a-type" />

<aui:fieldset>

	<%
	for (int i = 0; i < emailAddressesIndexes.length; i++) {
		int emailAddressesIndex = emailAddressesIndexes[i];

		EmailAddress emailAddress = emailAddresses.get(i);

		emailAddressesIndexesValue.add(String.valueOf(emailAddressesIndex));
	%>

		<aui:model-context bean="<%= emailAddress %>" model="<%= EmailAddress.class %>" />

		<div class="lfr-form-row lfr-form-row-inline">
			<div class="row-fields">
				<aui:input name='<%= "emailAddressId" + emailAddressesIndex %>' type="hidden" value="<%= emailAddress.getEmailAddressId() %>" />

				<aui:input fieldParam='<%= "emailAddressAddress" + emailAddressesIndex %>' label="email-address" name="address" />

				<aui:select label="type" name='<%= "emailAddressTypeId" + emailAddressesIndex %>' listType="<%= className + ListTypeConstants.EMAIL_ADDRESS %>" />

				<aui:input checked="<%= emailAddress.isPrimary() %>" cssClass="primary-ctrl" id='<%= "emailAddressPrimary" + emailAddressesIndex %>' inlineLabel="left" label="primary" name="emailAddressPrimary" type="radio" value="<%= emailAddressesIndex %>" />
			</div>
		</div>

	<%
	}
	%>

<aui:input name="emailAddressesIndexes" type="hidden" value="<%= StringUtil.merge(emailAddressesIndexesValue) %>" />

</aui:fieldset>

<aui:script use="liferay-auto-fields">
	Liferay.once(
		'enterpriseAdmin:revealadditionalEmailAddresses',
		function() {
			new Liferay.AutoFields(
				{
					contentBox: '#additionalEmailAddresses > fieldset',
					fieldIndexes: '<portlet:namespace />emailAddressesIndexes'
				}
			).render();
		}
	);
</aui:script>