import 'package:GroundPasserApp/bestList_screen.dart';
import 'package:GroundPasserApp/personalScreen.dart';
import 'package:GroundPasserApp/src/authentication.dart';
import 'package:GroundPasserApp/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'applicationState.dart';
import 'organizeGameInstance.dart';

class DeviceScreen extends StatelessWidget {
  //Stream to get all instances from the firebase document "bestlist". Here all runs of the game (instances) are saved
  final Stream<QuerySnapshot> _gameInstancesStream = FirebaseFirestore.instance
      .collection('bestlist')
      .orderBy('total', descending: false)
      .snapshots();

  DeviceScreen({Key? key, required this.device}) : super(key: key);

// chosen Bluetooth device is saved and pushed to all pages
  final BluetoothDevice device;

  // a method that is called later. It returns a list with all available Bluetooth services from the connected device,
  // adds a button if the Characteristic is writeable. If this button is pressed it sets the Characteristic on the remote device notifyable
  // a bit is sent to the characteristic running on the remote device, an new OrganizeGame Instance is created, which listens to all the
  // responses from the remote device, oranize and save them in the database
  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map(
                  (c) => CharacteristicTile(
                      characteristic: c,
                      onNotificationPressed: () async {
                        await c.setNotifyValue(!c.isNotifying);
                        //await c.read();
                      },
                      onStartGamePressed: () async {
                        await c.setNotifyValue(true);
                        await c.write([0x12], withoutResponse: true);
                        OrganizeGameInstance(
                            c,
                            FirebaseAuth.instance.currentUser!.displayName
                                .toString(),
                            FirebaseAuth.instance.currentUser!.uid.toString());
                        await c.read();
                      },
                      onStartGamePressed2: () {}
                      /*
                    descriptorTiles: c.descriptors
                        .map(
                          (d) => DescriptorTile(
                            descriptor: d,
                            onReadPressed: () => d.read(),
                            onWritePressed: () => d.write(_getRandomBytes()),
                          ),
                        )
                        .toList(),*/
                      ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    var backgroundColor = Colors.black;
    return Scaffold(
      // build App Bar with the devices name and a button to Connect/ Disconnect to the device in the Title section
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  backgroundColor = Colors.black;
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                // the connect button will be red so the users recognize if the device is disconnected
                case BluetoothDeviceState.disconnected:
                  backgroundColor = Colors.red;
                  onPressed = () => device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return TextButton(
                  onPressed: onPressed,
                  style: TextButton.styleFrom(
                      backgroundColor: backgroundColor, primary: Colors.white),
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        ?.copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      // the body ( main part of the page consists of different parts)
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // first a area where the connected device with some information to it (e.g. UUID) is shown
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? const Icon(Icons.bluetooth_connected)
                    : const Icon(Icons.bluetooth_disabled),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data! ? 1 : 0,
                    children: <Widget>[
                      //then a button is implemented that discover the Bluetooth Series of the Device and save them
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => device.discoverServices(),
                      ),
                      const IconButton(
                        icon: SizedBox(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                          width: 18.0,
                          height: 18.0,
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            // the a button to manage the authentication is shown below.
            //Here the user can Login/Register (depending if he already has an account) or Logout
            Consumer<ApplicationState>(
              builder: (context, appState, _) => Authentication(
                email: appState.email,
                loginState: appState.loginState,
                startLoginFlow: appState.startLoginFlow,
                verifyEmail: appState.verifyEmail,
                signInWithEmailAndPassword: appState.signInWithEmailAndPassword,
                cancelRegistration: appState.cancelRegistration,
                registerAccount: appState.registerAccount,
                signOut: appState.signOut,
              ),
            ),

            // below that services that were saved before are all shown in a list inlcuding a button to send them a message
            // (which in our case means the game logic on the hardware device will start) if this characteristic is writable
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: const [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data!),
                );
              },
            ),
            //Lastly two buttons are added to switch to team overview ...
            ElevatedButton.icon(
              label: const Text('Teamübersicht'),
              icon: const Icon(Icons.format_list_numbered_outlined),
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
              ),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      BestListScreen(_gameInstancesStream, device))),
            ),
            Container(height: 20),
            // or the personal overview
            ElevatedButton.icon(
                label: const Text('Persönliche Übersicht'),
                icon: const Icon(Icons.analytics_outlined),
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                ),
                onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => PersonalScreen(device)),
                    ))
          ],
        ),
      ),
    );
  }
}
