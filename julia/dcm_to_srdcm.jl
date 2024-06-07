using Distributed; using ClusterManagers; #addprocs(SlurmManager(16), t="01:30:00", N=4, mem_per_cpu=4096, ntasks=16, o="/cluster/scratch/spruthi/project4/julia/logs/log_test.txt"; exeflags="--project")


@everywhere using RegressionDynamicCausalModeling, MAT, Plots, HDF5
@everywhere using FilePathsBase, Serialization, Random, UnPack


#export load_matrix

function h5_save_output(output_srcdm, output_rdcm, filename::String)
    h5open(filename, "w") do file
        create_group(file, "srdcm")
        create_group(file, "rdcm")
        write(file, "srdcm/m_all", output_srdcm.m_all)
        write(file, "srdcm/F_r", output_srdcm.F_r)
        write(file, "srdcm/z_all", output_srdcm.z_all)
        write(file, "rdcm/m_all", output_rdcm.m_all)
        write(file, "rdcm/F_r", output_rdcm.F_r)
        write(file, "rdcm/z_all", output_rdcm.z_all)
    end
end

@everywhere function save_matrix(matrix, filename::String)
    #println("Saving matrix?")
    open(filename, "w") do file
        serialize(file, matrix)
    end
end

function load_matrix(filename::String)
    open(filename, "r") do file
        return deserialize(file)
    end
end

@everywhere function process_to_rdcm(dataDir::String, sub::String, targetDir::String, p0::Float64)
    #subnum = SubString(sub, 5, 8)
    #println(subnum)
    dcm = load_DCM(joinpath(dataDir, sub, "DCM.mat"))
    #dcm = load_DCM(joinpath(dataDir, "DCMs", "DCM$(subnum).mat"))
    #dcm = load_DCM(joinpath(dataDir, "share", "schizos", "DCM.$(sub).mat"))
    opt_srdcm = Options(SparseInversionParams(; reruns=50, restrictInputs=true); synthetic=false, rng=MersenneTwister(42))
    opt_rdcm = Options(RigidInversionParams(); synthetic=false, rng=MersenneTwister(42))

    rdcm = RigidRdcm(dcm) # convert the DCM to a rDCM model
    dcm_test = LinearDCM(dcm.a,rdcm.c,dcm.scans,dcm.nr,InputU(rdcm.U.u, rdcm.U.dt),dcm.Y,dcm.Ep)
    srdcm = SparseRdcm(dcm_test; inform_p0=true, p0=p0)
    # Estimate effective connectivity
    output_srdcm = invert(srdcm, opt_srdcm)
    output_rdcm = invert(rdcm, opt_rdcm)

    p0_out = string(floor(Int,p0*100))

    # save matrix
    #h5_save_output(output_srdcm, output_rdcm, "$targetDir/$(sub)_inv_mFz_$(p0_out).h5")
    h5open("$targetDir/$(sub)_inv_mFz_$(p0_out).h5", "w") do file
    create_group(file, "srdcm")
    #create_group(file, "rdcm")
    write(file, "srdcm/m_all", output_srdcm.m_all)
    write(file, "srdcm/F_r", output_srdcm.F_r)
    write(file, "srdcm/z_all", output_srdcm.z_all)
    write(file, "rdcm/m_all", output_rdcm.m_all)
    write(file, "rdcm/F_r", output_rdcm.F_r)
    #write(file, "rdcm/z_all", output_rdcm.z_all)
    end
    save_matrix(output_srdcm.m_all, "$targetDir/$(sub)_srdcm_m_$(p0_out).mat")
    save_matrix(output_rdcm.m_all, "$targetDir/$(sub)_rdcm_m_$(p0_out).mat")
    save_matrix(output_srdcm.Σ_all, "$targetDir/$(sub)_srdcm_sigma_$(p0_out).mat")
    save_matrix(output_rdcm.Σ_all, "$targetDir/$(sub)_rdcm_sigma_$(p0_out).mat")
    save_matrix(output_srdcm.F_r, "$targetDir/$(sub)_srdcm_F_$(p0_out).mat")
    save_matrix(output_rdcm.F_r, "$targetDir/$(sub)_rdcm_F_$(p0_out).mat")
    end

#function extract_subject(filename)
#    m = match(r"DCM\.(sub-\d+)\.mat", filename)
#    return m !== nothing ? m.captures[1] : nothing
#end

function main()
    #dataDir = "/cluster/scratch/spruthi/project4/SRPBS_OPEN/data"
    dataDir = dirname(pwd())
    dataDir = joinpath(dataDir,"SRPBS_OPEN","data")
    sparsity_p0 = [0.25,50]

    #@sync @distributed for file in readdir(dataDir)
    #for file in ["sub-1390", "sub-1391", "sub-1393", "sub-1400", "sub-1401", "sub-1403", "sub-1405", "sub-1408"]
    for file in ARGS
    #if file == "Brainnetome2016" || file == "sub-1367" || file == "sub-1378" || file == "sub-1380" || file == "sub-1385" || file == "sub-1392" || file == "sub-1402" || file == "sub-1404" || file == "sub-1406" || file == "sub-1407" || file == "sub-1363" || file == "sub-1364" || file == "sub-1365" || file == "sub-1409" || file == "sub-1410"
    #    continue
    #end
    if file == "Brainnetome2016"
        continue
    end

    println(file)
    dataFile = joinpath(dataDir, file)
    targetDir = joinpath(dataFile, "sparseInversion")
    if !ispath(targetDir)
        mkpath(targetDir)
        println("$targetDir created")
    end

    #println("$target_file does not exist yet")

    for p0 in sparsity_p0
        try
            process_to_rdcm(dataDir, file, targetDir, p0)
        catch e
            println("An error occurred: $(typeof(e)), err: $(e)")
            continue
        end
    end
end

for i in workers()
  rmprocs(i)
end
end

if abspath(PROGRAM_FILE) == @__FILE__
   println("Running as main script")
   main()
end