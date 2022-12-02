// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Uri? deepLink;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Get any initial links
  final PendingDynamicLinkData? initLink = await FirebaseDynamicLinks.instance.getInitialLink();
  deepLink = initLink?.link;

  print('initLink=$initLink');
  print('deepLink=$deepLink');
  runApp(
    MaterialApp(
      title: 'Dynamic Links Example',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const MyApp(),
        '/helloworld': (BuildContext context) => _DynamicLinkScreen(),
      },
    ),
  );
}

class MyApp extends StatelessWidget {

  const MyApp({
    super.key
  });

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      // navigatorObservers: [
      //   FirebaseAnalyticsObserver(analytics: analytics),
      // ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
  }

  Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      Navigator.pushNamed(context, dynamicLinkData.link.path);
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:
        Center(
                child: ElevatedButton(
                  child: const Text('두번째로 가기'),
                  onPressed: () {
                    // Get.to(() => const ThirdRoute());
                    firebaseLogEvent('두번째로가기');
                    Navigator.of(context).push(CupertinoPageRoute(
                                      settings: const RouteSettings(name: '두번째_페이지_입니다'),
                                      builder: (context) => const SecondRoute())
                    );
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const SecondRoute()),
                    // );
                  },
                ),
        )
    );
  }
}

class SecondRoute extends StatefulWidget {
  const SecondRoute({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<SecondRoute> createState() => _SecondRoute();
}

class _SecondRoute extends State<SecondRoute> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body:
      Stack(
        children: <Widget>[
          Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
          Align(
            alignment: Alignment.topRight,
            child: ElevatedButton(
              onPressed: () {
                firebaseLogEvent('Increment_btn_clicked');
                _incrementCounter();
              },
              child: const Icon(Icons.add),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () {
                firebaseLogEvent('이전으로_가기');
                Navigator.pop(context);
              },
              child: const Text('Go back!'),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                firebaseLogEvent('웹뷰');
                runApp(const WebViewExample());
              },
              child: const Text('Web_View'),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                firebaseLogEvent('세번째로가기');
                Navigator.of(context).push(CupertinoPageRoute(
                    settings: const RouteSettings(name: '세번째_페이지_입니다'),
                    builder: (context) => const ThirdRoute())
                );
              },
              child: const Text('세번째로 가기'),
            ),
          ),
        ],
      )
    );
  }
}

class ThirdRoute extends StatelessWidget {
  const ThirdRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Third Route'),
        ),
        body:
        Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  firebaseLogEvent('웹뷰');
                  runApp(const WebViewExample());
                },
                child: const Text('Web_View'),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {
                  firebaseLogEvent('이전으로_가기');
                  Navigator.pop(context);
                },
                child: const Text('Go back!'),
              ),
            ),
          ],
        )
    );
  }
}

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewExample> {
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    WebView.platform = AndroidWebView();

  }

  @override
  Widget build(BuildContext context) {
    return const WebView(
      initialUrl: 'http://mywanpark.dothome.co.kr/index-flutter.html',
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}

Future<void> firebaseLogEvent(content) async {
  FirebaseAnalytics analytics = FirebaseAnalytics();
  await analytics.logEvent(
    name: '$content버튼_클릭됨',
  );
}

class _DynamicLinkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hello World DeepLink'),
        ),
        body: Center(
          child: ElevatedButton(
            child: const Text('DyLink'),
            onPressed: () {
              // Get.to(() => const ThirdRoute());
              firebaseLogEvent('시작페이지로가기');
              Navigator.of(context).push(CupertinoPageRoute(
                  settings: const RouteSettings(name: '시작_페이지_입니다'),
                  builder: (context) => const MyApp())
              );
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const SecondRoute()),
              // );
            },
          ),
        )
      ),
    );
  }
}