#!/bin/bash
eval "$(conda shell.bash hook)"
cd workflow
conda activate hitmap-snakemake

# ------------------------------ Ask for the number of cores and validate input ------------------------------
while true; do
    read -p "How many cores would you like to set for Snakemake? " cores
    if [[ $cores =~ ^[0-9]+$ ]]; then
        break
    else
        echo "Please enter a valid number."
    fi
done

# ------------------------------ Ask for output folder name and validate ------------------------------
while true; do
    read -p "Please specify the folder name to save the output for this run (no spaces): " folder_name
    if [[ ! $folder_name =~ \ |\' ]]; then
        mkdir -p data/Output
        if [ -d "data/Output/$folder_name" ]; then
            echo "This folder name already exists. Please choose another one."
        else
            break
        fi
    else
        echo "Please do not include spaces in the folder name."
    fi
done

# get the name of the .ibd file and copy/link the corresponding ID folder
ibd_file_name=$(basename data/*.ibd .ibd)

# ------------------------------ Ask which module to run and validate ------------------------------
while true; do
    echo "Which module would you like to run? (Please type the number)"
    echo "1. Reference database generation"
    echo "2. Peak picking + peptide & protein scoring"
    echo "3. Image rendering"
    read -p "Enter your choice: " module_choice
    
    case $module_choice in
        1)
            echo "Snakemake pipeline starts now..."
            snakemake --cores "$cores" data/Summary\ folder/protein_index.csv
            ;;
        2)
            echo "Snakemake pipeline starts now..."
            snakemake --cores "$cores" data/$ibd_file_name\ ID/Peptide_region_file.csv
            ;;
        3)
            echo "Snakemake pipeline starts now..."
            snakemake --cores "$cores" data/Summary\ folder/Protein_feature_list_trimmed.csv
            ;;
        *)
            echo "Invalid option. Please enter 1, 2, or 3."
            continue
            ;;
    esac
    break
done

# ------------------------------ Copy or link results to the output folder ------------------------------
(cp -rl data/Summary\ folder "data/Output/$folder_name" || cp -r data/Summary\ folder "data/Output/$folder_name") 2> /dev/null
(cp -rl "data/${ibd_file_name} ID" "data/Output/$folder_name" || cp -r "data/${ibd_file_name} ID" "data/Output/$folder_name") 2> /dev/null