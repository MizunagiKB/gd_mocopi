# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2024 MizunagiKB <mizukb@live.jp>
extends MeshInstance3D
class_name PreviewAxisMocopi


@export var mat: StandardMaterial3D
@export var axis_scale: Vector3 = Vector3(1.0, 1.0, 1.0)
@export_node_path("GDMocopi") var mocopi_nodepath: NodePath


var axis = load("res://libs/gd_mocopi/axis.tscn")


var ary_axis: Array[Node3D] = []
var ary_quat: Array[Quaternion] = []
var ary_vct3: Array[Vector3] = []


func preview(o_mocopi: GDMocopi):

    var im: Mesh = self.mesh

    im.clear_surfaces()

    if o_mocopi == null: return
    if o_mocopi.valid != true: return

    im.surface_begin(Mesh.PRIMITIVE_LINES, mat)

    for i in range(GDMocopi.MOCOPI_BONE_COUNT):
        var calc_quat: Quaternion
        var calc_vct3: Vector3

        var p_idx: int = o_mocopi.ary_bndt[i].pbid

        if p_idx != -1:
            calc_quat = ary_quat[p_idx]
            calc_vct3 = ary_vct3[p_idx]

        calc_vct3 += (calc_quat * o_mocopi.ary_btdt[i].vct3)

        ary_quat[i] = calc_quat * o_mocopi.ary_btdt[i].quat
        ary_vct3[i] = calc_vct3

        var cube = ary_axis[i]
        cube.quaternion = ary_quat[i]
        cube.position = ary_vct3[i]
        cube.scale = axis_scale
        cube.visible = true

        if p_idx != -1:
            var vctTo = ary_axis[i].position
            var vctFr = ary_axis[p_idx].position
            im.surface_add_vertex(vctTo)
            im.surface_add_vertex(vctFr)

    im.surface_end()


func _ready():

    ary_axis.clear()

    for i in range(GDMocopi.MOCOPI_BONE_COUNT):
        var o = axis.instantiate()
        o.visible = false
        self.add_child(o)

        ary_axis.push_back(o)
        ary_quat.push_back(Quaternion())
        ary_vct3.push_back(Vector3())

    self.mesh = ImmediateMesh.new()


func _process(_delta):
    if self.visible == false: return
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi
    self.preview(o_mocopi)
