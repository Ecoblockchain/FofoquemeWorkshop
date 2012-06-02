public class TextBox {
  //////////////////
  static final int SMALLFONT  = 20;

  // text box dimension
  static final int   NUMLINES = 4;
  static final float BOXWIDTH = 0.8;  // percent of width

  private PFont myFont;
  private float boxX, boxW, textY;

  private String theMessage = "";

  public TextBox() {
    myFont = createFont(PFont.list()[0], SMALLFONT, true);
    // some constant stuff
    boxX = (1-BOXWIDTH)/2*width;
    boxW = BOXWIDTH*width;
    textY = height/4;
  }

  // draw a text input box and a send button
  public void draw() {
    background(0);

    // text box
    stroke(128);
    fill(128);
    rect(boxX, textY, boxW, NUMLINES*SMALLFONT);

    stroke(128);
    fill(255);
    rect(boxX-1, textY, boxW, NUMLINES*SMALLFONT);

    // the message
    textAlign(LEFT, TOP);
    textFont(myFont, SMALLFONT);
    fill(0);
    text(theMessage.toUpperCase(), boxX+2, textY+1, boxW-4, SMALLFONT*(NUMLINES-1));
  }

  public void clearMessage() {
    theMessage = "";
  }

  public String getMessage() {
    return theMessage;
  }

  void keyReleased(char mykey) {
    // on backspace, clear last char
    if (mykey == BACKSPACE) {
      if (theMessage.length() > 0) {
        theMessage = theMessage.substring(0, theMessage.length()-1);
      }
    }
    // on delete, clear string
    else if (mykey == DELETE) {
      theMessage = new String("");
    }
    // on key, add key to string
    else {
      if (theMessage.length() < 140) {
        theMessage = theMessage.toString()+(String.valueOf(mykey));
      }
    }
  }
};

