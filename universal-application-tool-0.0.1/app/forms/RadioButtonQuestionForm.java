package forms;

import services.question.types.QuestionType;
import services.question.types.RadioButtonQuestionDefinition;

public class RadioButtonQuestionForm extends MultiOptionQuestionForm {

  public RadioButtonQuestionForm() {
    super();
  }

  public RadioButtonQuestionForm(RadioButtonQuestionDefinition qd) {
    super(qd);
  }

  @Override
  public QuestionType getQuestionType() {
    return QuestionType.RADIO_BUTTON;
  }
}
