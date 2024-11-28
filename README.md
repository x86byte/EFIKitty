# INFORMATION
![image](https://github.com/user-attachments/assets/798f3d48-3eb0-4e78-bb3f-f575df6f7dcd)

## Contact
- **Telegram**: [@x86byte](https://t.me/x86byte)

# EFIKitty - Advanced UEFI Bootkit

EFIKitty is a UEFI bootkit written in x64 assembly that operates stealthily within the UEFI environment, bypassing Secure Boot and other security measures. It achieves this by injecting malicious payloads, manipulating UEFI variables, and hiding its presence from system memory scans. The payload can execute silently, evade detection, and persist after system reboots.

## Features
- **Payload Injection**: Injects a malicious payload into system memory.
- **Stealth Mode**: Activates stealth operations to avoid detection by hiding traces of the payload in system tables and memory.
- **Secure Boot Bypass**: Disables Secure Boot by modifying UEFI variables like `SecureBoot`, `db` (allowed certificates), and `dbx` (revoked certificates).
- **Memory Concealment**: Uses advanced techniques to hide the payload from memory scanners.
- **Persistence**: Ensures the payload persists even after a reboot by using Runtime Services to store it.
- **Injection Retry Logic**: In case of failure, the payload injection is retried automatically.

## How It Works
1. **Payload Injection**: EFIKitty first allocates memory for the payload and injects it stealthily into the UEFI environment. If injection fails, the system retries until successful.
   
2. **Stealth Operations**: After successfully injecting the payload, EFIKitty disables Secure Boot and modifies UEFI variables:
    - **Disables Secure Boot**: Manipulates the `SecureBoot` variable to disable Secure Boot.
    - **Modifies Certificates**: Modifies the `db` (allowed certificates) and `dbx` (revoked certificates) variables to allow arbitrary code execution.
      ![image](https://github.com/user-attachments/assets/210325d1-cade-4e27-b2d2-a4e3492117fd)
      [Get-SecureBootUEFI (SecureBoot) ](https://learn.microsoft.com/en-us/powershell/module/secureboot/get-securebootuefi?view=windowsserver2022-ps)
      
3. **System Table Manipulation**: It manipulates the system tables to hide traces of the payload. The bootkit interacts with both the EFI system table and EFI boot services to make detection harder.

4. **Runtime Services**: The payload is moved into Runtime Services memory, ensuring that it persists across reboots and operates in stealth mode.

5. **Memory Hiding**: EFIKitty uses memory clearing and obfuscation techniques to prevent detection by memory scanners. It applies XOR-based obfuscation and moves the payload to less detectable areas of memory.

## Code Walkthrough

### Entry Point (`efi_main`)
- The `efi_main` function is the entry point for the UEFI application. It loads the EFI system table and initiates the payload injection process.
- If the payload injection succeeds, it proceeds with activating stealth operations to hide the payload and avoid detection.

### Payload Injection (`inject_advanced_payload`)

- Allocates memory for the payload.
- If memory allocation succeeds, it copies the payload into the allocated space and marks the injection as successful.
- In case of failure, it retries the injection process.

### Stealth Operations (`advanced_stealth_operations`)

1. **Disabling Secure Boot**: The bootkit disables Secure Boot by manipulating UEFI variables like `SecureBoot`, `db` (allowed certificates), and `dbx` (revoked certificates).
2. **Modifying System Tables**: It manipulates the system table to hide the payload, making it harder for detection tools to identify.
3. **Hiding the Payload**: The bootkit clears the memory or applies XOR obfuscation to the payload to prevent it from being discovered by memory scanners.
   
### Runtime Persistence (`advanced_stealth_operations_continue`)

- The bootkit ensures the payload persists after system reboots by copying the payload into the Runtime Services area, where it remains in memory even after exiting the UEFI shell.

### Memory Concealment (`hide_payload_from_memory_scans`)

- It zeroes out memory and applies advanced obfuscation techniques (such as XOR) to hide the payload from scanners that attempt to detect malicious code in memory.

## Key Functions

- `efi_allocate_pool`: Allocates memory in the UEFI environment for the payload.
- `efi_zero_mem`: Zeroes out a section of memory to hide traces of the payload.
- `efi_set_variable`: Modifies UEFI variables such as `SecureBoot`, `db`, and `dbx`.
- `efi_copy_mem`: Copies memory from one location to another, used for payload injection.
- `efi_exit_boot_services`: Safely exits the boot services without triggering security alerts.

## Security Considerations

- **Anti-Detection**: EFIKitty is designed to bypass common security mechanisms like Secure Boot, making it an effective tool for persistence and stealth.
- **Modifying UEFI Variables**: This bootkit manipulates critical UEFI variables and system tables, which can lead to significant system instability if used improperly.
- **Persistence**: By hiding itself in Runtime Services, it ensures its presence across reboots, making it challenging to remove.

