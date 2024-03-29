/*
 www.ArduCopter.com - www.DIYDrones.com
 Copyright (c) 2010.  All rights reserved.
 An Open Source Arduino based multicopter.
 
 File     : CLI.pde
 Version  : v1.0, Oct 18, 2010
 Author(s): ArduCopter Team
 Jani Hirvinen, Jose Julio, Jordi Muñoz,
 Ken McEwans, Roberto Navoni, Sandro Benigno, Chris Anderson, Randy McEvans
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 
 * ************************************************************** *
 ChangeLog:
 - 19-10-10 Initial CLI
 
 * ************************************************************** *
 TODO:
 - Full menu systems, debug, settings
 
 * ************************************************************** */


boolean ShowMainMenu;


// CLI Functions
// This can be moved later to CLI.pde
void RunCLI () {

  //  APM_RC.Init();             // APM Radio initialization

  readUserConfig();          // Read memory values from EEPROM

  ShowMainMenu = TRUE;
  // We need to initialize Serial again due it was not initialized during startup. 
  SerBeg(SerBau);   
  SerPrln();
  SerPrln("Welcome to ArduCopter CLI"); 
  SerPri("Firmware: ");
  SerPrln(VER);
  SerPrln();
  SerPrln("Make sure that you have Carriage Return active");

  if(ShowMainMenu) Show_MainMenu();

  // Our main loop that never ends. Only way to get away from here is to reboot APM
  for (;;) { 

    if(ShowMainMenu) Show_MainMenu();   

    delay(50); 
    if (SerAva()) {
      ShowMainMenu = TRUE;
      queryType = SerRea();
      switch (queryType) {
      case 'a':
        Flip_MAG();
        break;
      case 'c':
        CALIB_CompassOffset();
        break;
      case 'd':
        Log_Read(1,4000);
        break;        
      case 'i':
        CALIB_AccOffset();
        break;
      case 't':
        CALIB_Throttle();  
        break;
      case 'e':
        CALIB_Esc();
        break; 
      case 'o':
        Set_SonarAndObstacleAvoidance_PIDs();
        break;
      case 'h':
        SHOW_rpyPIDs();
        break;
      case 'p':
        SET_PIDs();
        break;
      case 's':
        Show_Settings();
        break;
      case 'r':
        Reset_Settings();
        break;
      case 'm':
        RUN_Motors();
        break;
      case 'z':
        Log_Erase();
        break;        
      }
      SerFlu();
    }

    // Changing LED statuses to inform that we are in CLI mode
    // Blinking Red, Yellow, Green when in CLI mode
    if(millis() - cli_timer > 1000) {
      cli_timer = millis();
      CLILedStep();
    }
  } // Mainloop ends
}




void Show_MainMenu() {
  ShowMainMenu = FALSE; 
  SerPrln();
  SerPrln("CLI Menu - Type your command on command prompt");
  SerPrln("----------------------------------------------");
  SerPrln(" a - Activate/Deactivate compass (check #IsMag define too)");
  SerPrln(" c - Show/Save compass offsets");
  SerPrln(" d - dump logs to serial");  
  SerPrln(" e - ESC Throttle calibration (Works with official ArduCopter ESCs)");
  SerPrln(" i - Initialize and calibrate Accel offsets");
  SerPrln(" m - Motor tester with AIL/ELE stick");
  SerPrln(" o - Show/Save sonar & obstacle avoidance PIDs");
  SerPrln(" h - Show roll's, pitch's and yaw's PIDs");
  SerPrln(" p - change roll's, pitch's and yaw's PIDs");
  SerPrln(" r - Reset to factory settings");
  SerPrln(" t - Calibrate MIN Throttle value");
  SerPrln(" s - Show settings");
  SerPrln(" z - clear all logs");  
  SerPrln(" ");
  SerFlu();
}

/* ******************************************************* */
// this function contians a serias of 'cases'. the hierarchy is: 
// Axis selection (r for Roll, p for Pitch or y for Yaw) then >>
// Variable assignment

void SET_PIDs()
{
  // the temporary value for reading the command from the serial before updating the EEPROM
  float tempVal;
  SerPrln("Please enter the asix's name ('r' for ROLL, 'p' for PITCH and 'y' for YAW) that you want to change or 'q' to quit");
  SerPrln();
  // flushing the serial's buffer before input
  SerFlu();
  //wait's for input
  while (!SerAva()) {
    // when new char has arrived place it in var queryType(char) to choose asix
    queryType = SerRea();
    // case for the command - choosing between rool, pitch and yaw.
    // after selecting the desired axis 3 parameters are to be updated: P,I and D.
    switch (queryType) {
    case 'r':
      // the three following section are the ROLL's PIDs
      // P Roll
      SerPri("Please enter the p roll value or -1 to skip, the current value is: ");
      SerPrln(KP_QUAD_ROLL);
      SerFlu();
      while( !SerAva() );
      tempVal = readFloatSerial();
      if (tempVal >= 0 )
      {
        KP_QUAD_ROLL = tempVal;
        writeEEPROM(KP_QUAD_ROLL, KP_QUAD_ROLL_ADR);
        SerPri("the new p roll value is: ");
        SerPrln(KP_QUAD_ROLL);
      }
      SerPrln();
      
      // I Roll
      SerPrln("Please enter the i roll value or -1 to skip, the current value is: ");
      SerPrln(KI_QUAD_ROLL);
      SerFlu();
      while( !SerAva() );
      tempVal = readFloatSerial();
      if (tempVal >= 0 )
      {
        KI_QUAD_ROLL = tempVal;
        writeEEPROM(KI_QUAD_ROLL, KI_QUAD_ROLL_ADR);
        SerPrln("the new i roll value is ");
        SerPrln(KI_QUAD_ROLL);
      }
      SerPrln();
      
      // D Roll
      SerPrln("Please enter the d roll value or -1 to skip, the current value is: ");
      SerPrln(STABLE_MODE_KP_RATE_ROLL);
      SerFlu();
      while( !SerAva() );
      tempVal = readFloatSerial();
      if (tempVal >= 0 )
      {
        STABLE_MODE_KP_RATE_ROLL = tempVal;
        writeEEPROM(STABLE_MODE_KP_RATE_ROLL, STABLE_MODE_KP_RATE_ROLL_ADR);
        SerPrln("the new d roll value is ");
        SerPrln(STABLE_MODE_KP_RATE_ROLL);
      }
      SerPrln();
      break;
      
      case 'p':
      // the three following section are the PITCH's PIDs
      // P pitch
      SerPri("Please enter the p pitch value or -1 to skip, the current value is: ");
      SerPrln(KP_QUAD_PITCH);
      SerFlu();
      while( !SerAva() );
      tempVal = readFloatSerial();
      if (tempVal >= 0 )
      {
        KP_QUAD_PITCH = tempVal;
        writeEEPROM(KP_QUAD_PITCH, KP_QUAD_PITCH_ADR);
        SerPri("the new p pitch value is: ");
        SerPrln(KP_QUAD_PITCH);
      }
      SerPrln();
      
      // I Pitch
      SerPrln("Please enter the i pitch value or -1 to skip, the current value is: ");
      SerPrln(KI_QUAD_PITCH);
      SerFlu();
      while( !SerAva() );
      tempVal = readFloatSerial();
      if (tempVal >= 0 )
      {
        KI_QUAD_PITCH = tempVal;
        writeEEPROM(KI_QUAD_PITCH, KI_QUAD_PITCH_ADR);
        SerPrln("the new i pitch value is ");
        SerPrln(KI_QUAD_PITCH);
      }
      SerPrln();
      
      // D Pitch
      SerPrln("Please enter the d pitch value or -1 to skip, the current value is: ");
      SerPrln(STABLE_MODE_KP_RATE_PITCH);
      SerFlu();
      while( !SerAva() );
      tempVal = readFloatSerial();
      if (tempVal >= 0 )
      {
        STABLE_MODE_KP_RATE_PITCH = tempVal;
        writeEEPROM(STABLE_MODE_KP_RATE_PITCH, STABLE_MODE_KP_RATE_PITCH_ADR);
        SerPrln("the new d pitch value is ");
        SerPrln(STABLE_MODE_KP_RATE_PITCH);
      }
      SerPrln();
      break;
      
      case 'y':
      // the three following section are the YAW's PIDs
      // P Yaw
      SerPri("Please enter the p yaw value or -1 to skip, the current value is: ");
      SerPrln(KP_QUAD_YAW);
      SerFlu();
      while( !SerAva() );
      tempVal = readFloatSerial();
      if (tempVal >= 0 )
      {
        KP_QUAD_YAW = tempVal;
        writeEEPROM(KP_QUAD_YAW, KP_QUAD_YAW_ADR);
        SerPri("the new p yaw value is: ");
        SerPrln(KP_QUAD_YAW);
      }
      SerPrln();
      
      // I yaw
      SerPrln("Please enter the i yaw value or -1 to skip, the current value is: ");
      SerPrln(KI_QUAD_YAW);
      SerFlu();
      while( !SerAva() );
      tempVal = readFloatSerial();
      if (tempVal >= 0 )
      {
        KI_QUAD_YAW = tempVal;
        writeEEPROM(KI_QUAD_YAW, KI_QUAD_YAW_ADR);
        SerPrln("the new i yaw value is ");
        SerPrln(KI_QUAD_YAW);
      }
      SerPrln();
      
      // D yaw
      SerPrln("Please enter the d yaw value or -1 to skip, the current value is: ");
      SerPrln(STABLE_MODE_KP_RATE_YAW);
      SerFlu();
      while( !SerAva() );
      tempVal = readFloatSerial();
      if (tempVal >= 0 )
      {
        STABLE_MODE_KP_RATE_YAW = tempVal;
        writeEEPROM(STABLE_MODE_KP_RATE_YAW, STABLE_MODE_KP_RATE_YAW_ADR);
        SerPrln("the new d yaw value is ");
        SerPrln(STABLE_MODE_KP_RATE_YAW);
      }
      SerPrln();
      break;
    }
  }
    
}

