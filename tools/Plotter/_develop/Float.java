import java.lang.*;
/**
 * <p>Title: Class for float-point calculations in J2ME applications (MIDP 1.0 CLDC 1.0 where float or double types not exist)</p>
 * <p>Description: It makes float-point calculations via integer values</p>
 * <p>Copyright: Nick Henson Copyright (c) 2002-2003</p>
 * <p>Company: UNTEH</p>
 * <p>License: Free use only for non-commercial purpose</p>
 * <p>If you want to use all or part of this class for commercial applications then take into account these conditions:</p>
 * <p>1. I need a one copy of your product which includes my class with license key and so on</p>
 * <p>2. Please append my copyright information henson.midp.Float (C) by Nikolay Klimchuk on ‘About’ screen of your product</p>
 * <p>3. If you have web site please append link <a href=”http://henson.newmail.ru”>Nikolay Klimchuk</a> on the page with description of your product</p>
 * <p>That's all, thank you!</p>
 * @author Nikolay Klimchuk http://henson.newmail.ru
 * @version 0.9
 */

public class Float
{
  // Math section
  final static private Float ERROR=new Float(Long.MIN_VALUE, Long.MIN_VALUE);
  // Number of itterations, if you want to make calculations more precise set ITNUM=6,7,...
  // or ITMUN=4,3,... to make it faster
  final static private int ITNUM=5;
  // Square root from 3
  final static public Float SQRT3=new Float(1732050807568877294L, -18L);
  // Pi constant
  final static public Float PI=new Float(3141592653589793238L, -18L);
  final static public Float ZERO=new Float();
  final static public Float ONE=new Float(1L);
  final static public Float E = new Float(271828182845904512L, -17);
  final static public Float LOG10 = new Float(2302585092994045684L, -18);
  //
  final static public Float PIdiv2=PI.Div(2L);
  final static public Float PIdiv4=PIdiv2.Div(2L);
  final static public Float PIdiv6=PIdiv2.Div(3L);
  final static public Float PIdiv12=PIdiv6.Div(2L);
  final static public Float PImul2=PI.Mul(2L);
  final static public Float PImul4=PI.Mul(4L);
  //
  public long m_Val;
  public long m_E;
  //
  private long maxLimit=Long.MAX_VALUE/100;
  //
  public Float()
  {
    m_Val=m_E=0;
  }
  public Float(long value)
  {
    m_Val=value;
    m_E=0;
  }
  public Float(long value, long e)
  {
    m_Val=value;
    if(m_Val==0)
      m_E=0;
    else
      m_E=e;
  }
  public Float(Float value)
  {
    m_Val=value.m_Val;
    if(m_Val==0)
      m_E=0;
    else
      m_E=value.m_E;
  }

  public long toLong()
  {
    long tmpE=m_E;
    long tmpVal=m_Val;
    //
    while(tmpE!=0)
    {
      if(tmpE<0)
      {
        tmpVal/=10;
        tmpE++;
      }
      else
      {
        tmpVal*=10;
        tmpE--;
      }
    }
    return tmpVal;
  }

  public String toShortString()
  {
      if(isError()) { 
         return "NaN";
      }
      long e = m_E;
      long val = m_Val;
      Float f = this;
      if (e < 0) { 
          while (e < 0 && val != 0) { 
              val /= 10;
              e += 1;
          }
          e -= 1;
          if (e > m_E) { 
              long round = 1;
              int sign = m_Val < 0 ? -1 : 1;
              for (long d = m_E; d < e; d++, round *= 10);
              f = new Float((m_Val+sign*round/2)/round, e);
          }
      }
      return f.toString();
  }

  public boolean isError()
  {
    return (this.m_Val==ERROR.m_Val && this.m_E==ERROR.m_E);
  }

