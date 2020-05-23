import tkinter as tk
import serial

# FIR filter things
num_filter = 13
attenutations = [1] * num_filter

# defining dictionaries for use later
data_bits_dict = {5:serial.FIVEBITS,
                  6:serial.SIXBITS,
                  7:serial.SEVENBITS,
                  8:serial.EIGHTBITS}

stopbit_dict = {1:serial.STOPBITS_ONE,
                1.5:serial.STOPBITS_ONE_POINT_FIVE,
                2: serial.STOPBITS_TWO}

parity_dict = {"None":serial.PARITY_NONE,
               "Even":serial.PARITY_EVEN,
               "Odd":serial.PARITY_ODD,
               "Mark":serial.PARITY_MARK,
               "Space":serial.PARITY_SPACE}

# array to store
params = ["Port", "Baudrate", "Data Bits", "Stop Bits", "Parity"]
serial_params={"Port":"COM5",
               "Baudrate":9600,
               "Data Bits":8,
               "Stop Bits":1,
               "Parity":"None"}
# global serial port variable
ser = serial.Serial()
ser.port="COM5"
ser.baudrate=9600
ser.bytesize=8
ser.stopbits= serial.STOPBITS_ONE
ser.parity=serial.PARITY_NONE
ser.timeout=None
ser.write_timeout=1


def config_window():
    # closing serial port
    ser.close()
    # Serial configuration parameters
    config_frame = tk.Tk()
    config_frame.title("Serial configuration parameters")

    # dictionary of tkinter variables to access text input
    tk_serial_params={"Port":tk.StringVar(config_frame),
                   "Baudrate":tk.IntVar(config_frame),
                   "Data Bits":tk.IntVar(config_frame),
                   "Stop Bits":tk.DoubleVar(config_frame),
                   "Parity":tk.StringVar(config_frame)}
    for param in params:
        tk_serial_params[param].set(serial_params[param])

    for i in range(len(params)):
        tk.Label(config_frame, text=params[i]).grid(row=i, column=0)
        temp=tk.Entry(config_frame, textvariable=tk_serial_params[params[i]]).grid(row=i, column=1)

    exit_button = tk.Button(config_frame, text='Apply', command=lambda: set_serial_params(tk_serial_params, config_frame))
    exit_button.grid(row=len(params)+1, column=2)

    config_frame.bind('<Return>', lambda e: set_serial_params(tk_serial_params, config_frame))
    config_frame.mainloop()


def set_serial_params(dict, obj):
    print("Setting new serial params")
    for param in params:
        serial_params[param]=dict[param].get()

    ser.port = serial_params["Port"]
    ser.baudrate = serial_params["Baudrate"]
    ser.bytesize = data_bits_dict[serial_params["Data Bits"]]
    ser.stopbits = stopbit_dict[serial_params["Stop Bits"]]
    ser.parity = parity_dict[serial_params["Parity"]]

    obj.destroy()



def start_eq(text_obj):
    print("Starting")
    # for i in range(len(attenutations)):
    #     int_atten = round(attenutations[i]*(1<<14))
    #     print(bytes([i, int_atten>>8, int_atten&0xff]))
    try:
        ser.open()
    except Exception as e:
        text_obj.config(text="Failed to open port", bg="#ff0000")
        return
    text_obj.config(text="Running", bg="#00ff00")
    for i in range(len(attenutations)):
        int_atten = round(attenutations[i]*(1<<14))
        print(int_atten)
        ser.write(bytes([i, int_atten>>8, int_atten&0xff]))



def stop_eq(text_obj):
    print("Stopping")
    ser.close()
    text_obj.config(text="Idle", bg="#fcfcfc")



def write_attenuations(filter_num, atten, text_obj):
    atten = float(atten)
    attenutations[filter_num]=atten
    int_atten = round(atten*(1<<14))
    print(filter_num, int_atten)
    try:
        ser.write(bytes([filter_num, int_atten>>8, int_atten&0xff]))
    except Exception as e:
        text_obj.config(text="Port not open", bg="#ff0000")
        return



def main():
    root=tk.Tk()
    base=tk.Frame(root, bd=10)
    base.pack()
    root.title('ESE465 Audio Equalizer Control')

    status = tk.Label(root, text="Idle", bd=1, relief=tk.SUNKEN, anchor=tk.W)
    status.pack(side=tk.BOTTOM, fill=tk.X)

    # Control buttons
    button_frame = tk.Frame(base, bd=5)
    settings = tk.Button(button_frame, text='Settings', command=config_window)
    settings.pack()

    start = tk.Button(button_frame, text='Start', command=lambda: start_eq(status))
    start.pack()

    stop = tk.Button(button_frame, text='Stop', command=lambda: stop_eq(status))
    stop.pack()
    button_frame.pack(side=tk.LEFT)

    # Making sliders
    slider_frame = tk.Frame(base, bd=10, relief=tk.SUNKEN)
    tk_sliders = [tk.DoubleVar(slider_frame, value=i) for i in attenutations]

    for i in list(range(num_filter)):
        tk.Label(slider_frame, text=("Band " + str(i))).grid(row=0, column=i)
        tk.Scale(slider_frame, orient=tk.VERTICAL, from_=1, to=0,
                 resolution=0.00001, tickinterval=(0.5 if i==0 else 0), length=300,
                 variable=tk_sliders[i], digits=4,
                 command=lambda val: write_attenuations(i, val, status),
                 relief="solid").grid(row=1, column=i)
        # temp = tk.Scale(slider_frame, orient=tk.VERTICAL, from_=1, to=0,
        #          resolution=0.00001, tickinterval=(0.5 if i==0 else 0), length=300,
        #          variable=tk_sliders[i], digits=4,
        #          relief="solid")
        # temp.bind("<ButtonRelease-1>", lambda z: write_attenuations(i, tk_sliders[i].get(), status))
        # temp.grid(row=1, column=i)


    slider_frame.pack(side=tk.LEFT)
    root.mainloop()



if __name__ == '__main__':
    main()
