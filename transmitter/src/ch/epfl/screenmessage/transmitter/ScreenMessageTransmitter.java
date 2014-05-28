package ch.epfl.screenmessage.transmitter;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStreamReader;

public class ScreenMessageTransmitter {
	
	public final static String APP_NAME = "ScreenMessage Transmitter";
	public final static int NMBR_SQUARES_BORDER = 3;
	private final static boolean TESTING = false;
	private final static int INITIAL_DELAY = 2000;
	
	/**
	 * Usage : call with 2 arguments
	 * 
	 * @param args first argument = # of milliseconds of initial delay ; second argument = message
	 * 
	 * @throws Exception
	 */
	public static void main(String[] args) throws Exception {
		if (TESTING) {
			tests();
			return;
		}
		
		if (args == null || args.length < 2) {
			throw new IllegalArgumentException();
		}
		
		Thread.sleep(INITIAL_DELAY);
		ASCIITransmitter transmitter = new Transmitter33px();
		transmitter.setLatency(Integer.parseInt(args[0]));
        String line = null;
        
        for (int i = 1 ; i < args.length ; i++) {
        	BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(args[i]), "US-ASCII"));

            while((line = br.readLine()) != null) {
        		transmitter.setMessage(line);
        		transmitter.transmit();
            }	

            br.close();			
        }
	}
	
	private static void tests() throws Exception {
		Transmitter33px transmitter = new Transmitter33px();
		//transmitter.setMessage("Bonjour Lucas, ceci est un message code que je t envoie via l intermediaire d'une variante du QR-code, j ai volontairement omis les accents parce qu on ne sait jamais.");
		transmitter.setMessage("Bonjour Lucas, ceci est un message code que je t envoie via l intermediaire d'une variante du QR-code, j ai volontairement omis les accents parce qu on ne sait jamais. 1234567890".substring(0, 89));

		//transmitter.setMessage("???");
		// ? = 63 - 00111111
		/*
		 * checksum
		 * (63*65599 + 63)*65599 + 63
	     * 111111 00011111 01000100 11100000 01111111
		 */
		
		transmitter.transmit();
	}
	

}
