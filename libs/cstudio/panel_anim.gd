# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2024 MizunagiKB <mizukb@live.jp>
extends Control


@export_node_path("GDMocopi") var mocopi_nodepath: NodePath


signal anim_lib_reseted()
signal anim_selected(animation: String)


var anim_lib: AnimationLibrary = AnimationLibrary.new()
var take_counter: int = 1


func anim_append(anim: Animation):
    var take_name: String = "Take #%d" % [self.take_counter]
    self.anim_lib.add_animation(take_name, anim)

    var root: TreeItem = $panel_take_lib/tree_take.get_root()
    var item: TreeItem = root.create_child()
    item.set_text_alignment(1, HORIZONTAL_ALIGNMENT_RIGHT)
    item.set_text(0, take_name)
    item.set_text(1, "%.3f" % [anim.length])

    self.take_counter += 1


func anim_remove():
    pass


func anim_reset():
    anim_lib_reseted.emit()

    $panel_take_lib/tree_take.clear()
    $panel_take_lib/tree_take.columns = 2
    $panel_take_lib/tree_take.set_column_title(0, "Name")
    $panel_take_lib/tree_take.set_column_custom_minimum_width(0, 128)
    $panel_take_lib/tree_take.set_column_title(1, "Length")
    $panel_take_lib/tree_take.create_item()
    $panel_take_lib/tree_take.hide_root = true

    for anim_name in anim_lib.get_animation_list():
        self.anim_lib.remove_animation(anim_name)


func show_panel(show_order: bool):
    var tw = self.create_tween()
    tw.set_trans(Tween.TRANS_SINE)

    var vct: Vector2i = DisplayServer.window_get_size()

    if show_order == true:
        tw.tween_property(self, "position", Vector2(vct.x, 0), 0.5)
    else:
        tw.tween_property(self, "position", Vector2(vct.x + 384, 0), 0.5)


func _ready():
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi
    if o_mocopi != null:
        $panel_preview/SubViewportContainer/SubViewport/preview_axis_mocopi.mocopi_nodepath = o_mocopi.get_path()

    self.anim_reset()
    


func _process(_delta):
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi
    if o_mocopi == null: return


func _on_tree_take_gui_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_RIGHT:
            $PopupMenu.position = event.global_position
            $PopupMenu.show()
            accept_event()


func _on_file_dialog_file_selected(path):
    
    ResourceSaver.save(self.anim_lib, path)


func _on_tree_take_item_selected():
    var item: TreeItem = $panel_take_lib/tree_take.get_selected()
    if item != null:
        var animation: String = item.get_text(0)
        anim_selected.emit("Takes/" + animation)


func _on_btn_export_pressed():
    $FileDialog.filters = ["*.res;Animation Resource"]
    $FileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
    $FileDialog.show()


func _on_btn_trash_pressed():
    self.anim_reset()


func _on_popup_menu_id_pressed(_id):
    pass
