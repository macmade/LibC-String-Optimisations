/*******************************************************************************
 * XEOS - X86 Experimental Operating System
 * 
 * Copyright (c) 2010-2013, Jean-David Gadina - www.xs-labs.com
 * All rights reserved.
 * 
 * XEOS Software License - Version 1.0 - December 21, 2012
 * 
 * Permission is hereby granted, free of charge, to any person or organisation
 * obtaining a copy of the software and accompanying documentation covered by
 * this license (the "Software") to deal in the Software, with or without
 * modification, without restriction, including without limitation the rights
 * to use, execute, display, copy, reproduce, transmit, publish, distribute,
 * modify, merge, prepare derivative works of the Software, and to permit
 * third-parties to whom the Software is furnished to do so, all subject to the
 * following conditions:
 * 
 *      1.  Redistributions of source code, in whole or in part, must retain the
 *          above copyright notice and this entire statement, including the
 *          above license grant, this restriction and the following disclaimer.
 * 
 *      2.  Redistributions in binary form must reproduce the above copyright
 *          notice and this entire statement, including the above license grant,
 *          this restriction and the following disclaimer in the documentation
 *          and/or other materials provided with the distribution, unless the
 *          Software is distributed by the copyright owner as a library.
 *          A "library" means a collection of software functions and/or data
 *          prepared so as to be conveniently linked with application programs
 *          (which use some of those functions and data) to form executables.
 * 
 *      3.  The Software, or any substancial portion of the Software shall not
 *          be combined, included, derived, or linked (statically or
 *          dynamically) with software or libraries licensed under the terms
 *          of any GNU software license, including, but not limited to, the GNU
 *          General Public License (GNU/GPL) or the GNU Lesser General Public
 *          License (GNU/LGPL).
 * 
 *      4.  All advertising materials mentioning features or use of this
 *          software must display an acknowledgement stating that the product
 *          includes software developed by the copyright owner.
 * 
 *      5.  Neither the name of the copyright owner nor the names of its
 *          contributors may be used to endorse or promote products derived from
 *          this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT OWNER AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE, TITLE AND NON-INFRINGEMENT ARE DISCLAIMED.
 * 
 * IN NO EVENT SHALL THE COPYRIGHT OWNER, CONTRIBUTORS OR ANYONE DISTRIBUTING
 * THE SOFTWARE BE LIABLE FOR ANY CLAIM, DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN ACTION OF CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************/

/* $Id$ */

#include <stdlib.h>
#include <stdint.h>

void * xeos_memcpy_c( void * restrict s1, const void * restrict s2, size_t n );
void * xeos_memcpy_c( void * restrict s1, const void * restrict s2, size_t n )
{
    /* Note: scopes are used in order to comply with the 'restrict' keyword */
    
    if( s1 == NULL || s2 == NULL || n == 0 )
    {
        return s1;
    }
    
    {
        unsigned char       * cp1;
        const unsigned char * cp2;
        unsigned long       * lp1;
        const unsigned long * lp2;
        
        cp1 = s1;
        cp2 = s2;
        
        while( n > 0 && ( ( ( uintptr_t )cp2 & ( uintptr_t )-sizeof( unsigned long ) ) < ( uintptr_t )cp2 ) )
        {
            *( cp1++ ) = *( cp2++ );
            
            n--;
        }
            
        lp1 = ( void * )cp1;
        lp2 = ( void * )cp2;
        
        if( ( ( uintptr_t )lp1 & ( uintptr_t )-sizeof( unsigned long ) ) == ( uintptr_t )lp1 )
        {
            while( n >= sizeof( unsigned long ) * 16 )
            {
                lp1[  0 ] = lp2[  0 ];
                lp1[  1 ] = lp2[  1 ];
                lp1[  2 ] = lp2[  2 ];
                lp1[  3 ] = lp2[  3 ];
                lp1[  4 ] = lp2[  4 ];
                lp1[  5 ] = lp2[  5 ];
                lp1[  6 ] = lp2[  6 ];
                lp1[  7 ] = lp2[  7 ];
                lp1[  8 ] = lp2[  8 ];
                lp1[  9 ] = lp2[  9 ];
                lp1[ 10 ] = lp2[ 10 ];
                lp1[ 11 ] = lp2[ 11 ];
                lp1[ 12 ] = lp2[ 12 ];
                lp1[ 13 ] = lp2[ 13 ];
                lp1[ 14 ] = lp2[ 14 ];
                lp1[ 15 ] = lp2[ 15 ];
                n        -= sizeof( unsigned long ) * 16;
                lp1      += 16;
                lp2      += 16;
            }
            
            while( n >= sizeof( unsigned long ) * 8 )
            {
                lp1[ 0 ] = lp2[ 0 ];
                lp1[ 1 ] = lp2[ 1 ];
                lp1[ 2 ] = lp2[ 2 ];
                lp1[ 3 ] = lp2[ 3 ];
                lp1[ 4 ] = lp2[ 4 ];
                lp1[ 5 ] = lp2[ 5 ];
                lp1[ 6 ] = lp2[ 6 ];
                lp1[ 7 ] = lp2[ 7 ];
                n       -= sizeof( unsigned long ) * 8;
                lp1     += 8;
                lp2     += 8;
            }
            
            while( n >= sizeof( unsigned long ) )
            {
                *( lp1++ ) = *( lp2++ );
                n         -= sizeof( unsigned long );
            }
            
            cp1 = ( void * )lp1;
            cp2 = ( void * )lp2;
            
            while( n-- )
            {
                *( cp1++ ) = *( cp2++ );
            }
        }
        else
        {
            cp1 = ( void * )lp1;
            cp2 = ( void * )lp2;
            
            while( n-- )
            {
                *( cp1++ ) = *( cp2++ );
            }
        }
    }
    
    return s1;
}
