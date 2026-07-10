# InSARViz.jl

## Overview
InSARViz.jl is a Julia package for visualizing InSAR data.

## Get started

### Clone the repository
Navigate to the desired directory and run:
```bash
git clone https://github.com/AlexLasalarie/InSARViz.jl <your-dirname>
```

### Install dependencies
Navigate to the newly created directory and run:
```bash
julia install_insarviz.jl
```

### Quick launch
To start a development session and auto-load the environment:
```bash
julia -i dev_startup.jl
```
This will load some useful development tools such as Revise, BenchmarkTools, 
etc., if installed in your base Julia environment.

### Manual launch
Start a Julia session:
```bash
julia
```
Enter Package mode by typing `]`:
```bash
pkg> activate .
```
Exit package mode by pressing Backspace and run:
```bash
julia> using InSARViz
```

## How to visualize your data?
The recipe for generating plots is two steps:
1. create a list of the files to plot using `make_list.jl`
2. call the appropriate function `plot_<data-type>.jl` based on the type of data
   you are trying to visualize

### Complete usage information
To find the complete information on how to use a specific function, please refer
to the Julia `Help` mode. In the REPL:
```bash
julia> ?
```
You can now see the documentation for any of the package functions:
```bash
help?> <function-name>
```
To exit `Help` mode, press `Backspace`.

### Making a list of images to plot
To create the list of files to process, run the following from the REPL:
```bash
julia> files = make_list(<path-to-dir>, <file-extension>)
```
Where, `<path-to-dir>` is the path to the directory that contains the data you
would like to plot, and `<file-extension>` is the file' extension (e.g. ".int").

### Wrapped interferograms
To save PNG images of the amplitude (`_amp.png`) and phase (`_phi.png`) to disk,
run:
```bash
julia> plot_wrp_igrams(files, wid, len)
```
Where `files` is the list of files to visualize, and `wid` and `len` are the
width and length of the wrapped interferograms (in pixels).

### Unwrapped interferograms
To save PNG images of the amplitude (`_amp.png`) and phase (`_psi.png`) to disk,
run:
```bash
julia> plot_unw_igrams(files, wid, len)
```
Where `files` is the list of files to visualize, and `wid` and `len` are the
width and length of the wrapped interferograms (in pixels).

### Surface deformation
To save PNG images of the amplitude (`_amp.png`) and deformation (`_def.png`) to
disk, run:
```bash
julia> plot_deformations(files, wid, len, min_def, max_def)
```
Where `files` is the list of files to visualize, `wid` and `len` are the
width and length of the wrapped interferograms (in pixels), and `min_def` and
`max_def` are the minimum and maximum deformations.

### Coherence
