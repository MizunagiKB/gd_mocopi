# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2024 MizunagiKB <mizukb@live.jp>
extends Control


@export_node_path("GDMocopi") var mocopi_nodepath: NodePath


const ID_MENU_FILE_LOAD_PARAM: int = 1
const ID_MENU_FILE_SAVE_PARAM: int = 2

const ID_MENU_VIEW_SHOW_MODEL: int = 1
const ID_MENU_VIEW_SHOW_BONE_AXIS: int = 2


signal show_panel(show_order: bool)
signal menu_view_show_model(show_order: bool)
signal menu_view_show_bone_axis(show_order: bool)


func _ready():
    var menu: PopupMenu

    menu = $panel_menu/menu/menu_file.get_popup()
    menu.id_pressed.connect(_on_popup_file_id_pressed)

    menu = $panel_menu/menu/menu_view.get_popup()
    menu.id_pressed.connect(_on_popup_view_id_pressed)


func _process(_delta):
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi

    #$btn_param_load.disabled = o_mocopi == null
    #$btn_param_save.disabled = o_mocopi == null
    $panel_menu/btn_listen.disabled = o_mocopi == null

    if o_mocopi == null: return

    $panel_menu/lbl_bndt/value.text = "%d" % [o_mocopi.bndt_count]
    $panel_menu/lbl_btdt/value.text = "%d" % [o_mocopi.btdt_count]
    $panel_menu/lbl_time/value.text = "%.3f" % [o_mocopi.time]


func _gui_input(_event):
    accept_event()


func _on_popup_file_id_pressed(id: int):
    
    match id:
        ID_MENU_FILE_LOAD_PARAM:
            $FileDialog.title = "Open GDMocopi Param"
            $FileDialog.filters = ["*.json;GDMocopi Param"]
            $FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
            $FileDialog.show()

        ID_MENU_FILE_SAVE_PARAM:
            $FileDialog.title = "Save GDMocopi Param"
            $FileDialog.filters = ["*.json;GDMocopi Param"]
            $FileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
            $FileDialog.show()


func _on_popup_view_id_pressed(id: int):
    var menu: PopupMenu = $panel_menu/menu/menu_view.get_popup()
    var index: int = menu.get_item_index(id)

    match id:
        ID_MENU_VIEW_SHOW_MODEL:
            var show_order: bool = menu.is_item_checked(index)
            menu.set_item_checked(index, !show_order)
            menu_view_show_model.emit(!show_order)

        ID_MENU_VIEW_SHOW_BONE_AXIS:
            var show_order: bool = menu.is_item_checked(index)
            menu.set_item_checked(index, !show_order)
            menu_view_show_bone_axis.emit(!show_order)


func _on_btn_listen_toggled(button_pressed):
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi
    if o_mocopi == null: return

    $panel_menu/spin_listen_port.editable = !button_pressed

    if button_pressed == true:
        $panel_menu/btn_listen.text = "Listening ..."
        o_mocopi.port = $panel_menu/spin_listen_port.value
        o_mocopi.listen()
    else:
        $panel_menu/btn_listen.text = "Listen"
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


func _on_btn_show_ui_toggled(button_pressed):
    show_panel.emit(button_pressed)


func _on_spin_box_value_changed(value):
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi
    if o_mocopi == null: return

    o_mocopi.receive_port = $spin_listen_port.value
