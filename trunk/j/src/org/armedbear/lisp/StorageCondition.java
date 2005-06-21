/*
 * StorageCondition.java
 *
 * Copyright (C) 2004-2005 Peter Graves
 * $Id: StorageCondition.java,v 1.3 2005-06-21 18:42:15 piso Exp $
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

public class StorageCondition extends SeriousCondition
{
    public StorageCondition()
    {
    }

    public StorageCondition(LispObject initArgs) throws ConditionThrowable
    {
        super(initArgs);
    }

    public StorageCondition(String message)
    {
        super(message);
    }

    public LispObject typeOf()
    {
        return Symbol.STORAGE_CONDITION;
    }

    public LispObject classOf()
    {
        return StandardClass.STORAGE_CONDITION;
    }

    public LispObject typep(LispObject type) throws ConditionThrowable
    {
        if (type == Symbol.STORAGE_CONDITION)
            return T;
        if (type == StandardClass.STORAGE_CONDITION)
            return T;
        return super.typep(type);
    }
}
