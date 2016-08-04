import ddf.minim.*;
import ddf.minim.signals.*;

/**
 * in port = 9000
 * out port = 8000
 */

import oscP5.*;
import netP5.*;

// endereço para connectar no celular, ou no servidor
String hostAddress = "192.168.1.104";

// mensagens para ligar ao servidor
private String myConnectPattern = "/server/connect";
private String myDisconnectPattern = "/server/disconnect";

private OscP5 oscP5;
private NetAddress myRemoteLocation;

// objetos de audio
private Minim minim;
private AudioOutput out;
private SineWave sine;

void setup() {
  /* inicialização do processing */
  size(600, 400);
  frameRate(30);

  /* mensagens chegam na porta 9000 */
  oscP5 = new OscP5(this, 9000);
  /* mandar mensagens pra porta 8000 */
  myRemoteLocation = new NetAddress(hostAddress, 8000);

  /* conectar ao servidor */
  OscMessage myMessage = new OscMessage(myConnectPattern);
  oscP5.send(myMessage, myRemoteLocation);

  /* inicializar objetos de som */
  minim = new Minim(this);
  // line out
  out = minim.getLineOut(Minim.STEREO);
  // sinal de som (seno). um mini sintetizador.
  sine = new SineWave(440, 0.0, out.sampleRate());
  sine.portamento(200);
  // mandar o seno pro output
  out.addSignal(sine);
}


void draw() {
  /* desenhar um fundo preto */
  background(0);
}


/* todas as mensagens de OSC que chegam caem aqui */
void oscEvent(OscMessage theOscMessage) {
  // variaveis para guardar os valores que chegam na mensagem
  float xValue=0;
  float buttonValue = -1;

  // imprimir a mesagem e suas propriedeades
  println(theOscMessage.addrPattern()+" {"+theOscMessage.typetag()+"} ");

  // black voodoo magic para pegar o nome e numero do botao que foi apertado
  if (theOscMessage.addrPattern().matches("/[a-zA-Z0-9]+/[0-9]+")) {
    String[] words = theOscMessage.addrPattern().split("/");
    buttonValue =Integer.parseInt(words[2]);
  }

  /* pegar o valor das variáveis */
  if (theOscMessage.checkTypetag("ff")) {
    xValue = theOscMessage.get(0).floatValue();
  }
  else if (theOscMessage.checkTypetag("f")) {
    xValue = theOscMessage.get(0).floatValue();
  }
  else if (theOscMessage.checkTypetag("i")) {
    xValue = (float)theOscMessage.get(0).intValue();
  }

  // imprimir os valores
  println(xValue+" "+" "+buttonValue);

  // se recebeu um valor de botão e um valor acima de zero, ligar o som
  if ((buttonValue > -1) && (xValue > 0)) {
    float freq = map(buttonValue, 0, 64, 100, 1000);
    sine.setFreq(freq);
    sine.setAmp(1.0);
  }
  // se o valor for maior que 0, desligar o som
  else {
    sine.setAmp(0);
  }
}

void exit() {
  /* desligar do servidor */
  OscMessage myMessage = new OscMessage(myDisconnectPattern);
  oscP5.send(myMessage, myRemoteLocation);
  super.exit();
}

