/**
 * @file This file is part of EDGE.
 *
 * @author Justin Zhang(justinazhang2000 AT yahoo.com)
 *
 * @section LICENSE
 * Copyright (c) 2018, Regents of the University of California
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * @section DESCRIPTION
 * Truncating bits of mantissa
 **/

#ifndef CROP_HPP
#define CROP_HPP
#include <stdlib.h>
#include <stdio.h>
<<<<<<< HEAD
=======
#include <math.h>
>>>>>>> 169ed5318f58c667c3b98007ac8a88494d27b694
typedef union {
	double f;
	struct
    {
		long mantissa : 52;
		unsigned int exponent : 11;
		unsigned int sign : 1;
	} field;
} myfloat;
static void crop(double * input) __attribute__((unused));
static void crop(double * input)
{
	int numbits = atoi(getenv("MANT"));
<<<<<<< HEAD
	myfloat var;
	var.f = *input;
	var.field.mantissa = (var.field.mantissa>>numbits)<<numbits;
	*input = var.f;
=======
	int k = 0;
	int counter = 1;
	double sum = 0;
	double newnum = 0;
	long newmantissa = 0;
	myfloat var;
	var.f = *input;
	newmantissa = var.field.mantissa>>numbits;
	newmantissa = newmantissa << numbits;
	for (int j = 51; j >= 0; j--)
	{
		k = newmantissa >> j;
		if (k & 1)
		{
			sum += pow(2, -(counter));
		}
		counter++;
	}
	
	newnum = pow((-1), var.field.sign) * pow(2, var.field.exponent - 1023) * (1 + sum);
	*input = newnum;
>>>>>>> 169ed5318f58c667c3b98007ac8a88494d27b694
}
#endif
