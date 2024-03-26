extends Control

const CAM_ANGLE_MIN: float = -60.0
const CAM_ANGLE_MAX: float = 60.0
const CAM_DISTANCE_MIN: float = 1.0
const CAM_DISTANCE_MAX: float = 10.0
const ANIMATION_LIB_NAME: String = "Tales"

var vct_camera_rot: Vector3 = Vector3.ZERO

var mb_m: bool = false
var kb_shift: bool = false


func _ready():

    get_window().min_size = Vector2i(960, 480)

    $ui/panel_status.anim_create.connect($ui/panel_anim.anim_append)
    $ui/panel_status/AnimationPlayer.add_animation_library(ANIMATION_LIB_NAME, $ui/panel_anim.anim_lib)

    $ui/panel_anim.anim_selected.connect($ui/panel_status.anim_play)
    $ui/panel_anim.anim_lib_reseted.connect($ui/panel_status.anim_reset)

    $ui/panel_menu.show_panel.connect($ui/panel_param.show_panel)
    $ui/panel_menu.show_panel.connect($ui/panel_anim.show_panel)


func _input(event):

    var slide_x: float = 0.0
    var slide_y: float = 0.0

    if event is InputEventKey:
        if event.keycode == KEY_SHIFT:
            self.kb_shift = event.pressed

    elif event is InputEventMouseButton:
        match event.button_index:
            MOUSE_BUTTON_MIDDLE:
                self.mb_m = event.is_pressed()
            MOUSE_BUTTON_WHEEL_UP:
                $scene/cam_target/cam.position.z = clamp(
                    $scene/cam_target/cam.position.z - 0.2,
                    CAM_DISTANCE_MIN, CAM_DISTANCE_MAX
                )
            MOUSE_BUTTON_WHEEL_DOWN:
                $scene/cam_target/cam.position.z = clamp(
                    $scene/cam_target/cam.position.z + 0.2,
                    CAM_DISTANCE_MIN, CAM_DISTANCE_MAX
                )

    elif event is InputEventMouseMotion:
        if self.mb_m == true:
            if self.kb_shift == true:
                slide_x = event.relative.x * -0.01
                slide_y = event.relative.y * 0.01
            else:
                self.vct_camera_rot.x -= (event.relative.x)
                self.vct_camera_rot.y -= (event.relative.y)
                self.vct_camera_rot.y = clamp(
                    self.vct_camera_rot.y - event.relative.y,
                    CAM_ANGLE_MIN,
                    CAM_ANGLE_MAX
                )

                var basis: Basis = Basis()
                basis = basis.rotated(Vector3(1, 0, 0), deg_to_rad(self.vct_camera_rot.y))
                basis = basis.rotated(Vector3(0, 1, 0), deg_to_rad(self.vct_camera_rot.x))
                $scene/cam_target.basis = basis

    var vct_forward = ($scene/cam_target.global_position - $scene/cam_target/cam.global_position).normalized()
    var vct_slide = vct_forward.cross(Vector3.UP).normalized()

    $scene/cam_target.position += vct_slide * slide_x
    $scene/cam_target.position += Vector3.UP * slide_y


func _process(_delta):
    $scene/preview_axis_vrm.visible = $ui/panel_menu/btn_show_bone.button_pressed
    $"scene/RAYNOS-chan_1_0_2".visible = !$ui/panel_menu/btn_show_bone.button_pressed
