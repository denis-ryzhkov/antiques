import java.util.*;

public class Compiler { 
    static interface Expression { 
        Float evaluate(Hashtable bindings);
    }

    static interface Declaration { 
        void declare(Hashtable bindings);
    }
        
    static class ExpressionList implements Expression { 
        Expression[] exprs;
        
        public Float evaluate(Hashtable bindings) {
            Float val = exprs[0].evaluate(bindings);
            for (int i = 1; i < exprs.length; i++) { 
                val = exprs[i].evaluate(bindings);
            }
            return val;
        }
        
        ExpressionList(Expression[] exprs) { 
            this.exprs = exprs;
        }
    }

    static class AssignmentExpression implements Expression, Declaration { 
        String     name;
        Expression expr;

        public void declare(Hashtable bindings) {
            bindings.put(name, expr);
        }

        public Float evaluate(Hashtable bindings) {
            declare(bindings);
            return expr.evaluate(bindings);
        }
    }

    static class FunctionDefExpression implements Expression, Declaration { 
        String             name;
        FunctionExpression func;

        public void declare(Hashtable bindings) {
            bindings.put(name, func);
        }

        public Float evaluate(Hashtable bindings) {
            declare(bindings);
            return null;
        }
    }

    static class ConditionalExpression implements Expression { 
        Expression cond;
        Expression ifTrue;
        Expression ifFalse;

        public Float evaluate(Hashtable bindings) {
            return cond.evaluate(bindings).Equal(Float.ZERO)
                ? ifFalse.evaluate(bindings)
                : ifTrue.evaluate(bindings);
        }
    }

    abstract static class UnaryExpression implements Expression { 
        Expression operand;
    }

    static class NegExpression extends UnaryExpression { 
        public Float evaluate(Hashtable bindings) { 
            return operand.evaluate(bindings).Neg();
        }

        NegExpression(Expression operand) { 
            this.operand = operand;
        }
    }

    static class VariableExpression implements Expression { 
        String name;
        
        public Float evaluate(Hashtable bindings) { 
            Expression expr = (Expression)bindings.get(name);
            if (expr == null) { 
                throw new CompileError("Variable '" + name + "' is not defined");
            }
            return expr.evaluate(bindings);
        }

        VariableExpression(String name) { 
            this.name = name;
        }
    }
    
    static class FunctionExpression implements Expression { 
        Float[]    arguments;
        Expression body;
        
        public Float evaluate(Hashtable bindings) { 
            return body.evaluate(bindings);
        }
    }

    static class ParameterExpression implements Expression { 
        FunctionExpression function;
        int                index;

        public Float evaluate(Hashtable bindings) { 
            return function.arguments[index];
        }

        public ParameterExpression(int index, FunctionExpression function) { 
            this.index = index;
            this.function = function;
        }
    }

    static class PlotExpression implements Expression { 
        Expression from;
        Expression till;
        Expression step;
        String     func;

        FunctionExpression f;

        public Float evaluate(Hashtable bindings) { 
            Expression expr = (Expression)bindings.get(func);
            if (expr == null) { 
                Integer kind = (Integer)builtin.get(func);
                if (kind != null) { 
                    // builtin function
                    f = new FunctionExpression();
                    f.arguments = new Float[1];
                    f.body = new BuiltinFunction(kind.intValue(), new ParameterExpression(0, f));
                }  else {
                    throw new CompileError("Function '" + func + "' is not defined");
                }
            } else { 
                if (!(expr instanceof FunctionExpression)) { 
                    throw new CompileError("Last parameter of plot should be function");
                }
                f = (FunctionExpression)expr;
                if (f.arguments.length != 1) { 
                    throw new CompileError("Last parameter of plot should be function with one argument");
                }
            }
            return null;
        }
    }

    static class FunctionCallExpression implements Expression { 
        String name;
        Expression[] parameters;

        public Float evaluate(Hashtable bindings) { 
            Expression expr = (Expression)bindings.get(name);
            if (expr == null) { 
                throw new CompileError("Function '" + name + "' is not defined");
            }
            if (!(expr instanceof FunctionExpression)) { 
                throw new CompileError("Name '" + name + "' is not a function");
            }
            FunctionExpression func = (FunctionExpression)expr;
            Float[] arguments = new Float[parameters.length];
            for (int i = 0; i < parameters.length; i++) { 
                arguments[i] = parameters[i].evaluate(bindings);
            }
            Float[] saveArguments = func.arguments;    
            func.arguments = arguments;
            Float result = func.evaluate(bindings);
            func.arguments = saveArguments;
            return result;
        }
    }  

