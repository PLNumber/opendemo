import 'package:cloud_firestore/cloud_firestore.dart';

class Question{
  num w_Id;

  String word;
  String definition;
  bool iscorrect;
  Question(this.w_Id, this.word, this.definition, {this.iscorrect = true});
}