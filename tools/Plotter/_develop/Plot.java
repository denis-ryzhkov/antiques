import java.awt.*;
import java.awt.event.*;
import java.util.*;
import javax.swing.*;
import javax.swing.event.*;

//// Plot

public class Plot extends JPanel {

//// properties

 Vector points;
 int index, lastIndex;
 Float fromFloat, toFloat, xPrev, yPrev, yStepPrev;
 boolean showText, hasPrev, hasStepPrev;

//// constructor

 public Plot() {
  setBackground( Color.white );
 }

//// paint

 public void paint( Graphics g ) {
  super.paint( g );
  lastIndex = 0;
  hasPrev = hasStepPrev = false;
  paintPlot( g );
 }

 void repaintNow() { paint( getGraphics()); }

 void paintPlot() { paintPlot( getGraphics()); }

 void paintPlot( Graphics g ) {
  int width = getWidth();
  int height = getHeight();
  int xCenter = width / 2;
  int yCenter = height / 2;
  Float xCenterFloat = new Float( xCenter );
  Float yCenterFloat = new Float( yCenter );
  Float xScale = ( fromFloat == null || toFloat == null ||
    fromFloat.Equal( toFloat ))? Float.ONE :
    new Float( width ).Div( toFloat.Sub( fromFloat ));
  Float yScale = xScale;
  g.drawLine( 0, yCenter, width, yCenter );
  g.drawLine( xCenter, 0, xCenter, height );
  for ( index = lastIndex; index < points.size(); index++ ) {
   FloatPoint point = (FloatPoint) points.get( index );
   int x = (int) point.x.Mul( xScale ).Add( xCenterFloat ).toLong();
   int y = (int) yCenterFloat.Sub( point.y.Mul( yScale )).toLong();
   g.fillRect( x, y, 1, 1 );
   if ( showText && hasPrev ) {
    if ( point.x.Mul( xPrev ).m_Val <= 0 ) g.drawString( point.y.toShortString(), x, y );
    if ( point.y.Mul( yPrev ).m_Val <= 0 ) g.drawString( point.x.toShortString(), x, y );
    if ( hasStepPrev && point.y.Sub( yPrev ).Mul( yStepPrev ).m_Val <= 0 )
     g.drawString( point.y.toShortString(), x, y );
    yStepPrev = point.y.Sub( yPrev ); hasStepPrev = true;
   }
   xPrev = point.x; yPrev = point.y; hasPrev = true;
  }
  lastIndex = index;
}}
