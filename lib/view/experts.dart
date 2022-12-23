import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_glass_app/data/task.dart';
import 'package:google_glass_app/view/model.dart';
class ExpertsOverview extends StatefulWidget {
  List expertiesList;
 
  Task task;
   ExpertsOverview({
    Key key,
    this.expertiesList,this.task
  }) : super(key: key);

  @override
  State<ExpertsOverview> createState() => _ExpertsOverviewState();
}

class _ExpertsOverviewState extends State<ExpertsOverview> {
  @override
   bool selected = false;
   var selection;
   ScrollController scrollCtrl;
double dragHorizontalStartPosition = 0;

  double dragVerticalStartPosition = 0;
  double dragVerticalEndPosition = 0;

  int selectedIndex = 0;
  int newSelectedIndex = -1;
@override
  void initState() {
    super.initState();
    // fetchDirectoryEntries();
    scrollCtrl = ScrollController();
  }
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(title: Text("Experts List")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 295,
            child: Stack(
              children: [
                ListView.builder(
                   controller: this.scrollCtrl,
                  itemCount: widget.expertiesList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: Text(
                        widget.expertiesList[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: newSelectedIndex == index
                            ? Colors.white
                            : selectedIndex == index
                            ? Colors.black
                            : Colors.white,
                          ),
                      ),
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      color: newSelectedIndex == index
                      ? Colors.red
                      : selectedIndex == index
                      ? Colors.yellow
                      : Colors.blue,
                    );
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragStart: (details) {
                        dragHorizontalStartPosition = details.globalPosition.dx;
                      },
                      onHorizontalDragUpdate: (details) {
                        var distance = details.globalPosition.dx - this.dragHorizontalStartPosition;

                        int newCalculatedIndex = selectedIndex -
                            (distance / 50).floor();
                        if (newCalculatedIndex < 0) {
                          newCalculatedIndex = 0;
                        } else if (newCalculatedIndex > widget.expertiesList.length - 1) {
                          newCalculatedIndex = widget.expertiesList.length - 1;
                        }

                        if (newCalculatedIndex != newSelectedIndex) {
                          newSelectedIndex = newCalculatedIndex;
                          this.scrollCtrl.animateTo(
                            this.newSelectedIndex * 38.0,
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
                        if ((this.dragVerticalStartPosition -
                            this.dragVerticalEndPosition) < -80) {
                          Navigator.pop(context);
                        }
                      },
                    onTap: (){
                      selection=widget.expertiesList[selectedIndex];
                       List strarray1=[];List ddd=[];
                    },
            
                    ),
                  ),
    
              ],
            ),
          )
       ],)
    
    );
  
  }
  
}



