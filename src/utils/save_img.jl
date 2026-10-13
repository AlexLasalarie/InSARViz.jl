"""
    save_img(
        A::AbstractMatrix, 
        cmap::AbstractMatrix, 
        min_val::Real, 
        max_val::Real,
        name::String;
        mask::Bool=false
    )

Save a colored image to disk using a custom colormap.
"""
function save_img(
    A::AbstractMatrix,
    cmap::AbstractMatrix,
    min_val::Real,
    max_val::Real,
    name::String;
    mask::Bool=false
)
    len, wid = size(A)
    ncolors = size(cmap, 1)
    img = Matrix{RGB{N0f8}}(undef, len, wid)
    for (k, val) in enumerate(A)
        if mask && iszero(val)
            img[k] = RGB(1.0, 1.0, 1.0)
        else
            scaled = (val - min_val) / (max_val - min_val) * (ncolors - 1) + 1
            idx = clamp(round(Int, scaled), 1, ncolors)
            img[k] = RGB(cmap[idx, 1], cmap[idx, 2], cmap[idx, 3])
        end
    end
    save(name, img)
end
