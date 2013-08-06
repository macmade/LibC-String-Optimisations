C String Optimisations
======================

About
-----

**Heavily optimised** versions of the string functions from the C standard library, for x86 and x86_64, developed for the [XEOS Operating System](http://www.xs-labs.com/en/projects/xeos/).

**32** and **64** bits versions are available.  
When applicable, and if the CPU supports it, the functions will take advantage of the **SSE2 instruction** set.  
If not, less-optimised versions will be used.

Source code is written in **assembly**, with a test C file for each function, benchmarking it versus the system implementation.

Some numbers
------------

Here are a few benchmark results, compared to the C library implementation of **OS X 10.9** (which is also heavily optimised):

### 1 - strlen()

Test consists of **10000000** (10 millions) calls to `strlen()` with a 1000 characters string:

    OS X strlen() / 64bits:				0.531318 seconds
    XEOS strlen() / 64bits - SSE2:		0.527532 seconds
    XEOS strlen() / 64bits:				3.850802 seconds
    
    OS X strlen() / 32bits: 		  	0.610977 seconds
    XEOS strlen() / 32bits - SSE2:    	0.607162 seconds
    XEOS strlen() / 32bits: 		  	4.185022 seconds
    
### 2 - memset()

Test consists of **10000000** (10 millions) calls to `memset()` with a 4096 byes buffer:

    OS X memset() / 64bits:				0.906685 seconds
    XEOS memset() / 64bits - SSE2:		0.778556 seconds
    XEOS memset() / 64bits:				N/A (not developed yet)
    
    OS X memset() / 32bits: 		  	0.869590
    XEOS memset() / 32bits - SSE2:    	N/A (not developed yet)
    XEOS memset() / 32bits: 		  	N/A (not developed yet)
    
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
