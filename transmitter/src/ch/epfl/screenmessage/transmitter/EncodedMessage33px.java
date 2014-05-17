package ch.epfl.screenmessage.transmitter;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.util.Arrays;

import javax.swing.JPanel;

/**
 * A graphically encoded message, inspired by QRCode.
 * 
 * @author Lucas Vandroux
 * @author Mickaël Misbach
 *
 */
public class EncodedMessage33px extends JPanel {

	private static final long serialVersionUID = -1653211398335782405L;
	private final static boolean _ = false; // white
	private final static boolean X = true; //black
	
	/**
	 * The square matrix to use.
	 * true = white = bit 1
	 * false = black = bit 0
	 */
	private boolean[][] matrix;

	/**
	 * Initiziales with the given bytes the coded message.
	 * 
	 * @param data raw data, max 95 bytes
	 */
	public EncodedMessage33px(byte[] data) {
		if (data.length > 95) {
			throw new IllegalArgumentException();
		}
		
		this.setMatrix(this.getEmptyMatrix());
		
		for (int i = 0 ; i < data.length ; i++) {
			this.setByte(i, data[i]);
		}
	}
	
	/**
	 * 
	 * @param byteId 0 to 94 !! 95 bytes in total
	 * @param data data 
	 */
	private void setByte(int byteId, byte data) {
		int firstPos = byteId * 8;
		
		for (int i = 0 ; i < 8 ; i++) {
			String[] s = this.getBitCoords(firstPos + i).split(",");
			int u = Integer.parseInt(s[0]);
			int v = Integer.parseInt(s[1]);
			
			if ((data >> i & 1) == 1) {
				this.matrix[u][v] = true;
			} else {
				this.matrix[u][v] = false;
			}
		}
	}
	
	/**
	 * Generates the base pattern.
	 * 
	 * @return
	 */
	private boolean[][] getEmptyMatrix() {
		boolean[][] mat = new boolean[][] {
		
	//	{1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3}
		{X,X,X,X,X,X,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,X,X,X,X,X,X}, //1
		{X,_,_,_,_,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,_,_,_,_,_,X}, //2
		{X,_,X,X,X,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,_,X,X,X,_,X}, //3
		{X,_,X,X,X,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,_,X,X,X,_,X}, //4
		{X,_,X,X,X,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,_,X,X,X,_,X}, //5
		{X,_,_,_,_,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,_,_,_,_,_,X}, //6
		{X,X,X,X,X,X,X,_,X,_,X,_,X,_,X,_,X,_,X,_,X,_,X,_,X,_,X,X,X,X,X,X,X}, //7
		{_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_}, //8
		{_,_,_,_,_,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,_,_,_,_,_,_}, //9
		{_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_}, //10
		{_,_,_,_,_,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,_,_,_,_,_,_}, //11
		{_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_}, //12
		{_,_,_,_,_,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,_,_,_,_,_,_}, //13
		{_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_}, //14
		{_,_,_,_,_,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,_,_,_,_,_,_}, //15
		{_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_}, //16
		{_,_,_,_,_,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,_,_,_,_,_,_}, //17
		{_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_}, //18
		{_,_,_,_,_,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,_,_,_,_,_,_}, //19
		{_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_}, //20
		{_,_,_,_,_,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,_,_,_,_,_,_}, //21
		{_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_}, //22
		{_,_,_,_,_,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,_,_,_,_,_,_}, //23
		{_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_}, //24
		{_,_,_,_,_,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,_,_,_,_,_,_}, //25
		{_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_}, //26
		{X,X,X,X,X,X,X,_,X,_,X,_,X,_,X,_,X,_,X,_,X,_,X,_,X,_,X,_,X,_,X,_,X}, //27
		{X,_,_,_,_,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_}, //28
		{X,_,X,X,X,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,_,_,_,_,_,_}, //29
		{X,_,X,X,X,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_}, //30
		{X,_,X,X,X,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,_,_,_,_,_,_}, //31
		{X,_,_,_,_,_,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_}, //32
		{X,X,X,X,X,X,X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,_,_,_,_,_,_}, //33
		}; 
		
		return mat;
	}
	
	/**
	 * will return string formatted like : 33,211
	 * 
	 * From 0 to 759 : 95 bytes
	 * 
	 * @param pos
	 * @return
	 */
	private String getBitCoords(int pos) {
		
		if (pos >= 0 && pos <= 101) {
			//area west
			return (pos / 6 + 8) + "," + (pos % 6);
		} else if (pos >= 102 && pos <= 203) {	
			//area east
			pos -= 102;
			return (pos / 6 + 8) + "," + (pos % 6 + 27);
		} else if (pos >= 204 && pos <= 305) {
			//area south
			pos -= 204;
			return (pos / 17 + 27) + "," + (pos % 17 + 8);
		} else if (pos >= 306 && pos <= 407) {
			//area north
			pos -= 306;
			return (pos / 17) + "," + (pos % 17 + 8);
		} else if (pos >= 408 && pos <= 730) {
			//area center
			pos -= 408;
			return (pos / 19 + 8) + "," + (pos % 19 + 7);
		} else if (pos >= 731 && pos <= 747) {
			// area upper center
			pos -= 731;
			return (pos / 17 + 7) + "," + (pos % 17 + 8);
		} else if (pos >= 748 && pos <= 759) {
			//area lower center
			pos -= 748;
			return (pos / 12 + 25) + "," + (pos % 12 + 8);
		} else {
			throw new IllegalArgumentException();
		}
	}
	
	/**
	 * Paints the JPanel with the QRCode.
	 */
	@Override
	public void paintComponent(Graphics g) {
		if (this.matrix == null || this.getHeight() > this.getWidth()) {
			throw new IllegalStateException();
		}
		
		super.paintComponent(g);
		this.setBackground(Color.WHITE);
		Graphics2D g2 = (Graphics2D) g;
		g2.setColor(Color.BLACK); // drawing rectangles
		
		int pixelsPerSquare = this.getHeight() / this.getDim();
		int border = ScreenMessageTransmitter.NMBR_SQUARES_BORDER;
		int yShift = this.getWidth() / 2 - pixelsPerSquare * this.getDim() / 2;
		
		for (int i = border ; i < this.getDim() - border ; i++) { // going down
			for (int j = border ; j < this.getDim() - border ; j++) { // going right
				
				if (this.matrix[i - border][j - border]) {
					g2.fillRect(this.getX() + yShift + j*pixelsPerSquare, 
							this.getY() + i*pixelsPerSquare, 
							pixelsPerSquare, 
							pixelsPerSquare);
				}
			}
		}
	}

	/**
	 * 
	 * @return the dimension of the matrix, including the borders.
	 */
	public int getDim() {
		return this.matrix.length + 2 * ScreenMessageTransmitter.NMBR_SQUARES_BORDER;
	}

	public boolean[][] getMatrix() {
		return this.matrix;
	}
	
	/**
	 * Sets the matrix with dimension check.
	 * @param matrix
	 */
	public void setMatrix(boolean[][] matrix) {
		for (int i = 0 ; i < matrix.length ; i++) {
			if (matrix[i].length != matrix.length) {
				throw new IllegalArgumentException();
			}
		}
	
		this.matrix = Arrays.copyOf(matrix, matrix.length);
	}
}