/* ***************************************************** */
// shows the PIDs values of the Roll, Pitch and Yaw - there for = rpy

void SHOW_rpyPIDs()
{
  // read the valuse from the EEPROM before diplaying them in order to make sure its up to date
  readUserConfig();
  
  // prints the valuse in 3 row, ROLL, PITCH and YAW. each row cintains 3 vlause: the P the I and the D.
  SerPri("The currect PID values for ");
  SerPrln(" mode are:");

  // ROLL
  SerPri("ROLL: ");
  SerPri(KP_QUAD_ROLL);
  SerPri(",");
  SerPri(KI_QUAD_ROLL);
  SerPri(",");
  SerPrln(STABLE_MODE_KP_RATE_ROLL);
  
  // PITCH  
  SerPri("PITCH: ");
  SerPri(KP_QUAD_PITCH);
  SerPri(",");
  SerPri(KI_QUAD_PITCH);
  SerPri(",");
  SerPrln(STABLE_MODE_KP_RATE_PITCH);
  
  // YAW
  SerPri("YAW: ");
  SerPri(KP_QUAD_YAW);
  SerPri(",");
  SerPri(KI_QUAD_YAW);
  SerPri(",");
  SerPrln(STABLE_MODE_KP_RATE_YAW);
  SerPrln();
  
  // just to check that all had been printed beacsue sometimes the last cahrs are not been dispayed in the Serial monitor
  SerPrln("end of PIDs");
  SerPrln();
}

