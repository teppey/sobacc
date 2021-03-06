#!/bin/bash

assert() {
    expected="$1"
    input="$2"

    ./sobacc "$input" > tmp.s
    cc -o tmp tmp.s
    ./tmp
    actual="$?"

    if [ "$actual" = "$expected" ]; then
        echo "$input => $actual"
    else
        echo "$input => $expected expected, but got $actual"
        exit 1
    fi
}

assert_static() {
    expected="$1"
    input="$2"

    ./sobacc "$input" > tmp.s
    cc -o tmp -static tmp.s
    ./tmp
    actual="$?"

    if [ "$actual" = "$expected" ]; then
        echo "$input => $actual"
    else
        echo "$input => $expected expected, but got $actual"
        exit 1
    fi
}

assert_func() {
    file="$1"
    expected="$2"
    input="$3"

    cc -o "$file.o" -c "$file"
    ./sobacc "$input" > tmp.s
    cc -o tmp tmp.s "$file.o"
    actual="$(./tmp)"

    if [ "$actual" = "$expected" ]; then
        echo "$input => $actual"
    else
        echo "$input => $expected expected, but got $actual"
        exit 1
    fi
}

assert_func_return() {
    file="$1"
    expected="$2"
    input="$3"

    cc -o "$file.o" -c "$file"
    ./sobacc "$input" > tmp.s
    cc -o tmp tmp.s "$file.o"
    ./tmp
    actual="$?"

    if [ "$actual" = "$expected" ]; then
        echo "$input => $actual"
    else
        echo "$input => $expected expected, but got $actual"
        exit 1
    fi
}

assert_output() {
    expected="$1"
    input="$2"

    ./sobacc "$input" > tmp.s
    cc -o tmp -static tmp.s
    actual=$(./tmp)

    if [ "$actual" = "$expected" ]; then
        echo "$input => $actual"
    else
        echo "$input => $expected expected, but got $actual"
        exit 1
    fi
}

assert 0 'int main() { return 0; }'
assert 42 'int main() { return 42; }'
assert 21 'int main() { return 5+20-4; }'
assert 41 'int main() { return 12 + 34 - 5; }'
assert 47 'int main() { return 5+6*7; }'
assert 15 'int main() { return 5*(9-6); }'
assert 4 'int main() { return (3+5)/2; }'
assert 10 'int main() { return -10+20; }'
assert 8 'int main() { return -(3+5)*-1; }'
assert 9 'int main() { return +10+-1; }'
assert 0 'int main() { return 1==0; }'
assert 1 'int main() { return 0==0; }'
assert 1 'int main() { return 1==1; }'
assert 0 'int main() { return 1!=1; }'
assert 1 'int main() { return 1!=0; }'
assert 1 'int main() { return 3<5; }'
assert 0 'int main() { return 5<3; }'
assert 1 'int main() { return 3<=5; }'
assert 0 'int main() { return 5<=3; }'
assert 1 'int main() { return 5<=5; }'
assert 1 'int main() { return 4>2; }'
assert 0 'int main() { return 2>4; }'
assert 1 'int main() { return 2<=4; }'
assert 0 'int main() { return 4<=2; }'
assert 1 'int main() { return 4<=4; }'
assert 0 'int main() { return 1+2==3-4; }'
assert 1 'int main() { return (1>2)+(2<3); }'
assert 3 'int main() { int a; return a = 3; }'
assert 22 'int main() { int b; return b = 5 * 6 - 8; }'
assert 14 'int main() { int a; int b; a = 3; b = 5 * 6 - 8; return a + b / 2; }'
assert 1 'int main() { int foo; return foo = 1; }'
assert 5 'int main() { int bar; return bar = 2 + 3; }'
assert 10 'int main() { int foo; int bar; foo = 2; bar = 2 + 3; return foo * bar; }'
assert 0 'int main() { return 1 == 0; }'
assert 1 'int main() { return 1+1 == 2; }'
assert 5 'int main() { return 5; return 8; }'
assert 14 'int main() { int a; int b; a = 3; b = 5 * 6 - 8; return a + b / 2; }'
assert 1 'int main() { if (3 == 3) return 1; }'
assert 2 'int main() { if (3 == 4) return 1; else return 2; }'
assert 0 'int main() { int a; a = 0; while (a > 1) a = a + 1; return a; }'
assert 3 'int main() { int a; a = 0; while (a < 3) a = a + 1; return a; }'
assert 20 'int main() { int a; a = 0; while (a < 3) if (a == 2) a = a * 10; else a = a + 1; return a; }'
assert 1 'int main() { for (;;) return 1; }'
assert 1 'int main() { int a; for (a = 1;;) return a; }'
assert 2 'int main() { for (;0;) return 1; return 2; }'
assert 7 'int main() { int i; for (i = 0; i < 7; i = i + 1) 0; return i; }'
assert 11 'int main() { int a; a = 0; for (;; a = a + 1) if (a > 10) return a; }'
assert 4 'int main() { int a; int i; int j; a = 0; for (i = 0; i < 2; i = i + 1) for (j = 0; j < 2; j = j + 1) a = a + 1; return a; }'
assert 1 'int main() { { return 1; } }'
assert 2 'int main() { { int a; a = 1; return a + 1; } }'
assert 5 'int main() { int a; int b; a = 2; b = 3; if (a > 0) { a = a * a; b = a + 1; } return b; }'
assert 20 'int main() { int a; int b; a = b = 0; while (a < 10) { b = b + 1; a = a + 1; } return a + b; }'
assert 1 'int main() { {} return 1; }'
assert 8 'int fib(int n) { if (n <= 2) return 1; return fib(n - 2) + fib(n - 1); } int main() { return fib(6); }'
assert 3 'int main() { int x; int y; x = 3; y = &x; return *y; }'
assert 3 'int main() { int x; int y; int z; x = 3; y = &x; z = &y; return **z; }'
assert 3 'int main() { int x; int y; int z; x = 3; y = 5; z = &y + 8; return *z; }'
assert 15 'int foo(int x, int y) { return x * y; } int main() { return foo(3, 5); }'
assert 3 'int main() { int x; int *y; y = &x; *y = 3; return x; }'
assert 4 'int main() { int x; return sizeof(x); }'
assert 4 'int main() { int x; return sizeof(x + 3); }'
assert 8 'int main() { int *y; return sizeof(y); }'
assert 8 'int main() { int *y; return sizeof(y + 3); }'
assert 4 'int main() { int *y; return sizeof(*y); }'
assert 4 'int main() { return sizeof(1); }'
assert 4 'int main() { return sizeof(sizeof(1)); }'
assert 1 'int main() { int a[10]; return 1; }'
assert 3 'int main() { int a[2]; *a = 1; *(a + 1) = 2; int *p; p = a; return *p + *(p + 1); }'
assert 4 'int main() { int a[2]; a[0] = 1; a[1] = 3; return a[0] + a[1]; }'
assert 1 'int main() { int a[1]; a[0] = 1; return 0[a]; }'

