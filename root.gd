extends Control


@onready var lines: Node2D = $Line2D
@onready var fileMenu: PopupMenu = $GUI/MenuBar/File
@onready var fileDialog: FileDialog = $FileDialog
@onready var camera: Camera2D = $Camera2D
@onready var playerWindow: Window = $PlayerWindow
@onready var fog = $Fog
@onready var fog2 = $PlayerWindow/Fog
@onready var backgroundNode = $BackgroundNode
@onready var background = $BackgroundNode/Background

const LightTexture = preload('res://Light.png')
const DarkTexture = preload('res://Dark.png')
const GrayTexture = preload('res://Gray.png')

var blendImageHeight : int = 50
var blendImageWidth : int = 50

var modHeld : bool = false



var imgHeight : int
var imgWidth : int

var fogImage : Image
var fogTexture : ImageTexture

var fogImage2 : Image
var fogTexture2 : ImageTexture

var lightImage : Image
var darkImage : Image
var grayImage : Image


var blendRect : Rect2

var offset : Vector2

var pressed: bool = false
var pressed2: bool = false
var current_line: Line2D = null


var WIDTH: int = 10
var COLOR = Color.BLUE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fileMenu.connect('id_pressed', _on_file_id_pressed)
	fileDialog.add_filter("*.png, *.jpg, *.jpeg", "Images")
	fileDialog.popup()
	# playerWindow.world_2d = get_window().world_2d


	lightImage = LightTexture.get_image()
	lightImage.resize(blendImageHeight, blendImageWidth)
	lightImage.convert(Image.FORMAT_RGBAH)

	darkImage = DarkTexture.get_image()
	darkImage.resize(blendImageHeight, blendImageWidth)
	darkImage.convert(Image.FORMAT_RGBAH)

	grayImage = GrayTexture.get_image()
	grayImage.resize(blendImageHeight, blendImageWidth)
	grayImage.convert(Image.FORMAT_RGBAH)

	blendRect = Rect2(Vector2.ZERO, lightImage.get_size())


func update_fog(pos, erase: bool = false):
	lightImage.resize(blendImageHeight, blendImageWidth)
	darkImage.resize(blendImageHeight, blendImageWidth)
	grayImage.resize(blendImageHeight, blendImageWidth)
	offset = Vector2(blendImageWidth / 2, blendImageHeight / 2) - Vector2(imgWidth / 2, imgHeight / 2)
	blendRect = Rect2(Vector2.ZERO, lightImage.get_size())

	if not erase:
		fogImage.blend_rect(lightImage, blendRect, pos - offset)
		fogTexture.update(fogImage)

		fogImage2.blend_rect(lightImage, blendRect, pos - offset)
		fogTexture2.update(fogImage2)

	if erase:
		fogImage.blend_rect(grayImage, blendRect, pos - offset)
		fogTexture.update(fogImage)

		fogImage2.blend_rect(darkImage, blendRect, pos - offset)
		fogTexture2.update(fogImage2)


func _process(_delta):
	if Input.is_action_pressed("quit"):
		get_tree().quit()

	queue_redraw()

func _input(event: InputEvent) -> void:

	if event.is_action_pressed('mod'):
		modHeld = true

	if event.is_action_released('mod'):
		modHeld = false

	if event.is_action_pressed('zoom_in') and modHeld:
		blendImageWidth = max(5, blendImageWidth - 5)
		blendImageHeight = max(5, blendImageHeight - 5)

	if event.is_action_pressed('zoom_out') and modHeld:
		blendImageWidth += 5
		blendImageHeight += 5

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			pressed = event.pressed

			if pressed:
				update_fog(get_global_mouse_position())

		if event.button_index == MOUSE_BUTTON_RIGHT:
			pressed2 = event.pressed

			if pressed:
				update_fog(get_global_mouse_position(), true)

	elif event is InputEventMouseMotion:
		if pressed:
			update_fog(get_global_mouse_position())
		elif pressed2:
			update_fog(get_global_mouse_position(), true)

func _draw() -> void:
	draw_arc(get_global_mouse_position(), blendImageWidth * 0.5, 0.0, 2 * 3.141592, 100, Color.WHITE)

func _on_file_id_pressed(id: int) -> void:
	if id == 0:
		fileDialog.popup()


func _on_file_dialog_file_selected(path:String) -> void:
	var image = Image.new()
	image.load(path)

	imgWidth = image.get_size()[0]
	imgHeight = image.get_size()[1]

	fogImage = Image.create(imgWidth, imgHeight, false, Image.FORMAT_RGBAH)
	fogImage.fill(Color(0.5, 0.5, 0.5, 1))
	fogTexture = ImageTexture.create_from_image(fogImage)
	fog.texture = fogTexture



	offset = Vector2(blendImageWidth / 2, blendImageHeight / 2) - Vector2(imgWidth / 2, imgHeight / 2)

	var image_texture = ImageTexture.new()
	image_texture.set_image(image)

	background.texture = image_texture
	backgroundNode.position = -Vector2(imgWidth / 2, imgHeight / 2)

	# second window stuff
	$PlayerWindow/PlayerRoot.add_child(backgroundNode.duplicate())

	fogImage2 = Image.create(imgWidth, imgHeight, false, Image.FORMAT_RGBAH)
	fogImage2.fill(Color(0, 0, 0, 1))
	fogTexture2 = ImageTexture.create_from_image(fogImage2)
	fog2.texture = fogTexture2
