extends Panel


@export_node_path("GDMocopi") var mocopi_nodepath: NodePath


var record_on = load("res://res/icon/video-solid.svg")
var record_of = load("res://res/icon/clapperboard-solid.svg")
var play_on = load("res://res/icon/play-solid.svg")
var play_of = load("res://res/icon/pause-solid.svg")
var anim: Animation
var anim_record_time: float



signal anim_create(anim: Animation)


func anim_play(animation: String):

    $AnimationPlayer.play("VRM/" + animation)
    var anim: Animation = $AnimationPlayer.get_animation("VRM/" + animation)
    $hs_timeline.min_value = 0.0
    $hs_timeline.max_value = anim.length
    $hs_timeline.value = 0
    $hs_timeline.visible = true
    $AnimationPlayer.stop()

    $btn_play.icon = play_on
    $btn_play.button_pressed = false
    $btn_play.disabled = false



func anim_reset():
    $AnimationPlayer.current_animation = ""
    $AnimationPlayer.stop()
    $AnimationPlayer.clear_caches()
    $AnimationPlayer.clear_queue()

    $hs_timeline.min_value = 0.0
    $hs_timeline.max_value = 0.0
    $hs_timeline.value = 1.0
    $hs_timeline.visible = false

    $btn_play.icon = play_on
    $btn_play.button_pressed = false
    $btn_play.disabled = true


func _ready():
    self.anim_reset()


func _process(_delta):
    var o_mocopi: GDMocopi = get_node(mocopi_nodepath) as GDMocopi

    if o_mocopi == null:
        $btn_record.disabled = true
    else:
        $btn_record.disabled = !o_mocopi.valid

    if $btn_record.button_pressed == true:
        $lbl_position.text = "%.3f" % [self.anim.length]
    elif $btn_play.button_pressed == true:
        $lbl_position.text = "%.3f / %.3f" % [$AnimationPlayer.current_animation_position, $AnimationPlayer.current_animation_length]
        $hs_timeline.value = $AnimationPlayer.current_animation_position
    else:
        $lbl_position.text = "0.000"


func _on_vrm_pose_update(time: float, ary_vrm_pose: Array[GDMocopi.VRMPose]):

    if self.anim.get_track_count() == 0:
        self.anim_record_time = time
        for o_pose in ary_vrm_pose:
            var track: int
            if o_pose.pbid == -1:
                track = self.anim.add_track(Animation.TYPE_POSITION_3D)
                self.anim.track_set_path(track, ":" + o_pose.bone_name)
            track = self.anim.add_track(Animation.TYPE_ROTATION_3D)
            self.anim.track_set_path(track, ":" + o_pose.bone_name)

    for o_pose in ary_vrm_pose:
        var track: int
        if o_pose.pbid == -1:
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
            self.anim = Animation.new()
            self.anim_record_time = 0.0
            o_mocopi.vrm_pose_update.connect(_on_vrm_pose_update)
    else:
        $btn_record.icon = record_on
        if o_mocopi.vrm_pose_update.is_connected(_on_vrm_pose_update) == true:
            o_mocopi.vrm_pose_update.disconnect(_on_vrm_pose_update)

            anim_create.emit(self.anim)
