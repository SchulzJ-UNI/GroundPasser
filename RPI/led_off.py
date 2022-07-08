import neopixel
import board
import time
import random

#initialize the led stripes on GPIO pin 12 and 18
ledLU = neopixel.NeoPixel(board.D18, 25)
ledLO = neopixel.NeoPixel(board.D12, 25)

#turn off the led stripes
ledLU.fill((0,0,0))
ledLO.fill((0,0,0))

print("Licht von Tor aus")

