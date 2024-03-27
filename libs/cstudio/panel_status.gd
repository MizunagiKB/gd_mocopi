# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2024 MizunagiKB <mizukb@live.jp>
extends Panel


@export_node_path("GDMocopi") var mocopi_nodepath: NodePath


var record_on = load("res://libs/cstudio/res/icon/video-solid.svg")
var record_of = load("res://libs/cstudio/res/icon/clapperboard-solid.svg")
var play_on = load("res://libs/cstudio/res/icon/play-solid.svg")
var play_of = load("res://libs/cstudio/res/icon/pause-solid.svg")
var anim: Animation
var anim_record_time: float


signal anim_create(anim: Animation)


func anim_select(anim_name: String):
    $AnimationPlayer.play(anim_name)
    self.anim = $AnimationPlayer.get_animation(anim_name)
    $AnimationPlayer.stop()

    $hs_timeline.min_value = 0.0
    $hs_timeline.max_value = self.anim.length
    $hs_timeline.value = 0

    $btn_play.button_pressed = false
    $btn_play.disabled = false


func anim_reset():
    if $AnimationPlayer.is_playing() == true:
        $AnimationPlayer.stop()

    self.anim = Animation.new()
    self.anim_record_time = 0.0

    $hs_timeline.min_value = 0.0
    $hs_timeline.max_value = 0.0
    $hs_timeline.value = 0

    $btn_play.button_pressed = false
    $btn_play.disabled = true


func _ready():
    self.anim_reset()


func _process(_delta):
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi

    var anim_pos: float = 0.0

    if o_mocopi == null:
        $btn_record.disabled = true
    else:
        $btn_record.disabled = !o_mocopi.valid

    if $AnimationPlayer.assigned_animation != "":
        if $btn_play.button_pressed == true:
            anim_pos = $AnimationPlayer.current_animation_position
            $hs_timeline.value = anim_pos

    $lbl_position.text = "%.3f / %.3f" % [anim_pos, self.anim.length]


func _gui_input(_event):
    accept_event()


func _on_vrm_pose_update(time: float, ary_vrm_pose: Array[GDMocopi.VRMPose]):

    if self.anim.get_track_count() == 0:
        self.anim_record_time = time
        for o_pose in ary_vrm_pose:
            var track: int
            if o_pose.bnid == GDMocopi.E_MOCOPI_BONE.root:
                track = self.anim.add_track(Animation.TYPE_POSITION_3D)
                self.anim.track_set_path(track, ":" + o_pose.bone_name)
            track = self.anim.add_track(Animation.TYPE_ROTATION_3D)
            self.anim.track_set_path(track, ":" + o_pose.bone_name)

    for o_pose in ary_vrm_pose:
        var track: int
        if o_pose.bnid == GDMocopi.E_MOCOPI_BONE.root:
            track = self.anim.find_track(":" + o_pose.bone_name, Animation.TYPE_POSITION_3D)
            self.anim.track_insert_key(track, time - self.anim_record_time, o_pose.position)
        track = self.anim.find_track(":" + o_pose.bone_name, Animation.TYPE_ROTATION_3D)
        self.anim.track_insert_key(track, time - self.anim_record_time, o_pose.quaternion)

    self.anim.length = time - self.anim_record_time


func _on_btn_play_toggled(button_pressed):
    if button_pressed == true:
        $btn_play.icon = play_of
        $AnimationPlayer.play()
        $hs_timeline.min_value = 0.0
        $hs_timeline.max_value = $AnimationPlayer.current_animation_length
    else:
        $btn_play.icon = play_on
        $AnimationPlayer.pause()


func _on_hs_timeline_value_changed(value):
    $AnimationPlayer.seek(value, true)


func _on_btn_record_toggled(button_pressed):
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi
    if o_mocopi == null: return

    if button_pressed == true:
        $btn_record.icon = record_of
        if o_mocopi.vrm_pose_update.is_connected(_on_vrm_pose_update) == false:
            self.anim_reset()
            o_mocopi.vrm_pose_update.connect(_on_vrm_pose_update)
    else:
        $btn_record.icon = record_on
        if o_mocopi.vrm_pose_update.is_connected(_on_vrm_pose_update) == true:
            o_mocopi.vrm_pose_update.disconnect(_on_vrm_pose_update)

            anim_create.emit(self.anim)


func _on_animation_player_animation_finished(_anim_name):
    $btn_play.button_pressed = false
