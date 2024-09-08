import serial
from serial.tools import list_ports

class Uart():
    port = None
    baudrate = 19200
    data_size = 1 # one byte default
    endiantype = 'little' # little endian default

    def __init__(self, port):
        self.port = port
        self.ser = serial.Serial(
            port=self.port,
            baudrate=self.baudrate,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            bytesize=serial.EIGHTBITS,
            #timeout=1
        )


    # Read data from serial port:
    def read(self, data_size=1, byteorder = 'little'):
        res = int.from_bytes(self.ser.read(data_size), byteorder = byteorder)
        return res

    # Write data to serial port:
    def write(self, data, byteorder = 'little'):
        self.ser.write(
            int(data).to_bytes(self.data_size, byteorder = byteorder)
        )
    
    # Check if data is available to read (size of data_size):
    def check_data_available(self, data_size = 1):
        return self.ser.in_waiting >= data_size

    # Close serial port:
    def close(self):
        self.ser.close()

    # Clear input and output buffers:
    def clear(self):
        self.ser.reset_input_buffer()
        self.ser.reset_output_buffer()

if __name__ == '__main__':
    port = get_serial_port()
    uart = Uart(port)
    uart.write(0x01) # ??
    uart.close()
else:
    pass

def get_serial_port():
    try:
        ports_avail = list_ports.comports()
        ports = [port.device for port in ports_avail]
    except:
        print("Error getting serial ports.")
        input("Press Enter to exit...")
        exit(1)
    if len(ports_avail) == 0:
        print("No serial ports available.")
        input("Press Enter to try again...")
        get_serial_port()
    print("Available ports:")
    options = [f"{i + 1}. {port}" for i, port in enumerate(ports)]
    input_port = input("\n".join(options) + "\nSelect port: ")
    try:
        return ports[int(input_port) - 1]
    except:
        print("Invalid port.")
        input("Press Enter to try again...")
        get_serial_port()