  public String toString()
  {
    if(isError())
      return "NaN";
    //
    RemoveZero();
    //
    String str=Long.toString(m_Val);
    int len=str.length();
    boolean neg=false;
    if(m_Val<0L)
    {
      neg=true;
      str=str.substring(1, len);
      len--;
    }
    //
    StringBuffer sb=new StringBuffer();
    //
    if(m_E<0L)
    {
      int absE=(int)Math.abs(m_E);
      if(absE<len)
      {
        sb.append(str.substring(0, len-absE));
        sb.append(".");
        sb.append(str.substring(len-absE));
      }
      else
      {
        sb.append(str);
        for(int  i=0; i<(absE-len); i++)
          sb.insert(0, "0");
        sb.insert(0, "0.");
      }
    }
    else
    {
      if(len+m_E>6)
      {
        sb.append(str.charAt(0));
        if(str.length()>1)
        {
          sb.append(".");
          sb.append(str.substring(1));
        }
        else
          sb.append(".0");
        sb.append("E"+(len-1+m_E));
      }
      else
      {
        sb.append(str);
        for(int i=0; i<m_E; i++)
          sb.append("0");
      }
    }
    //
    str=sb.toString();
    sb=null;
    if(neg)
      str="-"+str;
    //
    return str;
  }

  public Float Add(Float value)
  {
    if(value.Equal(ZERO))
      return new Float(this);
    //
    long e1=m_E;
    long e2=value.m_E;
    long v1=m_Val;
    long v2=value.m_Val;
    // E must be equal in both operators
    while (e1 != e2)
    {
      if(e1 > e2)
      {
        if(Math.abs(v1)<maxLimit)
        {
          v1*=10;
          e1--;
        }
        else
        {
          v2/=10;
          e2++;
        }
      }
      else
      if(e1 < e2)
      {
        if(Math.abs(v2)<maxLimit)
        {
          v2*=10;
          e2--;
        }
        else
        {
          v1/=10;
          e1++;
        }
      }
    }
    //
    if( (v1>0 && v2>Long.MAX_VALUE-v1) || (v1<0 && v2<Long.MIN_VALUE-v1) )
    {
      v1/=10; e1++;
      v2/=10; e2++;
    }
    //
    if(v1>0 && v2>Long.MAX_VALUE-v1)
      return new Float(ERROR);
    else
    if(v1<0 && v2<Long.MIN_VALUE-v1)
      return new Float(ERROR);
    //
    return new Float(v1+v2, e1);
  }
  public Float Sub(Float value)
  {
    if(value.Equal(ZERO))
      return new Float(m_Val, m_E);
    return Add(new Float(-value.m_Val, value.m_E));
  }
  public Float Mul(long value)
  {
    return Mul(new Float(value, 0));
  }
  public Float Mul(Float value)
  {
    if(value.Equal(ZERO) || this.Equal(ZERO))
      return new Float(ZERO);
    if(value.Equal(ONE))
      return new Float(this);
    //
    boolean negative1=(m_Val<0);
    if(negative1) m_Val=-m_Val;
    boolean negative2=(value.m_Val<0);
    if(negative2) value.m_Val=-value.m_Val;
    // Check overflow and underflow
    do
    {
      if(value.m_Val>m_Val)
      {
        if(Long.MAX_VALUE/m_Val<value.m_Val)
        {
          value.m_Val/=10;
          value.m_E++;
        }
        else
          break;
      }
      else
      {
        if(Long.MAX_VALUE/value.m_Val<m_Val)
        {
          m_Val/=10;
          m_E++;
        }
        else
          break;
      }
    } while(true);
    //
    if(negative1) m_Val=-m_Val;
    if(negative2) value.m_Val=-value.m_Val;
    //
    long e=m_E+value.m_E;
    long v=m_Val*value.m_Val;
    return new Float(v, e);
  }
  public Float Div(long value)
  {
    return Div(new Float(value, 0));
  }
  public Float Div(Float value)
  {
    if(value.Equal(ONE))
      return new Float(this);
    //
    long e1=m_E;
    long e2=value.m_E;
    long v2=value.m_Val;
    if(v2==0L)
      return new Float(ERROR);
    long v1=m_Val;
    if(v1==0L)
      return new Float(ZERO);
    //
    long val=0L;
    while(true)
    {
      val+=(v1/v2);
      v1%=v2;
      if(v1==0L || Math.abs(val)>(Long.MAX_VALUE/10L))
        break;
      if(Math.abs(v1)>(Long.MAX_VALUE/10L))
      {
        v2/=10L;
        e2++;
      }
      else
      {
        v1*=10L;
        e1--;
      }
      val*=10L;
    }
    //
    Float f=new Float(val, e1-e2);
    f.RemoveZero();
    return f;
  }
  public void RemoveZero()
  {
    if(m_Val==0)
      return;
    while ( m_Val%10 == 0 )
    {
     m_Val/=10;
     m_E++;
    }
  }

