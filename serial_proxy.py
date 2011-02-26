#!/usr/bin/env python
import serial, sys, string

# Horrible workaround for strange bug in ruby serial port libraries, for now

START_IOPACKET   = '0x7e'

def find_packet(serial):
    if hex(ord(serial.read())) == START_IOPACKET:
        lengthMSB = ord(serial.read())
        lengthLSB = ord(serial.read())
        length = (lengthLSB + (lengthMSB << 8)) + 1
        return serial.read(length)
    else:
        return None


if len(sys.argv) == 1:
    sys.exit(["Required arg: serial dev (eg /dev/ttyUSB0)"])

serial_dev = sys.argv[1]
print("opening " + serial_dev)
serial = serial.Serial(serial_dev, 9600)
serial.open()

while True:
    packet = find_packet(serial)
    if packet:
        packet_bytes = [hex(ord(byte)) for byte in packet]
        print(string.join(packet_bytes, " "))
