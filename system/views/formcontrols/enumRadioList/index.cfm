<cfscript>
	inputName    = args.name         ?: "";
	inputId      = args.id           ?: "";
	inputClass   = args.class        ?: "";
	defaultValue = args.defaultValue ?: "";
	items        = args.items        ?: ArrayNew(1)
	inputType    = IsTrue( args.multiple ?: "" ) ? "checkbox" : "radio";
	inputClasses = isTrue( args.multiple ?: "" ) ? "ace-checkbox-2" : "ace-switch ace-switch-3"

	value  = event.getValue( name=inputName, defaultValue=defaultValue );
	if ( not IsSimpleValue( value ) ) {
		value = "";
	}
</cfscript>

<cfoutput>
	<cfloop array="#items#" index="item">
		<cfset itemId = inputId & LCase( Hash( item.id ) ) />
		<cfset disabled = IsTrue( item.disabled ?: "" ) />
		<div class="checkbox role-picker-radio">
			<label>
				<input class="#inputClass# ace #inputClasses#" name="#inputName#" id="#itemId#" type="#inputType#" value="#HtmlEditFormat( item.id )#"<cfif disabled> disabled="disabled"<cfelseif ListFindNoCase( value, item.id )> checked="checked"</cfif> tabindex="#getNextTabIndex()#">
				<span class="lbl">
					<span class="role-title bigger">#item.label#</span><br />
					<span class="role-desc">
						<cfif disabled>
							<em class="light-grey">#item.description#</em>
						<cfelse>
							#item.description#
						</cfif>
					</span>
				</span>
			</label>
		</div>
	</cfloop>
</cfoutput>