/* ************************************************************** */
// Compass/Magnetometer Offset Calibration
void CALIB_CompassOffset() {

#ifdef IsMAG  
  SerPrln("Rotate/Pitch/Roll your ArduCopter untill offset variables are not");
  SerPrln("anymore changing, write down your offset values and update them ");
  SerPrln("to their correct location.  Starting in..");
  SerPrln("2 secs.");
  delay(1000);
  SerPrln("1 secs.");
  delay(1000);
  SerPrln("starting now....");

  AP_Compass.init();   // Initialization
  AP_Compass.set_orientation(MAGORIENTATION);         // set compass's orientation on aircraft
  AP_Compass.set_offsets(0,0,0);                      // set offsets to account for surrounding interference
  AP_Compass.set_declination(ToRad(MAGCALIBRATION));  // set local difference between magnetic north and true north
  int counter = 0; 

  SerFlu();
  while(1) {
    static float min[3], max[3], offset[3];
    if((millis()- timer) > 100)  {
      timer = millis();
      AP_Compass.read();
      AP_Compass.calculate(0,0);  // roll = 0, pitch = 0 for this example

      // capture min
      if( AP_Compass.mag_x < min[0] ) min[0] = AP_Compass.mag_x;
      if( AP_Compass.mag_y < min[1] ) min[1] = AP_Compass.mag_y;
      if( AP_Compass.mag_z < min[2] ) min[2] = AP_Compass.mag_z;

      // capture max
      if( AP_Compass.mag_x > max[0] ) max[0] = AP_Compass.mag_x;
      if( AP_Compass.mag_y > max[1] ) max[1] = AP_Compass.mag_y;
      if( AP_Compass.mag_z > max[2] ) max[2] = AP_Compass.mag_z;

      // calculate offsets
      offset[0] = -(max[0]+min[0])/2;
      offset[1] = -(max[1]+min[1])/2;
      offset[2] = -(max[2]+min[2])/2;

      // display all to user
      SerPri("Heading:");
      SerPri(ToDeg(AP_Compass.heading));
      SerPri("  \t(");
      SerPri(AP_Compass.mag_x);
      SerPri(",");
      SerPri(AP_Compass.mag_y);
      SerPri(",");    
      SerPri(AP_Compass.mag_z);
      SerPri(")");

      // display offsets
      SerPri("\t offsets(");
      SerPri(offset[0]);
      SerPri(",");
      SerPri(offset[1]);
      SerPri(",");
      SerPri(offset[2]);
      SerPri(")");
      SerPrln();

      if(counter == 200) {
        counter = 0;
        SerPrln();
        SerPrln("Roll and Rotate your quad untill offsets are not changing!");
        //        SerPrln("to exit from this loop, reboot your APM");        
        SerPrln();        
        delay(500);
      }
      counter++;
    }
    if(SerAva() > 0){

      mag_offset_x = offset[0];
      mag_offset_y = offset[1];
      mag_offset_z = offset[2];

      SerPrln("Saving Offsets to EEPROM");
      writeEEPROM(mag_offset_x, mag_offset_x_ADR);
      writeEEPROM(mag_offset_y, mag_offset_y_ADR);
      writeEEPROM(mag_offset_z, mag_offset_z_ADR);
      delay(500);
      SerPrln("Saved...");
      SerPrln();
      break;
    }

  }
#else
  SerPrln("Magneto module is not activated on Arducopter.pde");
  SerPrln("Check your program #definitions, upload firmware and try again!!");
  //  SerPrln("Now reboot your APM");
  //  for(;;)
  //    delay(10);
#endif      

}


/* ************************************************************** */
// Accell calibration
void CALIB_AccOffset() {

  int loopy;
  long xx = 0, xy = 0, xz = 0; 

  SerPrln("Initializing Accelerometers..");
  adc.Init();            // APM ADC library initialization
  //  delay(250);                // Giving small moment before starting

  calibrateSensors();         // Calibrate neutral values of gyros  (in Sensors.pde)

  SerPrln();
  SerPrln("Sampling 50 samples from Accelerometers, don't move your ArduCopter!");
  SerPrln("Sample:\tAcc-X\tAxx-Y\tAcc-Z");

  for(loopy = 1; loopy <= 50; loopy++) {
    SerPri("  ");
    SerPri(loopy);
    SerPri(":");
    tab();
    SerPri(xx += adc.Ch(4));
    tab();
    SerPri(xy += adc.Ch(5));
    tab();
    SerPrln(xz += adc.Ch(6));
    delay(20);
  }

  xx = xx / (loopy - 1);
  xy = xy / (loopy - 1);
  xz = xz / (loopy - 1);
  xz = xz - 407;               // Z-Axis correction
  //  xx += 42;

  acc_offset_y = xy;
  acc_offset_x = xx;
  acc_offset_z = xz;

  AN_OFFSET[3] = acc_offset_x;
  AN_OFFSET[4] = acc_offset_y;
  AN_OFFSET[5] = acc_offset_z;

  SerPrln();
  SerPrln("Offsets as follows: ");  
  SerPri("  ");
  tab();
  SerPri(acc_offset_x);
  tab();
  SerPri(acc_offset_y);
  tab();
  SerPrln(acc_offset_z);

  SerPrln("Final results as follows: ");  
  SerPri("  ");
  tab();
  SerPri(adc.Ch(4) - acc_offset_x);
  tab();
  SerPri(adc.Ch(5) - acc_offset_y);
  tab();
  SerPrln(adc.Ch(6) - acc_offset_z);
  SerPrln();
  SerPrln("Final results should be close to 0, 0, 408 if they are far (-+10) from ");
  SerPrln("those values, redo initialization or use Configurator for finetuning");
  SerPrln();
  SerPrln("Saving values to EEPROM");
  writeEEPROM(acc_offset_x, acc_offset_x_ADR);
  writeEEPROM(acc_offset_y, acc_offset_y_ADR);
  writeEEPROM(acc_offset_z, acc_offset_z_ADR);
  delay(200);
  SerPrln("Saved..");
  SerPrln();
}


