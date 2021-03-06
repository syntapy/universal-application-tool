package forms;

import services.question.types.EmailQuestionDefinition;
import services.question.types.QuestionType;

public class EmailQuestionForm extends QuestionForm {

  public EmailQuestionForm() {
    super();
  }

  public EmailQuestionForm(EmailQuestionDefinition qd) {
    super(qd);
  }

  @Override
  public QuestionType getQuestionType() {
    return QuestionType.EMAIL;
  }
}
