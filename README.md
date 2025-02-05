**Project Documentation: Multi-Mode Microprocessor System**

![Proteus_Pic](https://github.com/saeedvft/Multi-Mode-Microprocessor-System/blob/main/mode_b.png)
---

### **1. Introduction**

The goal of this project is to design and implement a microprocessor-based system with three distinct operating modes. The system incorporates a keypad for user input, two 7-segment displays for output, and a relay (or LED) to indicate specific states. The system switches between modes using dedicated keypad inputs and performs unique functionalities in each mode:

- **Mode A**: Displays a scrolling text (e.g., the user’s name) across the 7-segment displays, mimicking a marquee.
- **Mode B**: Operates as a timer, counting seconds from 0 to 60. In even seconds, the decimal point (DP) of the 7-segment display is illuminated, and it is turned off during odd seconds.
- **Mode C**: Functions as a digital lock. The user enters a two-digit code via the keypad, which is checked against a pre-stored password in memory. If the entered code matches, the relay (or LED) is activated to simulate unlocking the door.

The system initializes in Mode A upon power-up.

---

### **2. System Design**

#### **2.1 Hardware Components**
1. **Microcontroller**: ATMEGA32
2. **Keypad**: 4x3 or 4x4 matrix keypad for user input
3. **7-Segment Displays**: Two common-anode or common-cathode 7-segment displays
4. **Relay or LED**: Used to simulate door lock/unlock
5. **Power Supply**: 5V DC for the microcontroller and peripherals
6. **Resistors**: Current-limiting resistors for 7-segment displays

#### **2.2 Circuit Connections**
- **Keypad**: Connected to PORTD for scanning rows and columns.
- **7-Segment Displays**: Connected to PORTA and PORTB. Multiplexing is used to drive the displays.
- **Relay/LED**: Connected to PORTC.
- **Microcontroller Pins**: Configured for input (keypad) and output (7-segment displays and relay/LED).

---

### **3. Implementation Details**

#### **3.1 Initialization**
- Stack pointer initialized.
- I/O ports configured:
  - PORTA and PORTB as output for 7-segment displays.
  - PORTC as output for relay/LED.
  - PORTD as input for the keypad.
- Pre-stored password set in memory.

#### **3.2 Mode A: Scrolling Text**
- Text (e.g., "Saeed") is stored in memory.
- Characters are displayed one at a time by shifting the text across the 7-segment displays.
- A delay function is used to control the speed of scrolling.

#### **3.3 Mode B: Timer**
- Timer0 is configured in CTC mode with a prescaler to achieve a 1-second delay.
- A counter increments from 0 to 60.
- Even/odd second detection toggles the DP pin of the 7-segment display.
- After reaching 60 seconds, the timer resets.

#### **3.4 Mode C: Digital Lock**
- The user enters a two-digit code via the keypad.
- The code is displayed on the 7-segment displays in real-time.
- The entered code is compared with the pre-stored password.
  - If matched, the green LED is activated for a few seconds.
  - If not matched, an error indicator is displayed (red LED is activated for a few seconds).

#### **3.5 Mode Switching**
- Keypad buttons `+`, `-`, and `*` are used to switch to Modes A, B, and C, respectively.
- Debouncing is handled via software delays.

---

### **4. Challenges**

1. **Keypad Debouncing**: Spurious signals from the keypad were mitigated using delays and software filtering.
2. **Multiplexing Displays**: Ensuring clear and flicker-free display required careful timing and synchronization.
3. **Precise Timing**: Achieving accurate 1-second delays for the timer mode was challenging and addressed using Timer0 in CTC mode.
4. **Memory Management**: Efficient use of registers and RAM for storing intermediate data and passwords.
5. **User Experience**: Ensuring smooth transitions between modes and responsive keypad inputs.

---

### **5. Conclusion**

This project demonstrates a versatile microprocessor-based system capable of performing multiple tasks using minimal hardware resources. The implementation of three distinct modes showcases the system's flexibility and practical utility in real-world applications, such as digital signage, timing, and security systems.

### **Future Enhancements**
1. Add buzzer feedback for invalid inputs in Mode C.
2. Implement EEPROM for persistent storage of the password.
3. Add additional text scrolling effects in Mode A.
4. Use an RTC (Real-Time Clock) module for precise timekeeping in Mode B.
