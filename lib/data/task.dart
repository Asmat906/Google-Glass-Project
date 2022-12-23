import 'dart:convert';

import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_glass_app/data/client.dart';
import 'package:google_glass_app/data/email.dart';
import 'package:google_glass_app/data/task_material.dart';
import 'package:intl/intl.dart';

import '../utils.dart';
import 'expert.dart';

class Task {
  String id = "";
  String todo = "";
  int duration = 0;
  DateTime startTime;
  String date  = "";

  DateTime emailSendDT;

  Client client;
  List<TaskMaterial> listTaskMaterial = [];
  List<Expert> listExpert = [];

  static  FlutterSecureStorage storage;

  String jsonString = "";

  //fetch emails with jobs for today!
  //save them for today

  static Future<List<Task>> fetchTasksFromInbox(DateTime dt) async {
    Map<String, Task> mapOfTasks = {};
    Email emailCredentials = Email();
    await emailCredentials.fetchEmailCredentials();
    final client = ImapClient(isLogEnabled: false);
    try {
      await client.connectToServer(emailCredentials.imap, int.parse(emailCredentials.imapPort), isSecure: true);
      await client.login(emailCredentials.email, emailCredentials.password);
      final mailboxes = await client.listMailboxes();
      await client.selectInbox();
      SearchImapResult sir = await client.searchMessagesWithQuery(SearchQueryBuilder.from("[${dt.year}.${dt.month}.${dt.day}]", SearchQueryType.subject));
      for (var id in sir.matchingSequence.toList()) {
        FetchImapResult fir = await client.fetchMessage(id, "BODY[]");
        String str = fir.messages[0].parts[0].decodeContentText().replaceAll("\r", "").replaceAll("\n", "");
        debugPrint(str);
        String receiver = getReceiverFromHeaders(fir.messages[0].headers);
        bool deletion = isDeletion(fir.messages[0].headers);
        String user = Utils.userName;

        if(receiver == user)
        {
          Task newTask = Task.parseTaskJson(str);
          newTask.emailSendDT = getEmailSendDateTimeFromHeaders(fir.messages[0].headers);
          if (mapOfTasks.containsKey(newTask.id)) {
            Task alreadyExistingTask = mapOfTasks[newTask.id];

            if (alreadyExistingTask.emailSendDT.compareTo(newTask.emailSendDT) < 0) {
              mapOfTasks[newTask.id] = newTask;
            }
          } else {
            mapOfTasks[newTask.id] = newTask;
          }

          if(deletion)
            mapOfTasks.remove(newTask.id);
        }
      }
      // FetchImapResult fir = await client.fetchMessages(sir.matchingSequence, "BODY[]");
      // for (MimeMessage message in fir.messages){
      //   debugPrint(message.parts[0].decodeContentText());
      // }
      // final fetchResult = await client.fetchRecentMessages(messageCount: 10, criteria: 'BODY.PEEK[]');

      await client.logout();
    } on ImapException catch (e) {
      print('IMAP failed with $e');
    }
    //sort by time
    List<Task> listOfTasks = mapOfTasks.values.toList();
    listOfTasks.sort((Task a, Task b) {
      return a.startTime.compareTo(b.startTime);
    });
    return listOfTasks;
  }

  static Task parseTaskJson(String jsonString) {
    dynamic d = JsonDecoder().convert(jsonString);
    Task t = Task();
    t.jsonString = jsonString;

    return fromJson(t, d);
  }

  static Task fromJson(Task t, dynamic d) {
    t.id = d['id'];
    t.startTime = DateTime.parse(d['startTime']);
    t.duration = int.parse(d['duration']);
    t.todo = d['todo'];
    t.date = DateFormat('dd.MM.yyyy').format(DateTime.parse(d['startTime']));

    t.client = Client.createFromJson(d['client']);

    if (d['hits'] != null) {
      print("><<>><<>><><><<>hits><<>><${d['hits']}");
      for (dynamic hit in d['hits']) {
        t.listTaskMaterial.add(TaskMaterial.createFromJson(hit));
      }
    }

    if (d['Expert'] != null) {
      print("><<>><<>><><><<>EXPERTTTT><<>><${d['Expert']}");
      for (dynamic hit in d['Expert']) {
        t.listExpert.add(Expert.createFromJson(hit));
      }
    }

    return t;
  }

  static DateTime getEmailSendDateTimeFromHeaders(List<Header> headers) {
    for (Header h in headers) {
      if (h.lowerCaseName == "date") {
        DateTime dt = DateFormat('E, d MMM yyyy HH:mm:ss Z', 'en_US').parse(h.value);
        // Wed, 18 Aug 2021 01:02:50 +0200
        debugPrint(dt.toString());
        return dt;
      }
    }
    return null;
  }

  static String getReceiverFromHeaders(List<Header> headers) {
    for (Header h in headers) {
      if (h.lowerCaseName == "to") {
        String header = h.toString();
        //debugPrint(header.substring(5,10));
        debugPrint(header.substring(header.indexOf("\"")+1,header.lastIndexOf("\"")));
        return header.substring(header.indexOf("\"")+1,header.lastIndexOf("\""));
      }
    }
    return null;
  }

  static bool isDeletion(List<Header> headers) {
    for (Header h in headers) {
      if (h.lowerCaseName == "subject") {
        String header = h.toString();
        //debugPrint(header.substring(5,10));
        if(header.endsWith("del"))
          return true;
        else
          return false;
      }
    }
    return null;
  }
}
