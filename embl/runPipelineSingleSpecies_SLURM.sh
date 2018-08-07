snakemake  --jobs 100 --local-cores 8 --restart-times 1 \
           --cluster 'sbatch -N 1 -n {cluster.n}  -t {cluster.time} --mem={cluster.mem} --output={cluster.output} --error={cluster.error}  --mail-type=FAIL'  \
           --cluster-config cluster.yaml --use-conda meta qc filter map extract