import os
import sys
import dbus, dbus.mainloop.glib
from gi.repository import GLib
from example_advertisement import Advertisement
from example_advertisement import register_ad_cb, register_ad_error_cb
from example_gatt_server import Service, Characteristic
from example_gatt_server import register_app_cb, register_app_error_cb
import gameLogic
import gameLogic2
import time

BLUEZ_SERVICE_NAME =           'org.bluez'
DBUS_OM_IFACE =                'org.freedesktop.DBus.ObjectManager'
LE_ADVERTISING_MANAGER_IFACE = 'org.bluez.LEAdvertisingManager1'
GATT_MANAGER_IFACE =           'org.bluez.GattManager1'
GATT_CHRC_IFACE =              'org.bluez.GattCharacteristic1'
#define UUIDs for the Service and the two characteristics
UART_SERVICE_UUID =            '6e400001-b5a3-f393-e0a9-e50e24dcca9e'
UART_RX_CHARACTERISTIC_UUID =  '6e400002-b5a3-f393-e0a9-e50e24dcca9e'
UART_TX_CHARACTERISTIC_UUID =  '6e400003-b5a3-f393-e0a9-e50e24dcca9e'
#define name of Bluetooth device that appears on Bluetooth searches
LOCAL_NAME =                   'GroundPasser'
mainloop = None

global zeit

class TxCharacteristic(Characteristic):
    def __init__(self, bus, index, service):
        #characteristic is able to write, read and notify
        Characteristic.__init__(self, bus, index, UART_TX_CHARACTERISTIC_UUID,
                                ['write', 'read', 'notify'], service)
        self.notifying = False
        
    def WriteValue(self, value, options):
        #print bytes received from mobile device
        print('remote: {}'.format(bytearray(value).decode()))
        #start the game set up
        gameLogic.setUp(self)
        #start the game logic (while loop for ten goals)
        total = gameLogic.game()
        #send the return data from gameLogic.game() to the mobile device
        self.send_tx(total)        

    def ReadValue(self, options):
        print('TestCharacteristic Read: ' + repr(self.value))
        return self.value

    # method to send data to the connected mobile device  
    def send_tx(self, s):
        print("send_tx")
        print(s)
        if not self.notifying:
            return
        value = []
        for c in s: 
            value.append(dbus.Byte(c.encode()))
        self.PropertiesChanged(GATT_CHRC_IFACE, {'Value': value}, [])
    
    def StartNotify(self):
        print("Start Notify")
        if self.notifying:
            return
        self.notifying = True

    def StopNotify(self):
        print("Stop Notify")
        if not self.notifying:
            return
        self.notifying = False

#same procedure only with another game Logic    
class RxCharacteristic(Characteristic):
    def __init__(self, bus, index, service):
        Characteristic.__init__(self, bus, index, UART_RX_CHARACTERISTIC_UUID,
                                ['write', 'read', 'notify'], service)

        self.notifying = False
        
    def WriteValue(self, value, options):
        print('remote: {}'.format(bytearray(value).decode()))
        gameLogic2.setUp(self)
        total = gameLogic2.game()
        self.send_tx(total)
        

    def ReadValue(self, options):
        print('TestCharacteristic Read: ' + repr(self.value))
        return self.value
        
    def send_tx(self, s):
        print("send_tx")
        print(s)
        if not self.notifying:
            return
        value = []
        for c in s: 
            value.append(dbus.Byte(c.encode()))
        self.PropertiesChanged(GATT_CHRC_IFACE, {'Value': value}, [])
    
    def StartNotify(self):
        print("Start Notify")
        if self.notifying:
            return
        self.notifying = True

    def StopNotify(self):
        print("Stop Notify")
        if not self.notifying:
            return
        self.notifying = False
        
#methods to initialize the GATT Server und start it with the implemented Characteristics
class UartService(Service):
    def __init__(self, bus, index):
        Service.__init__(self, bus, index, UART_SERVICE_UUID, True)
        self.add_characteristic(RxCharacteristic(bus, 0, self))
        self.add_characteristic(TxCharacteristic(bus, 1, self))

class Application(dbus.service.Object):
    def __init__(self, bus):
        self.path = '/'
        self.services = []
        dbus.service.Object.__init__(self, bus, self.path)

    def get_path(self):
        return dbus.ObjectPath(self.path)

    def add_service(self, service):
        self.services.append(service)

    @dbus.service.method(DBUS_OM_IFACE, out_signature='a{oa{sa{sv}}}')
    def GetManagedObjects(self):
        response = {}
        for service in self.services:
            response[service.get_path()] = service.get_properties()
            chrcs = service.get_characteristics()
            for chrc in chrcs:
                response[chrc.get_path()] = chrc.get_properties()
        return response

class UartApplication(Application):
    def __init__(self, bus):
        Application.__init__(self, bus)
        self.add_service(UartService(bus, 0))

class UartAdvertisement(Advertisement):
    def __init__(self, bus, index):
        Advertisement.__init__(self, bus, index, 'peripheral')
        self.add_service_uuid(UART_SERVICE_UUID)
        self.add_local_name(LOCAL_NAME)
        self.include_tx_power = True

def find_adapter(bus):
    remote_om = dbus.Interface(bus.get_object(BLUEZ_SERVICE_NAME, '/'),
                               DBUS_OM_IFACE)
    objects = remote_om.GetManagedObjects()
    for o, props in objects.items():
        if LE_ADVERTISING_MANAGER_IFACE in props and GATT_MANAGER_IFACE in props:
            return o
        print('Skip adapter:', o)
    return None

def main():
    os.system("sudo systemctl restart bluetooth.service")
    global mainloop
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SystemBus()
    adapter = find_adapter(bus)
    if not adapter:
        print('BLE adapter not found')
        return

    service_manager = dbus.Interface(
                                bus.get_object(BLUEZ_SERVICE_NAME, adapter),
                                GATT_MANAGER_IFACE)
    ad_manager = dbus.Interface(bus.get_object(BLUEZ_SERVICE_NAME, adapter),
                                LE_ADVERTISING_MANAGER_IFACE)

    app = UartApplication(bus)
    adv = UartAdvertisement(bus, 0)

    mainloop = GLib.MainLoop()

    service_manager.RegisterApplication(app.get_path(), {},
                                        reply_handler=register_app_cb,
                                        error_handler=register_app_error_cb)
    ad_manager.RegisterAdvertisement(adv.get_path(), {},
                                     reply_handler=register_ad_cb,
                                     error_handler=register_ad_error_cb)
    try:
        mainloop.run()
    except KeyboardInterrupt:
        adv.Release()

if __name__ == '__main__':
    main()
