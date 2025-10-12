import 'dart:async';
import 'dart:convert';
import 'package:elh/models/Todo.dart';
import 'package:elh/repository/TodoRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

class TodoController extends FutureViewModel<dynamic> {
  TodoRepository _todoRepository = locator<TodoRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  late SharedPreferences prefs;
  bool isLoading = true;
  List<Todo> todos = [];
  List<int> doneIds = [];

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    ApiResponse apiResponse = await _todoRepository.loadTodos();
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      this.todos = todosFromJson(decodeData['todos']);
      this.prefs = await SharedPreferences.getInstance();
      try {
        List<String> mList = (prefs.getStringList('doneIds') ?? []);
        this.doneIds = mList.map((i)=> int.parse(i)).toList();
      } catch(e) {}
      this.todos.forEach((todo) {
        if(this.doneIds.contains(todo.id)) {
          todo.done = true;
        }
      });
      this.isLoading = false;
    } else {
      _errorMessageService.errorOnAPICall();
    }
    notifyListeners();
  }

  FutureOr<bool> openUrl(url) async {
    Uri _url = Uri.parse(url);
    return launchUrl(_url);
  }

  onToDoChanged(todo) {
    todo.done = !todo.done;
    notifyListeners();
    //done ids
    if(doneIds.contains(todo.id) && !todo.done){
      this.doneIds.remove(todo.id);
    } else if(!doneIds.contains(todo.id) && todo.done){
      this.doneIds.add(todo.id);
    }
    List<String> stringsList=  this.doneIds.map((i)=>i.toString()).toList();
    prefs.setStringList('doneIds', stringsList);
  }

  Future<void> refreshData() async {
    this.loadDatas();
  }

  resetDones() {
    this.doneIds = [];
    this.todos.forEach((todo) {
      todo.done = false;
    });
    prefs.remove('doneIds');
    notifyListeners();
  }

}