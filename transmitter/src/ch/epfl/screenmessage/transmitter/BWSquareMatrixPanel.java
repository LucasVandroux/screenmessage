package ch.epfl.screenmessage.transmitter;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.util.Arrays;

import javax.swing.JPanel;

/**
 * Black and white square matrix.
 * 
 * @author mickael
 *
 */
public class BWSquareMatrixPanel extends JPanel {
	
	private static final long serialVersionUID = -810823167077423707L;
	
	/**
	 * The square matrix to use.
	 * true = white
	 * false = black
	 */
	private boolean[][] matrix;
	
	/**
	 * Default constructor, not initializing the matrix.
	 */
	public BWSquareMatrixPanel() { }
	
	/**
	 * 
	 * @param matrix the matrix of boolean to use.
	 */
	public BWSquareMatrixPanel(boolean[][] matrix) {
		this.setMatrix(matrix);
	}
	
	
	@Override
	public void paintComponent(Graphics g) {
		if (this.matrix == null || this.getHeight() > this.getWidth()) {
			throw new IllegalStateException();
		}
		
		super.paintComponent(g);
		Graphics2D g2 = (Graphics2D) g;
		
		int pixelsPerSquare = this.getHeight() / this.getDim();
		
		for (int i = 0 ; i < this.getDim() ; i++) { // going down
			for (int j = 0 ; j < this.getDim() ; j++) { // going right
				g2.setColor(this.matrix[i][j] ? Color.WHITE : Color.BLACK);
				g2.fillRect(this.getX() + j*pixelsPerSquare, 
						this.getY() + i*pixelsPerSquare, 
						pixelsPerSquare, 
						pixelsPerSquare);
			}
		}
	}
	
	/**
	 * 
	 * @return the dimension of the matrix.
	 */
	public int getDim() {
		return this.matrix.length;
	}
	
	public boolean[][] getMatrix() {
		return this.matrix;
	}
	
	public void setMatrix(boolean[][] matrix) {
		for (int i = 0 ; i < matrix.length ; i++) {
			if (matrix[i].length != matrix.length) {
				throw new IllegalArgumentException();
			}
		}

		this.matrix = Arrays.copyOf(matrix, matrix.length);
	}
}
