extends Node2D

# --- REFERENCIAS A LOS NODOS CORREGIDAS ---
# Según tu tscn, el caldero está en la raíz como 'Sprite2D' y las partículas adentro de él.
@onready var cauldron_sprite = $Sprite2D
@onready var particles = $Sprite2D/GPUParticles2D
@onready var witch = $CharacterBody2D

# --- CONFIGURACIÓN DE COLORES MÁGICOS ---
var color_rojo = Color("#ff4444")   # Rojo vibrante para combinar con tu sprite
var color_azul = Color("#44aaff")   # Azul mágico para tu sprite azul
var color_verde = Color("#44ff44")  # Verde original de la poción base

# --- REFERENCIAS A LAS IMÁGENES (ASSETS) ---
# Asegurate de que los archivos estén guardados exactamente en tu carpeta "assets" con estos nombres
@onready var sprite_rojo = load("res://assets/RedCauldron.png")
@onready var sprite_azul = load("res://assets/BlueCauldron.png")
@onready var sprite_verde = load("res://assets/vecteezy_pixel-art-wizard-s-cauldron-with-magical-potion_72636707.png")

func _ready():
	# Conectamos las señales de los botones de forma limpia
	$CanvasLayer/HBoxContainer/BtnRojo.pressed.connect(_on_btn_rojo_pressed)
	$CanvasLayer/HBoxContainer/BtnAzul.pressed.connect(_on_btn_azul_pressed)
	$CanvasLayer/HBoxContainer/BtnVerde.pressed.connect(_on_btn_verde_pressed)
	
	# Estado inicial: Verde original
	actualizar_sistema_de_colores(color_verde, sprite_verde)

# --- FUNCIONES DE LOS BOTONES ---

func _on_btn_rojo_pressed():
	print("¡Poción de fuego activada!")
	actualizar_sistema_de_colores(color_rojo, sprite_rojo)
	reproducir_animacion_hechizo()

func _on_btn_azul_pressed():
	print("¡Poción de hielo activada!")
	actualizar_sistema_de_colores(color_azul, sprite_azul)
	reproducir_animacion_hechizo()

func _on_btn_verde_pressed():
	print("¡Poción de ácido activada!")
	actualizar_sistema_de_colores(color_verde, sprite_verde)
	reproducir_animacion_hechizo()

# --- LA FUNCIÓN PRINCIPAL QUE TRABAJA LOS RECURSOS ---

func actualizar_sistema_de_colores(nuevo_color: Color, nueva_textura: Texture2D):
	# 1. Cambiar la imagen del caldero al color correspondiente
	if cauldron_sprite and nueva_textura:
		cauldron_sprite.texture = nueva_textura
		
		# IMPORTANTE: Si antes usaste 'modulate' para teñirlo de verde, 
		# hay que resetearlo a blanco (su color original) para que no arruine tus texturas nuevas.
		cauldron_sprite.modulate = Color.WHITE

	# 2. Modificar el gradiente de color de las partículas en tiempo real
	var material_particulas = particles.process_material as ParticleProcessMaterial
	
	# Verificamos si tenés asignado un gradiente en el material
	if material_particulas and material_particulas.color_ramp:
		var textura_gradiente = material_particulas.color_ramp as GradientTexture1D
		var gradiente = textura_gradiente.gradient
		
		if gradiente:
			# Cambiamos el color de inicio del remolino (abajo)
			gradiente.set_color(0, nuevo_color)
			# Cambiamos el color final para que se disuelva en transparente (arriba)
			gradiente.set_color(1, Color(nuevo_color.r, nuevo_color.g, nuevo_color.b, 0))
			
			# Forzamos a Godot a actualizar el cambio de gráficos inmediatamente
			textura_gradiente.emit_changed()
			particles.emit_changed()
	else:
		# Si no hay una curva de gradiente asignada, usamos el color fijo directamente
		material_particulas.color = nuevo_color

# --- EFECTO VISUAL EXTRA ---
func reproducir_animacion_hechizo():
	# Tu brujita usa un AnimatedSprite2D llamado de esa forma por defecto
	if witch.has_node("AnimatedSprite2D"):
		var anim_sprite = witch.get_node("AnimatedSprite2D")
		# Si creás una animación de ataque/hechizo podés reproducirla acá,
		# por ahora dejamos que siga en default para evitar caídas.
		pass
			
	# Generamos un destello/ráfaga: duplicamos temporalmente la cantidad de partículas
	particles.amount = 150
	await get_tree().create_timer(0.4).timeout
	particles.amount = 75  # Volvemos al flujo continuo por defecto de tu tscn
