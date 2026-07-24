# Collection of color maps for different quantities

# ----- Wrapped phase (rainbow)
function brew_igram()
    vec = ones(Float32, 255)
    vec[85:85+85] .= 1 .- 0.6 / 85 .* (0:85)
    vec[85+85:end] .= 0.4 .+ 0.6 / 85 .* (0:85)
    circshift(v::AbstractVector, n::Int) = v[mod.(collect(1:length(v)) .- 1 .- n, length(v)).+1]
    g = circshift(vec, 1)
    b = circshift(g, 85)
    r = circshift(b, 85)
    cmap = hcat(g, b, r)
    return cmap
end

# ------ Coherence (inferno)
function brew_coh()
    p = palette(:inferno, 255)
    cmap = Matrix{Float32}(undef, 255, 3)
    for i in 1:255
        c = p[i]
        cmap[i, 1] = c.r
        cmap[i, 2] = c.g
        cmap[i, 3] = c.b
    end
    return cmap
end

# ----- Deformation (blue, yellow, red)
function brew_byr()
    cmap = [165 0 38;
        215 48 39;
        244 109 67;
        253 174 97;
        254 224 144;
        255 255 191;
        224 243 248;
        171 217 233;
        116 173 209;
        69 117 180;
        49 54 149]
    cmap_interp = hcat(
        interp(cmap[:, 1], 255),
        interp(cmap[:, 2], 255),
        interp(cmap[:, 3], 255)
    )
    return cmap_interp ./ 255.0
end

# ----- Amplitude (gray)
function brew_gray()
    vals = range(0.0, 1.0, length=256)
    return hcat(vals, vals, vals)
end
