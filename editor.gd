extends Node3D


var axis = load("res://libs/gd_mocopi/axis.tscn")

var ary_bone_axis: Array[Node3D] = []
var ary_axis_vrm: Array[Node3D] = []
var ary_quat: Array[Quaternion] = []
var ary_vct3: Array[Vector3] = []
var dict_adjust: Dictionary

var mat: StandardMaterial3D


func preview_mocopi(ary_bndt: Array[GDMocopi.MocopiBndt], ary_btdt: Array[GDMocopi.MocopiBtdt]):

    var im: Mesh = $root_mocopi.mesh

    im.clear_surfaces()
    im.surface_begin(Mesh.PRIMITIVE_LINES, mat)

    for i in range(GDMocopi.MOCOPI_BONE_COUNT):
        var calc_quat: Quaternion
        var calc_vct3: Vector3

        var p_idx: int = ary_bndt[i].pbid

        if p_idx != -1:
            calc_quat = ary_quat[p_idx]
            calc_vct3 = ary_vct3[p_idx]
            pass

        calc_vct3 += (calc_quat * ary_btdt[i].vct3)

        ary_quat[i] = calc_quat * ary_btdt[i].quat
        ary_vct3[i] = calc_vct3

        var cube = ary_bone_axis[i]
        cube.quaternion = ary_quat[i]
        cube.position = ary_vct3[i]
        cube.scale = Vector3(0.075, 0.075, 0.075)
        cube.visible = true

        if p_idx != -1:
            var vctTo = ary_bone_axis[i].position
            var vctFr = ary_bone_axis[p_idx].position
            im.surface_add_vertex(vctTo)
            im.surface_add_vertex(vctFr)

    im.surface_end()


func preview_vrm():

    var skel: Skeleton3D = $Node3D/Reference/GeneralSkeleton
    
    if skel == null: return

    var im: Mesh = $root_vrm.mesh

    im.clear_surfaces()
    im.surface_begin(Mesh.PRIMITIVE_LINES, mat)

    var n: int = 0
    for bone_name in $GDMocopi.dict_remap.keys():
        var bone_index: int = skel.find_bone(bone_name)
        if bone_index == -1: continue

        var tf: Transform3D = skel.get_bone_global_pose(bone_index)
        var quat: Quaternion = Quaternion(tf.basis)

        ary_axis_vrm[n].basis = tf.basis
        ary_axis_vrm[n].position = tf.origin
        ary_axis_vrm[n].scale = Vector3(0.075, 0.075, 0.075)
        ary_axis_vrm[n].visible = true

        var p_idx: int = skel.get_bone_parent(bone_index)
        if n != 0:
            var vctTo = skel.get_bone_global_pose(bone_index).origin
            var vctFr = skel.get_bone_global_pose(p_idx).origin
            im.surface_add_vertex(vctTo)
            im.surface_add_vertex(vctFr)

        n += 1

    im.surface_end()


func _ready():

    # for mocopi
    ary_bone_axis.clear()
    for i in range(GDMocopi.MOCOPI_BONE_COUNT):
        var o = axis.instantiate()
        o.visible = false
        $root_mocopi.add_child(o)
        
        ary_bone_axis.push_back(o)
        ary_quat.push_back(Quaternion())
        ary_vct3.push_back(Vector3())

    $root_mocopi.mesh = ImmediateMesh.new()

    # for VRM
    ary_axis_vrm.clear()
    for i in range(GDMocopi.DEFAULT_MOCOPI_REMAP.size()):
        var o = axis.instantiate()
        o.visible = false
        $root_vrm.add_child(o)

        ary_axis_vrm.push_back(o)

    $root_vrm.mesh = ImmediateMesh.new()

    mat = StandardMaterial3D.new()
    mat.albedo_color = Color.GREEN

    $ui/list_bone.clear()
    for bone_name in GDMocopi.DEFAULT_MOCOPI_REMAP.keys():
        $ui/list_bone.add_item(bone_name)


