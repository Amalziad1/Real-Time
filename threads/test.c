
#include "CONSTANT.h"
#include "header.h"
#include "functions.h"

void readInputFile();

pthread_mutex_t mutex;

Food foods[MAX_FOOD];
Ant ants[MAX_ANTS];


void compareDistance() {
    for(int o=0;o<=foodNum;o++){
        int foodNumber=o;
        Food food=foods[o];
        float foodX=food.x;
        float foodY=food.y;
        pthread_mutex_lock(&mutex);
        //update pheromone levels based on distance to food
        for (int i = 0; i < antNum; i++) {
            float distance = sqrt(pow(foodX - ants[i].x, 2) + pow(foodY - ants[i].y, 2));
            if(distance >0 && distance<=foodDist){//distance 
                if(ants[i].found==0){
                    ants[i].pheromone += 1 / distance; // Indirectly proportional to the distance
                    ants[i].direction=atan2(foodY - ants[i].y, foodX - ants[i].x) * (180.0 / M_PI);
                    ants[i].food[ants[i].found][0]=foodNumber;
                    ants[i].food[ants[i].found][1]=distance;
                    ants[i].found+=1;
                }else{
                    int minDistance=1000;
                    int foodPlace;//food index
                    for(int j=0;j<ants[i].found;j++){
                        if(ants[i].food[j][1]<minDistance){
                            minDistance=ants[i].food[j][1];
                            foodPlace=ants[i].food[j][0];
                        }
                    }
                    if(foodPlace==foodNumber){
                        ants[i].pheromone += 1 / distance; // Indirectly proportional to the distance
                        ants[i].direction=atan2(foodY - ants[i].y, foodX - ants[i].x) * (180.0 / M_PI);
                        ants[i].food[ants[i].found][0]=foodNumber;
                        ants[i].food[ants[i].found][1]=distance;
                        ants[i].found+=1;
                    }else{
                        //won't change its direction if the distance is not the min from found pieces
                    }
                }
            }else if(distance ==0){
                //arrived
                ants[i].pheromone=1000;//assuming
                ants[i].speed=0;//ant stopped
                //======================bara
            }
        }
        pthread_mutex_unlock(&mutex);
    }
}

void* foodPlacement(void* arg) {
    while (1) {
        srand(time(NULL));
        Food * food=(Food*)arg;
        pthread_mutex_lock(&mutex);
        // Place food at a random position
        float foodX = (float)rand() / RAND_MAX * MAX_X;
        float foodY = (float)rand() / RAND_MAX * MAX_Y;
        
        food->x=foodX;
        food->y=foodY;
        
        food->size=(rand()%20)+1;//the size of the piece of food is between 1 and 20
        
        
        foods[foodNum].x=food->x;
        foods[foodNum].y=food->y;
        foods[foodNum].size=food->size;
        
        
        sleep(foodTime);
        
        foodNum++;
        
        // Check if the simulation duration has exceeded
        time_t current_time = time(NULL);
        if (current_time - start_time >= (endTimeInMinutes*60)) {//*60 to make it in seconds 
            break;
        }
    }

    pthread_exit(NULL);
}
void initializeAnts(){
    for(int i=0;i<antNum;i++){
        // Initially generate random direction
        srand(time(NULL));
        ants[i].direction = rand() % 8;
        if(ants[i].direction==0){
            ants[i].direction=0;//east
        }else if(ants[i].direction==1){
            ants[i].direction=45;//northEast
        }else if(ants[i].direction==2){
            ants[i].direction=90;//north
        }else if(ants[i].direction==3){
            ants[i].direction=135;//northWest
        }else if(ants[i].direction==4){
            ants[i].direction=180;//west
        }else if(ants[i].direction==5){
            ants[i].direction=225;//southWest
        }else if(ants[i].direction==6){
            ants[i].direction=270;//south
        }else if(ants[i].direction==7){
            ants[i].direction=315;//southEast
        }
        // Generate random speed for each ant
       ants[i].speed=rand()%10;
       ants[i].speed=ants[i].speed + 1; // to avoid 0
       
       // Initially generate random position
       ants[i].x=(float)rand() / RAND_MAX * MAX_X;
       ants[i].y=(float)rand() / RAND_MAX * MAX_Y;
       
       // Initially make pheromone and found=0
       ants[i].pheromone=0;
       ants[i].found=0;
       
       //ant ID
       ants[i].antID=antId;
       antId++;
    }
}
void* antMovement(void* arg) {
    Ant* ant = (Ant*)arg;
    
    while(1){
        compareDistance();//continuously compare distance with food pieces
        // Move the ant in the current direction with the current speed
        float dx = cos(ant->direction * M_PI / 180) * ant->speed;
        float dy = sin(ant->direction * M_PI / 180) * ant->speed;
        ant->x += dx;
        ant->y += dy;
        //check if the ant reaches the borders
        if(ant->x==MAX_X || ant->y==MAX_Y || ant->x==0 || ant->y==0){//borders
            int dir=rand()%2;
            if(dir==0){//CCW
                ant->direction=ant->direction+45;
                if(ant->direction>=360){
                    ant->direction=360-ant->direction;
                }
            }else{//CW
                ant->direction=ant->direction-45;
                if(ant->direction>=-1){
                    ant->direction=360+ant->direction;
                }
            }
        }
        
        pthread_mutex_lock(&mutex);
        for (int i = 0; i < antNum; i++) {
            if (i != ant - ants) {//to not compare with the same ant
                float distance = sqrt(pow(ant->x - ants[i].x, 2) + pow(ant->y - ants[i].y, 2));
                if (distance <= pheromoneDist && ants[i].pheromone >= (quantity*2)) {
                    //means that the pheromone is high
                    // Change the direction towards the food
                    ant->direction = atan2(ants[i].y - ant->y, ants[i].x - ant->x) * 180 / M_PI;
                    ant->pheromone = ants[i].pheromone/2;//will make lesser pheromone (the half)
                    break;
                }else if(distance <=pheromoneDist && ants[i].pheromone>=quantity && ants[i].pheromone<(quantity*2)){
                //means that the pheromone is not that strong but under the pheromone threshold of the user
                //then will change direction only by 5 degrees towards the ant that is going to the food
                    ant->direction= (atan2(ants[i].y - ant->y, ants[i].x - ant->x) * 180 / M_PI)+5;
                }//else won't change its direction
            }
        }
        pthread_mutex_unlock(&mutex);
        
        // Check if the simulation duration has exceeded
        time_t current_time = time(NULL);
        if (current_time - start_time >= (endTimeInMinutes*60)) {//*60 to make it in seconds 
            break;
        }
    }

    pthread_exit(NULL);
}

int main(){
    readInputFile();//getting user-defined variables
    
    initializeAnts(ants);
    
    start_time = time(NULL); // Start the timer
    
    pthread_t antThreads[antNum];
    pthread_t foodThread;
    pthread_mutex_init(&mutex, NULL);
    for (int i = 0; i < antNum; i++) {
        if(pthread_create(&antThreads[i], NULL, antMovement, (void*)&ants[i])!=0){
            perror("Failed to create an ant thread thread");
        }
    }
    if(pthread_create(&foodThread, NULL, foodPlacement, NULL)!=0){
        perror("Failed to create an ant thread thread");
    }
    /*
    //wait for ant threads to finish
    for (int i = 0; i < antNum; i++) {
        pthread_join(antThreads[i], NULL);
    }*/
    //wait for food thread to finish
    //pthread_join(foodThread,NULL);
    
    pthread_mutex_destroy(&mutex);
    printf("-------===\n");
    return 0;
}

