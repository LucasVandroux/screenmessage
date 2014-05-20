package ch.epfl.screenmessage.transmitter;

import java.awt.Frame;
import java.io.UnsupportedEncodingException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.BitSet;
import java.util.List;

import javax.swing.JFrame;

/**
 * Takes care of encoding the message into bits, generating headers, and then 
 * creating the encoded message.
 * 
 * @author Lucas Vandroux
 * @author Mickaël Misbach
 */
public class Transmitter33px extends JFrame implements ASCIITransmitter {
	
	private static final long serialVersionUID = 3772000742816092712L;
	private static final int MESS_LENGTH = 89; // # of bytes
	private static final int HEAD_LENGTH = 6; //# of bytes
	private static final int MS_LATENCY = 2000; // how much time each code stays (in milliseconds).
	
	/**
	 * bytes 0, 1, 2, 3 = checksum
	 * byte 4  = sequence info
	 * byte 5 = length of message
	 */
	private byte[][] headers;
	
	/**
	 * ascii encoded characters (one per byte), the whole is the message.
	 * Splitted accordingly to the underlying EncodedMessage.
	 */
	private byte[][] messages;
	
	/**
	 * Initialized the JFrame.
	 */
	public Transmitter33px() {
		super(ScreenMessageTransmitter.APP_NAME);
		setUndecorated(true);
		setExtendedState(Frame.MAXIMIZED_BOTH);
		setName(ScreenMessageTransmitter.APP_NAME);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	}
	
	/**
	 * Initialized the JFrame, and sets a message.
	 * 
	 * @param message message to be transmitted
	 */
	public Transmitter33px(String message) {
		this();
		this.setMessage(message);
	}
	
	/**
	 * Converts a string message to ascii-encoded byte array.
	 * @param m
	 * @return
	 */
	private byte[][] processMessage(String m) {	
		int nbMessages = m.length() / MESS_LENGTH;
		if (m.length() % MESS_LENGTH != 0) {
			nbMessages++;
		}
		
		byte[][] messages = new byte[nbMessages][];
		byte[] fullMessage = null;
		
		try {
			fullMessage = m.getBytes("US-ASCII");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			System.exit(ERROR);
		}
		
		// for every splits except the last one
		for (int i = 0 ; i < messages.length - 1; i++) {
			messages[i] = Arrays.copyOfRange(fullMessage, i*MESS_LENGTH, (i+1)*MESS_LENGTH);
		}
		
		// last split
		messages[messages.length - 1] = Arrays.copyOfRange(fullMessage, 
				(messages.length - 1)*MESS_LENGTH, 
				fullMessage.length);
		for (int i = 0 ; i < messages[0].length ; i++)
		System.out.print(Integer.toBinaryString(messages[0][i]&0xff));
		System.out.println();
		return messages;
	}
	
	/**
	 * Initializes headers:
	 * bytes 0, 1, 2, 3 = checksum
	 * byte 4  = sequence info
	 * byte 5 = length of message
	 * 
	 * @return the headers.
	 */
	private byte[][] processHeader() {
		byte[][] headers = new byte[this.messages.length][HEAD_LENGTH];
		
		for (int i = 0 ; i < headers.length ; i++) {
			// bytes 0, 1, 2, 3 = checksum
			byte[] checksum = this.getChecksum(this.messages[i]);
			for (int h = 0 ; h < 4 ; h++) {
				headers[i][h] = checksum[h];
			}
			
			// byte 4 = sequence info
			boolean last = (i == headers.length - 1) ? true : false;
			headers[i][4] = this.getSequenceInfo((byte) i, last);
			
			// byte 5 = length
			if (this.messages.length > Byte.MAX_VALUE) {
				// the byte is signed, but in this implementation should never go over 127 
				throw new IllegalStateException();
			}
			headers[i][5] = (byte) this.messages[i].length;
			
			System.out.println("Header #"+i+" processed: checksum="+
			Integer.toBinaryString(headers[i][0]&0xff)+"-"+
			Integer.toBinaryString(headers[i][1]&0xff)+"-"+
			Integer.toBinaryString(headers[i][2]&0xff)+"-"+
			Integer.toBinaryString(headers[i][3]&0xff));
			System.out.println("sequence info = "+Integer.toBinaryString(headers[i][4]&0xff));
			System.out.println("length = "+Integer.toBinaryString(headers[i][5]&0xff));
		}
		
		return headers;
	}
	
	/**
	 * the maximum value for the parameter is 127, full 1 bits on 7 bits
	 * 
	 * 
	 * @return
	 */
	private byte getSequenceInfo(byte seqNum, boolean isLast) {
		BitSet bs = BitSet.valueOf(new byte[]{seqNum});
		bs.set(7, isLast);
		
		if (bs.isEmpty()) {
			return 0;
		}
		
		return bs.toByteArray()[0];
	}

	/**
	 * It is computed using SDBM algorithm, on the 91 following bytes.
	 * Tt is an unsigned 32 bits integer.
	 * @param bs
	 * @return
	 */
	private byte[] getChecksum(byte[] bs) {
	    Long checksum = 0L;
	    for (int i = 0 ; i < bs.length ; i++) {
	    	checksum = checksum*65599 + bs[i];
	    }
	    
	    byte[] a = ByteBuffer.allocate(8).putLong(checksum).array();
	    
		return new byte[]{a[4], a[5], a[6], a[7]};
	}

	@Override
	public void setMessage(String message) {
		this.messages = this.processMessage(message);
		this.headers = this.processHeader();		
	}

	@Override
	public void transmit() throws Exception {
		List<EncodedMessage33px> list = new ArrayList<>();
		
		for (int i = 0; i < this.messages.length; i++) {
			byte[] h = this.headers[i];
			byte[] m = this.messages[i];
			byte[] data = new byte[h.length + m.length];
			
			System.arraycopy(h, 0, data, 0, h.length);
			System.arraycopy(m, 0, data, h.length, m.length);
			
			list.add(new EncodedMessage33px(data));
		}
		
		for (EncodedMessage33px encodedMessage33px : list) {
			getContentPane().removeAll();
			getContentPane().add(encodedMessage33px);
			this.validate();
			this.setVisible(true);
			Thread.sleep(MS_LATENCY);
		}
	}
}
