#ifndef __CONSTANTS__
#define __CONSTANTS__
#include <time.h>
#define MAX_X 100
#define MAX_Y 100
#define MAX_LINE_LENGTH 50
#define MAX_WORD_LENGTH 50
#define MAX_FOOD 30
#define MAX_ANTS 1000

typedef struct {
    float x;
    float y;
    float direction;//in degrees (0-364)
    int speed;//from 1 to 10
    float pheromone;//
    int food[MAX_FOOD][2];//for discovered food with their distance from the ant
    int found;//will increment 1 if the ant found a food
    int antID;
}Ant;

typedef struct {
    int antID;
    int position;
} Queue;

typedef struct {
    float x;
    float y;
    float size;//quantity is different from each piece will decrease when each ant eats a portion from it
    Queue queue;
} Food;


int antNum;//ant numbers
int foodTime;//amount of time for food pieces to generate (in seconds)
int foodDist;//distance between ant and food
int pheromoneDist;//distance for the effect of pheromon
int quantity;//quantity of pheromon that depends on the distance between the ant and the food
int foodPortionInPercent;//portion in % for ants to eat from the food piece
int endTimeInMinutes;//in minutes, time for simulation to end

int foodNum=0;//number of food pieces which are generated
int antId=0;//for ant id

time_t start_time;
#endif
