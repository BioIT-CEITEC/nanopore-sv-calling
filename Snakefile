from pathlib import Path
configfile: "config.json"
GLOBAL_REF_PATH = config["globalResources"] 

##### BioRoot utilities - reference #####
module BR:
    snakefile: gitlab("bioroots/bioroots_utilities", path="bioroots_utilities.smk",branch="master")
    config: config

use rule * from BR as other_*
config = BR.load_organism()¨

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
reference_path = os.path.join(GLOBAL_REF_PATH,config["organism"], config["reference"], "seq", config["reference"] + ".fa")

library_name = list(config["libraries"].keys())[0]
sample_hashes = list(config["libraries"][library_name]["samples"].keys())

sample_names = []
for sample in sample_hashes:
    sample_name = config["libraries"][library_name]["samples"][sample]["sample_name"]
    sample_names.append(sample_name)

##### Target rules #####
rule all:
    input:
        expand("{library_name}/SV_calling/{sample_name}/{sample_name}.vcf", library_name = library_name, sample_name = sample_names)

rule SV_calling:
    input: 
        bam = '{library_name}/aligned/{sample_name}/{sample_name}.bam'
    output:
        vcf = 'SV_calling/{sample}/{sample}.vcf'
    params: reference_path = reference_path,
    conda: 
        "../envs/svim_environment.yaml"
    shell:
        """
        svim alignment outputs/{wildcards.library_name}sv_calling/ {input.bam} {params.reference_path} 
        """

#rule QC_after_SV_calling:
