package ch.epfl.screenmessage.transmitter;

public class ScreenMessageTransmitter {
	
	public final static String APP_NAME = "ScreenMessage Transmitter";
	public final static int NMBR_SQUARES_BORDER = 3;
	
	public static void main(String[] args) {
		TransmitterFrame f = new TransmitterFrame();
		f.validate();
		System.out.println("kikoo");
		
		for (int i = 0 ; i < 200 ; i++) {
			char c = (char) i;
			int v = (int) c;
			System.out.println(c +" - "+v);
			
		}
	}

}
