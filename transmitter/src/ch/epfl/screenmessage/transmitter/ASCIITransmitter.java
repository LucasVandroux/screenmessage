package ch.epfl.screenmessage.transmitter;

/**
 * Defines a transmitter of strings, encoded in ASCII.
 * 
 * @author Lucas Vandroux
 * @author Mickaël Misbach
 */
public interface ASCIITransmitter {
	
	/**
	 * Sets the message to be transmitted.
	 * 
	 * @param message to be transmitted
	 */
	public void setMessage(String message);
	
	/**
	 * Transmits the message.
	 * 
	 * @throws Exception if transmitting fails
	 */
	public void transmit() throws Exception;
	
	public void setLatency(int latency);
}
