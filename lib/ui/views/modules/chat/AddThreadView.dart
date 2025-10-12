import 'package:elh/common/elh_icons.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/models/ChatThread.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/userThumb.dart';
import 'package:elh/ui/views/modules/chat/AddThreadController.dart';
import 'package:stacked/stacked.dart';

class AddThreadView extends StatelessWidget {
  final Thread? thread;
  AddThreadView(this.thread);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddThreadController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              title: Text(controller.title, style: headerTextWhite),
              backgroundColor: Colors.transparent,
              iconTheme: new IconThemeData(color: Colors.white),
              actions: [
                controller.userToAddIds.length > 0
                    ? controller.isSaving
                        ? BBloader()
                        : GestureDetector(
                            child: Center(
                                child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(Icons.send, color: Colors.white),
                            )),
                            onTap: () {
                              controller.saveThread();
                            },
                          )
                    : Container(),
              ],
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(220, 198, 169, 1.0),
                      Color.fromRGBO(143, 151, 121, 1.0),
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
                    child: SingleChildScrollView(
                    child: IndexedStack(
                      index: controller.getCurrentIndex(),
                      children: [
                        _threadTypeChoice(controller),
                        _listUsers(controller),
                      ],
                    ),
                  ))),
        viewModelBuilder: () => AddThreadController(thread));
  }

  _listUsers(AddThreadController controller) {
    if (controller.userListLoading) {
      return BBloader();
    }
    List<Widget> users = [];
    //recherche
    users.add(Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          UIHelper.verticalSpace(15),
          Text("Rechercher un membre de ma communauté", style: labelSmallStyle),
          UIHelper.verticalSpace(5),
          TextField(
            controller: controller.searchInputController,
            onChanged: (String value) async {
              controller.setSearch(value);
            },
            onSubmitted: (String value) async {
              controller.searchUser();
            },
            decoration: InputDecoration(
              hintStyle: TextStyle(color: fontGrey),
              enabledBorder: InputBorder.none,
              suffixIcon: controller.dataLoading
                  ? Container(width: 0)
                  : controller.searchTerm.length > 0
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: fontGrey,
                          ),
                          onPressed: () {
                            controller.clearSearch();
                          },
                        )
                      : Container(width: 0),
              hintText: 'Nom ou prénom ...',
              border: InputBorder.none,
            ),
          ),
          controller.showErrorText
              ? Center(
                  child: Text(
                      'La recherche doit contenir au moins 4 caractères !'),
                )
              : Container(),
          UIHelper.verticalSpaceSmall(),
        ],
      ),
    ));
    if (controller.hasSearch && controller.users.length == 0) {
      users.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 50),
          child: Column(
            children: [
              Center(
                child: Text('Aucun résultat parmi votre communauté !'),
              ),
              UIHelper.verticalSpace(15),
              Center(
                child: GestureDetector(
                  onTap: () {
                    controller.goToContact();
                  },
                  child: Text("Ajouter un contact", style: linkStyleBold),
                ),
              )
            ],
          )));
    }

    controller.users.forEach((user) {
      users.add(Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    userThumbIconEmpty(user["photo"], 40.0,
                        Icons.person_outline_outlined, 16.0),
                    UIHelper.horizontalSpace(10),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user["name"],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
                    Container(
                      width: 70,
                      alignment: Alignment.topRight,
                      child: _status(controller, user),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
    });
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: users,
          ),
          controller.hasMoreResults
              ? controller.loadingMoreUser
                  ? BBloader()
                  : GestureDetector(
                      onTap: () {
                        controller.loadMore();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          'Afficher plus de résultats',
                          style: smallText,
                        ),
                      ),
                    )
              : Container()
        ],
      ),
    );
  }

  _status(AddThreadController controller, user) {
    if (controller.userIsInListToAdd(user['id']) || user['isParticipant']) {
      return GestureDetector(
        onTap: () {
          controller.removeUser(user['id']);
        },
        child: Icon(
          Icons.check,
          color: fontGrey,
          size: 19,
        ),
      );
    } else {
      return GestureDetector(
          onTap: () {
            controller.addParticipant(user['id']);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: controller.threadType == 'simple'
                ? Icon(ElhIcons.share, color: primaryColor, size: 22)
                : Text('Ajouter', style: linkStyle),
          ));
    }
  }

  _threadTypeChoice(AddThreadController controller) {
    List<Widget> options = [];
    controller.threadTypeChoices.forEach((threadTypeChoice) {
      var icon = threadTypeChoice['val'] == 'simple'
          ? Icons.person_outline_outlined
          : Icons.group_outlined;
      options.add(GestureDetector(
          onTap: () {
            controller.setThreadType(threadTypeChoice['val']);
          },
          child: CardOption(icon, threadTypeChoice['title'],
              threadTypeChoice['description'])));
    });
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: options,
    );
  }
}

class CardOption extends StatelessWidget {
  final icon;
  final title;
  final description;
  const CardOption(this.icon, this.title, this.description);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              this.icon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Icon(
                        this.icon,
                        color: fontGrey,
                      ),
                    )
                  : Container(),
              Flexible(
                  child: Text(
                this.title,
                style: TextStyle(
                    fontSize: 15.0,
                    color: fontDark,
                    fontWeight: FontWeight.w900),
              )),
            ],
          ),
          UIHelper.verticalSpaceSmall(),
          Text(
            this.description,
            style: textDescription,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Icon(Icons.add_circle_outline)],
          )
        ],
      ),
    );
  }
}