void Flip_MAG() {
 SerPrln("Activate/Deactivate Magentometer!");
 SerPri("Magnetometer is now: ");
 delay(500);
 if(MAGNETOMETER == 0) {
  MAGNETOMETER = 1;
  writeEEPROM(MAGNETOMETER, MAGNETOMETER_ADR);
  SerPrln("Activated");
 } else { 
  MAGNETOMETER = 0;
  writeEEPROM(MAGNETOMETER, MAGNETOMETER_ADR);
  SerPrln("Deactivated");
 }
 delay(1000);
 SerPrln("State... saved");
  
}


void CALIB_Throttle() {
  int tmpThrottle = 1200;

  SerPrln("Move your throttle to MIN, reading starts in 3 seconds");
  delay(1000);
  SerPrln("2. ");
  delay(1000);
  SerPrln("1. ");
  delay(1000);
  SerPrln("Reading Throttle value, hit enter to exit");

  SerFlu();
  while(1) {
    ch_throttle = APM_RC.InputCh(CH_THROTTLE);
    SerPri("Throttle channel: ");
    SerPrln(ch_throttle);
    if(tmpThrottle > ch_throttle) tmpThrottle = ch_throttle;
    delay(50);
    if(SerAva() > 0){
      break; 
    }
  }

  SerPrln();
  SerPri("Lowest throttle value: ");
  SerPrln(tmpThrottle);
  SerPrln();
  SerPrln("Saving MIN_THROTTLE to EEPROM");
  writeEEPROM(tmpThrottle, MIN_THROTTLE_ADR);
  delay(200);
  SerPrln("Saved..");
  SerPrln();
}


void CALIB_Esc() {

  SerPrln("Disconnect your battery if you have it connected, keep your USB cable/Xbee connected!");
  SerPrln("After battery is disconnected hit enter key and wait more instructions:");
  SerPrln("As safety measure, unmount all your propellers before continuing!!");

  WaitSerialEnter();      

  SerPrln("Move your Throttle to maximum and connect your battery. ");
  SerPrln("after you hear beep beep tone, move your throttle to minimum and");
  SerPrln("hit enter after you are ready to disarm motors.");
  SerPrln("Arming now all motors");
  delay(500);
  SerPrln("Motors: ARMED");
  delay(200);
  SerPrln("Connect your battery and let ESCs to reboot!");
  while(1) {
    ch_throttle = APM_RC.InputCh(CH_THROTTLE);  
#if AIRFRAME == QUAD
    APM_RC.OutputCh(0, ch_throttle);    // Right motor
    APM_RC.OutputCh(1, ch_throttle);    // Left motor
    APM_RC.OutputCh(2, ch_throttle);    // Front motor
    APM_RC.OutputCh(3, ch_throttle);    // Back motor   
#endif
#if AIRFRAME == HEXA
    APM_RC.OutputCh(0, ch_throttle);    // Left Motor CW
    APM_RC.OutputCh(1, ch_throttle);    // Left Motor CCW
    APM_RC.OutputCh(2, ch_throttle);    // Right Motor CW
    APM_RC.OutputCh(3, ch_throttle);    // Right Motor CCW    
    APM_RC.OutputCh(6, ch_throttle);    // Front Motor CW
    APM_RC.OutputCh(7, ch_throttle);    // Back Motor CCW    
#endif
#if AIRFRAME == OCTA
    APM_RC.OutputCh(0, ch_throttle);    // Front Motor CW
    APM_RC.OutputCh(1, ch_throttle);    // Front Right Motor CCW
    APM_RC.OutputCh(2, ch_throttle);    // Right Motor CW
    APM_RC.OutputCh(3, ch_throttle);    // Back Right Motor CCW    
    APM_RC.OutputCh(6, ch_throttle);    // Back Motor CW
    APM_RC.OutputCh(7, ch_throttle);    // Back Left Motor CCW
    APM_RC.OutputCh(9, ch_throttle);    // Left Motor CW          // Connection PB5 on APM
    APM_RC.OutputCh(10, ch_throttle);   // Front Left Motor CCW   // Connection PE3 on APM  
#endif

    // InstantPWM => Force inmediate output on PWM signals
#if AIRFRAME == QUAD   
     // InstantPWM
    APM_RC.Force_Out0_Out1();
    APM_RC.Force_Out2_Out3();
#endif
#if ((AIRFRAME == HEXA) || (AIRFRAME == OCTA))
	      // InstantPWM
    APM_RC.Force_Out0_Out1();
    APM_RC.Force_Out2_Out3();
    APM_RC.Force_Out6_Out7();
#endif
    delay(20);
    if(SerAva() > 0){
      break; 
    }
  }

#if AIRFRAME == QUAD
    APM_RC.OutputCh(0, 900);    // Right motor
    APM_RC.OutputCh(1, 900);    // Left motor
    APM_RC.OutputCh(2, 900);    // Front motor
    APM_RC.OutputCh(3, 900);    // Back motor   
#endif
#if AIRFRAME == HEXA
    APM_RC.OutputCh(0, 900);    // Left Motor CW
    APM_RC.OutputCh(1, 900);    // Left Motor CCW
    APM_RC.OutputCh(2, 900);    // Right Motor CW
    APM_RC.OutputCh(3, 900);    // Right Motor CCW    
    APM_RC.OutputCh(6, 900);    // Front Motor CW
    APM_RC.OutputCh(7, 900);    // Back Motor CCW    
#endif 
#if AIRFRAME == OCTA
    APM_RC.OutputCh(0, 900);    // Front Motor CW
    APM_RC.OutputCh(1, 900);    // Front Right Motor CCW
    APM_RC.OutputCh(2, 900);    // Right Motor CW
    APM_RC.OutputCh(3, 900);    // Back Right Motor CCW    
    APM_RC.OutputCh(6, 900);    // Back Motor CW
    APM_RC.OutputCh(7, 900);    // Back Left Motor CCW
    APM_RC.OutputCh(9, 900);    // Left Motor CW          // Connection PB5 on APM
    APM_RC.OutputCh(10, 900);   // Front Left Motor CCW   // Connection PE3 on APM  
#endif

#if AIRFRAME == QUAD   
     // InstantPWM
    APM_RC.Force_Out0_Out1();
    APM_RC.Force_Out2_Out3();
#endif
#if ((AIRFRAME == HEXA) || (AIRFRAME == OCTA))
      // InstantPWM
    APM_RC.Force_Out0_Out1();
    APM_RC.Force_Out2_Out3();
    APM_RC.Force_Out6_Out7();
#endif

  SerPrln("Motors: DISARMED");
  SerPrln();
}


