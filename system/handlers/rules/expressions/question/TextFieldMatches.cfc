/**
 * Expression handler for "Textfield {question} text matches"
 *
 * @expressionContexts webrequest
 * @expressionCategory formbuilder
 */
component {

	property name="rulesEngineOperatorService" inject="rulesEngineOperatorService";
	property name="formBuilderService"         inject="formBuilderService";
	property name="formBuilderFilterService"   inject="formBuilderFilterService";

	/**
	 * @question.fieldtype  formbuilderQuestion
	 * @question.item_type  textinput,textarea,email
	 *
	 */
	private boolean function evaluateExpression(
		  required string question
		, required string value
		,          string  _stringOperator = "eq"
	) {
		var filter = prepareFilters( argumentCollection = arguments	) ;

		return formBuilderFilterService.evaluateQuestionSubmissionResponseMatch(
			  argumentCollection = arguments
			, userId             = payload.user.id
			, formId             = payload.formId ?: ""
			, submissionId       = payload.submissionId ?: ""
			, extraFilters       = filter
		);
	}

	/**
	 * @objects formbuilder_formsubmission
	 */
	private array function prepareFilters(
		  required string question
		, required string value
		,          string _stringOperator = "contains"
		,          string parentPropertyName = ""
		,          string filterPrefix       = ""
	){
		return formBuilderFilterService.prepareFilterForSubmissionQuestionResponseMatchesText( argumentCollection=arguments );
	}

}
