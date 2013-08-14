;-------------------------------------------------------------------------------
; XEOS - X86 Experimental Operating System
; 
; Copyright (c) 2010-2013, Jean-David Gadina - www.xs-labs.com
; All rights reserved.
; 
; XEOS Software License - Version 1.0 - December 21, 2012
; 
; Permission is hereby granted, free of charge, to any person or organisation
; obtaining a copy of the software and accompanying documentation covered by
; this license (the "Software") to deal in the Software, with or without
; modification, without restriction, including without limitation the rights
; to use, execute, display, copy, reproduce, transmit, publish, distribute,
; modify, merge, prepare derivative works of the Software, and to permit
; third-parties to whom the Software is furnished to do so, all subject to the
; following conditions:
; 
;       1.  Redistributions of source code, in whole or in part, must retain the
;           above copyright notice and this entire statement, including the
;           above license grant, this restriction and the following disclaimer.
; 
;       2.  Redistributions in binary form must reproduce the above copyright
;           notice and this entire statement, including the above license grant,
;           this restriction and the following disclaimer in the documentation
;           and/or other materials provided with the distribution, unless the
;           Software is distributed by the copyright owner as a library.
;           A "library" means a collection of software functions and/or data
;           prepared so as to be conveniently linked with application programs
;           (which use some of those functions and data) to form executables.
; 
;       3.  The Software, or any substancial portion of the Software shall not
;           be combined, included, derived, or linked (statically or
;           dynamically) with software or libraries licensed under the terms
;           of any GNU software license, including, but not limited to, the GNU
;           General Public License (GNU/GPL) or the GNU Lesser General Public
;           License (GNU/LGPL).
; 
;       4.  All advertising materials mentioning features or use of this
;           software must display an acknowledgement stating that the product
;           includes software developed by the copyright owner.
; 
;       5.  Neither the name of the copyright owner nor the names of its
;           contributors may be used to endorse or promote products derived from
;           this software without specific prior written permission.
; 
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT OWNER AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
; THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
; PURPOSE, TITLE AND NON-INFRINGEMENT ARE DISCLAIMED.
; 
; IN NO EVENT SHALL THE COPYRIGHT OWNER, CONTRIBUTORS OR ANYONE DISTRIBUTING
; THE SOFTWARE BE LIABLE FOR ANY CLAIM, DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
; EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
; PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
; WHETHER IN ACTION OF CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF OR IN CONNECTION WITH
; THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE, EVEN IF ADVISED
; OF THE POSSIBILITY OF SUCH DAMAGE.
;-------------------------------------------------------------------------------

; $Id$

; We are in 32 bits mode
BITS    32

section .data

global __SSE2Status

; SSE2 status flag:
; 
;   -1: Unchecked
;    0: SSE2 not available
;    1: SSE2 available
__SSE2Status:   dd  -1

section .text

; Makes the entry point visible to the linker
global _xeos_memcpy

;-------------------------------------------------------------------------------
; C99 - 32 bits memcpy() function
; 
; void * memcpy( void * restrict s1, const void * restrict s2, size_t n );
; 
; Input registers:
;       
;       None - Arguments on stack
; 
; Return registers:
;       
;       - EAX:      The destination pointer
; 
; Killed registers:
;       
;       None - __cdecl (all except EAX, ECX, EDX must be preserved)
;-------------------------------------------------------------------------------
_xeos_memcpy:
    
    ; Checks the status of the SSE2 flag
    cmp DWORD [ ds:__SSE2Status ], 1
    
    ; SSE2 are available - Use the optimized version of memcpy()
    je  _memcpy32_sse2
    
    ; Checks the status of the SSE2 flag
    cmp DWORD [ ds:__SSE2Status ], 0
    
    ; SSE2 are not available - Use the less-optimized version of memcpy()
    je  _memcpy32
    
    ; SSE2 status needs to be checked
    .check:
        
        ; CPUID - Asks for CPU features (EAX=1)
        mov     eax,    1
        cpuid
        
        ; Checks the SSE2 bit (bit 26)
        test    edx,    0x4000000      
        jz      .fail
        
    ; SSE2 available
    .ok:
        
        ; Sets the SSE2 status flag for the next calls and process the buffer
        ; with the optimized version of memcpy()
        mov DWORD [ ds:__SSE2Status ], 1
        jmp _memcpy32_sse2
    
    ; SSE2 not available
    .fail:
        
        ; Sets the SSE2 status flag for the next calls and process the buffer
        ; with the less-optimized version of memcpy()
        mov DWORD [ ds:__SSE2Status ], 0
        jmp _memcpy32

