//Все остальные дефайны лежат по пути /code/_DEFINES/hud.dm

/*
	Координаты

	WEST + х: 6 + (x * 2)
	х - сколько квадратов от левого края экрана. То есть, если нужно сделать квадрат над ушами (3 ряд) - нужно писать WEST+2:10

	Так же работает с SOUTH
	SOUTH + x: 6 + (x * 2)
	x - количество квадратов от нижнего края экрана. Квадрат выше очков, например, будет SOUTH+4:12


*/

#define ui_sub_inventory "WEST:6,SOUTH+3:11"
#define ui_boxers "WEST:6,SOUTH+4:13"
#define ui_socks "WEST:6,SOUTH+5:15"
#define ui_shirt "WEST:6,SOUTH+6:17"
#define ui_bra "WEST+1:8,SOUTH+5:15"
#define ui_ears_extra "WEST+2:10,SOUTH+4:13"
#define ui_wrists "WEST+1:8,SOUTH+4:13"
