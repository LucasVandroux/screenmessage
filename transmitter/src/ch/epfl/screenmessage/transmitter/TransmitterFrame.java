package ch.epfl.screenmessage.transmitter;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Frame;

import javax.swing.JFrame;

public class TransmitterFrame extends JFrame {
	
	private static final long serialVersionUID = 3772000742816092712L;
	

	public TransmitterFrame() {
		super(ScreenMessageTransmitter.APP_NAME);
		
		setUndecorated(true);
		setExtendedState(Frame.MAXIMIZED_BOTH);
		setName(ScreenMessageTransmitter.APP_NAME);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		//setContentPane(new EncodedMessage33px(null));
		getContentPane().setBackground(Color.WHITE);
		//getContentPane().setLayout(new BorderLayout());
		getContentPane().add(new EncodedMessage33px(null));
		getContentPane().setBackground(Color.WHITE);
		//pack();
		setVisible(true);
		//setBounds(100, 100, 450, 300);
		/*contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		setContentPane(contentPane);
		contentPane.setLayout(new BorderLayout(0, 0));*/
	}
	
	private void createCodePanel() {
		
	}
}
