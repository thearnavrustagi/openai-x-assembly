; Constants
SOCKET_DESCRIPTOR equ 3      ; File descriptor for the socket

; Data
request db 1024 dup(0)       ; Buffer for incoming HTTP request
response db "HTTP/1.1 200 OK", 0dh, 0ah,  ; HTTP response header
           "Content-Type: text/html", 0dh, 0ah, 0ah,
           "Hello, World!", 0

; Code
section .text
    global _start

_start:
    ; Create socket
    mov eax, 41                ; System call number for socket()
    mov ebx, 2                 ; AF_INET (IPv4)
    mov ecx, 1                 ; SOCK_STREAM (TCP)
    mov edx, 0                 ; Protocol (0 for default)
    int 0x80                   ; Invoke system call

    ; Check for error
    cmp eax, 0
    jl socket_error

    mov [SOCKET_DESCRIPTOR], eax ; Save socket descriptor

    ; Bind socket
    mov eax, 49                ; System call number for bind()
    mov ebx, [SOCKET_DESCRIPTOR]
    mov ecx, server_addr       ; Address of sockaddr_in struct
    mov edx, 16                ; Size of sockaddr_in struct
    int 0x80                   ; Invoke system call

    ; Check for error
    cmp eax, 0
    jl bind_error

    ; Listen for incoming connections
    mov eax, 50                ; System call number for listen()
    mov ebx, [SOCKET_DESCRIPTOR]
    mov ecx, 5                 ; Backlog queue size
    int 0x80                   ; Invoke system call

    ; Check for error
    cmp eax, 0
    jl listen_error

accept_loop:
    ; Accept incoming connection
    mov eax, 43                ; System call number for accept()
    mov ebx, [SOCKET_DESCRIPTOR]
    mov ecx, client_addr       ; Address of sockaddr_in struct
    mov edx, client_addr_size  ; Size of sockaddr_in struct
    int 0x80                   ; Invoke system call

    ; Check for error
    cmp eax, 0
    jl accept_error

    ; Save client socket descriptor
    mov [client_sock], eax

    ; Receive HTTP request from client
    mov eax, 45                ; System call number for recv()
    mov ebx, [client_sock]
    mov ecx, request           ; Address of buffer
    mov edx, 1024              ; Size of buffer
    int 0x80                   ; Invoke system call

    ; Check for error
    cmp eax, 0
    jl recv_error

    ; Send HTTP response to client
    mov eax, 44                ; System call number for send()
    mov ebx, [client_sock]
    mov ecx, response          ; Address of buffer
    mov edx, strlen(response)  ; Length of buffer
    int 0x80                   ; Invoke system call

    ;
