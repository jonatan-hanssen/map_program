extends Control


@onready var lines: Node2D = $Line2D
@onready var fileMenu: PopupMenu = $GUI/MenuBar/File
@onready var fileDialog: FileDialog = $FileDialog
@onready var camera: Camera2D = $Camera2D
@onready var playerWindow: Window = $PlayerWindow
@onready var fog = $Fog

const LightTexture = preload('res://Light.png')

const lightHeight : int = 50
const lightWidth : int = 50

const fogHeight : int = 800
const fogWidth : int = 800

var fogImage : Image
var fogTexture = ImageTexture
var lightImage : Image
var lightRect : Rect2
var lightOffset : Vector2
var fogOffset : Vector2

var pressed: bool = false
var current_line: Line2D = null


var WIDTH: int = 10
var COLOR = Color.BLUE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    fileMenu.connect('id_pressed', _on_file_id_pressed)
    fileDialog.add_filter("*.png, *.jpg, *.jpeg", "Images")
    playerWindow.world_2d = get_window().world_2d
    fogImage = Image.create(fogWidth, fogHeight, false, Image.FORMAT_RGBAH)
    fogImage.fill(Color.BLACK)
    fogTexture = ImageTexture.create_from_image(fogImage)
    fog.texture = fogTexture

    lightImage = LightTexture.get_image()
    lightImage.resize(lightHeight, lightWidth)
    lightImage.convert(Image.FORMAT_RGBAH)

    lightRect = Rect2(Vector2.ZERO, lightImage.get_size())

    lightOffset = Vector2(lightWidth / 2, lightHeight / 2)
    fogOffset = Vector2(- fogWidth / 2, - fogHeight / 2)

func update_fog(pos):
    print(pos + lightOffset)
    fogImage.blend_rect(lightImage, lightRect, pos - lightOffset - fogOffset)
    fogTexture.update(fogImage)


func _process(_delta):
    if Input.is_action_pressed("quit"):
        get_tree().quit()

func _input(event: InputEvent) -> void:

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            pressed = event.pressed

            if pressed:
                update_fog(get_global_mouse_position())

    elif event is InputEventMouseMotion and pressed:
        # current_line.add_point(get_global_mouse_position())
        print("hey", get_global_mouse_position())
        update_fog(get_global_mouse_position())


func _on_file_id_pressed(id: int) -> void:
    if id == 0:
        fileDialog.popup()


func _on_file_dialog_file_selected(path:String) -> void:
    var image = Image.new()
    image.load(path)

    var image_texture = ImageTexture.new()
    image_texture.set_image(image)

    $Background.texture = image_texture
