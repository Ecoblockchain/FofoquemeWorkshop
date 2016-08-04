int value = 0;
int freq=440;
int time=10;
int pTime=300;
long lastTime;
boolean pulse = true;


void setup() {

  Serial.begin(19200);
  // percorrer todas as notas no inicio
  /*
  for (int thisNote = 0; thisNote < NUM_NOTAS  ; thisNote++) {
    tone(8, melody[thisNote]);
    delay(10);
    noTone(8);
  }*/
  
  lastTime = millis();

}


void loop() {
  int c;

  c = Serial.read();
  if ((c>='0') && (c<='9')) {
    value = 10*value + c - '0';
  } 
  else {
    if (c=='f'){ 
      freq = value;
    }
    else if(c=='t'){
      time = value;
    }
    else if(c=='p'){
      Serial.println(freq);
      tone(8, freq,time);

    }
    else if(c=='l'){
      pulse = !pulse; 
    }else if(c== 'k'){
      pTime = value;
    }
    value = 0 ;

  }
  
  
  while(!Serial.available()){
    if(pulse){
      if(millis()-lastTime > pTime){
        tone(8, freq,100);
        lastTime = millis();
      }

    } 



  }



}




