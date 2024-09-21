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
        usb_ports = [port for port in ports_avail if 'USB' in port.device]
    except:
        print("Error getting serial ports.")
        input("Press Enter to exit...")
        exit(1)
    
    if len(usb_ports) == 0:
        print("No USB serial ports available.")
        input("Press Enter to exit...")
        exit(1)
    elif len(usb_ports) == 1:
        print(f"Automatically selected USB port: {usb_ports[0].device}")
        return usb_ports[0].device
    else:
        print("Available USB ports:")
        for i, port in enumerate(usb_ports):
            print(f"{i + 1}. {port.device}")
        
        while True:
            try:
                choice = int(input("Select port number: "))
                if 1 <= choice <= len(usb_ports):
                    return usb_ports[choice - 1].device
                else:
                    print("Invalid choice. Please try again.")
            except ValueError:
                print("Invalid input. Please enter a number.")

