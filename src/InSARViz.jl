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

# ------ Exports
export make_list
export plot_wrp_igrams

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
        min_amp::Union{Nothing,Real}=nothing,
        max_amp::Union{Nothing,Real}=nothing
    )

Plot the `phase` and `amplitude` of a list of wrapped interferograms as `.png`
images.

# Positional Arguments
- `file_paths`: `Vector{String}` listed of wrapped interferograms
- `wid`: `Int` width of the wrapped interferograms (in pixels)
- `len`: `Int` length of the wrapped interferograms (in pixels)

# Optional Arguments
- `min_amp`: `Real` amplitude lower bound. Default is `minimum(amp)`.
- `max_amp`: `Real` amplitude upper bound. Default is `maximum(amp)`.

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

    # Colormap
    cmap_phi = brew_igram()
    cmap_amp = brew_gray()

    for path in file_paths

        # Read file
        println("Processing: $path")
        read_wrp_igram!(raw, int, path)
        for (k, val) in enumerate(int)
            amp[k] = abs(val)
            phi[k] = angle(val)
        end

        # Amplitude bounds
        min_amp = quantile(vec(amp), min_quantile)
        max_amp = quantile(vec(amp), max_quantile)

        # Plot to disk
        base_path, _ = splitext(path)
        path_amp = base_path * "_amp.png"
        path_phi = base_path * "_phi.png"
        save_img(amp, cmap_amp, min_amp, max_amp, path_amp)
        save_img(phi, cmap_phi, -pi, pi, path_phi)
    end
end

end
