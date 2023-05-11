import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:lora_monitor/presentation/core/size_config.dart';

// ignore: must_be_immutable
class ConnectionStream extends StatefulWidget {
  const ConnectionStream(
      {Key? key,
      required this.url,
      required this.connected,
      required this.disconnected})
      : super(key: key);
  final String url;
  final Widget connected;
  final Widget disconnected;

  @override
  State<ConnectionStream> createState() => ConnectionStreamState();
}

class ConnectionStreamState extends State<ConnectionStream> {
  Timer? timer;
  Widget connectedWidget = const Text("");
  Widget disconnectedWidget = const Text("");
  bool conected = false;
  int counter = 0;

  void getUpdatedValue() async {
    try {
      final response = await http
          .get(
        Uri.parse(widget.url),
      )
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response(
              'Error', 408); // Request Timeout response status code
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          counter = 0;
          conected = true;
        });
      } else {
        counter += 1;
        if (counter > 5) {
          setState(() {
            conected = false;
          });
        }
      }
    } catch (e) {
      counter += 1;
      if (counter > 5) {
        setState(() {
          conected = false;
        });
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    connectedWidget = widget.connected;
    disconnectedWidget = widget.disconnected;
    getUpdatedValue();
    super.initState();
    timer = Timer.periodic(
        const Duration(seconds: 1), (Timer t) => getUpdatedValue());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(
          height: 10,
        ),
        conected == true ? connectedWidget : disconnectedWidget,
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: SizeConfig.blockSizeHorizontal * 3,
                  ),
                  conected
                      ? const Text("")
                      : SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 14,
                          height: SizeConfig.blockSizeHorizontal * 14,
                          child: FloatingActionButton(
                            onPressed: (() => {
                                  AppSettings.openWIFISettings(callback: () {}),
                                }),
                            child: Icon(
                              size: SizeConfig.blockSizeHorizontal * 8,
                              conected == false ? Icons.power_off : Icons.power,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}