void RUN_Motors() {

  long run_timer;
  byte motor;

  SerPrln("Move your ROLL/PITCH Stick to up/down, left/right to start");
  SerPrln("corresponding motor. Motor will pulse slowly! (20% Throttle)");
  SerPrln("SAFETY!! Remove all propellers before doing stick movements");
  SerPrln();
  SerPrln("Exit from test by hiting Enter");
  SerPrln();

  SerFlu();
  while(1) {

    ch_roll = APM_RC.InputCh(CH_ROLL);
    ch_pitch = APM_RC.InputCh(CH_PITCH);

    if(ch_roll < 1400) {
      SerPrln("Left Motor");
      OutMotor(1);
      delay(500);
    }
    if(ch_roll > 1600) {
      SerPrln("Right Motor");
      OutMotor(0);
      delay(500);

    }
    if(ch_pitch < 1400) {
      SerPrln("Front Motor");
      OutMotor(2);
      delay(500);

    }
    if(ch_pitch > 1600) {
      SerPrln("Rear Motor");
      OutMotor(3);
      delay(500);

    }

    // Shuting down all motors
    APM_RC.OutputCh(0, 900);
    APM_RC.OutputCh(1, 900);
    APM_RC.OutputCh(2, 900);
    APM_RC.OutputCh(3, 900);
    APM_RC.Force_Out0_Out1();
    APM_RC.Force_Out2_Out3();

    delay(100);
    //    delay(20);
    if(SerAva() > 0){
      SerFlu();
      SerPrln("Exiting motor/esc tester...");
      break; 
    }  
  } 

}

// Just a small ESC/Motor commander 
void OutMotor(byte motor_id) {
  APM_RC.OutputCh(motor_id, 1200);
  APM_RC.Force_Out0_Out1();
  APM_RC.Force_Out2_Out3();
}


byte Reset_Settings() {
  int c;
  
  SerPrln("Reseting EEPROM to default!"); 
  delay(500);
  SerFlu();
  delay(500);
  SerPrln("Hit 'Y' to reset factory settings, any other and you will return to main menu!");
  do {
    c = SerRea();
  } 
  while (-1 == c);

  if (('y' != c) && ('Y' != c)) {
    SerPrln("EEPROM has not reseted!");
    SerPrln("Returning to main menu.");
    return(-1);
  }

  SerPrln("Reseting to factory settings!");
  defaultUserConfig();
  delay(200);
  SerPrln("Saving to EEPROM");
  writeUserConfig();
  SerPrln("Done..");

}


