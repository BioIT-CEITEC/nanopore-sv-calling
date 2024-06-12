from pathlib import Path
configfile: "config.json"
GLOBAL_REF_PATH = config["globalResources"] 

ref_type = list(config["libraries"].values())[0]["reference"]
reference_path = os.path.join(GLOBAL_REF_PATH, "homo_sapiens", ref_type, "seq", ref_type + ".fa")

library_name = list(config["libraries"].keys())[0]
sample_hashes = list(config["libraries"][library_name]["samples"].keys())

sample_names = []
for sample in sample_hashes:
    sample_name = config["libraries"][library_name]["samples"][sample]["sample_name"]
    sample_names.append(sample_name)

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