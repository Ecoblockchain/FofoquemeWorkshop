/**
 */

import oscP5.*;
import netP5.*;

private OscP5 oscP5;
private NetAddress myRemoteLocation;

String lastOsc = "";

void setup() {
  /* inicialização do processing */
  size(600, 200);
  frameRate(25);
  textFont(createFont(PFont.list()[0], 18));

  /* inicializar um objeto de osc, que escuta por mensagens na porta 9000 */
  oscP5 = new OscP5(this, 9000);
}

void draw() {
  /* desenha um fundo preto e o texto com a ultima mensagem de OSC que recebemos */
  background(0);
  text(lastOsc, 10, 18);
}

/* todas as mensagens de OSC que chegam caem aqui */
void oscEvent(OscMessage theOscMessage) {
  lastOsc = "";

  /* montar uma frase com o nome da mensagem de osc e os tipos das variáveis que chegaram */
  lastOsc = lastOsc.concat("OSC : ");
  lastOsc = lastOsc.concat("nome{"+theOscMessage.addrPattern()+"} ");
  lastOsc = lastOsc.concat("variáveis{"+theOscMessage.typetag()+"} ");

  float ox=0, oy=0, oz=0;

  /* pegar o valor das variáveis */
  if (theOscMessage.checkTypetag("fff")) {
    /* pegar o valor das variáveis */
    ox = theOscMessage.get(0).floatValue();
    oy = theOscMessage.get(1).floatValue();
    oz = theOscMessage.get(2).floatValue();
    lastOsc = lastOsc.concat("valores{"+ox+" "+oy+" "+oz+"} ");
  }
  else if (theOscMessage.checkTypetag("ff")) {
    /* pegar o valor das variáveis */
    ox = theOscMessage.get(0).floatValue();
    oy = theOscMessage.get(1).floatValue();  
    lastOsc = lastOsc.concat("valores{"+ox+" "+oy+"} ");
  }
  else if (theOscMessage.checkTypetag("f")) {
    /* pegar o valor das variáveis */
    ox = theOscMessage.get(0).floatValue();
    lastOsc = lastOsc.concat("valor{"+ox+"} ");
  }
  else if (theOscMessage.checkTypetag("i")) {
    /* pegar o valor das variáveis */
    ox = (float)theOscMessage.get(0).intValue();
    lastOsc = lastOsc.concat("valor{"+ox+"} ");
  }

  println(lastOsc);
}

