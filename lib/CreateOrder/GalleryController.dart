import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kaban/CreateOrder/flutter_spanablegrid.dart';
import 'package:flutter/cupertino.dart';
import 'package:kaban/Managers.dart';
import 'package:kaban/Styles.dart' as styles;

class GalleryController extends StatefulWidget {
  Task task;
  GalleryController( {Key key, this.title, this.task}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _GalleryControllerState createState() => _GalleryControllerState();
}

class _GalleryControllerState extends State<GalleryController> {
  List<String> images = [];
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
    images = widget.task.images;
    });
  }
  
 

  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        backgroundColor: styles.Colors.background,
        appBar: EmptyAppBar(),
        body: new Padding(
            padding: const EdgeInsets.all(4.0),
            child:
//            GridView.custom(
//              gridDelegate: new HomeGridDelegate(),
//              childrenDelegate: new HomeChildDelegate(),
//              padding: new EdgeInsets.all(12.0),
//            )

            GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
                maxCrossAxisExtent: MediaQuery.of(context).size.width - 50,//200
                  childAspectRatio: 0.5//2
              ),

              itemBuilder: (BuildContext context, int index){
                return Image(
      image: new FileImage(new File(widget.task.images[index]),
    )
                  );
              },
              itemCount: images.length,
            )
        ),

        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleAppBar;

  const EmptyAppBar({
    Key key,
    @required this.titleAppBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () async => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: 44,
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Color(0xFFC4C4C4),
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(100);
}

class HomeChildDelegate extends SliverChildDelegate {

  @override
  Widget build(BuildContext context, int index) {

    if(index >= 20)
      return null;

    Color color = Colors.red;

    if(index == 0)
      color = Colors.blue;
    else if(index == 1 || index == 10)
      color = Colors.cyan;
    else if(index < 10)
      color = Colors.green;

    return new Container(decoration: new BoxDecoration(color: color , shape: BoxShape.rectangle));
  }

  @override
  bool shouldRebuild(SliverChildDelegate oldDelegate) => true;

  @override
  int get estimatedChildCount => 20;
}

class HomeGridDelegate extends SpanableSliverGridDelegate {

  HomeGridDelegate() : super(2, mainAxisSpacing: 10.0, crossAxisSpacing: 10.0);

  @override
  int getCrossAxisSpan(int index) {

    if (index == 1)
      return 2;


    return 1;

  }

  @override
  double getMainAxisExtent(int index) {
    if(index == 0)
      return 170.0;

    if(index == 1)
      return 258.0;

    return 170.0;
  }
}
