module InSARViz

# ----- External dependencies
using Colors            # create RGB objects
using Images            # for saving images
using ImageIO           # PNG encoder
using LinearAlgebra     # matrix manipulation for igram I/O
using Statistics        # for amplitude bounds

# ----- Internal dependencies

# File IO
include("fileio/read_wrp_igram.jl")
include("fileio/read_unw_igram.jl")

# Plotting utilities
include("utils/cmap.jl")
include("utils/save_img.jl")
include("utils/wrap.jl")

# ------ Exports
export make_list
export plot_wrp_igrams
export plot_unw_igrams
export plot_defs
export plot_cohs

# ----- Functions
"""
    make_list(
        dirpath::String,
        extension::String
    )

Create a list of all the files with a given extension within a directory.

# Positional Arguments
- `dirpath`: `String` path to directory containing the files
- `extension`: `String` file extension to search for

# Returns
`Vector{String}`: list of absolute paths
"""
function make_list(
    dirpath::String,
    extension::String
)
    file_list = readdir(dirpath)
    files = Vector{String}()
    for file_name in file_list
        if endswith(file_name, extension)
            full_path = joinpath(dirpath, file_name)
            push!(files, abspath(full_path))
        end
    end
    return files
end

"""
    plot_wrp_igrams(
    file_paths::Vector{String},
    wid::Int,
    len::Int;
    min_quantile::Real=0.01,
    max_quantile::Real=0.99
)

Plot the `phase` and `amplitude` of a list of wrapped interferograms as `.png`
images.

# Positional Arguments
- `file_paths`: `Vector{String}` listed of wrapped interferograms
- `wid`: `Int` width of the wrapped interferograms (in pixels)
- `len`: `Int` length of the wrapped interferograms (in pixels)

# Optional Arguments
- `min_quantile`: `Real` min amplitude quantile to clip to (default is `0.01`)
- `max_quantile`: `Real` max amplitude quantile to clip to (default is `0.99`)

# Returns
PNG images of the amplitude and wrapped phase.

# Notes
Output naming convention:
- <name>_amp.png: amplitude of the wrapped interferogram
- <name>_phi.png: phase of the wrapped interferogram
"""
function plot_wrp_igrams(
    file_paths::Vector{String},
    wid::Int,
    len::Int;
    min_quantile::Real=0.01,
    max_quantile::Real=0.99
)
    # Buffers
    raw = Matrix{ComplexF32}(undef, wid, len)
    int = Matrix{ComplexF32}(undef, len, wid)
    amp = Matrix{Float32}(undef, len, wid)
    phi = Matrix{Float32}(undef, len, wid)
    amp_vec = Vector{Float32}(undef, len * wid)

    # Colormap
    cmap_phi = brew_igram()
    cmap_amp = brew_gray()

    for path in file_paths

        # Read file
        println("Processing: $path")
        read_wrp_igram!(raw, int, path)
        for (k, val) in enumerate(int)
            amp_k = abs(val)
            amp[k] = amp_k
            amp_vec[k] = amp_k
            phi[k] = angle(val)
        end

        # Amplitude bounds
        min_amp, max_amp = quantile!(amp_vec, (min_quantile, max_quantile))

        # Plot to disk
        base_path, _ = splitext(path)
        path_amp = base_path * "_amp.png"
        path_phi = base_path * "_phi.png"
        save_img(amp, cmap_amp, min_amp, max_amp, path_amp)
        save_img(phi, cmap_phi, -pi, pi, path_phi)
    end
end

"""
    plot_unw_igrams(
        file_paths::Vector{String},
        wid::Int,
        len::Int;
        wrap_val::Real=10,
        min_quantile::Real=0.01,
        max_quantile::Real=0.99
    )

Plot the `phase` and `amplitude` of a list of unwrapped interferograms as `.png`
images.

# Positional Arguments
- `file_paths`: `Vector{String}` listed of unwrapped interferograms
- `wid`: `Int` width of the unwrapped interferograms (in pixels)
- `len`: `Int` length of the unwrapped interferograms (in pixels)

# Optional Arguments
- `wrap_val`: `Real` value to wrap the phase to as `[-val/2.0, val/2.0]`
- `min_quantile`: `Real` min amplitude quantile to clip to (default is `0.01`)
- `max_quantile`: `Real` max amplitude quantile to clip to (default is `0.99`)

# Returns
PNG images of the amplitude and unwrapped phase.

# Notes
Output naming convention:
- <name>_amp.png: amplitude of the unwrapped interferogram
- <name>_psi.png: phase of the unwrapped interferogram
"""
function plot_unw_igrams(
    file_paths::Vector{String},
    wid::Int,
    len::Int;
    wrap_val::Real=10,
    min_quantile::Real=0.01,
    max_quantile::Real=0.99
)
    # Buffers
    raw = Matrix{Float32}(undef, 2 * wid, len)
    amp = Matrix{Float32}(undef, len, wid)
    psi = Matrix{Float32}(undef, len, wid)
    amp_vec = Vector{Float32}(undef, len * wid)

    # Colormaps
    cmap_psi = brew_igram()
    cmap_amp = brew_gray()

    # Process
    for path in file_paths
        # File I/O
        println("Processing: $path")
        read_unw_igram!(raw, amp, psi, path)
        for (k, amp_k) in enumerate(amp)
            amp_vec[k] = amp_k
        end

        # Amplitude bounds
        min_amp, max_amp = quantile!(amp_vec, (min_quantile, max_quantile))

        # Wrap the phase to defined value
        wrap!(psi, Float32(-wrap_val / 2.0), Float32(wrap_val / 2.0))

        # Plot to disk
        base_path, _ = splitext(path)
        path_amp = base_path * "_amp.png"
        path_psi = base_path * "_psi.png"
        save_img(amp, cmap_amp, min_amp, max_amp, path_amp)
        save_img(psi, cmap_psi, -wrap_val / 2.0, wrap_val / 2.0, path_psi)
    end