# グローバル変数
assert 0 'int a; int main() { return a; }'
assert 1 'int a; int main() { a = 1; return a; }'
assert 0 'int a[4]; int main() { a[0] = 0; a[1] = 1; a[2] = 2; a[3] = 3; return a[0]; }'
assert 1 'int a[4]; int main() { a[0] = 0; a[1] = 1; a[2] = 2; a[3] = 3; return a[1]; }'
assert 2 'int a[4]; int main() { a[0] = 0; a[1] = 1; a[2] = 2; a[3] = 3; return a[2]; }'
assert 3 'int a[4]; int main() { a[0] = 0; a[1] = 1; a[2] = 2; a[3] = 3; return a[3]; }'
assert 4 'int a; int main() { return sizeof(a); }'
assert 32 'int a[4]; int main() { return sizeof(a); }'
assert 2 'int a; int main() { a = 1; int a; a = 2; return a; }'

# 文字型
assert 3 'int main() { char x[3]; x[0] = -1; x[1] = 2; int y; y = 4; return x[0] + y; }'
assert 3 'char x[3]; int y; int main() { x[0] = -1; x[1] = 2; y = 4; return x[0] + y; }'

# 文字列リテラル
assert_static 1 'int main() { char *s; s = "foo"; return 1; }'
assert_static 97 'int main() { char *s; s = "abc"; return s[0]; }'
assert_output hello 'int main() { char *s; s = "hello"; printf("%s", s); return 0; }'

assert_func ./testfunc/foo.c "OK" 'int main() { foo(); }'
assert_func ./testfunc/foo1.c "3" 'int main() { foo(3); }'
assert_func ./testfunc/foo2.c "7" 'int main() { foo(3, 4); }'
assert_func ./testfunc/foo3.c "12" 'int main() { foo(3, 4, 5); }'
assert_func ./testfunc/foo4.c "18" 'int main() { foo(3, 4, 5, 6); }'
assert_func ./testfunc/foo5.c "25" 'int main() { foo(3, 4, 5, 6, 7); }'
assert_func ./testfunc/foo6.c "33" 'int main() { foo(3, 4, 5, 6, 7, 8); }'

# TODO: intのサイズを8->4に変更したらコメントアウトを解除
#assert_func_return ./testfunc/alloc4.c "1" 'int main() { int *p; alloc4(&p, 1, 2, 4, 8); int *q; q = p + 0; return *q; }'
#assert_func_return ./testfunc/alloc4.c "2" 'int main() { int *p; alloc4(&p, 1, 2, 4, 8); int *q; q = p + 1; return *q; }'
#assert_func_return ./testfunc/alloc4.c "4" 'int main() { int *p; alloc4(&p, 1, 2, 4, 8); int *q; q = p + 2; return *q; }'
#assert_func_return ./testfunc/alloc4.c "8" 'int main() { int *p; alloc4(&p, 1, 2, 4, 8); int *q; q = p + 3; return *q; }'
#
#assert_func_return ./testfunc/alloc4.c "1" 'int main() { int *p; alloc4(&p, 1, 2, 4, 8); int *q; q = 0 + p; return *q; }'
#assert_func_return ./testfunc/alloc4.c "2" 'int main() { int *p; alloc4(&p, 1, 2, 4, 8); int *q; q = 1 + p; return *q; }'
#assert_func_return ./testfunc/alloc4.c "4" 'int main() { int *p; alloc4(&p, 1, 2, 4, 8); int *q; q = 2 + p; return *q; }'
#assert_func_return ./testfunc/alloc4.c "8" 'int main() { int *p; alloc4(&p, 1, 2, 4, 8); int *q; q = 3 + p; return *q; }'
#
#assert_func_return ./testfunc/alloc4.c "1" 'int main() { int *p; alloc4(&p, 1, 2, 4, 8); int *q; q = 0 + 0 + p; return *q; }'
#assert_func_return ./testfunc/alloc4.c "1" 'int main() { int *p; alloc4(&p, 1, 2, 4, 8); int *q; q = 0 + p + 0; return *q; }'
#assert_func_return ./testfunc/alloc4.c "2" 'int main() { int *p; alloc4(&p, 1, 2, 4, 8); int *q; q = 0 + p + 1; return *q; }'
#assert_func_return ./testfunc/alloc4.c "4" 'int main() { int *p; alloc4(&p, 1, 2, 4, 8); int *q; q = p + 3 - 1; return *q; }'

echo OK
