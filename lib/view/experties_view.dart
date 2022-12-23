import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_glass_app/data/task.dart';
import 'package:google_glass_app/view/experts.dart';
import 'package:google_glass_app/view/model.dart';
class ExpertiesOverview extends StatefulWidget {
  List expertiesList;
  List expertsList;
  Task task;
   ExpertiesOverview({
    Key key,
    this.expertiesList,this.expertsList,this.task
  }) : super(key: key);

  @override
  State<ExpertiesOverview> createState() => _ExpertiesOverviewState();
}

class _ExpertiesOverviewState extends State<ExpertiesOverview> {
  @override
   bool selected = false;
   bool tapped=false;
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
      appBar: AppBar(title: Text("Experties List")),
      body:Column(
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
                        var distance = details.globalPosition.dx -
                            this.dragHorizontalStartPosition;

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
                      setState(() {
                        tapped=true;
                    });
                    selection=widget.expertiesList[selectedIndex];
                    List strarray1=[];List ddd=[];
                    for(int i=0;i<widget.expertsList.length;i++){
                      String jkkk=widget.expertsList[i]['expertId'];
                      String hhhh;
                      hhhh = jkkk.replaceAll("[", " ");
                      hhhh = hhhh.replaceAll("]", " ");
                      List result = hhhh.split(',');
                      List kk;
                      for(int c=0;c<result.length;c++){
                        if( result[c].contains(selection)){
                        strarray1.add('${widget.expertsList[i]['name']}' " " + '${widget.expertsList[i]['lastNmae']}');
                      }

                    }
                 
                  }
                  print("??????????,,,,,,,222222222<<<<<<MMMMMMM<<<<<<$strarray1");
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => ExpertsOverview(expertiesList:strarray1,),)
                  );
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
 






