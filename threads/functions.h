#include "header.h"
#include "CONSTANT.h"

void readInputFile(){
    char line[MAX_LINE_LENGTH];
    char array[10][MAX_WORD_LENGTH];
    int lineNum=0;
    FILE* file=fopen("input.txt","r");
    if(file==NULL){
        printf("Input File not found\n");
        exit(0);
    }
    while(fgets(line,sizeof(line),file)!=NULL){
        char *word=strtok(line,"\n");
        strcpy(array[lineNum],word);
        word=strtok(NULL,"\n");
        lineNum++;
    }
    fclose(file);
    for(int i=0;i<lineNum;i++){
        char temp[10000];
        strcpy(temp,array[i]);
        char *word=strtok(temp," \t");
        if(strcmp(word,"antNum")==0){
                word=strtok(NULL," \t");
                if(word!=NULL){
                    antNum=atoi(word);
                }
            }else if(strcmp(word,"foodTime")==0){
                word=strtok(NULL," \t");
                if(word!=NULL){
                    foodTime=atoi(word);
                }
            }else if(strcmp(word,"foodDist")==0){
                word=strtok(NULL," \t");
                if(word!=NULL){
                    foodDist=atoi(word);
                }
            }else if(strcmp(word,"pheromoneDist")==0){
                word=strtok(NULL," \t");
                if(word!=NULL){
                    pheromoneDist=atoi(word);
                }
            }else if(strcmp(word,"quantity")==0){
                word=strtok(NULL," \t");
                if(word!=NULL){
                    quantity=atoi(word);
                }
            }else if(strcmp(word,"foodPortionInPercent")==0){
                word=strtok(NULL," \t");
                if(word!=NULL){
                    foodPortionInPercent=atoi(word);
                }
            }else if(strcmp(word,"endTimeInMinutes")==0){
                word=strtok(NULL," \t");
                if(word!=NULL){
                    endTimeInMinutes=atoi(word);
                }
            }
    }
}
