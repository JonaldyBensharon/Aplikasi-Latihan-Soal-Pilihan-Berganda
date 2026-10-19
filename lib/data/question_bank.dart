import '../models/quiz_question.dart';

const questionBank = <QuizQuestion>[
  QuizQuestion(id:'v1', prompt:'What is the opposite of “ancient”?', options:['Old','Modern','Historic','Traditional'], correctIndex:1),
  QuizQuestion(id:'v2', prompt:'The word "generous" means ...', options:['Full of oneself','Unwilling to help other','Willing to give and share','No self-awareness'], correctIndex:2),
  QuizQuestion(id:'v3', prompt:'My father helps someone gain knowledge. What is his job most likely to be?', options:['Teacher','Driver','Farmer','Singer'], correctIndex:0),
  QuizQuestion(id:'g1', prompt:'She usually ... to cinema every month. However, she did not go last week.', options:['go','goes','going','gone'], correctIndex:1),
  QuizQuestion(id:'g2', prompt:'They ... playing a very old video game, which is said to take a month to complete.', options:['is','am','are','be'], correctIndex:2),
  QuizQuestion(id:'g3', prompt:'I ... a fisherman when my family lived in Kapuas.', options:['is','am','was','be'], correctIndex:2),
  QuizQuestion(id:'g4', prompt:'Which of the sentences provided below is the most correct?', options:['He have a book.','He has a book.','He having a book.','He haves a book.'], correctIndex:1),
  QuizQuestion(id:'r1', passage:'Anna’s black cat, Minna, previously belonged to her aunt, Tina.', prompt:'What is the cat’s name?', options:['Anna','Minna','Black','Tina'], correctIndex:1),
  QuizQuestion(id:'r2', passage:'Anton’s brother is Budi’s father.', prompt:'Who is Budi to Anton?', options:['His father','His uncle','His nephew','His cousin'], correctIndex:2),
  QuizQuestion(id:'r3', passage:'The library opened on 11th, but closed on 16th at the start of the week.', prompt:'Which day was 2 days after the library opened?', options:['Wednesday','Thursday','Friday','Saturday'], correctIndex:2),
];
