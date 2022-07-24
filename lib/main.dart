import 'dart:convert';
import 'dart:ffi';
// import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_sensor/PushNotification.dart';
import 'package:overlay_support/overlay_support.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Contact List'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _currentIndex = 0;

  List myTabIndex = [myapp(), mytextfield()];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: OverlaySupport(child: myTabIndex[_currentIndex], ),
      // Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       const Text(
      //         'You have pushed the button this many times:',
      //       ),
      //       Text(
      //         '$_counter',
      //         style: Theme.of(context).textTheme.headline4,
      //       ),
      //       IconButton(
      //           onPressed: () {},
      //           icon: Icon(
      //             Icons.home,
      //           ))
      //     ],
      //   ),
      // ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone),
            label: 'Call',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.contact_mail),
          //   label: 'Contact',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.home_filled),
          //   label: 'home',
          // ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        unselectedItemColor: Colors.pink,
        selectedItemColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class myapp extends StatefulWidget {
  const myapp({Key? key}) : super(key: key);

  @override
  State<myapp> createState() => _myappState();
}

class _myappState extends State<myapp> {

  late int? _totalNotifications;

  @override
  void initState() {
    _totalNotifications = 0;
    super.initState();
  }



  List mylist = [];

  void getData() async {
    var data = await http
        .read(Uri.parse("https://jsonplaceholder.typicode.com/users"));
    setState(() {
      mylist.add(jsonDecode(data));
    });
    // mylist.clear();
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return ListView.builder(
        itemCount: mylist[0].length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(mylist[0][index]['name']),
            subtitle: Text(mylist[0][index]['email']),
            leading: GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Center(
                          child: Container(
                            child: Text(
                              mylist[0][index]["name"]
                                  .toString()
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        backgroundColor: Colors.blue,
                      );
                    });
              },
              child: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                width: 48,
                height: 48,

                child: Center(
                  child: Text(
                    mylist[0][index]['name']
                        .toString()
                        .substring(0, 1)
                        .toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                // Text(mylist[0][index]['name']
                //     .toString()
                //     .substring(0, 1)
                //     .toUpperCase(), style: TextStyle(backgroundColor: Colors.amber),),
              ),
            ),
          );
        });
  }
}

// textfield

class mytextfield extends StatefulWidget {
  const mytextfield({Key? key}) : super(key: key);

  @override
  State<mytextfield> createState() => _mytextfieldState();
}

class _mytextfieldState extends State<mytextfield> {
  var db = FirebaseFirestore.instance;

  final myFirstName = TextEditingController();
  final mylastName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  
  var _totalNotifications;
   late final FirebaseMessaging _messaging;
     PushNotification? _notificationInfo;
  
  void registerNotification() async {
  // 1. Initialize the Firebase app
  await Firebase.initializeApp();

  // 2. Instantiate Firebase Messaging
  _messaging = FirebaseMessaging.instance;

@override
  void dispose() {
    // TODO: implement dispose

    myFirstName.dispose();
    mylastName.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }
  // 3. On iOS, this helps to take the user permissions
  NotificationSettings settings = await _messaging.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Parse the message received
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );
      
        if (_notificationInfo != null) {
        // For displaying the notification as an overlay
        showSimpleNotification(
          Text(_notificationInfo!.title!),
          leading: NotificationBadge(totalNotifications: _totalNotifications),
          subtitle: Text(_notificationInfo!.body!),
          background: Colors.cyan.shade700,
          duration: Duration(seconds: 2),
        );
        
      }

      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    });
  } else {
    print('User declined or has not accepted permission');
  }
}
Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}



  

  void getAllData() {
    var data = {
      "FirstName": myFirstName.text.trim(),
      "LastName": mylastName.text.trim(),
      "email": email.text.trim(),
      "password": password.text.trim()
    };

    print(data);
    db.collection('userhistory').add(data).then((DocumentReference doc) =>
        print('DocumentSnapshot added with ID: ${doc.id}'));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        
        _notificationInfo != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TITLE: ${_notificationInfo!.title}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'BODY: ${_notificationInfo!.body}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                )
              : Container(),
        
        SizedBox(
          height: 10,
          width: 40,
        ),
           Text(
            'App for capturing Firebase Push Notifications',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 16.0),
          NotificationBadge(totalNotifications: _totalNotifications),
          SizedBox(height: 16.0),
     

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              
              
              
              
              
             
                
             
              
              
              Container(
                child: Center(
                  child: Text(
                    'Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                width: 100,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.blue,
                ),
              ),
              SizedBox(
                height: 10,
                width: 40,
              ),
              Container(
                child: Center(
                  child: Text(
                    'Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                width: 100,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.blue,
                ),
              ),
              SizedBox(
                height: 10,
                width: 40,
              ),
              Container(
                child: Center(
                  child: Text(
                    'Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                width: 100,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.blue,
                ),
              ),
              SizedBox(
                height: 10,
                width: 40,
              ),
              Container(
                child: Center(
                  child: Text(
                    'Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                width: 100,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.blue,
                ),
              ),
              SizedBox(
                height: 10,
                width: 40,
              ),
            ],
          ),
        ),
        Container(
          child: TextField(
            controller: myFirstName,
            decoration: InputDecoration(
                hintText: 'Enter your first name',
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                labelText: 'Enter your first name',
                icon: Icon(Icons.person)),
          ),
          width: 350,
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          child: TextField(
            controller: mylastName,
            decoration: InputDecoration(
                hintText: 'Enter your last name',
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                labelText: 'Enter your last name',
                icon: Icon(Icons.person)),
          ),
          width: 350,
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          child: TextField(
            controller: email,
            decoration: InputDecoration(
                hintText: 'Enter your email',
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                labelText: 'Enter your email',
                icon: Icon(Icons.email)),
          ),
          width: 350,
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          child: TextField(
            
            controller: password,
            obscureText: true,
            decoration: InputDecoration(
                hintText: 'Enter your password',
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                labelText: 'Enter your password',
                icon: Icon(Icons.lock),
                suffixIcon: Icon(Icons.remove_red_eye_rounded)),
          ),
          width: 350,
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          child: TextButton(
              onPressed: getAllData,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
              ),
              child: Text(
                "Submit",
                style: TextStyle(color: Colors.white, fontSize: 17),
              )),
          width: 50,
        ),
      ],
    );
  }
}


class NotificationBadge extends StatelessWidget {
  final int? totalNotifications;

  const NotificationBadge({required this.totalNotifications});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: new BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$totalNotifications',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}