;-------------------------------------------------------------------------------
; 32-bits SSE2 optimized memcpy() function
; 
; void * _memcpy32_sse2( void * restrict s1, const void * restrict s2, size_t n );
; 
; Input registers:
;       
;       None - Arguments on stack
; 
; Return registers:
;       
;       - EAX:      A pointer to the first occurence of the character in the
;                   buffer, or 0 (NULL)
; 
; Killed registers:
;       
;       None - __cdecl (all except EAX, ECX, EDX must be preserved)
;-------------------------------------------------------------------------------
_memcpy32_sse2:
    
    ; Creates a stack frame, so we can save registers, making them available
    ; to use. Otherwise, only 3 registers are safe, which is not enough here
    push    ebp
    mov     ebp,        esp
    
    ; Saves EDI and ESI as we are going to use them
    push    edi
    push    esi
    
    ; Gets the arguments from the stack
    mov     edi,        [ ebp +  8 ]
    mov     esi,        [ ebp + 12 ]
    mov     edx,        [ ebp + 16 ]
    
    ; Checks for a NULL destination pointer
    test        edi,        edi
    jz          .ret
    
    ; Checks for a NULL source pointer
    test        esi,        esi
    jz          .ret
    
    ; Gets the number of misaligned bytes in the original source pointer
    mov         eax,        esi
    mov         ecx,        esi
    and         ecx,        -16
    sub         eax,        ecx
    mov         ecx,        16
    sub         ecx,        eax
    
    ; Checks if the source pointer is already aligned
    cmp         ecx,        16
    jne         .source_notaligned
        
    .source_aligned:
        
        ; Gets the number of misaligned bytes in the original destination pointer
        mov         eax,        edi
        mov         ecx,        edi
        and         ecx,        -16
        sub         eax,        ecx
        mov         ecx,        16
        sub         ecx,        eax
        
        ; Checks if the destination pointer is also aligned
        cmp         ecx,        16
        jne         .dest_notaligned
        
        .source_dest_aligned:
            
            ; Writes 128 bytes at a time, if possible
            cmp         edx,        128
            jb          .source_dest_aligned_64
            
            .source_dest_aligned_128:
                
                ; Reads 128 bytes from the source buffer
                movdqa      xmm0,           [ esi ]
                movdqa      xmm1,           [ esi + 16 ]
                movdqa      xmm2,           [ esi + 32 ]
                movdqa      xmm3,           [ esi + 48 ]
                movdqa      xmm4,           [ esi + 64 ]
                movdqa      xmm5,           [ esi + 80 ]
                movdqa      xmm6,           [ esi + 96 ]
                movdqa      xmm7,           [ esi + 112 ]
                
                ; Writes 128 bytes into the destination buffer
                movdqa      [ edi ],        xmm0
                movdqa      [ edi +  16 ],  xmm1
                movdqa      [ edi +  32 ],  xmm2
                movdqa      [ edi +  48 ],  xmm3
                movdqa      [ edi +  64 ],  xmm4
                movdqa      [ edi +  80 ],  xmm5
                movdqa      [ edi +  96 ],  xmm6
                movdqa      [ edi + 112 ],  xmm7
                
                ; Advances the source and destination pointers and decreases
                ; the number of bytes to write
                add         edi,        128
                add         esi,        128
                sub         edx,        128
                
                ; Writes 128 bytes at a time, if possible
                cmp         edx,        128
                jge         .source_dest_aligned_128
            
            .source_dest_aligned_64:
                
                ; Writes 64 bytes at a time, if possible
                cmp         edx,        64
                jb          .source_dest_aligned_16
                
                ; Reads 64 bytes from the source buffer
                movdqa      xmm0,           [ esi ]
                movdqa      xmm1,           [ esi + 16 ]
                movdqa      xmm2,           [ esi + 32 ]
                movdqa      xmm3,           [ esi + 48 ]
                
                ; Writes 64 bytes into the destination buffer
                movdqa      [ edi ],        xmm0
                movdqa      [ edi +  16 ],  xmm1
                movdqa      [ edi +  32 ],  xmm2
                movdqa      [ edi +  48 ],  xmm3
                
                ; Advances the source and destination pointers and decreases
                ; the number of bytes to write
                add         edi,        64
                add         esi,        64
                sub         edx,        64
                
                ; Continues writing
                jmp         .source_dest_aligned_64
                
            .source_dest_aligned_16:
                
                ; Writes 16 bytes at a time, if possible
                cmp         edx,        16
                jb          .copy_end
                
                ; Reads 16 bytes from the source buffer
                movdqa      xmm0,       [ esi ]
                
                ; Writes 16 bytes into the destination buffer
                movdqa      [ edi ],    xmm0
                
                ; Advances the source and destination pointers and decreases
                ; the number of bytes to write
                add         edi,        16
                add         esi,        16
                sub         edx,        16
                
                ; Continues writing
                jmp         .source_dest_aligned_16
                
                ; Writes remaining bytes one by one
                jmp         .copy_end
                
        .dest_notaligned:
            
            ; Writes 128 bytes at a time, if possible
            cmp         edx,        128
            jb          .dest_notaligned_64
            
            .dest_notaligned_128:
                
                ; Reads 128 bytes from the source buffer
                movdqa      xmm0,           [ esi ]
                movdqa      xmm1,           [ esi + 16 ]
                movdqa      xmm2,           [ esi + 32 ]
                movdqa      xmm3,           [ esi + 48 ]
                movdqa      xmm4,           [ esi + 64 ]
                movdqa      xmm5,           [ esi + 80 ]
                movdqa      xmm6,           [ esi + 96 ]
                movdqa      xmm7,           [ esi + 112 ]
                
                ; Writes 128 bytes into the destination buffer
                movdqu      [ edi ],        xmm0
                movdqu      [ edi +  16 ],  xmm1
                movdqu      [ edi +  32 ],  xmm2
                movdqu      [ edi +  48 ],  xmm3
                movdqu      [ edi +  64 ],  xmm4
                movdqu      [ edi +  80 ],  xmm5
                movdqu      [ edi +  96 ],  xmm6
                movdqu      [ edi + 112 ],  xmm7
                
                ; Advances the source and destination pointers and decreases
                ; the number of bytes to write
                add         edi,        128
                add         esi,        128
                sub         edx,        128
                
                ; Writes 128 bytes at a time, if possible
                cmp         edx,        128
                jge         .dest_notaligned_128
            
            .dest_notaligned_64:
                
                ; Writes 64 bytes at a time, if possible
                cmp         edx,        64
                jb          .dest_notaligned_16
                
                ; Reads 64 bytes from the source buffer
                movdqa      xmm0,           [ esi ]
                movdqa      xmm1,           [ esi + 16 ]
                movdqa      xmm2,           [ esi + 32 ]
                movdqa      xmm3,           [ esi + 48 ]
                
                ; Writes 64 bytes into the destination buffer
                movdqu      [ edi ],        xmm0
                movdqu      [ edi +  16 ],  xmm1
                movdqu      [ edi +  32 ],  xmm2
                movdqu      [ edi +  48 ],  xmm3
                
                ; Advances the source and destination pointers and decreases
                ; the number of bytes to write
                add         edi,        64
                add         esi,        64
                sub         edx,        64
                
                ; Continues writing
                jmp         .dest_notaligned_64
                
            .dest_notaligned_16:
                
                ; Writes 16 bytes at a time, if possible
                cmp         edx,        16
                jb          .copy_end
                
                ; Reads 16 bytes from the source buffer
                movdqa      xmm0,       [ esi ]
                
                ; Writes 16 bytes into the destination buffer
                movdqu      [ edi ],    xmm0
                
                ; Advances the source and destination pointers and decreases
                ; the number of bytes to write
                add         edi,        16
                add         esi,        16
                sub         edx,        16
                
                ; Continues writing
                jmp         .dest_notaligned_16
                
    .copy_end:
        
        ; Checks if we have bytes to write
        test        edx,        edx
        jz          .ret
        
        ; Reads a byte from the source buffer
        mov         al,         [ esi ]
        
        ; Writes a byte into the destination buffer
        mov         [ edi ],    al
        
        ; Advances the source and destination pointers and decreases
        ; the number of bytes to write
        add         edi,        1
        add         esi,        1
        sub         edx,        1
        sub         ecx,        1
        
        ; Not aligned - Continues writing single bytes
        jmp         .copy_end
        
    .source_notaligned:
        
        ; Checks if we have bytes to write
        test        edx,        edx
        jz          .ret
        
        ; Reads a byte from the source buffer
        mov         al,         [ esi ]
        
        ; Writes a byte into the destination buffer
        mov         [ edi ],    al
        
        ; Advances the source and destination pointers and decreases
        ; the number of bytes to write
        add         edi,        1
        add         esi,        1
        sub         edx,        1
        sub         ecx,        1
        
        ; Checks if we're aligned
        test        ecx,        ecx
        jz          .source_aligned
        
        ; Not aligned - Continues writing single bytes
        jmp         .source_notaligned
        
    .ret:
        
        ; Returns the original destination pointer
        mov         eax,    [ ebp +  8 ]
        
        ; Restores saved registers
        pop         esi
        pop         edi
        pop         ebp
        
        ret

;-------------------------------------------------------------------------------
; 32-bits optimized memcpy() function
; 
; void * _memcpy32( void * restrict s1, const void * restrict s2, size_t n );
; 
; Input registers:
;       
;       None - Arguments on stack
; 
; Return registers:
;       
;       - EAX:      A pointer to the first occurence of the character in the
;                   buffer, or 0 (NULL)
; 
; Killed registers:
;       
;       None - __cdecl (all except EAX, ECX, EDX must be preserved)
;-------------------------------------------------------------------------------   
_memcpy32:
    
    ; Creates a stack frame, so we can save registers, making them available
    ; to use. Otherwise, only 3 registers are safe, which is not enough here
    push    ebp
    mov     ebp,        esp
    
    ; Saves EDI, ESI and EBX as we are going to use them
    push    edi
    push    esi
    push    ebx
    
    ; Gets the arguments from the stack
    mov     edi,        [ ebp +  8 ]
    mov     esi,        [ ebp + 12 ]
    mov     edx,        [ ebp + 16 ]
    
    mov     eax,        edi
    
    ; Restores saved registers
    pop         ebx
    pop         esi
    pop         edi
    pop         ebp
    
    ret
