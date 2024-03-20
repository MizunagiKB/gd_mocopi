extends Node3D


func _ready():

    $ui/list_bone.clear()
    for bone_name in GDMocopi.DEFAULT_MOCOPI_REMAP.keys():
        $ui/list_bone.add_item(bone_name)


func _process(_delta):

    $ui/lbl_bndt_count.text = str($GDMocopi.bndt_count)
    $ui/lbl_btdt_count.text = str($GDMocopi.btdt_count)
    $ui/lbl_time.text = "%.3f" % [$GDMocopi.time]
    
    $ui/chk_preview_axis_mocopi.button_pressed = $PreviewAxisMocopi.visible
    $ui/chk_preview_axis_vrm.button_pressed = $PreviewAxisVRM.visible

    if Input.is_action_pressed("ui_home"):
        pass
    elif Input.is_action_pressed("ui_left"):
        $Node3D.rotate_y(+0.05)
        $root_mocopi.rotate_y(+0.05)
    elif Input.is_action_pressed("ui_right"):
        $Node3D.rotate_y(-0.05)
        $root_mocopi.rotate_y(-0.05)

    if $GDMocopi.valid:
        $PreviewAxisMocopi.preview($GDMocopi)
        $PreviewAxisVRM.preview($GDMocopi)


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
        $ui/chk_listen.text = "Listen(%d)" % [$GDMocopi.receive_port]
        $GDMocopi.listen()
    else:
        $GDMocopi.stop()


func _on_chk_preview_axis_mocopi_toggled(button_pressed):
    $PreviewAxisMocopi.visible = button_pressed


func _on_chk_preview_axis_vrm_toggled(button_pressed):
    $PreviewAxisVRM.visible = button_pressed
