include("visualize.jl")

q = [[0.0, 0.5 + 0.5 * sin(1.0 * π * (t - 1) / 10.0), 0.0, 0.5] for t = 1:11]

vis = Visualizer()
render(vis)
visualize!(vis, q, 0.1)
