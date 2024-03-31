# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2024 MizunagiKB <mizukb@live.jp>
extends Control


@export_node_path("GDMocopi") var mocopi_nodepath: NodePath


const ID_MENU_FILE_LOAD_PARAM: int = 1
const ID_MENU_FILE_SAVE_PARAM: int = 2

const ID_MENU_VIEW_CAMERA_RESET: int = 1
const ID_MENU_VIEW_SHOW_MODEL: int = 2
const ID_MENU_VIEW_SHOW_BONE_AXIS: int = 3


var show_panel_order: int = 0

signal show_panel_menu(show_order: int)
signal show_panel_status(show_order: int)
signal show_panel_param(show_order: int)
signal show_panel_anim(show_order: int)

signal menu_view_camera_reset()
signal menu_view_show_model(show_order: bool)
signal menu_view_show_bone_axis(show_order: bool)


func show_panel(show_order: bool):
    var tw = self.create_tween()
    tw.set_trans(Tween.TRANS_SINE)

    if show_order == true:
        tw.tween_property($panel_menu, "position", Vector2(88, 0), 0.5)
    else:
        tw.tween_property($panel_menu, "position", Vector2(88, -32), 0.5)


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
        ID_MENU_VIEW_CAMERA_RESET:
            menu_view_camera_reset.emit()

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


func _on_btn_show_panel_pressed():

    self.show_panel_order += 1

    if self.show_panel_order > 2:
        self.show_panel_order = 0

    match self.show_panel_order:
        0:
            show_panel_param.emit(true)
            show_panel_anim.emit(true)
            show_panel_menu.emit(true)
            show_panel_status.emit(true)

        1:
            show_panel_param.emit(false)
            show_panel_anim.emit(false)

        2:
            show_panel_param.emit(false)
            show_panel_anim.emit(false)
            show_panel_menu.emit(false)
            show_panel_status.emit(false)


func _on_spin_box_value_changed(value):
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi
    if o_mocopi == null: return

    o_mocopi.receive_port = $spin_listen_port.value