    static class LiteralExpression implements Expression { 
        Float value;

        public Float evaluate(Hashtable bindings) { 
            return value;
        }

        LiteralExpression(Float value) { 
            this.value = value;
        }
    }
    
    static final int SIN = 0;
    static final int COS = 1;
    static final int TAN = 2;
    static final int ASIN = 3;
    static final int ACOS = 4;
    static final int ATAN = 5;
    static final int EXP = 6;
    static final int LOG = 7;
    static final int ABS = 8;
    static final int CEIL = 9;
    static final int FLOOR  = 10;
    static final int INT = 11;
    static final int FRAC  = 12;
    static final int SQR = 13;

    static Hashtable builtin;
    static { 
        builtin = new Hashtable();
        builtin.put("sin", new Integer(SIN));
        builtin.put("cos", new Integer(COS));
        builtin.put("tan", new Integer(TAN));
        builtin.put("asin", new Integer(ASIN));
        builtin.put("acos", new Integer(ACOS));
        builtin.put("atan", new Integer(ATAN));
        builtin.put("exp", new Integer(EXP));
        builtin.put("sqr", new Integer(SQR));
        builtin.put("log", new Integer(LOG));
        builtin.put("ceil", new Integer(CEIL));
        builtin.put("floor", new Integer(FLOOR));
    }

    static class BuiltinFunction implements Expression { 
        Expression operand;
        int kind;

        public Float evaluate(Hashtable bindings) { 
            Float x = operand.evaluate(bindings);
            switch (kind) { 
            case SIN:
                return Float.sin(x);
            case COS:
                return Float.cos(x);
            case TAN:
                return Float.tan(x);
            case ASIN:
                return Float.asin(x);
            case ACOS:
                return Float.acos(x);
            case ATAN:
                return Float.atan(x);
            case EXP:
                return Float.exp(x);
            case LOG:
                return Float.log(x);
            case ABS:
                return Float.abs(x);
            case CEIL:
                return Float.ceil(x);
            case FLOOR:
                return Float.floor(x);
            case SQR:
                return Float.sqrt(x);
            case INT:
                return Float.Int(x);
            case FRAC:
                return Float.Frac(x);
            default:
                throw new CompileError("Invalid builtin function");
            }
        }
        
        BuiltinFunction(int kind, Expression operand) { 
            this.kind = kind;
            this.operand = operand;
        }
    }

    static abstract class BinaryExpression implements Expression { 
        Expression left;
        Expression right; 
    }

    static class LessExpression extends BinaryExpression { 
        public Float evaluate(Hashtable bindings) { 
            return left.evaluate(bindings).Less(right.evaluate(bindings))
                ? Float.ONE : Float.ZERO;
        }
    }
        
    static class GreatExpression extends BinaryExpression { 
        public Float evaluate(Hashtable bindings) { 
            return left.evaluate(bindings).Great(right.evaluate(bindings))
                ? Float.ONE : Float.ZERO;
        }
    }
        
    static class RangeExpression implements Expression { 
        Expression min;
        Expression expr;
        Expression max;

        public Float evaluate(Hashtable bindings) { 
            Float val = expr.evaluate(bindings);
            return val.Great(min.evaluate(bindings)) && val.Less(max.evaluate(bindings))
                ? Float.ONE : Float.ZERO;
        }
    }
        
    static class MulExpression extends BinaryExpression {
        public Float evaluate(Hashtable bindings) { 
            return left.evaluate(bindings).Mul(right.evaluate(bindings));
        }
    }

    static class AddExpression extends BinaryExpression {
        public Float evaluate(Hashtable bindings) { 
            return left.evaluate(bindings).Add(right.evaluate(bindings));
        }
    }

    static class SubExpression extends BinaryExpression {
        public Float evaluate(Hashtable bindings) { 
            return left.evaluate(bindings).Sub(right.evaluate(bindings));
        }
    }

    static class DivExpression extends BinaryExpression {
        public Float evaluate(Hashtable bindings) { 
            return left.evaluate(bindings).Div(right.evaluate(bindings));
        }
    }

    static class PowerExpression extends BinaryExpression {
        public Float evaluate(Hashtable bindings) { 
            return Float.pow(left.evaluate(bindings), right.evaluate(bindings));
        }
    }

    public Compiler(String str) { 
        this.str = str;
    }

