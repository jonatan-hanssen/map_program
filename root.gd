extends Control


@onready var lines: Node2D = $Line2D
@onready var fileMenu: PopupMenu = $GUI/MenuBar/File
@onready var fileDialog: FileDialog = $FileDialog
@onready var camera: Camera2D = $Camera2D
@onready var playerWindow: Window = $PlayerWindow
@onready var fog = $Fog
@onready var background = $Background

const LightTexture = preload('res://Light.png')
const DarkTexture = preload('res://Dark.png')

const lightHeight : int = 50
const lightWidth : int = 50

const fogHeight : int = 800
const fogWidth : int = 800

var fogImage : Image
var fogTexture : ImageTexture

var lightImage : Image
var darkImage : Image
var lightRect : Rect2

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
    playerWindow.world_2d = get_window().world_2d


    lightImage = LightTexture.get_image()
    lightImage.resize(lightHeight, lightWidth)
    lightImage.convert(Image.FORMAT_RGBAH)

    darkImage = DarkTexture.get_image()
    darkImage.resize(lightHeight, lightWidth)
    darkImage.convert(Image.FORMAT_RGBAH)

    lightRect = Rect2(Vector2.ZERO, lightImage.get_size())

    offset = Vector2(lightWidth / 2, lightHeight / 2) + Vector2(- fogWidth / 2, - fogHeight / 2)

func update_fog(pos, image):
    fogImage.blend_rect(image, lightRect, pos - offset)
    fogTexture.update(fogImage)


func _process(_delta):
    if Input.is_action_pressed("quit"):
        get_tree().quit()

func _input(event: InputEvent) -> void:

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            pressed = event.pressed

            if pressed:
                update_fog(get_global_mouse_position(), lightImage)

        if event.button_index == MOUSE_BUTTON_RIGHT:
            pressed2 = event.pressed

            if pressed:
                update_fog(get_global_mouse_position(), darkImage)

    elif event is InputEventMouseMotion:
        if pressed:
            update_fog(get_global_mouse_position(), lightImage)
        if pressed2:
            update_fog(get_global_mouse_position(), darkImage)


func _on_file_id_pressed(id: int) -> void:
    if id == 0:
        fileDialog.popup()


func _on_file_dialog_file_selected(path:String) -> void:
    var image = Image.new()
    image.load(path)

    fogImage = Image.create(image.get_size()[0], image.get_size()[1], false, Image.FORMAT_RGBAH)
    fogImage.fill(Color.BLACK)
    fogTexture = ImageTexture.create_from_image(fogImage)
    fog.texture = fogTexture

    var image_texture = ImageTexture.new()
    image_texture.set_image(image)

    background.texture = image_texture
    fog.pos -= image.get_size()
