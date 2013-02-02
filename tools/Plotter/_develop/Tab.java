import java.awt.*;
import java.awt.event.*;
import java.util.*;
import javax.swing.*;
import javax.swing.event.*;

//// Tab

public class Tab extends JPanel implements Runnable {

//// properties

 static final Icon startIcon = new ImageIcon( "img/start.gif" );
 static final Icon pauseIcon = new ImageIcon( "img/pause.gif" );
 static final Icon closeIcon = new ImageIcon( "img/close.gif" );

 GridBagLayout layout;
 GridBagConstraints constraints;
 JTextField formulaField, fromField, toField, stepField;
 JCheckBox textCheckBox;
 Plot plot;

 Vector points;
 Thread thread;
 boolean paused;
 Hashtable bindings;
 Compiler.FunctionExpression f;
 Float fromFloat, toFloat, stepFloat;

//// parseFloat

 Float parseFloat( String string ) {
  Hashtable bindings = new Hashtable();
  Compiler áompiler = new Compiler( string );
  return (Float) ( áompiler.compile()).evaluate( bindings );
 }

//// place

 Component place( Component component, double weightx ) {
  constraints.weightx = weightx;
  layout.setConstraints( component, constraints );
  add( component );
  return component;
 }

//// constructor

 public Tab( final JTabbedPane tabPane ) {
  final Tab tab = this;
  points = new Vector();
  paused = false;

//// layout

  layout = new GridBagLayout();
  setLayout( layout );
  constraints = new GridBagConstraints();
  constraints.fill = GridBagConstraints.BOTH;

  JLabel formulaLabel = (JLabel) place( new JLabel( "f(x)=" ), 0.0 );
  formulaField = (JTextField) place( new JTextField( "x*cos(x)" ), 1.0 );
  JLabel fromLabel = (JLabel) place( new JLabel( "  x=" ), 0.0 );
  fromField = (JTextField) place( new JTextField( "-20" ), 0.05 );
  JLabel toLabel = (JLabel) place( new JLabel( ".." ), 0.0 );
  toField = (JTextField) place( new JTextField( "20" ), 0.05 );
  JLabel stepLabel = (JLabel) place( new JLabel( "  step=" ), 0.0 );
  stepField = (JTextField) place( new JTextField( "0.001" ), 0.05 );
  JLabel textLabel = (JLabel) place( new JLabel( "  text=" ), 0.0 );
  textCheckBox = (JCheckBox) place( new JCheckBox( "", true ), 0.0 );
  JButton startButton = (JButton) place( new JButton( "Start", startIcon ), 0.0 );
  JButton pauseButton = (JButton) place( new JButton( "Pause", pauseIcon ), 0.0 );
  constraints.gridwidth = GridBagConstraints.REMAINDER;
  JButton closeButton = (JButton) place( new JButton( "Close", closeIcon ), 0.0 );
  constraints.weighty = 1.0;
  plot = (Plot) place( new Plot(), 1.0 );
  plot.points = points;

  formulaField.selectAll();
  //new Delayer( 500 ) { public void act() { formulaField.requestFocus(); }};

//// start listener

  ActionListener startListener = new ActionListener() {
   public void actionPerformed( ActionEvent e ) {
    if ( thread != null && thread.isAlive()) thread.stop();
    String formula = formulaField.getText();
    tabPane.setTitleAt( tabPane.indexOfComponent( tab ), formula );
    bindings = new Hashtable();
    Compiler áompiler = new Compiler( "f(x)=" + formula );
    ( áompiler.compile()).evaluate( bindings );
    f = ( Compiler.FunctionExpression ) bindings.get( "f" );
    plot.fromFloat = fromFloat = parseFloat( fromField.getText());
    plot.toFloat = toFloat = parseFloat( toField.getText());
    stepFloat = parseFloat( stepField.getText());
    f.arguments[0] = fromFloat;
    points.clear();
    plot.showText = textCheckBox.isSelected();
    paused = false;
    thread = new Thread( tab );
    thread.setPriority( Thread.MIN_PRIORITY );
    thread.start();
    plot.repaintNow();
  }};
  formulaField.addActionListener( startListener );
  fromField.addActionListener( startListener );
  toField.addActionListener( startListener );
  stepField.addActionListener( startListener );
  startButton.addActionListener( startListener );

//// pause listener

  pauseButton.addActionListener( new ActionListener() {
   public void actionPerformed( ActionEvent e ) {
    if ( thread == null || !thread.isAlive()) return;
    if ( paused ) thread.resume();
    else thread.suspend();
    paused = !paused;
  }});

//// close listener

  closeButton.addActionListener( new ActionListener() {
   public void actionPerformed( ActionEvent e ) {
    System.out.println( points.size());
    if ( thread != null && thread.isAlive()) thread.stop();
    tabPane.remove( tab );
  }});
 }

//// run

 public void run() {
  while ( f.arguments[0].Less( toFloat )) {
   points.add( new FloatPoint( f.arguments[0], f.evaluate( bindings )));
   f.arguments[0] = f.arguments[0].Add( stepFloat );
   thread.yield();
}}}
