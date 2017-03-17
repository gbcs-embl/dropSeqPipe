NEWS -- Version 0.21
--------------
A.
Rerun option. Allows to force a rerun of a step. This means you don't have to delete files anymore to rerun a particular step, just add `--rerun`

B.
Possbility to run multiple steps at once in the --mode option:`-m pre-process knee-plot extract-expression`

Description
------------------
This pipeline is based on [snakemake](https://snakemake.readthedocs.io/en/stable/) and the dropseq tools provided by the [McCarroll Lab](http://mccarrolllab.com/dropseq/). It allows to handle raw data from your dropseq experiment until the count of UMI counts.


Installation
--------
Before using it you will need to install some softwares/packages:

1. [R](https://cran.r-project.org/)
2. [STAR aligner](https://github.com/alexdobin/STAR)
3. [Drop-seq tools (1.12)](http://mccarrolllab.com/dropseq/)
4. [Picard tools](https://broadinstitute.github.io/picard/)
5. [yaml R package](https://cran.r-project.org/web/packages/yaml/index.html)

Once you have everything just run:
```
git clone https://github.com/Hoohm/Drop-seq
cd Drop-seq
python3 setup.py install
```

Summary
-------

Before running the pipeline you will need a reference genome as well as the GTF (needed for the ReFlat) and the ReFlat. This is not explained here but you can get the info [here](http://mccarrolllab.com/dropseq/).

In order to run the pipeline you will need to write two config yaml files.
One will contain the paths to your executables as well as the Drop-Seq tools.
```
TMPDIR: /path/to/temp
PICARD: /path/to/picard/dist/picard.jar
DROPSEQ: /path/to/Drop-seq_tools-1.12
STAREXEC: /path/to/STAR/bin/Linux_x86_64/STAR
CORES: X
```
Please note the "space" after the semi-colon, it's needed for the yaml to work.

I had some issues because I had not enough space on / so I added a temp folder to fix that. Note: If you have the same problem, this TMPDIR variable won't make the change for the calls inside the drop-seq-tools. You have to edit all the *.sh files in the drop-seq tools and add it manually there.
* TMPDIR is the temp folder on the disk with enough space
* PICARD is the path to the picard.jar
* DROPSEQ is the path to the folder of Drop-Seq tools
* STAREXEC is the path to the STAR executable
* CORES is the number of cores you want to use in the pipeline (snakemake is great at balancing tasks!)

The other yaml file should be in the folder containing all your fastq files and should look like that.
```
Samples:
    Sample1:
        fraction: 0.001
        expected_cells: 100
    Sample2:
        fraction: 0.001
        expected_cells: 100
GENOMEREF: /path/to/reference.fa
REFFLAT: /path/to/reference.refFlat
METAREF: /path/to/STAR_REF
SPECIES:
    - MOUSE
    - HUMAN
```

* Samples contains a list of the names of your samples. In this example the samples in the folder should look like:
```
Sample1_R1.fastq.gz
Sample1_R2.fastq.gz
Sample2_R1.fastq.gz
Sample2_R2.fastq.gz
```

* fraction is the fraction of reads per cell you expect. This is to find the bend in the knee plot. Tweaking it changes where you cut and desice which are valid STAMPs and which are not. 0.001 is a good place to start testing.
* expected_cells should be the amount of cells you expect from your sample.
* GENOMEREF is the reference fasta of your genome.
* REFLAT is the reference refFlat file needed by the pipeline. You can check how to create it in the [Drop-Seq alignement cookbook](http://mccarrolllab.com/dropseq/).
* METAREF is the folder of the STAR index
* SPECIES is the species used in the experiment. Provide a list, even when only one species is present.
Ex:
```
 SPECIES:
    - MOUSE
    - HUMAN
```
or
```
 SPECIES:
    - MOUSE
```
Note: The name of the species is relevant in the mixed experiment, it has to match the name used in the mixed reference.


Once everything is in place, you can run the pipeline using the following command:

`dropSeqPip -f /path/to/your/samples/ -c /path/to/local/config/file.yaml -m mode`

You can choose from four different modes to run:

1. pre-process: Go from sample_R1.fastq.gz to the final.bam file containing the aligned sorted data.
2. knee-plot: Make the knee plot. Needs step 1.
3. species-plot: Make the species plot. Needs step 1 and 2. Won't run if you have only one species. (specific for mixing experiments)
4. extract-expression: Extract the expression data. Needs step 1 and 2 (3 for mixing experiment)

If you don't need to change values in the config files for the different steps, you can also simply run multiple modes at a time. ie:

`dropSeqPip -f /path/to/your/samples/ -c /path/to/local/config/file.yaml -m pre-process knee-plot extract-expression`

This is the folder structure you get in the end:
```
/path/to/your/samples/
| -- plots/
| -- summary/
| -- logs/
| config.yaml
```

* plots contains the knee plots and species plots.
* summary contains the barcodes selected per sample per species, final expression matrix.
* logs contains all the logs fromthe different programs that have run.


Note: The reason why I run the pre-processing in three different snakefiles is because of the way STAR handles the loading of the reference genome.
The main idea is that I want to load the reference once, process all the samples and then unload the reference.

Future implementations
---------------------------
* Cluster version (One of the reasons it's based on snakemake)
* Cross language dependencies installation
* Mixed reference genome generation
* reflat generation
* UMI and Barcode range in config.yaml


I hope it can help you out in your drop-seq experiment!

Feel free to comment and point out potential improvements.