    public Expression compile() {
        Expression expr = compileExpression();
        if (tkn != -1) { 
            throw new CompileError("Unexpected token '" + (char)tkn + "'");
        }
        return expr;
    }

    private Expression compileExpression() {
        Expression expr = compileAssignmentExpression();
        if (tkn == ',') { 
            Vector exprList = new Vector();
            exprList.addElement(expr);
            do { 
                exprList.addElement(compileAssignmentExpression());
            } while (tkn == ',');

            Expression[] exprs = new Expression[exprList.size()];
            for (int i = 0; i < exprs.length; i++) { 
                exprs[i] = (Expression)exprList.elementAt(i);
            }
            expr = new ExpressionList(exprs);
        }
        return expr;
    }
 
    private Expression compileAssignmentExpression() {
        Expression lvalue = compileCondExpression();
        if (tkn == '=') { 
            if (lvalue instanceof VariableExpression) { 
                AssignmentExpression asg = new AssignmentExpression();
                asg.name = ((VariableExpression)lvalue).name;
                asg.expr = compileAssignmentExpression();
                return asg;
             } else if (lvalue instanceof FunctionCallExpression) { 
                FunctionCallExpression call = (FunctionCallExpression)lvalue;
                FunctionExpression outer = function;
                String[] outerParameters = parameters;
                parameters = new String[call.parameters.length];
                for (int i = 0; i < parameters.length; i++) { 
                    if (call.parameters[i] instanceof VariableExpression) { 
                        parameters[i] = ((VariableExpression)call.parameters[i]).name;
                    } else { 
                        throw new CompileError("Invalid function parameter");
                    }
                }
                function = new FunctionExpression();
                function.arguments = new Float[parameters.length];
                function.body = compileAssignmentExpression();
                FunctionDefExpression defun = new FunctionDefExpression();
                defun.name = call.name;
                defun.func = function;
                function = outer;
                parameters = outerParameters;
                return defun;                 
            } else {
                throw new CompileError("Assignment can be done to variable or function");
            }
        } 
        return lvalue;
    }

    private Expression compileCondExpression() { 
        Expression left = compileCmpExpression();
        while (tkn == '?') { 
            ConditionalExpression cond = new ConditionalExpression();
            cond.cond = left;
            cond.ifTrue = compileCmpExpression();
            if (tkn != ':') { 
                throw new CompileError("':' expected");
            }
            cond.ifFalse = compileCmpExpression();
            left = cond;
        }
        return left;
    }
        
    private Expression compileCmpExpression() { 
        Expression left = compileAddExpression();
        int cop = tkn;
        if (cop == '>' || cop == '<') { 
            Expression right = compileAddExpression();
            if (cop == tkn) { 
                RangeExpression range = new RangeExpression();
                if (cop == '<') {
                    range.min = left;
                    range.expr = right;
                    range.max = compileAddExpression();
                } else {                     
                    range.max = left;
                    range.expr = right;
                    range.min = compileAddExpression();
                }
                return range;
            } else { 
                BinaryExpression bin = (cop == '<') 
                    ? (BinaryExpression)new LessExpression() : (BinaryExpression)new GreatExpression();
                bin.left = left;
                bin.right = right;
                return bin;
            }
        }
        return left;
    }
                

    private Expression compileAddExpression() { 
        Expression left = compileMulExpression();
        int cop = tkn;
        while (cop == '+' || cop == '-') { 
            Expression right =  compileMulExpression();            
            BinaryExpression bin = (cop == '+') 
                ? (BinaryExpression)new AddExpression() : (BinaryExpression)new SubExpression();
            bin.left = left;
            bin.right = right;
            left = bin; 
            cop = tkn;
        }
        return left;
    }
            
    private Expression compileMulExpression() { 
        Expression left = compilePowerExpression();
        int cop = tkn;
        while (cop == '*' || cop == '/') { 
            Expression right =  compilePowerExpression();            
            BinaryExpression bin = (cop == '*') 
                ? (BinaryExpression)new MulExpression() : (BinaryExpression)new DivExpression();
            bin.left = left;
            bin.right = right;
            left = bin;
            cop = tkn;
        }
        return left;
    }
            
    private Expression compilePowerExpression() { 
        Expression left = compileUnaryExpression();
        if (tkn == '^') { 
            Expression right = compilePowerExpression();
            PowerExpression pow = new PowerExpression();
            pow.left = left;
            pow.right = right;
            return pow;
        }
        return left;
    }
            
