#include <stdio.h>

#define ROZMIAR 10

int przestaw(int* tab, int rozmiar);


int main()
{
	int tab[ROZMIAR] = { 100, 90, 80, 70, 60, 50, 40, 30, 20, 10 };
	int i;
	int j;
	for (i = 0; i < 10; i++)
	{
		printf("%d ", tab[i]);
	}
	printf("\n");
	
	for (i = ROZMIAR; i >= 2; i--)
	{
		przestaw(tab, i);
		for (j = 0; j < 10; j++)
		{
			printf("%d ", tab[j]);
		}
		printf("\n");
	}


	

	return 0;
}