  public boolean Great(Float x)
  {
    long e1=m_E;
    long e2=x.m_E;
    long v1=m_Val;
    long v2=x.m_Val;
    //
    while (e1 != e2)
    {
      if(e1 > e2)
      {
        if(Math.abs(v1)<maxLimit)
        {
          v1*=10;
          e1--;
        }
        else
        {
          v2/=10;
          e2++;
        }
      }
      else
      if(e1 < e2)
      {
        if(Math.abs(v2)<maxLimit)
        {
          v2*=10;
          e2--;
        }
        else
        {
          v1/=10;
          e1++;
        }
      }
    }
    //
    return v1>v2;
  }
  public boolean Less(long x)
  {
    return Less(new Float(x, 0));
  }
  public boolean Less(Float x)
  {
    long e1=m_E;
    long e2=x.m_E;
    long v1=m_Val;
    long v2=x.m_Val;
    //
    while (e1 != e2)
  {
    if(e1 > e2)
    {
      if(Math.abs(v1)<maxLimit)
      {
        v1*=10;
        e1--;
      }
      else
      {
        v2/=10;
        e2++;
      }
    }
    else
    if(e1 < e2)
    {
      if(Math.abs(v2)<maxLimit)
      {
        v2*=10;
        e2--;
      }
      else
      {
        v1/=10;
        e1++;
      }
    }
  }
  //
  return v1<v2;
  }
  public boolean Equal(Float x)
  {
    long e1=m_E;
    long e2=x.m_E;
    long v1=m_Val;
    long v2=x.m_Val;
    //
    if((v1==0 && v2==0) || (v1==v2 && e1==e2))
      return true;
    // Values with exponent differences more than 20 times never could be equal
    if(Math.abs(e1-e2)>20)
      return false;
    //
    while (e1 != e2)
    {
      if(e1 > e2)
      {
        if(Math.abs(v1)<maxLimit)
        {
          v1*=10;
          e1--;
        }
        else
        {
          v2/=10;
          e2++;
        }
      }
      else
      if(e1 < e2)
      {
        if(Math.abs(v2)<maxLimit)
        {
          v2*=10;
          e2--;
        }
        else
        {
          v1/=10;
          e1++;
        }
      }
    }
    //
    return (v1==v2);
  }
  public Float Neg()
  {
    return new Float(-m_Val, m_E);
  }
  // Math section
  static public Float sin(Float x)
  {
    while( x.Great(PI) )
      x=x.Sub(PImul2);
    while( x.Less(PI.Neg()) )
      x=x.Add(PImul2);
    // x*x*x
    Float m1=x.Mul(x.Mul(x));
    Float q1=m1.Div(6L);
    // x*x*x*x*x
    Float m2=x.Mul(x.Mul(m1));
    Float q2=m2.Div(120L);
    // x*x*x*x*x*x*x
    Float m3=x.Mul(x.Mul(m2));
    Float q3=m3.Div(5040L);
    // x*x*x*x*x*x*x*x*x
    Float m4=x.Mul(x.Mul(m3));
    Float q4=m4.Div(362880L);
    // x*x*x*x*x*x*x*x*x*x*x
    Float m5=x.Mul(x.Mul(m4));
    Float q5=m5.Div(39916800L);
    //
    Float result=x.Sub(q1).Add(q2).Sub(q3).Add(q4).Sub(q5);
    // 1e-6
    if(result.Less(new Float(-999999, -6)))
      return new Float(-1L);
    // 1e-6
    if(result.Great(new Float(999999, -6)))
      return new Float(1L);
    // 5e-4
    if(result.Great(new Float(-5, -4)) && result.Less(new Float(5, -4)))
      return new Float(0L);
    //
    return result;
  }

