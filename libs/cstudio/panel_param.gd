extends Control


@export_node_path("GDMocopi") var mocopi_nodepath: NodePath


var bone_none = load("res://libs/cstudio/res/icon/person-solid-gray.svg")
var bone_rest = load("res://libs/cstudio/res/icon/person-solid.svg")
var bone_pose = load("res://libs/cstudio/res/icon/person-walking-solid.svg")
var current_bone_name: String


func show_panel(show_order: bool):
    var tw = self.create_tween()
    tw.set_trans(Tween.TRANS_SINE)
    if show_order == true:
        tw.tween_property(self, "position", Vector2(0, 0), 0.5)
    else:
        tw.tween_property(self, "position", Vector2(0 - 384, 0), 0.5)


func _ready():
    $panel_bone/opt_mocopi_bone.clear()
    for bone_name in GDMocopi.E_MOCOPI_BONE.keys():
        $panel_bone/opt_mocopi_bone.add_item(bone_name)

    $panel_bone/list_bone.clear()
    for bone_name in GDMocopi.DEFAULT_MOCOPI_PARAM.keys():
        $panel_bone/list_bone.add_item(bone_name)


func _process(_delta):
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi
    var ui_enable: bool = false

    if o_mocopi != null:
        ui_enable = !o_mocopi.dict_param.is_read_only()

    $panel_adjust/btn_x.disabled = !ui_enable
    $panel_adjust/btn_x/sli.editable = ui_enable
    $panel_adjust/btn_x/spin.editable = ui_enable

    $panel_adjust/btn_y.disabled = !ui_enable
    $panel_adjust/btn_y/sli.editable = ui_enable
    $panel_adjust/btn_y/spin.editable = ui_enable

    $panel_adjust/btn_z.disabled = !ui_enable
    $panel_adjust/btn_z/sli.editable = ui_enable
    $panel_adjust/btn_z/spin.editable = ui_enable
    
    $panel_bone/line_order.editable = ui_enable
    $panel_bone/btn_update.disabled = !ui_enable
    $panel_bone/opt_mocopi_bone.disabled = !ui_enable


func _on_ui_update():
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi

    if o_mocopi == null: return
    if self.current_bone_name.length() == 0: return

    var param: Dictionary = o_mocopi.dict_param[self.current_bone_name]

    if param.inv_x > 0:
        $panel_adjust/btn_x.text = "+X"
        $panel_adjust/btn_x.button_pressed = false
    else:
        $panel_adjust/btn_x.text = "-X"
        $panel_adjust/btn_x.button_pressed = true

    $panel_adjust/btn_x/sli.value = param.x
    $panel_adjust/btn_x/spin.value = param.x

    if param.inv_y > 0:
        $panel_adjust/btn_y.text = "+Y"
        $panel_adjust/btn_y.button_pressed = false
    else:
        $panel_adjust/btn_y.text = "-Y"
        $panel_adjust/btn_y.button_pressed = true

    $panel_adjust/btn_y/sli.value = param.y
    $panel_adjust/btn_y/spin.value = param.y

    if param.inv_z > 0:
        $panel_adjust/btn_z.text = "+Z"
        $panel_adjust/btn_z.button_pressed = false
    else:
        $panel_adjust/btn_z.text = "-Z"
        $panel_adjust/btn_z.button_pressed = true

    $panel_adjust/btn_z/sli.value = param.z
    $panel_adjust/btn_z/spin.value = param.z

    $panel_bone/line_order.text = param.order

    match int(param.update):
        GDMocopi.PARAM_UPDATE_NONE:
            $panel_bone/btn_update.icon = bone_none
        GDMocopi.PARAM_UPDATE_REST:
            $panel_bone/btn_update.icon = bone_rest
        GDMocopi.PARAM_UPDATE_POSE:
            $panel_bone/btn_update.icon = bone_pose

    $panel_bone/opt_mocopi_bone.select(param.index)


func _on_update(key: String, spin: SpinBox, value: int):
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi

    if o_mocopi == null: return
    if self.current_bone_name.length() == 0: return

    spin.value = value

    var param: Dictionary = o_mocopi.dict_param[self.current_bone_name]
    if param.is_read_only() != true:
        param[key] = value


func _on_sli_x_value_changed(value):
    self._on_update("x", $panel_adjust/btn_x/spin, value)

func _on_sli_y_value_changed(value):
    self._on_update("y", $panel_adjust/btn_y/spin, value)

func _on_sli_z_value_changed(value):
    self._on_update("z", $panel_adjust/btn_z/spin, value)


func _on_list_bone_item_selected(index):
    self.current_bone_name = $panel_bone/list_bone.get_item_text(index)
    _on_ui_update()


func _on_btn_update_pressed():
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi

    if o_mocopi == null: return
    if self.current_bone_name.length() == 0: return

    var param: Dictionary = o_mocopi.dict_param[self.current_bone_name]
    if param.is_read_only() == true: return

    print(param.update == GDMocopi.PARAM_UPDATE_POSE)
    match int(param.update):
        GDMocopi.PARAM_UPDATE_NONE:
            $panel_bone/btn_update.icon = bone_rest
            param.update = GDMocopi.PARAM_UPDATE_REST
        GDMocopi.PARAM_UPDATE_REST:
            $panel_bone/btn_update.icon = bone_pose
            param.update = GDMocopi.PARAM_UPDATE_POSE
        GDMocopi.PARAM_UPDATE_POSE:
            $panel_bone/btn_update.icon = bone_none
            param.update = GDMocopi.PARAM_UPDATE_NONE


func _on_line_order_text_changed(new_text):
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi

    if o_mocopi == null: return
    if self.current_bone_name.length() == 0: return

    var param: Dictionary = o_mocopi.dict_param[self.current_bone_name]
    if param.is_read_only() == true: return

    if new_text in ["XYZ", "XZY", "YXZ", "YZX", "ZXY", "ZYX"]:
        param.order = new_text


func _on_opt_mocopi_bone_item_selected(index):
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi

    if o_mocopi == null: return
    if self.current_bone_name.length() == 0: return

    var param: Dictionary = o_mocopi.dict_param[self.current_bone_name]
    if param.is_read_only() == true: return

    param.index = index
