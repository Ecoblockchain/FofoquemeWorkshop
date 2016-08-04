import processing.serial.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import oscP5.*;
import netP5.*;

/**
 * in port = 9000
 * out port = 8000
 */

// endereço para connectar no servidor
String hostAddress = "192.168.1.104";

// mensagens para ligar ao servidor
private String myConnectPattern = "/server/connect";
private String myDisconnectPattern = "/server/disconnect";

// objetos para comunicação osc
private OscP5 oscP5;
private NetAddress myRemoteLocation;

// objeto para a porta serial
private Serial myPort;

void setup() {
  /* inicializar processing */
  size(600, 400);
  frameRate(30);

  /* mensagens chegam na porta 9000 */
  oscP5 = new OscP5(this, 9000);
  /* mandar mensagens pra porta 8000 */
  myRemoteLocation = new NetAddress(hostAddress, 8000);

  /* conectar ao servidor */
  OscMessage myMessage = new OscMessage(myConnectPattern);
  oscP5.send(myMessage, myRemoteLocation);

  /* abrir a porta serial para falar com o Arduino */
  myPort = new Serial(this, Serial.list()[0], 19200);
}


void draw() {
  /* fundo preto */
  background(0);
}


/* todas as mensagens de OSC que chegam caem aqui */
void oscEvent(OscMessage theOscMessage) {
  // checar se a mensagem é pra ser mandada pro arduino
  if (theOscMessage.addrPattern().matches("/fofoca") && theOscMessage.checkTypetag("ff")) {
    float xValue = theOscMessage.get(0).floatValue();
    float yValue = theOscMessage.get(1).floatValue();

    // imprimir os valores da mensagem
    println(theOscMessage.addrPattern()+" {"+theOscMessage.typetag()+"} = "+xValue+" "+yValue);

    // transformar os valores que entram (que são de 0.0 a 1.0), em valores de frequencia e batida
    int tValue = (int)map(xValue, 1f, 0f, 0, 500);
    int fValue = (int)map(yValue, 1f, 0f, 100, 2000);
    // mandar pra porta serial/arduino
    myPort.write(str(tValue)+"k");
    myPort.write(str(fValue)+ "f");
  }
}

void exit() {
  /* desconectar do servidor */
  OscMessage myMessage = new OscMessage(myDisconnectPattern);
  oscP5.send(myMessage, myRemoteLocation);
  super.exit();
}

