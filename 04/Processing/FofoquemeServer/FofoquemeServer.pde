import oscP5.*;
import netP5.*;

/**
 * Código para receber informação OSC de um programa e repassar para vários clientes
 * out port = 9000
 *  in port = 8000
 */

private OscP5 oscP5;
private NetAddressList myNetAddressList = new NetAddressList();
private int myBroadcastPort = 9000;

String lastOsc = "";
private String myConnectPattern = "/server/connect";
private String myDisconnectPattern = "/server/disconnect";


void setup() {
  size(400, 200);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 8000);
  //
  textFont(createFont(PFont.list()[0], 18));
}

void draw() {
  background(0);
  text("SERVER", 10, 18);
}

void oscEvent(OscMessage theOscMessage) {
  /* check if the address pattern fits any of our patterns */
  if (theOscMessage.addrPattern().equals(myConnectPattern)) {
    connect(theOscMessage.netAddress().address());
  }
  else if (theOscMessage.addrPattern().equals(myDisconnectPattern)) {
    disconnect(theOscMessage.netAddress().address());
  }
  /**
   * if pattern matching was not successful, then re-broadcast the incoming
   * message to all addresses in the netAddresList. 
   */

  else if (theOscMessage.addrPattern().matches("/[a-zA-Z0-9]+/[0-9]+") && theOscMessage.checkTypetag("ff")) {
    String[] words = theOscMessage.addrPattern().split("/");
    int buttonValue = Integer.parseInt(words[2]);
    float xv = theOscMessage.get(0).floatValue();
    float yv = theOscMessage.get(1).floatValue();

    // send to the right client
    OscMessage myOscMsg = new OscMessage("/fofoca");
    myOscMsg.add(xv);
    myOscMsg.add(yv);
    oscP5.send(myOscMsg, myNetAddressList.get(buttonValue%myNetAddressList.size()));
  }

  //println(theOscMessage.addrPattern()+" {"+theOscMessage.typetag()+"}");
}

private void connect(String theIPaddress) {
  if (!myNetAddressList.contains(theIPaddress, myBroadcastPort)) {
    myNetAddressList.add(new NetAddress(theIPaddress, myBroadcastPort));
    println("### adding "+theIPaddress+" to the list.");
  } 
  else {
    println("### "+theIPaddress+" is already connected.");
  }
  println("### currently there are "+myNetAddressList.list().size()+" remote locations connected.");
}

private void disconnect(String theIPaddress) {
  if (myNetAddressList.contains(theIPaddress, myBroadcastPort)) {
    myNetAddressList.remove(theIPaddress, myBroadcastPort);
    println("### removing "+theIPaddress+" from the list.");
  }
  else {
    println("### "+theIPaddress+" is not connected.");
  }
  println("### currently there are "+myNetAddressList.list().size());
}

