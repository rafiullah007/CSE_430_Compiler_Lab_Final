# CSE_430_Compiler_Lab_Final

A minimal mini-compiler/interpreter built with **Flex** and **Bison**.

## Supported syntax

- Variable declaration: `int x;`
- Assignment: `x = 2 + 3 * 4;`
- Print expression: `print(x);`
- Arithmetic: `+`, `-`, `*`, `/`, parentheses, unary minus

## Build

```bash
make
```

## Run

```bash
printf "int x;\nx = 10 + 5 * 2;\nprint(x);\n" | ./mini_compiler
```

Expected output:

```text
20
```

## Test

```bash
make test
```
