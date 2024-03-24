extends MeshInstance3D
class_name PreviewAxisVRM


@export var mat: StandardMaterial3D
@export var axis_scale: Vector3 = Vector3(1.0, 1.0, 1.0)
@export_node_path("GDMocopi") var mocopi_nodepath: NodePath


var axis = load("res://libs/gd_mocopi/axis.tscn")


var ary_axis: Array[Node3D] = []


func preview(o_mocopi: GDMocopi):

    var im: Mesh = self.mesh

    im.clear_surfaces()

    if o_mocopi == null: return
    if o_mocopi.valid != true: return

    im.surface_begin(Mesh.PRIMITIVE_LINES, mat)

    var skel: Skeleton3D = get_node(o_mocopi.skel_nodepath) as Skeleton3D
    
    if skel == null: return

    var n: int = 0
    for bone_name in o_mocopi.dict_param.keys():
        var bone_index: int = skel.find_bone(bone_name)
        if bone_index == -1: continue

        var tf: Transform3D = skel.get_bone_global_pose(bone_index)

        ary_axis[n].basis = tf.basis
        ary_axis[n].position = tf.origin
        ary_axis[n].scale = axis_scale
        ary_axis[n].visible = true

        var p_idx: int = skel.get_bone_parent(bone_index)
        if n != 0:
            var vctTo = skel.get_bone_global_pose(bone_index).origin
            var vctFr = skel.get_bone_global_pose(p_idx).origin
            im.surface_add_vertex(vctTo)
            im.surface_add_vertex(vctFr)

        n += 1

    im.surface_end()


func _ready():

    ary_axis.clear()

    for i in range(GDMocopi.DEFAULT_MOCOPI_PARAM.size()):
        var o = axis.instantiate()
        o.visible = false
        self.add_child(o)

        ary_axis.push_back(o)

    self.mesh = ImmediateMesh.new()


func _process(_delta):
    if self.visible == true:
        var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi
        self.preview(o_mocopi)
