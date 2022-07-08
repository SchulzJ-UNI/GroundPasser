import neopixel
import board
import time
import random
from gpiozero import Button, Buzzer, LED, DigitalInputDevice, SmoothedInputDevice

#initialize the two vibration modules connected on GPIO pins 17 and 27
vibr = DigitalInputDevice (17)
vibr2 = DigitalInputDevice (27)
#initialize the led stripes on GPIO pin 12 and 18
ledLU = neopixel.NeoPixel(board.D18, 25)
ledLO = neopixel.NeoPixel(board.D12, 25)

# light up led stripes with color red
ledLU.fill((255,0,0))
ledLO.fill((255,0,0))

#wait for the first vibr module to be triggered, wait for 0.2 seconds and wait for the second one to be triggered
vibr.wait_for_active()
time.sleep(0.2)
vibr2.wait_for_active()

#turn off the led stripes
ledLU.fill((0,0,0))
ledLO.fill((0,0,0))

print("Tor getroffen")