void Show_Settings() {
  // Reading current EEPROM values

    SerPrln("ArduCopter - Current settings");
  SerPrln("-----------------------------");
  SerPri("Firmware: ");
  SerPri(VER);
  SerPrln();
  SerPrln();

  readUserConfig();
  delay(50);

  SerPri("Magnetom. offsets (x,y,z): ");
  SerPri(mag_offset_x);
  cspc();
  SerPri(mag_offset_y);
  cspc();
  SerPri(mag_offset_z);
  SerPrln();

  SerPri("Accel offsets (x,y,z): ");
  SerPri(acc_offset_x);
  cspc();
  SerPri(acc_offset_y);
  cspc();
  SerPri(acc_offset_z);
  SerPrln();

  SerPri("Min Throttle: ");
  SerPrln(MIN_THROTTLE);

  SerPri("Magnetometer 1-ena/0-dis: ");
  SerPrln(MAGNETOMETER, DEC);

  SerPri("Camera mode: ");
  SerPrln(cam_mode, DEC);

#if AIRFRAME == QUAD  
#ifdef FLIGHT_MODE_X_45Degree
  SerPri("Flight orientation: ");
  if(SW_DIP1) {
    SerPrln("x mode_45Degree (APM front pointing towards Front motor)");
  } 
  else {
    SerPrln("+ mode");
  }
#endif 
#ifdef FLIGHT_MODE_X
  SerPri("Flight orientation: ");
  SerPrln("x mode (APM front between Front and Right motor) DIP1 not applicable");
#endif
#endif
#if AIRFRAME == HEXA  
  SerPriln("Airframe = Hexa");
#endif
#if AIRFRAME == OCTA  
  SerPriln("Airframe = Octa");
#endif

  Show_SonarAndObstacleAvoidance_PIDs();

  SerPrln();
}

// Display obstacle avoidance pids
void Show_SonarAndObstacleAvoidance_PIDs() {
  SerPri("\tSonar PID: ");
  SerPri(KP_SONAR_ALTITUDE,3); cspc();
  SerPri(KI_SONAR_ALTITUDE,3); cspc();
  SerPrln(KD_SONAR_ALTITUDE,3);
  SerPri("\tObstacle SafetyZone: ");
  SerPrln(RF_SAFETY_ZONE);
  SerPri("\tRoll PID: ");
  SerPri(KP_RF_ROLL,3); cspc();
  SerPri(KI_RF_ROLL,3); cspc();
  SerPrln(KD_RF_ROLL,3);
  SerPri("\tPitch PID: ");
  SerPri(KP_RF_PITCH,3); cspc();
  SerPri(KI_RF_PITCH,3); cspc();
  SerPri(KD_RF_PITCH,3); 
  SerPrln();
  SerPri("\tMaxAngle: "); 
  SerPri(RF_MAX_ANGLE);   
  SerPrln();  
}

// save RF pids to eeprom
void Save_SonarAndObstacleAvoidancePIDs_toEEPROM() {  
  writeEEPROM(KP_RF_ROLL,KP_RF_ROLL_ADR);
  writeEEPROM(KI_RF_ROLL,KI_RF_ROLL_ADR);  
  writeEEPROM(KD_RF_ROLL,KD_RF_ROLL_ADR);
  writeEEPROM(KP_RF_PITCH,KP_RF_PITCH_ADR);
  writeEEPROM(KI_RF_PITCH,KI_RF_PITCH_ADR);  
  writeEEPROM(KD_RF_PITCH,KD_RF_PITCH_ADR);
  writeEEPROM(RF_MAX_ANGLE,RF_MAX_ANGLE_ADR);
  writeEEPROM(RF_SAFETY_ZONE,RF_SAFETY_ZONE_ADR);
  writeEEPROM(KP_SONAR_ALTITUDE,KP_SONAR_ALTITUDE_ADR);
  writeEEPROM(KI_SONAR_ALTITUDE,KI_SONAR_ALTITUDE_ADR);
  writeEEPROM(KD_SONAR_ALTITUDE,KD_SONAR_ALTITUDE_ADR);    
}

