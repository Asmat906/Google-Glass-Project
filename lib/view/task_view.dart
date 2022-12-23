import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_glass_app/consts.dart';
import 'package:google_glass_app/data/task.dart';
import 'package:google_glass_app/utils.dart';
import 'package:google_glass_app/view/task_detail_view.dart';
import 'package:intl/intl.dart';

class TaskView extends StatefulWidget {
  List<Task> listOfTasks = [];

  TaskView(this.listOfTasks);

  @override
  State<StatefulWidget> createState() {
    return _taskViewState();
  }
}

class _taskViewState extends State<TaskView> {
  bool currentSlotSet = false;
  int selectedIndex = 0;
  int newSelectedIndex = -1;
  final Color myGray = Color.fromARGB(255, 100, 100, 100);
  String userName = "";
  ScrollController _scrollController = ScrollController();

  double dragHorizontalStartPosition = 0;

  double dragVerticalStartPosition = 0;
  double dragVerticalEndPosition = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLOR_BLUE,
      appBar: AppBar(
        backgroundColor: COLOR_BLUE,
        centerTitle: true,
        title: Text("Aufträge - ${Utils.userName}"),
      ),
      body: Stack(children: [
        ListView(
          controller: this._scrollController,
          padding: EdgeInsets.all(10),
          children: getTasks(),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (details) {
            dragHorizontalStartPosition = details.globalPosition.dx;
          },
          onHorizontalDragUpdate: (details) {
            var distance = details.globalPosition.dx - this.dragHorizontalStartPosition;

            int newCalculatedIndex = selectedIndex - (distance / 50).floor();
            if (newCalculatedIndex < 0) {
              newCalculatedIndex = 0;
            } else if (newCalculatedIndex > this.widget.listOfTasks.length - 1) {
              newCalculatedIndex = this.widget.listOfTasks.length - 1;
            }

            if (newCalculatedIndex != newSelectedIndex) {
              newSelectedIndex = newCalculatedIndex;
              this._scrollController.animateTo(
                this.newSelectedIndex * 108.0,
                duration: Duration(milliseconds: 350),
                curve: Curves.linear,
              );
              // this.scrollCtrl.jumpTo(newSelectedIndex * 38.0);
              setState(() {});
            }
          },
          onHorizontalDragEnd: (details) {
            selectedIndex = newSelectedIndex;
            newSelectedIndex = -1;
            setState(() {});
          },
          onVerticalDragStart: (details) {
            this.dragVerticalStartPosition = details.globalPosition.dy;
            // debugPrint("$dragVerticalStartPosition");
          },
          onVerticalDragUpdate: (details) {
            this.dragVerticalEndPosition = details.globalPosition.dy;
            // debugPrint("$dragVerticalEndPosition");
          },
          onVerticalDragEnd: (_) {
            // debugPrint((this.dragVerticalStartPosition - this.dragVerticalEndPosition).toString());
            if ((this.dragVerticalStartPosition - this.dragVerticalEndPosition) < -80) {
              Navigator.pop(context);
            }
          },
          onTap: () {
            if (this.widget.listOfTasks.isNotEmpty){
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => TaskDetailView(this.widget.listOfTasks[selectedIndex])));
            }
          },
        ),
      ]),
    );
  }

  List<Widget> getTasks() {
    currentSlotSet = false;
    DateTime now = DateTime.now();
    List<Widget> w = [];
    for (int i = 0; i < this.widget.listOfTasks.length; i++) {
      Task t = this.widget.listOfTasks[i];
      w.add(Card(
        color: getColor(now, t, i),
        elevation: 5,
        borderOnForeground: false,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getIcon(now, t),
                ],
              ),
              SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      myDTFormat(t.startTime, t.duration),
                      style: TextStyle(
                        color: getTextColor(now, t, i),
                        fontSize: 25,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      t.todo,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: getTextColor(now, t, i),
                        fontSize: 25,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      t.client.name + ", " + t.client.address,
                      style: TextStyle(
                        color: getTextColor(now, t, i),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
    }

    return w;
  }

  String myDTFormat(DateTime dt, int duration) {
    return DateFormat("HH:mm").format(dt) + " - " + DateFormat("HH:mm").format(dt.add(Duration(minutes: duration)));
  }

  Color getColor(DateTime now, Task t, int index) {
    if (index == selectedIndex) {
      if ((t.startTime.compareTo(now) <= 0) && (t.startTime.add(Duration(minutes: t.duration)).compareTo(now) >= 0)) {
        currentSlotSet = true;
      }
      return COLOR_YELLOW;
    }
    if (index == newSelectedIndex) {
      if ((t.startTime.compareTo(now) <= 0) && (t.startTime.add(Duration(minutes: t.duration)).compareTo(now) >= 0)) {
        currentSlotSet = true;
      }

      return COLOR_RED;
    }
    if (t.startTime.compareTo(now) <= 0) {
      if (t.startTime.add(Duration(minutes: t.duration)).compareTo(now) >= 0) {
        currentSlotSet = true;
        return COLOR_GREEN;
      } else {
        return COLOR_PURPLE;
      }
    } else {
      if (!currentSlotSet) {
        currentSlotSet = true;
        return COLOR_GREEN;
      } else {
        return COLOR_ORANGE;
      }
    }
  }

  Icon getIcon(DateTime now, Task t) {
    IconData id = Icons.circle;
    if (t.startTime.add(Duration(minutes: t.duration)).compareTo(now) >= 0) {
      id = Icons.circle_outlined;
    }
    return Icon(id, color: Colors.black);
  }

  Color getTextColor(DateTime now, Task t, int index) {
    if (selectedIndex == index) {
      return Colors.black;
    }
    if (newSelectedIndex == index) {
      return Colors.white;
    }
    if (t.startTime.add(Duration(minutes: t.duration)).compareTo(now) >= 0) {
      return Colors.white;
    }
    return Colors.grey;
  }
}
