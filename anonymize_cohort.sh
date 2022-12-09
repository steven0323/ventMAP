#!/bin/sh
# Please specify patient_directory and the place you want to store info.csv before you run the script in default.yaml

unanon_data_path="${UNANON_DATA_PATH:-$(yq ".unanon_data_path" default.yaml)}" 
anon_data_path="${ANON_DATA_PATH:-$(yq ".anon_data_path" default.yaml)}" 

export raw_patient_dir data_path

anonymize_rawdata(){
    echo "Start anonymizing raw data ..."
    for dir in ${unanon_data_path}/experiment1/all_data/raw/*/; do
        # Preprocessing file from each patient directories and then anonymize data
        python ventmap/validate_data_type.py $dir
        python ventmap/anonymize_datatimes.py $dir --new-cohort-file $anon_data_path/info.csv --new-dir $anon_data_path/experiment1/all_data/raw
    done

    echo "Anonymization on raw data finished !!"
}

update_cohort_description(){
    echo "Update cohort description ..."
    python ventmap/redo_cohort_desc_after_anonymization.py --shift-file $anon_data_path/info.csv --non-anon-cohort-desc $unanon_data_path/cohort-description.csv --anon-cohort-desc $anon_data_path/anon-desc.csv
    echo "Update cohort description finished !!"

}

conda_activate(){
    # Need to specify the path to ccil_vwd here if not in Desktop
    echo "conda activate ards ..."
    cd ..
    cd $PWD/ccil_vwd/
    source activate ards
}

baseline(){
    echo "Preprocessed dataset and run baseline ..."    
    python train.py --data-path $anon_data_path --cohort-description $anon_data_path/anon-desc.csv --to-pickle processed_dataset.pkl
    echo "Preprocessing dataset finished !!"
}

anonymize_rawdata
update_cohort_description
conda_activate
baseline

