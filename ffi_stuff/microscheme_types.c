#include <stdbool.h>

struct vector;
struct pair;
struct closure;

typedef unsigned int ms_value;

typedef struct pair {
	ms_value car;
	ms_value cdr;
} pair;

typedef struct vector {
    unsigned int length;
    ms_value data[];
} vector;

typedef struct closure {
	unsigned char arity;
	unsigned int entry;
	struct closure *chain;
	ms_value cells[];
} closure;

pair *asPair (ms_value x) {
	return (pair*) (unsigned int) (x & 0b0001111111111111);
}

vector *asVector (ms_value x) {
	return (vector*) (unsigned int) (x & 0b0001111111111111);
}

closure *asClosure (ms_value x) {
	return (closure*) (unsigned int) (x & 0b0001111111111111);
}

unsigned char asChar (ms_value x) {
	return x & 0x00FF;
}

bool asBool (ms_value x) {
	return (x >> 8) & 0b00000001;
}

bool isNull (ms_value x) {
	return ((x >> 8) & 0b11111000) == 0b11101000;
}

ms_value ms_null  = 0b1110100000000000;
ms_value ms_true  = 0b1111100100000000;
ms_value ms_false = 0b1111100000000000;

ms_value toChar (unsigned char x) {
	return 0b1110000000000000 | x;
}

ms_value toPair (pair *x) {
	return 0b1000000000000000 | (0b0001111111111111 & ((unsigned int) x));
}

ms_value toVector (vector *x) {
	return 0b1010000000000000 | (0b0001111111111111 & ((unsigned int) x));
}

ms_value toClosure (closure *x) {
	return 0b1100000000000000 | (0b0001111111111111 & ((unsigned int) x));
}