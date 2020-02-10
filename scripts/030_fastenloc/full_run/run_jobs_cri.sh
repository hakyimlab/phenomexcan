#!/bin/bash

read -r -d '' PENDING_TISSUES << EOM
Brain_Cerebellum                   
Brain_Spinal_cord_cervical_c-1     
Artery_Coronary                    
Brain_Substantia_nigra             
Esophagus_Gastroesophageal_Junction
Small_Intestine_Terminal_Ileum     
Heart_Left_Ventricle               
Brain_Cortex                       
Brain_Hypothalamus                 
Muscle_Skeletal                    
Artery_Aorta                       
Spleen                             
Brain_Cerebellar_Hemisphere        
Uterus                             
Skin_Sun_Exposed                   
Nerve_Tibial                       
Colon_Sigmoid                      
Skin_Not_Sun_Exposed               
EOM

for tissue in ${PENDING_TISSUES}
do
    while [ $(qstat -i | wc -l) -gt 4000 ]
    do
        n_jobs=$(qstat -i | wc -l)
        echo "Not yet for ${tissue} (${n_jobs} now)"
        sleep 10m
    done

    echo $(date)
    echo "Running for tissue ${tissue}"
    parallel -j8 'qsub {}' ::: jobs_fastenloc/*_${tissue}_*.sh
done

