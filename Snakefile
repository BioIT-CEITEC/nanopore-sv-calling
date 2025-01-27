from pathlib import Path
import pandas as pd

configfile: "config.json"
GLOBAL_REF_PATH = config["globalResources"] 

##### BioRoot utilities - reference #####
module BR:
    snakefile: github("BioIT-CEITEC/bioroots_utilities", path="bioroots_utilities.smk",branch="master")
    config: config

use rule * from BR as other_*
config = BR.load_organism()
sample_tab = BR.load_sample()

##### Config processing #####
# Folders
#
#sample_tab = pd.DataFrame.from_dict(config["samples"],orient="index")
reference_path = os.path.join(GLOBAL_REF_PATH,config["organism"], config["reference"], "seq", config["reference"] + ".fa")

##### Target rules #####
rule all:
    input:
        expand("SV_calling/{sample_name}/variants.vcf", sample_name = sample_tab.sample_name)

rule SV_calling:
    input: 
        bam = 'aligned/{sample_name}/{sample_name}_sorted.bam'
    output:
        vcf = 'SV_calling/{sample_name}/{sample_name}_variants.vcf'
    params: dirname = "SV_calling/{sample_name}",
        genome = config["organism_fasta"]
    conda: 
        "envs/svim_environment.yaml"
    shell:
        """
        svim alignment {params.dirname} {input.bam} {params.genome} 
        """

#rule QC_after_SV_calling:
