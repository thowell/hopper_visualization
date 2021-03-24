using Colors
using CoordinateTransformations
using GeometryBasics
using MeshCat
using Rotations

"""
    Hopper
    	model inspired by "Dynamically Stable Legged Locomotion"
		s = (x, z, t, r)
			x - lateral position
			z - vertical position
			t - body orientation
			r - leg length
"""

# Kinematics
kinematics(q) = [q[1] + q[4] * sin(q[3]), q[2] - q[4] * cos(q[3])]
# kinematics(q) = [q[3], q[4]]

# Visualization
function visualize!(vis, q, Δt; fix_camera = true)

	# foot radius
    r_foot = 0.05

	# leg width
    r_leg = 0.5 * r_foot

	# set background to white
	setvisible!(vis["/Background"], true)
    setprop!(vis["/Background"], "top_color", RGBA(1.0, 1.0, 1.0, 1.0))
    setprop!(vis["/Background"], "bottom_color", RGBA(1.0, 1.0, 1.0, 1.0))
    setvisible!(vis["/Axes"], false)

	# create body
    setobject!(vis["body"], Sphere(Point3f0(0),
        convert(Float32, 0.1)),
        MeshPhongMaterial(color = RGBA(0, 1, 0, 1.0)))

	# create foot
    setobject!(vis["foot"], Sphere(Point3f0(0),
        convert(Float32, r_foot)),
        MeshPhongMaterial(color = RGBA(1.0, 165.0 / 255.0, 0, 1.0)))

	# create leg
    n_leg = 100
    for i = 1:n_leg
        setobject!(vis["leg$i"], Sphere(Point3f0(0),
            convert(Float32, r_leg)),
            MeshPhongMaterial(color = RGBA(0, 0, 0, 1.0)))
    end

    p_leg = [zeros(3) for i = 1:n_leg]

	# animation
    anim = MeshCat.Animation(convert(Int, floor(1.0 / Δt)))

    for t = 1:length(q)
        p_body = [q[t][1], 0.0, q[t][2]]
        p_foot = [kinematics(q[t])[1], 0.0, kinematics(q[t])[2]]

        q_tmp = Array(copy(q[t]))
        r_range = range(0, stop = q[t][4], length = n_leg)
        for i = 1:n_leg
            q_tmp[4] = r_range[i]
            p_leg[i] = [kinematics(q_tmp)[1], 0.0, kinematics(q_tmp)[2]]
        end
        q_tmp[4] = q[t][4]
        p_foot = [kinematics(q_tmp)[1], 0.0, kinematics(q_tmp)[2]]

        z_shift = [0.0; 0.0; r_foot]

        MeshCat.atframe(anim, t) do
            settransform!(vis["body"], Translation(p_body + z_shift))
            settransform!(vis["foot"], Translation(p_foot + z_shift))

            for i = 1:n_leg
                settransform!(vis["leg$i"], Translation(p_leg[i] + z_shift))
            end
        end
    end

	if fix_camera
		settransform!(vis["/Cameras/default"],
			compose(Translation(0.0, 0.5, -1.0), LinearMap(RotZ(-pi / 2.0))))
	end

    MeshCat.setanimation!(vis, anim)
end