    private Expression compileUnaryExpression() { 
        Expression expr;
        switch (scan()) { 
        case '+':
            return compileUnaryExpression();
        case '-':
            return new NegExpression(compileUnaryExpression());
        case '0':
            expr = new LiteralExpression(value);
            break;
        case '(':
            expr = compileExpression();
            if (tkn != ')') { 
                throw new CompileError("')' expected");
            }
            break;
        case '[':
            expr = compileExpression();
            if (tkn != ']') { 
                throw new CompileError("']' expected");
            }
            expr = new BuiltinFunction(INT, expr);
            break;
        case '{':
            expr = compileExpression();
            if (tkn != '}') { 
                throw new CompileError("'}' expected");
            }
            expr = new BuiltinFunction(FRAC, expr);
            break;
        case '|':
            expr = compileExpression();
            if (tkn != '|') { 
                throw new CompileError("'|' expected");
            }
            expr = new BuiltinFunction(ABS, expr);
            break;
        case 'a':
            if (name.equals("pi")) {
                expr = new LiteralExpression(Float.PI);
            } else if (name.equals("e")) {
                expr = new LiteralExpression(Float.E);
            } else { 
                if (function != null) { 
                    for (int i = 0; i < parameters.length; i++) { 
                        if (parameters[i].equals(name)) { 
                            tkn = scan();
                            return new ParameterExpression(i, function);
                        }
                    }
                }
                String ident = name;
                tkn = scan();
                if (tkn == '(') { 
                    expr = compileExpression();
                    if (tkn != ')') { 
                        throw new CompileError("')' expected");
                    }      
                    Expression[] params;
                    if (expr instanceof ExpressionList) { 
                        params = ((ExpressionList)expr).exprs;
                    } else { 
                        params = new Expression[1];
                        params[0] = expr;
                    }
                    if (ident.equals("plot")) { 
                        if (params.length < 3) { 
                            throw new CompileError("Plot function expect three or four parameters");
                        }
                        PlotExpression plot = new PlotExpression();
                        plot.from = params[0];
                        plot.till = params[1];
                        Expression func;
                        if (params.length == 4) { 
                            plot.step = params[2];
                            func = params[3];
                        } else { 
                            func = params[2];
                            plot.step = null;
                        }
                        if (!(func instanceof VariableExpression)) { 
                            throw new CompileError("Last parameter of plot should be function");
                        }
                        plot.func = ((VariableExpression)func).name;
                        expr = plot;
                    } else { 
                        Integer kind = (Integer)builtin.get(ident);
                        if (kind != null) { 
                            if (params.length != 1) { 
                                throw new CompileError("Function " + ident + " has one parameter");
                            }
                            expr = new BuiltinFunction(kind.intValue(), params[0]);
                        } else { 
                            FunctionCallExpression call = new FunctionCallExpression();
                            call.name = ident;
                            call.parameters = params;
                            expr = call;
                        }
                    }
                } else { 
                    return new VariableExpression(ident);
                }
            }            
            break;
        default:
            throw new CompileError("Syntax error");
        }
        tkn = scan();
        return expr;
    }

    int scan() { 
        char ch = 0;
        int i = pos;
        int n = str.length();
        while (i < n && ((ch = str.charAt(i)) == ' ' || ch == '\n')) { 
            i += 1;
        }
        pos = i;
        if (i == n) { 
            return -1;
        }
        if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_') { 
            while (++i < n && (((ch = str.charAt(i)) >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_'));
            name = str.substring(pos, i).toLowerCase();
            pos = i;
            return 'a';
        } else if (ch >= '0' && ch <= '9') { 
            while (++i < n && (ch = str.charAt(i)) >= '0' && ch <= '9');
            if (ch == '.') { 
                while (++i < n && (ch = str.charAt(i)) >= '0' && ch <= '9');
            }
            if (ch == 'e' || ch == 'E') { 
                if (i+1 < n && (ch = str.charAt(i+1)) == '+' || ch == '-') { 
                    i += 1;
                }
                while (++i < n && (ch = str.charAt(i)) >= '0' && ch <= '9');
            }
            value = Float.parse(str.substring(pos, i), 10);
            pos = i;
            return '0';
        } else { 
            pos = i+1;
            return ch;
        }
    }

    FunctionExpression function;
    String[]           parameters;
    Float              value;
    String             str;
    String             name;
    int                pos;
    int                tkn;
}
