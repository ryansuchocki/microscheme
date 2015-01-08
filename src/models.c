#include <stdbool.h>

#include "models.h"

// typedef struct model_info { 
// 	char *name;

// 	char *STR_TARGET;
// 	char *STR_PROG;
// 	char *STR_BAUD;

// 	char *specific_asm;
// } model_info;

model_info models[] = {
	{
		"MEGA",

		"atmega2560",
		"wiring",
		"115200",

		false,

		".EQU	PORT13,	0x05	\n"
		".EQU	DDR13,	0x04	\n"
		".EQU	P13,	7		\n"
	},
	{
		"UNO",

		"atmega328p",
		"arduino",
		"115200",

		false,

		".EQU	PORT13,	0x05	\n"
		".EQU	DDR13,	0x04	\n"
		".EQU	P13,	5		\n"
	},
	{
		"LEO",

		"atmega32u4",
		"avr109",
		"57600",

		true,

		".EQU	PORT13,	0x08	\n"
		".EQU	DDR13,	0x07	\n"
		".EQU	P13,	7		\n"
	}
};

int numModels = sizeof(models) / sizeof(model_info);
