// ignore_for_file: prefer_const_constructors, avoid_print
import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:shared_preferences_android/shared_preferences_android.dart';
// import 'package:shared_preferences_ios/shared_preferences_ios.dart';

// var a;
// var b;
// int callTypeOne = 0;
// int callTypeTwo = 0;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeBackgroundService();
  runApp(Home());
}

void initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}

Future<void> insert() async {
  var count = 0;
  var t = 0;
  final fb = FirebaseDatabase.instance;
  final Iterable<CallLogEntry> cLog = await CallLog.get();
  print('Queried call log entries');
  for (CallLogEntry entry in cLog) {
    final ref = fb.ref('call_log/$count');
    count++;
    ref.set({
      "name": '${entry.name}',
      "number": '${entry.number}',
      "type": '${entry.callType}',
      "duration": '${entry.duration}',
      "operator": '${entry.simDisplayName}',
    }).asStream();
    t++;
    if (t == 25) {
      return;
      // exit;
      // exitCode;
    }
  }
}

@pragma('vm:entry-point')
onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
      insert();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
//Some code for background task
  // Timer.periodic(const Duration(seconds: 10), (timer) async {
  // if (service is AndroidServiceInstance) {
  //   service.setForegroundNotificationInfo(
  //     title: "App in background...",
  //     content: "Update ${DateTime.now()}",
  //   );
  // }
  //   service.invoke(
  //     'update',
  //     {
  //       "current_date": DateTime.now().toIso8601String(),
  //     },
  //   );
  // });

  Timer.periodic(const Duration(seconds: 10), (timer) async {
    insert();
    // var count = 0;
    // var t = 0;

    // final fb = FirebaseDatabase.instance;
    // final Iterable<CallLogEntry> cLog = await CallLog.get();
    // print('Queried call log entries');
    // for (CallLogEntry entry in cLog) {
    //   DatabaseReference ref = FirebaseDatabase.instance.ref('call_log/$count');
    //   // setState(() {
    //   //   count++;
    //   // });
    //   count++;
    //   ref.set({
    //     "name": '${entry.name}',
    //     "number": '${entry.number}',
    //     "type": '${entry.callType}',
    //     "duration": '${entry.duration}',
    //     "operator": '${entry.simDisplayName}',
    //   }).asStream();
    //   // setState(() {
    //   //   t++;
    //   // });
    //   t++;
    //   if (t == 12) {
    //     return;
    //   }
    // }
    // for (CallLogEntry entry in cLog) {
    //   // DatabaseReference ref = FirebaseDatabase.instance.ref('call_log/$count');
    //   final ref = fb.ref('call_log/$count');
    //   // setState(() {
    //   //   count++;
    //   // });
    //   count++;
    //   ref.set({
    //     "name": '${entry.name}',
    //     "number": '${entry.number}',
    //     "call type": '${entry.number}',
    //     "duration": '${entry.duration}',
    //     "sim name": '${entry.simDisplayName}',
    //   }).asStream();
    // }
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  Iterable<CallLogEntry> _callLogEntries = <CallLogEntry>[];
  // late List<Operator> _operator;
  List<Operator> Op = [];
  // var count = 0;
  data stats = data('aa', 'bb', 0, 1);
  void postData() {}

  // var a;
  // var b;
  // int callTypeOne = 0;
  // int callTypeTwo = 0;
  // int test = 0;
  // List<dynamic> stats = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    setState(() {
      statistics();
      // print('init setstates $stats');
      asyncOperation();
      // print('init setstates $_callLogEntries');
      // _operator = getOperator();
      getOperator(Op);
    });
  }

  Future<Iterable<CallLogEntry>> results() async {
    Iterable<CallLogEntry> result = await CallLog.get();
    return result;
  }

  // aValue() {
  //   return stats.a;
  // }

  // bValue() {
  //   return stats.b;
  // }

  // callOneTypeValue() {
  //   return stats.callTypeOne;
  // }

  // callTwoTypeValue() {
  //   return stats.callTypeTwo;
  // }

  Future<data> statistics() async {
    var a;
    var b;
    int callTypeOne = 0;
    int callTypeTwo = 0;
    int test = 0;
    data r;
    Iterable<CallLogEntry> result = await results();
    for (CallLogEntry entry in result) {
      if (test == 0) {
        a = entry.simDisplayName;
        test++;
      }

      if (entry.simDisplayName == a) {
        callTypeOne++;
        // print('infos 1 : $a $callTypeOne');
      } else {
        b = entry.simDisplayName;
        callTypeTwo++;

        // print('infos : $b $callTypeTwo');
      }
    }
    setState(() {
      stats = data(a, b, callTypeOne, callTypeTwo);
    });
    return stats;
  }

  Future<Iterable<CallLogEntry>> asyncOperation() async {
    Iterable<CallLogEntry> result = await CallLog.get();
    setState(() {
      _callLogEntries = result;
    });
    return _callLogEntries;
  }

  String formatDate(DateTime dt) {
    return DateFormat('d-MMM-y H:m:s').format(dt);
  }

  String formatDay(DateTime dt) {
    return DateFormat('dd-MMM-y').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];

    // [
    //   Operator('${stats.a}', stats.callTypeOne),
    //   Operator('${stats.b}', stats.callTypeTwo),
    // ];

    for (CallLogEntry entry in _callLogEntries) {}

    for (CallLogEntry entry in _callLogEntries) {
      bool bo = false;
      var day;

      if (bo == false) {
        day = formatDay(DateTime.fromMillisecondsSinceEpoch(entry.timestamp!));
      }

      if (formatDay(DateTime.fromMillisecondsSinceEpoch(entry.timestamp!)) ==
          day) {
        children.add(
          GestureDetector(
            child: Column(
              children: [
                // Text(day),
                Card(
                  child: ListTile(
                    leading: Text('${entry.simDisplayName}'),
                    title: Text('${entry.name}'),
                    subtitle: Text(
                        '${formatDate(DateTime.fromMillisecondsSinceEpoch(entry.timestamp!))} \n ${entry.duration}s \n ${stats.b} ${stats.callTypeTwo} and ${stats.callTypeOne}'),
                  ),
                ),
              ],
            ),
          ),
        );
        bo = true;
      } else {
        children.add(
          GestureDetector(
            child: Column(
              children: [
                Text(formatDay(
                    DateTime.fromMillisecondsSinceEpoch(entry.timestamp!))),
                Card(
                  child: ListTile(
                    leading: Text('${entry.simDisplayName}'),
                    title: Text('${entry.name}'),
                    subtitle: Text(
                        '${formatDate(DateTime.fromMillisecondsSinceEpoch(entry.timestamp!))} \n ${entry.duration}s \n ${entry.simDisplayName} \n ${stats.a} ${entry.timestamp} \n ${stats.b} ${stats.callTypeTwo}and ${stats.callTypeOne}'),
                  ),
                ),
              ],
            ),
          ),
        );
        bo = false;
      }

      // children.add(
      //   GestureDetector(
      //     child: Column(
      //       children: [
      //         Text(formatDay(
      //             DateTime.fromMillisecondsSinceEpoch(entry.timestamp!))),
      //         Card(
      //           child: ListTile(
      //             leading: Text('${entry.simDisplayName}'),
      //             title: Text('${entry.name}'),
      //             subtitle: Text(
      //                 '${formatDate(DateTime.fromMillisecondsSinceEpoch(entry.timestamp!))} \n ${entry.duration}s \n ${entry.simDisplayName} \n ${stats.a} ${entry.timestamp} \n ${stats.b} ${stats.callTypeTwo}and ${stats.callTypeOne}'),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // );

      Op = [
        Operator('${stats.a}', stats.callTypeOne),
        Operator('${stats.b}', stats.callTypeTwo),
      ];
    }

    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Call Log App'),
            centerTitle: true,
            bottom: TabBar(
              // ignore: prefer_const_literals_to_create_immutables
              tabs: [
                Tab(
                  icon: Icon(Icons.recent_actors_sharp),
                  text: 'Recents',
                ),
                Tab(
                  icon: Icon(Icons.details),
                  text: 'Details',
                ),
                Tab(
                  icon: Icon(Icons.query_stats),
                  text: 'Statistics',
                ),
                Tab(
                  icon: Icon(Icons.contact_phone),
                  text: 'Contacts',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              FutureBuilder(
                future: asyncOperation(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    Iterable<CallLogEntry> result =
                        snapshot.data as Iterable<CallLogEntry>;
                    _callLogEntries = result;

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(children: children),
                      ),
                    );
                  } else {
                    Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: children),
                    ),
                  );
                },
              ),
              // SingleChildScrollView(
              //   child: Column(children: children.map((e) => e).toList()
              //       // [
              //       // Card(
              //       //   child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //       //       // ignore: prefer_const_literals_to_create_immutables
              //       //       children: <Widget>[
              //       //         Text('Dates'),
              //       //         Text('nombres appel'),
              //       //         Text('temps total'),
              //       //       ]),
              //       // ),
              //       // Column(children: <Widget>[
              //       //   Row(
              //       //     // ignore: prefer_const_literals_to_create_immutables
              //       //     children: <Widget>[
              //       //       Text('operateur'),
              //       //       SizedBox(
              //       //         width: 10.0,
              //       //       ),
              //       //       Text('Type d\'appel'),
              //       //       SizedBox(
              //       //         width: 10.0,
              //       //       ),
              //       //       Text('duree'),
              //       //     ],
              //       //   )
              //       // ])
              //       // ]
              //       ),
              // ),
              Center(
                child: Text('hey'),
              ),
              FutureBuilder(
                future: statistics(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // data myData = snapshot.data as data;
                    // stats = myData;
                    // statistics();
                    Iterable<CallLogEntry> result =
                        snapshot.data as Iterable<CallLogEntry>;
                    _callLogEntries = result;

                    return SfCartesianChart(
                      series: <ChartSeries>[
                        BarSeries<Operator, String>(
                            dataSource: getOperator(Op),
                            xValueMapper: (Operator optr, _) => optr.name,
                            yValueMapper: (Operator optr, _) =>
                                optr.numberOfCalls)
                      ],
                      primaryXAxis: CategoryAxis(),
                    );
                  } else {
                    Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return SfCartesianChart(
                    series: <ChartSeries>[
                      BarSeries<Operator, String>(
                          dataSource: getOperator(Op),
                          xValueMapper: (Operator optr, _) => optr.name,
                          yValueMapper: (Operator optr, _) =>
                              optr.numberOfCalls)
                    ],
                    primaryXAxis: CategoryAxis(),
                  );
                },
              ),
              Center(
                child: Text('hey'),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // var t = 0;
              // Workmanager().registerPeriodicTask('2', 'call_logs',
              //     frequency: Duration(minutes: 15));
              // for (CallLogEntry entry in _callLogEntries) {
              //   DatabaseReference ref =
              //       FirebaseDatabase.instance.ref('call_log/$count');
              //   setState(() {
              //     count++;
              //   });
              //   ref.set({
              //     "name": '${entry.name}',
              //     "number": '${entry.number}',
              //     "type": '${entry.callType}',
              //     "duration": '${entry.duration}',
              //     "operator": '${entry.simDisplayName}',
              //   }).asStream();
              //   setState(() {
              //     t++;
              //   });
              //   if (t == 12) {
              //     return;
              //     // exit;
              //     // exitCode;
              //   }
              // }

              Platform.isAndroid
                  ? () async {
                      await Workmanager().registerPeriodicTask(
                        '2',
                        'call_logs',
                        initialDelay: Duration(seconds: 10),
                      );
                      print('fb');
                    }
                  : null;
            },
            child: Icon(Icons.numbers),
          ),
        ),
      ),
      // ),
    );
  }

  List<Operator> getOperator(List<Operator> operator) {
    // List<Operator> operator = [
    //   Operator('${stats.a}', stats.callTypeOne),
    //   Operator('${stats.b}', stats.callTypeTwo),
    // ];
    return operator;
  }
}

class Durations {
  String call;
  double duration;

  Durations(this.call, this.duration);
}

class Operator {
  String name;
  int numberOfCalls;

  Operator(this.name, this.numberOfCalls);
}

class data {
  var a;
  var b;
  int callTypeOne = 0;
  int callTypeTwo = 0;
  data(this.a, this.b, this.callTypeOne, this.callTypeTwo);
}
