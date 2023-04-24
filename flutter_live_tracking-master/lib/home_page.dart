import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:snippet_coder_utils/FormHelper.dart';

// import 'package:flutter_form_builder/form_builder_validators.dart.';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late IO.Socket socket;
  double? latitude;
  double? longitude;
  static final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  // final globalKey = GlobalKey<FormState>();

  // get FormBuilderValidators => null;
  @override
  void initState() {
    super.initState();
    initSocket();
  }

  Future<void> initSocket() async {
    try {
      socket = IO.io("http://10.12.23.127:3700", <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });
      socket.connect();
      socket.onConnect((data) => {print('Connect :${socket.id}')});
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // var FormHelper; //could cause error
    return Scaffold(
        body: Form(
            key: globalKey,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(right: 20, top: 100),
                child: Column(
                  children: [
                    SizedBox(
                      width: (MediaQuery.of(context).size.width) * 1 / 1.59,
                      child: Column(
                        children: const [
                          Text(
                            "Em.res",
                            style: TextStyle(
                                fontSize: 60,
                                fontFamily: "Mukta",
                                height: 1.2,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text("There for you Just One tap Away")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.asset(
                    'lib/emres.png',
                    width: 300,
                    height: 400,
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 0, top: 100),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      FormHelper.submitButton("SOS", () async {
                        Position latlng = await Geolocator.getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.high);
                        print(latlng.latitude);
                        print(latlng.longitude);
                        latitude = latlng.latitude;
                        longitude = latlng.longitude;
                        if (validateAndSave()) {
                          var coords = {"lat": latitude, "lng": longitude};
                          socket.emit("position-change", jsonEncode(coords));
                        }
                      }),
                    ],
                  )),
            ])));
  }

  void disconnect() {
    super.dispose();
  }

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
}
