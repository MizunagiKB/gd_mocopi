extends Panel


@export_node_path("GDMocopi") var mocopi_nodepath: NodePath


func _ready():
    pass


func _process(_delta):
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi

    $btn_param_load.disabled = o_mocopi == null
    $btn_param_save.disabled = o_mocopi == null
    $btn_listen.disabled = o_mocopi == null

    if o_mocopi == null: return

    $lbl_bndt/value.text = "%d" % [o_mocopi.bndt_count]
    $lbl_btdt/value.text = "%d" % [o_mocopi.btdt_count]
    $lbl_time/value.text = "%.3f" % [o_mocopi.time]


func _on_btn_listen_toggled(button_pressed):
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi
    if o_mocopi == null: return

    if button_pressed == true:
        $btn_listen.text = "Listening ..."
        o_mocopi.listen()
    else:
        $btn_listen.text = "Listen"
        o_mocopi.stop()


func _on_btn_param_load_pressed():
    $FileDialog.title = "Open GDMocopi Param"
    $FileDialog.filters = ["*.json;GDMocopi Param"]
    $FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
    $FileDialog.show()


func _on_btn_param_save_pressed():
    $FileDialog.title = "Save GDMocopi Param"
    $FileDialog.filters = ["*.json;GDMocopi Param"]
    $FileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
    $FileDialog.show()


func _on_file_dialog_file_selected(path):
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi
    if o_mocopi == null: return

    match $FileDialog.file_mode:
        FileDialog.FILE_MODE_OPEN_FILE:
            o_mocopi.param_load(path)
        FileDialog.FILE_MODE_SAVE_FILE:
            o_mocopi.param_save(path)
