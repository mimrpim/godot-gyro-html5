extends Spatial


onready var camera := $Camera as Camera
onready var gyro_component := $GyroComponent as GyroComponent
onready var os_label := $"%OSLabel" as Label
onready var gyro_label := $"%GyroscopeLabel" as Label
# iOS pouze
onready var enable_gyro_btn := $"%EnableGyroBtn" as CheckButton


func _ready() -> void:
	# Aktualizace UI
	enable_gyro_btn.hide()
	os_label.text = "OS: %s" % gyro_component.os_string
	if gyro_component.os_string == "iOS":
		enable_gyro_btn.show()


# Spuštění žádosti o oprávnění pro iOS
func _on_EnableGyro_toggled(button_pressed: bool) -> void:
	gyro_component.is_permission_asked = button_pressed


# Zpracování dat z gyroskopu a rotace kamery
func _on_SensorComponent_gyroscope_triggered(coords: Vector3) -> void:
	# Zobrazení textu na UI
	var text := "(%.2f, %.2f, %.2f)" % [coords.x, coords.y, coords.z]
	gyro_label.text = "Gyroscope: %s" % text

	# Mapování os z JavaScript DeviceOrientationEvent:
	# coords.x = beta  (-180 až 180, Pitch - naklánění dopředu/dozadu)
	# coords.y = gamma (-90 až 90,   Roll  - naklánění do stran)
	# coords.z = alpha (0 až 360,    Yaw   - otáčení dokola / kompas)
	
	var pitch := coords.x
	var roll := coords.y
	var yaw := coords.z

	# Nastavení rotace kamery ve stupních (v režimu na výšku / Portrait)
	# Pokud držíte telefon na šířku (Landscape), osy pro rotaci prohoďte: Vector3(-roll, -yaw, -pitch)
	camera.rotation_degrees = Vector3(-pitch, -yaw, roll)


# Aktualizace tlačítka na základě výsledu žádosti na iOS
func _on_SensorComponent_ios_permission_requested(is_granted: bool) -> void:
	enable_gyro_btn.pressed = is_granted
	enable_gyro_btn.disabled = true
