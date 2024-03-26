extends Control

const CAM_ANGLE_LIMIT_MIN: float = -60.0
const CAM_ANGLE_LIMIT_MAX: float = 60.0

var vct_camera_rot: Vector3 = Vector3.ZERO
var vct_camera_forward: Vector3 = Vector3.ZERO
var vct_camera_slide: Vector3 = Vector3.ZERO
var cam_distance: float = 4.0
var cam_height: float = 1.0

var cam_position: Vector3 = Vector3(0, 1, 4)
var cam_target: Vector3 = Vector3(0, 1, 0)

var mbutton_m: bool = false
var kb_shift: bool = false


func _ready():

    $ui/panel_status.anim_create.connect($ui/panel_anim.anim_append)
    $ui/panel_status/AnimationPlayer.add_animation_library("VRM", $ui/panel_anim.anim_lib)

    $ui/panel_anim.anim_selected.connect($ui/panel_status.anim_play)
    $ui/panel_anim.anim_lib_reseted.connect($ui/panel_status.anim_reset)

    $ui/panel_menu.show_panel.connect($ui/panel_param.show_panel)
    $ui/panel_menu.show_panel.connect($ui/panel_anim.show_panel)


func _input(event):
    var slide_x: float = 0.0
    var slide_y: float = 0.0

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_MIDDLE:
            self.mbutton_m = event.is_pressed()
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            self.cam_distance += 1
        elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
            self.cam_distance -= 1

    elif event is InputEventMouseMotion:
        if self.mbutton_m == true:
            if self.kb_shift == true:
                slide_x = event.relative.x * -0.01
                slide_y = event.relative.y * 0.01
            else:
                self.vct_camera_rot.x -= (event.relative.x * 1.0)
                self.vct_camera_rot.y -= (event.relative.y * 1.0)

    elif event is InputEventKey:
        if event.keycode == KEY_SHIFT:
            self.kb_shift = event.pressed

    self.vct_camera_rot.y = clamp(self.vct_camera_rot.y, CAM_ANGLE_LIMIT_MIN, CAM_ANGLE_LIMIT_MAX)
    self.cam_distance = clamp(self.cam_distance, 1, 10)

    var vct_rot = Vector3(0, cam_height, cam_distance)
    var vct_rot_H = vct_rot.rotated(Vector3(0, 1, 0), deg_to_rad(self.vct_camera_rot.x))

    var vct_forward = (Vector3.ZERO - vct_rot_H).normalized()
    var vct_slide = vct_forward.cross(Vector3.UP).normalized()

    vct_rot = vct_rot.rotated(Vector3(1, 0, 0), deg_to_rad(self.vct_camera_rot.y))
    vct_rot = vct_rot.rotated(Vector3(0, 1, 0), deg_to_rad(self.vct_camera_rot.x))

    self.cam_position += vct_slide * slide_x
    self.cam_position += Vector3.UP * slide_y
    self.cam_target += vct_slide * slide_x
    self.cam_target += Vector3.UP * slide_y

    $scene/cam.position = vct_rot
    $scene/cam.look_at(self.cam_target, Vector3.UP)
    

func _process(_delta):
    $scene/preview_axis_vrm.visible = $ui/panel_menu/btn_show_bone.button_pressed
    $scene/RAYNOS.visible = !$ui/panel_menu/btn_show_bone.button_pressed
