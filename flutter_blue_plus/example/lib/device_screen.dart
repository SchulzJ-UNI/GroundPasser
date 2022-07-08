import 'package:GroundPasserApp/bestList_screen.dart';
import 'package:GroundPasserApp/personalScreen.dart';
import 'package:GroundPasserApp/profile.dart';
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
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('bestlist')
      .orderBy('total', descending: false)
      .snapshots();

  DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;
  var myProfile = Profile('nV', 'nV', 0, 0, 0, 0, 0, 0,0);
  var allTimeHs = 0;

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map(
                  (c) => CharacteristicTile(
                      characteristic: c,
                      /*onReadPressed: () => c.read(),
                    onWritePressed: () async {
                     await c.write([0x12], withoutResponse: true);

                      //await c.write([0x12]);
                     var antwort = await c.read();
                    },*/
                      onNotificationPressed: () async {
                        await c.setNotifyValue(!c.isNotifying);
                        //await c.read();
                      },
                      onStartGamePressed: () async {
                        await c.setNotifyValue(true);
                        await c.write([0x12], withoutResponse: true);
                        //await _updateMyProfile();
                        //await _getAllTimeHS();
                        OrganizeGameInstance(
                            c,
                            FirebaseAuth.instance.currentUser!.displayName
                                .toString(),
                            FirebaseAuth.instance.currentUser!.uid.toString());
                        //await c.write([0x12]);
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
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
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: const [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data!),
                );
              },
            ),
            ElevatedButton.icon(
                label: const Text('Teamübersicht'),
                icon: Icon(Icons.format_list_numbered_outlined ),
                style: ElevatedButton.styleFrom(primary: Colors.black, ),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BestListScreen(_usersStream, device, myProfile))),
                ),
            Container(height: 20),
            ElevatedButton.icon(
                label: const Text('Persönliche Übersicht'),
                icon: Icon(Icons.analytics_outlined),
                style: ElevatedButton.styleFrom(primary: Colors.black, ),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PersonalScreen(_usersStream, device)),
                ))

            // to here
          ],
        ),
      ),
    );
  }
}
