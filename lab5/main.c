#include <stdio.h>
#include <xmmintrin.h>
#include <stdint.h>

// instrukcja
float srednia_harm(float* tablica, unsigned int n);
float nowy_exp(float x);
void suma_rownolegla16x8bit(char* liczby_A, char* liczby_B);
void int2float(int* calkowite, float* zmienno_przec);
void pm_jeden(float* tabl);
void dodawanie_SSE(float* a);
// lab 2020
float obj_stozka(unsigned int big_r, unsigned int small_r, float h);
void szybki_max(int t1[], int t2[], int wynik[], int n);
void tangensy(float tan[]);
void wyznacz_max(float tab[], int prog);
float find_max_range(float v0, float alpha);
__m128 mul_at_once(__m128 a, __m128);
float oblicz_potege(unsigned char k, int m);
void dziel(__m128 tab128[], int n, float dzielnik);
// lab 2023
float* single_neuron(double* input, float* weights, unsigned int n);
float progowanie_sredniej_kroczacej(float* tab, unsigned int k, unsigned int m);
typedef struct {
	
	uint32_t calkowita;
	uint16_t ulamkowa;
} UINT48;
float uint48float(UINT48 p);


int main()
{
	// 5.1
	float tab[5] = { 1.0, 2.0, 3.0, 4.0, 5.0 };
	float a = srednia_harm(tab, 5);
	printf("%f\n", a);


	// 5.2
	float b = nowy_exp(2.0);
	printf("%f\n", b);

	float c = 0;
	float l = 2.0;
	int silnia = 1;
	for (int i = 1; i <= 20; i++)
	{
		l = 2.0;
		for (int j = 1; j <= i; j++)
			l *= 2.0;
		silnia *= i;
		c += l / silnia;
	}
	printf("%f\n", c);

	// 5.3
	char liczby_A[16] = { -128, -127, -126, -125, -124, -123, -122, -121, 120, 121, 122, 123, 124, 125, 126, 127 };
	char liczby_B[16] = { -3, -3, -3, -3, -3, -3, -3, -3, 3, 3, 3, 3, 3, 3, 3, 3 };
	suma_rownolegla16x8bit(liczby_A, liczby_B);
	for (int i = 0; i < 16; i++)
	{
		printf("\t%d : ", liczby_A[i]);
		printf("%d\n", liczby_B[i]);
	}

	// 5.4
	int dwa[4] = { -150, 23, 1, -2};
	float r[4];
	// podany rozkaz zapisuje w pamięci od razu 128 bitów,
	// więc muszą być 4 elementy w tablicy
	int2float(dwa, r);
	printf("\nKonwersja = %f %f\n", r[0], r[1]);
	printf("\nKonwersja = %f %f\n", r[2], r[3]);

	// 5.5
	float tabl[4] = { 1.0, 2.0, 3.0, 4.0 };
	pm_jeden(tabl);
	printf("\nPlusMinus = %f %f %f %f\n", tabl[0], tabl[1], tabl[2], tabl[3]);

	// 5.6
	float wyniki[4];
	dodawanie_SSE(wyniki);
	printf("\nWyniki = %f %f %f %f\n", wyniki[0], wyniki[1], wyniki[2], wyniki[3]);

	/////////////////
	// Laby z 2020 //
	/////////////////

	printf("\nObjetosc stozka = %f\n", obj_stozka(6, 2, 5.3));
	printf("\nObjetosc stozka = %f\n", obj_stozka(7, 3, 4.2));
	printf("\nObjetosc stozka = %f\n", obj_stozka(8, 4, 6.1));

	//printf("\nSizeof int = %d\n", sizeof(int));
	int t1[8] = { 1, 2, 3, 42, 1, 1, 1, 1 };
	int t2[8] = { 10, -11, 12, -13, 2, 2, 2, 2 };
	int wynik[10];
	szybki_max(t1, t2, wynik, 8);
	printf("\nWynik = ");
	for (int i = 0; i < 8; i++)
		printf("%d ", wynik[i]);

	float tan[5];
	tangensy(tan);
	printf("\nTangensy = ");
	for (int i = 0; i < 5; i++)
		printf("%f ", tan[i]);

	float ff[4] = { 1.0, 2.0, 3.0, 4.0 };
	wyznacz_max(ff, 2);
	printf("\nMax prog = %f %f %f %f\n", ff[0], ff[1], ff[2], ff[3]);

	printf("\nMax range = %f\n", find_max_range(10.0, 45.0));

	__m128 a128;
	__m128 b128;
	a128.m128_i32[0] = 1;
	a128.m128_i32[1] = 2;
	a128.m128_i32[2] = 3;
	a128.m128_i32[3] = 4;

	b128.m128_i32[0] = 2;
	b128.m128_i32[1] = 2;
	b128.m128_i32[2] = 2;
	b128.m128_i32[3] = 2;

	__m128 c128 = mul_at_once(a128, b128);

	printf("\nPotega %f", oblicz_potege(24, -4));
	printf("\nPotega %f", oblicz_potege(24, -3));
	printf("\nPotega %f", oblicz_potege(24, -2));

	__m128 tab128[] = { (__m128) {1.0f, 2.0f, 3.0f, 4.0f }, 
						(__m128) {5.0f, 6.0f, 7.0f, 8.0f }, 
						(__m128) {9.0f, 10.0f, 11.0f, 12.0f }, 
						(__m128) {13.0f, 14.0f, 15.0f, 16.0f } };
	dziel(tab128, 4, 2.0f);

	/////////////////
	// Laby z 2023 //
	/////////////////

	double neuron_in[4] = { 1.0, 2.0, 3.0, 4.0 };
	float neuron_w[4] = { 1.0, 2.0, -3.0, -4.0 };
	float* neuron_out = single_neuron(neuron_in, neuron_w, 4);
	printf("\n\nWynik neuronu %f", *neuron_out);
	free(neuron_out);

	float stab[] = { 2.1, 1.2, 2.1, 1.2, 2.1, 1.2 };
	float srednia = progowanie_sredniej_kroczacej(stab, 6, 3);
	printf("\nSrednia = %f", srednia);

	UINT48 p;
	p.calkowita = 1;
	p.ulamkowa = 1;
	float wf = uint48float(p);
printf("\nFloat = %f", wf);

	return 0;
}
