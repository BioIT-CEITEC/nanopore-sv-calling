from pathlib import Path
import pandas as pd

configfile: "config.json"
GLOBAL_REF_PATH = config["globalResources"] 

##### BioRoot utilities - reference #####
module BR:
    snakefile: gitlab("bioroots/bioroots_utilities", path="bioroots_utilities.smk",branch="master")
    config: config

use rule * from BR as other_*
config = BR.load_organism()

# setting organism from reference
f = open(os.path.join(GLOBAL_REF_PATH,"reference_info","reference2.json"),)
reference_dict = json.load(f)
f.close()

config["species_name"] = [organism_name for organism_name in reference_dict.keys() if isinstance(reference_dict[organism_name],dict) and config["reference"] in reference_dict[organism_name].keys()][0]
config["organism"] = config["species_name"].split(" (")[0].lower().replace(" ","_")
if len(config["species_name"].split(" (")) > 1:
    config["species"] = config["species_name"].split(" (")[1].replace(")","")

##### Config processing #####
# Folders
#
sample_tab = pd.DataFrame.from_dict(config["samples"],orient="index")
reference_path = os.path.join(GLOBAL_REF_PATH,config["organism"], config["reference"], "seq", config["reference"] + ".fa")

##### Target rules #####
rule all:
    input:
        expand("SV_calling/{sample_name}/variants.vcf", sample_name = sample_tab.sample_name)

rule SV_calling:
    input: 
        bam = 'aligned/{sample_name}/{sample_name}_sorted.bam'
    output:
        vcf = 'SV_calling/{sample_name}/variants.vcf'
    params: reference_path = reference_path,
        dirname = "SV_calling/{sample_name}"
    conda: 
        "envs/svim_environment.yaml"
    shell:
        """
        svim alignment {params.dirname} {input.bam} {params.reference_path} 
        """

#rule QC_after_SV_calling:
