import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' ;
// import 'package:jitsi_meet/feature_flag/feature_flag_enum.dart'  as prefix;
import 'package:jitsi_meet/jitsi_meet.dart' ;


import 'package:flutter/foundation.dart' ;



import 'package:jitsi_meet/room_name_constraint.dart';
import 'package:jitsi_meet/room_name_constraint_type.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final serverText = TextEditingController();
  final roomText = TextEditingController(text: "");
  final subjectText = TextEditingController(text: "");
  final nameText = TextEditingController(text: "");
  final emailText = TextEditingController(text: "");
  bool? isAudioOnly = true;
  bool? isAudioMuted = true;
  bool? isVideoMuted = true;

  @override
  void initState() {
    super.initState();
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
  }

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('VidConf'),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 24.0,
                ),
                // TextField(
                //   controller: serverText,
                //   decoration: InputDecoration(
                //       border: OutlineInputBorder(),
                //       labelText: "Server URL",
                //       hintText: "Hint: Leave empty for meet.jitsi.si"),
                // ),
                SizedBox(
                  height: 16.0,
                ),
                TextField(
                  controller: roomText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Room",
                  ),
                ),
                // SizedBox(
                //   height: 16.0,
                // ),
                // TextField(
                //   controller: subjectText,
                //   decoration: InputDecoration(
                //     border: OutlineInputBorder(),
                //     labelText: "Subject",
                //   ),
                // ),
                SizedBox(
                  height: 16.0,
                ),
                TextField(
                  controller: nameText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Display Name",
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextField(
                  controller: emailText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Email",
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                // SizedBox(
                //   height: 16.0,
                // ),
                CheckboxListTile(
                  title: Text("Audio Only"),
                  value: isAudioOnly,
                  onChanged: _onAudioOnlyChanged,
                ),
                SizedBox(
                  height: 16.0,
                ),
                CheckboxListTile(
                  title: Text("Audio Muted"),
                  value: isAudioMuted,
                  onChanged: _onAudioMutedChanged,
                ),
                SizedBox(
                  height: 16.0,
                ),
                CheckboxListTile(
                  title: Text("Video Muted"),
                  value: isVideoMuted,
                  onChanged: _onVideoMutedChanged,
                ),
                Divider(
                  height: 48.0,
                  thickness: 2.0,
                ),
                SizedBox(
                  height: 64.0,
                  width: double.maxFinite,
                  child: RaisedButton(
                    onPressed: () {
                      _joinMeeting();
                    },
                    child: Text(
                      "Join Meeting",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blue,
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onAudioOnlyChanged(bool? value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  _onAudioMutedChanged(bool? value) {
    setState(() {
      isAudioMuted = value;
    });
  }

  _onVideoMutedChanged(bool? value) {
    setState(() {
      isVideoMuted = value;
    });
  }

  _joinMeeting() async {
    String? serverUrl =
        serverText.text?.trim()?.isEmpty ?? false ? null : serverText.text;

    try {
      // Enable or disable any feature flag here
      // If feature flag are not provided, default values will be used
      // Full list of feature flags (and defaults) available in the README
      
      var featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
      };

      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }

      // Define meetings options here
      var options = JitsiMeetingOptions(room: roomText.text)
                ..serverURL = serverUrl
        ..subject = subjectText.text
        ..userDisplayName = nameText.text
        ..userEmail = emailText.text
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..featureFlags.addAll(featureFlags);
        

      debugPrint("JitsiMeetingOptions: $options");
      await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
          onConferenceWillJoin: (message) {
            debugPrint("${options.room} will join with message: $message");
          },
          onConferenceJoined: (message) {
            debugPrint("${options.room} joined with message: $message");
          },
          onConferenceTerminated: (message) {
            debugPrint("${options.room} terminated with message: $message");
          },
          genericListeners: [
            JitsiGenericListener(
                eventName: 'readyToClose',
                callback: (dynamic message) {
                  debugPrint("readyToClose callback");
                }),
          ]),
    );
    } catch (error) {
      debugPrint("error: $error");
    }
  }

  static final Map<RoomNameConstraintType, RoomNameConstraint>
      customContraints = {
    RoomNameConstraintType.MAX_LENGTH: new RoomNameConstraint((value) {
      return value.trim().length <= 50;
    }, "Maximum room name length should be 30."),
    RoomNameConstraintType.FORBIDDEN_CHARS: new RoomNameConstraint((value) {
      return RegExp(r"[$€£]+", caseSensitive: false, multiLine: false)
              .hasMatch(value) ==
          false;
    }, "Currencies characters aren't allowed in room names."),
  };

    void _onConferenceWillJoin(message) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined(message) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated(message) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }
}
