#include <stdio.h>
#include <stdlib.h>

extern int wyszukaj_znak(wchar_t tablica[], unsigned int* znak);
extern int* tablica_np(int tablica[], unsigned int* n);
extern int np(int tablica[], unsigned int* n);
extern int* to_i(char* tab);
extern long long int dwa(wchar_t* jeden, wchar_t* dwa);

int main() {
	//wchar_t utf16[] = L"Hello, 世世世界!";
	//unsigned int* znak = L'世';
	//unsigned int* wsk = &znak;
	//int ile = wyszukaj_znak(utf16, wsk);
	//printf("\n%d\t%x\t%x", ile, *wsk, &utf16[7]);

	//int tab[] = { 1, 2, 3, 4, 5, 6, 7 };
	//unsigned int n = 7;
	//int* wsk = &n;
	//int* tab2 = np(tab, wsk);
	//printf("\n%d\t%d", tab2[2], tab2[3]);
	//printf("\n%d", *wsk);
	//free(tab2);

	//char tab[255] = "122 34 56 365 1532";
	//int *tab2 = to_i(tab);
	//printf("\n%d\t%d\t%d\t%d\t%d", tab2[0], tab2[1], tab2[2], tab2[3], tab2[4]);

	wchar_t* j = L"4294967297";
	wchar_t* d = L"4294967296";
	dwa(j, d);
	return 0;
}
