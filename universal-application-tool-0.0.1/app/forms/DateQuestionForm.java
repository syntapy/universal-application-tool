package forms;

import services.question.types.DateQuestionDefinition;
import services.question.types.QuestionType;

public class DateQuestionForm extends QuestionForm {

  public DateQuestionForm() {
    super();
  }

  public DateQuestionForm(DateQuestionDefinition qd) {
    super(qd);
  }

  @Override
  public QuestionType getQuestionType() {
    return QuestionType.DATE;
  }
}