end

"""
    plot_defs(
        file_paths::Vector{String},
        wid::Int,
        len::Int,
        min_def::Real,
        max_def::Real;
        min_quantile::Real=0.01,
        max_quantile::Real=0.99
    )

Plot the `deformation` and `SAR amplitude` of a list of deformation maps.

# Positional Arguments
- `file_paths`: `Vector{String}` listed of deformation maps
- `wid`: `Int` width of the deformation map (in pixels)
- `len`: `Int` length of the deformation map (in pixels)
- `min_def`: `Real` lower bound of deformation color bar
- `max_def`: `Real` upper bound of deformation color bar

# Optional Arguments
- `min_quantile`: `Real` min amplitude quantile to clip to (default is `0.01`)
- `max_quantile`: `Real` max amplitude quantile to clip to (default is `0.99`)

# Returns
PNG images of the SAR amplitude and deformation.

# Notes
Output naming convention:
- <name>_amp.png: SAR amplitude map
- <name>_def.png: deformation map
"""
function plot_defs(
    file_paths::Vector{String},
    wid::Int,
    len::Int,
    min_def::Real,
    max_def::Real;
    min_quantile::Real=0.01,
    max_quantile::Real=0.99
)
    # Buffers
    raw = Matrix{Float32}(undef, 2 * wid, len)
    amp = Matrix{Float32}(undef, len, wid)
    def = Matrix{Float32}(undef, len, wid)
    amp_vec = Vector{Float32}(undef, len * wid)

    # Colormaps
    cmap_def = brew_byr()
    cmap_amp = brew_gray()

    # Process
    for path in file_paths
        # File I/O
        println("Processing: $path")
        read_unw_igram!(raw, amp, def, path)

        # Amplitude bounds
        for (k, amp_k) in enumerate(amp)
            amp_vec[k] = amp_k
        end
        min_amp, max_amp = quantile!(amp_vec, (min_quantile, max_quantile))

        # Plot to disk
        base_path, _ = splitext(path)
        path_amp = base_path * "_amp.png"
        path_def = base_path * "_def.png"
        save_img(amp, cmap_amp, min_amp, max_amp, path_amp)
        save_img(def, cmap_def, min_def, max_def, path_def)
    end
end

"""
    plot_cohs(
        file_paths::Vector{String},
        wid::Int,
        len::Int;
        min_quantile::Real=0.01,
        max_quantile::Real=0.99
    )

Plot the `coherence` and `amplitude` of a list of coherence maps.

# Positional Arguments
- `file_paths`: `Vector{String}` list of coherence maps
- `wid`: `Int` width of the coherence map (in pixels)
- `len`: `Int` length of the coherence map (in pixels)

# Optional Arguments
- `min_quantile`: `Real` min amplitude quantile to clip to (default is `0.01`)
- `max_quantile`: `Real` max amplitude quantile to clip to (default is `0.99`)

# Returns
PNG images of the interferogram amplitude and coherence.

# Notes
Output naming convention:
- <name>_amp.png: amplitude of the interferogram
- <name>_coh.png: coherence of the interferogram
"""
function plot_cohs(
    file_paths::Vector{String},
    wid::Int,
    len::Int;
    min_quantile::Real=0.01,
    max_quantile::Real=0.99
)
    # Buffers
    raw = Matrix{Float32}(undef, 2 * wid, len)
    amp = Matrix{Float32}(undef, len, wid)
    amp_vec = Vector{Float32}(undef, len * wid)
    coh = Matrix{Float32}(undef, len, wid)

    # Colormaps
    cmap_coh = brew_coh()
    cmap_amp = brew_gray()

    # Process
    for path in file_paths
        # File I/O
        println("Processing: $path")
        read_unw_igram!(raw, amp, coh, path)

        # Amplitude bounds
        for (k, amp_k) in enumerate(amp)
            amp_vec[k] = amp_k
        end
        min_amp, max_amp = quantile!(amp_vec, (min_quantile, max_quantile))

        # Plot to disk
        base_path, _ = splitext(path)
        path_amp = base_path * "_amp.png"
        path_coh = base_path * "_coh.png"
        save_img(amp, cmap_amp, min_amp, max_amp, path_amp)
        save_img(coh, cmap_coh, 0.0, 1.0, path_coh)
    end
end

end
