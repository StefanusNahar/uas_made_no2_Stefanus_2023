import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen() : super();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DatabaseReference _temperatureRef;
  double temperature = 0;
  late DatabaseReference _humidityRef;
  double humidity = 0;

  final DatabaseReference lockRef =
      FirebaseDatabase.instance.reference().child('lock');
  bool isLocked = true;
  String lockButtonLabel = 'Lock';

  @override
  void initState() {
    super.initState();
    // Temperature setup
    _temperatureRef = FirebaseDatabase.instance
        .reference()
        .child('data')
        .child('current')
        .child('temperature');
    _temperatureRef.onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          temperature = double.parse(snapshot.value.toString());
          print('Retrieved temperature: $temperature');
        });
      }
    });
    // Humidity setup
    _humidityRef = FirebaseDatabase.instance
        .reference()
        .child('data')
        .child('current')
        .child('humidity');
    _humidityRef.onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          humidity = double.parse(snapshot.value.toString());
          print('Retrieved humidity: $humidity');
        });
      }
    });
    // Lock setup
    lockRef.onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          isLocked = snapshot.value == 1;
          lockButtonLabel = isLocked ? 'Lock' : 'Unlock';
        });
      }
    });
  }

  @override
  void dispose() {
    _temperatureRef.onDisconnect();
    _humidityRef.onDisconnect();
    super.dispose();
  }
  void deleteAllData() {
  FirebaseDatabase.instance.reference().child('data').child('history').remove();
  // Add any additional initialization or updates after deleting the data.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
              child: Row(
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Current Temperature:',
                            style: TextStyle(fontSize: 24),
                          ),
                          Text(
                            '${temperature.toStringAsFixed(2)}°C',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    thickness: 1,
                    color: Colors.black,
                    width: 1,
                  ),
                  Expanded(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 98, 214, 240),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Current Humidity:',
                            style: TextStyle(fontSize: 24),
                          ),
                          Text(
                            '${humidity.toStringAsFixed(2)}%',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: 150,
              height: 150,
              child: Column(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Toggle the lock status
                        isLocked = !isLocked;
                      // Update the lock value in the Firebase Realtime Database
                      lockRef.set(isLocked ? 1 : 0);
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    icon: isLocked
                        ? const Icon(Icons.lock, size: 48)
                        : const Icon(Icons.lock_open, size: 48),
                    label: Text(lockButtonLabel, style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ), 
            const SizedBox(height: 16.0),
            SizedBox(
              width: 150,
              height: 40,
              child: ElevatedButton(
                onPressed: deleteAllData,
                child: const Text('Refresh'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
