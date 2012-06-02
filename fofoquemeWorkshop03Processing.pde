import com.sun.speech.freetts.*;

/**
 */

import oscP5.*;
import netP5.*;

String hostAddress = "192.168.1.9";
private String myConnectPattern = "/server/connect";
private String myDisconnectPattern = "/server/disconnect";

OscP5 oscP5;
NetAddress myRemoteLocation;
Voice myVoice;
TextBox myTextBox;

String textBox = "";

void setup() {
  size(600, 400);
  frameRate(30);

  /* listening at port 9000 */
  oscP5 = new OscP5(this, 9000);
  /* send to port 8000 */
  myRemoteLocation = new NetAddress(hostAddress, 8000);

  /* new connect request */
  OscMessage myMessage = new OscMessage(myConnectPattern);
  /* send the message */
  oscP5.send(myMessage, myRemoteLocation);

  /* voice stuff */
  VoiceManager myVoiceManager = VoiceManager.getInstance();
  myVoice = myVoiceManager.getVoice("kevin16");
  myVoice.allocate();

  myTextBox = new TextBox();
}


void draw() {
  background(0);
  myTextBox.draw();
}


void keyReleased() {
  // only deal with non-coded keys
  //   things that can be displayed
  if (key != CODED) {
    // on enter, send message and clear box
    if ((key == ENTER) || (key == RETURN)) {
      // send osc message here
      OscMessage myMsg = new OscMessage("/fofoca");
      myMsg.add(myTextBox.getMessage());
      
      oscP5.send(myMsg, myRemoteLocation);
      
      myTextBox.clearMessage();
    }
    else {
      /* pass forward to text box */
      myTextBox.keyReleased(key);
    }
  }
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {

  if ((theOscMessage.addrPattern().contains("fofoca")) && (theOscMessage.checkTypetag("s") == true)) {
    String word = theOscMessage.get(0).stringValue();
    myVoice.speak(word);
    println("recebi : "+word);
  }
}

void exit() {
  myVoice.deallocate();
  /* disconnect request */
  OscMessage myMessage = new OscMessage(myDisconnectPattern);
  /* send the message */
  oscP5.send(myMessage, myRemoteLocation);
  super.exit();
}