  static public Float cos(Float x)
  {
    while( x.Great(PI) )
      x=x.Sub(PImul2);
    while( x.Less(PI.Neg()) )
      x=x.Add(PImul2);
    // x*x
    Float m1=x.Mul(x);
    Float q1=m1.Div(2L);
    // x*x*x*x
    Float m2=m1.Mul(m1);
    Float q2=m2.Div(24L);
    // x*x*x*x*x*x
    Float m3=m1.Mul(m2);
    Float q3=m3.Div(720L);
    // x*x*x*x*x*x*x*x
    Float m4=m2.Mul(m2);
    Float q4=m4.Div(40320L);
    // x*x*x*x*x*x*x*x*x*x
    Float m5=m4.Mul(m1);
    Float q5=m5.Div(3628800L);
    Float result=ONE.Sub(q1).Add(q2).Sub(q3).Add(q4).Sub(q5);
    // 1e-6
    if(result.Less(new Float(-999999, -6)))
      return ONE.Neg();
    // 1e-6
    if(result.Great(new Float(999999, -6)))
      return new Float(ONE);
    // 5e-4
    if(result.Great(new Float(-5, -4)) && result.Less(new Float(5, -4)))
      return new Float(ZERO);
    //
    return result;
  }

  static public Float sqrt(Float x)
  {
    int sp=0;
    boolean inv=false;
    Float a,b;
    //
    if(x.Less(ZERO))
      return new Float(ERROR);
    if(x.Equal(ZERO))
      return new Float(ZERO);
    if(x.Equal(ONE))
      return new Float(ONE);
    // argument less than 1 : invert it
    if(x.Less(ONE))
    {
      x=ONE.Div(x);
      inv=true;
    }
    //
    long e=x.m_E/2;
    // exponent compensation
    Float tmp=new Float(x.m_Val, x.m_E-e*2);
    // process series of division by 16 until argument is <16
    while(tmp.Great(new Float(16L)))
    {
      sp++;
      tmp=tmp.Div(16L);
    }
    // initial approximation
    a=new Float(2L);
    // Newtonian algorithm
    for(int i=ITNUM; i>0; i--)
    {
      b=tmp.Div(a);
      a=a.Add(b);
      a=a.Div(2L);
    }
    // multiply result by 4 : as much times as divisions by 16 took place
    while(sp>0)
    {
      sp--;
      a=a.Mul(4L);
    }
    // exponent compensation
    a.m_E+=e;
    // invert result for inverted argument
    if(inv)
      a=ONE.Div(a);
    return a;
  }

  static public Float tan(Float x)
  {
    Float c=cos(x);
    if(c.Equal(ZERO)) return new Float(ERROR);
    return (sin(x).Div(c));
  }

  static public Float parse(String str, int radix) throws NumberFormatException
  {
    // Abs
    boolean neg=false;
    if (str.length() == 0) { 
        throw new NumberFormatException();
    }
    if(str.charAt(0)=='-')
    {
      str=str.substring(1);
      neg=true;
    } 
    else if(str.charAt(0)=='+')
    {
      str=str.substring(1);
    }
    if (str.length() == 0 || !Character.isDigit(str.charAt(0))) { 
        throw new NumberFormatException();
    }
    //
    int pos=str.indexOf(".");
    if (pos < 0) pos = str.indexOf(',');
        
    long exp=0;
    // Find exponent position
    int pos2=str.indexOf('E');
    if(pos2==-1) pos2=str.indexOf('e');
    //
    if(pos2!=-1)
    {
      String tmp=new String(str.substring(pos2+1));
      exp=Long.parseLong(tmp);
      str=str.substring(0, pos2);
    }
    //
    if(pos!=-1)
    {
      if (pos2 >= 0 && pos >= pos2){ 
          throw new NumberFormatException();
      }
      for(int m=pos+1; m<str.length(); m++)
      {
        if(Character.isDigit(str.charAt(m)))
          exp--;
        else
          throw new NumberFormatException();
      }
      str=str.substring(0, pos)+str.substring(pos+1);
      while(pos > 1 && str.charAt(0)=='0') {
        str=str.substring(1);
        pos -= 1;
      }
    }
    //
    long result=0L;
    int len=str.length();
    //
    StringBuffer sb=new StringBuffer(str);
    while(true)
    {
      // Long value can't have length more than 20
      while(len>20)
      {
        // Very large number for Long
        sb=sb.deleteCharAt(len-1);
        // Compensation of removed zeros
        if(len<pos || pos==-1)
          exp++;
        //
        len--;
      }
      //
      try
      {
        result=Long.parseLong(sb.toString(), radix);
        if(neg)
          result=-result;
        break;
      }
      catch(Exception e)
      {
        // Very large number for Long
        sb=sb.deleteCharAt(len-1);
        // Compensation of removed zeros
        if(len<pos || pos==-1)
          exp++;
        //
        len--;
      }
    }
    sb=null;
    //
    Float newValue=new Float(result, exp);
    newValue.RemoveZero();
    return newValue;
  }

