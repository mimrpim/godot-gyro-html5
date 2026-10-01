extends Spatial



onready var head: = $Player/Head as Spatial
onready var left_eye_pos: = $Player/Head / LeftEyePos as Spatial
onready var right_eye_pos: = $Player/Head / RightEyePos as Spatial


onready var viewport_left: = $HUD / HBoxContainer / LeftContainer / ViewportLeft as Viewport
onready var viewport_right: = $HUD / HBoxContainer / RightContainer / ViewportRight as Viewport
onready var camera_left: = $HUD / HBoxContainer / LeftContainer / ViewportLeft / CameraLeft as Camera
onready var camera_right: = $HUD / HBoxContainer / RightContainer / ViewportRight / CameraRight as Camera

onready var gyro_component: = $GyroComponent as GyroComponent
onready var os_label: = $"%OSLabel" as Label3D
onready var gyro_label: = $"%GyroscopeLabel" as Label3D
onready var enable_gyro_btn: = $"%EnableGyroBtn" as CheckButton


var yaw_offset: float = 0.0
var is_calibrated: = false


export var screen_orientation_deg: = - 90.0


func _ready() -> void :
	enable_gyro_btn.hide()
	os_label.text = "OS: %s" % gyro_component.os_string
	if gyro_component.os_string == "iOS":
		enable_gyro_btn.show()

	
	var world_3d: = get_world()
	viewport_left.world = world_3d
	viewport_right.world = world_3d


func _process(_delta: float) -> void :
	
	camera_left.global_transform = left_eye_pos.global_transform
	camera_right.global_transform = right_eye_pos.global_transform


func _unhandled_input(event: InputEvent) -> void :
	
	if event is InputEventScreenTouch and event.pressed:
		recalibrate()


func recalibrate() -> void :
	is_calibrated = false


func _on_EnableGyro_toggled(button_pressed: bool) -> void :
	gyro_component.is_permission_asked = button_pressed


func _on_SensorComponent_gyroscope_triggered(coords: Vector3) -> void :
	gyro_label.text = "Gyro RAW: (%.1f, %.1f, %.1f)" % [coords.x, coords.y, coords.z]

	
	var device_quat: = _get_device_quaternion(coords.x, coords.y, coords.z)

	
	var euler: = device_quat.get_euler()
	if not is_calibrated:
		yaw_offset = euler.y
		is_calibrated = true

	
	var calibrated_quat: = Quat(Vector3.UP, - yaw_offset) * device_quat

	
	head.transform.basis = Basis(calibrated_quat)



func _get_device_quaternion(beta: float, gamma: float, alpha: float) -> Quat:
	var a: = deg2rad(alpha)
	var b: = deg2rad(beta)
	var g: = deg2rad(gamma)
	var s: = deg2rad(screen_orientation_deg)

	
	var q_alpha: = Quat(Vector3.UP, a)
	var q_beta: = Quat(Vector3.RIGHT, b)
	var q_gamma: = Quat(Vector3.FORWARD, g)

	var q_device: = q_alpha * q_beta * q_gamma

	
	var q_cam: = Quat(Vector3.RIGHT, deg2rad( - 90.0))
	var q_screen: = Quat(Vector3.FORWARD, s)

	return q_device * q_cam * q_screen


func _on_SensorComponent_ios_permission_requested(is_granted: bool) -> void :
	enable_gyro_btn.pressed = is_granted
	enable_gyro_btn.disabled = true
	recalibrate()
