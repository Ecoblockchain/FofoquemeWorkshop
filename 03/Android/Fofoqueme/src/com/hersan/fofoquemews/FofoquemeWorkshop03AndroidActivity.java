package com.hersan.fofoquemews;

import java.util.LinkedList;
import java.util.Queue;

import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;

import processing.core.PApplet;
import oscP5.*;
import netP5.*;

public class FofoquemeWorkshop03AndroidActivity extends PApplet {

	private OscP5 oscP5;
	private NetAddressList myNetAddressList = new NetAddressList();
	/* listeningPort is the port the server is listening for incoming messages */
	private int myListeningPort = 8000;
	/* the broadcast port is the port the clients should listen for incoming messages from the server*/
	private int myBroadcastPort = 9000;

	private String myConnectPattern = "/server/connect";
	private String myDisconnectPattern = "/server/disconnect";
	private String myBroadcastPattern = "/fofoca";

	private Queue<String> msgQueue = null;
	private long lastTime;
	private int clientCnt = 0;

	/** for creating a menu object */
	@Override
	public boolean onCreateOptionsMenu (Menu menu){
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(com.hersan.fofoquemews.R.menu.menu, menu);
		return true;
	}

	/** for handling menu item clicks */
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// Handle item selection
		switch (item.getItemId()) {
		case com.hersan.fofoquemews.R.id.quitbutton:
			finish();
			return true;
		default: 
			return false;
		}
	}

	@Override
	public void setup(){
		oscP5 = new OscP5(this, myListeningPort);
		// new message queue
		msgQueue = (msgQueue == null)?(new LinkedList<String>()):msgQueue;
		// start thread...
		new Thread(new Runnable(){
			@Override
			public void run(){
				FofoquemeWorkshop03AndroidActivity.this.queueListener();
			}
		}).start();

	}

	@Override
	public void draw(){
		background(0);
	}

	// 
	// queue listener
	private void queueListener(){
		while(true){
			if((System.currentTimeMillis() - lastTime) > 300){
				if(msgQueue.peek() != null){
					System.out.println("### popping queue: "+msgQueue.peek());
					OscMessage myMessage = new OscMessage("/fofoca");
					 myMessage.add(msgQueue.poll());
					 oscP5.send(myMessage, myNetAddressList.get(clientCnt));
					 clientCnt += 1;
					 clientCnt = (clientCnt < myNetAddressList.size())?clientCnt:0;
					 lastTime = System.currentTimeMillis();
				}
			}		
		}
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
		else if (theOscMessage.addrPattern().equals(myBroadcastPattern)) {
			System.out.println("###: adding to queue from "+theOscMessage.netAddress().address());
			String fofoca = theOscMessage.get(0).stringValue();
			String[] words = fofoca.split(" ");

			for(int i=0; i<words.length; i++){
				msgQueue.offer(words[i]);
			}

			/*
			for(int i=0; i<myNetAddressList.size(); i++){
				  OscMessage myMessage = new OscMessage("/fofoca");
				  myMessage.add(words[i%(words.length)]);
				  // send the message 
				  oscP5.send(myMessage, myNetAddressList.get(i));
			}
			 */
		}
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
}
