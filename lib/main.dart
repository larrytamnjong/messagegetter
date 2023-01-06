import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SmsQuery _query = SmsQuery();
  List<SmsMessage> _messages = [];
  bool valid = false;

  @override
  void initState() {
    super.initState();
    print(_messages);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Read MoMo Messages'),
        ),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _messages.length,
            itemBuilder: (BuildContext context, int i) {
              var message = _messages[i];
              if (message.sender!.contains('MobileMoney') &&
                  message.body!.contains('A transaction ')) {
                valid = true;
              } else {
                valid = false;
              }
              return ListTile(
                title: Text('${message.sender} [${message.date}]'),
                subtitle: Column(
                  children: [
                    Text('${message.body} '),
                    Text(
                      '$valid',
                      style:
                          TextStyle(color: valid ? Colors.green : Colors.red),
                    ),
                    Divider()
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var permission = await Permission.sms.status;
            if (permission.isGranted) {
              final messages = await _query.querySms(
                kinds: [SmsQueryKind.inbox],
                address: '',
                count: _messages.length,
              );
              debugPrint('sms inbox messages: ${messages.length}');

              setState(() => _messages = messages);
            } else {
              await Permission.sms.request();
            }
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}