// 
void Set_SonarAndObstacleAvoidance_PIDs() {
  float tempVal1, tempVal2, tempVal3;
  int saveToEeprom = 0;
  // Display current PID values
  SerPrln("Sonar and Obstacle Avoidance:");
  Show_SonarAndObstacleAvoidance_PIDs();
  SerPrln();
  
  // SONAR PIDs
  SerFlu();
  SerPri("Enter Sonar P;I;D; values or 0 to skip: ");
  while( !SerAva() );  // wait until user presses a key
  tempVal1 = readFloatSerial();
  tempVal2 = readFloatSerial();
  tempVal3 = readFloatSerial();
  if( tempVal1 != 0 || tempVal2 != 0 || tempVal3 != 0 ) {
      KP_SONAR_ALTITUDE = tempVal1;
      KI_SONAR_ALTITUDE = tempVal2;
      KD_SONAR_ALTITUDE = tempVal3;
      SerPrln();
      SerPri("P:");
      SerPri(KP_SONAR_ALTITUDE,3);
      SerPri("\tI:");
      SerPri(KI_SONAR_ALTITUDE,3);
      SerPri("\tD:");
      SerPri(KD_SONAR_ALTITUDE,3);
      saveToEeprom = 1;
  }
  SerPrln();    
  
  // SAFETY ZONE
  SerFlu();
  SerPri("Enter Safety Zone (in cm) or 0 to skip: ");
  while( !SerAva() );  // wait until user presses a key
  tempVal1 = readFloatSerial();
  if( tempVal1 >= 20 && tempVal1 <= 700 ) {
      RF_SAFETY_ZONE = tempVal1;
      SerPri("SafetyZone: ");
      SerPri(RF_SAFETY_ZONE,3);
      saveToEeprom = 1;   
  }
  SerPrln();      
      
  // ROLL PIDs
  SerFlu();
  SerPri("Enter Roll P;I;D; values or 0 to skip: ");
  while( !SerAva() );  // wait until user presses a key
  tempVal1 = readFloatSerial();
  tempVal2 = readFloatSerial();
  tempVal3 = readFloatSerial();
  if( tempVal1 != 0 || tempVal2 != 0 || tempVal3 != 0 ) {
      KP_RF_ROLL = tempVal1;
      KI_RF_ROLL = tempVal2;
      KD_RF_ROLL = tempVal3;
      SerPrln();
      SerPri("P:");
      SerPri(KP_RF_ROLL,3);
      SerPri("\tI:");
      SerPri(KI_RF_ROLL,3);
      SerPri("\tD:");
      SerPri(KD_RF_ROLL,3);
      saveToEeprom = 1;
  }
  SerPrln();  
  
  // PITCH PIDs
  SerFlu();
  SerPri("Enter Pitch P;I;D; values or 0 to skip: ");
  while( !SerAva() );  // wait until user presses a key
  tempVal1 = readFloatSerial();
  tempVal2 = readFloatSerial();
  tempVal3 = readFloatSerial();
  if( tempVal1 != 0 || tempVal2 != 0 || tempVal3 != 0 ) {
      KP_RF_PITCH = tempVal1;
      KI_RF_PITCH = tempVal2;
      KD_RF_PITCH = tempVal3;
      SerPrln();
      SerPri("P:");
      SerPri(KP_RF_PITCH,3);
      SerPri("\tI:");
      SerPri(KI_RF_PITCH,3);
      SerPri("\tD:");
      SerPri(KD_RF_PITCH,3);      
      saveToEeprom = 1;
  }
  SerPrln();  
  
  // Max Angle
  SerFlu();
  SerPri("Enter Max Angle or 0 to skip: ");
  while( !SerAva() );  // wait until user presses a key
  tempVal1 = readFloatSerial();
  SerPrln(tempVal1);
  if( tempVal1 > 0 && tempVal1 < 90 ) {
      RF_MAX_ANGLE = tempVal1;
      SerPrln();
      SerPri("MaxAngle: "); 
      SerPri(RF_MAX_ANGLE);     
      saveToEeprom = 1;
  }
  SerPrln();   
  
  // save to eeprom
  if( saveToEeprom == 1 ) {
      SerPrln("Obstacle Avoidance:");
      Show_SonarAndObstacleAvoidance_PIDs();
      SerPrln();
      Save_SonarAndObstacleAvoidancePIDs_toEEPROM();
      SerPrln("Saved to EEPROM");
      SerPrln();
  }else{
      SerPrln("No changes. Nothing saved to EEPROM");
      SerPrln();
  }
}

void cspc() {
  SerPri(", ");
}

void WaitSerialEnter() {
  // Flush serials
  SerFlu();
  delay(50);
  while(1) {
    if(SerAva() > 0){
      break; 
    }
    delay(20);
  }
  delay(250);
  SerFlu();  
}







