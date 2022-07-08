from paramiko import SSHClient, AutoAddPolicy
import random
import time
import neopixel
import board
from gpiozero import Button, Buzzer, LED, DigitalInputDevice

#import main.py(Bluetooth Server) to be able to use the send_tx method and send data to the mobile device
import main

#initialize the three SSHClients to open communication tunnels to the remote panels
client = SSHClient()
client2 = SSHClient()
client3 = SSHClient()
#initialize the NeoPixel instances to controll the LED stripes
ledLU = neopixel.NeoPixel(board.D18, 25)
ledLO = neopixel.NeoPixel(board.D12, 25)
#initialize the Vibration modules and button
vibr = DigitalInputDevice (27)
vibr2 = DigitalInputDevice (22)
button = Button (24)

# initiate nrHits to count number of scored "goals"
nrHits =0
#iniate randInt to randomly assign the next "goal"
randInt = 3
total =0
cr = 0

# turn the led stripe green (signal that game starts soon) wait for one second and turn it off again
def lightUpGreen():
    ledLU.fill((0,255,0))
    ledLO.fill((0,255,0))
    time.sleep(1)
    ledLU.fill((0,0,0))
    ledLO.fill((0,0,0))
#same with blue to signalize the game is over
def lightUpBlue():
    ledLU.fill((0,0,255))
    ledLO.fill((0,0,255))
    time.sleep(1)
    ledLU.fill((0,0,0))
    ledLO.fill((0,0,0))

#method if this device is chosen to be passed against. Turn the led stripe red, wait for both vibration modules to be active and turn off the led again
def triggerThis():
    ledLU.fill((255,0,0))
    ledLO.fill((255,0,0))
    time.sleep(0.4)
    vibr.wait_for_active()
    time.sleep(0.2)
    vibr2.wait_for_active()
    ledLU.fill((0,0,0))
    ledLO.fill((0,0,0))
    print("Tor 4 getroffen") 

# turn off the led stripe from this device and the ones from the remote devices
def allLedOff():
    ledLU.fill((0,0,0))
    ledLO.fill((0,0,0))

    stdin4, stdout4, stderr4 = client.exec_command('sudo python3 /home/pi/led_off.py')
    stdin5, stdout5, stderr5 = client2.exec_command('sudo python3 /home/pi/led_off.py')
    stdin6, stdout6, stderr6 = client3.exec_command('sudo python3 /home/pi/led_off.py')

    stdin4.close()
    stdout4.close()
    stderr4.close()
    
    stdin5.close()
    stdout5.close()
    stderr5.close()
    
    stdin6.close()
    stdout6.close()
    stderr6.close()
    print("Alle Lichter ausgeschalten")

#initialize our three clients by connecting it via SSH and the ip adress, username and password of the remote devices. T
def setUp(chara):
    print("Set up abgeschlossen Start")
    global client
    global client2
    global client3
    global cr
    print("Set up abgeschlossen Variablen initialisiert")
    cr = chara
    client.load_system_host_keys()
    client.load_host_keys('/home/pi/.ssh/known_hosts')
    client.set_missing_host_key_policy(AutoAddPolicy())
    client.connect('192.168.4.1',username='pi', password='julian')
    print("Set up abgeschlossen client1")
    cr.send_tx("Set up abgeschlossen client1")
    
    client2.load_system_host_keys()
    client2.load_host_keys('/home/pi/.ssh/known_hosts')
    client2.set_missing_host_key_policy(AutoAddPolicy())
    client2.connect(hostname='192.168.4.2', username='pi',password='julian')
    print("Set up abgeschlossen client 2")
    cr.send_tx("Set up abgeschlossen client2")
    
    client3.load_system_host_keys()
    client3.load_host_keys('/home/pi/.ssh/known_hosts')
    client3.set_missing_host_key_policy(AutoAddPolicy())
    client3.connect(hostname='192.168.4.20', username='jonas',password='julian') 
    print("Set up abgeschlossen client 3")
    cr.send_tx("Set up abgeschlossen client3")
    
    allLedOff()
    print("Set up abgeschlossen2")

def game():
    print("Game has started")
    cr.send_tx("Game has started")
    lightUpGreen()
    #start meassuring time
    t0 = time.time()
    #loop ten times => 10 "goals" have to be scored
    global nrHits
    while nrHits <= 9:
        #generate a random number between 1 and 4
        global randInt
        randInt = random.randint(1,4)    
        #trigger one device by starting the led_on.py code thorough the command ('sudo python3 /home/pi/led_on.py') dependend on the generated randomInteger.
        #led_on.py lights up the led stripe from this device waits until the vibration module is active (= Ball hit the panel) and turns off the led stripe afterwards
        if randInt == 1:
            stdin, stdout, stderr = client.exec_command('sudo python3 /home/pi/led_on.py')
            out= stdout.read().decode("utf8")
            print(out)
            #measure the split time
            t2= time.time()
            zz= t2-t0
            #send it to the mobile device through the Bluetooth Characteristic
            send= str(nrHits)+"-"+str(zz)
            cr.send_tx(send)
            print(send)
        elif randInt == 2:
            stdin2, stdout2, stderr2 = client2.exec_command('sudo python3 /home/pi/led_on.py')
            out2= stdout2.read().decode("utf8")
            print(out2)
            t2= time.time()
            zz= t2-t0
            send= str(nrHits)+"-"+str(zz)
            cr.send_tx(send)
            print(send)
        elif randInt == 3:
            stdin3, stdout3, stderr3 = client3.exec_command('sudo python3 led_on.py')
            out3= stdout3.read().decode("utf8")
            print(out3)
            t2= time.time()
            zz= t2-t0
            send= str(nrHits)+"-"+str(zz)
            cr.send_tx(send)   
        #randInt did not indicate to trigger one of the remote devices, so we do the same logic for this device    
        else:
            triggerThis()
            t2= time.time()
            zz= t2-t0
            send= str(nrHits)+"-"+str(zz)
            cr.send_tx(send)
        #when vibration module on the triggered device was hit, add one to nrHits, sleep for one second and restart the loop      
        nrHits = nrHits +1
        time.sleep(1)
    #after ten hits, reset nr Hits and calculate end time
    t1 = time.time()
    global total
    total = t1-t0
    nrHits =0
    #siganlize end of game to user
    lightUpBlue()  
    print("Spiel ist vorbei")
    #close the communication tunnels to the remote devices
    stdin.close()
    stdout.close()
    stderr.close()

    stdin2.close()
    stdout2.close()
    stderr2.close()
    
    stdin3.close()
    stdout3.close()
    stderr3.close()
    # turn all LEDs off
    allLedOff()
    #and return the final time to main.py
    sendfinal = "Game over - Zeit: " +str(total)
    return sendfinal
