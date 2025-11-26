# LowDAQ
### Dynamic Scriptable DAQ System

This project was born from personal neccesity. I work as an automotive test engineer by day. I frequently need to make little widgets to do one thing or another with various microcontrollers. Usually I have to chain some sort of CAN interface together with various other IO operations to make two disparate systems play nice together. I figured I could make life a bit easier for myself if I wrote a framework that'd make these things a bit easier to stand up. 

C/C++ backend, Lua frontend. 


## Authors 

* **Devin Shoemaker** - *Initial work* - [tailwag](https://github.com/tailwag)

## License

* This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details

## Libraries

* Devin Shoemaker - [STM32DuinoPWM](https://github.com/tailwag/STM32DuinoPWM)
* Devin Shoemaker - [STM32DuinoCANFD](https://github.com/tailwag/STM32DuinoCANFD)
* Arduino         - [SD Library](https://github.com/arduino-libraries/SD)
* Adafruit        - [ADS1115 Library](https://github.com/adafruit/Adafruit_ADS1X15)
* STM32Duino      - [HAL Libraries](https://github.com/stm32duino)

## Acknowledgements

* The STM32Duino Project - thank you for allowing me to program these super powerful micros with ease
* The Developers of Lua - being able to embed lua made this project so much more fun
* World of Warcraft - wouldn't have learned lua if I wasn't writing sweaty combat addons

## Examples 

The help menu:

     LowDAQ > help()
     ============================================ Low Level DAQ System ============================================
     == General Commands                                                                                         ==
     ==    exec(code)                                  - run lua code directly                                   ==
     ==    free()                                      - check used memory in kb                                 ==
     ==    help()                                      - display this menu                                       ==
     ==    testFloats()                                - print floating point number tests                       ==
     ==                                                                                                          ==
     == ADC Commands                                                                                             ==
     ==    adcList()                                   - list the configuration of the available adc channels    ==
     ==    adcRead(channel)                            - get a voltage measurement from the ADC                  ==
     ==    adcSetChannel(channel, scale, offset, unit) - set scaling and offset for a channel                    ==
     ==                                                                                                          ==
     == Human Readable CAN Commands                                                                              ==
     ==    hrcReset(canId, canDlc)                     - clear the human readable frame                          ==
     ==    hrcSend()                                   - send the hr frame                                       ==
     ==    hrcSetValue(startBit, length, type, order)  - set a value, run hrcSetValue(help) for more info        ==
     ==                                                                                                          ==
     == Job Scripting Commands                                                                                   ==
     ==    jobAdd(function(), period(ms), description) - schedule a job to occur peridically                     ==
     ==    jobList()                                   - list current jobs                                       ==
     ==    jobToggle(index, [0|1])                     - toggle a job on or off                                  ==
     ==                                                                                                          ==
     == PWM Commands                                                                                             ==
     ==    pwmInGetDuty(pin)                           - measure duty cycle of pwm input                         ==
     ==    pwmInGetFreq(pin)                           - measure frequency of pwm input                          ==
     ==    pwmInList()                                 - show state of all pwm inputs                            ==
     ==    pwmOutList()                                - show state of all pwm outputs                           ==
     ==    pwmOutSet(pin, frequency, dutycycle)        - sets up a pwm output, defaults to on                    ==
     ==    pwmOutToggle(pin, [0|1])                    - toggles a pwm output on or off                          ==
     ==                                                                                                          ==
     == Periodic CAN Frame Commands                                                                              ==
     ==    pfByteSet(id, index, value)                 - update the value of one byte                            ==
     ==    pfDlcSet(id, value)                         - update the length of a periodic frame                   ==
     ==    pfList()                                    - returns list of all periodic frames                     ==
     ==    pfTimeSet(id, ms)                           - adjust the period of a frame                            ==
     ==    pfToggle(id, [0,1])                         - toggles a periodic frame on or off                      ==
     ==                                                                                                          ==
     == RVC Commands                                                                                             ==
     ==    rvcCapVolt(value)                           - use the ECU's RVC value up to [value]                   ==
     ==    rvcDisable()                                - disable the RVC output                                  ==
     ==    rvcGetMode()                                - return the current set RVC mode                         ==
     ==    rvcGetSetpoint()                            - return the current RVC setpoint                         ==
     ==    rvcTargetSOC(value)                         - attempt to modulate RVC to target an SOC value          ==
     ==    rvcTargetVolt(value)                        - sets the rvc output to [value]                          ==
     ==                                                                                                          ==
     == Single Shot CAN Frame Commands                                                                           ==
     ==    ssSend(id, dlc, data1, data2, ...)          - send a can frame once                                   ==
     ==                                                                                                          ==
     ==============================================================================================================
