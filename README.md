C String Optimisations
======================

About
-----

**Heavily optimised** versions of the string functions from the C standard library, for x86 and x86_64, developed for the [XEOS Operating System](http://www.xs-labs.com/en/projects/xeos/).

**32** and **64** bits versions are available.  
When applicable, and if the CPU supports it, the functions will take advantage of the **SSE2 instruction** set.  
If not, less-optimised versions will be used.

Source code is written in **assembly**, with a test C file for each function, benchmarking it versus the system implementation.

License
-------

Whole source code is released under the terms of the [XEOS Software License](http://www.xs-labs.com/en/projects/xeos-software-license/terms/).

Repository Infos
----------------

    Owner:			Jean-David Gadina - XS-Labs
    Web:			www.xs-labs.com
    Blog:			www.noxeos.com
    Twitter:		@macmade
    GitHub:			github.com/macmade
    LinkedIn:		ch.linkedin.com/in/macmade/
    StackOverflow:	stackoverflow.com/users/182676/macmade
