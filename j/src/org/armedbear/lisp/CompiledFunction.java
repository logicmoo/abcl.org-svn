/*
 * CompiledFunction.java
 *
 * Copyright (C) 2003-2004 Peter Graves
 * $Id: CompiledFunction.java,v 1.27 2004-09-15 13:19:01 piso Exp $
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

package org.armedbear.lisp;

public class CompiledFunction extends Closure
{
    public CompiledFunction(Symbol symbol, LispObject lambdaList,
                            LispObject body, Environment env)
        throws ConditionThrowable
    {
        super(null, lambdaList, body, env);
    }

    public LispObject typep(LispObject typeSpecifier) throws ConditionThrowable
    {
        if (typeSpecifier == Symbol.COMPILED_FUNCTION)
            return T;
        return super.typep(typeSpecifier);
    }

    public LispObject execute() throws ConditionThrowable
    {
        LispObject[] args = new LispObject[0];
        return execute(args);
    }

    public LispObject execute(LispObject arg) throws ConditionThrowable
    {
        LispObject[] args = new LispObject[1];
        args[0] = arg;
        return execute(args);
    }

    public LispObject execute(LispObject first, LispObject second)
        throws ConditionThrowable
    {
        LispObject[] args = new LispObject[2];
        args[0] = first;
        args[1] = second;
        return execute(args);
    }

    public LispObject execute(LispObject first, LispObject second,
                              LispObject third)
        throws ConditionThrowable
    {
        LispObject[] args = new LispObject[3];
        args[0] = first;
        args[1] = second;
        args[2] = third;
        return execute(args);
    }

    public LispObject execute(LispObject first, LispObject second,
                              LispObject third, LispObject fourth)
        throws ConditionThrowable
    {
        LispObject[] args = new LispObject[4];
        args[0] = first;
        args[1] = second;
        args[2] = third;
        args[3] = fourth;
        return execute(args);
    }

    public LispObject execute(LispObject[] args) throws ConditionThrowable
    {
        return signal(new LispError("CompiledFunction.execute(): not implemented"));
    }

    // ### make-compiled-function
    // make-compiled-function name lambda-list body => object
    private static final Primitive3 MAKE_COMPILED_FUNCTION =
        new Primitive3("make-compiled-function", PACKAGE_SYS, false)
    {
        public LispObject execute(LispObject first, LispObject second,
                                  LispObject third)
            throws ConditionThrowable
        {
            Symbol symbol;
            if (first == NIL)
                symbol = null;
            else
                symbol = checkSymbol(first);
            LispObject lambdaList = second;
            LispObject body = third;
            return new CompiledFunction(symbol, lambdaList, body,
                                        new Environment());
        }
    };

    // ### load-compiled-function
    private static final Primitive1 LOAD_COMPILED_FUNCTION =
        new Primitive1("load-compiled-function", PACKAGE_SYS, true,
                       "pathname")
    {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            String namestring = null;
            if (arg instanceof Pathname) {
                namestring = ((Pathname)arg).getNamestring();
            } else if (arg instanceof AbstractString) {
                namestring = arg.getStringValue();
            }
            if (namestring != null)
                return loadCompiledFunction(namestring);
            return signal(new LispError("Unable to load " + arg.writeToString()));
        }
    };

    // ### varlist
    private static final Primitive1 VARLIST =
        new Primitive1("varlist", PACKAGE_SYS, false)
    {
        public LispObject execute(LispObject arg) throws ConditionThrowable {
            if (arg instanceof Closure)
                return ((Closure)arg).getVariableList();
            return signal(new TypeError(arg, "compiled function"));
        }
    };
}
