
import serial
import time
import sys


ser = serial.Serial(sys.argv[1], 1000000)
ser.flushInput()
ser.close()

ser.open()

b1 = 0
b2 = 0
val = 0

ser.write(b'5')

while 1:
	b1 = ser.read()
	b2 = ser.read()
	val = (ord(b1) << 8) + ord(b2)
	print (str(val))
