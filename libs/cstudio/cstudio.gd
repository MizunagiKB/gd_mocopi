extends Control


func _ready():

    $ui/panel_status.anim_create.connect($ui/panel_anim.anim_append)
    $ui/panel_status/AnimationPlayer.add_animation_library("VRM", $ui/panel_anim.anim_lib)

    $ui/panel_anim.anim_selected.connect($ui/panel_status.anim_play)
    $ui/panel_anim.anim_lib_reseted.connect($ui/panel_status.anim_reset)

    $ui/panel_menu.show_panel.connect($ui/panel_param.show_panel)
    $ui/panel_menu.show_panel.connect($ui/panel_anim.show_panel)



func _process(_delta):
    pass
