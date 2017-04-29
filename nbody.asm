        global  main
        extern  printf
        extern  atoi

        section .text

%define BODY_SIZE 7
%define X 0
%define Y 1
%define Z 2
%define VX 3
%define VY 4
%define VZ 5
%define MASS 6

section .data
        half dq 0.5
        delta_time dq 0.01
        solar_mass dq 39.47841760435743
        bodies_length dq 5
        ; x, y, z, vx, vy, vz, mass
        bodies dq 0.0,                 0.0,                 0.0,                  0.0,                0.0,                 0.0,                  39.47841760435743,     \
                  4.841431442464721,  -1.1603200440274284, -0.10362204447112311,  0.606326392995832,  2.81198684491626,   -0.02521836165988763,  0.03769367487038949,   \
                  8.34336671824458,    4.124798564124305,  -0.4035234171143214,  -1.0107743461787924, 1.8256623712304119,  0.008415761376584154, 0.011286326131968767,  \
                  12.894369562139131, -15.111151401698631, -0.22330757889265573,  1.0827910064415354, 0.8687130181696082, -0.010832637401363636, 0.0017237240570597112, \
                  15.379697114850917, -25.919314609987964,  0.17925877295037118,  0.979090732243898,  0.5946989986476762, -0.034755955504078104, 0.0020336868699246304


offset_momentum:
        mov     r8, rdi
        movsd   xmm4, [rdi + VX*8]
        movsd   xmm5, [rdi + VY*8]
        movsd   xmm6, [rdi + VZ*8]
        movsd   xmm3, [solar_mass]
.next_body:
        movsd   xmm0, [r8 + VX*8]
        mulsd   xmm0, [r8 + MASS*8]
        divsd   xmm0, xmm3
        subsd   xmm4, xmm0

        movsd   xmm1, [r8 + VY*8]
        mulsd   xmm1, [r8 + MASS*8]
        divsd   xmm1, xmm3
        subsd   xmm5, xmm1

        movsd   xmm2, [r8 + VZ*8]
        mulsd   xmm2, [r8 + MASS*8]
        divsd   xmm2, xmm3
        subsd   xmm6, xmm2

        add     r8, BODY_SIZE*8
        dec     rsi
        jnz     .next_body

        movsd   [rdi + VX*8], xmm4
        movsd   [rdi + VY*8], xmm5
        movsd   [rdi + VZ*8], xmm6

        ret


bodies_energy:
        xorpd   xmm0, xmm0
.next_body:
        movsd   xmm1, [rdi + VX*8]
        mulsd   xmm1, xmm1

        movsd   xmm2, [rdi + VY*8]
        mulsd   xmm2, xmm2
        addsd   xmm1, xmm2

        movsd   xmm3, [rdi + VZ*8]
        mulsd   xmm3, xmm3
        addsd   xmm1, xmm3

        mulsd   xmm1, [half]
        mulsd   xmm1, [rdi + MASS*8]
        addsd   xmm0, xmm1

        mov     r10, rdi
        add     r10, BODY_SIZE*8
        mov     r11, rsi
        dec     r11
        jz      .end
.next:
        movsd   xmm1, [rdi + X*8]
        subsd   xmm1, [r10 + X*8]
        mulsd   xmm1, xmm1

        movsd   xmm2, [rdi + Y*8]
        subsd   xmm2, [r10 + Y*8]
        mulsd   xmm2, xmm2
        addsd   xmm1, xmm2

        movsd   xmm3, [rdi + Z*8]
        subsd   xmm3, [r10 + Z*8]
        mulsd   xmm3, xmm3
        addsd   xmm1, xmm3

        sqrtsd  xmm1, xmm1

        movsd   xmm2, [rdi + MASS*8]
        mulsd   xmm2, [r10 + MASS*8]

        divsd   xmm2, xmm1
        subsd   xmm0, xmm2

        add     r10, BODY_SIZE*8
        dec     r11
        jnz     .next

        add     rdi, BODY_SIZE*8
        dec     rsi
        jnz     .next_body
.end:
        ret


bodies_advance:
        mov     r14, rdi
        mov     r15, rsi
.next_body:
        mov     r10, rdi
        add     r10, BODY_SIZE*8
        mov     r11, rsi
        dec     r11
        jz      .calc_velocity