func _process(_delta):

    $ui/lbl_bndt_count.text = str($GDMocopi.bndt_count)
    $ui/lbl_btdt_count.text = str($GDMocopi.btdt_count)
    $ui/lbl_time.text = "%.3f" % [$GDMocopi.time]

    if $GDMocopi.valid:
        preview_mocopi($GDMocopi.ary_bndt, $GDMocopi.ary_btdt)
        preview_vrm()


    if Input.is_action_pressed("ui_home"):
        pass
    elif Input.is_action_pressed("ui_left"):
        $Node3D.rotate_y(+0.05)
        $root_mocopi.rotate_y(+0.05)
    elif Input.is_action_pressed("ui_right"):
        $Node3D.rotate_y(-0.05)
        $root_mocopi.rotate_y(-0.05)


func _on_btn_load_pressed():
    $FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
    $FileDialog.show()


func _on_btn_save_pressed():
    $FileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
    $FileDialog.show()


func _on_file_dialog_confirmed():
    match $FileDialog.file_mode:
        FileDialog.FILE_MODE_OPEN_FILE:
            $GDMocopi.json_load($FileDialog.current_path)
        FileDialog.FILE_MODE_SAVE_FILE:
            $GDMocopi.json_save($FileDialog.current_path)


func _on_x_value_changed(value):
    for index in $ui/list_bone.get_selected_items():
        var bone_name: String = $ui/list_bone.get_item_text(index)
        var param = $GDMocopi.dict_param[bone_name]
        $ui/x/lineedit.text = str(value)
        param.x = value
        break


func _on_y_value_changed(value):
    for index in $ui/list_bone.get_selected_items():
        var bone_name: String = $ui/list_bone.get_item_text(index)
        var param = $GDMocopi.dict_param[bone_name]
        $ui/y/lineedit.text = str(value)
        param.y = value
        break


func _on_z_value_changed(value):
    for index in $ui/list_bone.get_selected_items():
        var bone_name: String = $ui/list_bone.get_item_text(index)
        var param = $GDMocopi.dict_param[bone_name]
        $ui/z/lineedit.text = str(value)
        param.z = value
        break


func _on_item_list_item_selected(index):
    var bone_name: String = $ui/list_bone.get_item_text(index)
    var param = $GDMocopi.dict_param[bone_name]
    
    $ui/x.value = param.x
    $ui/x/lineedit.text = str(param.x)
    $ui/x/x_check.button_pressed = param.inv_x == -1
    $ui/y.value = param.y
    $ui/y/lineedit.text = str(param.y)
    $ui/y/y_check.button_pressed = param.inv_y == -1
    $ui/z.value = param.z
    $ui/z/lineedit.text = str(param.z)
    $ui/z/z_check.button_pressed = param.inv_z == -1

    $ui/line_order.text = param.order
    $ui/chk_on.button_pressed = param.on


func _on_x_check_toggled(toggled_on):
    for index in $ui/list_bone.get_selected_items():
        var bone_name: String = $ui/list_bone.get_item_text(index)
        var param = $GDMocopi.dict_param[bone_name]
        if toggled_on == true:
            param.inv_x = -1
        else:
            param.inv_x = 1


func _on_y_check_toggled(toggled_on):
    for index in $ui/list_bone.get_selected_items():
        var bone_name: String = $ui/list_bone.get_item_text(index)
        var param = $GDMocopi.dict_param[bone_name]
        if toggled_on == true:
            param.inv_y = -1
        else:
            param.inv_y = 1


func _on_z_check_toggled(toggled_on):
    for index in $ui/list_bone.get_selected_items():
        var bone_name: String = $ui/list_bone.get_item_text(index)
        var param = $GDMocopi.dict_param[bone_name]
        if toggled_on == true:
            param.inv_z = -1
        else:
            param.inv_z = 1


func _on_line_order_text_changed(new_text: String):
    if new_text.to_upper() in ["XYZ", "XZY", "YXZ", "YZX", "ZXY", "ZYX"]:
        for index in $ui/list_bone.get_selected_items():
            var bone_name: String = $ui/list_bone.get_item_text(index)
            var param = $GDMocopi.dict_param[bone_name]
            param.order = new_text


func _on_chk_on_toggled(toggled_on):
    for index in $ui/list_bone.get_selected_items():
        var bone_name: String = $ui/list_bone.get_item_text(index)
        var param = $GDMocopi.dict_param[bone_name]
        param.on = toggled_on


func _on_chk_listen_toggled(toggled_on):
    if toggled_on == true:
        $GDMocopi.listen()
    else:
        $GDMocopi.stop()
