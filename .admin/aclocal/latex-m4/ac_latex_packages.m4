#
#   Copyright (C) 2004  Boretti Mathieu
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
# AC_LATEX_PACKAGES([<package1>,<package2>,...,<packagen>],<class>,<variable>)
#
# Test the presences of package1 or if not package2 and so
# Using class <class> and set $<variable> to the right value 
# or no if not found
#
#
dnl @synopsis AC_LATEX_PACKAGES([<package1>,<package2>,<package3>],<class>,<variable>)
dnl
dnl This macro test if package1 in <class> exists and if not package2 and so
dnl and set <variable> to the right value
dnl
dnl  AC_LATEX_PACKAGES([allo,varioref,bonjour],book,vbook)
dnl  should set $vbook="varioref"
dnl
dnl @version 1.3
dnl @author Mathieu Boretti boretti@eig.unige.ch
dnl
define(_AC_LATEX_PACKAGE_INTERNE,[
	ifelse($#,0,[],$#,1,[],$#,2,[],$#,3,[
		AC_LATEX_PACKAGE($3,$2,$1)
	],[
		AC_LATEX_PACKAGE($3,$2,$1)
		if test "$$1" = "yes";
		then
			$1=$3 ; export $1 ;
		else
			_AC_LATEX_PACKAGE_INTERNE($1,$2,m4_shift(m4_shift(m4_shift($@))))
		fi;
	])
])

AC_DEFUN([AC_LATEX_PACKAGES],[
	_AC_LATEX_PACKAGE_INTERNE($3,$2,$1)
	AC_SUBST($3)
])