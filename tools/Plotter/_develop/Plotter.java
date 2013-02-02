import java.util.*;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.*;

//// Plotter

public class Plotter extends JFrame {

//// properties

 JTabbedPane tabPane;

//// main

 public static void main( String[] args ) {
  new Plotter();
 }

//// constructor

 public Plotter() {

//// layout

  setTitle( "Plotter" );
  setIconImage(( new ImageIcon( "img/Plotter.gif" )).getImage());
  setLocation( 100, 100 );
  setSize( 600, 400 );
  tabPane = new JTabbedPane();
  getContentPane().add( tabPane );

//// window listener

  addWindowListener( new WindowAdapter() { 
    public void windowClosing( WindowEvent windowEvent ) { System.exit( 0 ); }});

//// new listener

  tabPane.addMouseListener( new MouseAdapter() {
   public void mouseClicked( MouseEvent e ) {
    if ( e.getClickCount() != 2 ) return;
    Tab tab = new Tab( tabPane );
    tabPane.addTab( "New", tab );
    tabPane.setSelectedComponent( tab );
  }});

//// repaint timer

  new Delayer( 100, true ) { public void act() {
   Tab tab = (Tab) tabPane.getSelectedComponent();
   if ( tab == null || tab.paused || tab.thread == null ||
     !tab.thread.isAlive() && tab.plot.index == tab.points.size()) return;
   tab.plot.paintPlot();
  }};

//// final

  tabPane.addTab( "New", new Tab( tabPane ));
  show();
}}
