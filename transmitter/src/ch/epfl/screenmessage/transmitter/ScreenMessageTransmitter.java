package ch.epfl.screenmessage.transmitter;

public class ScreenMessageTransmitter {
	
	public final static String APP_NAME = "ScreenMessage Transmitter";
	public final static int NMBR_SQUARES_BORDER = 3;
	private final static boolean TESTING = true;
	
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
		
		if (args == null || args.length != 2) {
			throw new IllegalArgumentException();
		}
		
		Thread.sleep(Integer.parseInt(args[0]));
		ASCIITransmitter transmitter = new Transmitter33px();
		transmitter.setMessage(args[1]);
		transmitter.transmit();
	}
	
	private static void tests() throws Exception {
		ASCIITransmitter transmitter = new Transmitter33px();
		transmitter.setMessage("Bonjour Lucas, ceci est un message code que je t envoie via l intermediaire d'une variante du QR-code, j ai volontairement omis les accents parce qu on ne sait jamais. 1234567890");
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
