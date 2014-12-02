C String Optimisations
======================

[![Build Status](https://img.shields.io/travis/macmade/LibC-String-Optimisations.svg?branch=master&style=flat)](https://travis-ci.org/macmade/LibC-String-Optimisations)
[![Issues](http://img.shields.io/github/issues/macmade/LibC-String-Optimisations.svg?style=flat)](https://github.com/macmade/LibC-String-Optimisations/issues)
![Status](https://img.shields.io/badge/status-active-brightgreen.svg?style=flat)
![License](https://img.shields.io/badge/license-xeos-brightgreen.svg?style=flat)
[![Contact](https://img.shields.io/badge/contact-@macmade-blue.svg?style=flat)](https://twitter.com/macmade)

About
-----

**Heavily optimised** versions of the string functions from the C standard library, for x86 and x86_64 platforms, developed for the [XEOS Operating System](http://www.xs-labs.com/en/projects/xeos/).

**32** and **64** bits versions are available.  
When applicable, and if the CPU supports it, the functions will take advantage of the **SSE2 instruction** set.  
If not, less-optimised versions will be used.

Source code is written in **assembly**, with a test C file and a standard C implementation for each function, benchmarking it versus the system implementation.

Some numbers
------------

Here are a few benchmark results, compared to the C library implementation of **OS X 10.9** (which is also heavily optimised):

### 1 - strlen()

Test consists of **10000000** (10 millions) calls to `strlen()` with a 1000 characters string:

    OS X strlen() / 64bits:				0.531318 seconds
    XEOS strlen() / 64bits:				0.527532 seconds	<-- Best result: XEOS
    
    OS X strlen() / 32bits: 		  	0.610977 seconds
    XEOS strlen() / 32bits:    			0.607162 seconds	<-- Best result: XEOS
    
### 2 - memset()

Test consists of **10000000** (10 millions) calls to `memset()` with a 4096 bytes buffer:

    OS X memset() / 64bits:					0.906685 seconds
    XEOS memset() / 64bits:					0.778556 seconds	<-- Best result: XEOS
    
    OS X memset() / 32bits: 		  		0.869590 seconds
    XEOS memset() / 32bits:    				0.798635 seconds    <-- Best result: XEOS
    
### 3 - memchr()

Test consists of **10000000** (10 millions) calls to `memchr()` with a 1000 bytes buffer, searching last character:

    OS X memchr() / 64bits:					0.516240 seconds
    XEOS memchr() / 64bits:					0.476380 seconds	<-- Best result: XEOS
    
    OS X memchr() / 32bits: 		  		6.374186 seconds
    XEOS memchr() / 32bits:    				0.532130 seconds    <-- Best result (!!!): XEOS
    
### 4 - memcpy()

Test consists of **10000000** (10 millions) calls to `memcpy()` with a 4096 bytes source buffer:

    OS X memcpy() / 64bits:					0.928405 seconds
    XEOS memcpy() / 64bits:					0.858043 seconds	<-- Best result: XEOS
    
    OS X memcpy() / 64bits - misaligned:	1.218205 seconds	<-- Best result: OS X
    XEOS memcpy() / 64bits - misaligned:	1.408296 seconds
    
    OS X memcpy() / 32bits: 		  		0.975120 seconds
    XEOS memcpy() / 32bits:    				0.952001 seconds    <-- Best result: XEOS
    
    OS X memcpy() / 32bits - misaligned:	1.446217 seconds	<-- Best result: OS X
    XEOS memcpy() / 32bits - misaligned:	1.457572 seconds    
    

### 5 - strcat()

Test consists of **10000000** (10 millions) calls to `strcat()` with 1000 characters source and destination strings:

    OS X strcat() / 64bits:					1.314561 seconds
    XEOS strcat() / 64bits:					1.269549 seconds	<-- Best result: XEOS
    
    OS X strcat() / 64bits - misaligned:	3.920867 seconds	
    XEOS strcat() / 64bits - misaligned:	1.423539 seconds	<-- Best result (!!!): XEOS
    
    OS X strcat() / 32bits: 		  		1.653358 seconds
    XEOS strcat() / 32bits:    				1.349833 seconds    <-- Best result: XEOS
    
    OS X strcat() / 32bits - misaligned:	4.644904 seconds	
    XEOS strcat() / 32bits - misaligned:	1.515425 seconds    <-- Best result (!!!): XEOS

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
