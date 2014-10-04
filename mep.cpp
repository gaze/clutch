
#include <stdio.h>
#include <stdlib.h>
#include <chrono>
#include <iostream>
#include <fstream>


#define M_A(i,j) a[1600*i + j]
#define M_B(i,j) b[1600*i + j]

void dump_mat(float *a, float *b, std::string fname){
    std::ofstream myfile;
    myfile.open(fname);
    for(int i = 0; i < 1600; i++){
        for(int j = 0; j < 1600; j++){
            myfile << M_A(i,j) << " ";
        }
        myfile << std::endl;
    }
    myfile.close();
}

int main(){


    __restrict float *a = (float *)malloc(sizeof(float)*1600*1600);
    __restrict float *b = (float *)malloc(sizeof(float)*1600*1600);


    for(int i = 0; i < 1600; i++){
        for(int j = 0; j < 1600; j++){
           if(i == j){
               M_B(i,j) = 1;
           }else{
               M_B(i,j) = 0;
           }
        }
    }

    int times = 3000;

    {
        auto begin = std::chrono::high_resolution_clock::now();
        for(int repeatme = 0; repeatme < times; repeatme++){
            for(int (v0) = (0); (v0) < (1600) ;(v0) += (1)){
                for(int (v1) = (0); (v1) < (1600) ;(v1) += (1)){
                    M_A((v0), (v1)) = 0;
                }
                for(int (v2) = (0); (v2) < (20) ;(v2) += (1)){
                    for(int (v3) = (0); (v3) < (20) ;(v3) += (1)){
                        for(int (v4) = (0); (v4) < (2) ;(v4) += (1)){
                            M_A((v0), ((2)*(((2)*(((20)*(v2))+(v3)))+(v4)))) += (1.0)*M_B((v0), ((2)*(((2)*(((20)*(v2))+(v3)))+(v4))));
                            M_A((v0), (((2)*(((2)*(((20)*(v2))+(v3)))+(v4)))+(1))) += (-1.0)*M_B((v0), (((2)*(((2)*(((20)*(v2))+(v3)))+(v4)))+(1)));
                        }
                    }
                }
            }
        }
        auto end = std::chrono::high_resolution_clock::now();
        std::cerr << std::chrono::duration_cast<std::chrono::nanoseconds>(end-begin).count()*1e-9 << " s" << std::endl;
        dump_mat(a,b,"IIIz");
    }

    {
        auto begin = std::chrono::high_resolution_clock::now();
        for(int repeatme = 0; repeatme < times; repeatme++){
            for(int (v0) = (0); (v0) < (1600) ;(v0) += (1)){
                for(int (v1) = (0); (v1) < (1600) ;(v1) += (1)){
                    M_A((v0), (v1)) = 0;
                }
                for(int (v2) = (0); (v2) < (20) ;(v2) += (1)){
                    for(int (v3) = (0); (v3) < (20) ;(v3) += (1)){
                        M_A((v0), (((2)*(((20)*(((2)*(v2))+(1)))+(v3)))+(1))) += (1.0)*M_B((v0), ((2)*(((40)*(v2))+(v3))));
                        M_A((v0), ((2)*(((20)*(((2)*(v2))+(1)))+(v3)))) += (1.0)*M_B((v0), (((2)*(((40)*(v2))+(v3)))+(1)));
                    }
                    for(int (v4) = (0); (v4) < (20) ;(v4) += (1)){
                        M_A((v0), (((2)*(((40)*(v2))+(v4)))+(1))) += (1.0)*M_B((v0), ((2)*(((20)*(((2)*(v2))+(1)))+(v4))));
                        M_A((v0), ((2)*(((40)*(v2))+(v4)))) += (1.0)*M_B((v0), (((2)*(((20)*(((2)*(v2))+(1)))+(v4)))+(1)));
                    }
                }
            }
        }
        auto end = std::chrono::high_resolution_clock::now();
        std::cerr << std::chrono::duration_cast<std::chrono::nanoseconds>(end-begin).count()*1e-9 << " s" << std::endl;
        dump_mat(a,b,"IxIx");
    }

    {
        auto begin = std::chrono::high_resolution_clock::now();
        for(int repeatme = 0; repeatme < times; repeatme++){
            for(int (v0) = (0); (v0) < (1600) ;(v0) += (1)){
                for(int (v1) = (0); (v1) < (1600) ;(v1) += (1)){
                    M_A((v0), (v1)) = 0;
                }
                for(int (v2) = (0); (v2) < (20) ;(v2) += (1)){
                    for(int (v3) = (0); (v3) < (20) ;(v3) += (1)){
                        M_A((v0), (((2)*(((20)*((20)+(v2)))+(v3)))+(1))) += (1.0)*M_B((v0), ((2)*(((20)*(v2))+(v3))));
                        M_A((v0), ((2)*(((20)*((20)+(v2)))+(v3)))) += (1)*M_B((v0), (((2)*(((20)*(v2))+(v3)))+(1)));
                    }
                }
                for(int (v4) = (0); (v4) < (20) ;(v4) += (1)){
                    for(int (v5) = (0); (v5) < (20) ;(v5) += (1)){
                        M_A((v0), (((2)*(((20)*(v4))+(v5)))+(1))) += (1.0)*M_B((v0), ((2)*(((20)*((20)+(v4)))+(v5))));
                        M_A((v0), ((2)*(((20)*(v4))+(v5)))) += (1.0)*M_B((v0), (((2)*(((20)*((20)+(v4)))+(v5)))+(1)));
                    }
                }
            }
        }
        auto end = std::chrono::high_resolution_clock::now();
        std::cerr << std::chrono::duration_cast<std::chrono::nanoseconds>(end-begin).count()*1e-9 << " s" << std::endl;
        dump_mat(a,b,"xIIx");
    }

    free(a);
    free(b);
}
