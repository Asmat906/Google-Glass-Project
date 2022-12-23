import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Email {
  FlutterSecureStorage storage = FlutterSecureStorage();

  String name = "";
  String email = "";
  String password = "";
  String imap = "";
  String imapPort = "";
  String smtp = "";
  String smtpPort = "";

  void fetchEmailCredentials() async {
    name = await storage.read(key: "name");
    email = await storage.read(key: "email");
    password = await storage.read(key: "password");
    imap = await storage.read(key: "imap");
    imapPort = await storage.read(key: "imapPort");
    smtp = await storage.read(key: "smtp");
    smtpPort = await storage.read(key: "smtpPort");
  }
}