.next:
        movsd   xmm1, [rdi + X*8]
        subsd   xmm1, [r10 + X*8]

        movsd   xmm2, [rdi + Y*8]
        subsd   xmm2, [r10 + Y*8]

        movsd   xmm3, [rdi + Z*8]
        subsd   xmm3, [r10 + Z*8]

        movsd   xmm4, xmm1
        mulsd   xmm4, xmm4

        movsd   xmm5, xmm2
        mulsd   xmm5, xmm5

        movsd   xmm6, xmm3
        mulsd   xmm6, xmm6

        addsd   xmm4, xmm5
        addsd   xmm4, xmm6

        sqrtsd  xmm5, xmm4

        mulsd   xmm4, xmm5
        movsd   xmm5, xmm0

        divsd   xmm5, xmm4

        movsd   xmm6, [r10 + MASS*8]
        mulsd   xmm6, xmm5

        movsd   xmm7, xmm1
        mulsd   xmm7, xmm6
        movsd   xmm8, [rdi + VX*8]
        subsd   xmm8, xmm7
        movsd   [rdi + VX*8], xmm8

        movsd   xmm7, xmm2
        mulsd   xmm7, xmm6
        movsd   xmm8, [rdi + VY*8]
        subsd   xmm8, xmm7
        movsd   [rdi + VY*8], xmm8

        movsd   xmm7, xmm3
        mulsd   xmm7, xmm6
        movsd   xmm8, [rdi + VZ*8]
        subsd   xmm8, xmm7
        movsd   [rdi + VZ*8], xmm8

        movsd   xmm6, [rdi + MASS*8]
        mulsd   xmm6, xmm5

        movsd   xmm7, xmm1
        mulsd   xmm7, xmm6
        movsd   xmm8, [r10 + VX*8]
        addsd   xmm8, xmm7
        movsd   [r10 + VX*8], xmm8

        movsd   xmm7, xmm2
        mulsd   xmm7, xmm6
        movsd   xmm8, [r10 + VY*8]
        addsd   xmm8, xmm7
        movsd   [r10 + VY*8], xmm8

        movsd   xmm7, xmm3
        mulsd   xmm7, xmm6
        movsd   xmm8, [r10 + VZ*8]
        addsd   xmm8, xmm7
        movsd   [r10 + VZ*8], xmm8

        add     r10, BODY_SIZE*8
        dec     r11
        jnz     .next

        add     rdi, BODY_SIZE*8
        dec     rsi
        jnz     .next_body
.calc_velocity:
        movsd   xmm1, [r14 + X*8]
        movsd   xmm2, [r14 + VX*8]
        mulsd   xmm2, xmm0
        addsd   xmm1, xmm2
        movsd   [r14 + X*8], xmm1

        movsd   xmm1, [r14 + Y*8]
        movsd   xmm2, [r14 + VY*8]
        mulsd   xmm2, xmm0
        addsd   xmm1, xmm2
        movsd   [r14 + Y*8], xmm1

        movsd   xmm1, [r14 + Z*8]
        movsd   xmm2, [r14 + VZ*8]
        mulsd   xmm2, xmm0
        addsd   xmm1, xmm2
        movsd   [r14 + Z*8], xmm1

        add     r14, BODY_SIZE*8
        dec     r15
        jnz     .calc_velocity

        ret


main:
        mov     rdi, [rsi+8]            ; rdi = argv[1]
        call    atoi
        push    rax                     ; stack is now aligned

        mov     rdi, bodies
        mov     rsi, [bodies_length]
        call    offset_momentum

        mov     rdi, bodies
        mov     rsi, [bodies_length]
        call    bodies_energy

        mov     rdi, float_format
        mov     rax, 1
        call    printf

        pop     rax
        movsd   xmm0, [delta_time]
.advance:
        mov     rdi, bodies
        mov     rsi, [bodies_length]
        call    bodies_advance
        dec     rax
        jnz     .advance

        mov     rdi, bodies
        mov     rsi, [bodies_length]
        call    bodies_energy

        push    r14                     ; align stack

        mov     rdi, float_format
        mov     rax, 1
        call    printf

        pop     r14

        ret

float_format:
        db      "%.9f", 10, 0
