//// usage: new Delayer( 100, true ) { public void act() { ... }};

import java.awt.event.*;
import javax.swing.*;

//// Delayer

public abstract class Delayer {
 public abstract void act();
 public Delayer() { this( 0 ); }
 public Delayer( int delay ) { this( delay, false ); }
 public Delayer( int delay, final boolean loop ) {
  ( new Timer( delay, new ActionListener() {
   public void actionPerformed( ActionEvent actionEvent ) {
    act();
    if ( !loop ) ( (Timer) actionEvent.getSource()).stop();
  }})).start();
}}
