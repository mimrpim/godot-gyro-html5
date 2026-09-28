extends Spatial

# Citlivost / vyhlazení pohybu kamery
export(float, 0.01, 1.0) var smoothing: float = 0.25

onready var camera := $Camera as Camera
onready var gyro_component := $GyroComponent as GyroComponent
onready var os_label := $"%OSLabel" as Label
onready var gyro_label := $"%GyroscopeLabel" as Label
onready var enable_gyro_btn := $"%EnableGyroBtn" as CheckButton


func _ready() -> void:
	enable_gyro_btn.hide()
	os_label.text = "OS: %s" % gyro_component.os_string
	if gyro_component.os_string == "iOS":
		enable_gyro_btn.show()


func _on_EnableGyro_toggled(button_pressed: bool) -> void:
	gyro_component.is_permission_asked = button_pressed


func _on_SensorComponent_gyroscope_triggered(coords: Vector3) -> void:
	# Zobrazení údajů v HUD
	var text := "(%.2f, %.2f, %.2f)" % [coords.x, coords.y, coords.z]
	gyro_label.text = "Gyroscope: %s" % text

	# Převod stupňů z gyroskopu na radiány pro 3D rotaci
	# coords.x = beta (Pitch -> rotace osy X)
	# coords.z = alpha (Yaw -> rotace osy Y)
	# coords.y = gamma (Roll -> rotace osy Z)
	var target_pitch: float = deg2rad(coords.x)
	var target_yaw: float = deg2rad(-coords.z)
	var target_roll: float = deg2rad(-coords.y)

	# Aplikace plynulého pohybu na kameru
	camera.rotation.x = lerp_angle(camera.rotation.x, target_pitch, smoothing)
	camera.rotation.y = lerp_angle(camera.rotation.y, target_yaw, smoothing)
	camera.rotation.z = lerp_angle(camera.rotation.z, target_roll, smoothing)


func _on_SensorComponent_ios_permission_requested(is_granted: bool) -> void:
	enable_gyro_btn.pressed = is_granted
	enable_gyro_btn.disabled = true
