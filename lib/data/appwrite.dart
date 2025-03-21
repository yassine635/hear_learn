import 'package:appwrite/appwrite.dart';

class AppWrite {
  Client client = Client();
  //client.setProject('67dc0ea70005df138bad');
  AppWrite() {
    client
        .setEndpoint("https://cloud.appwrite.io/v1")
        .setProject("67dc0ea70005df138bad")
        .setSelfSigned(status: true);
  }
}
