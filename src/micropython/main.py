import machine
import dht
import time
import ssd1306
import socket
LED_PIN_NB = 2
led = machine.Pin(LED_PIN_NB, machine.Pin.OUT)
led.on()

button = machine.Pin(14, machine.Pin.IN, machine.Pin.PULL_UP)

ip = 'ip-here' # i.e. x.x.x.x
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

def connect():
    global s
    if s == None:
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((ip, 6060))
# main
def display_content():
    dht22 = dht.DHT22(machine.Pin(4))
    dht22.measure()
    temp = dht22.temperature()
    humidity = dht22.humidity()

    try:
	led.off()
	time.sleep(0.2)
	led.on()
    	s.send('[to_iphone]{b}[humidity]: {h} {b}[temperature]: {t}'.format(b='[command_buffer]', h=humidity, t=temp))
    except:
	print('socket err')

def p_button():
    isDown = False

    while True:
	message = s.recv(2048).decode("utf-8")
	print(message)

	display_content()
