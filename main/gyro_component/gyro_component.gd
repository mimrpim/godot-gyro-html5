






class_name GyroComponent
extends Node


signal ios_permission_requested(is_granted)
signal gyroscope_triggered(coords)

var window = JavaScript.get_interface("window")
var console = JavaScript.get_interface("console")
var handleOrientation = JavaScript.create_callback(self, "_handle_orientation")
var iosHandleOrientation = JavaScript.create_callback(self, "_ios_handle_orientation")

var is_permission_asked: = false setget _set_is_permission_asked
var os_string: String


func _ready() -> void :
	if OS.has_feature("JavaScript"):
		os_string = _get_os()
		
		if os_string == "Android":
			window.addEventListener("deviceorientation", handleOrientation)
	else:
		print("Not running on HTML5 platform")


func _get_os() -> String:
	return JavaScript.eval("""
		// https://dev.to/vaibhavkhulbe/get-os-details-from-the-webpage-in-javascript-b07
		function getOS() {
			var userAgent = window.navigator.userAgent,
			platform = window.navigator.platform,
			iosPlatforms = ['iPhone', 'iPad', 'iPod'],
			os = 'unknown';
			if (iosPlatforms.indexOf(platform) !== -1) {
				os = 'iOS';
			} else if (/Android/.test(userAgent)) {
				os = 'Android';
			}
			return os;
		}
		getOS();
	""")



func _handle_orientation(args: Array) -> void :
	var event = args[0]
	if event != null:
		var coords: = Vector3(event.beta, event.gamma, event.alpha)
		emit_signal("gyroscope_triggered", coords)
	else:
		print("Couldn't get event data!")






func _set_is_permission_asked(value: bool) -> void :
	is_permission_asked = value
	if value:
		var devicemotionevent = JavaScript.get_interface("DeviceMotionEvent")
		devicemotionevent.requestPermission().then(iosHandleOrientation).\
		catch(console.error)





func _ios_handle_orientation(args: Array) -> void :
	var state = args[0]
	if state == "granted":
		window.addEventListener("deviceorientation", handleOrientation)
	else:
		print("Request to access the orientation was rejected")
	emit_signal("ios_permission_requested", state == "granted")