  static public Float acos(Float x)
  {
    return PIdiv2.Sub(asin(x));
  }
  static public Float asin(Float x)
  {
    if( x.Less(ONE.Neg()) || x.Great(ONE) ) return new Float(ERROR);
    if( x.Equal(ONE.Neg()) ) return PIdiv2.Neg();
    if( x.Equal(ONE) ) return PIdiv2;
    return atan(x.Div(sqrt(ONE.Sub(x.Mul(x)))));
  }

  static public Float atan(Float x)
  {
      boolean signChange=false;
      boolean Invert=false;
      int sp=0;
      Float x2, a;
      // check up the sign change
      if(x.Less(ZERO))
      {
          x=x.Neg();
          signChange=true;
      }
      // check up the invertation
      if(x.Great(ONE))
      {
          x=ONE.Div(x);
          Invert=true;
      }
      // process shrinking the domain until x<PI/12
      while(x.Great(PIdiv12))
      {
          sp++;
          a=x.Add(SQRT3);
          a=ONE.Div(a);
          x=x.Mul(SQRT3);
          x=x.Sub(ONE);
          x=x.Mul(a);
      }
      // calculation core
      x2=x.Mul(x);
      a=x2.Add(new Float(14087812, -7));
      a=new Float(55913709, -8).Div(a);
      a=a.Add(new Float(60310579, -8));
      a=a.Sub(x2.Mul(new Float(5160454, -8)));
      a=a.Mul(x);
      // process until sp=0
      while(sp>0)
      {
          a=a.Add(PIdiv6);
          sp--;
      }
      // invertation took place
      if(Invert) a=PIdiv2.Sub(a);
      // sign change took place
      if(signChange) a=a.Neg();
      //
      return a;
  }

  static public Float atan2(Float x, Float y)
  {
      if( y.Equal(ZERO) ) return new Float(ERROR);
      Float f=atan(x.Div(y));
      if(x.m_Val>0 && y.m_Val<0)
        f=f.Add(PI);
      if(x.m_Val<0 && y.m_Val<0)
        f=f.Sub(PI);
      return f;
  }

  // precise
  // x=-35 diff=1.48%
  // x=-30 diff=0.09%
  // x=30 diff=0.09%
  // x=31 diff=0.17%
  // x=32 diff=0.31%
  // x=33 diff=0.54%
  // x=34 diff=0.91%
  // x=35 diff=1.46%
  static public Float exp(Float x)
  {
    if(x.Equal(ZERO))
      return new Float(ONE);
    //
    Float f=new Float(ONE);
    long d=1;
    Float k=null;
    boolean isless=x.Less(ZERO);
    if(isless)
      x=x.Neg();
    k=new Float(x).Div(d);
    //
    for(long i=2; i<50; i++)
    {
      f=f.Add(k);
      k=k.Mul(x).Div(i);
    }
    //
    if(isless)
      return ONE.Div(f);
    else
      return f;
  }

  // precise
  // x=25 diff=0.12%
  // x=30 diff=0.25%
  // x=35 diff=0.44%
  // x=40 diff=0.67%
  static private Float _log(Float x)
  {
    if(!x.Great(ZERO))
      return new Float(ERROR);
    //
    Float f=new Float(ZERO);
    //
    Float y1=x.Sub(ONE);
    Float y2=x.Add(ONE);
    Float y=y1.Div(y2);
    //
    Float k=new Float(y);
    y2=k.Mul(y);
    //
    for(long i=1; i<50; i+=2)
    {
      f=f.Add(k.Div(i));
      k=k.Mul(y2);
    }
    return f.Mul(2L);
  }

  static public Float log(Float x)
  {
    if(!x.Great(ZERO))
      return new Float(ERROR);
    //
    boolean neg=false;
    Float log2=_log(new Float(5, -1));
    if(x.m_Val<0)
    {
      neg=true;
      x.m_Val=-x.m_Val;
    }
    int index=0;
    while(x.Great(Float.ONE))
    {
      x=x.Div(2);
      index++;
    }
    Float res=_log(x);
    for(int i=0; i<index; i++)
      res=res.Sub(log2);
    if(neg)
      return Float.ONE.Div(res);
    else
      return res;
  }

