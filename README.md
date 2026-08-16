# FPGA-Based Automated Irrigation System Using LoRa Communication

## Project Overview

This project implements a LoRa-based communication system with an FPGA for receiving and processing sensor-related data.

An Arduino generates numeric data and sends it to a LoRa module using serial communication. The data is transmitted wirelessly to another LoRa module connected to the FPGA. On the FPGA side, a Verilog-based UART receiver captures the incoming data, and an FSM-based parser identifies the LoRa `+RCV=` response format and extracts the received payload.

## System Architecture

```text
Arduino
   |
   | SoftwareSerial
   | 9600 baud
   v
LoRa Transmitter
   |
   | Wireless LoRa Communication
   v
LoRa Receiver
   |
   | UART
   v
FPGA / ZedBoard
   |
   v
UART Receiver (rx_module)
   |
   v
LoRa Data Parser (lora_uart)
   |
   v
Payload Extraction
   |
   v
LED Output
```
## FPGA Processing

The FPGA implementation consists of two main Verilog modules:

1. UART Receiver - rx_module.v

The UART receiver:

Synchronizes the incoming serial signal.
Detects the UART start bit.
Receives 8 data bits.
Checks the stop bit.
Operates at 9600 baud with a 100 MHz FPGA clock.
Generates a data_valid signal when a byte is successfully received.
2. LoRa UART Parser - lora_uart.v

The parser processes the data received from the UART module and identifies the LoRa receiver response format:

+RCV=address,length,payload

An FSM is used to process the received message through the following states:

IDLE → HEADER → ADDR → LENGTH → PAYLOAD → DONE

The parser extracts the numeric payload and provides the processed result through the led[7:0] output.

## My Contribution

I worked on the LoRa-to-FPGA interfacing using UART. I implemented the UART receiver and the Verilog FSM-based LoRa data parser to receive, identify, and extract the payload from the LoRa receiver data.

## Technologies Used
Verilog HDL
FPGA / ZedBoard
UART
LoRa Communication
Arduino
SoftwareSerial
Xilinx Vivado
ModelSim
Repository Structure
```text
├── Arduino/
│   └── lora_transmitter.ino
│
├── FPGA/
│   ├── lora_uart.v
│   └── rx_module.v
│
├── Documentation/
│   └── Project_Report.pdf
│
└── README.md
```
## Documentation

The complete project report is available in the Documentation folder.

## Project Domain

FPGA Design | Embedded Systems | LoRa Communication | UART | Smart Agriculture
