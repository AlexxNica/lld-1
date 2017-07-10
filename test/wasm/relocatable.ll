; RUN: llc -filetype=obj %p/Inputs/hello.ll -o %t.hello.o
; RUN: llc -filetype=obj %s -o %t.o
; RUN: lld -flavor wasm -r -o %t.wasm %t.hello.o %t.o
; RUN: obj2yaml %t.wasm | FileCheck %s

target datalayout = "e-m:e-p:32:32-i64:64-n32:64-S128"
target triple = "wasm32-unknown-unknown-wasm"

; Function Attrs: nounwind
define hidden i32 @my_func() local_unnamed_addr #0 {
entry:
  %call = tail call i32 @foo_import() #2
  ret i32 1
}

declare i32 @foo_import() local_unnamed_addr #1

@func_addr1 = hidden global i32()* @my_func, align 4
@func_addr2 = hidden global i32()* @foo_import, align 4

; CHECK:      --- !WASM
; CHECK-NEXT: FileHeader:      
; CHECK-NEXT:   Version:         0x00000001
; CHECK-NEXT: Sections:        
; CHECK-NEXT:   - Type:            TYPE
; CHECK-NEXT:     Signatures:      
; CHECK-NEXT:       - Index:           0
; CHECK-NEXT:         ReturnType:      NORESULT
; CHECK-NEXT:         ParamTypes:      
; CHECK-NEXT:       - Index:           1
; CHECK-NEXT:         ReturnType:      NORESULT
; CHECK-NEXT:         ParamTypes:      
; CHECK-NEXT:           - I32
; CHECK-NEXT:       - Index:           2
; CHECK-NEXT:         ReturnType:      I32
; CHECK-NEXT:         ParamTypes:      
; CHECK-NEXT:   - Type:            IMPORT
; CHECK-NEXT:     Imports:         
; CHECK-NEXT:       - Module:          env
; CHECK-NEXT:         Field:           puts
; CHECK-NEXT:         Kind:            FUNCTION
; CHECK-NEXT:         SigIndex:        1
; CHECK-NEXT:       - Module:          env
; CHECK-NEXT:         Field:           foo_import
; CHECK-NEXT:         Kind:            FUNCTION
; CHECK-NEXT:         SigIndex:        2
; CHECK-NEXT:   - Type:            FUNCTION
; CHECK-NEXT:     FunctionTypes:   [ 0, 2 ]
; CHECK-NEXT:   - Type:            TABLE
; CHECK-NEXT:     Tables:          
; CHECK-NEXT:       - ElemType:        ANYFUNC
; CHECK-NEXT:         Limits:          
; CHECK-NEXT:           Flags:           0x00000001
; CHECK-NEXT:           Initial:         0x00000002
; CHECK-NEXT:           Maximum:         0x00000002
; CHECK-NEXT:   - Type:            MEMORY
; CHECK-NEXT:     Memories:        
; CHECK-NEXT:       - Initial:         0x00000001
; CHECK-NEXT:   - Type:            GLOBAL
; CHECK-NEXT:     Globals:         
; CHECK-NEXT:       - Type:            I32
; CHECK-NEXT:         Mutable:         false
; CHECK-NEXT:         InitExpr:        
; CHECK-NEXT:           Opcode:          I32_CONST
; CHECK-NEXT:           Value:           0
; CHECK-NEXT:       - Type:            I32
; CHECK-NEXT:         Mutable:         false
; CHECK-NEXT:         InitExpr:        
; CHECK-NEXT:           Opcode:          I32_CONST
; CHECK-NEXT:           Value:           8
; CHECK-NEXT:       - Type:            I32
; CHECK-NEXT:         Mutable:         false
; CHECK-NEXT:         InitExpr:        
; CHECK-NEXT:           Opcode:          I32_CONST
; CHECK-NEXT:           Value:           12
; CHECK-NEXT:   - Type:            EXPORT
; CHECK-NEXT:     Exports:         
; CHECK-NEXT:       - Name:            hello
; CHECK-NEXT:         Kind:            FUNCTION
; CHECK-NEXT:         Index:           2
; CHECK-NEXT:       - Name:            my_func
; CHECK-NEXT:         Kind:            FUNCTION
; CHECK-NEXT:         Index:           3
; CHECK-NEXT:   - Type:            ELEM
; CHECK-NEXT:     Segments:        
; CHECK-NEXT:       - Offset:          
; CHECK-NEXT:           Opcode:          I32_CONST
; CHECK-NEXT:           Value:           0
; CHECK-NEXT:         Functions:       [ 3, 1 ]
; CHECK-NEXT:   - Type:            CODE
; CHECK-NEXT:     Relocations:     
; CHECK-NEXT:       - Type:            R_WEBASSEMBLY_GLOBAL_ADDR_SLEB
; CHECK-NEXT:         Index:           0
; CHECK-NEXT:         Offset:          0x00000004
; CHECK-NEXT:       - Type:            R_WEBASSEMBLY_FUNCTION_INDEX_LEB
; CHECK-NEXT:         Index:           0
; CHECK-NEXT:         Offset:          0x0000000A
; CHECK-NEXT:       - Type:            R_WEBASSEMBLY_FUNCTION_INDEX_LEB
; CHECK-NEXT:         Index:           1
; CHECK-NEXT:         Offset:          0x00000013
; CHECK-NEXT:     Functions:       
; CHECK-NEXT:       - Locals:          
; CHECK-NEXT:         Body:          {{.*}}
; CHECK-NEXT:       - Locals:          
; CHECK-NEXT:         Body:          {{.*}}
; CHECK-NEXT:   - Type:            DATA
; CHECK-NEXT:     Relocations:     
; CHECK-NEXT:       - Type:            R_WEBASSEMBLY_TABLE_INDEX_I32
; CHECK-NEXT:         Index:           0
; CHECK-NEXT:         Offset:          0x00000012
; CHECK-NEXT:       - Type:            R_WEBASSEMBLY_TABLE_INDEX_I32
; CHECK-NEXT:         Index:           1
; CHECK-NEXT:         Offset:          0x00000016
; CHECK-NEXT:     Segments:        
; CHECK-NEXT:       - SectionOffset:     6
; CHECK-NEXT:         MemoryIndex:       0
; CHECK-NEXT:         Offset:          
; CHECK-NEXT:           Opcode:          I32_CONST
; CHECK-NEXT:           Value:           0
; CHECK-NEXT:         Content:         68656C6C6F0A00
; CHECK-NEXT:       - SectionOffset:     18
; CHECK-NEXT:         MemoryIndex:       0
; CHECK-NEXT:         Offset:
; CHECK-NEXT:           Opcode:          I32_CONST
; CHECK-NEXT:           Value:           8
; CHECK-NEXT:         Content:         '0000000001000000'
; CHECK-NEXT:   - Type:            CUSTOM
; CHECK-NEXT:     Name:            linking
; CHECK-NEXT:     DataSize:        16
; CHECK-NEXT:     DataAlignment:   4
; CHECK-NEXT:     SymbolInfo:      
; CHECK-NEXT:   - Type:            CUSTOM
; CHECK-NEXT:     Name:            name
; CHECK-NEXT:     FunctionNames:   
; CHECK-NEXT:       - Index:           0
; CHECK-NEXT:         Name:            puts
; CHECK-NEXT:       - Index:           1
; CHECK-NEXT:         Name:            foo_import
; CHECK-NEXT:       - Index:           2
; CHECK-NEXT:         Name:            hello
; CHECK-NEXT:       - Index:           3
; CHECK-NEXT:         Name:            my_func
; CHECK-NEXT: ...