  static public Float log10(Float x)
  {
    if(!x.Great(ZERO))
      return new Float(ERROR);
    //
    boolean neg=false;
    Float log2=_log(new Float(5, -1));
    if(x.m_Val<0)
    {
      neg=true;
      x.m_Val=-x.m_Val;
    }
    //
    int index=0;
    if(x.Great(Float.ONE))
    {
      // Áîëüøå 1
      while(x.Great(Float.ONE))
      {
        x=x.Div(10);
        index++;
      }
    }
    else
    {
      // Ìåíüøå èëè ðàâíî 1
      while(x.Less(Float.ONE))
      {
        x=x.Mul(10);
        index--;
      }
    }
    //
    Float res=new Float(index);
    if(!x.Equal(ONE))
      res=res.Add(log(x).Div(LOG10));
    //
    if(neg)
      return Float.ONE.Div(res);
    else
      return res;
  }
  // precise y=3.5
  // x=15 diff=0.06%
  // x=20 diff=0.40%
  // x=25 diff=1.31%
  // x=30 diff=2.95%
  // if x negative y must be integer value
  static public Float pow(Float x, Float y)
  {
    if(x.Equal(ZERO))
      return new Float(ZERO);
    if(x.Equal(ONE))
      return new Float(ONE);
    //
    long l=y.toLong();
    boolean integerValue=y.Equal(new Float(l));
    //
    if(integerValue)
    {
      boolean neg=false;
      if(y.Less(0))
        neg=true;
      //
      Float result=new Float(x);
      for(long i=1; i<(neg?-l:l); i++)
        result=result.Mul(x);
      //
      if(neg)
        return ONE.Div(result);
      else
        return result;
    }
    else
    {
      if(x.Great(ZERO))
        return exp(y.Mul(log(x)));
      else
        return new Float(ERROR);
    }
  }

  static public Float ceil(Float x)
  {
    long tmpVal=x.m_Val;
    //
    if(x.m_E<0)
    {
      long coeff=1;
      //
      if(x.m_E>-19)
      {
        for(long i=0; i<-x.m_E; i++)
          coeff*=10;
        tmpVal/=coeff;
        tmpVal*=coeff;
        if(x.m_Val-tmpVal>0)
          tmpVal+=coeff;
      }
      else
      if(tmpVal>0)
        return ONE;
      else
        return ZERO;
    }
    //
    return new Float(tmpVal, x.m_E);
  }

  static public Float floor(Float x)
  {
    long tmpVal=x.m_Val;
    //
    if(x.m_E<0)
    {
      long coeff=1;
      //
      if(x.m_E>-19)
      {
        for(long i=0; i<-x.m_E; i++)
          coeff*=10;
        tmpVal/=coeff;
        tmpVal*=coeff;
        if(x.m_Val-tmpVal<0)
          tmpVal-=coeff;
      }
      else
      if(tmpVal<0)
        return ONE.Neg();
      else
        return ZERO;
    }
    //
    return new Float(tmpVal, x.m_E);
  }

  static public Float abs(Float x)
  {
    if(x.m_Val<0)
      return x.Neg();
    return new Float(x);
  }

  static public Float Int(Float x)
  {
    long tmpVal=x.m_Val;
    //
    if(x.m_E<0)
    {
      long coeff=1;
      //
      if(x.m_E>-19)
      {
          for(long i=0, e=-x.m_E; i<e; i++)
          coeff*=10;
        tmpVal/=coeff;
        tmpVal*=coeff;
      }
      else
        return Float.ZERO;
    }
    //
    return new Float(tmpVal, x.m_E);
  }

  static public Float Frac(Float x)
  {
    long tmpVal=x.m_Val;
    //
    if(x.m_E<0)
    {
      long coeff=1;
      //
      if(x.m_E>-19)
      {
        for(long i=0, e=-x.m_E; i<e; i++)
          coeff*=10;
        tmpVal/=coeff;
        tmpVal*=coeff;
        tmpVal=x.m_Val-tmpVal;
      }
    } else { 
        return Float.ZERO;
    }        
    //
    return new Float(tmpVal, x.m_E);
  }
}
