import 'package:elh/models/Todo.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Todo/TodoController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class TodoView extends StatefulWidget {
  @override
  TodoViewState createState() => TodoViewState();
}

class TodoViewState extends State<TodoView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TodoController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              title: Text('Formalités administratives', style: headerTextWhite),
              elevation: 0,
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: PopupMenuButton(
                    elevation: 3,
                    offset: Offset(30, 35),
                    child: Icon(
                      MdiIcons.plus,
                      color: Colors.white,
                    ),
                    itemBuilder: (BuildContext bc) => [
                      PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(MdiIcons.squareOutline),
                              UIHelper.horizontalSpace(8),
                              Text("Réiniatiliser"),
                            ],
                          ),
                          value: "resetTodo"),
                    ],
                    onCanceled: () {},
                    onSelected: (value) {
                      if (value == 'resetTodo') {
                        controller.resetDones();
                      }
                    },
                  ),
                ),
              ],
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(220, 198, 169, 1.0), // light beige
                      Color.fromRGBO(143, 151, 121, 1.0), // olive green
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            body: controller.isLoading
                ? Center(child: BBloader())
                : SafeArea(
                    child: RefreshIndicator(
                      child: ListView(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        children: todos(controller),
                      ),
                      onRefresh: controller.refreshData,
                    ),
                  )),
        viewModelBuilder: () => TodoController());
  }

  List<Widget> todos(TodoController todoController) {
    List<Widget> todoList = [];
    todoController.todos.forEach((Todo todo) {
      todoList.add(Container(
          margin: EdgeInsets.only(bottom: 15),
          child: ListTile(
            onTap: () {
              todoController.onToDoChanged(todo);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            tileColor: Colors.white,
            leading: Icon(
              todo.done ? Icons.check_box : Icons.check_box_outline_blank,
              color: todo.done ? successColor : primaryColor,
            ),
            title: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: HtmlWidget(todo.content,
                      onTapUrl: (url) => todoController.openUrl(url),
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: todo.done ? fontGrey : fontDark,
                      )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(todo.done ? '' : 'Effecuté ?',
                        style: TextStyle(color: fontGrey, fontSize: 11))
                  ],
                )
              ],
            ),
          )));
    });
    return todoList;
  }
}
