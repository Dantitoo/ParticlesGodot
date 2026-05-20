extends Node2D

# --- REFERENCIAS A LOS NODOS ADAPTADAS A TU NUEVA ESTRUCTURA ---
# Apuntamos a los tres sprites individuales dentro de la subescena Cauldron
@onready var sprite_verde = $Cauldron/calderonVerde
@onready var sprite_rojo = $Cauldron/calderonRojo
@onready var sprite_azul = $Cauldron/calderonAzul

# Las partículas que están adentro de la subescena Cauldron
@onready var particles = $Cauldron/GPUParticles2D

# --- CONFIGURACIÓN DE COLORES PARA LAS PARTÍCULAS ---
var color_rojo = Color("#ff4444")   # Rojo fuego
var color_azul = Color("#44aaff")   # Azul hielo
var color_verde = Color("#44ff44")  # Verde ácido base

func _ready():
	# Conexión limpia de los botones por código
	$CanvasLayer/HBoxContainer/BtnRojo.pressed.connect(_on_btn_rojo_pressed)
	$CanvasLayer/HBoxContainer/BtnAzul.pressed.connect(_on_btn_azul_pressed)
	$CanvasLayer/HBoxContainer/BtnVerde.pressed.connect(_on_btn_verde_pressed)
	
	# Estado inicial: Mostramos el verde y ocultamos el resto
	actualizar_visibilidad_y_particulas(sprite_verde, color_verde)

# --- FUNCIONES DE LOS BOTONES ---

func _on_btn_rojo_pressed():
	print("¡Poción de fuego activada!")
	actualizar_visibilidad_y_particulas(sprite_rojo, color_rojo)

func _on_btn_azul_pressed():
	print("¡Poción de hielo activada!")
	actualizar_visibilidad_y_particulas(sprite_azul, color_azul)

func _on_btn_verde_pressed():
	print("¡Poción de ácido activada!")
	actualizar_visibilidad_y_particulas(sprite_verde, color_verde)

# --- FUNCIÓN PRINCIPAL DE CONTROL ---

func actualizar_visibilidad_y_particulas(sprite_activo: Sprite2D, nuevo_color: Color):
	# 1. CONTROL DE VISIBILIDAD DE LOS CALDEROS
	# Apagamos los tres primero de forma limpia
	sprite_verde.visible = false
	sprite_rojo.visible = false
	sprite_azul.visible = false
	
	# Prendemos únicamente el seleccionado por el botón
	if sprite_activo:
		sprite_activo.visible = true

	# 2. MODIFICAR EL COLOR DE LAS PARTÍCULAS
	var material_particulas = particles.process_material as ParticleProcessMaterial
	
	if material_particulas and material_particulas.color_ramp:
		var textura_gradiente = material_particulas.color_ramp as GradientTexture1D
		var gradiente = textura_gradiente.gradient
		
		if gradiente:
			# El remolino arranca con el color de la poción y se desvanece arriba
			gradiente.set_color(0, nuevo_color)
			gradiente.set_color(1, Color(nuevo_color.r, nuevo_color.g, nuevo_color.b, 0))
			
			# Forzamos la actualización de los gráficos de las partículas
			textura_gradiente.emit_changed()
			particles.emit_changed()
	else:
		# Si no hay rampa de gradiente asignada, cambia el color plano directo
		material_particulas.color = nuevo_color
