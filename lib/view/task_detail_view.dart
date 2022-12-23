import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_glass_app/data/task.dart';
import 'package:google_glass_app/data/task_material.dart';
import 'package:google_glass_app/utils.dart';
import 'package:google_glass_app/video_listing.dart';
import 'package:google_glass_app/video_player.dart';
import 'package:google_glass_app/view/experties_view.dart';
import 'package:google_glass_app/view/model.dart';
import 'package:google_glass_app/view/pdf_view.dart';

import '../data/expert.dart';

class TaskDetailView extends StatefulWidget {
  Task task;

  TaskDetailView(this.task);

  @override
  State<StatefulWidget> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Ansicht - langer Tap für Zurück")),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          showFileListing();
        },
         onDoubleTap: (){
                   var Grooup2=[];
                   var ExpertList=[];
                  String jsonUser;
                  var newgfgList;
                  for ( int i=0;i< widget.task.listExpert.length;i++ ){
                    Experts user=Experts(widget.task.listExpert[i].firstName.toString(), widget.task.listExpert[i].lastName.toString(), widget.task.listExpert[i].email.toString(),widget.task.listExpert[i].expertField.toString(),widget.task.listExpert[i].lastName.toString(),);
                    jsonUser = jsonEncode(user);
                    
                    var j=jsonDecode(jsonUser); 
                    Grooup2.add(widget.task.listExpert[i].expertField);
                    ExpertList.add(j);
                  }
                  var kk =Grooup2.join(",");
                   var k =kk.toString();
                   k = k.replaceAll("[", " ");
                   k = k.replaceAll("]", " ");
                   k = k.replaceAll(" , ", ",");
                   k=k.trim();
                   List strarray = k.split(",");
                   var dddd=strarray;
                   var strarray1 = dddd.toSet().toList();
                Navigator.push(
               context,
               MaterialPageRoute(
               builder: (context) => ExpertiesOverview(expertiesList:strarray1,expertsList:ExpertList),
             ));
       
                  
                },
               
        onLongPress: () {
          Navigator.of(context).pop();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView(
            children: [
              SizedBox(height: 10),
              getBoldText('Datum:'),
              getText(this.widget.task.date),
              SizedBox(height: 10),
              getBoldText('Zeit:'),
              getText(Utils.myDTFormat(this.widget.task.startTime, this.widget.task.duration)),
              SizedBox(height: 10),
              getBoldText('Aufgabe:'),
              getText(this.widget.task.todo),
              SizedBox(height: 10),
              getBoldText('Kunde'),
              getText(this.widget.task.client.name),
              getText(this.widget.task.client.address),
              getText(this.widget.task.client.phone),
              getText(this.widget.task.client.email),
              SizedBox(height: 10),
              getBoldText('Auftragsnummer'),
              getText(this.widget.task.id),
              SizedBox(height: 10),
              GestureDetector(
                onTap: (){
                  
                },
                child: getBoldText('Experten')),
              getExperts(this.widget.task.listExpert),
              SizedBox(height: 10),
              getBoldText('Element(e) - Tap für Dateiansicht'),
              getMaterials(this.widget.task.listTaskMaterial),
            ],
          ),
        ),
      ),
    );
  }

  void showFileListing() async {
    
    List<String> gtinList = this.widget.task.listTaskMaterial.map((e) => e.gtin).toList();
    print("><><<><><>GGGGGGGGGGGGG<><><>GG><><><><><$gtinList");
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            VideoListing(
              listGtinFilter: gtinList,
            )));
    /*final result = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              VideoListing(
                listGtinFilter: gtinList,
              )));

      if ((result ?? "").length > 0) {
        if ((result as String).toLowerCase().endsWith(".pdf")) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => PDFViewer(result)));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => VideoPlayer(result, 0, isLocalFile: true)));
        }
      }*/

  }

  Widget getBoldText(String text) {
    return Text(text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ));
  }

  Widget getText(String text, {bool bold = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget getMaterials(List<TaskMaterial> ltm) {
    print("><<>><<><>ltmltmltmltmltmltmltmltm><<>><<>><$ltm");
    List<Widget> lw = [];
    for (var m in ltm) {
      lw.add(getText(m.manufacturer, bold: true));
      lw.add(getText(m.description));
      lw.add(getText(m.gtin));
      lw.add(SizedBox(height: 10));
    }
    return Column(
      children: lw,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget getExperts(List<Expert> lexp) {
    print("><<>><<><>BBBBBBBBBBBBBBBB><<>><<>><$lexp");
    List<Widget> lw = [];
    // for (var m in lexp) {
      for(int c=0;c<lexp.length;c++){
         print("><<>><<><>lexp.length><<>><<>><${lexp.length}");
         lw.add(getText("Name: " + lexp[c].firstName + " " + lexp[c].lastName+ " Email: " + lexp[c].email +" Expertenbereiche: "+ lexp[c].expertField.toString()));
      lw.add(SizedBox(height: 10));
      }
      
   // }
    return Column(
      children: lw,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}
