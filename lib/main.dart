import 'dart:math';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

// Speech recognization and Talk packages added here
import 'dart:async';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIDGS CHATBOT',
      theme: ThemeData(
        brightness: Brightness.dark,
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'SIDGS HINDI CHATBOT'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

// This widget is the home page of your application. It is stateful, meaning
// that it has a State object (defined below) that contains fields that affect
// how it looks.

// This class is the configuration for the state. It holds the values (in this
// case the title) provided by the parent (in this case the App widget) and
// used by the build method of the State. Fields in a Widget subclass are
// always marked "final".

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // speech recognization initaialize variables
  String? speechStatus = "Talk to me";
  late String? speechRecognizeText;
  String output = '';
  bool _onDevice = false;
  final TextEditingController _pauseForController =
      TextEditingController(text: '4');
  final TextEditingController _listenForController =
      TextEditingController(text: '30');
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String _currentLocaleId = '';
  final SpeechToText speech = SpeechToText();

  late bool micPermissionStatus;

  // Text to Speech
  FlutterTts flutterTts = FlutterTts();

  // final messageInsert = TextEditingController();
  List<Map> messsages = [];

  // Google translator
  final translator = GoogleTranslator();

  // Loading Initialization
  bool isVoiceLoaing = false;
  bool isRepLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "IB GROUP CHAT-BOT",
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              child: Column(
                children: <Widget>[
                  Flexible(
                      child: ListView.builder(
                          reverse: true,
                          itemCount: messsages.length,
                          itemBuilder: (context, index) => chat(
                              messsages[index]["message"].toString(),
                              messsages[index]["data"]))),
                  SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    height: 5.0,
                    color: Colors.greenAccent,
                  ),
                  Visibility(
                    visible: speechStatus == 'Listening...',
                    child: Center(
                      child: Lottie.asset(
                        'assets/lottie_animations/animation_lmfza6go.json',
                        // width: 150.0,
                        // height: 130.0,
                        fit: BoxFit.cover,
                        animate: true,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // ListTile(
                  //   leading: IconButton(
                  //     icon: const Icon(
                  //       Icons.mic,
                  //       color: Colors.greenAccent,
                  //       size: 35,
                  //     ),
                  //     onPressed: () async {
                  //       await speechRecognizeConvTT();
                  //     },
                  //   ),
                  //   title: Container(
                  //     height: 40,
                  //     decoration: const BoxDecoration(
                  //       borderRadius: BorderRadius.all(Radius.circular(15)),
                  //       color: Color.fromRGBO(220, 220, 220, 1),
                  //     ),
                  //     padding: const EdgeInsets.only(
                  //         bottom: 5, left: 15, right: 5, top: 0),
                  //     child: TextFormField(
                  //       controller: messageInsert,
                  //       decoration: InputDecoration(
                  //         hintText: "अपना संदेश दर्ज करें...",
                  //         hintStyle: TextStyle(color: Colors.black26),
                  //         border: InputBorder.none,
                  //         focusedBorder: InputBorder.none,
                  //         enabledBorder: InputBorder.none,
                  //         errorBorder: InputBorder.none,
                  //         disabledBorder: InputBorder.none,
                  //       ),
                  //       style: TextStyle(fontSize: 16, color: Colors.black),
                  //       onChanged: (value) {},
                  //     ),
                  //   ),
                  //   trailing:  IconButton(
                  //       icon: const Icon(
                  //         Icons.send,
                  //         size: 30.0,
                  //         color: Colors.greenAccent,
                  //       ),
                  //       onPressed: () {
                  //         if (messageInsert.text.isEmpty) {
                  //           print("empty message");
                  //         } else {
                  //           setState(() {
                  //             messsages.insert(
                  //                 0, {"data": 1, "message": messageInsert.text});
                  //           });
                  //           print("Before send Debug1");
                  //           response(messageInsert.text);
                  //           messageInsert.clear();
                  //         }
                  //         FocusScopeNode currentFocus = FocusScope.of(context);
                  //         if (!currentFocus.hasPrimaryFocus) {
                  //           currentFocus.unfocus();
                  //         }
                  //       }),
                  // ),
                  Center(
                    child: InkWell(
                      child: SizedBox(
                        width: 250,
                        height: 150,
                        child: Lottie.asset(
                          'assets/lottie_animations/mic.json',
                          // width: 150.0,
                          // height: 130.0,
                          fit: BoxFit.cover,
                          animate: true,
                        ),
                      ),
                      onTap: () async {
                        await flutterTts.stop();
                        await speechRecognizeConvTT();
                        setState(() {
                          messsages.insert(
                              0, {"data": 1, "message": speechRecognizeText});
                        });
                        print("Before send Debug1");
                        response(speechRecognizeText);
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  )
                ],
              ),
            ),
            // TODO: Loading Widgets

            if (isRepLoading)
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Lottie.asset(
                  'assets/lottie_animations/AiLoading.json',
                  width: 150.0,
                  height: 130.0,
                  fit: BoxFit.cover,
                  animate: true,
                ),
              ),

            if (isVoiceLoaing)
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Lottie.asset(
                  'assets/lottie_animations/Loading.json',
                  width: 150.0,
                  height: 130.0,
                  fit: BoxFit.cover,
                  animate: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget chat(String message, int data) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment:
            data == 1 ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          data == 0
              ? Container(
                  height: 60,
                  width: 60,
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/robot.jpg"),
                  ),
                )
              : Container(),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Bubble(
                radius: Radius.circular(15.0),
                color: data == 0
                    ? Color.fromRGBO(23, 157, 139, 1)
                    : Colors.orangeAccent,
                elevation: 0.0,
                child: Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        width: 10.0,
                      ),
                      Flexible(
                          child: Container(
                        constraints: BoxConstraints(maxWidth: 200),
                        child: Text(
                          message,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ))
                    ],
                  ),
                )),
          ),
          data == 1
              ? Container(
                  height: 60,
                  width: 60,
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/default.jpg"),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  void response(query) async {
    setState(() {
      isRepLoading = true;
    });
    // String configPath = "assets/service.json";

//TODO TEST 2
    // String configPath = "assets/kisan_mitra_service.json";

    //TODO TEST 3
    String configPath = "assets/helpdesk.json";

    DialogAuthCredentials credentials =
        await DialogAuthCredentials.fromFile(configPath);
    //TODO TEST 1
    // DialogFlowtter instance = DialogFlowtter(
    //   credentials: credentials,
    // )..projectId = "hindi-agent-dv9d";

    //TODO TEST 2
    // DialogFlowtter instance = DialogFlowtter(
    //   credentials: credentials,
    // )..projectId = "kisan-mitra-xn9s";

    //TODO TEST 3
    DialogFlowtter instance = DialogFlowtter(
      credentials: credentials,
    )..projectId = "bigquery-public-data-368612";
    late String? enQuery;

    var enTranslator = translator.translate(query ?? "", from: 'hi', to: 'en');

    await enTranslator.then((value) {
      enQuery = value.toString();
    });

    print("enQuery : $enQuery");

    final QueryInput queryInput = QueryInput(
      text: TextInput(
        text: "$enQuery",
        languageCode: "en",
      ),
    );

    String isQueryNotFound = "";

    try {
      // DetectIntentResponse response =
      await instance
          .detectIntent(
        queryInput: queryInput,
      )
          .then((value) async {
        print("Khiriyat : ${value}");
        if (isQueryNotFound.isEmpty) {
          print("Response Rehaman Debug : ${value}");

          late String hiTranslator;
          await translator
              .translate(value.text.toString(), from: 'en', to: 'hi')
              .then((value) async {
            hiTranslator = value.toString();
          });
          setState(() {
            messsages.insert(0, {"data": 0, "message": hiTranslator});
          });
          talkResp(hiTranslator);
        }
        return value;
      }).catchError((error) {
        isQueryNotFound = "Data not found";
        print("Astagfirullah  Error : $error");
      });
    } catch (e) {
      print('Error  Astagfirullah :$e');
    }
    setState(() {
      isRepLoading = false;
    });

    print(
        "------------------------------------------------------------------------------------------------------------------------------------------");

    // AIResponse aiResponse = await dialogflow.detectIntent(query);

    if (isQueryNotFound.isNotEmpty) {
      print("no data found");
      messsages.insert(0, {
        "data": 0,
        "message":
            "कृपया स्पष्ट रूप से और विस्तार से बताएं कि आप किस विषय के बारे में जानना चाहते हैं, ताकि मैं आपकी मदद कर सकूँ।"
      });

      talkResp(
          "कृपया स्पष्ट रूप से और विस्तार से बताएं कि आप किस विषय के बारे में जानना चाहते हैं, ताकि मैं आपकी मदद कर सकूँ।");
    }

    // print(aiResponse.getListMessage()[0]["text"]["text"][0].toString());
  }

  speechRecognizeConvTT() async {
    micPermissionStatus = await Permission.microphone.isGranted;
    int perSec = 1;
    int waitingTime = 0;

    if (micPermissionStatus) {
      Timer timerCtrl = Timer.periodic(Duration(seconds: perSec), (timer) {
        if (speechStatus == 'Talk to me') {
          timer.cancel();
        }
        print("waiting  timer Started : $waitingTime");
        waitingTime++;
        setState(() {});
      });

      bool isInitialized = await speech.initialize();
      setState(() {
        speechStatus = "Listening...";
      });

      if (isInitialized) {
        var systemLocale = await speech.systemLocale();
        print("system Locale : ${systemLocale!.localeId}");
        _currentLocaleId = systemLocale?.localeId ?? '';
        final pauseFor = int.tryParse(_pauseForController.text);
        final listenFor = int.tryParse(_listenForController.text);
        await speech.listen(
          onResult: (result) {
            if (!result.finalResult) {
              setState(() {
                output = '${result.recognizedWords}';
                speechStatus = "Listening...";
                speechRecognizeText = '${result.recognizedWords}';
                print("speech to text test1 : ${result.recognizedWords}");
              });
            } else {
              setState(() {
                output = '${result.recognizedWords}';
                speechRecognizeText = '${result.recognizedWords}';
                speechStatus = 'Talk to me';
                print("speech to text test2 : ${result.recognizedWords}");
                // messageInsert.text = speechRecognizeText!;
              });
            }

            print("speech to text test3 : ${result.recognizedWords}");
            speechRecognizeText = '${result.recognizedWords}';
            output = '${result.recognizedWords}';

            setState(() {});
          },
          listenFor: Duration(seconds: listenFor ?? 30),
          pauseFor: Duration(seconds: pauseFor ?? 8),
          partialResults: true,
          localeId: 'hi',
          onSoundLevelChange: (level) {
            minSoundLevel = min<double>(minSoundLevel, level);
            maxSoundLevel = max<double>(maxSoundLevel, level);
            print(
                'sound level frequency: $level: $minSoundLevel - $maxSoundLevel ');
            level = level;
          },
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
          onDevice: _onDevice,
        );
      }
    } else {
      showAdaptiveDialog(
        context: context,
        builder: (context) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 200,
              width: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 0,
                  ),
                  Text(
                    "Required device mic permission!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MaterialButton(
                            color: Colors.blueAccent,
                            child: Text('Done'),
                            onPressed: () async {
                              await Permission.microphone.request();
                              Navigator.of(context).pop();
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (output.isEmpty) {
      print("the value is getting empty");
      speechRecognizeText = "";
      setState(() {});
    }

    await Future.delayed(Duration(seconds: 3));
    setState(() {
      isVoiceLoaing = true;
    });
    await Future.delayed(Duration(seconds: waitingTime), () {
      setState(() {
        speechStatus = 'Talk to me';
      });
    });

    setState(() {
      isVoiceLoaing = false;
    });
  }

  talkResp(String? msg) async {
    String defautlLangCode = "hi-IN";
    // var lang = await flutterTts.getLanguages;
    var acceptedLang = await flutterTts.setLanguage(defautlLangCode);

    if (acceptedLang > 0) {
      // var defaultVoice = await flutterTts.getDefaultVoice;
      List voices = await flutterTts.getVoices;
      List hindiVoices = voices
          .where((element) => element['locale'] == defautlLangCode)
          .toList();

      print("List of voices : ");

      await flutterTts
          .setVoice({"name": "hi-in-x-cfn#male_3-local", "locale": "hi-IN"});

      print("Before Speek text recognization: $output");
      // print("set Voice : ${setVoice.whenComplete(() {
      //   print("after complition");
      // }).catchError((error) => error)}");

      await flutterTts.speak(msg!);
    }
  }
}
