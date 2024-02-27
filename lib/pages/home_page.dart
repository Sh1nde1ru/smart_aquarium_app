import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:smart_aquarium_app/widgets/my_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dynamic temperature;
  dynamic outputTemp;
  dynamic pH;
  dynamic outputPh;
  double initValue = 0;
  double hourOnInit = 0;
  double hourOffInit = 0;
  double minOnInit = 0;
  double minOffInit = 0;
  final timeOnHours = FixedExtentScrollController();
  final timeOnMins = FixedExtentScrollController();
  final timeOffHours = FixedExtentScrollController();
  final timeOffMins = FixedExtentScrollController();

  Timer? saveEvent1;
  Timer? saveEvent2;

  Timer? saveEvent3;
  Timer? saveEvent4;

  @override
  void initState() {
    loadData();
    DatabaseReference tempRef =
        FirebaseDatabase.instance.ref("DATA/Temperature");
    Stream<DatabaseEvent> streamTemp = tempRef.onValue;
    streamTemp.listen((event) {
      temperature = event.snapshot.value;
      setState(() {
        outputTemp = temperature;
      });
    });

    DatabaseReference phRef = FirebaseDatabase.instance.ref("DATA/pH");
    Stream<DatabaseEvent> streamPh = phRef.onValue;
    streamPh.listen((event) {
      pH = event.snapshot.value;
      setState(() {
        outputPh = pH;
      });
    });
    super.initState();
  }

  void loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      initValue = prefs.getDouble('initValue') ?? 0;
      hourOnInit = prefs.getDouble('timeOnInitialHours') ?? 0;
      minOnInit = prefs.getDouble('timeOnInitialMins') ?? 0;
      hourOffInit = prefs.getDouble('timeOffInitialHours') ?? 0;
      minOffInit = prefs.getDouble('timeOffInitialMins') ?? 0;

      timeOnHours.animateToItem(hourOnInit.toInt(),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.linearToEaseOut);
      timeOnMins.animateToItem(minOnInit.toInt(),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.linearToEaseOut);
      timeOffMins.animateToItem(minOffInit.toInt(),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.linearToEaseOut);
      timeOffHours.animateToItem(hourOffInit.toInt(),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.linearToEaseOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Colors.deepPurple.shade400,
            Colors.deepPurple.shade300,
            Colors.deepPurple.shade200
          ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyContainer(
                    height: 150,
                    width: 150,
                    color: Colors.deepPurple.shade300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Teplota",
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            "$temperature°C",
                            style: const TextStyle(
                                fontSize: 40, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                  MyContainer(
                      height: 150,
                      width: 150,
                      color: Colors.deepPurple.shade300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "pH",
                            style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            "$pH",
                            style: const TextStyle(
                                fontSize: 40, color: Colors.white),
                          )
                        ],
                      ))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyContainer(
                    height: 150,
                    width: 150,
                    color: Colors.deepPurple.shade300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Zapnutí:",
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 50,
                                width: 50,
                                //čas zanptnutí hodiny
                                child: ListWheelScrollView.useDelegate(
                                    controller: timeOnHours,
                                    physics: const FixedExtentScrollPhysics(),
                                    itemExtent: 40,
                                    childDelegate:
                                        ListWheelChildLoopingListDelegate(
                                      children: List<Widget>.generate(
                                        24,
                                        (index) => Text(
                                          index < 10 ? '0' "$index" : "$index",
                                          style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    onSelectedItemChanged: (value) {
                                      HapticFeedback.lightImpact();

                                      //playSound();
                                      saveEvent1?.cancel();
                                      saveEvent1 = Timer(
                                          const Duration(seconds: 1),
                                          () => storeTimeOnHours(value));
                                    }),
                              ),
                              const SizedBox(
                                height: 45,
                                child: Text(
                                  ':',
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                width: 50,
                                //čas zapnutí minuty
                                child: ListWheelScrollView.useDelegate(
                                    //controller: timeOnMinutes,
                                    itemExtent: 40,
                                    controller: timeOnMins,
                                    physics: const FixedExtentScrollPhysics(),
                                    childDelegate:
                                        ListWheelChildLoopingListDelegate(
                                      children: List<Widget>.generate(
                                        60,
                                        (index) => Text(
                                          index < 10 ? '0' "$index" : "$index",
                                          style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    onSelectedItemChanged: (value) {
                                      HapticFeedback.lightImpact();

                                      //playSound();
                                      saveEvent2?.cancel();
                                      saveEvent2 = Timer(
                                          const Duration(seconds: 1),
                                          () => storeTimeOnMins(value));
                                    }),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  MyContainer(
                    height: 150,
                    width: 150,
                    color: Colors.deepPurple.shade300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Center(
                            child: Text(
                              "Vypnutí:",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 50,
                                width: 50,
                                child: ListWheelScrollView.useDelegate(
                                  controller: timeOffHours,
                                  //controller: timeOffHours,
                                  physics: const FixedExtentScrollPhysics(),
                                  itemExtent: 40,
                                  childDelegate:
                                      ListWheelChildLoopingListDelegate(
                                    children: List<Widget>.generate(
                                      24,
                                      (index) => Text(
                                        index < 10 ? '0' "$index" : "$index",
                                        style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  onSelectedItemChanged: (value) {
                                    HapticFeedback.lightImpact();

                                    //playSound();
                                    saveEvent3?.cancel();
                                    saveEvent3 = Timer(
                                        const Duration(seconds: 1),
                                        () => storeTimeOffHours(value));
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 45,
                                child: Text(
                                  ':',
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                width: 50,
                                child: ListWheelScrollView.useDelegate(
                                    controller: timeOffMins,
                                    itemExtent: 40,
                                    physics: const FixedExtentScrollPhysics(),
                                    childDelegate:
                                        ListWheelChildLoopingListDelegate(
                                      children: List<Widget>.generate(
                                        60,
                                        (index) => Text(
                                          index < 10 ? '0' "$index" : "$index",
                                          style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    onSelectedItemChanged: (value) {
                                      HapticFeedback.lightImpact();

                                      //playSound();
                                      // storeTimeOffMins(value);
                                      saveEvent4?.cancel();
                                      saveEvent4 = Timer(
                                          const Duration(seconds: 1),
                                          () => storeTimeOffMins(value));
                                    }),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              SleekCircularSlider(
                initialValue: initValue,
                appearance: CircularSliderAppearance(
                  size: 300,
                  startAngle: 180,
                  angleRange: 180,
                  customWidths: CustomSliderWidths(
                    trackWidth: 50,
                    shadowWidth: 0,
                    progressBarWidth: 50,
                  ),
                  customColors: CustomSliderColors(
                      gradientStartAngle: 180,
                      gradientEndAngle: 360,
                      progressBarColors: [
                        Colors.blue.shade900,
                        Colors.deepOrange,
                        Colors.yellow
                      ],
                      trackColor: Colors.grey.shade500),
                ),
                min: 0,
                max: 100,
                onChange: (double value) {
                  setState(() {
                    storeStartValue(value);
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void storeStartValue(double value) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("LightValue");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        ref.set(value.round());
        prefs.setDouble('initValue', value);
      },
    );
  }

  void storeTimeOnHours(int value) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("timeOnHour");
    print('Saving value to local storage time on hours');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ref.set(value);
      prefs.setDouble('timeOnInitialHours', value.toDouble());
    });
  }

  void storeTimeOffHours(int value) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("timeOffHour");
    print('Saving value to local storage time off hours');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ref.set(value);
      prefs.setDouble('timeOffInitialHours', value.toDouble());
    });
  }

  void storeTimeOnMins(int value) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("timeOnMins");
    print('Saving value to local storage time on mins');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ref.set(value);
      prefs.setDouble('timeOnInitialMins', value.toDouble());
    });
  }

  void storeTimeOffMins(int value) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("timeOffMins");
    print('Saving value to local storage time off mins');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ref.set(value);
      prefs.setDouble('timeOffInitialMins', value.toDouble());
    });
  }
}
